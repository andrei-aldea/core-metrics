# Architecture decisions

These decisions describe the current product except where explicitly marked superseded. Implementation evidence and validation limits are in [PROJECT_ANALYSIS_REPORT.md](PROJECT_ANALYSIS_REPORT.md).

## ADR-001 — Native, dependency-free application

Use Swift, SwiftUI, AppKit, Core Text, Foundation, Observation, OSLog, ServiceManagement, Accessibility and public Darwin APIs. Native frameworks cover this small utility without a cross-platform layer or monitoring SDK. A new dependency needs explicit review and a written justification.

## ADR-002 — Providers and pure calculations

Keep raw acquisition behind injectable providers, math in pure calculators, immutable snapshots in Models, and observable state on the main actor. This localizes unsafe pointer/Mach work and permits deterministic fixtures. No global monitoring singleton or general-purpose dependency container is needed.

## ADR-003 — Current values only

Retain only the latest CPU, memory and storage snapshots. There are no charts, history buffers, database or telemetry persistence. Historical migrations for menu-bar preferences remain necessary and are retained.

## ADR-004 — Existing macOS 27 baseline

Keep macOS 27 across all targets. This minimum predates the remediation; compatibility was reviewed, not expanded or lowered. Standard controls and system window presentation supply current native materials. There are no older-system fallback claims and no decorative blur stacks. Revalidate on a stable supported Xcode before submission. See Apple's [Liquid Glass adoption guidance](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass).

## ADR-005 — Menu-bar-only lifecycle

**Lifecycle implementation superseded by [ADR-019](#adr-019--own-native-status-item-geometry-and-lifetime).** The following records the original MenuBarExtra implementation.

Use [MenuBarExtra](https://developer.apple.com/documentation/swiftui/menubarextra) with window style and `LSUIElement`. The persistent panel contains selectors; the status label contains live values. Settings uses native SettingsLink. Do not persist an invisible status item with no recovery surface. Sampling starts idempotently from the label and continues while configuration surfaces are closed.

**Amended by [ADR-016](#adr-016--keep-panel-actions-in-one-row):** the earlier panel About action is removed; Settings, Copy Readings and Quit share one footer row.

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

Guard explicit UI-test launch configuration with `#if DEBUG`. Test launches reset a dedicated preferences suite and may set only the app's appearance through public AppKit APIs; normal launches continue using the person's configuration. An explicit test relaunch flag preserves that isolated suite so startup with saved selections can be exercised. Keep live providers active for ordinary scenarios; [ADR-019](#adr-019--own-native-status-item-geometry-and-lifetime) adds one explicitly selected DEBUG-only CPU fixture for deterministic native-geometry regression testing. Start interactive flows with one stat; the broad dark flow selects seven stats through the panel, then relaunches with those saved selections and checks status availability and the native status codes. A focused Settings test adds Memory Used and Storage Free through Settings in Label and Value mode, checks the three status names and frame growth, then verifies the selections after closing and reopening Settings. This protects normal preferences while covering Settings/privacy flows and restoration; it does not establish behavior on every crowded desktop.

## ADR-010 — Bound status text with a native template image

**Superseded by [ADR-015](#adr-015--restore-native-status-text), then [ADR-019](#adr-019--own-native-status-item-geometry-and-lifetime).** The following records the earlier implementation and its rationale, not current behavior.

Keep the existing window-style `MenuBarExtra`, established English names/codes, and padded values. Render the status text with the system monospaced font into a fixed-width `CGImage` using public [ImageRenderer](https://developer.apple.com/documentation/swiftui/imagerenderer). Native adaptation of both a font-modified Text and an attributed-font Text still allowed live width changes during repeated UI testing. A template image preserves the rendered dimensions without introducing a custom status-item controller or private view introspection. SwiftUI [template rendering](https://developer.apple.com/documentation/swiftui/image/renderingmode(_:)) lets native presentation supply the tint.

Measure locale glyph advances independently of current readings and cache the layout in view state until the locale changes. Cap the rendered text width at 320 points and truncate long selections at the tail. Retain only the latest image in view state, keyed by formatted text, capped width, display scale, and spoken summary. Settings keeps the full uncapped text in an attributed monospaced font inside a focusable horizontal scroll area with native indicators.

Supply the rendered image, its scale, and an intrinsic label through SwiftUI's [Image initializer](https://developer.apple.com/documentation/swiftui/image/init(_:scale:orientation:label:)). The label includes “Core Metrics” and the full metric/value summary, so visual truncation does not intentionally omit accessible values. Formatting and layout tests cover the requested frame; native UI tests must also check actual width, accessible naming through the status item's `title`, and saved seven-stat startup. These checks require runtime evidence recorded in the report. macOS still decides how much menu-bar space is available, so visibility on every crowded desktop is not guaranteed.


## ADR-011 — Optional main-app login registration

Use public `SMAppService.mainApp` behind an injectable MainActor service. Read OS registration state on initialization, after operations, and when Settings becomes active. Never register automatically or persist a second flag. Display approval requirements and sanitized errors, and offer the documented Login Items settings action. An owned task serializes changes without retaining the store across a suspended unregister. No helper, daemon, entitlement, or signing change is needed. DEBUG UI tests inject a fake service; final signed installation and login behavior remain release validation.

## ADR-012 — Explicit current-reading copy and local help

Copy full selected names and formatted values on an explicit action, independent of menu-bar visibility or representation. Use the same locale-aware value formatting, spell out unavailable readings, and omit timestamps and machine identity. The clipboard writer is injectable; a private named-pasteboard fixture covers the actual API without touching the general clipboard. Success changes the text-only Copy Readings button label to Copied and posts a spoken announcement; failure uses a native alert. macOS owns the clipboard after writing, and Privacy describes possible Universal Clipboard sharing.

Offer concise Metric Help from Settings as a native scrollable sheet. Its content follows the existing metric definitions, including overlapping memory categories and the difference between memory use and pressure. It adds no acquisition, networking, or history.

**Amended by [ADR-016](#adr-016--keep-panel-actions-in-one-row):** Help is available only from Settings, and the former Copy Current Readings label/icon and separate confirmation caption are replaced by one text-only button with stable dimensions.

## ADR-013 — Reproducible local validation

Provide a dependency-free shell entry point with native Foundation artifact checks. Serialize app builds, unit tests, analysis and optional interactive UI tests to avoid competing native test hosts. Keep logs, DerivedData and result bundles outside the checkout, validate the built Release package, and report toolchain warnings honestly. This command neither archives for distribution nor changes publisher configuration.


## ADR-014 — Settings owns representation and activation

**Panel navigation mechanism amended by [ADR-019](#adr-019--own-native-status-item-geometry-and-lifetime).** Representation remains in Settings; the detached AppKit-hosted panel uses an injected scene action instead of the earlier SettingsLink style.

Retain all metric checkboxes in the persistent panel, but configure Menu Bar Text only in Settings, immediately below its full live preview. This gives the panel more space for metric choices and removes its root display-mode binding. Selection limits, ordering, migration and value formatting are unchanged.

Keep native [SettingsLink](https://developer.apple.com/documentation/swiftui/settingslink) navigation. Its scoped [PrimitiveButtonStyle](https://developer.apple.com/documentation/swiftui/primitivebuttonstyle) uses a native bordered Button to request public [application activation](https://developer.apple.com/documentation/appkit/nsapplication/activate()) and then forward the link’s original action. Preserve button roles, keyboard shortcuts and accessibility activation; do not replace them with tap gestures, private selectors or window enumeration. Desktop tests must open Settings before another modal can activate the app and must not call `XCUIApplication.activate()` to compensate for focus behavior.

## ADR-015 — Restore native status text

**MenuBarExtra presentation superseded by [ADR-019](#adr-019--own-native-status-item-geometry-and-lifetime).** The following retains the user-reported regression and intermediate implementation.

Restore the single native attributed Text label used before ADR-010. The user reported changed menu-bar typography and an inability to see additional selected readings in the installed app. The bitmap implementation imposed a 320-point cap and tail truncation, which could hide a third reading in the ordinary three-stat Label and Value configuration. The selection model still allowed seven; the cap affected presentation. Rendering the explicit monospaced font into pixels also bypassed the native text host's typography adaptation, although the precise visual difference requires runtime comparison.

Keep [MenuBarExtra](https://developer.apple.com/documentation/swiftui/menubarextra), the existing monospaced font, locale-aware width reservation, padded values, selection ordering and accessibility summary. Remove the status-only image renderer and width cap. Settings continues to show the same full string in a horizontal scroll area. No preference migration, metric formula or acquisition change is required.

Prefer native text and complete supplied readings over enforcing bitmap dimensions. The host may adapt font and width, and previous native testing recorded width drift; the requested reservation is not a guarantee of fixed status-item size. macOS still controls menu-bar space, so crowded or notched displays may not fit long selections. Validate native typography, one/three/seven selections, representation changes, spoken context and saved-selection startup in the running app. Keep historical renderer measurements in the report as evidence for the superseded implementation.

## ADR-016 — Keep panel actions in one row

Keep the CPU, Memory and Storage checkbox sections, followed by a single native footer row. Place Settings beside the text-only Copy Readings button and use a spacer before trailing Quit. Remove About and Metric Help from the panel; Metric Help remains in Settings. This follows the requested panel layout without changing selection, formatting, clipboard behavior or Settings activation.

Reserve space for both localized Copy Readings and Copied labels within the same button. Success changes its visible and accessible label and posts an announcement, without adding a second row or moving adjacent controls. Preserve the existing copy-button accessibility identifier and remove the standalone confirmation element. Clear copy-error presentation explicitly when OK is clicked or the panel disappears. Desktop validation must check the footer before and after success, failure feedback that stays dismissed after reopening, keyboard activation and Help dismissal from Settings.


## ADR-017 — Dismiss the panel before Settings and preserve spoken readings

**Presentation mechanism superseded by [ADR-019](#adr-019--own-native-status-item-geometry-and-lifetime).** Panel dismissal before Settings and complete spoken context remain requirements; the following records the earlier MenuBarExtra mechanism.

Desktop testing exposed the selection panel remaining above Settings after activation. The native SettingsLink button now invokes the environment’s [DismissAction](https://developer.apple.com/documentation/swiftui/dismissaction), then activates the app and forwards the original Settings action. Keyboard activation bypasses the custom SettingsLink style. Replace the standard app Settings command with a native Commands Button that obtains the active panel’s DismissAction via [focusedSceneValue](https://developer.apple.com/documentation/swiftui/view/focusedscenevalue(_:_:)), dismisses it, activates the app and invokes [openSettings](https://developer.apple.com/documentation/swiftui/environmentvalues/opensettings). The visible panel retains SettingsLink. No duplicate presentation state or window reference is stored. Tests require the panel to disappear and the Settings controls to be reachable, including reopening with Command-comma. No delay, window lookup or private selector is needed.

The native status item also drops a separate accessibility value even while it renders the correct text. Put the app name and full metric summary into one localized accessibility label, shared with Settings preview. Preserve the native visual Text and single accessibility element; inspect the exposed title/label independently of screenshots that show the rendered glyphs.


## ADR-018 — Reserve percentage space separately in Compact

**Column sizing superseded by [ADR-019](#adr-019--own-native-status-item-geometry-and-lifetime).** The following records the intermediate six-character Compact rule; current percentages use a locale-derived column in every mode.

Seven selected readings can push a native status item into macOS menu-bar overflow. Compact percentages previously reserved the eight characters needed by the largest byte value even though current locale percentage output needs at most six, including spacing and direction marks. Reserve six characters for Compact percentage statistics and eight for bytes. Other display modes retain their existing columns and native typography. The layout calculator uses the same per-stat widths as text formatting.

Unit coverage checks percentage output across Foundation’s available locales and verifies that values from small percentages through 100% fit without changing slot width. Byte boundary values retain their eight-character space. This reduces unnecessary padding without truncation, a bitmap, an arbitrary width cap, or removal of selected readings. Desktop tests and screenshots must still verify the actual status item; no native control can promise unlimited space on every desktop.


## ADR-019 — Own native status-item geometry and lifetime

**Font and value-column contract superseded by [ADR-020](#adr-020--use-native-tabular-digits-and-measured-value-columns).** Native status-item ownership, fixed allocation, lifecycle and Settings integration remain current. The typography and validation measurements below describe the preceding revision.

The user reported that the restored MenuBarExtra label still moved as readings changed. Own a native `NSStatusItem` and set a positive [length](https://developer.apple.com/documentation/appkit/nsstatusitem/length) from the selected stats, mode and locale. Recompute that allocation only when configuration or locale changes; live samples update [NSStatusBarButton](https://developer.apple.com/documentation/appkit/nsstatusbarbutton)'s attributed title. Use the normal system font for label prefixes and static separators, and the monospaced system font for padded live values, both at the system size (13 points on the reviewed runtime). Keep full text, ordering and accessibility summary without a bitmap or arbitrary width cap. Measure static runs in their actual font and reserve conservative locale-aware value columns. Share the native attributed title with Settings preview, explicitly converting AppKit font attributes to SwiftUI font attributes. Apple's [monospaced font guidance](https://developer.apple.com/documentation/appkit/nsfont/monospacedsystemfont(ofsize:weight:)) notes that some glyphs can have different advances, so retain locale-aware point measurement and actual glyph-fit checks. Observed MenuBarExtra modifier behavior is runtime evidence, not a claimed Apple specification.

Use `max(4, MetricFormatting.percentage(1, locale: locale).count)` for every percentage column in all display modes. This reserves localized spacing and direction marks without making short percentage values consume the eight-character byte column. Byte values still reserve eight characters. Compact separates complete stat slots with one space; other modes use two. Pass the same locale to formatting and point measurement. Coverage checks every integer percentage from 0 through 100 across Foundation's available locales and every mode, with separate actual-glyph layout fixtures. No reading is truncated to implement the tighter spacing.

Move app lifetime to `CoreMetricsAppDelegate`: strongly own the stores and status controller, start sampling on launch, and stop presentation observations and sampling on termination. The status bar [does not retain its item](https://developer.apple.com/documentation/appkit/nsstatusbar/statusitem(withlength:)). The controller owns cancellable, weakly captured observation and locale tasks. This replaces label-driven sampling startup without changing acquisition, persistence, migration or privacy behavior.

Use macOS 27's public [expandedInterfaceDelegate](https://developer.apple.com/documentation/appkit/nsstatusitem/expandedinterfacedelegate) to coordinate the status item's expanded session with a transient [NSPopover](https://developer.apple.com/documentation/appkit/nspopover), hosting the existing SwiftUI panel through [NSHostingController](https://developer.apple.com/documentation/swiftui/nshostingcontroller). Keep Settings as a native SwiftUI scene registered with [NSHostingSceneRepresentation](https://developer.apple.com/documentation/swiftui/nshostingscenerepresentation); Apple's example exposes the scene's `environment.openSettings()` action to AppKit. A detached SettingsLink failed to open Settings during integration testing. Use an ordinary bordered Settings Button with an injected [OpenSettingsAction](https://developer.apple.com/documentation/swiftui/opensettingsaction) obtained directly from the represented scene, matching the public AppKit bridge. Do not copy the entire scene environment into `NSHostingController`; the hosted panel receives its app stores explicitly. SettingsLink remains appropriate within SwiftUI scene contexts. Close the owned panel before activating/opening Settings, and preserve native keyboard/menu actions. No private selector, status-item introspection, helper or entitlement is introduced.

Outside-click follow-up: the transient popover could remain open when the agent was inactive at presentation. After successful `show`, request application activation and make the owned content window key. Keep dismissal within the existing native transient behavior and closure/session coordination; add no event monitor, application observer or geometry change. The focused desktop regression covers a real Finder Dock click, same-app Settings title-bar click, reopening, persistent interior selection changes and Escape. The final F7khvi desktop rerun passed all eight scenarios with no failures; the report preserves the initial hover failure, focused rerun and final results.

Status-item toggle follow-up: retain the existing native expanded-interface session as the owner of repeated status-item clicks. A dedicated regression checks three open/close cycles, including after changing to three readings, and requires that closing the panel does not open Settings. Ordinary clicks also passed against the installed Release with normal preferences. The proposed transient-close veto and animation change did not improve a separate rapid-double-click case and were removed. The report distinguishes the verified single-click interaction from that unresolved gesture; neither custom event handling nor a target/action replacement was introduced.

Add a DEBUG-only CPU fixture that alternates 9% and 100% without changing selection or mode. Its desktop regression compares the actual status item's width and screen position across six publications, then opens the panel, dismisses with Escape and reopens it. Keep normal UI scenarios on live providers. Validate complete text, one/three/seven selections, saved-selection startup, popover accessibility, Settings click/shortcut paths and shutdown. All seven NativeVerified UI scenarios passed on the reviewed desktop, including three full-name selections, seven Compact selections and saved startup. The deterministic fixture recorded six identical 52-point-wide frames. These measured results resolve the observed local regressions; broader display/accessibility coverage remains separate, with full evidence in the report.

Fixed width prevents the app from requesting a new allocation for each reading; it does not guarantee menu-bar room or prevent movement caused by changes elsewhere on the desktop. Apple explicitly documents that [isVisible](https://developer.apple.com/documentation/appkit/nsstatusitem/isvisible) stays true when an item is temporarily hidden for insufficient space. Do not infer fit from that property or promise seven long readings on every display. Settings preview and Copy Readings retain access to the full selection. Handle public [applicationShouldHandleReopen](https://developer.apple.com/documentation/appkit/nsapplicationdelegate/applicationshouldhandlereopen(_:hasvisiblewindows:)) by dismissing the panel, activating the app and opening the represented Settings scene, then returning false. Opening the already-running app again in Finder supplies a recovery path even when a long label has no room. A separate async XCTest exercises public `NSWorkspace.openApplication`, verifies that the process identifier is unchanged, and requires usable foreground Settings. It passed in NativeVerified; keep this recovery path distinct from terminate/relaunch testing.


## ADR-020 — Use native tabular digits and measured value columns

Keep ADR-019's owned `NSStatusItem`, positive allocation, public popover/Settings bridge and lifetime. Replace SF Mono live values with the standard system font containing tabular digits through public [monospacedDigitSystemFont](https://developer.apple.com/documentation/appkit/nsfont/monospaceddigitsystemfont(ofsize:weight:)). Apple documents that other characters can retain different advances, so character-count padding cannot determine native geometry. Use one consistent font size per mode. Compact codes, inter-stat separators and tabular-digit values all use the small system size (11 points on the reviewed runtime); Label and Value and Value Only use the normal system size (13 points). This addresses the requested native typography while retaining space for Compact selections.

Cache separate normal-font and Compact-font point columns when the locale changes. Format candidate strings and resolve the visual percent-boundary strategy once per locale, then measure the same candidates in each font. Keep the two-point visual percent gap in every mode. Measure every decorated integer percentage from 0 through 100, and separate memory/storage candidates that combine all seven byte suffixes with localized repeated-digit and zero-heavy width templates, including a zero-heavy case for each leading digit and zero itself. The current candidate set contains 133 strings per byte style. Include the unavailable marker in each category. Measure static prefixes and separators in their actual font. Align every reading using one ordinary leading space whose kerning is `max(0, reservedColumnWidth - measuredValueWidth) - spaceAdvance`. Its net advance fills the unused column so the following column remains stable across digit, decimal, unit and unavailable transitions. Character-count plain-text helpers and tests remain separate; they no longer drive native title geometry. Metric formulas and byte/percentage string formatting are unchanged.

Start value runs with zero kerning to disable pair kerning. Resolve the visual percent/numeric boundary once per locale in `makePercentSpacing`, using public Core Text [glyph positions](https://developer.apple.com/documentation/coretext/ctrungetpositions(_:_:_:)) and [string indices](https://developer.apple.com/documentation/coretext/ctrungetstringindices(_:_:_:)) from the formatted 100% sample. Logical suffix/prefix position alone is insufficient for bidirectional text. Exclude Unicode format marks when locating the visible symbol, skip locales whose whitespace already supplies the gap, and cache the visible symbol plus the symbol/first-number/last-number boundary. Subsequent values apply the two-point kern to exactly one visible character. A percentSymbol can include Arabic Letter Mark; decorating that entire range can add four points instead of two. Preserve the formatted text, locale spaces, prefix-symbol placement and bidirectional marks. Measure the decorated values when reserving their columns. The Settings preview explicitly maps both AppKit font and kerning attributes into SwiftUI so it presents the same attributed title.

Native layout fixtures check tabular digits/proportional letters, complete reading order, localized glyph fit, Core Text column positions across changing values and units, and two-point percent gaps only where needed. Retain the typography, deterministic live-position and already-running app-recovery scenarios as the desktop suite expands. The preceding NativeVerified seven-test pass and 52-point frame measurements are historical evidence for ADR-019's typography. The typography revision's RViaos validation passed all seven then-existing UI scenarios, plus Debug/Release builds, 68 unit-test declarations with 161 executions, analysis and artifact checks. Units and UI tests had no failures or skips. Six alternating 9%/100% publications retained identical 58-point-wide frames and position. Inspected captures confirmed complete readable seven-stat Compact text at 11 points and consistent full-name text and Settings preview at 13 points. Known AppIntents warnings and observed beta-runtime layout diagnostics remain recorded in the report. Available menu-bar room and the wider display/accessibility matrix remain limits.
