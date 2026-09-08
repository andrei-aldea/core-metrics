import AppKit
import CoreText
import Foundation
import Testing
@testable import Core_Metrics

@MainActor
@Suite("Menu-bar label layout")
struct MenuBarLabelLayoutTests {
    @Test("Native label typography saves width without shortening any readings")
    func nativeLabelsKeepCompleteText() {
        let stats: [MenuBarStat] = [.cpuUser, .memoryUsed, .storageFree]
        let locale = Locale(identifier: "en_US_POSIX")
        let layout = MenuBarLabelLayout(locale: locale)
        let values = ["100%", "1023.9GB", "999.9GB"]
        for mode in [MenuBarDisplayMode.labelAndValue, .compact] {
            let title = layout.attributedTitle(stats: stats, values: values, displayMode: mode)
            let plainText = MenuBarLabelFormatting.text(
                stats: stats, values: values, displayMode: mode, locale: locale
            )
            let allMonospacedWidth = (plainText as NSString)
                .size(withAttributes: [.font: MenuBarLabelLayout.font]).width
            #expect(title.string == plainText)
            #expect(title.size().width < allMonospacedWidth)
            #expect(title.size().width <= layout.width(stats: stats, displayMode: mode))
        }
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
            (.memoryCompressed, [
                MetricFormatting.compactBytes(.max, style: .memory, locale: locale),
                MetricFormatting.unavailable,
            ]),
            (.memoryUsedPercentage, [
                MetricFormatting.percentage(1, locale: locale),
                MetricFormatting.unavailable,
            ]),
            (.storageUsedPercentage, [
                MetricFormatting.percentage(1, locale: locale),
                MetricFormatting.unavailable,
            ]),
            (.storageTotal, [
                MetricFormatting.compactBytes(.max, style: .storage, locale: locale),
                MetricFormatting.unavailable,
            ]),
        ]

        for mode in MenuBarDisplayMode.allCases {
            for sample in samples {
                for value in sample.values {
                    let title = layout.attributedTitle(
                        stats: [sample.stat],
                        values: [value],
                        displayMode: mode
                    )
                    #expect(title.string == MenuBarLabelFormatting.text(
                        stats: [sample.stat], values: [value], displayMode: mode, locale: locale
                    ))
                    #expect(title.size().width <= layout.width(stats: [sample.stat], displayMode: mode))
                }
            }
        }
    }

    @Test("Live values leave following labels and value columns at the same positions", arguments: [
        "en_US_POSIX", "ro_RO",
    ])
    func valueColumnsStayInPlace(identifier: String) throws {
        let locale = Locale(identifier: identifier)
        let layout = MenuBarLabelLayout(locale: locale)
        let states = [
            [
                MetricFormatting.percentage(0.09, locale: locale),
                MetricFormatting.compactBytes(1_610_612_736, style: .memory, locale: locale),
                MetricFormatting.compactBytes(9_000_000_000, style: .storage, locale: locale),
            ],
            [
                MetricFormatting.percentage(1, locale: locale),
                MetricFormatting.compactBytes(1_073_634_443_673, style: .memory, locale: locale),
                MetricFormatting.compactBytes(999_900_000_000, style: .storage, locale: locale),
            ],
            Array(repeating: MetricFormatting.unavailable, count: 3),
        ]

        for mode in MenuBarDisplayMode.allCases {
            let stats: [MenuBarStat] = mode == .valueOnly
                ? [.cpuUser]
                : [.cpuUser, .memoryUsed, .storageFree]
            var referenceWidth: CGFloat?
            var referenceOffsets: [CGFloat]?
            for values in states {
                let title = layout.attributedTitle(
                    stats: stats, values: Array(values.prefix(stats.count)), displayMode: mode
                )
                let offsets = try columnOffsets(in: title, stats: stats, displayMode: mode)
                if let referenceWidth, let referenceOffsets {
                    #expect(abs(title.size().width - referenceWidth) < 0.01)
                    #expect(offsets.count == referenceOffsets.count)
                    for (offset, referenceOffset) in zip(offsets, referenceOffsets) {
                        #expect(abs(offset - referenceOffset) < 0.01)
                    }
                } else {
                    referenceWidth = title.size().width
                    referenceOffsets = offsets
                }
                #expect(title.size().width <= layout.width(stats: stats, displayMode: mode))
            }
        }
    }

    private func columnOffsets(
        in title: NSAttributedString,
        stats: [MenuBarStat],
        displayMode: MenuBarDisplayMode
    ) throws -> [CGFloat] {
        let line = CTLineCreateWithAttributedString(title)
        let string = title.string as NSString
        var searchStart = 0
        var offsets: [CGFloat] = []
        for stat in stats {
            let prefix = MenuBarLabelFormatting.prefix(for: stat, displayMode: displayMode)
            if prefix.isEmpty {
                offsets.append(CTLineGetOffsetForStringIndex(line, 0, nil))
                continue
            }
            let range = string.range(
                of: prefix,
                range: NSRange(location: searchStart, length: string.length - searchStart)
            )
            try #require(range.location != NSNotFound)
            offsets.append(CTLineGetOffsetForStringIndex(line, range.location, nil))
            offsets.append(CTLineGetOffsetForStringIndex(line, NSMaxRange(range), nil))
            searchStart = NSMaxRange(range)
        }
        return offsets
    }
}
