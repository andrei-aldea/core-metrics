import AppKit
import Foundation

/// Reserves a stable status-item width, including locale-specific fallback
/// glyphs that can be wider than the monospaced font's Latin characters.
@MainActor
struct MenuBarLabelLayout {
    static let labelFont = NSFont.systemFont(ofSize: NSFont.systemFontSize)
    static let font = NSFont.monospacedSystemFont(
        ofSize: NSFont.systemFontSize,
        weight: .regular
    )

    private static let latinCharacterAdvance = advance(of: "0")
    private let locale: Locale
    private let valueCharacterAdvance: CGFloat

    init(locale: Locale) {
        self.locale = locale
        let samples = (0...9).map { digit in
            MetricFormatting.percentage(Double(digit) / 10, locale: locale)
                + MetricFormatting.compactBytes(
                    UInt64(digit),
                    style: .memory,
                    locale: locale
                )
        }
        let characters = Set(samples.joined())
        valueCharacterAdvance = characters.reduce(Self.latinCharacterAdvance) {
            max($0, Self.advance(of: String($1)))
        }
    }

    func attributedTitle(
        stats: [MenuBarStat],
        values: [String],
        displayMode: MenuBarDisplayMode
    ) -> NSAttributedString {
        guard stats.count == values.count else {
            return NSAttributedString(string: MetricFormatting.unavailable, attributes: [.font: Self.font])
        }

        let title = NSMutableAttributedString(string: "")
        for index in stats.indices {
            if index > 0 {
                title.append(NSAttributedString(
                    string: MenuBarLabelFormatting.separator(for: displayMode),
                    attributes: [.font: Self.labelFont]
                ))
            }
            title.append(NSAttributedString(
                string: MenuBarLabelFormatting.prefix(for: stats[index], displayMode: displayMode),
                attributes: [.font: Self.labelFont]
            ))
            title.append(NSAttributedString(
                string: MenuBarLabelFormatting.paddedValue(
                    values[index], for: stats[index], displayMode: displayMode, locale: locale
                ),
                attributes: [.font: Self.font]
            ))
        }
        return title
    }

    func width(stats: [MenuBarStat], displayMode: MenuBarDisplayMode) -> CGFloat {
        guard !stats.isEmpty else { return ceil(Self.advance(of: MetricFormatting.unavailable)) + 1 }
        let prefixWidth = stats.reduce(CGFloat.zero) {
            $0 + (MenuBarLabelFormatting.prefix(for: $1, displayMode: displayMode) as NSString)
                .size(withAttributes: [.font: Self.labelFont]).width
        }
        let separatorWidth = (MenuBarLabelFormatting.separator(for: displayMode) as NSString)
            .size(withAttributes: [.font: Self.labelFont]).width
        let valueCharacters = stats.reduce(0) {
            $0 + MenuBarLabelFormatting.valueColumnWidth(for: $1, displayMode: displayMode, locale: locale)
        }
        return ceil(
            prefixWidth + separatorWidth * CGFloat(stats.count - 1)
                + valueCharacterAdvance * CGFloat(valueCharacters)
        ) + 1
    }

    private static func advance(of text: String) -> CGFloat {
        (text as NSString).size(withAttributes: [.font: font]).width
    }
}
