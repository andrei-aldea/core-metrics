import SwiftUI

/// Keeps Settings in a native SwiftUI scene within the AppKit lifecycle.
struct CoreMetricsSettingsScene: Scene {
    let metricsStore: MetricsStore
    let preferencesStore: PreferencesStore
    let launchAtLoginStore: LaunchAtLoginStore
    let dismissPanel: @MainActor () -> Void

    var body: some Scene {
        Settings {
            SettingsView()
                .environment(metricsStore)
                .environment(preferencesStore)
                .environment(launchAtLoginStore)
                .tint(Color.primary)
        }
        .windowResizability(.contentSize)
        .commands {
            SettingsCommands(dismissPanel: dismissPanel)
        }
    }
}
