import SwiftUI

/// A native menu toggle that preserves the one-to-five stat invariant.
struct MenuBarStatToggleView: View {
    @Environment(PreferencesStore.self) private var preferencesStore

    let stat: MenuBarStat

    var body: some View {
        Toggle(stat.dashboardName, isOn: selection)
            .disabled(isDisabled)
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

        return preferencesStore.enabledStats.count
            >= MenuBarConfiguration.maximumEnabledStatCount
    }
}
