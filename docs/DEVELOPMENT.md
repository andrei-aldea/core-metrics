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

## Configuration and build

The project has Debug and Release configurations. Debug enables testability and ordinary diagnostics. Release uses optimization, dSYMs, dead-code stripping, and asset space optimization. Both keep Swift warnings as errors, complete concurrency checks, App Sandbox and hardened runtime. The generated Info.plist declares a menu-bar agent (`LSUIElement`), Utilities category, AppIcon, version 1.0/build 1, and no non-exempt encryption.

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

Swift Testing covers pure CPU/memory/storage arithmetic, zero/overflow inputs, preference migration/invariants, byte/percent formatting, failure/recovery, store lifetime, cancellation and URL cache invalidation. A volume fixture reads aggregate capacity for `/`; it does not scan files. UserDefaults fixtures create unique test suites. The UI scheme uses XCTest and a local ad-hoc signature in an interactive desktop session; it is deliberately excluded from the main unit-test build action.

Two native UI tests are defined: light appearance with one Value Only statistic, and dark appearance with seven statistics. Both initially launch with one Value Only statistic; the dark test selects seven through the open native panel, then relaunches and checks that the saved selection can open the panel. `UITestLaunchConfiguration` is compiled only in DEBUG and activates only when `CORE_METRICS_UI_TESTING=1`. The initial launch resets a dedicated UI-test UserDefaults suite; `CORE_METRICS_UI_RELAUNCH=1` preserves that suite for the relaunch check. `CORE_METRICS_UI_APPEARANCE` selects the app's light/dark appearance. Normal preferences and system appearance are not changed; ordinary development launches use the normal configuration, and Release excludes these controls.

Each flow terminates earlier instances of the app's current bundle identity before launch, opens the persistent panel, checks accessible controls, toggles/restores a selection and representation, and opens Settings. Representation checks expect short labels to resize and long labels to stay within the width cap. Both flows open Privacy, check the local-data explanation, and exercise Return/Escape dismissal. Screenshots target the status item, panel, Settings window and Privacy sheet. The tests terminate their launched app on exit. Close work in the app before running them; the existing duplicate-instance cleanup can close a normal development instance.

`MenuBarStatusLabel` retains the native `MenuBarExtra` and renders the text into an in-memory `CGImage` with SwiftUI `ImageRenderer`. Its fixed content width is capped at 320 points, with tail ellipsis for longer text; the template image uses the system tint and display scale. The full text remains in the scrollable Settings preview, and the image's intrinsic accessibility label carries the full spoken summary. The native status frame also includes system padding. The seven-stat relaunch check exercises startup with saved selections on this desktop; testing across other crowded/notched displays remains release work. Finite element screenshots removed the observed screenshot-time infinite-rectangle diagnostics; synthetic keyboard/click diagnostics may still occur.

These are implemented test scenarios, not a claim that every run passed. Final results, including the corrected intrinsic-image accessibility check, and remaining runtime coverage are in the [report](PROJECT_ANALYSIS_REPORT.md). The status accessibility assertions query the native item's `title`, not its `label`. XCTest may expose macOS segmented selection as NSNumber rather than String; account for both when querying controls. Keep accessibility identifiers stable and update the test's application lookup only as part of an authorized identity change.

There is no SwiftLint/formatter configuration, snapshot framework, integration backend, extension/widget suite, CI workflow or established benchmark suite. Do not claim those checks passed. Use focused tests for observed regressions and record tool limitations.

## Running-app checklist

- Run from Xcode; locate the status item and open its persistent panel.
- Toggle statistics repeatedly and verify the panel stays open and the label updates immediately. Check one/seven limits and CPU → Memory → Storage order.
- Open Settings, change representation and selections, confirm preview and status item agree, then restore the original preferences.
- Open Settings → Privacy, review its scrollable local-data information, and confirm Done, Return and Escape dismiss the sheet without changing the status configuration.
- Check About, Quit/relaunch, keyboard traversal, shortcuts and focus. With VoiceOver, verify full metric context, values, disabled controls and unavailable samples.
- Inspect light/dark appearance, Increased Contrast, Reduce Transparency, Reduce Motion, Differentiate Without Color and larger supported text settings. Restore system settings after testing.
- Resize Settings and inspect its full horizontal preview. Check status-label ellipsis, locale digits, seven-selection relaunch, small displays and menu-bar/notch constraints. The 320-point content cap limits width; it cannot reserve space on every crowded menu bar.

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
| No app window/Dock icon | Intentional menu-bar agent. Find the status value and open the panel or Settings. |
| Status value unavailable | CPU needs an initial delta; failed providers retry. Inspect only category transition logs. |
| UI runner cannot launch/control the app | Confirm interactive desktop, local signing, existing automation permissions, and duplicate instances. Do not weaken sandbox/hardened runtime. |
| App Intents metadata extraction skipped | Xcode beta emits a build-tool warning when no AppIntents dependency exists. No documented supported opt-out was established for this target. Record it and recheck stable Xcode; do not add an unused framework or suppress warnings. |
| Build database busy | Avoid concurrent builds using the same DerivedData directory; serialize those operations. |
| Newly added source missing | Project uses filesystem-synchronized groups; check scope/target membership before adding duplicate references. |

Keep logs/result bundles outside tracked source. Redact private data before sharing. Release preparation belongs in [APP_STORE.md](APP_STORE.md).
