import SwiftUI

@main
struct CoreMetricsApp: App {
    @State private var metricsStore = MetricsStore()
    @State private var preferencesStore: PreferencesStore

    init() {
        #if DEBUG
        if let testPreferences = UITestLaunchConfiguration.configureIfRequested() {
            _preferencesStore = State(initialValue: testPreferences)
            return
        }
        #endif
        _preferencesStore = State(initialValue: PreferencesStore())
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarMenuView()
                .environment(metricsStore)
                .environment(preferencesStore)
                .tint(Color.primary)
        } label: {
            MenuBarLabelView(isStatusItem: true)
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
        .windowResizability(.contentMinSize)
    }
}
