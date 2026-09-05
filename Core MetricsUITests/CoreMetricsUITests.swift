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
    func testAddingThirdStatInSettingsKeepsFullStatusText() throws {
        terminateExistingApplicationInstances()

        let app = XCUIApplication()
        app.launchEnvironment = [
            "CORE_METRICS_UI_TESTING": "1",
            "CORE_METRICS_UI_APPEARANCE": "light",
        ]
        app.launch()
        defer { app.terminate() }

        let statusItem = app.statusItems.firstMatch
        guard statusItem.waitForExistence(timeout: 5) else {
            XCTFail("The status item should be available before adding readings")
            return
        }
        let panel = app.descendants(matching: .any)["menuBarPanel"]
        statusItem.click()
        if !panel.waitForExistence(timeout: 5) {
            statusItem.click()
        }
        guard panel.waitForExistence(timeout: 5) else {
            XCTFail("The status panel should open before adding readings")
            return
        }

        app.buttons["menuBar.settings"].click()
        let settingsWindow = app.windows["com_apple_SwiftUI_Settings_window"]
        guard settingsWindow.waitForExistence(timeout: 5) else {
            XCTFail("Settings should open for adding readings")
            return
        }
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
        let displayMode = settingsWindow.radioButtons["Label and Value"]
        reveal(displayMode, in: settingsWindow.scrollViews.firstMatch)
        displayMode.click()

        addStat("Memory Used", category: "Memory", in: settingsWindow, app: app)
        XCTAssertTrue(settingsWindow.buttons["Remove Memory Used"].waitForExistence(timeout: 3))
        XCTAssertTrue(statusItem.title.contains("CPU User"))
        XCTAssertTrue(statusItem.title.contains("RAM Used"))
        let twoStatWidth = statusItem.frame.width
        XCTAssertGreaterThan(twoStatWidth, 0)

        addStat("SSD Free Space", category: "Storage", in: settingsWindow, app: app)
        let selectedStorage = settingsWindow.buttons["Remove SSD Free Space"]
        XCTAssertTrue(selectedStorage.waitForExistence(timeout: 3))
        reveal(selectedStorage, in: settingsWindow.scrollViews.firstMatch)
        XCTAssertTrue(statusItem.title.contains("CPU User"))
        XCTAssertTrue(statusItem.title.contains("RAM Used"))
        XCTAssertTrue(statusItem.title.contains("SSD Free"))
        XCTAssertGreaterThan(
            statusItem.frame.width, twoStatWidth,
            "Adding a third reading should expand the status item to include its value"
        )
        let statusScreenshot = XCTAttachment(screenshot: statusItem.screenshot())
        statusScreenshot.name = "Native status text with three readings"
        statusScreenshot.lifetime = .keepAlways
        add(statusScreenshot)

        settingsWindow.typeKey("w", modifierFlags: .command)
        XCTAssertTrue(settingsWindow.waitForNonExistence(timeout: 3))
        statusItem.click()
        guard panel.waitForExistence(timeout: 3) else {
            XCTFail("The panel should remain available after adding three readings")
            return
        }
        let storageCheckbox = app.checkBoxes["menuBarStat.storageAvailable"]
        XCTAssertTrue(isSelected(storageCheckbox))
        app.buttons["menuBar.settings"].click()
        XCTAssertTrue(settingsWindow.waitForExistence(timeout: 5))
        XCTAssertTrue(settingsWindow.buttons["Remove Memory Used"].exists)
        reveal(selectedStorage, in: settingsWindow.scrollViews.firstMatch)
        XCTAssertTrue(selectedStorage.isHittable)
        XCTAssertTrue(statusItem.title.contains("SSD Free"))
        let settingsScreenshot = XCTAttachment(screenshot: settingsWindow.screenshot())
        settingsScreenshot.name = "Reopened Settings with three selected readings"
        settingsScreenshot.lifetime = .keepAlways
        add(settingsScreenshot)
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
            "CORE_METRICS_UI_COPY_FAILURE": appearance == "dark" ? "1" : "0",
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
        // Menu-bar commands must work while another application is active.
        // Finder is only activated; the test does not browse or modify files.
        XCUIApplication(bundleIdentifier: "com.apple.finder").activate()
        XCTAssertTrue(app.wait(for: .runningBackground, timeout: 5))
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

        // Exercise Settings before any About/Help/alert could activate this
        // menu-bar agent and hide an activation defect in the Settings button.
        let settingsWindow = app.windows["com_apple_SwiftUI_Settings_window"]
        app.buttons["menuBar.settings"].click()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
        guard settingsWindow.waitForExistence(timeout: 5) else {
            XCTFail("The first Settings click should open the native Settings window")
            return
        }
        XCTAssertTrue(settingsWindow.isHittable)
        XCTAssertTrue(settingsWindow.radioButtons["Compact"].isHittable)
        settingsWindow.typeKey("w", modifierFlags: .command)
        XCTAssertTrue(settingsWindow.waitForNonExistence(timeout: 3))
        XCUIApplication(bundleIdentifier: "com.apple.finder").activate()
        XCTAssertTrue(app.wait(for: .runningBackground, timeout: 5))
        statusItem.click()
        XCTAssertTrue(panel.waitForExistence(timeout: 3))

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
            app.staticTexts["Menu Bar Text"].exists,
            "Menu Bar Text belongs in Settings, not the selection panel"
        )
        XCTAssertEqual(app.radioButtons.count, 0, "The panel should contain no display-mode selector")
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
        if !statusItem.title.contains("CU") {
            let hierarchy = XCTAttachment(string: app.debugDescription)
            hierarchy.name = "Status accessibility diagnosis"
            hierarchy.lifetime = .keepAlways
            add(hierarchy)
        }
        XCTAssertTrue(statusItem.title.contains("CU"))
        if configuration == "seven-stats" {
            XCTAssertTrue(statusItem.title.contains("MU"))
            XCTAssertTrue(statusItem.title.contains("M%"))
            XCTAssertTrue(statusItem.title.contains("S%"))
        }
        let statusScreenshot = XCTAttachment(screenshot: statusItem.screenshot())
        statusScreenshot.name = "Status label - \(appearance)"
        statusScreenshot.lifetime = .keepAlways
        add(statusScreenshot)
        let panelScreenshot = XCTAttachment(screenshot: panel.screenshot())
        panelScreenshot.name = "Persistent status panel - \(appearance)"
        panelScreenshot.lifetime = .keepAlways
        add(panelScreenshot)

        app.buttons["menuBar.copyCurrentReadings"].click()
        if appearance == "dark" {
            let failure = app.staticTexts["Couldn’t Copy Readings"]
            XCTAssertTrue(failure.waitForExistence(timeout: 3))
            app.buttons["OK"].click()
            XCTAssertTrue(failure.waitForNonExistence(timeout: 3))
        } else {
            XCTAssertTrue(app.staticTexts["menuBar.copyConfirmation"].waitForExistence(timeout: 3))
        }
        XCTAssertTrue(panel.exists)
        let panelWindow = app.windows.containing(.button, identifier: "menuBar.copyCurrentReadings").firstMatch
        if panelWindow.exists {
            let actionsScreenshot = XCTAttachment(screenshot: panelWindow.screenshot())
            actionsScreenshot.name = "Panel actions - \(appearance)"
            actionsScreenshot.lifetime = .keepAlways
            add(actionsScreenshot)
        }

        app.buttons["menuBar.metricHelp"].click()
        try verifyMetricHelp(in: app, appearance: appearance, dismissWithReturn: false)
        XCTAssertTrue(panel.exists)
        XCTAssertTrue(app.buttons["Settings…"].isHittable)

        app.buttons["menuBar.settings"].click()
        XCTAssertTrue(
            app.wait(for: .runningForeground, timeout: 5),
            "Settings must activate the app without test-side assistance"
        )
        XCTAssertTrue(
            app.staticTexts["Live Preview"].waitForExistence(timeout: 5),
            "Settings should expose the live status preview"
        )
        XCTAssertTrue(app.buttons["Restore Defaults"].exists)

        XCTAssertTrue(settingsWindow.exists)
        XCTAssertTrue(settingsWindow.isHittable)
        let preview = app.scrollViews["settings.livePreview"]
        XCTAssertTrue(preview.exists)
        XCTAssertTrue(settingsWindow.staticTexts["Menu Bar Text"].exists)
        XCTAssertTrue(
            settingsWindow.radioButtons["Compact"].isHittable,
            "Display choices should be reachable immediately below the preview"
        )

        if configuration == "single-stat" {
            // Temporarily adding a second stat selects Compact. Value Only is
            // restored here because representation now belongs to Settings.
            let valueOnly = settingsWindow.radioButtons["Value Only"]
            XCTAssertTrue(valueOnly.isHittable)
            valueOnly.click()
        }

        let originalMode = try XCTUnwrap(
            ["Label and Value", "Value Only", "Compact"].first { title in
                let control = app.radioButtons[title]
                return control.exists && isSelected(control)
            },
            "Settings should expose the selected representation"
        )
        let originalWidth = statusItem.frame.width
        let alternateMode = originalMode == "Compact" ? "Label and Value" : "Compact"
        reveal(app.radioButtons[alternateMode], in: settingsWindow.scrollViews.firstMatch)
        app.radioButtons[alternateMode].click()
        let expandedWidth = statusItem.frame.width
        XCTAssertGreaterThan(
            expandedWidth, originalWidth,
            "Showing more descriptive labels should expand the native status item"
        )
        app.radioButtons[originalMode].click()
        XCTAssertTrue(isSelected(app.radioButtons[originalMode]))
        XCTAssertLessThan(statusItem.frame.width, expandedWidth)

        let launchAtLogin = app.checkBoxes["settings.launchAtLogin"]
        reveal(launchAtLogin, in: settingsWindow.scrollViews.firstMatch)
        XCTAssertTrue(launchAtLogin.isEnabled)
        XCTAssertFalse(app.staticTexts["settings.launchAtLoginStatus"].exists)
        launchAtLogin.click()
        XCTAssertTrue(app.staticTexts["settings.launchAtLoginStatus"].waitForExistence(timeout: 3))
        XCTAssertEqual(
            app.staticTexts["settings.launchAtLoginStatus"].label,
            "Core Metrics will open when you log in."
        )
        launchAtLogin.click()
        XCTAssertTrue(app.staticTexts["settings.launchAtLoginStatus"].waitForNonExistence(timeout: 3))

        let helpButton = app.buttons["settings.metricHelp"]
        reveal(helpButton, in: settingsWindow.scrollViews.firstMatch)
        helpButton.click()
        try verifyMetricHelp(in: app, appearance: appearance, dismissWithReturn: true)

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
        privacyContent.scroll(byDeltaX: 0, deltaY: -600)
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
        XCTAssertTrue(isSelected(app.radioButtons[originalMode]))

        let settingsScreenshot = XCTAttachment(screenshot: settingsWindow.screenshot())
        settingsScreenshot.name = "Settings - \(appearance)"
        settingsScreenshot.lifetime = .keepAlways
        add(settingsScreenshot)

        // Close a previously created Settings window and reopen it from the
        // panel. Neither path may call app.activate() to compensate for focus.
        settingsWindow.typeKey("w", modifierFlags: .command)
        XCTAssertTrue(settingsWindow.waitForNonExistence(timeout: 3))
        XCUIApplication(bundleIdentifier: "com.apple.finder").activate()
        XCTAssertTrue(app.wait(for: .runningBackground, timeout: 5))
        statusItem.click()
        XCTAssertTrue(panel.waitForExistence(timeout: 3))
        if configuration == "single-stat" {
            app.buttons["menuBar.settings"].typeKey(",", modifierFlags: .command)
        } else {
            app.buttons["menuBar.settings"].click()
        }
        XCTAssertTrue(settingsWindow.waitForExistence(timeout: 5))
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
        XCTAssertTrue(settingsWindow.isHittable)

        if configuration == "seven-stats" {
            app.terminate()
            app.launchEnvironment["CORE_METRICS_UI_RELAUNCH"] = "1"
            app.launch()
            let restoredStatusItem = app.statusItems.firstMatch
            XCTAssertTrue(restoredStatusItem.waitForExistence(timeout: 5))
            XCTAssertTrue(restoredStatusItem.title.contains("M%"))
            XCTAssertTrue(restoredStatusItem.title.contains("S%"))
            restoredStatusItem.click()
            XCTAssertTrue(panel.waitForExistence(timeout: 5))
        }
    }

    @MainActor
    private func addStat(
        _ name: String,
        category: String,
        in settingsWindow: XCUIElement,
        app: XCUIApplication
    ) {
        let addMenu = settingsWindow.descendants(matching: .any)
            .matching(identifier: "settings.addStat").firstMatch
        reveal(addMenu, in: settingsWindow.scrollViews.firstMatch)
        addMenu.click()

        let categoryItem = app.menuItems[category]
        XCTAssertTrue(categoryItem.waitForExistence(timeout: 3))
        categoryItem.hover()
        let statItem = app.menuItems[name]
        XCTAssertTrue(statItem.waitForExistence(timeout: 3))
        statItem.click()
    }

    @MainActor
    private func isSelected(_ control: XCUIElement) -> Bool {
        control.isSelected
            || (control.value as? String) == "1"
            || (control.value as? NSNumber)?.boolValue == true
    }

    @MainActor
    private func verifyMetricHelp(
        in app: XCUIApplication,
        appearance: String,
        dismissWithReturn: Bool
    ) throws {
        let title = app.staticTexts["metricHelp.title"]
        guard title.waitForExistence(timeout: 3) else {
            XCTFail("Metric Help should expose its accessible title")
            return
        }
        let content = app.scrollViews["metricHelp.content"]
        XCTAssertTrue(content.exists)
        XCTAssertTrue(content.staticTexts["CPU"].firstMatch.isHittable)
        content.scroll(byDeltaX: 0, deltaY: -700)
        XCTAssertTrue(content.staticTexts["Reading Updates"].firstMatch.isHittable)
        let screenshot = XCTAttachment(screenshot: app.sheets.firstMatch.screenshot())
        screenshot.name = "Metric Help - \(appearance) - \(dismissWithReturn ? "Settings" : "Panel")"
        screenshot.lifetime = .keepAlways
        add(screenshot)
        app.sheets.firstMatch.typeKey(dismissWithReturn ? .return : .escape, modifierFlags: [])
        XCTAssertTrue(title.waitForNonExistence(timeout: 3))
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
