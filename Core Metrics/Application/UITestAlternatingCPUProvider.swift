#if DEBUG
/// Already-normalized CPU samples for an explicitly isolated UI-test launch.
/// MetricsStore supplies its normal cadence; this fixture owns no task or timer.
nonisolated struct UITestAlternatingCPUProvider: CPUMetricsProviding {
    private var nextSampleIsMaximum = false

    mutating func sample(isContinuous: Bool) throws -> CPUUsage? {
        // Unlike cumulative Mach ticks, these values need no delta baseline.
        let user = nextSampleIsMaximum ? 1.0 : 0.09
        nextSampleIsMaximum.toggle()
        return CPUUsage(user: user, system: 0, idle: 1 - user)
    }

    mutating func reset() {
        nextSampleIsMaximum = false
    }
}
#endif
