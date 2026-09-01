/// Combines the public Mach reader with the pure delta accumulator.
nonisolated struct CPUMetricsProvider: CPUMetricsProviding {
    private let reader: any CPUTicksReading
    private var accumulator = CPUSampleAccumulator()

    init(reader: any CPUTicksReading = HostCPUTicksReader()) {
        self.reader = reader
    }

    /// Returns `nil` for the first sample, after reset/discontinuity, or when
    /// the pure calculator observes no elapsed ticks.
    mutating func sample(isContinuous: Bool = true) throws -> CPUUsage? {
        let ticks = try reader.readTicks()
        return accumulator.consume(ticks, isContinuous: isContinuous)
    }

    mutating func reset() {
        accumulator.reset()
    }
}
