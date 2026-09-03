import Foundation

/// Builds one text-only status label. A single `Text` is more reliable than a
/// hierarchy of images and independently framed values in a menu-bar scene.
nonisolated enum MenuBarLabelFormatting {
    static let valueColumnWidth = 5

    static func text(
        stats: [MenuBarStat],
        values: [String],
        displayMode: MenuBarDisplayMode
    ) -> String {
        guard stats.count == values.count else {
            return MetricFormatting.unavailable
        }

        return stats.indices.map { index in
            slot(
                stat: stats[index],
                value: values[index],
                displayMode: displayMode
            )
        }
        .joined(separator: "  ")
    }

    private static func slot(
        stat: MenuBarStat,
        value: String,
        displayMode: MenuBarDisplayMode
    ) -> String {
        let reservedValue = String(
            repeating: " ",
            count: max(valueColumnWidth - value.count, 0)
        ) + value

        return switch displayMode {
        case .labelAndValue:
            "\(stat.menuBarName) \(reservedValue)"
        case .valueOnly:
            reservedValue
        case .compact:
            "\(stat.shortCode) \(reservedValue)"
        }
    }
}
