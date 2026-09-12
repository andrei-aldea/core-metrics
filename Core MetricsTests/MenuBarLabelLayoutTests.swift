import AppKit
import CoreText
import Foundation
import Testing
@testable import Core_Metrics

@MainActor
@Suite("Menu-bar label layout")
struct MenuBarLabelLayoutTests {
    @Test("Compact changes labels without shrinking values or inter-stat spacing")
    func compactOnlyShortensLabels() throws {
        let stats: [MenuBarStat] = [.cpuUser, .memoryUsed, .storageFree]
        let values = ["9%", "8.0GB", "100.0GB"]
        let layout = MenuBarLabelLayout(locale: Locale(identifier: "en_US_POSIX"))
        let full = layout.attributedTitle(stats: stats, values: values, displayMode: .labelAndValue)
        let compact = layout.attributedTitle(stats: stats, values: values, displayMode: .compact)
        for value in values {
            let fullRange = (full.string as NSString).range(of: value)
            let compactRange = (compact.string as NSString).range(of: value)
            try #require(fullRange.location != NSNotFound && compactRange.location != NSNotFound)
            #expect(full.attributedSubstring(from: fullRange).isEqual(to: compact.attributedSubstring(from: compactRange)))
        }
        let savedLabelWidth = stats.reduce(CGFloat.zero) { width, stat in
            width + (stat.menuBarName as NSString).size(withAttributes: [.font: MenuBarLabelLayout.labelFont]).width
                - (stat.shortCode as NSString).size(withAttributes: [.font: MenuBarLabelLayout.labelFont]).width
        }
        #expect(abs(full.size().width - compact.size().width - savedLabelWidth) < 0.01)
    }

    @Test("Icon mode attaches one native category symbol to each complete value")
    func categorySymbolsAndValues() throws {
        let stats: [MenuBarStat] = [.cpuUser, .cpuSystem, .memoryUsed, .storageFree]
        let values = ["9%", "100%", "8.0GB", "100.0GB"]
        let layout = MenuBarLabelLayout(locale: Locale(identifier: "en_US_POSIX"))
        let title = layout.attributedTitle(stats: stats, values: values, displayMode: .iconAndValue)
        var attachments: [NSTextAttachment] = []
        title.enumerateAttribute(.attachment, in: NSRange(location: 0, length: title.length)) { value, _, _ in
            if let attachment = value as? NSTextAttachment { attachments.append(attachment) }
        }
        #expect(attachments.count == stats.count)
        for attachment in attachments {
            let image = try #require(attachment.image)
            #expect(image.isTemplate)
            #expect(attachment.bounds.width > 0)
            #expect(attachment.bounds.height > 0)
            #expect(abs(attachment.bounds.midY - MenuBarLabelLayout.labelFont.capHeight / 2) < 0.01)
        }
        for value in values { #expect(title.string.contains(value)) }
        for stat in stats { #expect(!title.string.contains(stat.menuBarName)) }
        #expect(title.size().width <= layout.width(stats: stats, displayMode: .iconAndValue))

        let valuesOnly = layout.attributedTitle(stats: stats, values: values, displayMode: .valueOnly)
        #expect(!valuesOnly.string.contains("\u{FFFC}"))
        #expect(valuesOnly.string.replacingOccurrences(of: "\u{200E}", with: "")
            .split(separator: " ").map(String.init) == values)
        #expect(valuesOnly.size().width < title.size().width)

        for mode in [MenuBarDisplayMode.iconAndValue, .valueOnly] {
            let presentation = StatusItemPresentation(
                configuration: MenuBarConfiguration(enabledStats: stats, displayMode: mode),
                cpuUsage: nil, memoryUsage: nil, storageUsage: nil,
                locale: Locale(identifier: "en_US_POSIX")
            )
            for stat in stats { #expect(presentation.accessibilityLabel.contains(stat.displayName)) }
            #expect(presentation.accessibilityLabel.contains("Unavailable"))
        }
    }

    @Test("Each representation uses one native size with tabular digits and proportional letters",
          arguments: MenuBarDisplayMode.allCases)
    func systemTypographyUsesTabularDigits(displayMode: MenuBarDisplayMode) throws {
        let title = MenuBarLabelLayout(locale: Locale(identifier: "en_US_POSIX")).attributedTitle(
            stats: [.cpuUser, .memoryUsed], values: ["1%", "8GB"], displayMode: displayMode
        )
        let expectedSize: CGFloat = 12
        title.enumerateAttribute(.font, in: NSRange(location: 0, length: title.length)) { value, _, _ in
            #expect((value as? NSFont)?.pointSize == expectedSize)
        }
        let valueRange = (title.string as NSString).range(of: "1%")
        try #require(valueRange.location != NSNotFound)
        let valueFont = try #require(title.attribute(.font, at: valueRange.location, effectiveRange: nil) as? NSFont)
        func width(_ text: String) -> CGFloat {
            (text as NSString).size(withAttributes: [.font: valueFont]).width
        }
        #expect(abs(width("1") - width("8")) < 0.01)
        #expect(width("i") < width("M"))
    }

    @Test("Native labels preserve complete readings in their selected order")
    func nativeLabelsKeepCompleteText() throws {
        let stats: [MenuBarStat] = [.cpuUser, .memoryUsed, .storageFree]
        let locale = Locale(identifier: "en_US_POSIX")
        let layout = MenuBarLabelLayout(locale: locale)
        let values = ["100%", "1023.9GB", "999.9GB"]
        for mode in [MenuBarDisplayMode.labelAndValue, .compact] {
            let title = layout.attributedTitle(stats: stats, values: values, displayMode: mode)
            let string = title.string as NSString
            var readingEnd = 0
            for (stat, value) in zip(stats, values) {
                let name = mode == .compact ? stat.shortCode : stat.menuBarName
                let nameRange = string.range(
                    of: name,
                    range: NSRange(location: readingEnd, length: string.length - readingEnd)
                )
                try #require(nameRange.location != NSNotFound)
                let valueStart = NSMaxRange(nameRange)
                let valueRange = string.range(
                    of: value,
                    range: NSRange(location: valueStart, length: string.length - valueStart)
                )
                try #require(valueRange.location != NSNotFound)
                readingEnd = NSMaxRange(valueRange)
            }
            #expect(title.size().width <= layout.width(stats: stats, displayMode: mode))
        }
    }

    @Test("Localized fallback digits fit the fixed status frame", arguments: [
        "ccp_BD", "my_MM", "mni_Mtei_IN", "ar_SA", "fa_IR", "tr_TR", "fr_FR", "ro_RO", "en_US_POSIX",
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
                    #expect(title.string.hasSuffix(value))
                    if mode == .labelAndValue || mode == .compact {
                        let name = mode == .compact ? sample.stat.shortCode : sample.stat.menuBarName
                        #expect(title.string.hasPrefix(name))
                    }
                    #expect(title.size().width <= layout.width(stats: [sample.stat], displayMode: mode))
                }
            }
        }
    }

    @Test("Live values leave following labels and value columns at the same positions", arguments: [
        "en_US_POSIX", "ro_RO", "ar_SA", "fa_IR", "he_IL", "ar_SA@numbers=latn", "tr_TR", "fr_FR",
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
                MetricFormatting.compactBytes(UInt64(1023.9 * 1_024 * 1_024), style: .memory, locale: locale),
                MetricFormatting.compactBytes(999_900_000, style: .storage, locale: locale),
            ],
            [
                MetricFormatting.percentage(0.88, locale: locale),
                MetricFormatting.compactBytes(UInt64(1023.9 * 1_024 * 1_024 * 1_024), style: .memory, locale: locale),
                MetricFormatting.compactBytes(999_900_000_000, style: .storage, locale: locale),
            ],
            [
                MetricFormatting.percentage(0.01, locale: locale),
                MetricFormatting.compactBytes(1_024 * 1_024 * 1_024, style: .memory, locale: locale),
                MetricFormatting.compactBytes(1_000_000_000, style: .storage, locale: locale),
            ],
            Array(repeating: MetricFormatting.unavailable, count: 3),
        ]

        for mode in MenuBarDisplayMode.allCases {
            let stats: [MenuBarStat] = [.cpuUser, .memoryUsed, .storageFree]
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
                        #expect(abs(offset - referenceOffset) < 0.01, "\(identifier), \(mode), \(values)")
                    }
                } else {
                    referenceWidth = title.size().width
                    referenceOffsets = offsets
                }
                #expect(title.size().width <= layout.width(stats: stats, displayMode: mode))
            }
        }
    }

    @Test("Percent spacing adds two points only when the locale has no gap", arguments: [
        ("en_US_POSIX", "%", 2.0, false),
        ("tr_TR", "%", 2.0, true),
        ("ar_SA", "٪", 2.0, false),
        ("fa_IR", "٪", 2.0, false),
        ("he_IL", "%", 2.0, false),
        ("ar_SA@numbers=latn", "٪", 2.0, false),
        ("he_IL@numbers=arab", "٪", 2.0, false),
        ("fr_FR", "%", 0.0, false),
    ])
    func percentSpacing(
        identifier: String,
        percentSymbol: String,
        expectedGap: Double,
        signIsPrefix: Bool
    ) throws {
        let locale = Locale(identifier: identifier)
        let layout = MenuBarLabelLayout(locale: locale)
        for mode in MenuBarDisplayMode.allCases {
            for fraction in [0.09, 1.0] {
                let value = MetricFormatting.percentage(fraction, locale: locale)
                let title = layout.attributedTitle(
                    stats: [.cpuUser], values: [value], displayMode: mode
                )
                let valueRange = (title.string as NSString).range(of: value)
                try #require(valueRange.location != NSNotFound)
                let decoratedValue = title.attributedSubstring(from: valueRange)
                #expect(decoratedValue.string == value)
                let reference = NSAttributedString(
                    string: value,
                    attributes: [.font: NSFont.monospacedDigitSystemFont(
                        ofSize: 12,
                        weight: .regular
                    ), .kern: 0]
                )
                let string = value as NSString
                let signRange = string.range(of: percentSymbol)
                try #require(signRange.location != NSNotFound)
                let signPosition = try glyphPosition(in: reference, at: signRange.location)
                let numbers = try value.indices.filter { value[$0].isNumber }.map { index in
                    let range = NSRange(index..<value.index(after: index), in: value)
                    return (range: range, x: try glyphPosition(in: reference, at: range.location))
                }
                let neighbor = try #require(numbers.min {
                    abs($0.x - signPosition) < abs($1.x - signPosition)
                })
                let digitRange = neighbor.range
                try #require((signRange.location < digitRange.location) == signIsPrefix)
                if expectedGap == 0 {
                    let gapStart = NSMaxRange(digitRange)
                    let localeGap = string.substring(with: NSRange(
                        location: gapStart, length: signRange.location - gapStart
                    ))
                    #expect(!localeGap.isEmpty)
                    let gapIsWhitespace = localeGap.allSatisfy(\.isWhitespace)
                    #expect(gapIsWhitespace)
                }

                // Compare physical glyph positions, independently of the carrier
                // used to align the complete value within its reserved column.
                let decoratedDistance = abs(
                    try glyphPosition(in: decoratedValue, at: signRange.location)
                        - glyphPosition(in: decoratedValue, at: digitRange.location)
                )
                let referenceDistance = abs(
                    try glyphPosition(in: reference, at: signRange.location)
                        - glyphPosition(in: reference, at: digitRange.location)
                )
                #expect(abs(decoratedDistance - referenceDistance - CGFloat(expectedGap)) < 0.01)
                #expect(abs(decoratedValue.size().width - reference.size().width - CGFloat(expectedGap)) < 0.01)
            }
        }
    }

    private func glyphPosition(in title: NSAttributedString, at stringIndex: Int) throws -> CGFloat {
        let line = CTLineCreateWithAttributedString(title)
        let runs = try #require(CTLineGetGlyphRuns(line) as? [CTRun])
        for run in runs {
            let count = CTRunGetGlyphCount(run)
            var indices = [CFIndex](repeating: 0, count: count)
            var positions = [CGPoint](repeating: .zero, count: count)
            CTRunGetStringIndices(run, CFRange(location: 0, length: 0), &indices)
            CTRunGetPositions(run, CFRange(location: 0, length: 0), &positions)
            if let index = indices.firstIndex(of: stringIndex) {
                return positions[index].x
            }
        }
        Issue.record("The rendered value should contain the requested sign or digit glyph")
        throw MissingGlyph()
    }

    private struct MissingGlyph: Error {}

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
