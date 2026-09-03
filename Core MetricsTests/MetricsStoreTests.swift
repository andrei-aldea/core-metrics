import Foundation
import Synchronization
import Testing
@testable import Core_Metrics

@Suite("Metrics store health")
struct MetricsStoreTests {
    @MainActor
    @Test("A failed sample clears stale data")
    func failureClearsStaleData() async {
        let store = MetricsStore(
            cpuProvider: FailsAfterFirstCPUProvider(),
            memoryProvider: FixedMemoryProvider(),
            storageProvider: FixedStorageProvider(),
            fastSamplingInterval: .milliseconds(10),
            storageSamplingInterval: .seconds(60)
        )

        store.start()
        defer { store.stop() }

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

private nonisolated enum FixtureProviderError: Error {
    case unavailable
}

private nonisolated struct FailsAfterFirstCPUProvider: CPUMetricsProviding {
    private var sampleCount = 0

    mutating func sample(isContinuous: Bool) throws -> CPUUsage? {
        defer { sampleCount += 1 }

        guard sampleCount == 0 else {
            throw FixtureProviderError.unavailable
        }

        return MetricsStoreTests.cpuUsage
    }

    mutating func reset() {}
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

private nonisolated struct FixedMemoryProvider: MemoryMetricsProviding {
    mutating func sample() throws -> MemoryUsage? {
        MemoryUsage(
            usedBytes: 60,
            cachedBytes: 40,
            swapUsedBytes: 5
        )
    }
}

private nonisolated struct FixedStorageProvider: StorageMetricsProviding {
    func sample() throws -> StorageUsage? {
        StorageUsage(
            usedBytes: 75,
            availableBytes: 25,
            totalBytes: 100
        )
    }
}
