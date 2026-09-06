import AppKit
import SwiftUI

/// Close the menu-bar panel before activating the app and opening Settings.
/// Keeping a Button preserves keyboard and accessibility activation.
struct ActivatingSettingsLinkStyle: PrimitiveButtonStyle {
    let dismissPanel: DismissAction

    func makeBody(configuration: Configuration) -> some View {
        Button(role: configuration.role) {
            dismissPanel()
            NSApplication.shared.activate()
            configuration.trigger()
        } label: {
            configuration.label
        }
        .buttonStyle(.bordered)
    }
}
