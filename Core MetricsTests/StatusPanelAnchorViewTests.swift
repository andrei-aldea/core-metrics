import AppKit
import Testing
@testable import Core_Metrics

@MainActor
@Suite("Status panel anchor")
struct StatusPanelAnchorViewTests {
    @Test("The anchor stays fixed as a right-aligned status button grows and shrinks")
    func selectionWidthChangesPreserveAnchor() {
        let container = NSView(frame: NSRect(x: 0, y: 0, width: 800, height: 24))
        let button = NSStatusBarButton(frame: NSRect(x: 745, y: 0, width: 55, height: 24))
        container.addSubview(button)
        let anchor = StatusPanelAnchorView(frame: .zero)
        anchor.attach(to: button)
        let original = anchor.convert(anchor.bounds, to: container)

        for width: CGFloat in [99, 140, 350, 140, 99, 55] {
            button.frame = NSRect(x: 800 - width, y: 0, width: width, height: 24)
            #expect(anchor.convert(anchor.bounds, to: container) == original)
            #expect(anchor.frame.maxX == button.bounds.maxX)
        }
        // Reopening must reuse the same view, including after geometry changes.
        anchor.attach(to: button)
        #expect(button.subviews.count == 1)
        #expect(anchor.convert(anchor.bounds, to: container) == original)
    }

    @Test("The anchor leaves the right edge clickable and exposes no accessibility element")
    func anchorDoesNotInterceptInteraction() {
        let button = NSStatusBarButton(frame: NSRect(x: 0, y: 0, width: 55, height: 24))
        let anchor = StatusPanelAnchorView(frame: .zero)
        anchor.attach(to: button)
        let point = NSPoint(x: button.bounds.maxX - 0.5, y: button.bounds.midY)

        #expect(anchor.frame.contains(point))
        #expect(anchor.hitTest(point) == nil)
        #expect(button.hitTest(point) === button)
        #expect(!anchor.isAccessibilityElement())
    }
}
