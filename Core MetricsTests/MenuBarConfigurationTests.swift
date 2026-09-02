import Foundation
import Testing
@testable import Core_Metrics

@Suite("Menu-bar configuration")
struct MenuBarConfigurationTests {
    @Test("Metric metadata has stable identifiers")
    func metricMetadata() {
        #expect(MetricKind.cpu.id == "cpu")
        #expect(MetricKind.memory.id == "memory")
        #expect(MetricKind.storage.id == "storage")
        #expect(MetricKind.allCases.map(\.shortCode) == ["C", "M", "S"])
        #expect(MetricKind.allCases.map(\.systemImage) == ["cpu", "memorychip", "internaldrive"])
    }

    @Test("Menu-bar stats have stable persistence values and categories")
    func menuBarStatMetadata() {
        #expect(MenuBarStat.allCases.map(\.rawValue) == [
            "cpuTotal",
            "cpuUser",
            "cpuSystem",
            "cpuIdle",
            "memoryPercentage",
            "memoryUsed",
            "memoryAvailable",
            "memoryAppEstimate",
            "memoryWired",
            "memoryCompressed",
            "memoryTotal",
            "storagePercentage",
            "storageUsed",
            "storageAvailable",
            "storageTotal",
        ])
        #expect(MenuBarStat.values(for: .cpu).count == 4)
        #expect(MenuBarStat.values(for: .memory).count == 7)
        #expect(MenuBarStat.values(for: .storage).count == 4)
        #expect(MenuBarStat.allCases.map(\.shortCode) == [
            "CT", "CU", "CS", "CI",
            "M%", "MU", "MA", "ME", "MW", "MC", "MT",
            "S%", "SU", "SA", "ST",
        ])
    }

    @Test("Display modes have stable persistence values")
    func displayModeRawValues() {
        #expect(MenuBarDisplayMode.allCases.map(\.rawValue) == [
            "iconAndValue",
            "valueOnly",
            "compact",
        ])
    }

    @Test("Legacy metric value styles have stable persistence values")
    func metricValueStyleRawValues() {
        #expect(CPUMenuValueStyle.allCases.map(\.rawValue) == [
            "total",
            "user",
            "system",
            "idle",
        ])
        #expect(MemoryMenuValueStyle.allCases.map(\.rawValue) == [
            "percentage",
            "used",
            "available",
            "appEstimate",
            "wired",
            "compressed",
            "total",
        ])
        #expect(StorageMenuValueStyle.allCases.map(\.rawValue) == [
            "percentage",
            "used",
            "available",
            "total",
        ])
    }

    @Test("Initialization repairs empty, duplicate, and oversized lists", arguments: [
        ([MenuBarStat](), [MenuBarStat.cpuTotal]),
        ([.memoryUsed, .cpuTotal, .memoryUsed], [.memoryUsed, .cpuTotal]),
        (
            [.storageTotal, .memoryUsed, .cpuTotal, .cpuUser, .cpuSystem, .cpuIdle],
            [.storageTotal, .memoryUsed, .cpuTotal, .cpuUser, .cpuSystem]
        ),
    ])
    func normalizesEnabledStats(input: [MenuBarStat], expected: [MenuBarStat]) {
        let configuration = MenuBarConfiguration(enabledStats: input)
        #expect(configuration.enabledStats == expected)
    }

    @Test("At least one stat must remain enabled")
    func preservesMinimumEnabledStat() {
        var configuration = MenuBarConfiguration()

        #expect(!configuration.canDisable(.cpuTotal))
        let refusedLastDisable = configuration.setStat(.cpuTotal, enabled: false)
        #expect(!refusedLastDisable)
        #expect(configuration.enabledStats == [.cpuTotal])

        let enabledMemory = configuration.setStat(.memoryUsed, enabled: true)
        #expect(enabledMemory)
        #expect(configuration.canDisable(.cpuTotal))
        let disabledCPU = configuration.setStat(.cpuTotal, enabled: false)
        #expect(disabledCPU)
        #expect(configuration.enabledStats == [.memoryUsed])
        let refusedOnlyMemoryDisable = configuration.setStat(.memoryUsed, enabled: false)
        #expect(!refusedOnlyMemoryDisable)
    }

    @Test("Stats append in order and stop at five")
    func enablesStatsInOrder() {
        var configuration = MenuBarConfiguration()

        let enabledCPUUser = configuration.setStat(.cpuUser, enabled: true)
        let enabledMemory = configuration.setStat(.memoryUsed, enabled: true)
        let enabledStorage = configuration.setStat(.storageAvailable, enabled: true)
        let enabledCompressed = configuration.setStat(.memoryCompressed, enabled: true)
        let refusedSixth = configuration.setStat(.storageTotal, enabled: true)
        let refusedDuplicate = configuration.setStat(.memoryUsed, enabled: true)

        #expect(enabledCPUUser)
        #expect(enabledMemory)
        #expect(enabledStorage)
        #expect(enabledCompressed)
        #expect(!refusedSixth)
        #expect(!refusedDuplicate)
        #expect(configuration.enabledStats == [
            .cpuTotal,
            .cpuUser,
            .memoryUsed,
            .storageAvailable,
            .memoryCompressed,
        ])
    }

    @Test("Value-only mode remains exclusive to one stat")
    func restrictsValueOnlyMode() {
        var configuration = MenuBarConfiguration(displayMode: .valueOnly)
        #expect(configuration.displayMode == .valueOnly)

        let enabledMemory = configuration.setStat(.memoryUsed, enabled: true)
        #expect(enabledMemory)
        #expect(configuration.displayMode == .compact)

        configuration.displayMode = .valueOnly
        #expect(configuration.displayMode == .compact)

        let normalized = MenuBarConfiguration(
            enabledStats: [.cpuTotal, .storagePercentage],
            displayMode: .valueOnly
        )
        #expect(normalized.displayMode == .compact)
    }

    @Test("Reordering moves one adjacent position and respects boundaries")
    func reordersStats() {
        var configuration = MenuBarConfiguration(
            enabledStats: [.cpuTotal, .memoryUsed, .storagePercentage]
        )

        let movedCPUDown = configuration.moveStatDown(.cpuTotal)
        #expect(movedCPUDown)
        #expect(configuration.enabledStats == [.memoryUsed, .cpuTotal, .storagePercentage])
        let movedStorageUp = configuration.moveStatUp(.storagePercentage)
        #expect(movedStorageUp)
        #expect(configuration.enabledStats == [.memoryUsed, .storagePercentage, .cpuTotal])
        let movedFirstUp = configuration.moveStatUp(.memoryUsed)
        let movedLastDown = configuration.moveStatDown(.cpuTotal)
        let movedLastByDirection = configuration.moveStat(.cpuTotal, direction: .down)

        #expect(!movedFirstUp)
        #expect(!movedLastDown)
        #expect(!movedLastByDirection)
    }

    @Test("Decoding repairs an empty current-format stat list")
    func decodingRepairsInvariant() throws {
        let data = try #require(
            """
            {
              "enabledStats": [],
              "displayMode": "compact"
            }
            """.data(using: .utf8)
        )

        let configuration = try JSONDecoder().decode(MenuBarConfiguration.self, from: data)
        #expect(configuration.enabledStats == [.cpuTotal])
        #expect(configuration.displayMode == .compact)
    }

    @Test("Version 1 preferences migrate to equivalent concrete stats")
    func migratesVersionOnePreferences() throws {
        let data = try #require(
            """
            {
              "enabledMetrics": ["storage", "cpu", "memory"],
              "displayMode": "compact",
              "cpuValueStyle": "system",
              "memoryValueStyle": "compressed",
              "storageValueStyle": "available"
            }
            """.data(using: .utf8)
        )

        let configuration = try JSONDecoder().decode(MenuBarConfiguration.self, from: data)
        #expect(configuration.enabledStats == [
            .storageAvailable,
            .cpuSystem,
            .memoryCompressed,
        ])
        #expect(configuration.displayMode == .compact)
    }

    @Test("Reset restores every default")
    func resetsConfiguration() {
        var configuration = MenuBarConfiguration(
            enabledStats: [.storageTotal, .memoryUsed],
            displayMode: .compact
        )

        configuration.reset()
        #expect(configuration == .defaultValue)
    }
}
