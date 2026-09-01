/// Sampling boundary used by `MetricsStore` and replaceable by fixtures.
nonisolated protocol MemoryMetricsProviding: Sendable {
    mutating func sample() throws -> MemoryUsage?
}
