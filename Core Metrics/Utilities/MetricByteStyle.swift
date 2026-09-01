import Foundation

nonisolated enum MetricByteStyle: Sendable {
    case memory
    case storage

    var foundationStyle: ByteCountFormatStyle.Style {
        switch self {
        case .memory:
            .memory
        case .storage:
            .file
        }
    }

    var compactBase: Double {
        switch self {
        case .memory:
            1_024
        case .storage:
            1_000
        }
    }
}
