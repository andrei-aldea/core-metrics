import SwiftUI

struct CPUSectionView: View {
    @Environment(\.locale) private var locale

    let usage: CPUUsage?
    let sampleState: MetricSampleState

    var body: some View {
        Section("CPU") {
            MetricAvailabilityView(metricName: "CPU", state: sampleState)

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
