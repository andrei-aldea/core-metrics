import Foundation
import Observation

/// Main-actor-owned, observable state for the current metrics and their short
/// in-memory histories.
@MainActor
@Observable
final class MetricsStore {
    private(set) var cpuUsage: CPUUsage?
    private(set) var memoryUsage: MemoryUsage?
    private(set) var storageUsage: StorageUsage?
    private(set) var isSampling = false

    private var cpuHistoryBuffer: RingBuffer<CPUUsage>
    private var memoryHistoryBuffer: RingBuffer<MemoryUsage>

    var cpuHistory: [CPUUsage] {
        cpuHistoryBuffer.elements
    }

    var memoryHistory: [MemoryUsage] {
        memoryHistoryBuffer.elements
    }

    @ObservationIgnored private let initialCPUProvider: any CPUMetricsProviding
    @ObservationIgnored private let initialMemoryProvider: any MemoryMetricsProviding
    @ObservationIgnored private let storageProvider: any StorageMetricsProviding
    @ObservationIgnored private let fastSamplingInterval: Duration
    @ObservationIgnored private let storageSamplingInterval: Duration
    @ObservationIgnored private let longGapThreshold: TimeInterval
    @ObservationIgnored private var samplingTask: Task<Void, Never>?

    init(
        cpuProvider: any CPUMetricsProviding = CPUMetricsProvider(),
        memoryProvider: any MemoryMetricsProviding = MemoryMetricsProvider(),
        storageProvider: any StorageMetricsProviding = RootVolumeStorageProvider(),
        fastSamplingInterval: Duration = .seconds(1),
        storageSamplingInterval: Duration = .seconds(30),
        longGapThreshold: TimeInterval = 5,
        historyCapacity: Int = 120
    ) {
        precondition(fastSamplingInterval > .zero)
        precondition(storageSamplingInterval > .zero)
        precondition(longGapThreshold > 0)
        precondition(historyCapacity > 0)

        initialCPUProvider = cpuProvider
        initialMemoryProvider = memoryProvider
        self.storageProvider = storageProvider
        self.fastSamplingInterval = fastSamplingInterval
        self.storageSamplingInterval = storageSamplingInterval
        self.longGapThreshold = longGapThreshold
        cpuHistoryBuffer = RingBuffer(capacity: historyCapacity)
        memoryHistoryBuffer = RingBuffer(capacity: historyCapacity)
    }

    deinit {
        samplingTask?.cancel()
    }

    /// Starts one owned sampling task. Its CPU/memory and storage loops are
    /// structured child tasks and stop cooperatively when this task is
    /// cancelled.
    func start() {
        guard samplingTask == nil else {
            return
        }

        let cpuProvider = initialCPUProvider
        let memoryProvider = initialMemoryProvider
        let storageProvider = storageProvider
        let fastInterval = fastSamplingInterval
        let storageInterval = storageSamplingInterval
        let gapThreshold = longGapThreshold

        isSampling = true
        samplingTask = Task { @concurrent [weak self] in
            await withTaskGroup(of: Void.self) { group in
                group.addTask { [weak self] in
                    var cpuProvider = cpuProvider
                    var memoryProvider = memoryProvider
                    var previousWallSampleDate: Date?

                    while !Task.isCancelled {
                        guard self != nil else {
                            return
                        }

                        let wallSampleDate = Date.now
                        let isContinuous = Self.isContinuous(
                            from: previousWallSampleDate,
                            to: wallSampleDate,
                            threshold: gapThreshold
                        )
                        previousWallSampleDate = wallSampleDate

                        do {
                            if let usage = try cpuProvider.sample(isContinuous: isContinuous) {
                                await self?.recordCPU(usage)
                            }
                        } catch {
                            // A failed read invalidates the delta baseline but
                            // intentionally preserves the last published value.
                            cpuProvider.reset()
                        }

                        do {
                            if let usage = try memoryProvider.sample() {
                                await self?.recordMemory(usage)
                            }
                        } catch {
                            // Preserve the last good value and retry next time.
                        }

                        do {
                            try await Task.sleep(for: fastInterval)
                        } catch {
                            return
                        }
                    }
                }

                group.addTask { [weak self] in
                    while !Task.isCancelled {
                        guard self != nil else {
                            return
                        }

                        do {
                            if let usage = try storageProvider.sample() {
                                await self?.recordStorage(usage)
                            }
                        } catch {
                            // Preserve the last good value and retry next time.
                        }

                        do {
                            try await Task.sleep(for: storageInterval)
                        } catch {
                            return
                        }
                    }
                }

                await group.waitForAll()
            }
        }
    }

    func stop() {
        samplingTask?.cancel()
        samplingTask = nil
        isSampling = false
    }

    private func recordCPU(_ usage: CPUUsage) {
        cpuUsage = usage
        cpuHistoryBuffer.append(usage)
    }

    private func recordMemory(_ usage: MemoryUsage) {
        memoryUsage = usage
        memoryHistoryBuffer.append(usage)
    }

    private func recordStorage(_ usage: StorageUsage) {
        storageUsage = usage
    }

    private nonisolated static func isContinuous(
        from previous: Date?,
        to current: Date,
        threshold: TimeInterval
    ) -> Bool {
        guard let previous else {
            return false
        }

        let elapsed = current.timeIntervalSince(previous)
        return elapsed >= 0 && elapsed <= threshold
    }
}
