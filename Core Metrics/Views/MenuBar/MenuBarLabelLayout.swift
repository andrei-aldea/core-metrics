import AppKit
import CoreText
import Foundation

/// Uses native system typography with measured, fixed value columns.
@MainActor
struct MenuBarLabelLayout {
    // Matches the apparent size of the supplied Macs Fan Control reference.
    // Every representation uses the same native text and symbol point size.
    static let pointSize: CGFloat = 12
    static let labelFont = NSFont.systemFont(ofSize: pointSize)
    static let font = NSFont.monospacedDigitSystemFont(
        ofSize: pointSize,
        weight: .regular
    )
    private static let percentGap: CGFloat = 2
    private let percentSpacing: PercentSpacing?
    private let columns: ValueColumns
    private static let categoryPrefixes: [MetricKind: NSAttributedString] = Dictionary(
        uniqueKeysWithValues: MetricKind.allCases.map { metric in
            guard let image = NSImage(
                systemSymbolName: metric.systemImage,
                accessibilityDescription: metric.displayName
            )?.withSymbolConfiguration(.init(pointSize: labelFont.pointSize, weight: .regular)) else {
                return (metric, NSAttributedString(
                    string: "\(metric.displayName) ", attributes: [.font: labelFont]
                ))
            }
            image.isTemplate = true
            let attachment = NSTextAttachment()
            attachment.image = image
            attachment.bounds = CGRect(
                x: 0, y: (labelFont.capHeight - image.size.height) / 2,
                width: image.size.width, height: image.size.height
            )
            let prefix = NSMutableAttributedString(string: "\u{200E}", attributes: [.font: labelFont])
            prefix.append(NSAttributedString(attachment: attachment))
            prefix.addAttribute(.font, value: labelFont, range: NSRange(location: 0, length: prefix.length))
            prefix.append(NSAttributedString(string: " ", attributes: [.font: labelFont]))
            return (metric, prefix)
        }
    )

    init(locale: Locale) {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .percent
        let symbol = formatter.percentSymbol ?? "%"
        let percentages = (0...100).map {
            MetricFormatting.percentage(Double($0) / 100, locale: locale)
        }
        let spacing = Self.makePercentSpacing(in: percentages[100], percentSymbol: symbol)
        percentSpacing = spacing
        let memory = MetricFormatting.compactByteColumnCandidates(style: .memory, locale: locale)
        let storage = MetricFormatting.compactByteColumnCandidates(style: .storage, locale: locale)
        func reservedWidth(_ candidates: [String]) -> CGFloat {
            (candidates + [MetricFormatting.unavailable]).reduce(CGFloat.zero) {
                max($0, Self.attributedValue($1, font: Self.font, spacing: spacing).size().width)
            }
        }
        // Every representation shares one size and one set of locale columns.
        // Live samples never repeat candidate formatting or symbol creation.
        columns = ValueColumns(
            percentage: reservedWidth(percentages),
            memory: reservedWidth(memory),
            storage: reservedWidth(storage)
        )
    }

    func attributedTitle(
        stats: [MenuBarStat],
        values: [String],
        displayMode: MenuBarDisplayMode
    ) -> NSAttributedString {
        let valueFont = Self.font
        guard stats.count == values.count else {
            return NSAttributedString(string: MetricFormatting.unavailable, attributes: [.font: valueFont])
        }

        let title = NSMutableAttributedString(string: "")
        for index in stats.indices {
            if index > 0 {
                title.append(NSAttributedString(
                    string: MenuBarLabelFormatting.separator(for: displayMode),
                    attributes: [.font: Self.labelFont]
                ))
            }
            title.append(Self.prefix(for: stats[index], displayMode: displayMode))
            let value = Self.attributedValue(values[index], font: valueFont, spacing: percentSpacing)
            // The space is an invisible alignment carrier. Its measured
            // advance plus kerning fills exactly the unused column width,
            // even when decimal separators, units or fallback digits differ.
            let spaceWidth = (" " as NSString).size(withAttributes: [.font: valueFont]).width
            title.append(NSAttributedString(
                string: " ",
                attributes: [
                    .font: valueFont,
                    .kern: max(0, valueColumnWidth(for: stats[index]) - value.size().width)
                        - spaceWidth,
                ]
            ))
            title.append(value)
        }
        return title
    }

    func width(stats: [MenuBarStat], displayMode: MenuBarDisplayMode) -> CGFloat {
        guard !stats.isEmpty else {
            return ceil(Self.attributedValue(
                MetricFormatting.unavailable,
                font: Self.font,
                spacing: percentSpacing
            ).size().width) + 1
        }
        let prefixWidth = stats.reduce(CGFloat.zero) {
            $0 + Self.prefix(for: $1, displayMode: displayMode).size().width
        }
        let separatorWidth = (MenuBarLabelFormatting.separator(for: displayMode) as NSString)
            .size(withAttributes: [.font: Self.labelFont]).width
        return ceil(
            prefixWidth + separatorWidth * CGFloat(stats.count - 1)
                + stats.reduce(CGFloat.zero) { $0 + valueColumnWidth(for: $1) }
        ) + 1
    }

    private struct ValueColumns {
        let percentage: CGFloat
        let memory: CGFloat
        let storage: CGFloat
    }

    private func valueColumnWidth(for stat: MenuBarStat) -> CGFloat {
        return switch stat {
        case .cpuUsed, .cpuUser, .cpuSystem, .cpuIdle,
             .memoryUsedPercentage, .storageUsedPercentage:
            columns.percentage
        case .memoryUsed, .memoryWired, .memoryCompressed, .memoryCached, .memorySwap, .memoryTotal:
            columns.memory
        case .storageUsed, .storageFree, .storageTotal:
            columns.storage
        }
    }

    private static func prefix(for stat: MenuBarStat, displayMode: MenuBarDisplayMode) -> NSAttributedString {
        if displayMode == .iconAndValue, let prefix = categoryPrefixes[stat.metric] {
            return prefix
        }
        return NSAttributedString(
            string: MenuBarLabelFormatting.prefix(for: stat, displayMode: displayMode),
            attributes: [.font: labelFont]
        )
    }

    private struct PercentSpacing {
        enum Boundary {
            case symbol
            case firstNumber
            case lastNumber
        }

        let symbol: String
        let boundary: Boundary
    }

    /// Resolve the visual boundary once per locale. Logical suffix position
    /// alone is insufficient when a percent symbol includes a bidi marker.
    private static func makePercentSpacing(in value: String, percentSymbol: String) -> PercentSpacing? {
        let string = value as NSString
        let symbolRange = string.range(of: percentSymbol)
        guard symbolRange.location != NSNotFound else { return nil }
        let sample = NSAttributedString(string: value, attributes: [.font: font, .kern: 0])
        let line = CTLineCreateWithAttributedString(sample)
        guard let runs = CTLineGetGlyphRuns(line) as? [CTRun] else { return nil }
        var glyphs: [(range: NSRange, x: CGFloat)] = []
        for run in runs {
            let count = CTRunGetGlyphCount(run)
            var indices = [CFIndex](repeating: 0, count: count)
            var positions = [CGPoint](repeating: .zero, count: count)
            CTRunGetStringIndices(run, CFRange(location: 0, length: 0), &indices)
            CTRunGetPositions(run, CFRange(location: 0, length: 0), &positions)
            for index in indices.indices where indices[index] >= 0 && indices[index] < string.length {
                glyphs.append((
                    string.rangeOfComposedCharacterSequence(at: indices[index]),
                    positions[index].x
                ))
            }
        }

        guard let sign = glyphs.first(where: { glyph in
            let character = string.substring(with: glyph.range)
            return NSLocationInRange(glyph.range.location, symbolRange)
                && !character.allSatisfy(\.isWhitespace)
                && !character.unicodeScalars.allSatisfy { $0.properties.generalCategory == .format }
        }) else { return nil }
        let numbers = glyphs.filter { string.substring(with: $0.range).first?.isNumber == true }
        guard let neighbor = numbers.min(by: { abs($0.x - sign.x) < abs($1.x - sign.x) }) else {
            return nil
        }

        let gapStart = min(NSMaxRange(neighbor.range), NSMaxRange(sign.range))
        let gapEnd = max(neighbor.range.location, sign.range.location)
        guard gapStart <= gapEnd,
              !string.substring(with: NSRange(location: gapStart, length: gapEnd - gapStart))
                .contains(where: \.isWhitespace) else { return nil }

        let boundary: PercentSpacing.Boundary
        if sign.x < neighbor.x {
            boundary = .symbol
        } else if neighbor.range.location == numbers.map(\.range.location).min() {
            boundary = .firstNumber
        } else if neighbor.range.location == numbers.map(\.range.location).max() {
            boundary = .lastNumber
        } else {
            return nil
        }
        return PercentSpacing(symbol: string.substring(with: sign.range), boundary: boundary)
    }

    private static func attributedValue(
        _ value: String,
        font: NSFont,
        spacing: PercentSpacing?
    ) -> NSAttributedString {
        let text = NSMutableAttributedString(string: value, attributes: [.font: font, .kern: 0])
        guard let spacing, let sign = value.range(of: spacing.symbol) else { return text }
        let range: Range<String.Index>
        switch spacing.boundary {
        case .symbol:
            range = sign
        case .firstNumber:
            guard let index = value.firstIndex(where: \.isNumber) else { return text }
            range = index..<value.index(after: index)
        case .lastNumber:
            guard let index = value.lastIndex(where: \.isNumber) else { return text }
            range = index..<value.index(after: index)
        }
        // Apply the gap to one visible glyph, never a directional marker.
        text.addAttribute(.kern, value: percentGap, range: NSRange(range, in: value))
        return text
    }
}
