import AppKit
import SwiftUI

/// Owns the native popover while SwiftUI supplies its selection controls.
@MainActor
final class StatusPanelPresenter: NSObject, NSPopoverDelegate {
    private let popover = NSPopover()
    private let onClose: @MainActor () -> Void
    private var isClosing = false

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

    func show(relativeTo button: NSStatusBarButton) {
        guard !isClosing else {
            onClose()
            return
        }
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        if !popover.isShown {
            onClose()
        }
    }

    func close() {
        guard popover.isShown, !isClosing else { return }
        isClosing = true
        popover.close()
    }

    func popoverWillClose(_ notification: Notification) {
        isClosing = true
    }

    func popoverDidClose(_ notification: Notification) {
        // Ending the status session can synchronously call close() again.
        // Keep the guard through that callback, including native dismissals.
        defer { isClosing = false }
        onClose()
    }
}
