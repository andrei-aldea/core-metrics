import Foundation

nonisolated enum StorageMenuValueStyle: String, CaseIterable, Codable, Sendable {
    case percentage
    case available

    var displayName: String {
        switch self {
        case .percentage:
            "Percentage Used"
        case .available:
            "Available Space"
        }
    }
}
