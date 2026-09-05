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
            String(localized: "Label and Value")
        case .valueOnly:
            String(localized: "Value Only")
        case .compact:
            String(localized: "Compact")
        }
    }
}
