import SwiftUI

@main
struct CoreMetricsApp: App {
    @State private var metricsStore = MetricsStore()
    @State private var preferencesStore: PreferencesStore
    @State private var launchAtLoginStore: LaunchAtLoginStore

    init() {
        #if DEBUG
        if let testPreferences = UITestLaunchConfiguration.configureIfRequested() {
            _preferencesStore = State(initialValue: testPreferences)
            _launchAtLoginStore = State(initialValue: LaunchAtLoginStore(service: UITestLaunchAtLoginService()))
            return
        }
        #endif
        _preferencesStore = State(initialValue: PreferencesStore())
        _launchAtLoginStore = State(initialValue: LaunchAtLoginStore())
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
                .environment(launchAtLoginStore)
                .tint(Color.primary)
        }
        .windowResizability(.contentMinSize)
    }
}
