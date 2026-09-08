import SwiftUI

/// Persistent selection content hosted in the native status popover.
struct MenuBarMenuView: View {
    let dismissPanel: @MainActor () -> Void
    let openSettings: OpenSettingsAction
    var writeToClipboard: @MainActor (String) -> Bool = { CurrentReadingsPasteboard.write($0, to: .general) }

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

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
                Button("Settings…", action: showSettings)
                    .buttonStyle(.bordered)
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
    }

    private var panelWidth: Double {
        dynamicTypeSize.isAccessibilitySize ? 500 : 420
    }

    private func quit() {
        NSApplication.shared.terminate(nil)
    }

    private func showSettings() {
        dismissPanel()
        NSApplication.shared.activate()
        openSettings()
    }
}
