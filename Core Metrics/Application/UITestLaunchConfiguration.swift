#if DEBUG
import AppKit
import Foundation

/// Explicit XCTest launch configuration, compiled out of Release. Normal
/// development launches continue to use the person's own preferences/appearance.
@MainActor
enum UITestLaunchConfiguration {
    static func configureIfRequested() -> PreferencesStore? {
        let environment = ProcessInfo.processInfo.environment
        guard environment["CORE_METRICS_UI_TESTING"] == "1" else {
            return nil
        }

        let suiteName = "org.example.CoreMetrics.UITests"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            preconditionFailure("Unable to create isolated UI-test preferences")
        }
        let isRelaunch = environment["CORE_METRICS_UI_RELAUNCH"] == "1"
        if !isRelaunch {
            defaults.removePersistentDomain(forName: suiteName)
        }
        let preferences = PreferencesStore(defaults: defaults)
        if !isRelaunch {
            preferences.displayMode = .valueOnly
        }

        if environment["CORE_METRICS_UI_APPEARANCE"] == "light" {
            NSApplication.shared.appearance = NSAppearance(named: .aqua)
        } else if environment["CORE_METRICS_UI_APPEARANCE"] == "dark" {
            NSApplication.shared.appearance = NSAppearance(named: .darkAqua)
        }
        return preferences
    }
}
#endif
