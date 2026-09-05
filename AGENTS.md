# Core Metrics Agent Guide

These rules apply repository-wide. This is the canonical instruction file; no nested or assistant-specific guidance is currently needed.

## Product and platform

Core Metrics is a small native macOS menu-bar utility for aggregate CPU, memory, and startup-volume storage. Its `MenuBarExtra` window is a persistent selection panel; live values appear in the status label and Settings preview. It retains no metric history.

- macOS 27.0 minimum, Xcode 27/macOS 27 SDK; verified locally with Xcode 27.0 beta 6 (`27A5252f`), Swift 6.4 compiler.
- Swift 6 language mode, complete strict concurrency, MainActor app default isolation, approachable concurrency enabled.
- Entry point: `Core Metrics.xcodeproj`; shared schemes: `Core Metrics` and `Core Metrics UI Tests`.
- Targets: `Core Metrics`, `Core MetricsTests`, `Core MetricsUITests`; configurations: Debug and Release.
- No iOS/iPadOS/Catalyst target, extensions, packages, dependency manager, generated source pipeline, configured linter, or CI workflow.

Do not expand into an optimizer or Activity Monitor replacement. Fan control, SMC/private APIs, temperature probing, privileged helpers, daemons, kernel extensions, cleaning, process inspection/killing, file scanning, malware features, hardware tuning, battery/network monitoring, cloud features, accounts, analytics, ads, subscriptions, and purchases are out of scope.

## Architecture and ownership

- `Core Metrics/Core_MetricsApp.swift`: scene composition and state ownership.
- `Core Metrics/Application`: main-actor observable sampling state, task ownership and cancellation.
- `Core Metrics/Metrics`: thin injectable providers, raw counters and pure calculators. Keep Mach and volume code here.
- `Core Metrics/Models`: immutable Sendable metric snapshots.
- `Core Metrics/Preferences`: validated configuration, compatibility decoding, app-only UserDefaults persistence.
- `Core Metrics/Utilities`: centralized locale-aware metric and status-text formatting.
- `Core Metrics/Views`: native status label and locale-aware layout, persistent selection panel, and Settings.
- `Core MetricsTests`: Swift Testing fixtures; `Core MetricsUITests`: XCTest desktop flows.

Keep acquisition off the main actor, UI state on the main actor, and pure calculations nonisolated and testable. Prefer structured child tasks and explicit ownership; cancel owned work and reject obsolete results after stop/restart. Never add broad `@unchecked Sendable`, unsafe isolation, blocking waits, or warning suppression to evade diagnostics. Preserve weak task captures so sampling cannot retain its store indefinitely.

Use native scene navigation and SettingsLink. No coordinator or dependency container is needed for these surfaces. Preserve provider injection and migration schemas. Failures clear stale metric values and retry; a failed swap read must not discard valid physical-memory values. Log only category/state transitions, never raw samples, paths, machine identity or user information.

## API, privacy, signing, and repository hygiene

Mac App Store compatibility and App Sandbox are requirements. Use documented public Apple APIs and verify important system APIs against official Apple sources. Keep hardened runtime and least-privilege entitlements. Recheck Apple's current Required Reason API policy when adopting a covered API; declarations must describe actual use.

The app is local-only: no networking, tracking, analytics, accounts, telemetry or backend. Persist only menu-bar preferences. No Keychain or sensitive-data storage is needed. Never add root access, a private framework, or an undocumented system behavior.

Do not start, invoke, suggest, or switch into a Codex Security Scan or dedicated security-scanning workflow. Manual source/privacy review and local Xcode analysis are permitted; do not upload repository data to external scanners.

Do not automatically change bundle identifiers, signing identities, teams, provisioning, certificates, production entitlements, deployment targets, or publisher accounts. Never expose personal names, emails, usernames, home paths, device identifiers, credentials, private URLs, signing data, keychain contents, or tokens. Keep the existing neutral placeholder identity until an explicitly authorized release configuration.

Keep Xcode user state, build output, result bundles, dSYMs, archives, secrets, and local tooling ignored. Do not commit generated files merely because Xcode created them. If dependencies are added after explicit review, reconsider lockfile policy and document exact resolution steps.

## Design, resources, and accessibility

Follow [docs/DESIGN.md](docs/DESIGN.md) and current Apple Human Interface Guidelines. Preserve visual identity, native controls, semantic colors, system typography, SF Symbols, monospaced live values, and platform-owned materials. No decorative blur stacks or charts. macOS 27 is the existing minimum; do not add imaginary older-platform support.

Support keyboard traversal, VoiceOver labels/values, light/dark appearance, Increased Contrast, Reduce Motion, Reduce Transparency, and Differentiate Without Color. Never convey information solely by color. Keep full metric context in spoken labels, concise hints, and localization-ready text. Do not fabricate translations. Verify long text and constrained status-item width in the running app.

Before removing a symbol or resource, check runtime/asset references, target membership, migration decoding, tests, accessibility identifiers, and documentation. Retain icon size variants and legacy preference decoding even when a simple text search finds few references. Preserve licenses, copyright and legal notices.

## Validation and development commands

```sh
xcodebuild -list -project "Core Metrics.xcodeproj"
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics" -resolvePackageDependencies
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics" -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO build
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics" -configuration Release -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO build
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics" -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO test
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics" -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO analyze
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics UI Tests" -destination 'platform=macOS' CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=YES test
git diff --check
```

Dependency resolution currently finds no packages. UI tests require a signed local app, interactive desktop, and automation permissions. See [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) for isolated build directories, diagnostics and troubleshooting. Treat warnings, concurrency diagnostics, sandbox errors, and privacy-manifest diagnostics as defects; report toolchain limitations accurately instead of suppressing them.

For UI work, run from Xcode, locate the status item, open its panel and Settings, change preferences and confirm immediate label updates. Inspect light/dark appearance, focus, spoken labels, large text, width stability, clipping and accessibility display options. A successful build or preview alone is insufficient. Add meaningful regression tests for correctness changes; do not add tests that merely restate trivial implementation.

## Environment cleanup and completion

Inventory before cleanup. No simulator is required for this Mac app, but other projects may need installed runtimes/devices. Only remove confirmed unavailable devices with supported `simctl` behavior or verified stale reproducible caches. Never erase all simulators, delete active devices, archives, potentially needed dSYMs, current device support, certificates, profiles, credentials, or keychain entries. Keep uncertain candidates and report them. Cache deletion increases the next build's duration; record exact recovered bytes and revalidate.

Update README/runbooks when setup or behavior changes, `docs/METRICS.md` when formulas change, and `docs/DECISIONS.md` for architectural decisions. Keep [docs/PROJECT_ANALYSIS_REPORT.md](docs/PROJECT_ANALYSIS_REPORT.md) aligned with this remediation's final diff, measurements, failures and limitations. Do a second repository-wide review before declaring completion.

Do not commit, push, publish, archive for distribution, upload, rewrite history, or discard unrelated work unless explicitly requested. Before an authorized commit, inspect working and staged diffs, search staged content for personal/signing/secret data, build and run relevant tests, and ensure one coherent change. Prefer descriptive messages such as `fix(metrics): reject cancelled samples`.
