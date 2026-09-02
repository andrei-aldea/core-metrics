import SwiftUI

struct DashboardView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(MetricsStore.self) private var metricsStore
    @Environment(PreferencesStore.self) private var preferencesStore

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                DashboardSelectedStatsView(
                    stats: preferencesStore.enabledStats,
                    cpuUsage: metricsStore.cpuUsage,
                    memoryUsage: metricsStore.memoryUsage,
                    storageUsage: metricsStore.storageUsage
                )

                Divider()
                    .padding(.horizontal)

                CPUSectionView(
                    usage: metricsStore.cpuUsage,
                    history: metricsStore.cpuHistory,
                    sampleState: metricsStore.cpuSampleState
                )

                Divider()
                    .padding(.horizontal)

                MemorySectionView(
                    usage: metricsStore.memoryUsage,
                    history: metricsStore.memoryHistory,
                    sampleState: metricsStore.memorySampleState
                )

                Divider()
                    .padding(.horizontal)

                StorageSectionView(
                    usage: metricsStore.storageUsage,
                    sampleState: metricsStore.storageSampleState
                )
            }
        }
        .frame(
            minHeight: DashboardLayout.contentMinimumHeight,
            idealHeight: DashboardLayout.contentIdealHeight,
            maxHeight: DashboardLayout.contentMaximumHeight
        )
        .frame(width: panelWidth)
    }

    private var panelWidth: Double {
        dynamicTypeSize.isAccessibilitySize
            ? DashboardLayout.accessiblePanelWidth
            : DashboardLayout.panelWidth
    }
}
