import SwiftUI

struct StorageSectionView: View {
    @Environment(\.locale) private var locale

    let usage: StorageUsage?
    let sampleState: MetricSampleState

    var body: some View {
        Section("Startup Disk") {
            MetricAvailabilityView(metricName: "Storage", state: sampleState)

            MetricRowView(
                label: "Free Space",
                value: formattedBytes(usage?.availableBytes)
            )

            MetricRowView(
                label: "Used Space",
                value: formattedBytes(usage?.usedBytes)
            )

            MetricRowView(
                label: "Total Capacity",
                value: formattedBytes(usage?.totalBytes)
            )
        }
    }

    private func formattedBytes(_ value: UInt64?) -> String {
        guard let value else {
            return MetricFormatting.unavailable
        }

        return MetricFormatting.bytes(value, style: .storage, locale: locale)
    }
}
