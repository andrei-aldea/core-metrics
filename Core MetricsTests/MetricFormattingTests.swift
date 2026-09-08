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

    @Test("Builds one complete text-only status label")
    func buildsStatusLabel() {
        #expect(
            MenuBarLabelFormatting.text(
                stats: [.cpuUser, .memoryUsed],
                values: ["15%", "12.0GB"],
                displayMode: .compact,
                locale: locale
            ) == "CU  15% MU   12.0GB"
        )
        #expect(
            MenuBarLabelFormatting.text(
                stats: [.cpuUser],
                values: ["15%"],
                displayMode: .labelAndValue,
                locale: locale
            ) == "CPU User  15%"
        )
        #expect(
            MenuBarLabelFormatting.text(
                stats: [.storageTotal],
                values: ["1.0TB"],
                displayMode: .labelAndValue,
                locale: locale
            ) == "Storage Total    1.0TB"
        )
        #expect(
            MenuBarLabelFormatting.text(
                stats: [.cpuUser],
                values: ["9%"],
                displayMode: .valueOnly,
                locale: locale
            ) == "  9%"
        )
        #expect(
            MenuBarLabelFormatting.text(
                stats: [.cpuUser],
                values: [],
                displayMode: .compact,
                locale: locale
            ) == MetricFormatting.unavailable
        )
    }

    @Test("Every display mode fills its reserved character width", arguments: [
        ([MenuBarStat.cpuUser], ["9%"], MenuBarDisplayMode.labelAndValue),
        ([.cpuUser], ["99%"], .valueOnly),
        ([.cpuUser, .memoryUsed], ["9%", "2.1GB"], .compact),
    ])
    func fillsReservedCharacterWidth(
        stats: [MenuBarStat],
        values: [String],
        displayMode: MenuBarDisplayMode
    ) {
        let text = MenuBarLabelFormatting.text(
            stats: stats,
            values: values,
            displayMode: displayMode,
            locale: locale
        )
        #expect(
            text.count == MenuBarLabelFormatting.reservedCharacterCount(
                stats: stats,
                displayMode: displayMode,
                locale: locale
            )
        )
    }

    @Test("Each live value keeps a stable menu-bar column width")
    func reservesStableStatusValueWidth() {
        let stats: [MenuBarStat] = [
            .cpuUsed,
            .memoryUsedPercentage,
            .memoryWired,
            .memoryCompressed,
            .memoryTotal,
            .storageUsedPercentage,
            .storageTotal,
        ]
        let shorterValues = MenuBarLabelFormatting.text(
            stats: stats,
            values: ["9%", "1%", "2.1GB", "1.0GB", "8.0GB", "9%", "9.0GB"],
            displayMode: .compact,
            locale: locale
        )
        let longerValues = MenuBarLabelFormatting.text(
            stats: stats,
            values: ["100%", "100%", "1023.9GB", "999.9GB", "999.9GB", "100%", "999.9TB"],
            displayMode: .compact,
            locale: locale
        )

        #expect(longerValues.contains("1023.9GB"))
        #expect(shorterValues.count == 71)
        #expect(
            MenuBarLabelFormatting.reservedCharacterCount(
                stats: stats,
                displayMode: .compact,
                locale: locale
            ) == shorterValues.count
        )
        #expect(shorterValues.count == longerValues.count)
    }

    @Test("Percentage columns preserve zero through 100 in every available locale and display mode")
    func percentagesFitAvailableLocales() throws {
        let percentageStats: [MenuBarStat] = [
            .cpuUsed, .cpuUser, .cpuSystem, .cpuIdle,
            .memoryUsedPercentage, .storageUsedPercentage,
        ]

        for identifier in Locale.availableIdentifiers {
            let locale = Locale(identifier: identifier)
            let values = (0...100).map {
                MetricFormatting.percentage(Double($0) / 100, locale: locale)
            }
            let longestValue = try #require(values.max { $0.count < $1.count })

            for mode in MenuBarDisplayMode.allCases {
                let capacity = MenuBarLabelFormatting.valueColumnWidth(
                    for: .cpuUser,
                    displayMode: mode,
                    locale: locale
                )
                #expect(capacity >= 4)
                #expect(
                    values.allSatisfy { $0.count <= capacity },
                    "Every formatted percentage must fit in \(identifier), \(mode)"
                )

                for stat in percentageStats {
                    let text = MenuBarLabelFormatting.text(
                        stats: [stat],
                        values: [longestValue],
                        displayMode: mode,
                        locale: locale
                    )
                    #expect(text.hasSuffix(longestValue), "Preserve the full value in \(identifier)")
                    #expect(
                        text.count == MenuBarLabelFormatting.reservedCharacterCount(
                            stats: [stat], displayMode: mode, locale: locale
                        )
                    )
                }
            }
        }
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
