/// Sampling boundary used by `MetricsStore` and replaceable by fixtures.
nonisolated protocol StorageMetricsProviding: Sendable {
    func sample() throws -> StorageUsage?
}
