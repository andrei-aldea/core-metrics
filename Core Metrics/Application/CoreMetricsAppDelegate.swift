import AppKit
import SwiftUI

/// Owns app-lifetime stores, sampling and native status presentation. Register
/// the Settings scene through Apple's public AppKit/SwiftUI scene bridge.
@MainActor
final class CoreMetricsAppDelegate: NSObject, NSApplicationDelegate {
    private let metricsStore: MetricsStore
    private let preferencesStore: PreferencesStore
    private let launchAtLoginStore: LaunchAtLoginStore
    private let writeToClipboard: @MainActor (String) -> Bool
    private var settingsScene: NSHostingSceneRepresentation<CoreMetricsSettingsScene>?
    private var statusController: StatusItemController?

    override init() {
        #if DEBUG
        if let testPreferences = UITestLaunchConfiguration.configureIfRequested() {
            if ProcessInfo.processInfo.environment["CORE_METRICS_UI_ALTERNATING_CPU"] == "1" {
                metricsStore = MetricsStore(cpuProvider: UITestAlternatingCPUProvider())
            } else {
                metricsStore = MetricsStore()
            }
            preferencesStore = testPreferences
            launchAtLoginStore = LaunchAtLoginStore(service: UITestLaunchAtLoginService())
            let shouldFailCopy = ProcessInfo.processInfo.environment["CORE_METRICS_UI_COPY_FAILURE"] == "1"
            writeToClipboard = { _ in !shouldFailCopy }
            super.init()
            return
        }
        #endif
        metricsStore = MetricsStore()
        preferencesStore = PreferencesStore()
        launchAtLoginStore = LaunchAtLoginStore()
        writeToClipboard = { CurrentReadingsPasteboard.write($0, to: .general) }
        super.init()
    }

    func applicationWillFinishLaunching(_ notification: Notification) {
        let scene = NSHostingSceneRepresentation {
            CoreMetricsSettingsScene(
                metricsStore: metricsStore,
                preferencesStore: preferencesStore,
                launchAtLoginStore: launchAtLoginStore,
                dismissPanel: { [weak self] in self?.statusController?.dismissPanel() }
            )
        }
        settingsScene = scene
        NSApplication.shared.addSceneRepresentation(scene)
        installApplicationMenu()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let settingsScene else { return }
        statusController = StatusItemController(
            metricsStore: metricsStore,
            preferencesStore: preferencesStore,
            openSettings: settingsScene.environment.openSettings,
            writeToClipboard: writeToClipboard
        )
        metricsStore.start()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows: Bool) -> Bool {
        // Launching the already-running utility provides a recovery path to
        // Settings even when other menu-bar items leave too little room.
        openSettings()
        return false
    }

    func applicationWillTerminate(_ notification: Notification) {
        statusController?.stop()
        statusController = nil
        metricsStore.stop()
    }

    @objc private func openSettings() {
        statusController?.dismissPanel()
        NSApplication.shared.activate()
        settingsScene?.environment.openSettings()
    }

    private func installApplicationMenu() {
        let mainMenu = NSMenu()
        let appMenuItem = NSMenuItem()
        let appMenu = NSMenu(title: "Core Metrics")
        let settings = NSMenuItem(
            title: String(localized: "Settings…"),
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settings.target = self
        appMenu.addItem(settings)
        appMenu.addItem(.separator())
        appMenu.addItem(NSMenuItem(
            title: String(localized: "Quit Core Metrics"),
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        ))
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)

        let fileMenuItem = NSMenuItem()
        let fileMenu = NSMenu(title: String(localized: "File"))
        fileMenu.addItem(NSMenuItem(
            title: String(localized: "Close Window"),
            action: #selector(NSWindow.performClose(_:)),
            keyEquivalent: "w"
        ))
        fileMenuItem.submenu = fileMenu
        mainMenu.addItem(fileMenuItem)

        let editMenuItem = NSMenuItem()
        let editMenu = NSMenu(title: String(localized: "Edit"))
        editMenu.addItem(NSMenuItem(
            title: String(localized: "Copy"),
            action: #selector(NSText.copy(_:)),
            keyEquivalent: "c"
        ))
        editMenu.addItem(NSMenuItem(
            title: String(localized: "Select All"),
            action: #selector(NSText.selectAll(_:)),
            keyEquivalent: "a"
        ))
        editMenuItem.submenu = editMenu
        mainMenu.addItem(editMenuItem)
        NSApplication.shared.mainMenu = mainMenu
    }
}
