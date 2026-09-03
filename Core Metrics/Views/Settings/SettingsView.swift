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
                Text("This is the exact text sent to the menu bar. Each value reserves an eight-character column, so live updates do not resize its slot.")
            }

            Section {
                ForEach(preferencesStore.enabledStats) { stat in
                    MenuBarStatSettingsRow(stat: stat)
                }

                HStack {
                    addStatMenu
                        .disabled(preferencesStore.availableStats.isEmpty)

                    Spacer()

                    Text("\(preferencesStore.enabledStats.count) of \(MenuBarConfiguration.maximumEnabledStatCount)")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Menu Bar Stats")
            } footer: {
                Text("Choose one to seven stats. Their order always matches the CPU, Memory, and Storage order in the status panel. Value Only is available when a single stat is selected.")
            }

            Section("Representation") {
                Picker("Display", selection: $preferences.displayMode) {
                    ForEach(preferencesStore.availableDisplayModes) { mode in
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
        .frame(
            minWidth: 520,
            idealWidth: 580,
            minHeight: 500,
            idealHeight: 560
        )
    }

    private var addStatMenu: some View {
        let availableStats = preferencesStore.availableStats

        return Menu {
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
}
