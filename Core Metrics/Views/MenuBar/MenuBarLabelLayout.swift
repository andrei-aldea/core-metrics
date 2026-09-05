import AppKit
import Foundation

/// Reserves a stable status-item width, including locale-specific fallback
/// glyphs that can be wider than the monospaced font's Latin characters.
@MainActor
struct MenuBarLabelLayout {
    static let font = NSFont.monospacedSystemFont(
        ofSize: NSFont.systemFontSize,
        weight: .regular
    )

    private static let latinCharacterAdvance = advance(of: "0")
    private let valueCharacterAdvance: CGFloat

    init(locale: Locale) {
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

    func width(stats: [MenuBarStat], displayMode: MenuBarDisplayMode) -> CGFloat {
        let characterCount = MenuBarLabelFormatting.reservedCharacterCount(
            stats: stats,
            displayMode: displayMode
        )
        let valueCharacters = stats.count * MenuBarLabelFormatting.valueColumnWidth
        let labelCharacters = characterCount - valueCharacters
        return ceil(
            Self.latinCharacterAdvance * CGFloat(labelCharacters)
                + valueCharacterAdvance * CGFloat(valueCharacters)
        ) + 1
    }

    private static func advance(of text: String) -> CGFloat {
        (text as NSString).size(withAttributes: [.font: font]).width
    }
}
