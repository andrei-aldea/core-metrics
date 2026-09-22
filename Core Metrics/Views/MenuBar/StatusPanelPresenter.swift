import AppKit
import SwiftUI

/// Owns the native popover while SwiftUI supplies its selection controls.
@MainActor
final class StatusPanelPresenter: NSObject, NSPopoverDelegate {
    private let popover = NSPopover()
    private let anchorView = StatusPanelAnchorView(frame: .zero)
    private let onClose: @MainActor () -> Void
    private var isClosing = false
    private var positionObservationTask: Task<Void, Never>?
    private var positionedButtonSize: NSSize?

    init(
        openSettings: OpenSettingsAction,
        metricsStore: MetricsStore,
        preferencesStore: PreferencesStore,
        writeToClipboard: @escaping @MainActor (String) -> Bool,
        onClose: @escaping @MainActor () -> Void
    ) {
        self.onClose = onClose
        super.init()

        let content = MenuBarMenuView(
            dismissPanel: { [weak self] in self?.close() },
            openSettings: openSettings,
            writeToClipboard: writeToClipboard
        )
        .environment(metricsStore)
        .environment(preferencesStore)
        .tint(Color.primary)

        let hostingController = NSHostingController(rootView: content)
        hostingController.sizingOptions.insert(.preferredContentSize)
        popover.behavior = .transient
        popover.delegate = self
        popover.contentViewController = hostingController
        // The content retains its existing 420/500-point width and ideal
        // 580-point height; the native Form scrolls within that viewport.
        popover.contentSize = hostingController.sizeThatFits(
            in: NSSize(width: 500, height: 580)
        )
    }

    deinit {
        positionObservationTask?.cancel()
    }

    func show(relativeTo button: NSStatusBarButton) {
        guard !isClosing else {
            onClose()
            return
        }
        positionedButtonSize = button.bounds.size
        anchorView.attach(to: button)
        popover.show(relativeTo: anchorView.bounds, of: anchorView, preferredEdge: .minY)
        guard popover.isShown else {
            onClose()
            return
        }
        // The status item can open while this agent is inactive. Give the
        // transient popover native focus so an outside click can dismiss it.
        NSApplication.shared.activate()
        popover.contentViewController?.view.window?.makeKey()
        observePosition(of: button)
    }

    func close() {
        guard popover.isShown, !isClosing else { return }
        isClosing = true
        popover.close()
    }

    private func updatePosition(relativeTo button: NSStatusBarButton) {
        guard popover.isShown, !isClosing,
              positionedButtonSize != button.bounds.size else { return }
        positionedButtonSize = button.bounds.size
        anchorView.attach(to: button)
        popover.show(relativeTo: anchorView.bounds, of: anchorView, preferredEdge: .minY)
    }

    private func observePosition(of button: NSStatusBarButton) {
        positionObservationTask?.cancel()
        guard let window = button.window else { return }
        // A status-item resize and its backing-window move happen separately.
        // Reanchor after the move so the popover does not retain an intermediate
        // screen position from the view's earlier autoresizing notification.
        // Pure window moves need no refresh: AppKit already tracks the anchor.
        let moves = NotificationCenter.default.notifications(named: NSWindow.didMoveNotification, object: window)
        positionObservationTask = Task { @MainActor [weak self, weak button] in
            for await _ in moves {
                guard !Task.isCancelled, let button else { return }
                self?.updatePosition(relativeTo: button)
            }
        }
    }

    func popoverWillClose(_ notification: Notification) {
        isClosing = true
        positionObservationTask?.cancel()
        positionObservationTask = nil
    }

    func popoverDidClose(_ notification: Notification) {
        // Ending the status session can synchronously call close() again.
        // Keep the guard through that callback, including native dismissals.
        defer { isClosing = false }
        onClose()
    }
}
