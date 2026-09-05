import Foundation

/// The finite set of metrics Core Metrics can expose in the menu bar.
nonisolated enum MetricKind: String, CaseIterable, Codable, Hashable, Identifiable, Sendable {
    case cpu
    case memory
    case storage

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .cpu:
            String(localized: "CPU")
        case .memory:
            String(localized: "Memory")
        case .storage:
            String(localized: "Storage")
        }
    }

    var systemImage: String {
        switch self {
        case .cpu:
            "cpu"
        case .memory:
            "memorychip"
        case .storage:
            "internaldrive"
        }
    }
}
