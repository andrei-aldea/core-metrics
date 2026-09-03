import AppKit
import SwiftUI

struct MenuBarLabelView: View {
    private static let statusFont = NSFont.monospacedSystemFont(
        ofSize: NSFont.systemFontSize,
        weight: .regular
    )
    private static let characterAdvance = ("0" as NSString).size(
        withAttributes: [.font: statusFont]
    ).width

    @Environment(\.locale) private var locale
    @Environment(MetricsStore.self) private var metricsStore
    @Environment(PreferencesStore.self) private var preferencesStore

    var body: some View {
        let stats = preferencesStore.enabledStats
        let values = stats.map(value(for:))
        let statusText = MenuBarLabelFormatting.text(
            stats: stats,
            values: values,
            displayMode: preferencesStore.displayMode
        )
        let reservedWidth = statusWidth(
            stats: stats,
            displayMode: preferencesStore.displayMode
        )
        let spokenSummary = accessibilitySummary(stats: stats, values: values)

        Text(verbatim: statusText)
            .font(Font(Self.statusFont))
            .lineLimit(1)
            .frame(width: reservedWidth, alignment: .leading)
            .help(spokenSummary)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Core Metrics")
            .accessibilityValue(spokenSummary)
            .task {
                metricsStore.start()
            }
    }

    private func statusWidth(
        stats: [MenuBarStat],
        displayMode: MenuBarDisplayMode
    ) -> CGFloat {
        let characterCount = MenuBarLabelFormatting.reservedCharacterCount(
            stats: stats,
            displayMode: displayMode
        )
        return ceil(Self.characterAdvance * CGFloat(characterCount)) + 1
    }

    private func value(for stat: MenuBarStat) -> String {
        switch stat.metric {
        case .cpu:
            MenuValueFormatting.value(
                for: stat,
                cpuUsage: metricsStore.cpuUsage,
                memoryUsage: nil,
                storageUsage: nil,
                locale: locale
            )
        case .memory:
            MenuValueFormatting.value(
                for: stat,
                cpuUsage: nil,
                memoryUsage: metricsStore.memoryUsage,
                storageUsage: nil,
                locale: locale
            )
        case .storage:
            MenuValueFormatting.value(
                for: stat,
                cpuUsage: nil,
                memoryUsage: nil,
                storageUsage: metricsStore.storageUsage,
                locale: locale
            )
        }
    }

    private func accessibilitySummary(
        stats: [MenuBarStat],
        values: [String]
    ) -> String {
        zip(stats, values)
            .map { stat, value in
                let accessibleValue = value == MetricFormatting.unavailable
                    ? "Unavailable"
                    : value
                return "\(stat.displayName), \(accessibleValue)"
            }
            .joined(separator: ", ")
    }
}
