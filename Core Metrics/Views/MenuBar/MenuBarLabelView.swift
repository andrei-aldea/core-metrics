import SwiftUI

struct MenuBarLabelView: View {
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

        Text(verbatim: statusText)
            .fontDesign(.monospaced)
            .lineLimit(1)
            .fixedSize()
            .help(accessibilitySummary(stats: stats, values: values))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Core Metrics")
            .accessibilityValue(accessibilitySummary(stats: stats, values: values))
            .task {
                metricsStore.start()
            }
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
