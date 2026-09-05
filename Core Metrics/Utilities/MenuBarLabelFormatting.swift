/// Builds the shared text for the full Settings preview and the bounded
/// template status image. Formatting stays independent of presentation.
nonisolated enum MenuBarLabelFormatting {
    /// Eight characters fit the largest one-decimal compact byte value
    /// (`1023.9GB`) while keeping every live slot stable.
    static let valueColumnWidth = 8

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

    /// Returns the exact number of monospaced characters reserved by the
    /// selected slots. This is independent of live values, so the status item
    /// can hold a fixed point width until the configuration changes.
    static func reservedCharacterCount(
        stats: [MenuBarStat],
        displayMode: MenuBarDisplayMode
    ) -> Int {
        guard !stats.isEmpty else {
            return MetricFormatting.unavailable.count
        }

        let slotCharacters = stats.reduce(into: 0) { count, stat in
            let slotWidth = switch displayMode {
            case .labelAndValue:
                stat.menuBarName.count + 1 + valueColumnWidth
            case .valueOnly:
                valueColumnWidth
            case .compact:
                stat.shortCode.count + 1 + valueColumnWidth
            }
            count += slotWidth
        }
        let separatorCharacters = (stats.count - 1) * 2
        return slotCharacters + separatorCharacters
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
