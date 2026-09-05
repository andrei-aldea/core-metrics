import SwiftUI

struct MenuBarStatSettingsRow: View {
    @Environment(PreferencesStore.self) private var preferencesStore

    let stat: MenuBarStat

    var body: some View {
        HStack(spacing: 12) {
            Label(stat.displayName, systemImage: stat.metric.systemImage)

            Spacer()

            Text(stat.shortCode)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            Button(
                "Remove \(stat.displayName)",
                systemImage: "minus.circle",
                action: removeStat
            )
            .disabled(!preferencesStore.canDisable(stat))
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)
            .controlSize(.small)
            .help("Remove from menu bar")
            .accessibilityHint(
                preferencesStore.canDisable(stat)
                    ? String(localized: "Removes this value from the menu bar.")
                    : String(localized: "At least one value must remain selected.")
            )
        }
    }

    private func removeStat() {
        preferencesStore.setStat(stat, enabled: false)
    }
}
