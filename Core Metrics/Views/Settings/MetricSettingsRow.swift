import SwiftUI

struct MetricSettingsRow: View {
    @Environment(PreferencesStore.self) private var preferencesStore

    let metric: MetricKind

    var body: some View {
        HStack(spacing: 12) {
            Toggle(isOn: enabledBinding) {
                Label(metric.displayName, systemImage: metric.systemImage)
            }
            .disabled(isOnlyEnabledMetric)

            Spacer()

            if isEnabled {
                HStack(spacing: 4) {
                    Button {
                        preferencesStore.moveMetricUp(metric)
                    } label: {
                        Image(systemName: "arrow.up")
                    }
                    .disabled(isFirst)
                    .accessibilityLabel("Move \(metric.displayName) earlier")
                    .help("Move earlier")

                    Button {
                        preferencesStore.moveMetricDown(metric)
                    } label: {
                        Image(systemName: "arrow.down")
                    }
                    .disabled(isLast)
                    .accessibilityLabel("Move \(metric.displayName) later")
                    .help("Move later")
                }
                .buttonStyle(.borderless)
                .controlSize(.small)
            }
        }
    }

    private var enabledBinding: Binding<Bool> {
        Binding(
            get: { preferencesStore.isMetricEnabled(metric) },
            set: { preferencesStore.setMetric(metric, enabled: $0) }
        )
    }

    private var isEnabled: Bool {
        preferencesStore.isMetricEnabled(metric)
    }

    private var isOnlyEnabledMetric: Bool {
        isEnabled && !preferencesStore.canDisable(metric)
    }

    private var enabledIndex: Int? {
        preferencesStore.enabledMetrics.firstIndex(of: metric)
    }

    private var isFirst: Bool {
        enabledIndex == preferencesStore.enabledMetrics.startIndex
    }

    private var isLast: Bool {
        guard let enabledIndex else {
            return false
        }

        return enabledIndex == preferencesStore.enabledMetrics.index(
            before: preferencesStore.enabledMetrics.endIndex
        )
    }
}
