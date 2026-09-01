import Foundation
import Testing
@testable import Core_Metrics

@Suite("Metrics store health")
struct MetricsStoreTests {
    @MainActor
    @Test("A failed sample clears stale data and marks sampling limited")
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

        let reachedLimitedState = await eventually {
            store.cpuUsage == nil
                && store.memoryUsage != nil
                && store.storageUsage != nil
                && store.hasSamplingIssue
        }

        #expect(reachedLimitedState)
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
        #expect(store.hasSamplingIssue)

        recoveryGate.allowValueSamples()
        let recovered = await eventually {
            store.cpuUsage == Self.cpuUsage
                && store.memoryUsage != nil
                && store.storageUsage != nil
                && !store.hasSamplingIssue
        }

        #expect(recovered)
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

            try? await Task.sleep(for: .milliseconds(5))
        }

        return condition()
    }

    fileprivate nonisolated static let cpuUsage = CPUUsage(
        total: 0.5,
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

private nonisolated final class RecoveryGate: @unchecked Sendable {
    enum Sample {
        case failure
        case baseline
        case value
    }

    private let lock = NSLock()
    private var count = 0
    private var valuesAreAllowed = false

    var sampleCount: Int {
        lock.withLock { count }
    }

    func nextSample() -> Sample {
        lock.withLock {
            defer { count += 1 }

            if count == 0 {
                return .failure
            }

            return valuesAreAllowed ? .value : .baseline
        }
    }

    func allowValueSamples() {
        lock.withLock {
            valuesAreAllowed = true
        }
    }
}

private nonisolated struct FixedMemoryProvider: MemoryMetricsProviding {
    mutating func sample() throws -> MemoryUsage? {
        MemoryUsage(
            usedBytes: 60,
            availableBytes: 40,
            totalBytes: 100,
            usedFraction: 0.6
        )
    }
}

private nonisolated struct FixedStorageProvider: StorageMetricsProviding {
    func sample() throws -> StorageUsage? {
        StorageUsage(
            usedBytes: 75,
            availableBytes: 25,
            totalBytes: 100,
            usedFraction: 0.75
        )
    }
}
