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

    @Test("Display modes have stable persistence values")
    func displayModeRawValues() {
        #expect(MenuBarDisplayMode.allCases.map(\.rawValue) == [
            "iconAndValue",
            "valueOnly",
            "compact",
        ])
    }

    @Test("Initialization repairs empty, duplicate, and oversized lists", arguments: [
        ([MetricKind](), [MetricKind.cpu]),
        ([.memory, .cpu, .memory], [.memory, .cpu]),
        ([.storage, .memory, .cpu, .storage], [.storage, .memory, .cpu]),
    ])
    func normalizesEnabledMetrics(input: [MetricKind], expected: [MetricKind]) {
        let configuration = MenuBarConfiguration(enabledMetrics: input)
        #expect(configuration.enabledMetrics == expected)
    }

    @Test("At least one metric must remain enabled")
    func preservesMinimumEnabledMetric() {
        var configuration = MenuBarConfiguration()

        #expect(!configuration.canDisable(.cpu))
        let refusedLastDisable = configuration.setMetric(.cpu, enabled: false)
        #expect(!refusedLastDisable)
        #expect(configuration.enabledMetrics == [.cpu])

        let enabledMemory = configuration.setMetric(.memory, enabled: true)
        #expect(enabledMemory)
        #expect(configuration.canDisable(.cpu))
        let disabledCPU = configuration.setMetric(.cpu, enabled: false)
        #expect(disabledCPU)
        #expect(configuration.enabledMetrics == [.memory])
        let refusedOnlyMemoryDisable = configuration.setMetric(.memory, enabled: false)
        #expect(!refusedOnlyMemoryDisable)
    }

    @Test("Enabling appends and duplicate requests are no-ops")
    func enablesMetricsInOrder() {
        var configuration = MenuBarConfiguration()

        let enabledStorage = configuration.setMetric(.storage, enabled: true)
        let enabledMemory = configuration.setMetric(.memory, enabled: true)
        let duplicateStorage = configuration.setMetric(.storage, enabled: true)

        #expect(enabledStorage)
        #expect(enabledMemory)
        #expect(!duplicateStorage)
        #expect(configuration.enabledMetrics == [.cpu, .storage, .memory])
    }

    @Test("Value-only mode remains exclusive to one metric")
    func restrictsValueOnlyMode() {
        var configuration = MenuBarConfiguration(displayMode: .valueOnly)
        #expect(configuration.displayMode == .valueOnly)

        let enabledMemory = configuration.setMetric(.memory, enabled: true)
        #expect(enabledMemory)
        #expect(configuration.displayMode == .compact)

        configuration.displayMode = .valueOnly
        #expect(configuration.displayMode == .compact)

        let normalized = MenuBarConfiguration(
            enabledMetrics: [.cpu, .storage],
            displayMode: .valueOnly
        )
        #expect(normalized.displayMode == .compact)
    }

    @Test("Reordering moves one adjacent position and respects boundaries")
    func reordersMetrics() {
        var configuration = MenuBarConfiguration(enabledMetrics: [.cpu, .memory, .storage])

        let movedCPUDown = configuration.moveMetricDown(.cpu)
        #expect(movedCPUDown)
        #expect(configuration.enabledMetrics == [.memory, .cpu, .storage])
        let movedStorageUp = configuration.moveMetricUp(.storage)
        #expect(movedStorageUp)
        #expect(configuration.enabledMetrics == [.memory, .storage, .cpu])
        let movedFirstUp = configuration.moveMetricUp(.memory)
        let movedLastDown = configuration.moveMetricDown(.cpu)
        let movedLastByDirection = configuration.moveMetric(.cpu, direction: .down)

        #expect(!movedFirstUp)
        #expect(!movedLastDown)
        #expect(!movedLastByDirection)
    }

    @Test("Decoding repairs an empty enabled list")
    func decodingRepairsInvariant() throws {
        let data = try #require(
            """
            {
              "enabledMetrics": [],
              "displayMode": "compact",
              "memoryValueStyle": "used",
              "storageValueStyle": "available"
            }
            """.data(using: .utf8)
        )

        let configuration = try JSONDecoder().decode(MenuBarConfiguration.self, from: data)
        #expect(configuration.enabledMetrics == [.cpu])
        #expect(configuration.displayMode == .compact)
        #expect(configuration.memoryValueStyle == .used)
        #expect(configuration.storageValueStyle == .available)
    }

    @Test("Reset restores every default")
    func resetsConfiguration() {
        var configuration = MenuBarConfiguration(
            enabledMetrics: [.storage, .memory],
            displayMode: .compact,
            memoryValueStyle: .used,
            storageValueStyle: .available
        )

        configuration.reset()
        #expect(configuration == .defaultValue)
    }
}
