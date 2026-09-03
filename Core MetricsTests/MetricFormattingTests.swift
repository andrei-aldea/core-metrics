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
        (UInt64(13.86 * 1_024 * 1_024 * 1_024), "13.9G"),
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

    @Test("Routes every concrete menu-bar stat to its value", arguments: [
        (MenuBarStat.cpuUser, "15%"),
        (.cpuSystem, "25%"),
        (.cpuIdle, "60%"),
        (.memoryUsed, "12G"),
        (.memoryCached, "3G"),
        (.memorySwap, "1G"),
        (.storageUsed, "857G"),
        (.storageFree, "143G"),
        (.storageTotal, "1T"),
    ])
    func formatsConcreteMenuBarStat(stat: MenuBarStat, expected: String) {
        let cpu = CPUUsage(total: 0.4, user: 0.15, system: 0.25, idle: 0.6)
        let memory = MemoryUsage(
            usedBytes: 12 * 1_024 * 1_024 * 1_024,
            cachedBytes: 3 * 1_024 * 1_024 * 1_024,
            swapUsedBytes: 1 * 1_024 * 1_024 * 1_024
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
            swapUsedBytes: nil
        )

        #expect(formattedValue(for: .cpuIdle, cpu: nil) == "—")
        #expect(formattedValue(for: .memoryUsed, memory: nil) == "—")
        #expect(formattedValue(for: .memorySwap, memory: memoryWithoutSwap) == "—")
        #expect(formattedValue(for: .storageFree, storage: nil) == "—")
    }

    @Test("Builds one complete text-only status label")
    func buildsStatusLabel() {
        #expect(
            MenuBarLabelFormatting.text(
                stats: [.cpuUser, .memoryUsed],
                values: ["15%", "12G"],
                displayMode: .compact
            ) == "CU   15%  MU   12G"
        )
        #expect(
            MenuBarLabelFormatting.text(
                stats: [.cpuUser],
                values: ["15%"],
                displayMode: .labelAndValue
            ) == "CPU User   15%"
        )
        #expect(
            MenuBarLabelFormatting.text(
                stats: [.storageTotal],
                values: ["1T"],
                displayMode: .labelAndValue
            ) == "SSD Total    1T"
        )
        #expect(
            MenuBarLabelFormatting.text(
                stats: [.cpuUser],
                values: ["9%"],
                displayMode: .valueOnly
            ) == "   9%"
        )
    }

    @Test("Each live value keeps a stable menu-bar column width")
    func reservesStableStatusValueWidth() {
        let stats: [MenuBarStat] = [
            .cpuUser,
            .cpuSystem,
            .memoryUsed,
            .storageFree,
            .memorySwap,
        ]
        let shorterValues = MenuBarLabelFormatting.text(
            stats: stats,
            values: ["9%", "1%", "2.1G", "9G", "—"],
            displayMode: .compact
        )
        let longerValues = MenuBarLabelFormatting.text(
            stats: stats,
            values: ["100%", "99%", "13.9G", "999G", "8.8G"],
            displayMode: .compact
        )

        #expect(shorterValues.count == longerValues.count)
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
