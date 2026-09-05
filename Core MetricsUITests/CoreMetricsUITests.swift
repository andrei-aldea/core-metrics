import AppKit
import XCTest

final class CoreMetricsUITests: XCTestCase {
    @MainActor
    func testLightAppearanceWithValueOnly() throws {
        try verifyMenuBarSettingsAndPrivacy(appearance: "light", configuration: "single-stat")
    }

    @MainActor
    func testDarkAppearanceWithSevenStats() throws {
        try verifyMenuBarSettingsAndPrivacy(appearance: "dark", configuration: "seven-stats")
    }

    @MainActor
    private func verifyMenuBarSettingsAndPrivacy(
        appearance: String,
        configuration: String
    ) throws {
        terminateExistingApplicationInstances()

        let app = XCUIApplication()

        app.launchEnvironment = [
            "CORE_METRICS_UI_TESTING": "1",
            "CORE_METRICS_UI_APPEARANCE": appearance,
        ]
        app.launch()
        defer { app.terminate() }

        XCTAssertTrue(
            app.wait(for: .runningBackground, timeout: 5) || app.state == .runningForeground,
            "Core Metrics should remain running as a menu-bar utility"
        )

        let statusItem = app.statusItems.firstMatch
        XCTAssertTrue(
            statusItem.waitForExistence(timeout: 5),
            "The Core Metrics status item should be available"
        )

        let panel = app.descendants(matching: .any)["menuBarPanel"]
        // Menu-bar activation can race the first window/label layout on launch.
        // Retry once only when no panel appeared; never toggle an open panel.
        statusItem.click()
        if !panel.waitForExistence(timeout: 5) {
            statusItem.click()
        }
        guard panel.waitForExistence(timeout: 5) else {
            XCTFail("The status item should open the persistent Core Metrics panel")
            return
        }
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

        let valueOnlyControl = app.radioButtons["Value Only"]
        let wasValueOnly = valueOnlyControl.exists
            && (
                valueOnlyControl.isSelected
                    || (valueOnlyControl.value as? String) == "1"
                    || (valueOnlyControl.value as? NSNumber)?.boolValue == true
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
        if wasValueOnly {
            // Adding a second stat changes Value Only to Compact. Restore the
            // representation as well as the selection used by this UI test.
            XCTAssertTrue(valueOnlyControl.waitForExistence(timeout: 2))
            valueOnlyControl.click()
        }

        if configuration == "seven-stats" {
            // Open the panel with a small status item, then exercise seven
            // selections through UI even on a crowded/notched desktop.
            for identifier in [
                "menuBarStat.cpuTotal", "menuBarStat.cpuSystem", "menuBarStat.cpuIdle",
                "menuBarStat.memoryUsed", "menuBarStat.memoryPercentage",
                "menuBarStat.storagePercentage",
            ] {
                let control = app.checkBoxes[identifier]
                XCTAssertTrue(control.exists)
                control.click()
            }
            XCTAssertTrue(panel.exists)
        }

        XCTAssertEqual(app.checkBoxes["menuBarStat.cpuSystem"].label, "CPU System")
        XCTAssertEqual(
            app.checkBoxes["menuBarStat.memoryPercentage"].label,
            "RAM Used %"
        )
        if !statusItem.title.contains("Core Metrics") {
            let hierarchy = XCTAttachment(string: app.debugDescription)
            hierarchy.name = "Status accessibility diagnosis"
            hierarchy.lifetime = .keepAlways
            add(hierarchy)
        }
        XCTAssertTrue(statusItem.title.contains("Core Metrics"))
        XCTAssertTrue(statusItem.title.contains("CPU"))
        let statusScreenshot = XCTAttachment(screenshot: statusItem.screenshot())
        statusScreenshot.name = "Status label - \(appearance)"
        statusScreenshot.lifetime = .keepAlways
        add(statusScreenshot)
        let panelScreenshot = XCTAttachment(screenshot: panel.screenshot())
        panelScreenshot.name = "Persistent status panel - \(appearance)"
        panelScreenshot.lifetime = .keepAlways
        add(panelScreenshot)

        app.buttons["Settings…"].click()
        app.activate()
        XCTAssertTrue(
            app.staticTexts["Live Preview"].waitForExistence(timeout: 5),
            "Settings should expose the live status preview"
        )
        XCTAssertTrue(app.buttons["Restore Defaults"].exists)

        let settingsWindow = app.windows["com_apple_SwiftUI_Settings_window"]
        XCTAssertTrue(settingsWindow.exists)
        let preview = app.scrollViews["settings.livePreview"]
        XCTAssertTrue(preview.exists)

        let originalMode = try XCTUnwrap(
            ["Label and Value", "Value Only", "Compact"].first { title in
                let control = app.radioButtons[title]
                return control.exists
                    && (
                        control.isSelected
                            || (control.value as? String) == "1"
                            || (control.value as? NSNumber)?.boolValue == true
                    )
            },
            "Settings should expose the selected representation"
        )
        let originalWidth = statusItem.frame.width
        let alternateMode = originalMode == "Compact" ? "Label and Value" : "Compact"
        reveal(app.radioButtons[alternateMode], in: settingsWindow.scrollViews.firstMatch)
        app.radioButtons[alternateMode].click()
        if configuration == "single-stat" {
            XCTAssertNotEqual(
                statusItem.frame.width, originalWidth,
                "Changing representation should immediately resize a short status label"
            )
        } else {
            XCTAssertEqual(statusItem.frame.width, originalWidth, accuracy: 1)
            XCTAssertLessThanOrEqual(statusItem.frame.width, 350)
        }
        app.radioButtons[originalMode].click()
        XCTAssertEqual(statusItem.frame.width, originalWidth, accuracy: 1)

        let privacyButton = app.buttons["settings.privacyInformation"]
        reveal(privacyButton, in: settingsWindow.scrollViews.firstMatch)
        privacyButton.click()
        let privacyTitle = app.staticTexts["privacyInformation.title"]
        guard privacyTitle.waitForExistence(timeout: 3) else {
            XCTFail("Privacy should expose its accessible title")
            return
        }
        XCTAssertTrue(app.staticTexts["Core Metrics works entirely on your Mac."].exists)
        let privacyContent = app.scrollViews["privacyInformation.content"]
        XCTAssertTrue(privacyContent.exists)
        privacyContent.scroll(byDeltaX: 0, deltaY: -300)
        let diagnostics = privacyContent.staticTexts["Local Diagnostics"].firstMatch
        XCTAssertTrue(diagnostics.isHittable)
        let privacyScreenshot = XCTAttachment(screenshot: app.sheets.firstMatch.screenshot())
        privacyScreenshot.name = "Privacy - \(appearance)"
        privacyScreenshot.lifetime = .keepAlways
        add(privacyScreenshot)
        app.sheets.firstMatch.typeKey(.return, modifierFlags: [])
        XCTAssertTrue(privacyTitle.waitForNonExistence(timeout: 3))
        privacyButton.click()
        XCTAssertTrue(privacyTitle.waitForExistence(timeout: 3))
        app.sheets.firstMatch.typeKey(.escape, modifierFlags: [])
        XCTAssertTrue(privacyTitle.waitForNonExistence(timeout: 3))
        XCTAssertEqual(statusItem.frame.width, originalWidth, accuracy: 1)

        let settingsScreenshot = XCTAttachment(screenshot: settingsWindow.screenshot())
        settingsScreenshot.name = "Settings - \(appearance)"
        settingsScreenshot.lifetime = .keepAlways
        add(settingsScreenshot)

        if configuration == "seven-stats" {
            app.terminate()
            app.launchEnvironment["CORE_METRICS_UI_RELAUNCH"] = "1"
            app.launch()
            let restoredStatusItem = app.statusItems.firstMatch
            XCTAssertTrue(restoredStatusItem.waitForExistence(timeout: 5))
            XCTAssertTrue(restoredStatusItem.title.contains("RAM Used %"))
            XCTAssertTrue(restoredStatusItem.title.contains("SSD Used %"))
            XCTAssertLessThanOrEqual(restoredStatusItem.frame.width, 350)
            restoredStatusItem.click()
            XCTAssertTrue(panel.waitForExistence(timeout: 5))
        }
    }

    @MainActor
    private func reveal(_ control: XCUIElement, in scrollView: XCUIElement) {
        for _ in 0..<4 {
            if control.isHittable { return }
            scrollView.scroll(byDeltaX: 0, deltaY: -250)
        }
        XCTAssertTrue(control.isHittable, "Control should become reachable by scrolling")
    }

    @MainActor
    private func terminateExistingApplicationInstances() {
        let bundleIdentifier = "org.example.CoreMetrics"
        var runningApplications = NSRunningApplication.runningApplications(
            withBundleIdentifier: bundleIdentifier
        )

        for application in runningApplications {
            application.terminate()
        }

        let deadline = Date().addingTimeInterval(2)
        while !runningApplications.isEmpty, Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
            runningApplications = NSRunningApplication.runningApplications(
                withBundleIdentifier: bundleIdentifier
            ).filter { !$0.isTerminated }
        }

        for application in runningApplications {
            application.forceTerminate()
        }
    }
}
