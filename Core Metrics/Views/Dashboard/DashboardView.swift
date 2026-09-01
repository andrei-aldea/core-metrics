import SwiftUI

struct DashboardView: View {
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
                        history: metricsStore.cpuHistory
                    )

                    Divider()

                    MemorySectionView(
                        usage: metricsStore.memoryUsage,
                        history: metricsStore.memoryHistory
                    )

                    Divider()

                    StorageSectionView(usage: metricsStore.storageUsage)
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
        .frame(width: DashboardLayout.panelWidth)
    }
}
