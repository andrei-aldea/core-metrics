import Foundation
import Observation
import OSLog

/// Main-actor-owned, observable state for the current metrics and their short
/// in-memory histories.
@MainActor
@Observable
final class MetricsStore {
    private(set) var cpuUsage: CPUUsage?
    private(set) var memoryUsage: MemoryUsage?
    private(set) var storageUsage: StorageUsage?
    private(set) var cpuSampleState: MetricSampleState = .collecting
    private(set) var memorySampleState: MetricSampleState = .collecting
    private(set) var storageSampleState: MetricSampleState = .collecting
    private(set) var isSampling = false

    private var cpuHistoryBuffer: RingBuffer<CPUUsage>
    private var memoryHistoryBuffer: RingBuffer<MemoryUsage>

    var cpuHistory: [CPUUsage] {
        cpuHistoryBuffer.elements
    }

    var memoryHistory: [MemoryUsage] {
        memoryHistoryBuffer.elements
    }

    var hasSamplingIssue: Bool {
        cpuSampleState == .unavailable
            || memorySampleState == .unavailable
            || storageSampleState == .unavailable
    }

    @ObservationIgnored private let initialCPUProvider: any CPUMetricsProviding
    @ObservationIgnored private let initialMemoryProvider: any MemoryMetricsProviding
    @ObservationIgnored private let storageProvider: any StorageMetricsProviding
    @ObservationIgnored private let fastSamplingInterval: Duration
    @ObservationIgnored private let storageSamplingInterval: Duration
    @ObservationIgnored private let longGapThreshold: TimeInterval
    @ObservationIgnored private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "CoreMetrics",
        category: "Metrics"
    )
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
        samplingTask = Task(priority: .utility) { @concurrent [weak self] in
            await withDiscardingTaskGroup { group in
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

                        let cpuUsage: CPUUsage?
                        let cpuFailed: Bool
                        do {
                            cpuUsage = try cpuProvider.sample(isContinuous: isContinuous)
                            cpuFailed = false
                        } catch {
                            // A failed read invalidates the delta baseline but
                            // does not leave a stale value presented as live.
                            cpuProvider.reset()
                            cpuUsage = nil
                            cpuFailed = true
                        }

                        let memoryUsage: MemoryUsage?
                        let memoryFailed: Bool
                        do {
                            memoryUsage = try memoryProvider.sample()
                            memoryFailed = memoryUsage == nil
                        } catch {
                            memoryUsage = nil
                            memoryFailed = true
                        }

                        await self?.recordFastSample(
                            cpuUsage: cpuUsage,
                            cpuFailed: cpuFailed,
                            memoryUsage: memoryUsage,
                            memoryFailed: memoryFailed
                        )

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

                        let shouldRetryQuickly: Bool
                        do {
                            let usage = try storageProvider.sample()
                            await self?.recordStorage(usage)
                            shouldRetryQuickly = usage == nil
                        } catch {
                            await self?.recordStorageFailure()
                            shouldRetryQuickly = true
                        }

                        do {
                            try await Task.sleep(
                                for: shouldRetryQuickly ? fastInterval : storageInterval
                            )
                        } catch {
                            return
                        }
                    }
                }

            }
        }
    }

    func stop() {
        samplingTask?.cancel()
        samplingTask = nil
        isSampling = false
    }

    /// Applies the fast CPU and memory results in one main-actor hop, keeping
    /// the off-actor acquisition loop from scheduling separate UI work items.
    private func recordFastSample(
        cpuUsage: CPUUsage?,
        cpuFailed: Bool,
        memoryUsage: MemoryUsage?,
        memoryFailed: Bool
    ) {
        if cpuFailed {
            recordCPUFailure()
        } else {
            recordCPU(cpuUsage)
        }

        if memoryFailed {
            recordMemoryFailure()
        } else {
            recordMemory(memoryUsage)
        }
    }

    private func recordCPU(_ usage: CPUUsage?) {
        cpuUsage = usage
        guard let usage else {
            if cpuSampleState != .unavailable {
                cpuSampleState = .collecting
            }
            return
        }

        if cpuSampleState == .unavailable {
            logger.notice("CPU sampling recovered")
        }
        cpuSampleState = .available
        cpuHistoryBuffer.append(usage)
    }

    private func recordMemory(_ usage: MemoryUsage?) {
        memoryUsage = usage
        guard let usage else {
            if memorySampleState != .unavailable {
                logger.error("Memory sampling became unavailable")
            }
            memorySampleState = .unavailable
            return
        }

        if memorySampleState == .unavailable {
            logger.notice("Memory sampling recovered")
        }
        memorySampleState = .available
        memoryHistoryBuffer.append(usage)
    }

    private func recordStorage(_ usage: StorageUsage?) {
        storageUsage = usage
        guard usage != nil else {
            if storageSampleState != .unavailable {
                logger.error("Storage sampling became unavailable")
            }
            storageSampleState = .unavailable
            return
        }

        if storageSampleState == .unavailable {
            logger.notice("Storage sampling recovered")
        }
        storageSampleState = .available
    }

    private func recordCPUFailure() {
        if cpuSampleState != .unavailable {
            logger.error("CPU sampling became unavailable")
        }
        cpuSampleState = .unavailable
        cpuUsage = nil
    }

    private func recordMemoryFailure() {
        if memorySampleState != .unavailable {
            logger.error("Memory sampling became unavailable")
        }
        memorySampleState = .unavailable
        memoryUsage = nil
    }

    private func recordStorageFailure() {
        if storageSampleState != .unavailable {
            logger.error("Storage sampling became unavailable")
        }
        storageSampleState = .unavailable
        storageUsage = nil
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
