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

        let panel = app.descendants(matching: .any)["menuBarPanel"]
        XCTAssertTrue(
            panel.waitForExistence(timeout: 5),
            "The status item should open the persistent Core Metrics panel"
        )
        XCTAssertFalse(app.staticTexts["Selected"].exists)
        XCTAssertTrue(
            app.staticTexts["CPU"].exists,
            "The panel should begin directly with the CPU section"
        )
        XCTAssertTrue(
            app.checkBoxes["menuBarStat.cpuSystem"].exists,
            "CPU System should be directly selectable without a transient submenu"
        )
        for identifier in [
            "menuBarStat.cpuTotal",
            "menuBarStat.memoryPercentage",
            "menuBarStat.memoryWired",
            "menuBarStat.memoryCompressed",
            "menuBarStat.memoryTotal",
            "menuBarStat.storagePercentage",
        ] {
            XCTAssertTrue(
                app.checkBoxes[identifier].exists,
                "The new statistic \(identifier) should appear in its metric section"
            )
        }
        XCTAssertFalse(
            app.staticTexts["Live"].exists,
            "The removed sampling badge should not be present"
        )
        XCTAssertFalse(
            app.staticTexts["Style"].exists,
            "The segmented display control should not repeat a Style label"
        )
        XCTAssertTrue(
            app.staticTexts["Menu Bar Text"].exists,
            "The bare display-mode control should retain its section heading"
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
            panel.waitForExistence(timeout: 2),
            "Selecting a stat should keep the status panel open"
        )
        enabledControl?.click()
    }
}
