import SwiftUI

struct DashboardView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(MetricsStore.self) private var metricsStore

    var body: some View {
        VStack(spacing: 0) {
            DashboardHeaderView(
                isSampling: metricsStore.isSampling,
                hasSamplingIssue: metricsStore.hasSamplingIssue
            )
                .padding(.horizontal)
                .padding(.vertical, DashboardLayout.chromeVerticalPadding)

            Divider()

            ScrollView {
                VStack(spacing: 0) {
                    CPUSectionView(
                        usage: metricsStore.cpuUsage,
                        history: metricsStore.cpuHistory,
                        sampleState: metricsStore.cpuSampleState
                    )

                    Divider()

                    MemorySectionView(
                        usage: metricsStore.memoryUsage,
                        history: metricsStore.memoryHistory,
                        sampleState: metricsStore.memorySampleState
                    )

                    Divider()

                    StorageSectionView(
                        usage: metricsStore.storageUsage,
                        sampleState: metricsStore.storageSampleState
                    )
                }
            }
            .frame(
                idealHeight: DashboardLayout.contentIdealHeight,
                maxHeight: DashboardLayout.contentMaximumHeight
            )

            Divider()

            DashboardFooterView()
                .padding(.horizontal)
                .padding(.vertical, DashboardLayout.chromeVerticalPadding)
        }
        .frame(width: panelWidth)
    }

    private var panelWidth: Double {
        dynamicTypeSize.isAccessibilitySize
            ? DashboardLayout.accessiblePanelWidth
            : DashboardLayout.panelWidth
    }
}
