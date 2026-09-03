import Foundation

/// Locale-aware, centralized formatting for dashboard and menu-bar values.
nonisolated enum MetricFormatting {
    static let unavailable = "—"

    static func percentage(
        _ fraction: Double,
        fractionDigits: Int = 0,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        let normalized = fraction.isFinite ? min(max(fraction, 0), 1) : 0
        return normalized.formatted(
            .percent
                .precision(.fractionLength(max(fractionDigits, 0)))
                .locale(locale)
        )
    }

    static func bytes(
        _ value: UInt64,
        style: MetricByteStyle,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        ByteCountFormatStyle(
            style: style.foundationStyle,
            spellsOutZero: true,
            includesActualByteCount: false,
            locale: locale
        ).format(Int64(clamping: value))
    }

    /// A deliberately short byte representation for the constrained menu bar.
    /// It uses at most one decimal place below 100 units and omits whitespace.
    static func compactBytes(
        _ bytes: UInt64,
        style: MetricByteStyle,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        let suffixes = ["B", "K", "M", "G", "T", "P", "E"]
        let base = style.compactBase
        var value = Double(bytes)
        var suffixIndex = 0

        while value >= base, suffixIndex < suffixes.count - 1 {
            value /= base
            suffixIndex += 1
        }

        let number: String
        if suffixIndex > 0, value < 100 {
            number = value.formatted(
                .number
                    .precision(.fractionLength(0...1))
                    .locale(locale)
            )
        } else {
            number = value.formatted(
                .number
                    .precision(.fractionLength(0))
                    .locale(locale)
            )
        }

        return number + suffixes[suffixIndex]
    }
}
