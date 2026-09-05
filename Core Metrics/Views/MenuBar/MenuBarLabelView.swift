import SwiftUI

struct MenuBarLabelView: View {
    var isStatusItem = false
    @Environment(\.locale) private var locale
    @Environment(MetricsStore.self) private var metricsStore
    @Environment(PreferencesStore.self) private var preferencesStore
    @State private var layout = MenuBarLabelLayout(locale: .current)

    var body: some View {
        let stats = preferencesStore.enabledStats
        let values = stats.map(value(for:))
        let statusText = MenuBarLabelFormatting.text(
            stats: stats,
            values: values,
            displayMode: preferencesStore.displayMode
        )
        let reservedWidth = layout.width(
            stats: stats,
            displayMode: preferencesStore.displayMode
        )
        let spokenSummary = accessibilitySummary(stats: stats, values: values)

        Group {
            if isStatusItem {
                MenuBarStatusLabel(
                    text: statusText,
                    width: reservedWidth,
                    spokenSummary: spokenSummary
                )
            } else {
                Text(attributedStatusText(statusText))
                    .lineLimit(1)
                    .frame(width: reservedWidth, alignment: .leading)
                    .help(spokenSummary)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Core Metrics")
                    .accessibilityValue(spokenSummary)
            }
        }
            .onChange(of: locale, initial: true) { _, locale in
                layout = MenuBarLabelLayout(locale: locale)
            }
            .task {
                metricsStore.start()
            }
    }

    private func attributedStatusText(_ text: String) -> AttributedString {
        var content = AttributedString(text)
        content.font = Font(MenuBarLabelLayout.font)
        return content
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
                    ? String(localized: "Unavailable")
                    : value
                return "\(stat.displayName), \(accessibleValue)"
            }
            .joined(separator: ", ")
    }
}
