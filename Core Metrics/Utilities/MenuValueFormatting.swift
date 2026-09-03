import Foundation

/// Pure menu-bar value selection that guarantees compact, non-arbitrary value
/// strings for every supported aggregate statistic.
nonisolated enum MenuValueFormatting {
    static func value(
        for stat: MenuBarStat,
        cpuUsage: CPUUsage?,
        memoryUsage: MemoryUsage?,
        storageUsage: StorageUsage?,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        switch stat {
        case .cpuUsed:
            percentage(cpuUsage?.used, locale: locale)
        case .cpuUser:
            percentage(cpuUsage?.user, locale: locale)
        case .cpuSystem:
            percentage(cpuUsage?.system, locale: locale)
        case .cpuIdle:
            percentage(cpuUsage?.idle, locale: locale)
        case .memoryUsed:
            memory(memoryUsage?.usedBytes, locale: locale)
        case .memoryUsedPercentage:
            percentage(memoryUsage?.usedFraction, locale: locale)
        case .memoryWired:
            memory(memoryUsage?.wiredBytes, locale: locale)
        case .memoryCompressed:
            memory(memoryUsage?.compressedBytes, locale: locale)
        case .memoryCached:
            memory(memoryUsage?.cachedBytes, locale: locale)
        case .memorySwap:
            memory(memoryUsage?.swapUsedBytes, locale: locale)
        case .memoryTotal:
            memory(memoryUsage?.totalBytes, locale: locale)
        case .storageUsed:
            storage(storageUsage?.usedBytes, locale: locale)
        case .storageUsedPercentage:
            percentage(storageUsage?.usedFraction, locale: locale)
        case .storageFree:
            storage(storageUsage?.availableBytes, locale: locale)
        case .storageTotal:
            storage(storageUsage?.totalBytes, locale: locale)
        }
    }

    private static func percentage(
        _ value: Double?,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        guard let value else { return MetricFormatting.unavailable }
        return MetricFormatting.percentage(value, locale: locale)
    }

    private static func memory(
        _ value: UInt64?,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        guard let value else { return MetricFormatting.unavailable }
        return MetricFormatting.compactBytes(value, style: .memory, locale: locale)
    }

    private static func storage(
        _ value: UInt64?,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        guard let value else { return MetricFormatting.unavailable }
        return MetricFormatting.compactBytes(value, style: .storage, locale: locale)
    }
}
