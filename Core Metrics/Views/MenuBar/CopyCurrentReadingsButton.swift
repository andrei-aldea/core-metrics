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
        Button(action: copyReadings) {
            ZStack {
                // Reserve both localized labels so feedback cannot move the
                // neighboring Settings and Quit buttons.
                Text("Copy Readings").hidden()
                Text("Copied").hidden()
                if didCopy {
                    Text("Copied")
                } else {
                    Text("Copy Readings")
                }
            }
        }
        .accessibilityIdentifier("menuBar.copyCurrentReadings")
        .accessibilityLabel(didCopy ? String(localized: "Copied") : String(localized: "Copy Readings"))
        .accessibilityHint("Copies the full names and current values of your selected stats.")
        .alert("Couldn’t Copy Readings", isPresented: $isShowingFailure) {
            Button("OK", role: .cancel) {
                isShowingFailure = false
            }
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
            if isShowingFailure {
                isShowingFailure = false
            }
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
