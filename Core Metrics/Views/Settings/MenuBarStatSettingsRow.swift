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

            HStack(spacing: 4) {
                Button("Move \(stat.displayName) earlier", systemImage: "arrow.up") {
                    preferencesStore.moveStatUp(stat)
                }
                .disabled(isFirst)
                .labelStyle(.iconOnly)
                .help("Move earlier")

                Button("Move \(stat.displayName) later", systemImage: "arrow.down") {
                    preferencesStore.moveStatDown(stat)
                }
                .disabled(isLast)
                .labelStyle(.iconOnly)
                .help("Move later")

                Button("Remove \(stat.displayName)", systemImage: "minus.circle") {
                    preferencesStore.setStat(stat, enabled: false)
                }
                .disabled(!preferencesStore.canDisable(stat))
                .labelStyle(.iconOnly)
                .help("Remove from menu bar")
            }
            .buttonStyle(.borderless)
            .controlSize(.small)
        }
    }

    private var enabledIndex: Int? {
        preferencesStore.enabledStats.firstIndex(of: stat)
    }

    private var isFirst: Bool {
        enabledIndex == preferencesStore.enabledStats.startIndex
    }

    private var isLast: Bool {
        guard let enabledIndex else {
            return false
        }

        return enabledIndex == preferencesStore.enabledStats.index(
            before: preferencesStore.enabledStats.endIndex
        )
    }
}
