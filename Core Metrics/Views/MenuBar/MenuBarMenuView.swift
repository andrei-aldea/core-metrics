import SwiftUI

/// A persistent, system-presented menu-bar panel. Window style is intentional:
/// unlike a pull-down menu, the panel remains open while several stats are
/// selected and macOS still owns the surrounding Liquid Glass material.
struct MenuBarMenuView: View {
    var writeToClipboard: @MainActor (String) -> Bool = { CurrentReadingsPasteboard.write($0, to: .general) }

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.dismiss) private var dismiss

    var body: some View {
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

            Divider()

            HStack(alignment: .firstTextBaseline, spacing: 12) {
                SettingsLink {
                    Text("Settings…")
                }
                .buttonStyle(ActivatingSettingsLinkStyle(dismissPanel: dismiss))
                .accessibilityIdentifier("menuBar.settings")

                CopyCurrentReadingsButton(writeToClipboard: writeToClipboard)

                Spacer()

                Button("Quit", action: quit)
                    .keyboardShortcut("q")
            }
            .padding()
        }
        .frame(width: panelWidth)
        .frame(minHeight: 540, idealHeight: 580)
        .focusedSceneValue(\.dismissMenuBarPanel, dismiss)
    }

    private var panelWidth: Double {
        dynamicTypeSize.isAccessibilitySize ? 500 : 420
    }

    private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
