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
        #expect(MetricKind.allCases.map(\.systemImage) == ["cpu", "memorychip", "internaldrive"])
    }

    @Test("Menu-bar stats have stable persistence values and categories")
    func menuBarStatMetadata() {
        #expect(MenuBarConfiguration.maximumEnabledStatCount == 7)
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
    }

    @Test("Display modes have stable persistence values")
    func displayModeRawValues() {
        #expect(MenuBarDisplayMode.allCases.map(\.rawValue) == [
            "iconAndValue",
            "valueOnly",
            "compact",
        ])
    }

    @Test("Initialization repairs empty, duplicate, and oversized lists", arguments: [
        ([MenuBarStat](), [MenuBarStat.cpuUser]),
        ([.memoryUsed, .cpuUser, .memoryUsed], [.cpuUser, .memoryUsed]),
        (
            Array(MenuBarStat.allCases.reversed()),
            [.cpuUser, .cpuSystem, .cpuIdle, .memoryUsed, .memoryCached, .memorySwap, .storageUsed]
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
        #expect(!configuration.canEnable(.cpuUser))
        #expect(configuration.canEnable(.memoryUsed))
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

    @Test("Stats follow widget order and stop at seven")
    func enablesStatsInWidgetOrder() {
        var configuration = MenuBarConfiguration()

        let enabledStorageTotal = configuration.setStat(.storageTotal, enabled: true)
        let enabledSwap = configuration.setStat(.memorySwap, enabled: true)
        let enabledCPUIdle = configuration.setStat(.cpuIdle, enabled: true)
        let enabledMemory = configuration.setStat(.memoryUsed, enabled: true)
        let enabledStorageFree = configuration.setStat(.storageFree, enabled: true)
        let enabledCPUSystem = configuration.setStat(.cpuSystem, enabled: true)
        let refusedEighth = configuration.setStat(.storageUsed, enabled: true)
        let refusedDuplicate = configuration.setStat(.memoryUsed, enabled: true)

        #expect(enabledStorageTotal)
        #expect(enabledSwap)
        #expect(enabledCPUIdle)
        #expect(enabledMemory)
        #expect(enabledStorageFree)
        #expect(enabledCPUSystem)
        #expect(!refusedEighth)
        #expect(!refusedDuplicate)
        #expect(!configuration.canEnable(.storageUsed))
        #expect(configuration.availableStats.isEmpty)
        #expect(configuration.enabledStats == [
            .cpuUser,
            .cpuSystem,
            .cpuIdle,
            .memoryUsed,
            .memorySwap,
            .storageFree,
            .storageTotal,
        ])
    }

    @Test("Value-only mode remains exclusive to one stat")
    func restrictsValueOnlyMode() {
        var configuration = MenuBarConfiguration(displayMode: .valueOnly)
        #expect(configuration.displayMode == .valueOnly)
        #expect(configuration.availableDisplayModes == MenuBarDisplayMode.allCases)

        let enabledMemory = configuration.setStat(.memoryUsed, enabled: true)
        #expect(enabledMemory)
        #expect(configuration.displayMode == .compact)
        #expect(configuration.availableDisplayModes == [.labelAndValue, .compact])

        configuration.displayMode = .valueOnly
        #expect(configuration.displayMode == .compact)

        let normalized = MenuBarConfiguration(
            enabledStats: [.cpuUser, .storageUsed],
            displayMode: .valueOnly
        )
        #expect(normalized.displayMode == .compact)
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
            .cpuSystem,
            .memoryUsed,
            .storageFree,
        ])
        #expect(configuration.displayMode == .compact)
    }

    @Test("Every version 1 CPU style remains decodable", arguments: [
        ("total", MenuBarStat.cpuUser),
        ("user", .cpuUser),
        ("system", .cpuSystem),
        ("idle", .cpuIdle),
    ])
    func migratesEveryVersionOneCPUStyle(
        rawValue: String,
        expected: MenuBarStat
    ) throws {
        let configuration = try decodeVersionOneStyle(
            metric: "cpu",
            key: "cpuValueStyle",
            rawValue: rawValue
        )
        #expect(configuration.enabledStats == [expected])
    }

    @Test("Every version 1 memory style remains decodable", arguments: [
        ("percentage", MenuBarStat.memoryUsed),
        ("used", .memoryUsed),
        ("available", .memoryCached),
        ("appEstimate", .memoryUsed),
        ("wired", .memoryUsed),
        ("compressed", .memoryUsed),
        ("total", .memoryUsed),
    ])
    func migratesEveryVersionOneMemoryStyle(
        rawValue: String,
        expected: MenuBarStat
    ) throws {
        let configuration = try decodeVersionOneStyle(
            metric: "memory",
            key: "memoryValueStyle",
            rawValue: rawValue
        )
        #expect(configuration.enabledStats == [expected])
    }

    @Test("Every version 1 storage style remains decodable", arguments: [
        ("percentage", MenuBarStat.storageUsed),
        ("used", .storageUsed),
        ("available", .storageFree),
        ("total", .storageTotal),
    ])
    func migratesEveryVersionOneStorageStyle(
        rawValue: String,
        expected: MenuBarStat
    ) throws {
        let configuration = try decodeVersionOneStyle(
            metric: "storage",
            key: "storageValueStyle",
            rawValue: rawValue
        )
        #expect(configuration.enabledStats == [expected])
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
            .memorySwap,
            .storageUsed,
        ])
        #expect(configuration.displayMode == .labelAndValue)
    }

    private func decodeVersionOneStyle(
        metric: String,
        key: String,
        rawValue: String
    ) throws -> MenuBarConfiguration {
        let data = try #require(
            """
            {
              "enabledMetrics": ["\(metric)"],
              "\(key)": "\(rawValue)"
            }
            """.data(using: .utf8)
        )
        return try JSONDecoder().decode(MenuBarConfiguration.self, from: data)
    }
}
