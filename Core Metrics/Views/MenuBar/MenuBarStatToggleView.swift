import SwiftUI

/// A native panel toggle that preserves the one-to-seven stat invariant.
struct MenuBarStatToggleView: View {
    @Environment(PreferencesStore.self) private var preferencesStore

    let stat: MenuBarStat

    var body: some View {
        Toggle(stat.panelName, isOn: selection)
            .disabled(isDisabled)
            .toggleStyle(.checkbox)
            .accessibilityIdentifier("menuBarStat.\(stat.rawValue)")
            .accessibilityLabel(stat.displayName)
            .accessibilityHint(accessibilityHint)
    }

    private var selection: Binding<Bool> {
        Binding(
            get: { preferencesStore.isStatEnabled(stat) },
            set: { preferencesStore.setStat(stat, enabled: $0) }
        )
    }

    private var isDisabled: Bool {
        if preferencesStore.isStatEnabled(stat) {
            return !preferencesStore.canDisable(stat)
        }

        return !preferencesStore.canEnable(stat)
    }

    private var accessibilityHint: String {
        if preferencesStore.isStatEnabled(stat) {
            return preferencesStore.canDisable(stat)
                ? String(localized: "Removes this value from the menu bar.")
                : String(localized: "At least one value must remain selected.")
        }

        return isDisabled
            ? String(localized: "Remove another value before selecting this one.")
            : String(localized: "Adds this value to the menu bar.")
    }
}
