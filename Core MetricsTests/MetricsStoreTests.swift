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
    @Test("Stopped sampling discards in-flight results", arguments: StoppedMetric.allCases)
    func stopDiscardsInFlightResults(metric: StoppedMetric) async throws {
        let shutdown = SamplingShutdown()
        let store = MetricsStore(
            cpuProvider: FixedCPUProvider {
                if metric == .cpu { shutdown.stop() }
            },
            memoryProvider: FixedMemoryProvider {
                if metric == .memory { shutdown.stop() }
            },
            storageProvider: FixedStorageProvider {
                if metric == .storage { shutdown.stop() }
            },
            fastSamplingInterval: .seconds(60),
            storageSamplingInterval: .seconds(60)
        )
        shutdown.store = store

        store.start()
        defer { store.stop() }

        let stopped = await eventually { shutdown.task != nil }
        try #require(stopped)
        let task = try #require(shutdown.task)
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

nonisolated enum StoppedMetric: CaseIterable, Sendable {
    case cpu, memory, storage
}

@MainActor
private final class SamplingShutdown {
    weak var store: MetricsStore?
    private(set) var task: Task<Void, Never>?

    func stop() {
        task = store?.stop()
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

// Synchronous fixture callbacks complete the main-actor stop before returning
// a result. The real provider boundary runs off-main, so the test can await
// shutdown completion without sleeps or holding a blocked main actor.
private nonisolated struct FixedCPUProvider: CPUMetricsProviding {
    var onSample: (@MainActor @Sendable () -> Void)? = nil

    mutating func sample(isContinuous: Bool) throws -> CPUUsage? {
        if let onSample {
            DispatchQueue.main.sync { onSample() }
        }
        return MetricsStoreTests.cpuUsage
    }

    mutating func reset() {}
}

private nonisolated struct FixedMemoryProvider: MemoryMetricsProviding {
    var onSample: (@MainActor @Sendable () -> Void)? = nil

    mutating func sample() throws -> MemoryUsage? {
        if let onSample {
            DispatchQueue.main.sync { onSample() }
        }
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
    var onSample: (@MainActor @Sendable () -> Void)? = nil

    func sample() throws -> StorageUsage? {
        if let onSample {
            DispatchQueue.main.sync { onSample() }
        }
        return StorageUsage(
            usedBytes: 75,
            availableBytes: 25,
            totalBytes: 100
        )
    }
}
