import AppKit
import SwiftUI

/// The status item uses a real macOS menu so the system owns its Liquid Glass,
/// selection, keyboard behavior, separators, and nested-menu presentation.
struct MenuBarMenuView: View {
    @Environment(\.locale) private var locale
    @Environment(\.openWindow) private var openWindow
    @Environment(MetricsStore.self) private var metricsStore
    @Environment(PreferencesStore.self) private var preferencesStore

    var body: some View {
        @Bindable var preferences = preferencesStore

        Button("Show Core Metrics", action: showDashboard)

        Divider()

        Section("Selected Stats") {
            ForEach(preferencesStore.enabledStats) { stat in
                Button(action: showDashboard) {
                    Text(menuTitle(for: stat))
                }
                .accessibilityLabel(accessibilityLabel(for: stat))
            }
        }

        Divider()

        Menu("Customize Stats") {
            Text(
                "\(preferencesStore.enabledStats.count) of "
                    + "\(MenuBarConfiguration.maximumEnabledStatCount) selected"
            )

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

        SettingsLink {
            Text("Settings…")
        }

        Divider()

        Button("Quit Core Metrics", action: quit)
            .keyboardShortcut("q")
    }

    private var availableDisplayModes: [MenuBarDisplayMode] {
        preferencesStore.enabledStats.count > 1
            ? MenuBarDisplayMode.allCases.filter { $0 != .valueOnly }
            : MenuBarDisplayMode.allCases
    }

    private func menuTitle(for stat: MenuBarStat) -> String {
        "\(stat.dashboardName) — \(formattedValue(for: stat))"
    }

    private func accessibilityLabel(for stat: MenuBarStat) -> String {
        let value = formattedValue(for: stat)
        let accessibleValue = value == MetricFormatting.unavailable
            ? "Unavailable"
            : value
        return "\(stat.displayName), \(accessibleValue)"
    }

    private func formattedValue(for stat: MenuBarStat) -> String {
        MenuValueFormatting.value(
            for: stat,
            cpuUsage: metricsStore.cpuUsage,
            memoryUsage: metricsStore.memoryUsage,
            storageUsage: metricsStore.storageUsage,
            locale: locale
        )
    }

    private func showDashboard() {
        openWindow(id: DashboardLayout.windowIdentifier)
        NSApplication.shared.activate()
    }

    private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
