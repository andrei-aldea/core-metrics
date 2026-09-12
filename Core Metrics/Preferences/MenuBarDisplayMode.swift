import Foundation

nonisolated enum MenuBarDisplayMode: String, CaseIterable, Codable, Identifiable, Sendable {
    // Older releases stored the text-label mode under this identifier.
    case labelAndValue = "iconAndValue"
    case compact
    case iconAndValue = "categoryIconAndValue"
    case valueOnly

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .labelAndValue:
            String(localized: "Label and Value")
        case .valueOnly:
            String(localized: "Values Only")
        case .compact:
            String(localized: "Compact")
        case .iconAndValue:
            String(localized: "Icon and Value")
        }
    }
}
