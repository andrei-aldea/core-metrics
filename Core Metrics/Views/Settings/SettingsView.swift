import SwiftUI

struct SettingsView: View {
    @Environment(PreferencesStore.self) private var preferencesStore
    @State private var isShowingPrivacy = false

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
                .frame(maxWidth: .infinity)
                .focusable()
                .accessibilityIdentifier("settings.livePreview")
                .accessibilityLabel("Live Preview")
                .accessibilityHint("Scroll horizontally to read all selected stats.")
            } header: {
                Text("Live Preview")
            } footer: {
                Text("Your full selection is shown here. Scroll horizontally to see every stat. Long menu-bar text is shortened to leave room for other items.")
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
                    Button("Privacy…", action: showPrivacy)
                        .accessibilityIdentifier("settings.privacyInformation")

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
        .sheet(isPresented: $isShowingPrivacy) {
            PrivacyInformationView()
        }
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

    private func showPrivacy() {
        isShowingPrivacy = true
    }
}
