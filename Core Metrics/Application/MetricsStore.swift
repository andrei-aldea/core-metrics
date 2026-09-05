import Foundation
import Observation
import OSLog

/// Main-actor-owned observable state for the current aggregate metrics.
@MainActor
@Observable
final class MetricsStore {
    private enum SampleKind: String, Hashable {
        case cpu = "CPU"
        case memory = "Memory"
        case storage = "Storage"
    }

    private(set) var cpuUsage: CPUUsage?
    private(set) var memoryUsage: MemoryUsage?
    private(set) var storageUsage: StorageUsage?

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
    @ObservationIgnored private var unavailableMetrics: Set<SampleKind> = []
    @ObservationIgnored private var samplingTask: Task<Void, Never>?
    @ObservationIgnored private var samplingID: UUID?

    init(
        cpuProvider: any CPUMetricsProviding = CPUMetricsProvider(),
        memoryProvider: any MemoryMetricsProviding = MemoryMetricsProvider(),
        storageProvider: any StorageMetricsProviding = RootVolumeStorageProvider(),
        fastSamplingInterval: Duration = .seconds(2),
        storageSamplingInterval: Duration = .seconds(30),
        longGapThreshold: TimeInterval = 5
    ) {
        precondition(fastSamplingInterval > .zero)
        precondition(storageSamplingInterval > .zero)
        precondition(longGapThreshold > 0)

        initialCPUProvider = cpuProvider
        initialMemoryProvider = memoryProvider
        self.storageProvider = storageProvider
        self.fastSamplingInterval = fastSamplingInterval
        self.storageSamplingInterval = storageSamplingInterval
        self.longGapThreshold = longGapThreshold
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
        let samplingID = UUID()
        self.samplingID = samplingID

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

                        guard !Task.isCancelled else {
                            return
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
                            memoryFailed: memoryFailed,
                            samplingID: samplingID
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
                            await self?.recordStorage(usage, samplingID: samplingID)
                            shouldRetryQuickly = usage == nil
                        } catch {
                            await self?.recordStorage(nil, samplingID: samplingID)
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

    /// Invalidates publication immediately. The returned task can be awaited
    /// when a caller also needs in-flight synchronous acquisition to finish.
    @discardableResult
    func stop() -> Task<Void, Never>? {
        let task = samplingTask
        samplingID = nil
        task?.cancel()
        samplingTask = nil
        return task
    }

    /// Applies the fast CPU and memory results in one main-actor hop, keeping
    /// the off-actor acquisition loop from scheduling separate UI work items.
    private func recordFastSample(
        cpuUsage: CPUUsage?,
        cpuFailed: Bool,
        memoryUsage: MemoryUsage?,
        memoryFailed: Bool,
        samplingID: UUID
    ) {
        guard self.samplingID == samplingID, !Task.isCancelled else {
            return
        }

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
        if usage != nil {
            markAvailable(.cpu)
        }
    }

    private func recordMemory(_ usage: MemoryUsage?) {
        memoryUsage = usage
        guard usage != nil else {
            markUnavailable(.memory)
            return
        }

        markAvailable(.memory)
    }

    private func recordStorage(_ usage: StorageUsage?, samplingID: UUID) {
        guard self.samplingID == samplingID, !Task.isCancelled else {
            return
        }

        storageUsage = usage
        guard usage != nil else {
            markUnavailable(.storage)
            return
        }

        markAvailable(.storage)
    }

    private func recordCPUFailure() {
        cpuUsage = nil
        markUnavailable(.cpu)
    }

    private func recordMemoryFailure() {
        memoryUsage = nil
        markUnavailable(.memory)
    }

    private func markUnavailable(_ metric: SampleKind) {
        guard unavailableMetrics.insert(metric).inserted else {
            return
        }

        logger.error("\(metric.rawValue, privacy: .public) sampling became unavailable")
    }

    private func markAvailable(_ metric: SampleKind) {
        guard unavailableMetrics.remove(metric) != nil else {
            return
        }

        logger.notice("\(metric.rawValue, privacy: .public) sampling recovered")
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
