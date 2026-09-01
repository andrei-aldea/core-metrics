import Foundation

nonisolated enum MemoryMenuValueStyle: String, CaseIterable, Codable, Sendable {
    case percentage
    case used

    var displayName: String {
        switch self {
        case .percentage:
            "Percentage"
        case .used:
            "Used Memory"
        }
    }
}
