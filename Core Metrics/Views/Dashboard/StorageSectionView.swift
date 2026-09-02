import SwiftUI

struct StorageSectionView: View {
    @Environment(\.locale) private var locale

    let usage: StorageUsage?
    let sampleState: MetricSampleState

    var body: some View {
        MetricSectionView(
            title: "Storage",
            systemImage: "internaldrive",
            primaryLabel: "Startup disk used",
            primaryValue: formattedPercentage(usage?.usedFraction)
        ) {
            MetricAvailabilityView(metricName: "Storage", state: sampleState)

            if let usage {
                ProgressView(value: usage.usedFraction)
                    .progressViewStyle(.linear)
                    .tint(Color.primary)
                    .accessibilityLabel(Text("Startup disk used"))
                    .accessibilityValue(Text(accessiblePercentage))
            }

            MetricRowView(
                label: "Used",
                value: formattedBytes(usage?.usedBytes)
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

    private var accessiblePercentage: String {
        guard let usage else {
            return "Unavailable"
        }

        return MetricFormatting.percentage(usage.usedFraction, locale: locale)
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

        return MetricFormatting.bytes(value, style: .storage, locale: locale)
    }
}
