import Foundation

nonisolated enum MemoryMenuValueStyle: String, CaseIterable, Codable, Sendable {
    case percentage
    case used
    case available
    case appEstimate
    case wired
    case compressed
    case total

    var displayName: String {
        switch self {
        case .percentage:
            "Percentage Used"
        case .used:
            "Used Memory"
        case .available:
            "Available Memory"
        case .appEstimate:
            "App Estimate"
        case .wired:
            "Wired Memory"
        case .compressed:
            "Compressed Memory"
        case .total:
            "Total Memory"
        }
    }
}
