import AppKit
import SwiftUI

extension FocusedValues {
    @Entry var dismissMenuBarPanel: DismissAction?
}

/// Route the app-wide shortcut through the active panel's native dismissal.
struct SettingsCommands: Commands {
    @FocusedValue(\.dismissMenuBarPanel) private var dismissMenuBarPanel
    @Environment(\.openSettings) private var openSettings

    var body: some Commands {
        CommandGroup(replacing: .appSettings) {
            Button("Settings…") {
                dismissMenuBarPanel?()
                NSApplication.shared.activate()
                openSettings()
            }
            .keyboardShortcut(",", modifiers: .command)
        }
    }
}
