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
