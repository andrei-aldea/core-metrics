# Core Metrics

Core Metrics is a focused, privacy-first macOS menu-bar utility for seeing CPU, memory, and startup-disk usage at a glance.

The app is being built with Swift and SwiftUI for eventual free distribution through the Mac App Store. It uses public Apple APIs, runs inside the App Sandbox, keeps metric history in memory, and has no account, network service, telemetry, analytics, advertising, or third-party dependency.

## Status

Repository and product documentation are in place. The native application, metric providers, menu-bar dashboard, settings, and automated tests are under active development.

## Build and test

After the Xcode project is present:

```sh
xcodebuild -list -project "Core Metrics.xcodeproj"
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics" -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO build
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics" -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO test
```

Open `Core Metrics.xcodeproj` in Xcode to run and inspect the menu-bar interface.

## Privacy

Core Metrics reads local aggregate system counters only. It does not inspect arbitrary processes or files, persist metric history, or transmit data.

Before an App Store release, replace the placeholder bundle identifier with an identifier controlled by the publisher and configure signing locally. Never commit developer team IDs, certificates, provisioning profiles, Apple IDs, or machine-specific Xcode data.

See [AGENTS.md](AGENTS.md) for contributor rules and [docs](docs) for architecture, metric semantics, design, and App Store notes.

## License

A repository license has not yet been selected.
