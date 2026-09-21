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
        (Double.nan, "0%"),
        (Double.infinity, "0%"),
    ])
    func formatsPercentages(_ fraction: Double, expected: String) {
        #expect(MetricFormatting.percentage(fraction, locale: locale) == expected)
    }

    @Test("Formats compact memory values", arguments: [
        (UInt64(0), "0.0B"),
        (UInt64(1_024), "1.0KB"),
        (UInt64(1_610_612_736), "1.5GB"),
        (UInt64(12 * 1_024 * 1_024 * 1_024), "12.0GB"),
        (UInt64(13.86 * 1_024 * 1_024 * 1_024), "13.9GB"),
        (UInt64(1023.96 * 1_024 * 1_024 * 1_024), "1.0TB"),
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
            ) == "143.0GB"
        )
    }

    @Test("Byte decimals follow the requested locale")
    func formatsByteDecimalsForLocale() {
        let romanianLocale = Locale(identifier: "ro_RO")

        #expect(
            MetricFormatting.compactBytes(
                143_000_000_000,
                style: .storage,
                locale: romanianLocale
            ) == "143,0GB"
        )
    }

    @Test("Routes every concrete menu-bar stat to its value", arguments: [
        (MenuBarStat.cpuUsed, "40%"),
        (.cpuUser, "15%"),
        (.cpuSystem, "25%"),
        (.cpuIdle, "60%"),
        (.memoryUsed, "12.0GB"),
        (.memoryUsedPercentage, "75%"),
        (.memoryWired, "4.0GB"),
        (.memoryCompressed, "2.5GB"),
        (.memoryCached, "3.0GB"),
        (.memorySwap, "1.0GB"),
        (.memoryTotal, "16.0GB"),
        (.storageUsed, "857.0GB"),
        (.storageUsedPercentage, "86%"),
        (.storageFree, "143.0GB"),
        (.storageTotal, "1.0TB"),
    ])
    func formatsConcreteMenuBarStat(stat: MenuBarStat, expected: String) {
        let cpu = CPUUsage(user: 0.15, system: 0.25, idle: 0.6)
        let memory = MemoryUsage(
            usedBytes: 12 * 1_024 * 1_024 * 1_024,
            cachedBytes: 3 * 1_024 * 1_024 * 1_024,
            swapUsedBytes: 1 * 1_024 * 1_024 * 1_024,
            wiredBytes: 4 * 1_024 * 1_024 * 1_024,
            compressedBytes: 5 * 1_024 * 1_024 * 1_024 / 2,
            totalBytes: 16 * 1_024 * 1_024 * 1_024
        )
        let storage = StorageUsage(
            usedBytes: 857_000_000_000,
            availableBytes: 143_000_000_000,
            totalBytes: 1_000_000_000_000
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
        let memoryWithoutSwap = MemoryUsage(
            usedBytes: 12,
            cachedBytes: 3,
            swapUsedBytes: nil,
            wiredBytes: 4,
            compressedBytes: 2,
            totalBytes: 16
        )

        #expect(formattedValue(for: .cpuUsed, cpu: nil) == "—")
        #expect(formattedValue(for: .cpuIdle, cpu: nil) == "—")
        #expect(formattedValue(for: .memoryUsed, memory: nil) == "—")
        #expect(formattedValue(for: .memoryWired, memory: nil) == "—")
        #expect(formattedValue(for: .memorySwap, memory: memoryWithoutSwap) == "—")
        #expect(formattedValue(for: .storageUsedPercentage, storage: nil) == "—")
        #expect(formattedValue(for: .storageFree, storage: nil) == "—")
    }

    private func formattedValue(
        for stat: MenuBarStat,
        cpu: CPUUsage? = nil,
        memory: MemoryUsage? = nil,
        storage: StorageUsage? = nil
    ) -> String {
        MenuValueFormatting.value(
            for: stat,
            cpuUsage: cpu,
            memoryUsage: memory,
            storageUsage: storage,
            locale: locale
        )
    }
}
