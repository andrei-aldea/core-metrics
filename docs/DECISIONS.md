# Architecture decisions

These decisions describe the current product. Implementation evidence and validation limits are in [PROJECT_ANALYSIS_REPORT.md](PROJECT_ANALYSIS_REPORT.md).

## ADR-001 — Native, dependency-free application

Use Swift, SwiftUI, AppKit, Foundation, Observation, OSLog, ServiceManagement, Accessibility and public Darwin APIs. Native frameworks cover this small utility without a cross-platform layer or monitoring SDK. A new dependency needs explicit review and a written justification.

## ADR-002 — Providers and pure calculations

Keep raw acquisition behind injectable providers, math in pure calculators, immutable snapshots in Models, and observable state on the main actor. This localizes unsafe pointer/Mach work and permits deterministic fixtures. No global monitoring singleton or general-purpose dependency container is needed.

## ADR-003 — Current values only

Retain only the latest CPU, memory and storage snapshots. There are no charts, history buffers, database or telemetry persistence. Historical migrations for menu-bar preferences remain necessary and are retained.

## ADR-004 — Existing macOS 27 baseline

Keep macOS 27 across all targets. This minimum predates the remediation; compatibility was reviewed, not expanded or lowered. Standard controls and system window presentation supply current native materials. There are no older-system fallback claims and no decorative blur stacks. Revalidate on a stable supported Xcode before submission. See Apple's [Liquid Glass adoption guidance](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass).

## ADR-005 — Menu-bar-only lifecycle

Use [MenuBarExtra](https://developer.apple.com/documentation/swiftui/menubarextra) with window style and `LSUIElement`. The persistent panel contains selectors; the status label contains live values. Settings uses native SettingsLink, and About uses the standard AppKit panel. Do not persist an invisible status item with no recovery surface. Sampling starts idempotently from the label and continues while configuration surfaces are closed.

## ADR-006 — Explicit aggregate memory semantics

Use public VM counters for cached/free/wired/compressed memory, physicalMemory for total RAM, and the public VM_SWAPUSAGE sysctl for swap. Memory Used is physical total minus clamped cached/free memory; compressed memory is occupied compressed RAM, not its logical uncompressed size. Treat swap failure independently. These are aggregate estimates aligned with Activity Monitor category names, not its private implementation. Exact formulas and caveats live in [METRICS.md](METRICS.md).

## ADR-007 — Narrow privacy declaration

Retain the existing manifest with Disk Space `85F4.1`, User Defaults `CA92.1`, and no collected data/tracking. Apple's macOS-specific applicability must be checked at release; current declarations truthfully describe use rather than inventing reasons. See [APP_STORE.md](APP_STORE.md) for official sources and release review obligations.

Expose factual local privacy information from Settings in a native, scrollable sheet. Describe the implemented aggregate reads, local persistence, and diagnostics. Keep publisher-controlled policy/support URLs and legal decisions in the release workflow; do not invent them or introduce networking to display local information.

## ADR-008 — Reject obsolete work and refresh metadata

Give each sampling generation an identity checked on the main actor before publication. Cancelling does not interrupt an already-running synchronous system call; identity validation prevents its late result from updating a restarted store. Return the cancelled task from `stop()` when completion must be awaited. This preserves the existing provider contracts and avoids locks in app state.

Clear cached URL resource values before each background storage sample. Apple [documents URL caching](https://developer.apple.com/documentation/foundation/url/resourcevalues(forkeys:)); main-thread automatic invalidation does not cover the app's background loop. The small local invalidation is preferable to accepting stale disk values or adding a separate cache abstraction.

## ADR-009 — Separate interactive and unit validation

Keep the UI-test target and its shared scheme, but remove its redundant build entry from the unit-test scheme. Unsigned unit runs should not build an unused desktop automation runner. Local UI signing and publisher distribution signing remain separate validation concerns.

Guard explicit UI-test launch configuration with `#if DEBUG`. Test launches reset a dedicated preferences suite and may set only the app's appearance through public AppKit APIs; normal launches continue using the person's configuration. An explicit test relaunch flag preserves that isolated suite so startup with saved selections can be exercised. Keep live providers active so tests exercise actual status updates. Start interactive flows with one stat, then add seven selections through the panel. The dark scenario relaunches with those saved selections and checks status availability and its full accessible summary. This protects normal preferences while covering both Settings/privacy flows and restoration; it does not establish behavior on every crowded desktop.

## ADR-010 — Bound status text with a native template image

Keep the existing window-style `MenuBarExtra`, established English names/codes, and padded values. Render the status text with the system monospaced font into a fixed-width `CGImage` using public [ImageRenderer](https://developer.apple.com/documentation/swiftui/imagerenderer). Native adaptation of both a font-modified Text and an attributed-font Text still allowed live width changes during repeated UI testing. A template image preserves the rendered dimensions without introducing a custom status-item controller or private view introspection. SwiftUI [template rendering](https://developer.apple.com/documentation/swiftui/image/renderingmode(_:)) lets native presentation supply the tint.

Measure locale glyph advances independently of current readings and cache the layout in view state until the locale changes. Cap the rendered text width at 320 points and truncate long selections at the tail. Retain only the latest image in view state, keyed by formatted text, capped width, display scale, and spoken summary. Settings keeps the full uncapped text in an attributed monospaced font inside a focusable horizontal scroll area with native indicators.

Supply the rendered image, its scale, and an intrinsic label through SwiftUI's [Image initializer](https://developer.apple.com/documentation/swiftui/image/init(_:scale:orientation:label:)). The label includes “Core Metrics” and the full metric/value summary, so visual truncation does not intentionally omit accessible values. Formatting and layout tests cover the requested frame; native UI tests must also check actual width, accessible naming through the status item's `title`, and saved seven-stat startup. These checks require runtime evidence recorded in the report. macOS still decides how much menu-bar space is available, so visibility on every crowded desktop is not guaranteed.


## ADR-011 — Optional main-app login registration

Use public `SMAppService.mainApp` behind an injectable MainActor service. Read OS registration state on initialization, after operations, and when Settings becomes active. Never register automatically or persist a second flag. Display approval requirements and sanitized errors, and offer the documented Login Items settings action. An owned task serializes changes without retaining the store across a suspended unregister. No helper, daemon, entitlement, or signing change is needed. DEBUG UI tests inject a fake service; final signed installation and login behavior remain release validation.

## ADR-012 — Explicit current-reading copy and local help

Copy full selected names and formatted values on an explicit action, independent of menu-bar truncation or representation. Use the same locale-aware value formatting, spell out unavailable readings, and omit timestamps and machine identity. The clipboard writer is injectable; a private named-pasteboard fixture covers the actual API without touching the general clipboard. Success uses compact inline feedback; failure uses a native alert. macOS owns the clipboard after writing, and Privacy describes possible Universal Clipboard sharing.

Offer concise Metric Help from the panel and Settings as a native scrollable sheet. Its content follows the existing metric definitions, including overlapping memory categories and the difference between memory use and pressure. It adds no acquisition, networking, or history.

## ADR-013 — Reproducible local validation

Provide a dependency-free shell entry point with native Foundation artifact checks. Serialize app builds, unit tests, analysis and optional interactive UI tests to avoid competing native test hosts. Keep logs, DerivedData and result bundles outside the checkout, validate the built Release package, and report toolchain warnings honestly. This command neither archives for distribution nor changes publisher configuration.


## ADR-014 — Settings owns representation and activation

Retain all metric checkboxes in the persistent panel, but configure Menu Bar Text only in Settings, immediately below its full live preview. This gives the panel more space for metric choices and removes its root display-mode binding. Selection limits, ordering, migration and value formatting are unchanged.

Keep native [SettingsLink](https://developer.apple.com/documentation/swiftui/settingslink) navigation. Its scoped [PrimitiveButtonStyle](https://developer.apple.com/documentation/swiftui/primitivebuttonstyle) uses a native bordered Button to request public [application activation](https://developer.apple.com/documentation/appkit/nsapplication/activate()) and then forward the link’s original action. Preserve button roles, keyboard shortcuts and accessibility activation; do not replace them with tap gestures, private selectors or window enumeration. Desktop tests must open Settings before another modal can activate the app and must not call `XCUIApplication.activate()` to compensate for focus behavior.
