import Foundation
import Observation

/// Reflects macOS's setting without registering at initialization or persisting
/// a second copy of the setting in app preferences.
@MainActor
@Observable
final class LaunchAtLoginStore {
    private(set) var status: LaunchAtLoginStatus
    private(set) var isUpdating = false
    private(set) var errorMessage: String?

    @ObservationIgnored private let service: any LaunchAtLoginServicing
    @ObservationIgnored private var operation: Task<Void, Never>?

    init(service: any LaunchAtLoginServicing = MainAppLoginService()) {
        self.service = service
        status = service.status
    }

    deinit {
        operation?.cancel()
    }

    /// Approval is a registered request, but macOS will not launch the app
    /// until the user approves it. The Settings section displays that state.
    var isRegistered: Bool {
        status == .enabled || status == .requiresApproval
    }

    var canChangeRegistration: Bool {
        status != .notFound && status != .unknown && !isUpdating
    }

    func refresh() {
        let updatedStatus = service.status
        if updatedStatus != status {
            errorMessage = nil
            status = updatedStatus
        }
    }

    /// Returns the owned operation so tests or other callers can await it.
    /// Cancellation before dispatch avoids a change. Once macOS receives an
    /// operation, cancellation cannot undo it; its resulting state is reread.
    @discardableResult
    func setEnabled(_ enabled: Bool) -> Task<Void, Never>? {
        guard !isUpdating else { return operation }

        refresh()
        errorMessage = nil
        guard canChangeRegistration, enabled != isRegistered else { return nil }

        isUpdating = true
        let service = service
        operation = Task { [weak self, service] in
            guard !Task.isCancelled else {
                self?.finishUpdate(requestedEnabled: enabled, failed: false)
                return
            }

            let failed: Bool
            do {
                if enabled {
                    try service.register()
                } else {
                    try await service.unregister()
                }
                failed = false
            } catch {
                failed = true
            }

            self?.finishUpdate(requestedEnabled: enabled, failed: failed)
        }
        return operation
    }

    func openLoginItemsSettings() {
        service.openLoginItemsSettings()
    }

    private func finishUpdate(requestedEnabled: Bool, failed: Bool) {
        refresh()
        isUpdating = false
        operation = nil

        // A denied registration can still create a request requiring approval.
        // The explicit approval UI explains that state without leaking NSError
        // descriptions, which may contain app paths or signing details.
        let reachedRequestedState = requestedEnabled
            ? isRegistered
            : status == .notRegistered
        if failed, !reachedRequestedState {
            errorMessage = requestedEnabled
                ? String(localized: "macOS couldn’t enable Launch at Login. Try again or check Login Items in System Settings.")
                : String(localized: "macOS couldn’t turn off Launch at Login. Try again or check Login Items in System Settings.")
        }
    }
}
