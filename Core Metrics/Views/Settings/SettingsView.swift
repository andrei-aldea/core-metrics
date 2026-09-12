import SwiftUI

struct SettingsView: View {
    @Environment(PreferencesStore.self) private var preferencesStore
    @State private var isShowingPrivacy = false
    @State private var isShowingMetricHelp = false

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
                Text("Your full selection is shown here. Scroll horizontally to see every stat.")
            }

            Section {
                Picker("Display", selection: $preferences.displayMode) {
                    ForEach(preferencesStore.availableDisplayModes) { mode in
                        Text(mode.displayName)
                            .tag(mode)
                    }
                }
                .pickerStyle(.radioGroup)
                .accessibilityIdentifier("settings.displayMode")
            } header: {
                Text("Menu Bar Text")
            } footer: {
                Text("All modes use the same text size. Compact shortens labels; Icon and Value shows category symbols; Values Only hides labels. Stats keep the order shown below.")
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
                Text("Choose one to seven stats. Their order always matches the CPU, Memory, and Storage order in the status panel.")
            }

            LaunchAtLoginSection()

            Section {
                HStack {
                    Button("Privacy…", action: showPrivacy)
                        .accessibilityIdentifier("settings.privacyInformation")

                    Button("Metric Help…") {
                        isShowingMetricHelp = true
                    }
                    .accessibilityIdentifier("settings.metricHelp")

                    Link("Support…", destination: PublicAppLinks.support)
                        .accessibilityIdentifier("settings.support")
                        .help("Open Core Metrics support in your browser")

                    Spacer()
                    Button("Restore Defaults") {
                        preferencesStore.reset()
                    }
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 580)
        .frame(minHeight: 500, idealHeight: 560, maxHeight: .infinity)
        .sheet(isPresented: $isShowingPrivacy) {
            PrivacyInformationView()
        }
        .sheet(isPresented: $isShowingMetricHelp) {
            MetricHelpView()
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
        .accessibilityIdentifier("settings.addStat")
    }

    private func showPrivacy() {
        isShowingPrivacy = true
    }
}
