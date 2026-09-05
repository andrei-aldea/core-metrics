import Foundation
import Testing
@testable import Core_Metrics

@MainActor
@Suite("Launch at Login state")
struct LaunchAtLoginStoreTests {
    @Test("Initialization and refresh only read the system setting", arguments: LaunchAtLoginStatus.allCases)
    func initializationDoesNotRegister(status: LaunchAtLoginStatus) {
        let service = FakeLoginService()
        let store = LaunchAtLoginStore(service: service)

        #expect(store.status == .notRegistered)
        #expect(!store.isRegistered)

        service.status = status
        store.refresh()

        #expect(store.status == status)
        #expect(store.isRegistered == (status == .enabled || status == .requiresApproval))
        #expect(service.registerCount == 0)
        #expect(service.unregisterCount == 0)
    }

    @Test("An explicit request enables the main-app login item")
    func registersWhenRequested() async throws {
        let service = FakeLoginService()
        let store = LaunchAtLoginStore(service: service)
        let task = try #require(store.setEnabled(true))
        await task.value

        #expect(service.registerCount == 1)
        #expect(store.status == .enabled)
        #expect(store.isRegistered)
        #expect(!store.isUpdating)
        #expect(store.errorMessage == nil)
        #expect(store.setEnabled(true) == nil)
        #expect(service.registerCount == 1)
    }

    @Test("A denied registration keeps approval distinct from enabled")
    func reflectsRequiredApproval() async throws {
        let service = FakeLoginService()
        service.registrationStatus = .requiresApproval
        service.registrationFails = true
        let store = LaunchAtLoginStore(service: service)
        let task = try #require(store.setEnabled(true))
        await task.value

        #expect(store.status == .requiresApproval)
        #expect(store.isRegistered)
        #expect(store.errorMessage == nil)
        #expect(service.openSettingsCount == 0)

        store.openLoginItemsSettings()
        #expect(service.openSettingsCount == 1)
    }

    @Test("Registered and pending login items can be removed", arguments: [
        LaunchAtLoginStatus.enabled, .requiresApproval,
    ])
    func unregistersWhenRequested(status: LaunchAtLoginStatus) async throws {
        let service = FakeLoginService(status: status)
        let store = LaunchAtLoginStore(service: service)
        let task = try #require(store.setEnabled(false))
        await task.value

        #expect(service.unregisterCount == 1)
        #expect(store.status == .notRegistered)
        #expect(!store.isRegistered)
        #expect(!store.isUpdating)
        #expect(store.errorMessage == nil)
    }

    @Test("Operation failures preserve real state and hide raw diagnostics", arguments: [true, false])
    func operationFailureRemainsTruthful(enabling: Bool) async throws {
        let initialStatus: LaunchAtLoginStatus = enabling ? .notRegistered : .enabled
        let service = FakeLoginService(status: initialStatus)
        service.registrationFails = enabling
        service.registrationStatus = initialStatus
        service.unregistrationFails = !enabling
        let store = LaunchAtLoginStore(service: service)
        let task = try #require(store.setEnabled(enabling))
        await task.value

        #expect(store.status == initialStatus)
        #expect(!store.isUpdating)
        let message = try #require(store.errorMessage)
        #expect(!message.contains("sensitive diagnostic"))

        service.status = enabling ? .enabled : .notRegistered
        store.refresh()
        #expect(store.errorMessage == nil)
    }

    @Test("Unavailable system states never trigger registration", arguments: [
        LaunchAtLoginStatus.notFound, .unknown,
    ])
    func doesNotMutateUnavailableService(status: LaunchAtLoginStatus) {
        let service = FakeLoginService(status: status)
        let store = LaunchAtLoginStore(service: service)

        #expect(!store.canChangeRegistration)
        #expect(store.setEnabled(true) == nil)
        #expect(service.registerCount == 0)
        #expect(service.unregisterCount == 0)
    }

    @Test("An in-flight removal cannot overlap a new registration")
    func preventsOverlappingOperations() async throws {
        let service = FakeLoginService(status: .enabled)
        service.suspendsUnregistration = true
        let store = LaunchAtLoginStore(service: service)
        let task = try #require(store.setEnabled(false))
        await service.waitForUnregistration()

        #expect(store.isUpdating)
        #expect(!store.canChangeRegistration)
        store.setEnabled(true)
        #expect(service.registerCount == 0)
        #expect(service.unregisterCount == 1)

        service.completeUnregistration()
        await task.value
        #expect(store.status == .notRegistered)
        #expect(!store.isUpdating)
    }

    @Test("Cancellation before dispatch does not change login items")
    func cancelsBeforeDispatch() async throws {
        let service = FakeLoginService()
        let store = LaunchAtLoginStore(service: service)
        let task = try #require(store.setEnabled(true))
        task.cancel()
        await task.value

        #expect(service.registerCount == 0)
        #expect(store.status == .notRegistered)
        #expect(!store.isUpdating)
        #expect(store.errorMessage == nil)
    }

    @Test("A pending system operation does not retain its store")
    func pendingOperationDoesNotRetainStore() async throws {
        let service = FakeLoginService(status: .enabled)
        service.suspendsUnregistration = true
        var store: LaunchAtLoginStore? = LaunchAtLoginStore(service: service)
        weak let weakStore = store
        let task = try #require(store?.setEnabled(false))
        await service.waitForUnregistration()

        store = nil
        #expect(weakStore == nil)

        service.completeUnregistration()
        await task.value
    }
}

@MainActor
private final class FakeLoginService: LaunchAtLoginServicing {
    var status: LaunchAtLoginStatus
    var registrationStatus = LaunchAtLoginStatus.enabled
    var registrationFails = false
    var unregistrationFails = false
    var suspendsUnregistration = false
    private(set) var registerCount = 0
    private(set) var unregisterCount = 0
    private(set) var openSettingsCount = 0
    private var unregistration: CheckedContinuation<Void, Never>?
    private var unregistrationStarted: CheckedContinuation<Void, Never>?

    init(status: LaunchAtLoginStatus = .notRegistered) {
        self.status = status
    }

    func register() throws {
        registerCount += 1
        status = registrationStatus
        if registrationFails { throw fixtureError }
    }

    func unregister() async throws {
        unregisterCount += 1
        if suspendsUnregistration {
            await withCheckedContinuation { continuation in
                unregistration = continuation
                unregistrationStarted?.resume()
                unregistrationStarted = nil
            }
        }
        if unregistrationFails { throw fixtureError }
        status = .notRegistered
    }

    func openLoginItemsSettings() {
        openSettingsCount += 1
    }

    func waitForUnregistration() async {
        guard unregisterCount == 0 else { return }
        await withCheckedContinuation { unregistrationStarted = $0 }
    }

    func completeUnregistration() {
        unregistration?.resume()
        unregistration = nil
    }

    private var fixtureError: NSError {
        NSError(
            domain: "LaunchAtLoginFixture",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "sensitive diagnostic"]
        )
    }
}
