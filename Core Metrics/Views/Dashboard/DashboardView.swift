import SwiftUI

struct DashboardView: View {
    @Environment(MetricsStore.self) private var metricsStore

    var body: some View {
        Form {
            CPUSectionView(
                usage: metricsStore.cpuUsage,
                sampleState: metricsStore.cpuSampleState
            )

            MemorySectionView(
                usage: metricsStore.memoryUsage,
                sampleState: metricsStore.memorySampleState
            )

            StorageSectionView(
                usage: metricsStore.storageUsage,
                sampleState: metricsStore.storageSampleState
            )
        }
        .formStyle(.grouped)
        .frame(
            minWidth: DashboardLayout.minimumWindowWidth,
            idealWidth: DashboardLayout.idealWindowWidth,
            minHeight: DashboardLayout.minimumWindowHeight,
            idealHeight: DashboardLayout.idealWindowHeight
        )
    }
}
