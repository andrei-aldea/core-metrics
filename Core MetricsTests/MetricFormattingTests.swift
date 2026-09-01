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

    @Test("Menu formatting selects the configured value")
    func formatsMenuValues() {
        let memory = MemoryUsage(
            usedBytes: 12 * 1_024 * 1_024 * 1_024,
            availableBytes: 4 * 1_024 * 1_024 * 1_024,
            totalBytes: 16 * 1_024 * 1_024 * 1_024,
            usedFraction: 0.75
        )
        let storage = StorageUsage(
            usedBytes: 857_000_000_000,
            availableBytes: 143_000_000_000,
            totalBytes: 1_000_000_000_000,
            usedFraction: 0.857
        )

        #expect(MenuValueFormatting.memory(memory, style: .percentage, locale: locale) == "75%")
        #expect(MenuValueFormatting.memory(memory, style: .used, locale: locale) == "12G")
        #expect(MenuValueFormatting.storage(storage, style: .percentage, locale: locale) == "86%")
        #expect(MenuValueFormatting.storage(storage, style: .available, locale: locale) == "143G")
    }

    @Test("Unavailable values use a stable placeholder")
    func formatsUnavailableValues() {
        #expect(MenuValueFormatting.cpu(nil, locale: locale) == "—")
        #expect(MenuValueFormatting.memory(nil, style: .used, locale: locale) == "—")
        #expect(MenuValueFormatting.storage(nil, style: .available, locale: locale) == "—")
    }
}
