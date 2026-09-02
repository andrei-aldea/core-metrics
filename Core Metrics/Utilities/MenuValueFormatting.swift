import Foundation

/// Pure menu-bar value selection. Views add SF Symbols and accessibility text;
/// this layer guarantees compact, non-arbitrary value strings.
nonisolated enum MenuValueFormatting {
    static func value(
        for stat: MenuBarStat,
        cpuUsage: CPUUsage?,
        memoryUsage: MemoryUsage?,
        storageUsage: StorageUsage?,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        switch stat {
        case .cpuTotal:
            cpu(cpuUsage, style: .total, locale: locale)
        case .cpuUser:
            cpu(cpuUsage, style: .user, locale: locale)
        case .cpuSystem:
            cpu(cpuUsage, style: .system, locale: locale)
        case .cpuIdle:
            cpu(cpuUsage, style: .idle, locale: locale)
        case .memoryPercentage:
            memory(memoryUsage, style: .percentage, locale: locale)
        case .memoryUsed:
            memory(memoryUsage, style: .used, locale: locale)
        case .memoryAvailable:
            memory(memoryUsage, style: .available, locale: locale)
        case .memoryAppEstimate:
            memory(memoryUsage, style: .appEstimate, locale: locale)
        case .memoryWired:
            memory(memoryUsage, style: .wired, locale: locale)
        case .memoryCompressed:
            memory(memoryUsage, style: .compressed, locale: locale)
        case .memoryTotal:
            memory(memoryUsage, style: .total, locale: locale)
        case .storagePercentage:
            storage(storageUsage, style: .percentage, locale: locale)
        case .storageUsed:
            storage(storageUsage, style: .used, locale: locale)
        case .storageAvailable:
            storage(storageUsage, style: .available, locale: locale)
        case .storageTotal:
            storage(storageUsage, style: .total, locale: locale)
        }
    }

    static func cpu(
        _ usage: CPUUsage?,
        style: CPUMenuValueStyle,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        guard let usage else { return MetricFormatting.unavailable }

        let fraction = switch style {
        case .total:
            usage.total
        case .user:
            usage.user
        case .system:
            usage.system
        case .idle:
            usage.idle
        }
        return MetricFormatting.percentage(fraction, locale: locale)
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
        case .available:
            return MetricFormatting.compactBytes(usage.availableBytes, style: .memory, locale: locale)
        case .appEstimate:
            return MetricFormatting.compactBytes(usage.appEstimateBytes, style: .memory, locale: locale)
        case .wired:
            return MetricFormatting.compactBytes(usage.wiredBytes, style: .memory, locale: locale)
        case .compressed:
            return MetricFormatting.compactBytes(usage.compressedBytes, style: .memory, locale: locale)
        case .total:
            return MetricFormatting.compactBytes(usage.totalBytes, style: .memory, locale: locale)
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
        case .used:
            return MetricFormatting.compactBytes(usage.usedBytes, style: .storage, locale: locale)
        case .available:
            return MetricFormatting.compactBytes(usage.availableBytes, style: .storage, locale: locale)
        case .total:
            return MetricFormatting.compactBytes(usage.totalBytes, style: .storage, locale: locale)
        }
    }
}
