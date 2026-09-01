/// Sampling boundary used by `MetricsStore` and replaceable by fixtures.
nonisolated protocol CPUMetricsProviding: Sendable {
    mutating func sample(isContinuous: Bool) throws -> CPUUsage?
    mutating func reset()
}
