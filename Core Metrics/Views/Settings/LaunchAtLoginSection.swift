import SwiftUI

struct LaunchAtLoginSection: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(LaunchAtLoginStore.self) private var launchAtLoginStore

    var body: some View {
        Section {
            HStack {
                Toggle("Launch at Login", isOn: registration)
                    .disabled(!launchAtLoginStore.canChangeRegistration)
                    .accessibilityIdentifier("settings.launchAtLogin")
                    .accessibilityValue(statusDescription)

                if launchAtLoginStore.isUpdating {
                    ProgressView()
                        .controlSize(.small)
                        .accessibilityLabel("Updating Launch at Login")
                }
            }

            if launchAtLoginStore.status != .notRegistered {
                Text(statusDescription)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("settings.launchAtLoginStatus")
            }

            if let errorMessage = launchAtLoginStore.errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("settings.launchAtLoginError")
            }

            if launchAtLoginStore.status == .requiresApproval
                || launchAtLoginStore.errorMessage != nil {
                Button("Open Login Items Settings…", action: openLoginItemsSettings)
                    .disabled(launchAtLoginStore.isUpdating)
                    .accessibilityIdentifier("settings.loginItemsSettings")
            }
        } header: {
            Text("Startup")
        } footer: {
            Text("Open Core Metrics automatically when you log in. macOS manages this setting separately from your menu-bar preferences.")
        }
        .onAppear(perform: refresh)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { refresh() }
        }
    }

    private var registration: Binding<Bool> {
        Binding(
            get: { launchAtLoginStore.isRegistered },
            set: { launchAtLoginStore.setEnabled($0) }
        )
    }

    private var statusDescription: String {
        switch launchAtLoginStore.status {
        case .notRegistered:
            String(localized: "Off")
        case .enabled:
            String(localized: "Core Metrics will open when you log in.")
        case .requiresApproval:
            String(localized: "Approval required. Allow Core Metrics in Login Items in System Settings before it can open at login.")
        case .notFound:
            String(localized: "Launch at Login is unavailable for this copy of Core Metrics.")
        case .unknown:
            String(localized: "macOS couldn’t determine the Launch at Login status.")
        }
    }

    private func refresh() {
        launchAtLoginStore.refresh()
    }

    private func openLoginItemsSettings() {
        launchAtLoginStore.openLoginItemsSettings()
    }
}
