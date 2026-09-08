import AppKit
import SwiftUI

/// Route Settings through the owned native panel's dismissal action.
struct SettingsCommands: Commands {
    let dismissPanel: @MainActor () -> Void
    @Environment(\.openSettings) private var openSettings

    var body: some Commands {
        CommandGroup(replacing: .appSettings) {
            Button("Settings…") {
                dismissPanel()
                NSApplication.shared.activate()
                openSettings()
            }
            .keyboardShortcut(",", modifiers: .command)
        }
    }
}
