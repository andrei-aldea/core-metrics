import Foundation

nonisolated enum StorageMenuValueStyle: String, CaseIterable, Codable, Sendable {
    case percentage
    case used
    case available
    case total

    var displayName: String {
        switch self {
        case .percentage:
            "Percentage Used"
        case .used:
            "Used Space"
        case .available:
            "Available Space"
        case .total:
            "Total Capacity"
        }
    }
}
