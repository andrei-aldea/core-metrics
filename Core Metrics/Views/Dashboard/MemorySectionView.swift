import SwiftUI

struct MemorySectionView: View {
    @Environment(\.locale) private var locale

    let usage: MemoryUsage?
    let sampleState: MetricSampleState

    var body: some View {
        Section("Memory") {
            MetricAvailabilityView(metricName: "Memory", state: sampleState)

            MetricRowView(
                label: "Memory Used",
                value: formattedBytes(usage?.usedBytes)
            )

            MetricRowView(
                label: "Cached Files",
                value: formattedBytes(usage?.cachedBytes)
            )

            MetricRowView(
                label: "Swap Used",
                value: formattedBytes(usage?.swapUsedBytes)
            )
        }
    }

    private func formattedBytes(_ value: UInt64?) -> String {
        guard let value else {
            return MetricFormatting.unavailable
        }

        return MetricFormatting.bytes(value, style: .memory, locale: locale)
    }
}
