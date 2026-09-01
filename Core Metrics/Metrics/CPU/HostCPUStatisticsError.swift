import Darwin

nonisolated enum HostCPUStatisticsError: Error, Equatable, Sendable {
    case machCallFailed(kern_return_t)
    case incompleteResult
}
