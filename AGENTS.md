# Core Metrics Agent Guide

These rules apply repository-wide. This is the canonical instruction file; no nested or assistant-specific guidance is currently needed.

## Product and platform

Core Metrics is a small native macOS menu-bar utility for aggregate CPU, memory, and startup-volume storage. An owned `NSStatusItem` displays native text with a fixed allocation for each configuration. Its `NSPopover` contains a selection panel that stays open while choices change; live values also appear in Settings preview. It retains no metric history.

- macOS 27.0 minimum, Xcode 27/macOS 27 SDK; verified locally with Xcode 27.0 beta 6 (`27A5252f`), Swift 6.4 compiler.
- Swift 6 language mode, complete strict concurrency, MainActor app default isolation, approachable concurrency enabled.
- Entry point: `Core Metrics.xcodeproj`; shared schemes: `Core Metrics` and `Core Metrics UI Tests`.
- Targets: `Core Metrics`, `Core MetricsTests`, `Core MetricsUITests`; configurations: Debug and Release.
- No iOS/iPadOS/Catalyst target, extensions, packages, dependency manager, generated source pipeline, configured linter, or CI workflow.

Do not expand into an optimizer or Activity Monitor replacement. Fan control, SMC/private APIs, temperature probing, privileged helpers, daemons, kernel extensions, cleaning, process inspection/killing, file scanning, malware features, hardware tuning, battery/network monitoring, cloud features, accounts, analytics, ads, subscriptions, and purchases are out of scope.

## Architecture and ownership

- `Core Metrics/Core_MetricsApp.swift`: AppKit entry point and application-delegate lifetime.
- `Core Metrics/Application`: app-lifetime stores, sampling and cancellation, native status-item ownership and observation.
- `Core Metrics/Metrics`: thin injectable providers, raw counters and pure calculators. Keep Mach and volume code here.
- `Core Metrics/Models`: immutable Sendable metric snapshots.
- `Core Metrics/Preferences`: validated configuration, compatibility decoding, app-only UserDefaults persistence.
- `Core Metrics/Utilities`: centralized locale-aware metric and status-text formatting.
- `Core Metrics/Views`: shared status presentation and locale-aware layout, hosted selection panel, native popover presenter, Settings preview and Settings scene.
- `Core MetricsTests`: Swift Testing fixtures; `Core MetricsUITests`: XCTest desktop flows.

Keep acquisition off the main actor, UI state on the main actor, and pure calculations nonisolated and testable. Prefer structured child tasks and explicit ownership; cancel owned work and reject obsolete results after stop/restart. Never add broad `@unchecked Sendable`, unsafe isolation, blocking waits, or warning suppression to evade diagnostics. Preserve weak task captures so sampling cannot retain its store indefinitely.

Keep status geometry in `StatusItemController`: readings update `NSStatusBarButton.attributedTitle`, while only selection, mode or locale changes recompute the positive `NSStatusItem.length`. Use system-font labels/separators and `monospacedDigitSystemFont` values at one size per mode: uniform small-system size for all Compact runs (11 points on the reviewed runtime), normal system size for the other modes (13 points). Cache separate point columns for each font size and locale, measured from decorated percentages 0…100 and localized byte-width candidates across all seven suffixes, including Unavailable. Format the candidates and resolve the visual percent-gap strategy once per locale, then measure them for both font sizes. Align each value with one ordinary leading space carrying point kerning; character-count padding does not own native geometry. Resolve the percent/digit visual boundary once per locale using public Core Text glyph positions. Cache whether the visible symbol or first/last numeric character carries the two-point kern, excluding Unicode format marks such as Arabic Letter Mark. Apply it to exactly one visible character only when the locale supplies no whitespace gap; preserve the formatted text, symbol order and bidirectional marks. Share the native attributed title with Settings preview through explicit SwiftUI font and kerning conversion. Compact separates slots with one space, other modes with two. Keep formatting and point-width calculation aligned. Retain the status item strongly and cancel owned observations at shutdown. Use macOS 27's public expanded-interface delegate with the owned popover and `NSHostingSceneRepresentation` for native Settings. Use SettingsLink in SwiftUI scene contexts; the AppKit-hosted panel uses a native Button with an injected `OpenSettingsAction` obtained from the represented scene. Do not copy an entire scene environment into the detached hosting controller. Dismiss the panel before activating Settings. Preserve the public reopen handler: opening an already-running app in Finder opens native Settings so a hidden long status item does not prevent configuration recovery. Do not add private selectors, view introspection or a general-purpose dependency container. Preserve provider injection and migration schemas. Failures clear stale metric values and retry; a failed swap read must not discard valid physical-memory values. Log only category/state transitions, never raw samples, paths, machine identity or user information.

## API, privacy, signing, and repository hygiene

Mac App Store compatibility and App Sandbox are requirements. Use documented public Apple APIs and verify important system APIs against official Apple sources. Keep hardened runtime and least-privilege entitlements. Recheck Apple's current Required Reason API policy when adopting a covered API; declarations must describe actual use.

The app is local-only: no networking, tracking, analytics, accounts, telemetry or backend. Persist only menu-bar preferences. Optional Launch at Login uses public `SMAppService.mainApp` and the actual OS state, with no helper or shadow preference. Copy Current Readings writes only on an explicit action; automated tests must use a named pasteboard or injected writer and fake login service to preserve the person’s clipboard and login items. No Keychain or sensitive-data storage is needed. Never add root access, a private framework, or an undocumented system behavior.

Do not start, invoke, suggest, or switch into a Codex Security Scan or dedicated security-scanning workflow. Manual source/privacy review and local Xcode analysis are permitted; do not upload repository data to external scanners.

Do not automatically change bundle identifiers, signing identities, teams, provisioning, certificates, production entitlements, deployment targets, or publisher accounts. Never expose personal names, emails, usernames, home paths, device identifiers, credentials, private URLs, signing data, keychain contents, or tokens. Keep the existing neutral placeholder identity until an explicitly authorized release configuration.

Keep Xcode user state, build output, result bundles, dSYMs, archives, secrets, and local tooling ignored. Do not commit generated files merely because Xcode created them. If dependencies are added after explicit review, reconsider lockfile policy and document exact resolution steps.

## Design, resources, and accessibility

Follow [docs/DESIGN.md](docs/DESIGN.md) and current Apple Human Interface Guidelines. Preserve visual identity, native controls, semantic colors, system typography, SF Symbols, tabular-digit live values, and platform-owned materials. No decorative blur stacks or charts. macOS 27 is the existing minimum; do not add imaginary older-platform support.

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

For UI work, run from Xcode, locate the status item, open its panel and Settings, change preferences and confirm immediate label updates. Measure actual status-item width and screen position across changing readings with a fixed configuration; separately verify expected resizing after selection/mode/locale changes. Inspect one/three/seven selections, saved-selection startup, already-running app reopen recovery to Settings (covered by the public NSWorkspace/PID-preservation UI fixture), panel dismissal and reopening, light/dark appearance, focus, spoken labels, large text, clipping and accessibility display options. Fixed allocation does not guarantee available menu-bar space, and `NSStatusItem.isVisible` remains true when space temporarily hides the item. A successful build or preview alone is insufficient. Add meaningful regression tests for correctness changes; do not add tests that merely restate trivial implementation.

## Environment cleanup and completion

Inventory before cleanup. No simulator is required for this Mac app, but other projects may need installed runtimes/devices. Only remove confirmed unavailable devices with supported `simctl` behavior or verified stale reproducible caches. Never erase all simulators, delete active devices, archives, potentially needed dSYMs, current device support, certificates, profiles, credentials, or keychain entries. Keep uncertain candidates and report them. Cache deletion increases the next build's duration; record exact recovered bytes and revalidate.

Update README/runbooks when setup or behavior changes, `docs/METRICS.md` when formulas change, and `docs/DECISIONS.md` for architectural decisions. Keep [docs/PROJECT_ANALYSIS_REPORT.md](docs/PROJECT_ANALYSIS_REPORT.md) aligned with this remediation's final diff, measurements, failures and limitations. Do a second repository-wide review before declaring completion.

Do not commit, push, publish, archive for distribution, upload, rewrite history, or discard unrelated work unless explicitly requested. Before an authorized commit, inspect working and staged diffs, search staged content for personal/signing/secret data, build and run relevant tests, and ensure one coherent change. Prefer descriptive messages such as `fix(metrics): reject cancelled samples`.
