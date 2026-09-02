import SwiftUI

/// The status item uses a real macOS menu so the system owns its Liquid Glass,
/// selection, keyboard behavior, separators, and nested-menu presentation.
struct MenuBarMenuView: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(PreferencesStore.self) private var preferencesStore

    var body: some View {
        @Bindable var preferences = preferencesStore
        let selectedStatCount = preferencesStore.enabledStats.count
        let maximumStatCount = MenuBarConfiguration.maximumEnabledStatCount

        Button("Show Core Metrics", action: showDashboard)

        Divider()

        Section("Selected Stats") {
            ForEach(preferencesStore.enabledStats) { stat in
                MenuBarSelectedStatItemView(
                    stat: stat,
                    action: showDashboard
                )
            }
        }

        Divider()

        Menu("Customize Stats") {
            Text("\(selectedStatCount) of \(maximumStatCount) selected")

            Divider()

            ForEach(MetricKind.allCases) { metric in
                Menu(metric.displayName) {
                    ForEach(MenuBarStat.values(for: metric)) { stat in
                        MenuBarStatToggleView(stat: stat)
                    }
                }
            }
        }

        Picker("Menu Bar Display", selection: $preferences.displayMode) {
            ForEach(availableDisplayModes) { mode in
                Text(mode.displayName)
                    .tag(mode)
            }
        }

        Divider()

        Button("About Core Metrics", action: showAbout)

        SettingsLink {
            Text("Settings…")
        }
        .keyboardShortcut(",", modifiers: .command)

        Divider()

        Button("Quit Core Metrics", action: quit)
            .keyboardShortcut("q")
    }

    private var availableDisplayModes: [MenuBarDisplayMode] {
        preferencesStore.enabledStats.count > 1
            ? MenuBarDisplayMode.allCases.filter { $0 != .valueOnly }
            : MenuBarDisplayMode.allCases
    }

    private func showDashboard() {
        openWindow(id: DashboardLayout.windowIdentifier)
        NSApplication.shared.activate()
    }

    private func showAbout() {
        NSApplication.shared.activate()
        NSApplication.shared.orderFrontStandardAboutPanel(nil)
    }

    private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
