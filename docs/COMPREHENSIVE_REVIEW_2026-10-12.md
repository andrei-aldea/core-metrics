# Core Metrics comprehensive review — 12 October 2026

Current native candidate: **1.0 (9), locally validated, not yet archived or uploaded at this checkpoint**. Starting clean native revision: `938da31f4426cebdb29faa404098e15f661dcfce`; companion website: `ff7ba975c2111c1b03f09b8282b515e8f6297097`. The [build-8 delivery receipt](RELEASE_PREPARATION_2026-10-12.md) and [owner-only beta cleanup](<../../Pe langa/Verification/TestFlightCleanup2026-10-12.md>) remain dated account evidence. Build 8 is currently Testing for the sole specified owner; build 9 is a new source candidate, not an observed App Store Connect state.

## Outcome and scope

The review covered application lifetime and native status/popover ownership; off-main CPU, memory and volume acquisition and pure calculations; cancellation/restart behavior; immutable snapshots and locale-aware text/layout; preference validation and legacy migrations; all Settings/help/privacy views; public contacts; fixtures, unit/UI tests, assets, privacy declarations, build configuration and release tools. SwiftUI Pro and UI/UX guidance informed the pass, with macOS native conventions taking precedence over mobile patterns. The [website review](<../../core-metrics-website/docs/audit/COMPREHENSIVE_REVIEW_2026-10-12.md>) covers its complete route, component, bilingual copy, dependency and publication surfaces.

| Area | Finding and disposition |
| --- | --- |
| Native Settings and support | Support asks users for their app version but Settings did not expose it. The Help and Preferences footer now displays the actual bundled version/build as selectable text. It retains the existing Restore Defaults explanation. |
| Ownership | The owner confirmed DOROBANTI NETWORK S.R.L. and creation year 2026 in [shared policy](<../../Pe langa/BUSINESS_POLICY.md>). Debug and Release bundle metadata now contain the copyright, also shown in the footer. No registration or third-party ownership claim was added. |
| App structure and UI | Retained the small menu-bar application, native controls, 580-point Settings content, four display modes, one-to-seven selections and complete metric context. No dashboard, onboarding flow or new preference was justified. |
| Correctness and concurrency | No additional reproducible source defect found. Retained weak sampling ownership, obsolete-generation rejection, independent swap failure, pure formula validation, locale/direction handling and stable point-based status allocation. |
| Data and permissions | Preserved local aggregate readings, no metric history/network/accounts/purchases, app-only preferences, explicit host-only copy and optional OS-managed login. Automated checks use isolated preferences, named pasteboards and fake login services. |
| Dead code and resources | No native removal justified. Legacy preference identifiers/decoders, DEBUG fixtures and icon variants remain required despite low reference counts. The website's unused UI wrappers and their exclusive dependencies were removed after caller/configuration searches. |
| Tests | Existing calculation, layout, formatting, persistence, concurrency, provider, copy and login tests provide useful behavior coverage. No tests added that merely repeat new copyright text. |

## Local validation

Final Xcode 27.0 (`27A266a`) was selected per command without changing the machine-wide toolchain. Commands used a private isolated DerivedData folder and at most four jobs. No desktop XCTest runner was launched and the ordinary running app, clipboard and login settings were not manipulated. A separately copied/ad-hoc-signed Debug9 fixture used the existing isolated preference suite, fake login service and no-op clipboard writer for a focused native inspection.

- Debug hosted unit run: **75 distinct cases / 173 executions, zero failures, skips or expected failures**, on macOS 27.2. Final footer/copyright source was included; the later build-number-only change was followed by fresh Debug and Release builds.
- Final Debug and Release **1.0 (9)** builds pass. Both packaged plists independently match version/build and `Copyright © 2026 DOROBANTI NETWORK S.R.L.`.
- Xcode analysis, source privacy/sandbox policy, bundle-permission regressions, resolved-concurrency regressions and final packaged-artifact validation pass. Release excludes known DEBUG fixture markers.
- No Swift/concurrency errors or analysis warnings. Earlier full builds emitted only Xcode's App Intents metadata-extraction notice because the app has no AppIntents dependency; final incremental build-9 logs have no warnings.
- Xcode resolves hardened runtime off for the unsigned Debug development product despite the source setting, as already documented; Release resolves it on. Unsigned checks do not establish effective distribution signing or entitlements.

Private evidence: `CoreMetricsComprehensive20261012-uddkj7t4` in the system temporary directory, including `UnitTests.xcresult`, `debug-unit.log`, `analyze.log`, `final-debug9.log`, `final-release9.log` and the four policy/regression logs. Machine/account identifiers and generated products remain outside Git.

## Delivery and remaining acceptance

The [build-9 TestFlight notes](TESTFLIGHT_BUILD_9_NOTES_EN.txt) and [App Review notes](APP_REVIEW_BUILD_9_NOTES_EN.txt) are prepared for exact authenticated save/readback. Build 9 must be frozen to a reviewed commit, archived using the retained authorized release configuration, validated as a signed archive and installer, Apple-validated and uploaded. Processing, new-group assignment, build-8 expiry, public-draft selection and screenshot replacement are separate observed actions; none is inferred from local checks. The old screenshots do not show the new footer.

The isolated light-appearance Debug9 fixture was inspected through native accessibility and an actual screenshot: the scrollbar reaches the entire footer, Version 1.0 (9), copyright and restore explanation are visible without clipped controls. The fixture quit normally; all baseline application processes remained running. Private evidence is `VisualDebug9/settings-footer-light.png` and `ownership.json` alongside the logs. This confirms the focused footer rendering, not full keyboard/VoiceOver acceptance or genuine App Store artwork. A real signed Release9 Settings capture remains needed. Broader current desktop behavior, VoiceOver and accessibility display settings, constrained menu-bar space, sleep/wake, a complete login cycle, installed TestFlight acceptance and minimum macOS **27.0** acceptance remain separate from this macOS 27.2 non-GUI run. Reachable hardware is not evidence that the delivered candidate is installed.

Website legal notices remain marked drafts with noindex and failed-closed publication approval. Confirmed ownership does not approve final legal wording, verify provider retention/transfers, prove mailbox delivery or authorize a public App Review submission/release. Preserve the remaining facts in the shared policy.
