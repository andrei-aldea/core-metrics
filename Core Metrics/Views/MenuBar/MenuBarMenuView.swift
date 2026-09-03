import SwiftUI

/// A persistent, system-presented menu-bar panel. Window style is intentional:
/// unlike a pull-down menu, the panel remains open while several stats are
/// selected and macOS still owns the surrounding Liquid Glass material.
struct MenuBarMenuView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.openWindow) private var openWindow
    @Environment(PreferencesStore.self) private var preferencesStore

    var body: some View {
        @Bindable var preferences = preferencesStore

        VStack(spacing: 0) {
            Button("Open Core Metrics", action: showDashboard)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(Color.primary)
                .accessibilityIdentifier("openDashboard")
                .frame(maxWidth: .infinity)
                .padding()

            Divider()

            Form {
                Section {
                    LabeledContent("Selected") {
                        Text(selectionCount)
                            .monospacedDigit()
                    }
                } footer: {
                    Text("Choose up to five values here and reorder them in Settings. Live values appear only in the menu bar itself.")
                }

                ForEach(MetricKind.allCases) { metric in
                    Section(metric.displayName) {
                        ForEach(MenuBarStat.values(for: metric)) { stat in
                            MenuBarStatToggleView(stat: stat)
                        }
                    }
                }

                Section("Menu Bar Text") {
                    Picker("Style", selection: $preferences.displayMode) {
                        ForEach(availableDisplayModes) { mode in
                            Text(mode.displayName)
                                .tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .formStyle(.grouped)
            .accessibilityIdentifier("menuBarPanel")

            Divider()

            HStack {
                Button("About", action: showAbout)

                SettingsLink {
                    Text("Settings…")
                }
                .keyboardShortcut(",", modifiers: .command)

                Spacer()

                Button("Quit", action: quit)
                    .keyboardShortcut("q")
            }
            .padding()
        }
        .frame(width: panelWidth)
        .frame(minHeight: 540, idealHeight: 580)
    }

    private var selectionCount: String {
        "\(preferencesStore.enabledStats.count) of \(MenuBarConfiguration.maximumEnabledStatCount)"
    }

    private var availableDisplayModes: [MenuBarDisplayMode] {
        preferencesStore.enabledStats.count > 1
            ? MenuBarDisplayMode.allCases.filter { $0 != .valueOnly }
            : MenuBarDisplayMode.allCases
    }

    private var panelWidth: Double {
        dynamicTypeSize.isAccessibilitySize ? 500 : 420
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
