import Foundation

nonisolated enum MenuBarDisplayMode: String, CaseIterable, Codable, Identifiable, Sendable {
    case iconAndValue
    case valueOnly
    case compact

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .iconAndValue:
            "Icon and Value"
        case .valueOnly:
            "Value Only"
        case .compact:
            "Compact"
        }
    }
}
