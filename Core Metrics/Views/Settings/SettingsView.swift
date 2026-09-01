import SwiftUI

struct SettingsView: View {
    @Environment(PreferencesStore.self) private var preferencesStore

    var body: some View {
        @Bindable var preferences = preferencesStore

        Form {
            Section {
                ForEach(orderedMetrics) { metric in
                    MetricSettingsRow(metric: metric)
                }
            } header: {
                Text("Menu Bar Metrics")
            } footer: {
                Text("Choose one to three metrics. Enabled metrics appear in this order. Value Only is available for a single metric.")
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

            Section("Metric Values") {
                Picker("Memory", selection: $preferences.memoryValueStyle) {
                    ForEach(MemoryMenuValueStyle.allCases, id: \.self) { style in
                        Text(style.displayName).tag(style)
                    }
                }

                Picker("Storage", selection: $preferences.storageValueStyle) {
                    ForEach(StorageMenuValueStyle.allCases, id: \.self) { style in
                        Text(style.displayName).tag(style)
                    }
                }
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

    private var orderedMetrics: [MetricKind] {
        preferencesStore.enabledMetrics + MetricKind.allCases.filter {
            !preferencesStore.isMetricEnabled($0)
        }
    }

    private var availableDisplayModes: [MenuBarDisplayMode] {
        if preferencesStore.enabledMetrics.count > 1 {
            return MenuBarDisplayMode.allCases.filter { $0 != .valueOnly }
        }

        return MenuBarDisplayMode.allCases
    }
}
