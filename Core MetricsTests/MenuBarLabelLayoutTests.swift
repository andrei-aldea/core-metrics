import AppKit
import Foundation
import Testing
@testable import Core_Metrics

@MainActor
@Suite("Menu-bar label layout")
struct MenuBarLabelLayoutTests {
    @Test("Latin numbering uses one font advance per reserved character")
    func retainsLatinWidth() {
        let stats: [MenuBarStat] = [.cpuUser, .memoryUsed, .storageFree]
        let layout = MenuBarLabelLayout(locale: Locale(identifier: "en_US_POSIX"))
        let advance = ("0" as NSString).size(
            withAttributes: [.font: MenuBarLabelLayout.font]
        ).width
        let characterCount = MenuBarLabelFormatting.reservedCharacterCount(
            stats: stats,
            displayMode: .compact
        )

        #expect(
            layout.width(stats: stats, displayMode: .compact)
                == ceil(advance * CGFloat(characterCount)) + 1
        )
    }

    @Test("Localized fallback digits fit the fixed status frame", arguments: [
        "ccp_BD", "my_MM", "mni_Mtei_IN", "ar_SA", "fa_IR", "ro_RO", "en_US_POSIX",
    ])
    func localizedValuesFit(identifier: String) {
        let locale = Locale(identifier: identifier)
        let layout = MenuBarLabelLayout(locale: locale)
        let samples: [(stat: MenuBarStat, values: [String])] = [
            (.cpuUser, [
                MetricFormatting.percentage(0.01, locale: locale),
                MetricFormatting.percentage(0.99, locale: locale),
                MetricFormatting.percentage(1, locale: locale),
                MetricFormatting.unavailable,
            ]),
            (.memoryUsed, [
                MetricFormatting.compactBytes(1_073_634_443_673, style: .memory, locale: locale),
                MetricFormatting.compactBytes(1_099_404_574_720, style: .memory, locale: locale),
                MetricFormatting.compactBytes(.max, style: .memory, locale: locale),
                MetricFormatting.unavailable,
            ]),
        ]

        for mode in MenuBarDisplayMode.allCases {
            for sample in samples {
                for value in sample.values {
                    let text = MenuBarLabelFormatting.text(
                        stats: [sample.stat],
                        values: [value],
                        displayMode: mode
                    )
                    let measuredWidth = (text as NSString).size(
                        withAttributes: [.font: MenuBarLabelLayout.font]
                    ).width

                    #expect(measuredWidth <= layout.width(stats: [sample.stat], displayMode: mode))
                }
            }
        }
    }
}
