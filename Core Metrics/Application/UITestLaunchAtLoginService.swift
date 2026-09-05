#if DEBUG
/// An explicitly injected UI-test service. It never calls ServiceManagement
/// or modifies the person's actual macOS login items.
@MainActor
final class UITestLaunchAtLoginService: LaunchAtLoginServicing {
    private(set) var status: LaunchAtLoginStatus = .notRegistered

    func register() throws {
        status = .enabled
    }

    func unregister() async throws {
        status = .notRegistered
    }

    func openLoginItemsSettings() {}
}
#endif
