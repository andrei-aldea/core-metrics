# Development, testing, and Xcode maintenance

## Toolchain and setup

Open `Core Metrics.xcodeproj` with Xcode 27 and the macOS 27 SDK. The reviewed host runs macOS 27, Xcode 27.0 beta 6 (`27A5252f`), and Apple Swift 6.4. Project sources compile in Swift 6 language mode. No iOS runtime or simulator is required. Apple's [macOS 27 compatibility list](https://www.apple.com/os/macos/) supports Apple silicon Macs only, so Intel hardware execution is outside this project's deployment matrix. Validate the native arm64 app on supported Macs.

Check the active tools before changing anything:

```sh
xcode-select -p
xcodebuild -version
xcrun swift --version
xcodebuild -list -project "Core Metrics.xcodeproj"
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics" -resolvePackageDependencies
```

There are no Swift packages, Pods, Carthage artifacts, environment secrets, backend endpoints, generated sources, or install scripts. Dependency resolution should list no packages. Prefer a per-command `DEVELOPER_DIR` override when testing another installed Xcode; do not change the machine-wide selection or deployment target incidentally.

## One-command validation

From the repository root, run:

```sh
./scripts/validate.sh
./scripts/validate.sh --ui --output-root /tmp
```

The second command includes the native UI suite and needs an interactive desktop with existing automation permissions. Close work in the app first because the UI suite terminates earlier app instances. The script also works from another working directory when invoked through its quoted path. `--help` explains the options without invoking Xcode; `--output-root` accepts an existing directory outside the checkout, including paths with spaces. Each run creates a new private directory under that location, or under `${TMPDIR:-/tmp}` by default, and prints its location.

The script checks macOS 27/Apple silicon, Xcode 27+, the macOS 27+ SDK and Swift 6+, then serially lists the project, resolves dependencies, builds Debug, runs unit tests, builds Release and analyzes. It lints source and packaged property lists, verifies the reviewed sandbox/privacy declarations and packaged metadata against resolved build settings, and checks that Release excludes DEBUG UI-test markers and unexpected nested bundles. Hardened runtime must be enabled in both source app configurations and in resolved Release settings; a resolved Debug value of `NO` is explicitly reported as a development/test limitation. Project, source entitlement and privacy-manifest fingerprints must remain unchanged. Optional ad-hoc UI tests run afterward in separate DerivedData; their app's effective sandbox entitlement is checked. Final working and staged diff checks run even after a failed build step.

`summary.tsv` records executed steps; `outcome.txt` records the overall result and diagnostic counts. Raw logs, resolved build settings, products and `.xcresult` bundles stay in the private run directory. Failed commands/checks stop dependent work and return nonzero. Unexpected warning lines also fail validation; the known AppIntents metadata-skipped warning is retained, counted and reported as an outstanding toolchain limitation. Passing commands do not resolve that warning, DisplayManager diagnostics, distribution signing or the wider runtime matrix. Redact raw local artifacts before sharing them.

The script uses macOS Bash and Swift/Foundation without additional packages. It does not delete artifacts, alter Xcode selection or publisher configuration, create distribution archives, upload, or commit. Existing manual commands below remain useful for focused work; the script's isolated output is the repeatable full-validation path. Use the [report](PROJECT_ANALYSIS_REPORT.md) for actual execution evidence.

## Configuration and build

The project has Debug and Release configurations. Debug enables testability and ordinary diagnostics. Release uses optimization, dSYMs, dead-code stripping, and asset space optimization. Both keep Swift warnings as errors, complete concurrency checks and App Sandbox. Both source app configurations set `ENABLE_HARDENED_RUNTIME=YES`; the reviewed unsigned build settings resolve it to `NO` for Debug and `YES` for Release. This Debug development/test limitation does not establish effective runtime hardening. The project setting remains enabled, Release must resolve to `YES`, and the signed shipping archive still needs effective hardening validation. The generated Info.plist declares a menu-bar agent (`LSUIElement`), Utilities category, AppIcon, version 1.0/build 1, and no non-exempt encryption.

Use an ignored `build/` directory when separate logs/products help reproduce a result:

```sh
mkdir -p build
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics" -destination 'platform=macOS' -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO build
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics" -configuration Release -destination 'platform=macOS' -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO build
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics" -destination 'platform=macOS' -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO analyze
```

On an Apple silicon host, append `,arch=arm64` to the destination to select it explicitly. The repository does not change its standard architecture settings for this convenience. Unsigned builds validate source/resources, not distribution signing or sandbox behavior.

For interactive work, select `Core Metrics` / `My Mac` and Run in Xcode. The current local setup uses “Sign to Run Locally”; publisher signing is a separate release action. Keep identifiers, signing identities, teams and provisioning credentials unchanged unless explicitly authorized.

## Unit and UI tests

```sh
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics" -destination 'platform=macOS' -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO test
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics UI Tests" -destination 'platform=macOS' -derivedDataPath build/UIData CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=YES test
git diff --check
```

Swift Testing covers pure CPU/memory/storage arithmetic, zero/overflow inputs, preference migration/invariants, byte/percent formatting, failure/recovery, store lifetime, cancellation and URL cache invalidation. Percentage formatting coverage checks every integer from 0 through 100 across Foundation's available locales and all display modes against the locale-derived column; focused layout fixtures compare actual glyph widths with the reserved frame. A volume fixture reads aggregate capacity for `/`; it does not scan files. UserDefaults fixtures create unique test suites. The UI scheme uses XCTest and a local ad-hoc signature in an interactive desktop session; it is deliberately excluded from the main unit-test build action.

Seven native UI tests are defined: broad light/Value Only and dark/seven-stat flows, `testAddingThirdStatInSettingsKeepsFullStatusText`, `testSettingsKeyboardShortcutOpensWindowAndDismissesPanel`, `testDarkAppearanceCopyFailureWithSingleStat`, `testStatusItemPositionRemainsStableAcrossLiveCPUValues`, and `testReopeningRunningApplicationOpensSettings`. The copy-failure flow isolates error recovery from long status-item geometry. All initially launch with one Value Only statistic. The dark flow selects seven through the open native panel, then relaunches and checks that the saved selection can open the panel. `UITestLaunchConfiguration` is compiled only in DEBUG and activates only when `CORE_METRICS_UI_TESTING=1`. The initial launch resets a dedicated UI-test UserDefaults suite; `CORE_METRICS_UI_RELAUNCH=1` preserves that suite for the relaunch check. `CORE_METRICS_UI_APPEARANCE` selects the app's light/dark appearance. Normal preferences and system appearance are not changed; ordinary development launches use the normal configuration, and Release excludes these controls.

Each broad flow terminates earlier instances of the app's current bundle identity before launch, activates Finder to put Core Metrics in the background, and opens the persistent panel. It verifies that the display-mode picker is absent and opens Settings before an alert could activate the app. After requiring the panel to disappear and checking foreground/hittable Settings without forcing Core Metrics active from test code, it returns to the panel and toggles/restores a selection. Representation is changed only in Settings. The flows also close and reopen Settings through clicking or Command-comma. Representation checks must verify selected content and native label updates without assuming a fixed maximum width. Footer checks require Settings, Copy Readings and Quit in one row, no panel About/Metric Help, and no copy icon. The copy button retains `menuBar.copyCurrentReadings` while its accessible label changes from Copy Readings to Copied after success; its dimensions must remain stable. The former separate `menuBar.copyConfirmation` element is removed. Both broad flows exercise Metric Help only in Settings, with Return/Escape dismissal, fake Launch at Login toggles, and injected copy success/failure. They open Privacy, check the local-data explanation, and exercise Return/Escape dismissal. Status interactions hover and require a hittable item before clicking; a hidden or overflowing item fails explicitly rather than receiving a blind fallback click. Screenshots target finite status-item, panel/window, Settings and sheet elements. DEBUG test launches inject a fake login service and clipboard writer; they do not change actual login items or the general clipboard. A unit fixture separately writes to a private named pasteboard and releases it afterward. All seven tests terminate their launched app on exit. Close work in the app before running them; the existing duplicate-instance cleanup can close a normal development instance.

The focused Settings test selects Label and Value, adds Memory Used and then Storage Free through Add Stat, and checks that the status title retains CPU User, Memory Used and Storage Free. It compares the two-stat and three-stat frames to verify that the third reading expands the native label instead of being hidden behind the former cap. It then closes Settings, verifies the storage checkbox in the panel, reopens Settings and checks that both added selections remain available. This verifies intentional allocation growth after a configuration change; live-value stability is covered separately.

The position regression uses `CORE_METRICS_UI_ALTERNATING_CPU=1` to inject a DEBUG-only CPU provider, leaving ordinary UI flows on live providers. Process-local language/locale arguments make its expected 9% and 100% labels deterministic. It waits for six actual publications, pairs each title with its AX snapshot frame, and compares finite, nonempty width and x/y position at 0.01-point tolerance. It then opens the panel, confirms the single selection is unchanged, dismisses with Escape and reopens it. It records frame observations as a test attachment. The fixture does not alter the person's preferences, clipboard, login items or system locale.

The async reopen fixture calls public `NSWorkspace.openApplication` for the already-running application bundle. It verifies the returned process identifier matches the existing process, then requires foreground Settings with a hittable Compact control. This covers reopen recovery without substituting a terminate/relaunch.

`StatusItemController` owns a native `NSStatusItem` and sets its positive width from locale-aware layout only after a selection, mode or locale change. Live samples update the native attributed button title. Label prefixes and static separators use the normal system font; padded value runs use the monospaced system font at the same system size (13 points on the reviewed runtime). Width measures static text in its actual font and adds conservative locale-aware value columns. `MenuBarLabelView` supplies only the scrollable Settings preview through shared `StatusItemPresentation` and `MenuBarLabelLayout.attributedTitle`, explicitly converting NSFont runs into SwiftUI font attributes. `StatusPanelPresenter` hosts the SwiftUI controls in a transient native popover, coordinated with macOS 27's expanded-interface session. The hosted panel uses a native Settings Button with an injected `OpenSettingsAction` from the represented scene; it closes the panel before activation and presentation. The AppKit delegate starts sampling at launch and stops observations/presentation and sampling at termination. All percentage columns now reserve `max(4, localized100.count)` characters, byte columns eight; Compact uses a one-space separator and other modes use two. Formatting and layout receive the same locale. The former MenuBarExtra text host, bitmap renderer and 320-point cap are not current presentation paths. Recheck one, three and seven selections, all modes, live frame stability, panel/Settings accessibility and saved-selection startup; available space varies across crowded/notched displays.

All seven NativeVerified UI scenarios passed on the reviewed desktop: three-stat Settings selection, dark copy-error recovery, seven-stat Compact/relaunch, light appearance, already-running app reopen, Settings shortcut, and live geometry with Escape/reopen. The geometry fixture recorded six identical 52-point-wide frames across alternating 9% and 100% values. The final default validator passed Debug/Release builds, 66 unit-test declarations with 142 executions, analysis and artifact checks with zero unexpected warnings; the known AppIntents toolchain warning remains documented. Final measurements and remaining runtime coverage are in the [report](PROJECT_ANALYSIS_REPORT.md). Keep historical image-label, MenuBarExtra Text and earlier AppKit failures distinct from these final results; wider display and assistive-technology review remains required. The native status button receives the combined app-name/metric-summary through its accessibility label and title; inspect the actual exposed attributes. Assert that summary independently of screenshot inspection of rendered abbreviations. Settings preview must expose the same summary. XCTest exposes the native Launch at Login control as a Switch and may expose segmented selection as NSNumber rather than String; account for those native representations when querying controls. Keep accessibility identifiers stable and update the test's application lookup only as part of an authorized identity change.

There is no SwiftLint/formatter configuration, snapshot framework, integration backend, extension/widget suite, CI workflow or established benchmark suite. Do not claim those checks passed. Use focused tests for observed regressions and record tool limitations.

## Running-app checklist

- Run from Xcode; locate the status item and open its persistent panel.
- Toggle statistics repeatedly and verify the panel stays open and the label updates immediately. Check one/seven limits and CPU → Memory → Storage order.
- Open Settings, change representation and selections, confirm preview and status item agree, then restore the original preferences.
- With the app still running, open its application bundle again in Finder and confirm native Settings opens or comes forward. This is the recovery route if a long label is hidden by menu-bar space. The dedicated NSWorkspace UI fixture exercises this reopen event and preserves the process identifier; keep manual Finder recovery in display-matrix review.
- Open Settings → Privacy, review its scrollable local-data information, and confirm Done, Return and Escape dismiss the sheet without changing the status configuration.
- Check the Settings / Copy Readings / Quit footer, stable Copied feedback, Quit/relaunch, keyboard traversal, shortcuts and focus. Open Metric Help from Settings. With VoiceOver, verify copy announcements, full metric context, values, disabled controls and unavailable samples.
- Inspect light/dark appearance, Increased Contrast, Reduce Transparency, Reduce Motion, Differentiate Without Color and larger supported text settings. Restore system settings after testing.
- Resize Settings and inspect its full horizontal preview. Check native status typography, locale digits, complete one/three/seven-stat text, saved-selection relaunch, small displays and menu-bar/notch constraints. Measure width and x/y position across live updates, then verify that selection/mode/locale changes recompute the allocation. macOS controls available space; the app supplies the full string without an artificial width cap.

Use Xcode's Main Thread Checker during these flows. Thread/Address Sanitizers and Instruments are diagnostic tools for relevant defects, not substitutes for correctness tests. Report the actual runtime and sampling conditions for memory/energy observations; do not infer launch speed or leak freedom from a build.

## Safe environment maintenance

Inventory before deletion. Useful read-only commands:

```sh
xcrun simctl list runtimes
xcrun simctl list devices
xcrun simctl list devices unavailable
du -sh ~/Library/Developer/Xcode/DerivedData ~/Library/Developer/Xcode/Archives ~/Library/Developer/Xcode/iOS\ DeviceSupport ~/Library/Caches/org.swift.swiftpm ~/Library/Developer/CoreSimulator
```

Missing directories are normal. Do not publish raw inventory output containing device IDs, names, home paths or other project details. An immediate directory modification date is not proof of last use or staleness.

Only after confirming unavailable devices and their relevance may `xcrun simctl delete unavailable` be used. Never erase all devices or delete available devices/runtimes simply because this Mac project has no simulator target. Preserve runtimes needed by other active projects.

DerivedData/module/package caches are reproducible, but remove only verified stale or faulty project-specific artifacts. Cache deletion increases the next build's duration. Do not delete archives, potentially needed dSYMs, recent device support, signing certificates, provisioning profiles, developer accounts or keychain entries. Keep uncertain items as review candidates and record exact recovered bytes. Recheck tools, required platforms, build/tests and launch after any cleanup.

The September 2026 review found no confirmed stale/corrupt artifacts and removed none. Detailed sanitized sizes and retained categories are in the [report](PROJECT_ANALYSIS_REPORT.md).

## Troubleshooting

| Symptom | Check/action |
| --- | --- |
| macOS SDK or Swift syntax unavailable | Check selected Xcode and macOS 27 SDK; retain deployment target and concurrency settings. |
| Multiple matching Mac destinations | Specify host architecture in the destination; this is not a product defect. |
| No app window/Dock icon | Intentional menu-bar agent. Initial launch shows its status value. Open the already-running app again in Finder to open or raise native Settings. |
| Status value unavailable | CPU needs an initial delta; failed providers retry. Inspect only category transition logs. |
| Status item missing or clipped | Reopen the already-running app in Finder to reach Settings and select Compact or fewer readings. Check actual desktop space, selected mode and glyph fit. A positive allocation does not guarantee enough space, and `NSStatusItem.isVisible` stays true during temporary space-related hiding. Do not treat it as an overflow detector. |
| UI runner cannot launch/control the app | Confirm interactive desktop, local signing, existing automation permissions, and duplicate instances. Do not weaken sandbox/hardened runtime. |
| App Intents metadata extraction skipped | Xcode beta emits a build-tool warning when no AppIntents dependency exists. No documented supported opt-out was established for this target. Record it and recheck stable Xcode; do not add an unused framework or suppress warnings. |
| Build database busy | Avoid concurrent builds using the same DerivedData directory; serialize those operations. |
| Newly added source missing | Project uses filesystem-synchronized groups; check scope/target membership before adding duplicate references. |

Keep logs/result bundles outside tracked source. Redact private data before sharing. Release preparation belongs in [APP_STORE.md](APP_STORE.md).


### UI runner initialization failures

If XCTest reports “Timed out while enabling automation mode” before any test case starts, distinguish runner initialization from a failing app assertion. Retain the `.xcresult` and raw log, check the interactive session and Xcode Helper authorization using [Apple’s UI-testing guidance](https://developer.apple.com/documentation/XCUIAutomation/recording-ui-automation-for-testing), and avoid resetting system permissions or killing other projects’ test services as cleanup. A previously working DerivedData location did not resolve this timeout in the feature follow-up. The default validation command can still verify builds, units and packaged artifacts; it explicitly skips UI tests and cannot replace desktop validation. This is a historical runner failure, not the outcome of the seven passing NativeVerified scenarios; see the report for its context and the final results.
