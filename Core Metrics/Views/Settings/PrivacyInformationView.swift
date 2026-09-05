import SwiftUI

/// Keep these statements aligned with providers, preferences, and diagnostics.
struct PrivacyInformationView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Privacy")
                .font(.title2)
                .bold()
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("privacyInformation.title")

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Core Metrics works entirely on your Mac.")

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Metric Readings")
                            .font(.headline)
                            .accessibilityAddTraits(.isHeader)
                        Text("The app reads aggregate CPU usage, memory usage including swap, and startup-volume capacity. It does not inspect individual processes or scan your files.")
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Saved Information")
                            .font(.headline)
                            .accessibilityAddTraits(.isHeader)
                        Text("Current readings are kept in memory while the app runs. No metric history is saved. Your menu-bar selections and display style are saved locally and can be reset with Restore Defaults.")
                        Text("The optional Launch at Login setting is managed separately by macOS.")
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Connections")
                            .font(.headline)
                            .accessibilityAddTraits(.isHeader)
                        Text("The app makes no network connections. It has no accounts, analytics, advertising, or tracking.")
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Local Diagnostics")
                            .font(.headline)
                            .accessibilityAddTraits(.isHeader)
                        Text("When readings become unavailable or recover, the app writes a message to macOS system logs. These messages contain only the metric category and availability state.")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)
            }
            .focusable()
            .accessibilityIdentifier("privacyInformation.content")
            .accessibilityLabel("Privacy Information")
            .accessibilityHint("Scroll vertically to read all privacy information.")

            HStack {
                Spacer()
                Button("Done", action: close)
                    .keyboardShortcut(.defaultAction)
                    .accessibilityIdentifier("privacyInformation.done")
            }
        }
        .padding(24)
        .frame(minWidth: 440, idealWidth: 500, minHeight: 360, idealHeight: 440)
        .onExitCommand(perform: close)
    }

    private func close() {
        dismiss()
    }
}
