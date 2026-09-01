import AppKit
import SwiftUI

struct DashboardFooterView: View {
    var body: some View {
        HStack {
            SettingsLink {
                Label("Settings", systemImage: "gearshape")
            }

            Spacer()

            Button("Quit", systemImage: "power", action: quit)
                .keyboardShortcut("q")
        }
        .buttonStyle(.borderless)
        .controlSize(.small)
    }

    private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
