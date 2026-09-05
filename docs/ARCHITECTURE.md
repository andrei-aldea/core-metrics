# Architecture

Core Metrics has one native app target and two test targets. SwiftUI owns the scenes; small providers own public system API calls; pure calculators own metric math. No package, service container, coordinator, repository framework, database, or networking layer is needed.

## Flow and ownership

`CoreMetricsApp` owns one `MetricsStore` and one `PreferencesStore` as `@State`. It injects both into the status label/panel and Settings. `MenuBarLabelView.task` starts sampling idempotently, including when the label is used as the Settings preview. Sampling continues while the panel is closed because the menu-bar value remains live.

Providers in `Metrics/` read aggregate CPU ticks, physical-memory/swap counters, and startup-volume capacity. Calculators validate raw inputs and produce immutable Sendable snapshots in `Models/`. Low-level code never appears in views. `Utilities/` formats values centrally; `Views/` reads only metric categories selected for presentation, reducing unrelated invalidations.

The native window-style `MenuBarExtra` keeps selections open. `LSUIElement` hides the Dock/app-switcher entry. Settings opens through `SettingsLink`; About uses the standard AppKit panel; Quit uses normal application termination. Settings owns the presentation state for a native privacy-information sheet. There is no persisted hidden-status-item state, launch-at-login helper, deep link, or background service.

## Concurrency and lifetime

`MetricsStore` is main-actor observable state. Its owned utility-priority task starts off-main and owns two result-discarding child loops: CPU/memory and storage. Providers run synchronously off-main; publication hops to the main actor. Each Mach host send right is released with `mach_port_deallocate`.

CPU and memory refresh approximately every two seconds. Storage refreshes every 30 seconds after a valid read and retries every two seconds when unavailable. Suspensions use cancellable task sleeps. Weak captures prevent the task from retaining the store; deinitialization cancels work. No timer array, sample queue, chart buffer, or history accumulates.

Each start creates a sampling identity. `stop()` invalidates it immediately and cancels the task; publication checks identity and cancellation on the main actor. Thus a synchronous read that finishes after stop/restart cannot overwrite the next generation. `stop()` returns the cancelled task when a caller needs to await cooperative shutdown. System calls already in progress cannot be forcibly interrupted.

CPU discontinuity detection compares sample wall-clock dates. A negative gap or a gap above five seconds resets its baseline; the next valid delta restores the reading. This is a sampling-gap heuristic, not a dedicated sleep/wake observer.

Foundation caches resource values on URL instances. The storage provider clears cached values on a local URL copy before each off-main capacity read, ensuring each poll asks for fresh metadata.

## Failure boundaries

A failed CPU call resets the baseline and clears the current value. Initial CPU sampling or zero tick deltas may return no value without a failure log. Missing/throwing memory or storage snapshots clear that category. A missing swap result clears only Swap Used.

Unavailable/recovery transitions are logged once per category with OSLog; samples, errors containing paths, machine identity, and preference payloads are never logged. The UI renders an em dash and an accessible “Unavailable” value. Recovery requires no restart.

## Preferences and presentation

`MenuBarConfiguration` enforces one to seven unique stats in CPU → Memory → Storage order. Value Only is allowed for one stat; adding another changes it to Compact. Raw persisted identifiers and both earlier preference schemas are preserved. Legacy decoding is live compatibility code, not dead code.

`PreferencesStore` loads app-only JSON from UserDefaults, repairs malformed/wrongly typed values, and immediately persists meaningful changes. Equal assignments skip encoding and disk-preference writes. Unit persistence fixtures use unique suites; interactive tests use the separate launch configuration described below.

`MenuBarLabelView` shares formatting, selection order, and the full spoken summary between the status item and Settings. For the native status item, `MenuBarStatusLabel` uses public `ImageRenderer` to render monospaced text into a fixed-width `CGImage`. SwiftUI `Image` receives that image, its display scale, and an intrinsic accessibility label, then uses template rendering so the system supplies its menu-bar tint. Its content width is the smaller of the locale-aware reservation and 320 points; longer text truncates at the tail. The existing window-style `MenuBarExtra` still owns the status item and panel. The image label includes “Core Metrics” and the full metric summary.

`MenuBarLabelLayout` measures locale-specific digit, decimal-separator, and percent glyphs to calculate a stable frame reservation. The label holds this layout in state and refreshes it when the locale changes. The status renderer retains only its latest image, rebuilding it when formatted text, capped width, display scale, or the spoken summary changes. No images or samples are written to disk. Layout fixtures check text against the requested frame, while native UI tests check the actual status item. Menu-bar space remains controlled by macOS.

Settings presents the full, uncapped text using an `AttributedString` with the measured monospaced font. Its focusable horizontal ScrollView retains native scroll indicators and explains how to see the complete selection. `PrivacyInformationView` presents static, localization-ready descriptions of aggregate reads, local preferences, current-only readings, absent network features, and category-only diagnostics. Its scrollable content and Done/Return/Escape dismissal require no provider, persistence, or network work. Keep these descriptions synchronized with changes to data handling. Descriptive names and accessibility text use localization-aware APIs; compact status codes retain their current English contract. No translations are bundled yet. See [design](DESIGN.md) for accessibility validation constraints.

## Configuration and tests

All targets use macOS 27 and Swift 6. The app additionally uses MainActor default isolation. Debug is unoptimized/testable; Release uses standard whole-module optimization, dead-code stripping, and asset space optimization. Sandbox and hardened runtime remain enabled in both.

`UITestLaunchConfiguration` and its app-entry invocation are guarded by `#if DEBUG`. An explicit `CORE_METRICS_UI_TESTING=1` launch uses a dedicated UI-test UserDefaults suite. It resets that suite and starts with one Value Only statistic unless `CORE_METRICS_UI_RELAUNCH=1` requests preservation of the test preferences. The optional `CORE_METRICS_UI_APPEARANCE` flag applies light or dark appearance to this application through public AppKit APIs. Normal launches retain standard preferences and system appearance; Release excludes these test hooks. Providers continue to acquire real aggregate metrics during UI tests. The dark seven-stat scenario adds selections through the panel, then relaunches with the saved test preferences to exercise status-item availability and its full accessible summary at startup. Available menu-bar space still varies by desktop configuration; test outcomes belong in the report.

The main shared scheme builds the app and unit tests. The separate UI scheme builds the app and XCTest runner. Native status-item accessibility assertions inspect its XCTest `title` attribute. Provider protocols permit deterministic fixtures; Swift Testing covers calculations, migrations, persistence, cancellation, recovery, formatting, and cached resource invalidation. See [DEVELOPMENT.md](DEVELOPMENT.md) for validation commands and [PROJECT_ANALYSIS_REPORT.md](PROJECT_ANALYSIS_REPORT.md) for measured results.
