import SwiftUI

struct SettingsView: View {
    @Environment(PreferencesStore.self) private var preferencesStore

    var body: some View {
        @Bindable var preferences = preferencesStore

        Form {
            Section {
                ScrollView(.horizontal) {
                    MenuBarLabelView()
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .glassEffect(.regular, in: .capsule)
                }
                .scrollIndicators(.hidden)
                .frame(maxWidth: .infinity)
            } header: {
                Text("Live Preview")
            } footer: {
                Text("This uses the same fixed-width slots as the menu bar. Scroll horizontally when a five-stat layout is wider than the preview area.")
            }

            Section {
                ForEach(preferencesStore.enabledStats) { stat in
                    MenuBarStatSettingsRow(stat: stat)
                }

                HStack {
                    addStatMenu
                        .disabled(availableStats.isEmpty)

                    Spacer()

                    Text("\(preferencesStore.enabledStats.count) of \(MenuBarConfiguration.maximumEnabledStatCount)")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Menu Bar Stats")
            } footer: {
                Text("Choose one to five aggregate stats. The two-character code appears in Compact mode. Each stat keeps a fixed-width slot while its value updates. Value Only is available for a single stat.")
            }

            Section("Representation") {
                Picker("Display", selection: $preferences.displayMode) {
                    ForEach(availableDisplayModes) { mode in
                        Text(mode.displayName)
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section {
                HStack {
                    Spacer()
                    Button("Restore Defaults") {
                        preferencesStore.reset()
                    }
                }
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 420, idealWidth: 480)
    }

    private var addStatMenu: some View {
        Menu {
            ForEach(MetricKind.allCases) { metric in
                Menu(metric.displayName) {
                    ForEach(availableStats.filter { $0.metric == metric }) { stat in
                        Button(stat.displayName) {
                            preferencesStore.setStat(stat, enabled: true)
                        }
                    }
                }
                .disabled(availableStats.allSatisfy { $0.metric != metric })
            }
        } label: {
            Label("Add Stat", systemImage: "plus")
        }
    }

    private var availableStats: [MenuBarStat] {
        guard preferencesStore.enabledStats.count < MenuBarConfiguration.maximumEnabledStatCount else {
            return []
        }

        return MenuBarStat.allCases.filter { !preferencesStore.isStatEnabled($0) }
    }

    private var availableDisplayModes: [MenuBarDisplayMode] {
        if preferencesStore.enabledStats.count > 1 {
            return MenuBarDisplayMode.allCases.filter { $0 != .valueOnly }
        }

        return MenuBarDisplayMode.allCases
    }
}
