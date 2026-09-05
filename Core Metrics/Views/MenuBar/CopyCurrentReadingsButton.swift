import Accessibility
import SwiftUI

struct CopyCurrentReadingsButton: View {
    var writeToClipboard: @MainActor (String) -> Bool = { text in
        CurrentReadingsPasteboard.write(text, to: .general)
    }

    @Environment(\.locale) private var locale
    @Environment(MetricsStore.self) private var metricsStore
    @Environment(PreferencesStore.self) private var preferencesStore
    @State private var isShowingFailure = false
    @State private var didCopy = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button("Copy Current Readings", systemImage: "doc.on.doc", action: copyReadings)
                .accessibilityIdentifier("menuBar.copyCurrentReadings")
                .accessibilityHint("Copies the full names and current values of your selected stats.")

            if didCopy {
                Text("Copied")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Readings copied")
                    .accessibilityIdentifier("menuBar.copyConfirmation")
            }
        }
        .alert("Couldn’t Copy Readings", isPresented: $isShowingFailure) {
        } message: {
            Text("The readings could not be written to the clipboard. Try copying them again.")
        }
        .onChange(of: preferencesStore.enabledStats) {
            didCopy = false
        }
        .onChange(of: locale) {
            didCopy = false
        }
        .onDisappear {
            didCopy = false
        }
    }

    private func copyReadings() {
        let text = CurrentReadingsFormatting.text(
            stats: preferencesStore.enabledStats,
            cpuUsage: metricsStore.cpuUsage,
            memoryUsage: metricsStore.memoryUsage,
            storageUsage: metricsStore.storageUsage,
            locale: locale
        )
        didCopy = writeToClipboard(text)
        isShowingFailure = !didCopy
        if didCopy {
            AccessibilityNotification.Announcement(String(localized: "Readings copied")).post()
        }
    }
}
