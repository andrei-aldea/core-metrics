import AppKit

/// AppKit owns the menu-bar item; the app's Settings remain a SwiftUI scene.
@main
@MainActor
enum CoreMetricsApp {
    static func main() {
        let application = NSApplication.shared
        let delegate = CoreMetricsAppDelegate()
        application.delegate = delegate
        withExtendedLifetime(delegate) {
            application.run()
        }
    }
}
