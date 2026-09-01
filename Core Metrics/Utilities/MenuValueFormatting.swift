import Foundation

/// Pure menu-bar value selection. Views add SF Symbols and accessibility text;
/// this layer guarantees compact, non-arbitrary value strings.
nonisolated enum MenuValueFormatting {
    static func cpu(_ usage: CPUUsage?, locale: Locale = .autoupdatingCurrent) -> String {
        guard let usage else { return MetricFormatting.unavailable }
        return MetricFormatting.percentage(usage.total, locale: locale)
    }

    static func memory(
        _ usage: MemoryUsage?,
        style: MemoryMenuValueStyle,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        guard let usage else { return MetricFormatting.unavailable }

        switch style {
        case .percentage:
            return MetricFormatting.percentage(usage.usedFraction, locale: locale)
        case .used:
            return MetricFormatting.compactBytes(usage.usedBytes, style: .memory, locale: locale)
        }
    }

    static func storage(
        _ usage: StorageUsage?,
        style: StorageMenuValueStyle,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        guard let usage else { return MetricFormatting.unavailable }

        switch style {
        case .percentage:
            return MetricFormatting.percentage(usage.usedFraction, locale: locale)
        case .available:
            return MetricFormatting.compactBytes(usage.availableBytes, style: .storage, locale: locale)
        }
    }
}
