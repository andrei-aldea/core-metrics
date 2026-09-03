nonisolated enum MetricByteStyle: Sendable {
    case memory
    case storage

    var unitBase: Double {
        switch self {
        case .memory:
            1_024
        case .storage:
            1_000
        }
    }
}
