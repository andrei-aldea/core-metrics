<p align="center"><img src="docs/assets/Core-Metrics-AppIcon-Master.png" width="128" height="128" alt="Core Metrics app icon"></p>

# Core Metrics

Core Metrics is a native macOS menu-bar utility for aggregate CPU, memory, and startup-volume usage. Select one to seven statistics in a persistent status panel or Settings. The native status item reserves space for the chosen configuration and updates its text as readings change; Settings provides a scrollable preview of the full selection. macOS controls the available menu-bar space. There are no charts or retained metric history.

The app is local-only, sandboxed, and has no accounts, networking, tracking, analytics, purchases, or third-party dependencies. It is under development and is not ready for App Store submission yet.

## Requirements and targets

- macOS **27.0 or later** on a compatible **Apple silicon Mac**. Apple's [macOS 27 compatibility list](https://www.apple.com/os/macos/) excludes Intel Macs. There is no iPhone, iPad, Catalyst, widget, or extension target.
- Xcode **27** with the macOS 27 SDK. The current release-validation environment is Xcode 27.0 RC (`27A266a`), Apple Swift 6.4, on Apple silicon.
- Swift **6 language mode**, complete strict concurrency, and MainActor default isolation for the app. SwiftUI, AppKit, Core Text, Foundation, Observation, OSLog, ServiceManagement, Accessibility, and public Darwin APIs supply all functionality.
- Project: `Core Metrics.xcodeproj`. Targets: `Core Metrics`, `Core MetricsTests` (Swift Testing), and `Core MetricsUITests` (XCTest).
- Shared schemes: `Core Metrics` for build/run/unit tests and `Core Metrics UI Tests` for interactive UI tests. Configurations: Debug and Release; there is no staging configuration.

The macOS minimum and publisher configuration must not be changed as incidental cleanup. Apple accepts Xcode 27 RC (`27A266a`) and its macOS 27 RC SDK for App Store and TestFlight as of September 9. The RC is installed alongside the earlier beta; use a per-command `DEVELOPER_DIR` override to select it without changing the machine-wide setting. See the [release guidance](docs/APP_STORE.md#current-release-requirements).

## Setup, build, and launch

Clone your repository checkout, enter its root, and open `Core Metrics.xcodeproj`. There are no environment files, service credentials, package installations, or code-generation steps. Dependency resolution is a no-op today:

```sh
xcodebuild -list -project "Core Metrics.xcodeproj"
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics" -resolvePackageDependencies
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics" -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO build
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics" -configuration Release -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO build
```

Unsigned builds validate compilation. For interactive development, select `Core Metrics` / `My Mac` in Xcode and Run using a local signing configuration. The app appears in the menu bar, not the Dock. Click its live value to select statistics. The panel has one footer row with Settings and the text-only Copy Readings button together, followed by Quit at the trailing edge. Menu Bar Text is configured only in Settings, directly below Live Preview. The Settings button requests app activation before opening or raising the native Settings scene. Settings also contains Metric Help. Copy Readings copies full selected names and current values, regardless of menu-bar space; its label becomes Copied on success without moving the neighboring buttons. Launch at Login is optional and off until you enable it in Settings; macOS manages its registration. If menu-bar space hides a long selection, open the already-running app again in Finder to bring up Settings, then choose Compact or fewer readings.

Only menu-bar preferences are persisted in app-scoped UserDefaults. Existing preference schemas migrate on read. Debug enables debugging/testability; Release enables optimization, dead-code stripping, and compact asset processing. Both source configurations enable sandboxing, hardened runtime, and strict compiler checks. Xcode resolves hardened runtime as off for the current Debug development build and on for Release; the final distribution signature still needs verification. Signing identities and publisher credentials belong outside the public repository.

## Tests and checks

```sh
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics" -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO test
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics" -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO analyze
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics UI Tests" -destination 'platform=macOS' CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=YES test
```

Twelve UI tests use local ad-hoc signing, require an interactive desktop and existing automation permissions, and are separate from repeatable unsigned unit tests. All initially launch with one Values Only statistic in a dedicated test preference suite. The broad light flow keeps that selection; the broad dark flow selects seven through the native panel, then relaunches with those saved test preferences and checks that the status item opens the panel. These flows also cover label updates, Settings-only representation, initial Settings activation before any modal appears, click/keyboard reopening, accessibility text, Privacy, Metric Help in Settings, login toggling, and copy success/failure. A separate dark single-stat flow checks copy-error recovery, and a focused shortcut test checks Command-comma. A deterministic CPU fixture alternates 9% and 100% across six observed publications and checks the actual status-item width and screen position before opening its panel, dismissing with Escape and reopening it. A separate async reopen test uses public NSWorkspace to open the already-running app, verifies its process is unchanged, and requires usable foreground Settings. The content-width regression checks the actual 580-point Settings window and all four display choices plus help/privacy/support controls. An outside-click regression checks dismissal through a real Finder Dock click and a same-app Settings title-bar click, then verifies reopening, persistent interior toggling and Escape. A status-item regression repeats three open/close cycles by clicking the readings themselves, including after changing to three metrics inside the panel. It also requires that closing the panel does not open Settings. Footer checks cover the single action row and stable text-only Copy Readings/Copied button. A focused Settings regression test switches to Label and Value, adds Memory Used and Storage Free, and checks all three status names, width growth when adding the third reading, and selections after closing and reopening Settings. DEBUG-only launch controls isolate preferences and app appearance, leaving normal preferences and system appearance unchanged. The position fixture and the light/dark display-mode fixtures substitute CPU readings; other UI scenarios keep live metric providers. Each new mode fixture checks all four modes with three categories, unchanged native frames across 9%/100% transitions, complete preview/accessibility context and persisted Icon and Value relaunch. Login service and clipboard writes use DEBUG-only substitutes, so automated UI tests do not change actual login items or the general clipboard; final results are recorded in the [report](docs/PROJECT_ANALYSIS_REPORT.md).

Run `./scripts/validate.sh` for the complete local build, unit-test, analysis, and packaging checks, or `./scripts/validate.sh --ui` to include interactive desktop tests. Logs and artifacts stay outside the repository. This validates build packaging; it does not create a distribution archive or publish anything.

There is no configured SwiftLint, formatter, snapshot suite, CI workflow, or performance suite. Do not weaken checks or introduce a formatter dependency just to satisfy a generic checklist.

For UI changes, verify the running status item, panel and Settings, immediate preference updates, keyboard focus, VoiceOver, light/dark appearances, accessibility display settings, large text, and constrained menu-bar space. The September 12 source uses the same 12-point size in all four modes and a native 580-point Settings width. The Xcode 27 RC review passed Debug/Release builds, 71 unit-test declarations with 171 executions, all 12 desktop tests, analysis and artifact checks. Earlier reproduced beta failures, remaining build/runtime diagnostics and display/accessibility limits are recorded in the [production-readiness report](docs/PROJECT_ANALYSIS_REPORT.md#production-readiness-review--september-12-2026). The installed local Release was rebuilt with the RC and updated; real Launch at Login registration remained enabled across an app relaunch and that update. A full logout/login cycle remains separate. See the [development runbook](docs/DEVELOPMENT.md) for reproduction.

## Metrics and architecture

| Category | Choices |
| --- | --- |
| CPU | CPU Used, CPU User, CPU System, CPU Idle (percentages) |
| Memory | Memory Used, Memory Used (%), Wired Memory, Compressed Memory, Cached Files, Swap Used, Physical Memory |
| Storage | Storage Used, Storage Used (%), Storage Free, Storage Total for the startup volume |

Providers acquire raw aggregate values off the main actor; pure calculators validate them; `MetricsStore` publishes current snapshots; views format the selected values. CPU/memory refresh about every two seconds, storage every 30 seconds with faster retries after failure. An unavailable reading clears the live value and displays an em dash. The app saves no metric history and makes no network requests. An explicit copy action writes selected readings to the macOS clipboard; macOS may share clipboard contents through Universal Clipboard when enabled.

AppKit owns an `NSStatusItem` with an explicit positive width derived from the selected stats, mode and locale. Live samples update its native attributed button title without recomputing that width. A public transient `NSPopover` hosts the SwiftUI selection panel; after successful presentation, the app activates and makes its owned popover content window key so outside clicks dismiss it natively; Settings remains a native SwiftUI scene registered through `NSHostingSceneRepresentation`. The status item and Settings preview share the same attributed title. Labels/separators use the system font and values use its tabular-digit variant. Label and Value, Compact, Icon and Value, and Values Only all use the same 12-point native size for labels and values. Compact changes only the labels to their short codes. Icon and Value uses a native category SF Symbol before each value; Values Only works with any selection count. Shared point columns cached per locale reserve complete percentages, byte values and Unavailable. Candidate strings and the visual percent-gap strategy are prepared once per locale. A leading space with measured kerning aligns each value, and a locale-cached visual-boundary check adds a two-point percent gap to one visible character where needed, preserving locale spaces, symbol order and bidirectional marks. The preview explicitly converts fonts, kerning and symbol attachments with their baseline offsets to SwiftUI. All modes place two spaces between stats. Invisible direction anchors keep unlabeled stats ordered in bidirectional locales. There is no bitmap renderer or artificial width cap. The previous 11-point Compact measurements are historical; validation of the shared-size modes is recorded in the report. Fixed allocation does not guarantee space on every desktop. See [ADR-021](docs/DECISIONS.md#adr-021--share-native-sizing-across-four-display-modes).

```text
Core Metrics/Core_MetricsApp.swift   AppKit entry point
Core Metrics/Application/           App/store lifetime, native status item, sampling and login state
Core Metrics/Metrics/               Providers, raw counters, pure calculators
Core Metrics/Models/                Immutable metric snapshots
Core Metrics/Preferences/           Validated configuration and persistence
Core Metrics/Utilities/             Shared metric/status formatting
Core Metrics/Views/                 Hosted panel, native popover, shared presentation, Settings
Core MetricsTests/                  Swift Testing unit/provider fixtures
Core MetricsUITests/                Native desktop UI automation
docs/                              Product, engineering and release guidance
```

## Privacy, release, and maintenance

Core Metrics uses documented public Apple APIs and the App Sandbox entitlement. The privacy manifest declares disk-space display and app-only UserDefaults access, with no tracking or collected data. Settings → Privacy explains aggregate readings, saved preferences, the absence of network connections, and local diagnostic messages. Logging contains only metric-category failure/recovery transitions. Fan control, process inspection, file scanning, cleaning, privileged helpers, private APIs, and cloud features are outside product scope.

A publisher-controlled bundle identity and signing setup, finalized public privacy policy, completed metadata/screenshots and signed distribution-archive validation are still required. The native Privacy sheet supplies factual app information; final publisher policy and App Store requirements still need review. See [App Store and privacy preparation](docs/APP_STORE.md); repository checks cannot guarantee approval.

No simulator is needed for this macOS target. Do not erase simulators or delete installed runtimes because this app does not use them. Inventory Xcode caches before cleanup, retain archives/dSYMs/signing material, and remove only verified stale reproducible artifacts. Cache deletion makes the next build slower.

If builds fail, check `xcode-select -p`, `xcodebuild -version`, and `xcrun swift --version`, then choose a compatible local Xcode without altering project signing. If UI automation fails, distinguish desktop/signing permissions from app defects. A missing Dock icon is intentional. Initial launch presents the status item; reopening the already-running app in Finder opens Settings even if the status item has too little room. Detailed troubleshooting is in the [development runbook](docs/DEVELOPMENT.md).

## Documentation

- [Architecture](docs/ARCHITECTURE.md) and [decisions](docs/DECISIONS.md)
- [Metric definitions](docs/METRICS.md) and [design/accessibility](docs/DESIGN.md)
- [Development, testing, and Xcode maintenance](docs/DEVELOPMENT.md)
- [App Store, manual privacy/security review, and release](docs/APP_STORE.md)
- [Icon provenance](docs/ICON.md)
- [Remediation report and validation evidence](docs/PROJECT_ANALYSIS_REPORT.md)
- [Contributing](CONTRIBUTING.md) and [agent instructions](AGENTS.md)

## License

No license has been selected yet. The source is publicly visible, but no permission to copy, modify, or redistribute it is granted unless a license is added later.
