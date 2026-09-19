import AppKit

/// Supplies popover geometry without intercepting status-button clicks.
@MainActor
final class StatusPanelAnchorView: NSView {
    func attach(to button: NSStatusBarButton) {
        guard superview !== button else { return }
        removeFromSuperview()
        setAccessibilityElement(false)
        autoresizingMask = [.minXMargin, .height]
        // Status items grow to the left. Keep the positioning view at the
        // right edge instead of following the full button's changing center.
        frame = NSRect(
            x: button.bounds.maxX - 1,
            y: button.bounds.minY,
            width: 1,
            height: button.bounds.height
        )
        button.addSubview(self)
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        nil
    }
}
