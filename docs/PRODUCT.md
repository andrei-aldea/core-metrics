# Core Metrics product context

This is the maintained product brief for native-app work. It describes the checked-in implementation and established design choices; it is not a release receipt or a fresh App Store Connect observation. Use [PLAN.md](PLAN.md) for prioritized work, [DESIGN.md](DESIGN.md) for the detailed UI contract, and [METRICS.md](METRICS.md) for formulas.

## Purpose and users

Core Metrics puts current aggregate CPU, memory and startup-volume readings in the macOS menu bar. The intended user wants a quick glance at selected system readings and a small native configuration surface. This audience description is an inference from the implementation and existing brief, not a researched persona or a claim about adoption.

The product answers “what are my current readings?” It retains no history and does not diagnose performance causes, inspect individual processes, optimize the Mac or promise an improvement in speed, battery life or memory pressure.

## Implemented capabilities

| Area | Checked-in behavior |
| --- | --- |
| Platform and lifecycle | Native macOS 27 minimum; menu-bar app with no Dock entry or main document window. AppKit owns lifetime, the status item and popover; SwiftUI supplies configuration and Settings. |
| Selection | Choose one to seven of 15 stats, including several from the same category. Order is always CPU → Memory → Storage and the enum order within each category. Default is CPU User in Label and Value. |
| Readings | CPU Used, User, System and Idle; Memory Used, Used (%), Wired, Compressed, Cached Files, Swap Used and Physical Memory; Storage Used, Used (%), Free and Total for the startup volume. |
| Display modes | Label and Value, Compact, Icon and Value, Values Only; each supports every allowed selection count. All use the same 12-point native size. Compact changes label wording. |
| Updates and failures | CPU/memory refresh about every two seconds; storage about every thirty seconds, with faster retry on failure. Unavailable values clear stale readings and display a dash. CPU needs a baseline; failed swap does not hide physical-memory readings. |
| Preferences | Persist menu-bar selections and mode locally. Restore Defaults resets those preferences; compatibility decoding retains older schemas and identifiers. |
| Copy | Explicit Copy Readings takes current selected names/values, independent of display mode, and replaces this Mac's clipboard contents. It excludes Universal Clipboard, timestamps and machine identity. Success provides visible/spoken feedback; failure uses a native alert. |
| Login | Optional Launch at Login reflects macOS registration/approval state. It does not create a Core Metrics account, helper or duplicate saved preference. |
| Help and links | Settings presents local Metric Help and Privacy sheets; Support/Privacy links open fixed destinations in the browser without attaching readings or preferences. A privacy-email link opens a draft in the mail app. |

Implementation references: [stat catalog](../Core%20Metrics/Preferences/MenuBarStat.swift), [configuration](../Core%20Metrics/Preferences/MenuBarConfiguration.swift), [display modes](../Core%20Metrics/Preferences/MenuBarDisplayMode.swift), [sampling](../Core%20Metrics/Application/MetricsStore.swift), [clipboard writer](../Core%20Metrics/Utilities/CurrentReadingsPasteboard.swift), [public links](../Core%20Metrics/Utilities/PublicAppLinks.swift), and [architecture](ARCHITECTURE.md).

## Core journeys and acceptance

1. **Launch and glance.** Launch the app and find its readings in the menu bar. Closing Settings leaves sampling active. Saved choices return on the next normal launch. An initial unavailable CPU reading is expected until a valid delta exists.
2. **Choose readings.** Click the status item and toggle native checkboxes in the CPU, Memory and Storage sections. The panel stays open and anchored while the selection updates immediately. Controls prevent zero or more than seven selected stats. A second single click, Escape or a real outside click dismisses the panel.
3. **Configure appearance.** Open Settings from the panel or Command-comma. The panel closes; Settings opens or rises in front. Its full live preview scrolls horizontally; four radio choices control representation. Add/remove controls share the same bounded canonical selection.
4. **Recover when space is constrained.** macOS can temporarily hide a long item when menu-bar room is scarce. Reopen the already-running app in Finder to open Settings, then choose fewer stats or a narrower mode. Fixed allocation cannot guarantee seven readings fit every desktop.
5. **Copy or understand a reading.** Copy from the panel, or open Metric Help in Settings. Help explains aggregate CPU, overlapping memory categories, startup-volume capacity, independent sampling and unavailable values. A high used-memory percentage alone does not establish memory pressure.
6. **Manage startup or reset.** Explicitly enable/disable Launch at Login and follow macOS approval guidance if needed. Restore Defaults returns CPU User / Label and Value without changing login registration. Quit ends sampling normally.

Source anchors: [panel](../Core%20Metrics/Views/MenuBar/MenuBarMenuView.swift), [Settings](../Core%20Metrics/Views/Settings/SettingsView.swift), [reopen recovery](../Core%20Metrics/Application/CoreMetricsAppDelegate.swift), [copy feedback](../Core%20Metrics/Views/MenuBar/CopyCurrentReadingsButton.swift), [login UI](../Core%20Metrics/Views/Settings/LaunchAtLoginSection.swift).

## Design and accessibility baseline

Preserve the restrained native UI: system typography, semantic colors, native checkboxes/buttons/forms, SF Symbols and platform-owned materials. The panel footer is one row of Settings, Copy Readings and Quit. Representation and Help belong in Settings. The native status item has no brand header, chart or decorative severity scale. Artwork and naming follow [BRAND.md](BRAND.md); Macs Fan Control was a sizing reference, not an integration or affiliation.

The status title uses system labels, tabular-digit values and locale-aware point columns. Reserve width per selection/mode/locale; live sampling changes text without resizing that allocation. Settings shares the presentation and provides a horizontally scrollable full preview. Preserve formatted digits, percent spacing and bidirectional marks. The current UI text is English/localization-ready; localized number formatting does not imply bundled translations.

Keep full spoken metric context even in Compact/Icon/Values Only. Existing controls supply native selection state, descriptive labels/hints, semantic sheet headings, selectable wrapping text, focusable scrolling and Done/Return/Escape dismissal. Selection must not depend on color. The panel has 420/500-point normal/accessibility-size branches; Settings is 580 points wide with vertical scrolling. These source choices require runtime checks for actual macOS text settings, keyboard focus, long text and clipping; they do not establish completed accessibility support.

The complete acceptance matrix remains in [DESIGN.md](DESIGN.md#required-runtime-review). It includes one/three/seven selections, all modes, width/position across changing values, popover anchoring/dismissal, light/dark, constrained displays, larger text, VoiceOver, keyboard traversal, Increased Contrast, Reduce Motion, Reduce Transparency and Differentiate Without Color. Do not redesign these surfaces to close a verification gap.

## Scope and boundaries

- Keep the app local-only, sandboxed, dependency-free and based on documented public Apple APIs. Acquire aggregate metrics off-main; publish current UI state on the main actor. Store only menu-bar preferences; logs contain category/state transitions.
- Preserve macOS 27 minimum, existing signing/identity configuration, preference migrations and test isolation. A toolchain or hardware inventory is environment evidence, not permission to change platform requirements.
- No history, accounts, cloud sync, telemetry, analytics, ads, subscriptions or purchases. No iPhone/iPad/Catalyst/Windows target is implemented.
- No optimizer, cleaner, process inspection/killing, file scans, malware features, fan/temperature probing, GPU/battery/network monitoring, hardware tuning, privileged helper, daemon or private API.
- Do not change formulas based on an apparent disagreement with another utility: compare the documented definition and sampling first. Memory uses binary scaling, storage decimal; neither is a diagnostic score.
- Website hosting and voluntary support correspondence are separate data-processing surfaces. Do not extend the app's local-only claim to those services or invent legal/publisher facts.

## Decisions and conditions for reconsideration

The [decision log](DECISIONS.md) records rationale and superseded implementations. The native/no-dependency boundary, current-values-only scope and provider/calculator split fit the implemented utility; reconsider only against an approved requirement or measured limitation. AppKit status ownership addresses native geometry/lifetime requirements; a return to SwiftUI-only status presentation would need equivalent public-API behavior and runtime evidence. Locale layout caching is an optimization with correctness tests, not permission to change approved typography. Persistence identifiers remain compatibility contracts even where their names no longer match the visible mode.

## Status, assumptions and open questions

**Implemented:** the capabilities and journeys above are present in source. **Verification pending:** the full runtime/accessibility/lifecycle matrix on the new Mac and minimum supported macOS. Dated builds, installed-candidate checks and App Store receipts in [PROJECT_ANALYSIS_REPORT.md](PROJECT_ANALYSIS_REPORT.md), the [12 October review](COMPREHENSIVE_REVIEW_2026-10-12.md) and [launch checklist](APP_STORE_LAUNCH_CHECKLIST.md) are historical evidence tied to their recorded source, artifact, machine and scope. They do not establish today's account state or validate this Mac.

**Documented intent:** the existing launch materials describe a free App Store release with Romania-only initial availability. This is not a fresh price/territory/account observation. Public release, website-policy approval, installed-candidate acceptance and release authorization remain separate gates. Follow [APP_STORE.md](APP_STORE.md) and inspect current evidence before any separately authorized release work.

**Open questions and prerequisites:**

- Does the current desktop permit the signed XCTest runner to initialize, and can the remaining native/assistive-technology matrix be completed? Earlier runner initialization failures are infrastructure evidence, not passing app scenarios.
- Are sleep/wake, real subsequent login, long-running resource behavior and minimum-OS acceptance demonstrated for the intended shipping candidate? Source behavior and a successful registration call are insufficient evidence.
- What is the current publisher-approved website/support policy and release disposition? Read the [shared business policy](../../../iOS/BluffArtist/BUSINESS_POLICY.md) before legal/public-policy changes. Fresh-Mac discovery found it in the renamed iOS checkout; the former sibling path is obsolete. Its dated facts do not establish current account state or final legal approval.
- No user research or quantitative product success targets were found. Do not invent adoption, reliability or performance claims; treat any future measurement as separately scoped work consistent with the local-only boundary.

Use [PLAN.md](PLAN.md) for the next authorized development outcome and proportional verification. Account changes, public submission, upload/distribution and website deployment require their own authorization.
