import SwiftUI

@main
struct CoreMetricsApp: App {
    @State private var metricsStore = MetricsStore()
    @State private var preferencesStore = PreferencesStore()

    var body: some Scene {
        MenuBarExtra {
            DashboardView()
                .environment(metricsStore)
                .environment(preferencesStore)
                .tint(Color.primary)
        } label: {
            MenuBarLabelView()
                .environment(metricsStore)
                .environment(preferencesStore)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environment(metricsStore)
                .environment(preferencesStore)
                .tint(Color.primary)
        }
        .windowResizability(.contentSize)
    }
}
