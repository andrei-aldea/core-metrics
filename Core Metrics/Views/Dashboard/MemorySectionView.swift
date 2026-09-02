import SwiftUI

struct MemorySectionView: View {
    @Environment(\.locale) private var locale

    let usage: MemoryUsage?
    let history: [MemoryUsage]
    let sampleState: MetricSampleState

    var body: some View {
        MetricSectionView(
            title: "Memory",
            systemImage: "memorychip",
            primaryLabel: "Used",
            primaryValue: formattedPercentage(usage?.usedFraction)
        ) {
            MetricAvailabilityView(metricName: "Memory", state: sampleState)

            MetricHistoryChart(
                metricName: "Memory usage",
                samples: history,
                value: \MemoryUsage.usedFraction
            )

            MetricRowView(
                label: "Used",
                value: formattedBytes(usage?.usedBytes)
            )

            MetricRowView(
                label: "App Estimate",
                value: formattedBytes(usage?.appEstimateBytes)
            )

            MetricRowView(
                label: "Wired",
                value: formattedBytes(usage?.wiredBytes)
            )

            MetricRowView(
                label: "Compressed",
                value: formattedBytes(usage?.compressedBytes)
            )

            MetricRowView(
                label: "Available",
                value: formattedBytes(usage?.availableBytes)
            )

            MetricRowView(
                label: "Total",
                value: formattedBytes(usage?.totalBytes)
            )
        }
    }

    private func formattedPercentage(_ value: Double?) -> String {
        guard let value else {
            return MetricFormatting.unavailable
        }

        return MetricFormatting.percentage(value, locale: locale)
    }

    private func formattedBytes(_ value: UInt64?) -> String {
        guard let value else {
            return MetricFormatting.unavailable
        }

        return MetricFormatting.bytes(value, style: .memory, locale: locale)
    }
}
