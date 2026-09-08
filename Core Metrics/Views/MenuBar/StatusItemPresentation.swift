import Foundation

/// One immutable rendering update shared by the native status item and preview.
nonisolated struct StatusItemPresentation: Sendable {
    let configuration: MenuBarConfiguration
    let values: [String]
    let accessibilitySummary: String

    init(
        configuration: MenuBarConfiguration,
        cpuUsage: CPUUsage?,
        memoryUsage: MemoryUsage?,
        storageUsage: StorageUsage?,
        locale: Locale
    ) {
        self.configuration = configuration
        let stats = configuration.enabledStats
        values = stats.map { stat in
            MenuValueFormatting.value(
                for: stat,
                cpuUsage: cpuUsage,
                memoryUsage: memoryUsage,
                storageUsage: storageUsage,
                locale: locale
            )
        }
        accessibilitySummary = zip(stats, values).map { stat, value in
            let readableValue = value == MetricFormatting.unavailable
                ? String(localized: "Unavailable")
                : value
            return "\(stat.displayName), \(readableValue)"
        }.joined(separator: ", ")
    }

    var accessibilityLabel: String {
        String(localized: "Core Metrics, \(accessibilitySummary)")
    }
}
