import SwiftUI

struct CPUSectionView: View {
    @Environment(\.locale) private var locale

    let usage: CPUUsage?
    let history: [CPUUsage]
    let sampleState: MetricSampleState

    var body: some View {
        MetricSectionView(
            title: "CPU",
            systemImage: "cpu",
            primaryLabel: "Total used",
            primaryValue: formattedPercentage(usage?.total)
        ) {
            MetricAvailabilityView(metricName: "CPU", state: sampleState)

            MetricHistoryChart(
                metricName: "CPU usage",
                samples: history,
                value: \CPUUsage.total
            )

            MetricRowView(
                label: "User",
                value: formattedPercentage(usage?.user)
            )

            MetricRowView(
                label: "System",
                value: formattedPercentage(usage?.system)
            )

            MetricRowView(
                label: "Idle",
                value: formattedPercentage(usage?.idle)
            )
        }
    }

    private func formattedPercentage(_ value: Double?) -> String {
        guard let value else {
            return MetricFormatting.unavailable
        }

        return MetricFormatting.percentage(value, locale: locale)
    }
}
