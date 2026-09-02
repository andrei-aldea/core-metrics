import SwiftUI

/// One live native-menu row that observes only the metric category it needs.
struct MenuBarSelectedStatItemView: View {
    @Environment(\.locale) private var locale
    @Environment(MetricsStore.self) private var metricsStore

    let stat: MenuBarStat
    let action: () -> Void

    var body: some View {
        let value = formattedValue

        Button(action: action) {
            Text("\(stat.dashboardName) — \(value)")
        }
        .accessibilityLabel(accessibilityLabel(for: value))
        .accessibilityInputLabels([stat.dashboardName, stat.displayName])
        .accessibilityHint("Opens the detailed dashboard.")
    }

    private var formattedValue: String {
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

    private func accessibilityLabel(for value: String) -> String {
        let accessibleValue = value == MetricFormatting.unavailable
            ? "Unavailable"
            : value
        return "\(stat.displayName), \(accessibleValue)"
    }
}
