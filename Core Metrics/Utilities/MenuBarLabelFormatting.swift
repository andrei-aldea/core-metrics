/// Shared native label prefixes and slot separators.
/// Point-based value allocation belongs to MenuBarLabelLayout.
nonisolated enum MenuBarLabelFormatting {
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

    static func separator(for displayMode: MenuBarDisplayMode) -> String {
        "  "
    }
}
