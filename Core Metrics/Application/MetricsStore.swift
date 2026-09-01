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
    private(set) var isSampling = false
    private(set) var hasSamplingIssue = false

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
    @ObservationIgnored private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "CoreMetrics",
        category: "Metrics"
    )
    @ObservationIgnored private var samplingTask: Task<Void, Never>?
    @ObservationIgnored private var cpuSamplingFailed = false
    @ObservationIgnored private var memorySamplingFailed = false
    @ObservationIgnored private var storageSamplingFailed = false

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
                            let usage = try cpuProvider.sample(isContinuous: isContinuous)
                            await self?.recordCPU(usage)
                        } catch {
                            // A failed read invalidates the delta baseline but
                            // does not leave a stale value presented as live.
                            cpuProvider.reset()
                            await self?.recordCPUFailure()
                        }

                        do {
                            let usage = try memoryProvider.sample()
                            await self?.recordMemory(usage)
                        } catch {
                            await self?.recordMemoryFailure()
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
                            let usage = try storageProvider.sample()
                            await self?.recordStorage(usage)
                        } catch {
                            await self?.recordStorageFailure()
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
        cpuSamplingFailed = false
        memorySamplingFailed = false
        storageSamplingFailed = false
        hasSamplingIssue = false
    }

    private func recordCPU(_ usage: CPUUsage?) {
        cpuUsage = usage
        guard let usage else {
            updateSamplingIssue()
            return
        }

        if cpuSamplingFailed {
            logger.notice("CPU sampling recovered")
        }
        cpuSamplingFailed = false
        cpuHistoryBuffer.append(usage)
        updateSamplingIssue()
    }

    private func recordMemory(_ usage: MemoryUsage?) {
        memoryUsage = usage
        guard let usage else {
            if !memorySamplingFailed {
                logger.error("Memory sampling became unavailable")
            }
            memorySamplingFailed = true
            updateSamplingIssue()
            return
        }

        if memorySamplingFailed {
            logger.notice("Memory sampling recovered")
        }
        memorySamplingFailed = false
        memoryHistoryBuffer.append(usage)
        updateSamplingIssue()
    }

    private func recordStorage(_ usage: StorageUsage?) {
        storageUsage = usage
        guard usage != nil else {
            if !storageSamplingFailed {
                logger.error("Storage sampling became unavailable")
            }
            storageSamplingFailed = true
            updateSamplingIssue()
            return
        }

        if storageSamplingFailed {
            logger.notice("Storage sampling recovered")
        }
        storageSamplingFailed = false
        updateSamplingIssue()
    }

    private func recordCPUFailure() {
        if !cpuSamplingFailed {
            logger.error("CPU sampling became unavailable")
        }
        cpuSamplingFailed = true
        cpuUsage = nil
        updateSamplingIssue()
    }

    private func recordMemoryFailure() {
        if !memorySamplingFailed {
            logger.error("Memory sampling became unavailable")
        }
        memorySamplingFailed = true
        memoryUsage = nil
        updateSamplingIssue()
    }

    private func recordStorageFailure() {
        if !storageSamplingFailed {
            logger.error("Storage sampling became unavailable")
        }
        storageSamplingFailed = true
        storageUsage = nil
        updateSamplingIssue()
    }

    private func updateSamplingIssue() {
        hasSamplingIssue = cpuSamplingFailed
            || memorySamplingFailed
            || storageSamplingFailed
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
