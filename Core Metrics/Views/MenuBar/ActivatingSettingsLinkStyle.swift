import AppKit
import SwiftUI

/// MenuBarExtra can be used while the app is inactive. Activate the app as
/// part of the native button action, then let SettingsLink open or raise its
/// scene. Keeping a Button preserves keyboard and accessibility activation.
struct ActivatingSettingsLinkStyle: PrimitiveButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(role: configuration.role) {
            NSApplication.shared.activate()
            configuration.trigger()
        } label: {
            configuration.label
        }
        .buttonStyle(.bordered)
        .keyboardShortcut(",", modifiers: .command)
    }
}
