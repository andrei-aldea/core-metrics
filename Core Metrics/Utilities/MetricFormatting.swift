import Foundation

/// Locale-aware, centralized formatting for menu-bar values.
nonisolated enum MetricFormatting {
    static let unavailable = "—"
    private static let compactByteSuffixes = [
        "B", "KB", "MB", "GB", "TB", "PB", "EB",
    ]

    static func percentage(
        _ fraction: Double,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        let normalized = fraction.isFinite ? min(max(fraction, 0), 1) : 0
        return normalized.formatted(
            .percent
                .precision(.fractionLength(0))
                .locale(locale)
        )
    }

    /// A deliberately short byte representation for the constrained menu bar.
    /// It always uses one decimal place and omits whitespace.
    static func compactBytes(
        _ bytes: UInt64,
        style: MetricByteStyle,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        let scaled = scaledBytes(bytes, style: style)
        return oneDecimal(scaled.value, locale: locale)
            + compactByteSuffixes[scaled.suffixIndex]
    }

    /// Localized geometric templates for reserving a byte-value column.
    /// These cover each digit shape and suffix, including templates wider than
    /// a real scaled value; they do not participate in metric formatting.
    static func compactByteColumnCandidates(
        style: MetricByteStyle,
        locale: Locale
    ) -> [String] {
        let repeatedDigitPattern: Int
        let zeroHeavyValue: Double
        switch style {
        case .memory:
            repeatedDigitPattern = 11_111
            zeroHeavyValue = 1_000
        case .storage:
            repeatedDigitPattern = 1_111
            zeroHeavyValue = 100
        }

        let templates: [Double] = (1...9).flatMap { digit -> [Double] in
            [Double(digit * repeatedDigitPattern) / 10, Double(digit) * zeroHeavyValue]
        } + [0]
        let localizedNumbers = templates.map { oneDecimal($0, locale: locale) }
        return compactByteSuffixes.flatMap { suffix in
            localizedNumbers.map { $0 + suffix }
        }
    }

    private static func scaledBytes(
        _ bytes: UInt64,
        style: MetricByteStyle
    ) -> (value: Double, suffixIndex: Int) {
        let base = style.unitBase
        var value = Double(bytes)
        var suffixIndex = 0

        while value >= base, suffixIndex < compactByteSuffixes.count - 1 {
            value /= base
            suffixIndex += 1
        }

        // Promote values that would round to the next unit, keeping compact
        // output short and avoiding labels such as 1024.0GB.
        let roundedValue = (value * 10).rounded() / 10
        if roundedValue >= base, suffixIndex < compactByteSuffixes.count - 1 {
            return (roundedValue / base, suffixIndex + 1)
        }

        return (value, suffixIndex)
    }

    private static func oneDecimal(
        _ value: Double,
        locale: Locale
    ) -> String {
        value.formatted(
            .number
                .grouping(.never)
                .precision(.fractionLength(1))
                .locale(locale)
        )
    }
}
