import AppKit
import SwiftUI

struct DashboardFooterView: View {
    var body: some View {
        GlassEffectContainer(spacing: 8) {
            HStack {
                SettingsLink {
                    Label("Settings", systemImage: "gearshape")
                }

                Spacer()

                Button("Quit", systemImage: "power", action: quit)
                    .keyboardShortcut("q")
            }
            .buttonStyle(.glass)
            .controlSize(.small)
        }
    }

    private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
