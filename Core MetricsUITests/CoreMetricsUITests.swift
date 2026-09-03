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

        let showDashboard = app.buttons["openDashboard"]
        XCTAssertTrue(
            showDashboard.waitForExistence(timeout: 5),
            "The status item should open the persistent Core Metrics panel"
        )
        XCTAssertTrue(
            app.descendants(matching: .any)["menuBarPanel"].exists,
            "The panel should expose stat customization"
        )
        XCTAssertTrue(
            app.checkBoxes["menuBarStat.cpuSystem"].exists,
            "CPU System should be directly selectable without a transient submenu"
        )
        XCTAssertFalse(
            app.staticTexts["Live"].exists,
            "The removed sampling badge should not be present"
        )
        XCTAssertTrue(
            app.buttons["About"].exists,
            "The menu-only app should expose the standard About panel"
        )
        XCTAssertTrue(
            app.buttons["Settings…"].exists,
            "Settings should remain directly available from the status panel"
        )

        let enabledControl = app.checkBoxes.allElementsBoundByIndex.first(
            where: \.isEnabled
        )
        XCTAssertNotNil(enabledControl)
        enabledControl?.click()
        XCTAssertTrue(
            showDashboard.waitForExistence(timeout: 2),
            "Selecting a stat should keep the status panel open"
        )
        enabledControl?.click()

        showDashboard.click()

        let dashboard = app.windows["Core Metrics"]
        XCTAssertTrue(dashboard.waitForExistence(timeout: 5))
        XCTAssertGreaterThanOrEqual(dashboard.frame.width, 540)
        XCTAssertGreaterThanOrEqual(dashboard.frame.height, 460)
        XCTAssertTrue(app.staticTexts["User"].exists)
        XCTAssertTrue(app.staticTexts["System"].exists)
        XCTAssertTrue(app.staticTexts["Idle"].exists)
        XCTAssertTrue(app.staticTexts["Memory Used"].exists)
        XCTAssertTrue(app.staticTexts["Cached Files"].exists)
        XCTAssertTrue(app.staticTexts["Swap Used"].exists)
        XCTAssertTrue(app.staticTexts["Free Space"].exists)
        XCTAssertTrue(app.staticTexts["Used Space"].exists)
        XCTAssertTrue(app.staticTexts["Total Capacity"].exists)
    }
}
