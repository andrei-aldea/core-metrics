# Core Metrics release preparation — 12 October 2026

The owner authorized further fixes, commit/push, a new TestFlight build and App Store Connect preparation. Public App Review submission, a public release and legal approval are not implied. Earlier 11 October work and dated release evidence remain preserved.

## Candidate scope and configuration

This candidate adds an explicit privacy-request email action in the native Privacy sheet and explains the exact scope of Restore Defaults in Settings. It changes no metric calculation, sampling, persistence format, sandbox entitlement, purchase behavior or network architecture. The English interface and macOS 27 / Apple silicon requirements remain.

The tracked development identity remains neutral and version/build remains 1.0 (1). Distribution uses the existing ignored private release configuration. The live App Store Connect check on 12 October confirmed app record **6808253200**, build **1.0 (7)** Complete in Build Uploads (8 October, 18:29), and no newer upload. Candidate **1.0 (8)** is reserved for this change. Build 7 is Ready to Submit with no group; build 6 is Testing in both existing groups. Do not duplicate the accepted build-7 upload. The app-record identifier does not establish public storefront availability.

Create the candidate only after source review and a source commit; fingerprint runtime/resource/project inputs and test/validation tooling. Reuse the existing signing/export approach, normal readable bundle permissions inside private artifact storage, and accepted Xcode 27.0 (27A266a). Preserve the archive, dSYM, installer and receipt. Validate identity, version, architecture, signature, sandbox, hardened runtime, privacy manifest, permissions and exclusion of Debug fixtures in both the archive and expanded exported package before Apple validation/upload.

## Current local evidence

- Debug and Release builds, 75 Swift Testing cases (173 executions), static analysis, source/packaged metadata, sandbox/privacy, permission fixtures, concurrency/configuration guards and whitespace pass on 12 October. Three known AppIntents metadata warning lines remain; no other warnings or DisplayManager rectangle diagnostics.
- Validation evidence: `core-metrics-validation.NFyYXC` under the local temporary directory. No desktop XCTest suite ran in this pass because it terminates earlier instances of the same development app; the user’s running app must be preserved.
- The unchanged Settings/Privacy changes received the targeted native visual check on 11 October, including complete scrolling, explicit email action and dismissal. That is not a new archive/TestFlight acceptance pass or a full VoiceOver, appearance, menu-bar geometry, login-cycle, sleep/wake or minimum-OS pass.
- The website has a new 12 October bilingual copy and contact-flow revision. App UI and support copy remain aligned. Legal approval/effective date are pending, with draft/noindex gates retained. Shared confirmed and unknown facts are in [BUSINESS_POLICY.md](<../../Pe langa/BUSINESS_POLICY.md>).

## App Store Connect actions

Keep English (U.S.), Utilities and the existing public app name. Recheck saved Free pricing and Romania distribution independently. Use the existing support URL `https://core-metrics.dorobantimedia.com/en/support`, marketing URL `https://core-metrics.dorobantimedia.com/en` and privacy URL `https://core-metrics.dorobantimedia.com/en/privacy`. Support/privacy email is `support@dorobantimedia.com`; account-specific review contact stays in App Store Connect only. Sign-in is not required.

Refresh the Settings screenshot from the accepted real candidate, preserving provenance and excluding Debug/sample fixtures. Existing Metric Help artwork should only be reused after matching it to current UI. The live 12 October public-draft check still shows build 5 selected, copyright blank and automatic release selected. Support and marketing URLs are correct; the review-contact email still uses the prior general company address. Account metadata work must reconcile that field with the confirmed app contact without inventing personal review-contact details. Actual copyright ownership, release/territory choices, complete legal notices and the final app-privacy assessment must not be inferred from a binary upload. The source remains on-device, but actual optional support and developer-held TestFlight processing require their own assessment.

## Prepared App Review notes

New candidate copy; not a claim of a saved account field. 1918 characters / 1920 UTF-8 bytes.

```text
Core Metrics is a macOS menu-bar utility. It requires macOS 27 or later on a compatible Apple silicon Mac. The interface is in English; numeric formatting follows the macOS locale.

1. Launch the app and locate its live readings in the menu bar. There is intentionally no Dock icon or main app window. Allow a few seconds for the initial CPU sample.
2. Click the status label to open the persistent selection panel. Choose one to seven CPU, Memory and Storage stats. The panel remains open as choices change.
3. Use Settings in the panel footer to open the native Settings window. Menu Bar Text changes the representation; all four modes remain available for every selection count. Add Stat and the remove controls change the selection. Live Preview can scroll horizontally.
4. Copy Readings in the panel footer writes the full selected names and current values to this Mac’s clipboard. It is an explicit action, replaces the current clipboard content and excludes these copies from Universal Clipboard.
5. Metric Help, Support and Privacy are available in Settings. The Privacy sheet opens the public policy or a privacy-request email with a subject only; no readings are attached or sent automatically. Restore Defaults returns the selection to CPU User and Label and Value, leaving Launch at Login unchanged. Launch at Login is optional and reflects macOS registration or approval state. No helper or administrator access is required.
6. Quit in the panel footer exits the app.

The app reads aggregate system values through public Apple APIs. It has no accounts, network connections, purchases or retained metric history. A dash indicates an unavailable reading. Storage represents startup-volume capacity, not a file scan. Long selections need sufficient menu-bar space; Compact, Icon and Value, or Values Only use less room. If the readings are hidden, open the already-running app in Finder to recover Settings.
```

## Prepared TestFlight What to Test

New candidate copy; no tester invitation, group assignment or account save is claimed. 2607 characters / 2607 UTF-8 bytes.

```text
Please test Core Metrics on macOS 27 or later on a compatible Apple silicon Mac. The interface is in English; numbers follow your locale.

1. Launch the app, find its readings in the menu bar, and allow a few seconds for the first CPU sample. There is no main window or Dock icon.
2. Open the selection panel and try one, three and seven readings from CPU, Memory and Storage, including several from one category. Choices should update immediately in canonical order while the panel stays open. At least one and at most seven must remain selected.
3. Open Settings and repeatedly change between Label and Value, Compact, Icon and Value, and Values Only. All modes should support every selection count and retain complete values and units. Use Add Stat, remove controls and the horizontally scrollable Live Preview. Reopen Settings, then quit and relaunch, and check that choices are saved.
4. Watch changing readings with an unchanged selection and mode. The status item should keep its allocated width and position; changing selection or mode may resize it. If a long selection is hidden, open the already-running app from Finder to recover Settings and choose fewer readings or a narrower mode.
5. Confirm that checkbox clicks keep the panel open, another status-item click closes it, and real outside clicks or Escape dismiss it. Reopen it after each dismissal. Settings and Command-comma should close the panel and raise Settings.
6. Check the clearer Help and Preferences section in Settings. Restore Defaults should return to CPU User in Label and Value while leaving Launch at Login unchanged. Open Privacy, scroll to Support and Privacy Requests, and check the publisher and support address. Email a Privacy Request should open your email app with a subject only; sending is your choice. Help and Privacy should scroll and close with Done, Return or Escape. Use Copy Readings only when you want to replace this Mac's clipboard, and check its full selected names, values and Copied feedback.
7. On a test setup, check sleep/wake recovery, VoiceOver, keyboard traversal and accessibility display settings. If testing Launch at Login, use an installed signed copy and your own explicit choice; macOS manages registration and approval separately from menu-bar defaults. A real login cycle and minimum macOS 27.0 acceptance remain separate from local automated tests.

A dash means a reading is unavailable; CPU needs a baseline after launch or a sampling gap. Swap may be unavailable while other memory readings remain valid. The app saves no metric history and does not inspect processes or scan files.
```
