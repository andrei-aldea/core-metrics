import Foundation
import Synchronization
import Testing
@testable import Core_Metrics

@Suite("Metrics store health")
struct MetricsStoreTests {
    @MainActor
    @Test("A failed sample clears stale data")
    func failureClearsStaleData() async throws {
        let failureGate = FailureGate()
        let store = MetricsStore(
            cpuProvider: ControlledFailureCPUProvider(gate: failureGate),
            memoryProvider: FixedMemoryProvider(),
            storageProvider: FixedStorageProvider(),
            fastSamplingInterval: .milliseconds(10),
            storageSamplingInterval: .seconds(60)
        )

        store.start()
        defer { store.stop() }

        let publishedSample = await eventually {
            store.cpuUsage == Self.cpuUsage
        }
        try #require(publishedSample)

        failureGate.failSubsequentSamples()
        let clearedStaleSample = await eventually {
            store.cpuUsage == nil
                && store.memoryUsage != nil
                && store.storageUsage != nil
        }

        #expect(clearedStaleSample)
    }

    @MainActor
    @Test("A recovered provider restores live data")
    func recoveryRestoresLiveData() async {
        let recoveryGate = RecoveryGate()
        let store = MetricsStore(
            cpuProvider: ControlledRecoveryCPUProvider(gate: recoveryGate),
            memoryProvider: FixedMemoryProvider(),
            storageProvider: FixedStorageProvider(),
            fastSamplingInterval: .milliseconds(10),
            storageSamplingInterval: .seconds(60)
        )

        store.start()
        defer { store.stop() }

        let reachedBaselineAfterFailure = await eventually {
            recoveryGate.sampleCount >= 2
        }
        #expect(reachedBaselineAfterFailure)
        #expect(store.cpuUsage == nil)

        recoveryGate.allowValueSamples()
        let recovered = await eventually {
            store.cpuUsage == Self.cpuUsage
                && store.memoryUsage != nil
                && store.storageUsage != nil
        }

        #expect(recovered)
    }

    @MainActor
    @Test("Shutdown rejects cancelled provider results", arguments: CancelledMetric.allCases)
    func shutdownRejectsCancelledProviderResults(metric: CancelledMetric) async throws {
        let cancellation = SamplingCancellation()
        let store = MetricsStore(
            cpuProvider: FixedCPUProvider {
                if metric == .cpu { cancellation.cancelCurrentSample() }
            },
            memoryProvider: FixedMemoryProvider {
                if metric == .memory { cancellation.cancelCurrentSample() }
            },
            storageProvider: FixedStorageProvider {
                if metric == .storage { cancellation.cancelCurrentSample() }
            },
            fastSamplingInterval: .seconds(60),
            storageSamplingInterval: .seconds(60)
        )

        store.start()
        defer { store.stop() }

        let cancelled = await eventually { cancellation.didCancel }
        try #require(cancelled)
        // Exercise the complete shutdown contract. Cancellation and session
        // invalidation cooperate here; neither guard is tested in isolation.
        let task = try #require(store.stop())
        await task.value

        switch metric {
        case .cpu, .memory:
            #expect(store.cpuUsage == nil)
            #expect(store.memoryUsage == nil)
        case .storage:
            #expect(store.storageUsage == nil)
        }
    }

    @MainActor
    @Test("Stopping before the first publication leaves every reading unavailable")
    func immediateStopRejectsFirstPublication() async throws {
        let store = MetricsStore(
            cpuProvider: FixedCPUProvider(),
            memoryProvider: FixedMemoryProvider(),
            storageProvider: FixedStorageProvider()
        )

        // Keep the main actor until stop has invalidated the session. Even if
        // a provider finishes on another executor, it cannot publish yet.
        store.start()
        let task = try #require(store.stop())
        await task.value

        #expect(store.cpuUsage == nil)
        #expect(store.memoryUsage == nil)
        #expect(store.storageUsage == nil)
        #expect(store.stop() == nil)
    }

    @MainActor
    @Test("Restarted CPU sampling replaces the old value with a fresh baseline")
    func restartEstablishesFreshCPUBaseline() async throws {
        let gate = CPUContinuityGate()
        let store = MetricsStore(
            cpuProvider: ContinuityCPUProvider(gate: gate),
            memoryProvider: FixedMemoryProvider(),
            storageProvider: FixedStorageProvider(),
            fastSamplingInterval: .milliseconds(20),
            storageSamplingInterval: .seconds(60)
        )
        store.start()
        defer { store.stop() }

        try #require(await eventually { store.cpuUsage == Self.cpuUsage })
        let stoppedTask = try #require(store.stop())
        await stoppedTask.value

        // Hold the nil value without blocking the sampling task, so a busy
        // main actor cannot miss a transient baseline between two samples.
        gate.holdRestartBaseline()
        store.start()
        try #require(await eventually {
            store.cpuUsage == nil && gate.restartBaselineIsContinuous != nil
        })
        #expect(gate.restartBaselineIsContinuous == false)
        gate.releaseValues()
        #expect(await eventually { store.cpuUsage == Self.cpuUsage })
    }

    @MainActor
    @Test("Memory failures clear only memory values and recovery restores them")
    func memoryFailureAndRecoveryPreserveOtherMetrics() async throws {
        let gate = MemoryRecoveryGate()
        let store = MetricsStore(
            cpuProvider: FixedCPUProvider(),
            memoryProvider: ControlledMemoryProvider(gate: gate),
            storageProvider: FixedStorageProvider(),
            fastSamplingInterval: .milliseconds(10),
            storageSamplingInterval: .seconds(60)
        )
        store.start()
        defer { store.stop() }

        try #require(await eventually {
            store.cpuUsage != nil && store.memoryUsage != nil && store.storageUsage != nil
        })

        gate.setUnavailable(true)
        try #require(await eventually { store.memoryUsage == nil })
        #expect(store.cpuUsage == Self.cpuUsage)
        #expect(store.storageUsage != nil)

        gate.setUnavailable(false)
        #expect(await eventually { store.memoryUsage != nil })
    }

    @MainActor
    @Test("Storage failure retries promptly instead of waiting for its normal cadence")
    func storageFailureRetriesPromptly() async {
        let recoveryGate = StorageRecoveryGate()
        let store = MetricsStore(
            cpuProvider: ControlledRecoveryCPUProvider(
                gate: RecoveryGate(valuesAreAllowed: true)
            ),
            memoryProvider: FixedMemoryProvider(),
            storageProvider: ControlledRecoveryStorageProvider(gate: recoveryGate),
            fastSamplingInterval: .milliseconds(10),
            storageSamplingInterval: .seconds(60)
        )

        store.start()
        defer { store.stop() }

        let failed = await eventually {
            recoveryGate.sampleCount >= 1
                && store.storageUsage == nil
        }
        #expect(failed)

        recoveryGate.allowValueSamples()
        let recovered = await eventually {
            recoveryGate.sampleCount >= 2
                && store.storageUsage != nil
        }

        #expect(recovered)
    }

    @MainActor
    @Test("The owned sampling task does not retain the store")
    func samplingTaskDoesNotRetainStore() async {
        var store: MetricsStore? = MetricsStore(
            cpuProvider: ControlledRecoveryCPUProvider(
                gate: RecoveryGate(valuesAreAllowed: true)
            ),
            memoryProvider: FixedMemoryProvider(),
            storageProvider: FixedStorageProvider(),
            fastSamplingInterval: .seconds(60),
            storageSamplingInterval: .seconds(60)
        )
        weak let weakStore = store

        store?.start()
        store = nil

        let deallocated = await eventually {
            weakStore == nil
        }
        #expect(deallocated)
    }

    @MainActor
    private func eventually(
        attempts: Int = 100,
        condition: @MainActor () -> Bool
    ) async -> Bool {
        for _ in 0..<attempts {
            if condition() {
                return true
            }

            do {
                try await Task.sleep(for: .milliseconds(5))
            } catch {
                return false
            }
        }

        return condition()
    }

    fileprivate nonisolated static let cpuUsage = CPUUsage(
        user: 0.3,
        system: 0.2,
        idle: 0.5
    )
}

nonisolated enum CancelledMetric: CaseIterable, Sendable {
    case cpu, memory, storage
}

private nonisolated final class SamplingCancellation: Sendable {
    private let cancelled = Mutex(false)

    var didCancel: Bool {
        cancelled.withLock { $0 }
    }

    func cancelCurrentSample() {
        withUnsafeCurrentTask { task in
            task?.cancel()
        }
        cancelled.withLock { $0 = true }
    }
}

private nonisolated enum FixtureProviderError: Error {
    case unavailable
}

private nonisolated struct ControlledFailureCPUProvider: CPUMetricsProviding {
    let gate: FailureGate

    mutating func sample(isContinuous: Bool) throws -> CPUUsage? {
        guard !gate.shouldFail else {
            throw FixtureProviderError.unavailable
        }

        return MetricsStoreTests.cpuUsage
    }

    mutating func reset() {}
}

private nonisolated struct ContinuityCPUProvider: CPUMetricsProviding {
    let gate: CPUContinuityGate
    private var hasSampled = false

    init(gate: CPUContinuityGate) {
        self.gate = gate
    }

    mutating func sample(isContinuous: Bool) throws -> CPUUsage? {
        defer { hasSampled = true }
        return gate.sample(isContinuous: isContinuous, isFirstSample: !hasSampled)
    }

    mutating func reset() {}
}

private nonisolated final class CPUContinuityGate: Sendable {
    private struct State: Sendable {
        var holdsValues = false
        var restartBaselineIsContinuous: Bool?
    }

    private let state = Mutex(State())

    var restartBaselineIsContinuous: Bool? {
        state.withLock { $0.restartBaselineIsContinuous }
    }

    func holdRestartBaseline() {
        state.withLock {
            $0.holdsValues = true
            $0.restartBaselineIsContinuous = nil
        }
    }

    func releaseValues() {
        state.withLock { $0.holdsValues = false }
    }

    func sample(isContinuous: Bool, isFirstSample: Bool) -> CPUUsage? {
        state.withLock { state in
            if state.holdsValues {
                if isFirstSample {
                    state.restartBaselineIsContinuous = isContinuous
                }
                return nil
            }
            return isContinuous ? MetricsStoreTests.cpuUsage : nil
        }
    }
}

private nonisolated struct ControlledMemoryProvider: MemoryMetricsProviding {
    let gate: MemoryRecoveryGate

    mutating func sample() throws -> MemoryUsage? {
        guard !gate.isUnavailable else {
            throw FixtureProviderError.unavailable
        }
        var provider = FixedMemoryProvider()
        return try provider.sample()
    }
}

private nonisolated final class MemoryRecoveryGate: Sendable {
    private let unavailable = Mutex(false)

    var isUnavailable: Bool {
        unavailable.withLock { $0 }
    }

    func setUnavailable(_ value: Bool) {
        unavailable.withLock { $0 = value }
    }
}

private nonisolated final class FailureGate: Sendable {
    private let failure = Mutex(false)

    var shouldFail: Bool {
        failure.withLock { $0 }
    }

    func failSubsequentSamples() {
        failure.withLock { $0 = true }
    }
}

private nonisolated struct ControlledRecoveryCPUProvider: CPUMetricsProviding {
    let gate: RecoveryGate

    mutating func sample(isContinuous: Bool) throws -> CPUUsage? {
        switch gate.nextSample() {
        case .failure:
            throw FixtureProviderError.unavailable
        case .baseline:
            return nil
        case .value:
            return MetricsStoreTests.cpuUsage
        }
    }

    mutating func reset() {}
}

private nonisolated final class RecoveryGate: Sendable {
    enum Sample: Sendable {
        case failure
        case baseline
        case value
    }

    private struct State: Sendable {
        var count = 0
        var valuesAreAllowed: Bool
    }

    private let state: Mutex<State>

    init(valuesAreAllowed: Bool = false) {
        state = Mutex(State(valuesAreAllowed: valuesAreAllowed))
    }

    var sampleCount: Int {
        state.withLock { $0.count }
    }

    func nextSample() -> Sample {
        state.withLock { state in
            defer { state.count += 1 }

            if state.count == 0 {
                return .failure
            }

            return state.valuesAreAllowed ? .value : .baseline
        }
    }

    func allowValueSamples() {
        state.withLock { state in
            state.valuesAreAllowed = true
        }
    }
}

private nonisolated struct ControlledRecoveryStorageProvider: StorageMetricsProviding {
    let gate: StorageRecoveryGate

    func sample() throws -> StorageUsage? {
        guard gate.nextSampleShouldSucceed() else {
            throw FixtureProviderError.unavailable
        }

        return try FixedStorageProvider().sample()
    }
}

private nonisolated final class StorageRecoveryGate: Sendable {
    private struct State: Sendable {
        var count = 0
        var valuesAreAllowed = false
    }

    private let state = Mutex(State())

    var sampleCount: Int {
        state.withLock { $0.count }
    }

    func nextSampleShouldSucceed() -> Bool {
        state.withLock { state in
            state.count += 1
            return state.valuesAreAllowed
        }
    }

    func allowValueSamples() {
        state.withLock { state in
            state.valuesAreAllowed = true
        }
    }
}

// These callbacks act within the provider's existing task. Cancelling that
// task before returning a sample requires no blocked executor or main-queue hop.
private nonisolated struct FixedCPUProvider: CPUMetricsProviding {
    var onSample: (@Sendable () -> Void)? = nil

    mutating func sample(isContinuous: Bool) throws -> CPUUsage? {
        onSample?()
        return MetricsStoreTests.cpuUsage
    }

    mutating func reset() {}
}

private nonisolated struct FixedMemoryProvider: MemoryMetricsProviding {
    var onSample: (@Sendable () -> Void)? = nil

    mutating func sample() throws -> MemoryUsage? {
        onSample?()
        return MemoryUsage(
            usedBytes: 60,
            cachedBytes: 40,
            swapUsedBytes: 5,
            wiredBytes: 20,
            compressedBytes: 10,
            totalBytes: 100
        )
    }
}

private nonisolated struct FixedStorageProvider: StorageMetricsProviding {
    var onSample: (@Sendable () -> Void)? = nil

    func sample() throws -> StorageUsage? {
        onSample?()
        return StorageUsage(
            usedBytes: 75,
            availableBytes: 25,
            totalBytes: 100
        )
    }
}
