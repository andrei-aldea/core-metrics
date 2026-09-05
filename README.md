<p align="center"><img src="docs/assets/Core-Metrics-AppIcon-Master.png" width="128" height="128" alt="Core Metrics app icon"></p>

# Core Metrics

Core Metrics is a native macOS menu-bar utility for aggregate CPU, memory, and startup-volume usage. Select one to seven statistics in a persistent status panel or Settings. A native text label presents the full selection, with a scrollable preview in Settings. macOS controls the available menu-bar space. There are no charts or retained metric history.

The app is local-only, sandboxed, and has no accounts, networking, tracking, analytics, purchases, or third-party dependencies. It is under development and is not ready for App Store submission yet.

## Requirements and targets

- macOS **27.0 or later** on a compatible **Apple silicon Mac**. Apple's [macOS 27 compatibility list](https://www.apple.com/os/macos/) excludes Intel Macs. There is no iPhone, iPad, Catalyst, widget, or extension target.
- Xcode **27** with the macOS 27 SDK. The verified environment is Xcode 27.0 beta 6 (`27A5252f`), Apple Swift 6.4, on Apple silicon.
- Swift **6 language mode**, complete strict concurrency, and MainActor default isolation for the app. SwiftUI, AppKit, Foundation, Observation, OSLog, ServiceManagement, Accessibility, and public Darwin APIs supply all functionality.
- Project: `Core Metrics.xcodeproj`. Targets: `Core Metrics`, `Core MetricsTests` (Swift Testing), and `Core MetricsUITests` (XCTest).
- Shared schemes: `Core Metrics` for build/run/unit tests and `Core Metrics UI Tests` for interactive UI tests. Configurations: Debug and Release; there is no staging configuration.

The macOS minimum and publisher configuration must not be changed as incidental cleanup. Release requires a stable toolchain accepted by Apple at submission time.

## Setup, build, and launch

Clone your repository checkout, enter its root, and open `Core Metrics.xcodeproj`. There are no environment files, service credentials, package installations, or code-generation steps. Dependency resolution is a no-op today:

```sh
xcodebuild -list -project "Core Metrics.xcodeproj"
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics" -resolvePackageDependencies
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics" -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO build
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics" -configuration Release -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO build
```

Unsigned builds validate compilation. For interactive development, select `Core Metrics` / `My Mac` in Xcode and Run using a local signing configuration. The app appears in the menu bar, not the Dock. Click its live value to select statistics, open About or Settings, or Quit. Menu Bar Text is configured only in Settings, directly below Live Preview. The Settings button requests app activation before opening or raising the native Settings scene. Metric Help explains the readings. Copy Current Readings copies full selected names and current values, regardless of menu-bar space. Launch at Login is optional and off until you enable it in Settings; macOS manages its registration.

Only menu-bar preferences are persisted in app-scoped UserDefaults. Existing preference schemas migrate on read. Debug enables debugging/testability; Release enables optimization, dead-code stripping, and compact asset processing. Both source configurations enable sandboxing, hardened runtime, and strict compiler checks. Xcode resolves hardened runtime as off for the current Debug development build and on for Release; the final distribution signature still needs verification. Signing identities and publisher credentials belong outside the public repository.

## Tests and checks

```sh
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics" -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO test
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics" -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO analyze
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics UI Tests" -destination 'platform=macOS' CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=YES test
```

Three UI tests use local ad-hoc signing, require an interactive desktop and existing automation permissions, and are separate from repeatable unsigned unit tests. All initially launch with one Value Only statistic in a dedicated test preference suite. The broad light flow keeps that selection; the broad dark flow selects seven through the native panel, then relaunches with those saved test preferences and checks that the status item opens the panel. These flows also cover label updates, Settings-only representation, initial Settings activation before any modal appears, click/keyboard reopening, accessibility text, Privacy, Metric Help, login toggling, and copy success/failure. A focused Settings regression test switches to Label and Value, adds Memory Used and SSD Free Space, and checks all three status names, width growth when adding the third reading, and selections after closing and reopening Settings. DEBUG-only launch controls isolate preferences and app appearance, leaving normal preferences and system appearance unchanged. Login service and clipboard writes use DEBUG-only substitutes, so automated UI tests do not change actual login items or the general clipboard; final results are recorded in the [report](docs/PROJECT_ANALYSIS_REPORT.md).

Run `./scripts/validate.sh` for the complete local build, unit-test, analysis, and packaging checks, or `./scripts/validate.sh --ui` to include interactive desktop tests. Logs and artifacts stay outside the repository. This validates build packaging; it does not create a distribution archive or publish anything.

There is no configured SwiftLint, formatter, snapshot suite, CI workflow, or performance suite. Do not weaken checks or introduce a formatter dependency just to satisfy a generic checklist.

For UI changes, verify the running status item, panel and Settings, immediate preference updates, keyboard focus, VoiceOver, light/dark appearances, accessibility display settings, large text, and constrained menu-bar space. The seven-stat relaunch flow covers the reviewed desktop; the wider crowded/notched display matrix remains release work. See the [development runbook](docs/DEVELOPMENT.md) for exact workflows and limitations.

## Metrics and architecture

| Category | Choices |
| --- | --- |
| CPU | Used, User, System, Idle percentages |
| Memory | Used bytes/percentage, Wired, Compressed, Cached Files, Swap Used, Physical Memory |
| Storage | Used bytes/percentage, Free Space, Total Capacity for `/` |

Providers acquire raw aggregate values off the main actor; pure calculators validate them; `MetricsStore` publishes current snapshots; views format the selected values. CPU/memory refresh about every two seconds, storage every 30 seconds with faster retries after failure. An unavailable reading clears the live value and displays an em dash. The app saves no metric history and makes no network requests. An explicit copy action writes selected readings to the macOS clipboard; macOS may share clipboard contents through Universal Clipboard when enabled.

The native `MenuBarExtra` hosts a single attributed `Text` label, shared with the full Settings preview. Formatting retains padded values and a locale-aware width reservation. The native host may adapt the requested font and width, so fixed on-screen width is not guaranteed. Native text replaces the previous capped bitmap label after a reported font change and hidden selected readings; see [ADR-015](docs/DECISIONS.md#adr-015--restore-native-status-text).

```text
Core Metrics/Core_MetricsApp.swift   Scene composition
Core Metrics/Application/           Sampling lifecycle and login registration state
Core Metrics/Metrics/               Providers, raw counters, pure calculators
Core Metrics/Models/                Immutable metric snapshots
Core Metrics/Preferences/           Validated configuration and persistence
Core Metrics/Utilities/             Shared metric/status formatting
Core Metrics/Views/                 Menu-bar panel, label, Settings
Core MetricsTests/                  Swift Testing unit/provider fixtures
Core MetricsUITests/                Native desktop UI automation
docs/                              Product, engineering and release guidance
```

## Privacy, release, and maintenance

Core Metrics uses documented public Apple APIs and the App Sandbox entitlement. The privacy manifest declares disk-space display and app-only UserDefaults access, with no tracking or collected data. Settings → Privacy explains aggregate readings, saved preferences, the absence of network connections, and local diagnostic messages. Logging contains only metric-category failure/recovery transitions. Fan control, process inspection, file scanning, cleaning, privileged helpers, private APIs, and cloud features are outside product scope.

A publisher-controlled bundle identity, signing setup, stable toolchain validation, public publisher privacy/support pages, policy review, metadata, and signed archive validation are still required. The native Privacy sheet supplies factual app information; final publisher policy and App Store requirements still need review. See [App Store and privacy preparation](docs/APP_STORE.md); repository checks cannot guarantee approval.

No simulator is needed for this macOS target. Do not erase simulators or delete installed runtimes because this app does not use them. Inventory Xcode caches before cleanup, retain archives/dSYMs/signing material, and remove only verified stale reproducible artifacts. Cache deletion makes the next build slower.

If builds fail, check `xcode-select -p`, `xcodebuild -version`, and `xcrun swift --version`, then choose a compatible local Xcode without altering project signing. If UI automation fails, distinguish desktop/signing permissions from app defects. A missing Dock icon is intentional; reopen the app and use its status item. Detailed troubleshooting is in the [development runbook](docs/DEVELOPMENT.md).

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
