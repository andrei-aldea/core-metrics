import Foundation
import Testing
@testable import Core_Metrics

@Suite("Metric formatting")
struct MetricFormattingTests {
    private let locale = Locale(identifier: "en_US_POSIX")

    @Test("Formats normalized percentages", arguments: [
        (0.0, "0%"),
        (0.176, "18%"),
        (1.0, "100%"),
        (-1.0, "0%"),
        (2.0, "100%"),
    ])
    func formatsPercentages(_ fraction: Double, expected: String) {
        #expect(MetricFormatting.percentage(fraction, locale: locale) == expected)
    }

    @Test("Formats compact memory values", arguments: [
        (UInt64(0), "0B"),
        (UInt64(1_024), "1K"),
        (UInt64(1_610_612_736), "1.5G"),
        (UInt64(12 * 1_024 * 1_024 * 1_024), "12G"),
    ])
    func formatsCompactMemory(_ bytes: UInt64, expected: String) {
        #expect(MetricFormatting.compactBytes(bytes, style: .memory, locale: locale) == expected)
    }

    @Test("Formats compact storage values with decimal units")
    func formatsCompactStorage() {
        #expect(
            MetricFormatting.compactBytes(
                143_000_000_000,
                style: .storage,
                locale: locale
            ) == "143G"
        )
    }

    @Test("Formats each CPU menu value", arguments: [
        (CPUMenuValueStyle.total, "40%"),
        (.user, "15%"),
        (.system, "25%"),
        (.idle, "60%"),
    ])
    func formatsCPUMenuValues(style: CPUMenuValueStyle, expected: String) {
        let cpu = CPUUsage(total: 0.4, user: 0.15, system: 0.25, idle: 0.6)
        #expect(MenuValueFormatting.cpu(cpu, style: style, locale: locale) == expected)
    }

    @Test("Formats each memory menu value", arguments: [
        (MemoryMenuValueStyle.percentage, "75%"),
        (.used, "12G"),
        (.available, "4G"),
        (.appEstimate, "8G"),
        (.wired, "3G"),
        (.compressed, "1G"),
        (.total, "16G"),
    ])
    func formatsMemoryMenuValues(style: MemoryMenuValueStyle, expected: String) {
        let memory = MemoryUsage(
            usedBytes: 12 * 1_024 * 1_024 * 1_024,
            availableBytes: 4 * 1_024 * 1_024 * 1_024,
            totalBytes: 16 * 1_024 * 1_024 * 1_024,
            appEstimateBytes: 8 * 1_024 * 1_024 * 1_024,
            wiredBytes: 3 * 1_024 * 1_024 * 1_024,
            compressedBytes: 1 * 1_024 * 1_024 * 1_024,
            usedFraction: 0.75
        )

        #expect(MenuValueFormatting.memory(memory, style: style, locale: locale) == expected)
    }

    @Test("Formats each storage menu value", arguments: [
        (StorageMenuValueStyle.percentage, "86%"),
        (.used, "857G"),
        (.available, "143G"),
        (.total, "1T"),
    ])
    func formatsStorageMenuValues(style: StorageMenuValueStyle, expected: String) {
        let storage = StorageUsage(
            usedBytes: 857_000_000_000,
            availableBytes: 143_000_000_000,
            totalBytes: 1_000_000_000_000,
            usedFraction: 0.857
        )

        #expect(MenuValueFormatting.storage(storage, style: style, locale: locale) == expected)
    }

    @Test("Routes every concrete menu-bar stat to its value", arguments: [
        (MenuBarStat.cpuTotal, "40%"),
        (.cpuUser, "15%"),
        (.cpuSystem, "25%"),
        (.cpuIdle, "60%"),
        (.memoryPercentage, "75%"),
        (.memoryUsed, "12G"),
        (.memoryAvailable, "4G"),
        (.memoryAppEstimate, "8G"),
        (.memoryWired, "3G"),
        (.memoryCompressed, "1G"),
        (.memoryTotal, "16G"),
        (.storagePercentage, "86%"),
        (.storageUsed, "857G"),
        (.storageAvailable, "143G"),
        (.storageTotal, "1T"),
    ])
    func formatsConcreteMenuBarStat(stat: MenuBarStat, expected: String) {
        let cpu = CPUUsage(total: 0.4, user: 0.15, system: 0.25, idle: 0.6)
        let memory = MemoryUsage(
            usedBytes: 12 * 1_024 * 1_024 * 1_024,
            availableBytes: 4 * 1_024 * 1_024 * 1_024,
            totalBytes: 16 * 1_024 * 1_024 * 1_024,
            appEstimateBytes: 8 * 1_024 * 1_024 * 1_024,
            wiredBytes: 3 * 1_024 * 1_024 * 1_024,
            compressedBytes: 1 * 1_024 * 1_024 * 1_024,
            usedFraction: 0.75
        )
        let storage = StorageUsage(
            usedBytes: 857_000_000_000,
            availableBytes: 143_000_000_000,
            totalBytes: 1_000_000_000_000,
            usedFraction: 0.857
        )

        #expect(
            MenuValueFormatting.value(
                for: stat,
                cpuUsage: cpu,
                memoryUsage: memory,
                storageUsage: storage,
                locale: locale
            ) == expected
        )
    }

    @Test("Unavailable values use a stable placeholder")
    func formatsUnavailableValues() {
        #expect(MenuValueFormatting.cpu(nil, style: .idle, locale: locale) == "—")
        #expect(MenuValueFormatting.memory(nil, style: .used, locale: locale) == "—")
        #expect(MenuValueFormatting.storage(nil, style: .available, locale: locale) == "—")
    }
}
