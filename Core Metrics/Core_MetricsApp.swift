import SwiftUI

@main
struct CoreMetricsApp: App {
    @State private var metricsStore = MetricsStore()
    @State private var preferencesStore: PreferencesStore
    @State private var launchAtLoginStore: LaunchAtLoginStore
    private let writeToClipboard: @MainActor (String) -> Bool

    init() {
        #if DEBUG
        if let testPreferences = UITestLaunchConfiguration.configureIfRequested() {
            _preferencesStore = State(initialValue: testPreferences)
            _launchAtLoginStore = State(initialValue: LaunchAtLoginStore(service: UITestLaunchAtLoginService()))
            let shouldFailCopy = ProcessInfo.processInfo.environment["CORE_METRICS_UI_COPY_FAILURE"] == "1"
            writeToClipboard = { _ in !shouldFailCopy }
            return
        }
        #endif
        _preferencesStore = State(initialValue: PreferencesStore())
        _launchAtLoginStore = State(initialValue: LaunchAtLoginStore())
        writeToClipboard = { CurrentReadingsPasteboard.write($0, to: .general) }
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarMenuView(writeToClipboard: writeToClipboard)
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
                .environment(launchAtLoginStore)
                .tint(Color.primary)
        }
        .windowResizability(.contentMinSize)
    }
}
