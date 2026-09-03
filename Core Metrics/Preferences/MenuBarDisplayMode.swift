import Foundation

nonisolated enum MenuBarDisplayMode: String, CaseIterable, Codable, Identifiable, Sendable {
    case labelAndValue = "iconAndValue"
    case valueOnly
    case compact

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .labelAndValue:
            "Label and Value"
        case .valueOnly:
            "Value Only"
        case .compact:
            "Compact"
        }
    }
}
