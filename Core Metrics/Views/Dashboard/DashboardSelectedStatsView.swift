import SwiftUI

/// A flat summary of the same ordered stats configured for the menu bar.
/// The standard window surface provides the visual layer around this content.
struct DashboardSelectedStatsView: View {
    @Environment(\.locale) private var locale

    let stats: [MenuBarStat]
    let cpuUsage: CPUUsage?
    let memoryUsage: MemoryUsage?
    let storageUsage: StorageUsage?

    var body: some View {
        let values = stats.map(value(for:))

        VStack(alignment: .leading, spacing: 8) {
            Text("Menu Bar Stats")
                .font(.subheadline)
                .bold()
                .foregroundStyle(.secondary)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: 6) {
                ForEach(stats.enumerated(), id: \.element) { index, stat in
                    LabeledContent(stat.dashboardName) {
                        Text(values[index])
                            .monospacedDigit()
                            .frame(width: 72, alignment: .trailing)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(stat.displayName)
                    .accessibilityValue(accessibilityValue(values[index]))
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, DashboardLayout.sectionVerticalPadding)
    }

    private func value(for stat: MenuBarStat) -> String {
        MenuValueFormatting.value(
            for: stat,
            cpuUsage: cpuUsage,
            memoryUsage: memoryUsage,
            storageUsage: storageUsage,
            locale: locale
        )
    }

    private func accessibilityValue(_ formattedValue: String) -> String {
        formattedValue == MetricFormatting.unavailable
            ? "Unavailable"
            : formattedValue
    }
}
