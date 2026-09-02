import SwiftUI

@main
struct CoreMetricsApp: App {
    @State private var metricsStore = MetricsStore()
    @State private var preferencesStore = PreferencesStore()

    var body: some Scene {
        MenuBarExtra {
            MenuBarMenuView()
                .environment(metricsStore)
                .environment(preferencesStore)
                .tint(Color.primary)
        } label: {
            MenuBarLabelView()
                .environment(metricsStore)
                .environment(preferencesStore)
        }
        .menuBarExtraStyle(.menu)

        Window("Core Metrics", id: DashboardLayout.windowIdentifier) {
            DashboardView()
                .environment(metricsStore)
                .environment(preferencesStore)
                .tint(Color.primary)
        }
        .defaultLaunchBehavior(.suppressed)
        .windowResizability(.contentSize)

        Settings {
            SettingsView()
                .environment(metricsStore)
                .environment(preferencesStore)
                .tint(Color.primary)
        }
        .windowResizability(.contentSize)
    }
}
