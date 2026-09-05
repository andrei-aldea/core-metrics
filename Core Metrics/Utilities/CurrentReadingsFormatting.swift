import Foundation

/// Formats the selected current values for copying, without status-item
/// abbreviations, padding, or visual truncation.
nonisolated enum CurrentReadingsFormatting {
    static func text(
        stats: [MenuBarStat],
        cpuUsage: CPUUsage?,
        memoryUsage: MemoryUsage?,
        storageUsage: StorageUsage?,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        stats.map { stat in
            let value = MenuValueFormatting.value(
                for: stat,
                cpuUsage: cpuUsage,
                memoryUsage: memoryUsage,
                storageUsage: storageUsage,
                locale: locale
            )
            let readableValue = value == MetricFormatting.unavailable
                ? String(localized: "Unavailable", locale: locale)
                : value
            return "\(stat.displayName): \(readableValue)"
        }
        .joined(separator: "\n")
    }
}
