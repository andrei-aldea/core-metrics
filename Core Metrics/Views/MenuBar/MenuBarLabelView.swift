import SwiftUI

struct MenuBarLabelView: View {
    @Environment(\.locale) private var locale
    @Environment(MetricsStore.self) private var metricsStore
    @Environment(PreferencesStore.self) private var preferencesStore

    var body: some View {
        HStack(spacing: 6) {
            ForEach(preferencesStore.enabledMetrics) { metric in
                MenuBarMetricLabelView(
                    metric: metric,
                    displayMode: preferencesStore.displayMode,
                    value: value(for: metric)
                )
            }
        }
        .monospacedDigit()
        .lineLimit(1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Core Metrics")
        .accessibilityValue(accessibilitySummary)
        .task {
            metricsStore.start()
        }
    }

    private var accessibilitySummary: String {
        preferencesStore.enabledMetrics
            .map(accessibilityDescription(for:))
            .joined(separator: ", ")
    }

    private func value(for metric: MetricKind) -> String {
        switch metric {
        case .cpu:
            MenuValueFormatting.cpu(metricsStore.cpuUsage, locale: locale)
        case .memory:
            MenuValueFormatting.memory(
                metricsStore.memoryUsage,
                style: preferencesStore.memoryValueStyle,
                locale: locale
            )
        case .storage:
            MenuValueFormatting.storage(
                metricsStore.storageUsage,
                style: preferencesStore.storageValueStyle,
                locale: locale
            )
        }
    }

    private func accessibilityDescription(for metric: MetricKind) -> String {
        switch metric {
        case .cpu:
            guard let usage = metricsStore.cpuUsage else {
                return "CPU unavailable"
            }

            return "CPU \(MetricFormatting.percentage(usage.total, locale: locale)) used"
        case .memory:
            guard let usage = metricsStore.memoryUsage else {
                return "Memory unavailable"
            }

            switch preferencesStore.memoryValueStyle {
            case .percentage:
                return "Memory \(MetricFormatting.percentage(usage.usedFraction, locale: locale)) used"
            case .used:
                return "Memory \(MetricFormatting.bytes(usage.usedBytes, style: .memory, locale: locale)) used"
            }
        case .storage:
            guard let usage = metricsStore.storageUsage else {
                return "Storage unavailable"
            }

            switch preferencesStore.storageValueStyle {
            case .percentage:
                return "Storage \(MetricFormatting.percentage(usage.usedFraction, locale: locale)) used"
            case .available:
                return "Storage \(MetricFormatting.bytes(usage.availableBytes, style: .storage, locale: locale)) available"
            }
        }
    }
}
