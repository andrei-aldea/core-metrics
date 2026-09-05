import Foundation
import Testing
@testable import Core_Metrics

@Suite("Current readings formatting")
struct CurrentReadingsFormattingTests {
    private let locale = Locale(identifier: "en_US_POSIX")

    @Test("Copies all seven selected readings with complete names")
    func formatsSevenReadings() {
        let text = CurrentReadingsFormatting.text(
            stats: [
                .cpuUsed, .cpuUser, .cpuSystem, .cpuIdle,
                .memoryUsed, .memoryUsedPercentage, .storageUsedPercentage,
            ],
            cpuUsage: CPUUsage(user: 0.15, system: 0.25, idle: 0.6),
            memoryUsage: memory,
            storageUsage: storage,
            locale: locale
        )

        #expect(text == """
        CPU Used: 40%
        CPU User: 15%
        CPU System: 25%
        CPU Idle: 60%
        Memory Used: 12.0GB
        RAM Used %: 75%
        SSD Used %: 86%
        """)
    }

    @Test("Names unavailable readings instead of copying an em dash", arguments: MenuBarStat.allCases)
    func spellsOutUnavailable(stat: MenuBarStat) {
        let text = CurrentReadingsFormatting.text(
            stats: [stat],
            cpuUsage: nil,
            memoryUsage: nil,
            storageUsage: nil,
            locale: locale
        )

        #expect(text == "\(stat.displayName): Unavailable")
    }

    @Test("Unavailable swap preserves other current memory values")
    func handlesUnavailableSwap() {
        let memoryWithoutSwap = MemoryUsage(
            usedBytes: memory.usedBytes,
            cachedBytes: memory.cachedBytes,
            swapUsedBytes: nil,
            wiredBytes: memory.wiredBytes,
            compressedBytes: memory.compressedBytes,
            totalBytes: memory.totalBytes
        )
        let text = CurrentReadingsFormatting.text(
            stats: [.memoryUsed, .memorySwap],
            cpuUsage: nil,
            memoryUsage: memoryWithoutSwap,
            storageUsage: nil,
            locale: locale
        )

        #expect(text == "Memory Used: 12.0GB\nSwap Used: Unavailable")
    }

    @Test("Copies localized byte values", arguments: [
        ("en_US_POSIX", "12.0GB", "143.0GB"),
        ("ro_RO", "12,0GB", "143,0GB"),
    ])
    func formatsForLocale(identifier: String, memoryValue: String, storageValue: String) {
        let text = CurrentReadingsFormatting.text(
            stats: [.memoryUsed, .storageFree],
            cpuUsage: nil,
            memoryUsage: memory,
            storageUsage: storage,
            locale: Locale(identifier: identifier)
        )

        #expect(text == "Memory Used: \(memoryValue)\nSSD Free Space: \(storageValue)")
    }

    private var memory: MemoryUsage {
        MemoryUsage(
            usedBytes: 12 * 1_024 * 1_024 * 1_024,
            cachedBytes: 3 * 1_024 * 1_024 * 1_024,
            swapUsedBytes: 1_024 * 1_024 * 1_024,
            wiredBytes: 4 * 1_024 * 1_024 * 1_024,
            compressedBytes: 5 * 1_024 * 1_024 * 1_024 / 2,
            totalBytes: 16 * 1_024 * 1_024 * 1_024
        )
    }

    private var storage: StorageUsage {
        StorageUsage(
            usedBytes: 857_000_000_000,
            availableBytes: 143_000_000_000,
            totalBytes: 1_000_000_000_000
        )
    }
}
