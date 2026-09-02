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

        let statusItem = app.statusItems["Core Metrics"]
        XCTAssertTrue(
            statusItem.waitForExistence(timeout: 5),
            "The Core Metrics status item should be available"
        )

        statusItem.click()

        let showDashboard = app.menuItems["Show Core Metrics"]
        XCTAssertTrue(
            showDashboard.waitForExistence(timeout: 5),
            "The status item should open the native Core Metrics menu"
        )
        XCTAssertTrue(
            app.menuItems.matching(
                NSPredicate(format: "label BEGINSWITH %@", "CPU Used —")
            ).firstMatch.exists,
            "The native menu should show the default configured stat"
        )
        XCTAssertFalse(
            app.menuItems["Live"].exists,
            "The removed sampling badge should not be present"
        )
        XCTAssertTrue(
            app.menuItems["About Core Metrics"].exists,
            "The menu-only app should expose the standard About panel"
        )
        XCTAssertTrue(
            app.menuItems["Settings…"].exists,
            "Settings should remain directly available from the status menu"
        )

        showDashboard.click()

        XCTAssertTrue(
            app.windows["Core Metrics"].waitForExistence(timeout: 5),
            "The native menu should open the detailed metrics window"
        )
    }
}
