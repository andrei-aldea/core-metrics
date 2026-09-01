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
        } label: {
            MenuBarLabelView()
                .environment(metricsStore)
                .environment(preferencesStore)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environment(preferencesStore)
        }
        .windowResizability(.contentSize)
    }
}
