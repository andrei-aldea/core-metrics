# Core Metrics

Core Metrics is a focused, privacy-first macOS menu-bar utility for seeing CPU, memory, and startup-disk usage at a glance.

The app is built with Swift and SwiftUI for eventual free distribution through the Mac App Store. It uses public Apple APIs, runs inside the App Sandbox, keeps metric history in memory, and has no account, network service, telemetry, analytics, advertising, or third-party dependency.

## Status

The native MVP is implemented:

- A menu-bar-only `MenuBarExtra` shows an ordered selection of one to three live CPU, memory, and storage values.
- The compact dashboard presents CPU total/user/system/idle with history, the documented Core Metrics memory estimate with history, and startup-volume used/available/total capacity.
- Settings changes metric visibility and order, display mode, memory/storage representation, and restores defaults. Preferences persist in `UserDefaults` and update the status label immediately.
- Metric acquisition, calculations, bounded history, formatting, preferences, and presentation remain separate and have automated tests around their pure behavior.

Current development validation uses Xcode 27.0 beta (build `27A5252f`), Apple Swift 6.4, and the macOS 27 SDK. The app deployment target is macOS 14. This beta toolchain is suitable for development validation only; an App Store archive must use a stable Xcode version supported by App Store Connect at submission time.

## Build and test

```sh
xcodebuild -list -project "Core Metrics.xcodeproj"
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics" -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO build
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics" -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO test
```

Open `Core Metrics.xcodeproj` in Xcode to run and inspect the menu-bar interface.

The shared scheme keeps the repeatable test command focused on unit tests. The UI-test target remains available for targeted smoke testing, while real status-item, dashboard, and Settings verification is performed from the running app in Xcode.

## Privacy

Core Metrics reads local aggregate system counters only. It does not inspect arbitrary processes or files, persist metric history, or transmit data.

If a metric read fails, the current value changes to an unavailable state instead of displaying an old sample as live. Valid chart history remains bounded in memory so it can continue when sampling recovers. Failure and recovery transitions are logged without including metric values or machine-specific details.

## Release status

The MVP is not yet an App Store submission artifact. Before release, the publisher must provide a final app icon, replace the placeholder bundle identifier, configure team and distribution signing locally, publish privacy-policy and support URLs, add an easily accessible in-app privacy-policy link, complete the App Store privacy label and metadata, and validate a signed archive made with a supported stable Xcode. The final archive must retain App Sandbox and hardened runtime while containing no `get-task-allow` entitlement.

Never commit developer team IDs, certificates, provisioning profiles, Apple IDs, personal Git metadata, or machine-specific Xcode data. See [docs/APP_STORE.md](docs/APP_STORE.md) for the full audit and release checklist.

See [AGENTS.md](AGENTS.md) for contributor rules and [docs](docs) for architecture, metric semantics, design, and App Store notes.

## License

A repository license has not yet been selected.
