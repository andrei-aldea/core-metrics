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
            "cpuUser",
            "cpuSystem",
            "cpuIdle",
            "memoryUsed",
            "memoryCached",
            "memorySwap",
            "storageUsed",
            "storageAvailable",
            "storageTotal",
        ])
        #expect(MenuBarStat.values(for: .cpu).count == 3)
        #expect(MenuBarStat.values(for: .memory).count == 3)
        #expect(MenuBarStat.values(for: .storage).count == 3)
        #expect(MenuBarStat.allCases.map(\.shortCode) == [
            "CU", "CS", "CI",
            "MU", "CF", "SW",
            "SU", "SF", "ST",
        ])
        #expect(MenuBarStat.allCases.map(\.dashboardName) == [
            "User", "System", "Idle",
            "Memory Used", "Cached Files", "Swap Used",
            "Used Space", "Free Space", "Total Capacity",
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
        ([MenuBarStat](), [MenuBarStat.cpuUser]),
        ([.memoryUsed, .cpuUser, .memoryUsed], [.memoryUsed, .cpuUser]),
        (
            [.storageTotal, .memoryUsed, .cpuUser, .cpuSystem, .cpuIdle, .memoryCached],
            [.storageTotal, .memoryUsed, .cpuUser, .cpuSystem, .cpuIdle]
        ),
    ])
    func normalizesEnabledStats(input: [MenuBarStat], expected: [MenuBarStat]) {
        let configuration = MenuBarConfiguration(enabledStats: input)
        #expect(configuration.enabledStats == expected)
    }

    @Test("At least one stat must remain enabled")
    func preservesMinimumEnabledStat() {
        var configuration = MenuBarConfiguration()

        #expect(!configuration.canDisable(.cpuUser))
        let refusedLastDisable = configuration.setStat(.cpuUser, enabled: false)
        #expect(!refusedLastDisable)
        #expect(configuration.enabledStats == [.cpuUser])

        let enabledMemory = configuration.setStat(.memoryUsed, enabled: true)
        #expect(enabledMemory)
        #expect(configuration.canDisable(.cpuUser))
        let disabledCPU = configuration.setStat(.cpuUser, enabled: false)
        #expect(disabledCPU)
        #expect(configuration.enabledStats == [.memoryUsed])
        let refusedOnlyMemoryDisable = configuration.setStat(.memoryUsed, enabled: false)
        #expect(!refusedOnlyMemoryDisable)
    }

    @Test("Stats append in order and stop at five")
    func enablesStatsInOrder() {
        var configuration = MenuBarConfiguration()

        let enabledCPUSystem = configuration.setStat(.cpuSystem, enabled: true)
        let enabledMemory = configuration.setStat(.memoryUsed, enabled: true)
        let enabledStorage = configuration.setStat(.storageFree, enabled: true)
        let enabledCached = configuration.setStat(.memoryCached, enabled: true)
        let refusedSixth = configuration.setStat(.storageTotal, enabled: true)
        let refusedDuplicate = configuration.setStat(.memoryUsed, enabled: true)

        #expect(enabledCPUSystem)
        #expect(enabledMemory)
        #expect(enabledStorage)
        #expect(enabledCached)
        #expect(!refusedSixth)
        #expect(!refusedDuplicate)
        #expect(configuration.enabledStats == [
            .cpuUser,
            .cpuSystem,
            .memoryUsed,
            .storageFree,
            .memoryCached,
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
            enabledStats: [.cpuUser, .storageUsed],
            displayMode: .valueOnly
        )
        #expect(normalized.displayMode == .compact)
    }

    @Test("Reordering moves one adjacent position and respects boundaries")
    func reordersStats() {
        var configuration = MenuBarConfiguration(
            enabledStats: [.cpuUser, .memoryUsed, .storageFree]
        )

        let movedCPUDown = configuration.moveStatDown(.cpuUser)
        #expect(movedCPUDown)
        #expect(configuration.enabledStats == [.memoryUsed, .cpuUser, .storageFree])
        let movedStorageUp = configuration.moveStatUp(.storageFree)
        #expect(movedStorageUp)
        #expect(configuration.enabledStats == [.memoryUsed, .storageFree, .cpuUser])
        let movedFirstUp = configuration.moveStatUp(.memoryUsed)
        let movedLastDown = configuration.moveStatDown(.cpuUser)
        let movedLastByDirection = configuration.moveStat(.cpuUser, direction: .down)

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
        #expect(configuration.enabledStats == [.cpuUser])
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
            .storageFree,
            .cpuSystem,
            .memoryUsed,
        ])
        #expect(configuration.displayMode == .compact)
    }

    @Test("Former concrete stats migrate without resetting the whole configuration")
    func migratesFormerConcreteStats() throws {
        let data = try #require(
            """
            {
              "enabledStats": [
                "cpuTotal",
                "memoryAvailable",
                "storagePercentage",
                "memorySwap"
              ],
              "displayMode": "iconAndValue"
            }
            """.data(using: .utf8)
        )

        let configuration = try JSONDecoder().decode(MenuBarConfiguration.self, from: data)
        #expect(configuration.enabledStats == [
            .cpuUser,
            .memoryCached,
            .storageUsed,
            .memorySwap,
        ])
        #expect(configuration.displayMode == .labelAndValue)
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
