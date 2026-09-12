import Foundation

/// Builds the complete text for the native status title and Settings preview.
/// Formatting stays independent of the system-owned presentation.
nonisolated enum MenuBarLabelFormatting {
    /// Eight characters fit the largest one-decimal compact byte value
    /// (`1023.9GB`) while keeping every live slot stable.
    static let valueColumnWidth = 8

    /// A percentage column reserves its locale's complete 100% representation,
    /// including spacing and direction marks, independently of the live value.
    static func valueColumnWidth(
        for stat: MenuBarStat,
        displayMode: MenuBarDisplayMode,
        locale: Locale = .current
    ) -> Int {
        switch stat {
        case .cpuUsed, .cpuUser, .cpuSystem, .cpuIdle,
             .memoryUsedPercentage, .storageUsedPercentage:
            return max(4, MetricFormatting.percentage(1, locale: locale).count)
        default:
            return valueColumnWidth
        }
    }

    static func text(
        stats: [MenuBarStat],
        values: [String],
        displayMode: MenuBarDisplayMode,
        locale: Locale = .current
    ) -> String {
        guard stats.count == values.count else {
            return MetricFormatting.unavailable
        }

        return stats.indices.map { index in
            prefix(for: stats[index], displayMode: displayMode) + paddedValue(
                values[index],
                for: stats[index],
                displayMode: displayMode,
                locale: locale
            )
        }
        .joined(separator: separator(for: displayMode))
    }

    /// Returns the exact character count of the padded plain-text form.
    /// The attributed layout measures labels and value columns separately.
    static func reservedCharacterCount(
        stats: [MenuBarStat],
        displayMode: MenuBarDisplayMode,
        locale: Locale = .current
    ) -> Int {
        guard !stats.isEmpty else {
            return MetricFormatting.unavailable.count
        }

        let slotCharacters = stats.reduce(into: 0) { count, stat in
            let valueWidth = valueColumnWidth(for: stat, displayMode: displayMode, locale: locale)
            count += prefix(for: stat, displayMode: displayMode).count + valueWidth
        }
        let separatorCharacters = (stats.count - 1) * separator(for: displayMode).count
        return slotCharacters + separatorCharacters
    }

    static func prefix(for stat: MenuBarStat, displayMode: MenuBarDisplayMode) -> String {
        switch displayMode {
        case .labelAndValue: "\(stat.menuBarName) "
        // A zero-width direction anchor keeps unlabeled slots in canonical
        // order when a localized value contains right-to-left direction marks.
        case .valueOnly: "\u{200E}"
        case .compact: "\(stat.shortCode) "
        // The native layout replaces this object marker with an SF Symbol.
        case .iconAndValue: "\u{200E}\u{FFFC} "
        }
    }

    static func paddedValue(
        _ value: String,
        for stat: MenuBarStat,
        displayMode: MenuBarDisplayMode,
        locale: Locale = .current
    ) -> String {
        let columnWidth = valueColumnWidth(for: stat, displayMode: displayMode, locale: locale)
        return String(
            repeating: " ",
            count: max(columnWidth - value.count, 0)
        ) + value
    }

    static func separator(for displayMode: MenuBarDisplayMode) -> String {
        "  "
    }
}
