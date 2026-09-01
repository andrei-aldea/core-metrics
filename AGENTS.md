# Core Metrics Agent Guide

These rules apply to every change in this repository.

## Product scope

Core Metrics is a small native macOS menu-bar utility. Version 1 shows only aggregate CPU, memory, and startup-volume storage information. The menu bar is the primary surface; its popover provides a compact dashboard and Settings controls the small set of supported representations.

Do not turn the product into a general optimizer or Activity Monitor replacement. Fan control, SMC/private APIs, temperature probing, privileged helpers, daemons, kernel extensions, cleaning, process killing or inspection, file scanning, malware features, hardware tuning, battery/network monitoring, cloud features, accounts, analytics, ads, subscriptions, and purchases are out of scope.

## Distribution, API, and privacy rules

- Mac App Store compatibility is a hard requirement.
- Keep App Sandbox enabled and add no entitlement without a documented need.
- Use only documented public Apple APIs. Verify important system APIs in official Apple documentation.
- Never add root access, a privileged helper, a private framework, or an undocumented behavior.
- The app is local-only: no network connection, account, tracking, analytics SDK, advertising, or telemetry.
- Aggregate metric samples remain on the Mac. History is bounded in memory and is not persisted.
- Before adopting a Required Reason API, verify Apple's current policy, add `PrivacyInfo.xcprivacy` only when required, and document the truthful reason.

## Public repository hygiene

Never commit personal names, email addresses, Apple IDs, usernames, home paths, device names, developer team IDs, certificates, provisioning profiles, credentials, tokens, private URLs, or machine identifiers. Use a neutral placeholder bundle identifier until release configuration. Keep `xcuserdata`, DerivedData, build output, secrets, and local tool state ignored.

Before every commit:

1. Inspect `git diff` and the staged diff.
2. Search staged content for absolute home paths, usernames, credentials, signing IDs, and Xcode user data.
3. Build and run relevant tests.
4. Confirm the commit is one coherent, understandable change.

## Native implementation rules

- Use Swift, SwiftUI, Foundation, Swift Charts, SF Symbols, and documented Apple system APIs.
- Do not add a third-party package without a strong written justification and explicit review.
- Keep acquisition, pure calculation, history, app state, preferences, and presentation separated.
- Keep low-level Mach/volume code out of views.
- Prefer dependency injection at provider boundaries; avoid global singleton state.
- Use modern Swift concurrency and observation with clear actor isolation.
- Treat warnings, concurrency diagnostics, deprecations, sandbox issues, and privacy-manifest diagnostics as defects.
- Centralize locale-aware value formatting and avoid fake precision.

## Design and accessibility

Follow `docs/DESIGN.md` and current Apple Human Interface Guidelines. Use semantic colors, system typography, SF Symbols, native controls, stable monospaced digits for live values, restrained charts, and native Liquid Glass only where the platform provides it. Provide a native fallback on older supported macOS versions; never imitate glass with decorative blur stacks.

Support keyboard navigation, VoiceOver labels and values, light/dark appearance, Increased Contrast, Reduce Motion, Reduce Transparency, and Differentiation Without Color. Never communicate a metric solely through color.

## Architecture map

- `Core Metrics/Application`: app lifecycle, composition, and shared observable state.
- `Core Metrics/Metrics`: provider boundaries and CPU/memory/storage acquisition.
- `Core Metrics/Models`: pure metric snapshots, calculations, history, and preferences.
- `Core Metrics/UI`: menu-bar label, dashboard sections, reusable components, and Settings.
- `Core Metrics/Utilities`: centralized format styles and small shared helpers.
- `Core MetricsTests`: Swift Testing suites for pure logic and provider fixtures.

Metric definitions and formulas belong in `docs/METRICS.md`. Meaningful architectural choices belong in `docs/DECISIONS.md`.

## Repeatable validation

```sh
xcodebuild -list -project "Core Metrics.xcodeproj"
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics" -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO build
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics" -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO test
```

For UI work, also run from Xcode, locate the status item, open the dashboard, open Settings, change preferences, and confirm the status label updates immediately. Inspect light and dark appearance, keyboard focus, accessibility labels, layout at large text sizes, live-value width stability, clipping, animation, and Reduced Motion/Transparency behavior. The running app is authoritative; a successful build or preview is not sufficient.

## Git expectations

Keep commits small, descriptive, and buildable. Use messages such as `feat(cpu): add delta-based sampling`, `test(metrics): cover bounded history`, or `docs: record storage semantics`; never use `update`, `changes`, `stuff`, or `wip`. Do not rewrite or discard unrelated user changes.
