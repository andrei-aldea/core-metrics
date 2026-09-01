import XCTest

final class CoreMetricsUITests: XCTestCase {
    @MainActor
    func testMenuBarAppLaunches() {
        let app = XCUIApplication()

        app.launch()

        XCTAssertTrue(
            app.wait(for: .runningBackground, timeout: 5) || app.state == .runningForeground,
            "Core Metrics should remain running as a menu-bar utility"
        )
    }
}
