import SwiftUI

/// A persistent, system-presented menu-bar panel. Window style is intentional:
/// unlike a pull-down menu, the panel remains open while several stats are
/// selected and macOS still owns the surrounding Liquid Glass material.
struct MenuBarMenuView: View {
    var writeToClipboard: @MainActor (String) -> Bool = { CurrentReadingsPasteboard.write($0, to: .general) }

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(PreferencesStore.self) private var preferencesStore
    @State private var isShowingMetricHelp = false

    var body: some View {
        @Bindable var preferences = preferencesStore

        VStack(spacing: 0) {
            Form {
                ForEach(MetricKind.allCases) { metric in
                    Section(metric.displayName) {
                        ForEach(MenuBarStat.values(for: metric)) { stat in
                            MenuBarStatToggleView(stat: stat)
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .accessibilityIdentifier("menuBarPanel")

            VStack(alignment: .leading) {
                Text("Menu Bar Text")
                    .font(.headline)

                Picker("Menu Bar Text", selection: $preferences.displayMode) {
                    ForEach(preferencesStore.availableDisplayModes) { mode in
                        Text(mode.displayName)
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .fixedSize(horizontal: true, vertical: false)
                .frame(maxWidth: .infinity)
            }
            .padding()

            Divider()

            HStack(alignment: .top) {
                CopyCurrentReadingsButton(writeToClipboard: writeToClipboard)

                Spacer()

                Button("Metric Help…") {
                    isShowingMetricHelp = true
                }
                .accessibilityIdentifier("menuBar.metricHelp")
            }
            .padding(.horizontal)
            .padding(.top)

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
        .sheet(isPresented: $isShowingMetricHelp) {
            MetricHelpView()
        }
    }

    private var panelWidth: Double {
        dynamicTypeSize.isAccessibilitySize ? 500 : 420
    }

    private func showAbout() {
        NSApplication.shared.activate()
        NSApplication.shared.orderFrontStandardAboutPanel(nil)
    }

    private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
