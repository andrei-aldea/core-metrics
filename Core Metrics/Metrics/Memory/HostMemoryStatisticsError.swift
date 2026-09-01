import Darwin

nonisolated enum HostMemoryStatisticsError: Error, Equatable, Sendable {
    case vmStatisticsCallFailed(kern_return_t)
    case pageSizeCallFailed(kern_return_t)
    case incompleteResult
}
