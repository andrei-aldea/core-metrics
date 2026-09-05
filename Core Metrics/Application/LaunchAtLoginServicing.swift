/// Main-actor boundary for the system login-item setting and test substitutes.
@MainActor
protocol LaunchAtLoginServicing: AnyObject {
    var status: LaunchAtLoginStatus { get }
    func register() throws
    func unregister() async throws
    func openLoginItemsSettings()
}
