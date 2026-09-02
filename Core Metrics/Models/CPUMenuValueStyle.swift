import Foundation

nonisolated enum CPUMenuValueStyle: String, CaseIterable, Codable, Sendable {
    case total
    case user
    case system
    case idle

    var displayName: String {
        switch self {
        case .total:
            "Total Used"
        case .user:
            "User"
        case .system:
            "System"
        case .idle:
            "Idle"
        }
    }
}
