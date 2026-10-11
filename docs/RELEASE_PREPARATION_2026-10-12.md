# Core Metrics release preparation — 12 October 2026

The owner authorized further fixes, commit/push, a new TestFlight build and App Store Connect preparation. Public App Review submission, a public release and legal approval are not implied. Earlier 11 October work and dated release evidence remain preserved.

## Candidate scope and configuration

This candidate adds an explicit privacy-request email action in the native Privacy sheet and explains the exact scope of Restore Defaults in Settings. It changes no metric calculation, sampling, persistence format, sandbox entitlement, purchase behavior or network architecture. The English interface and macOS 27 / Apple silicon requirements remain.

The tracked development identity remains neutral and version/build remains 1.0 (1). Distribution uses the existing ignored private release configuration. The live App Store Connect check on 12 October confirmed app record **6808253200**, build **1.0 (7)** Complete in Build Uploads (8 October, 18:29), and no newer upload. Candidate **1.0 (8)** was subsequently archived from committed `df1e22607892b5829f5887d8f80d4e94fe3f8dad`, validated and accepted by Apple for upload on 12 October. The later authenticated check confirms build 8 Complete. Its existing internal-group assignment and exact saved notes are recorded below; zero internal testers means no installed testing is established. The earlier check recorded build 7 Ready to Submit with no group and build 6 Testing in both existing groups. Do not duplicate the accepted build-7 upload. The app-record identifier does not establish public storefront availability.

The candidate was created after source review and a source commit, with frozen runtime/resource/project and test/validation fingerprints. It reused the existing signing/export approach, normal readable bundle permissions inside private artifact storage, and accepted Xcode 27.0 (27A266a). The archive, dSYM, installer and receipt are preserved. Identity, version, architecture, signature, sandbox, hardened runtime, privacy manifest, permissions and exclusion of Debug fixtures passed in both the archive and expanded exported package before Apple validation/upload.

## Current local evidence

- Debug and Release builds, 75 Swift Testing cases (173 executions), static analysis, source/packaged metadata, sandbox/privacy, permission fixtures, concurrency/configuration guards and whitespace pass on 12 October. Three known AppIntents metadata warning lines remain; no other warnings or DisplayManager rectangle diagnostics.
- Validation evidence: `core-metrics-validation.NFyYXC` under the local temporary directory. No desktop XCTest suite ran in this pass because it terminates earlier instances of the same development app; the user’s running app must be preserved.
- The unchanged Settings/Privacy changes received the targeted native visual check on 11 October, including complete scrolling, explicit email action and dismissal. That is not a new archive/TestFlight acceptance pass or a full VoiceOver, appearance, menu-bar geometry, login-cycle, sleep/wake or minimum-OS pass.
- The website has a new 12 October bilingual copy and contact-flow revision. App UI and support copy remain aligned. Legal approval/effective date are pending, with draft/noindex gates retained. Shared confirmed and unknown facts are in [BUSINESS_POLICY.md](<../../Pe langa/BUSINESS_POLICY.md>).

## App Store Connect actions

Keep English (U.S.), Utilities and the existing public app name. Recheck saved Free pricing and Romania distribution independently. Use the existing support URL `https://core-metrics.dorobantimedia.com/en/support`, marketing URL `https://core-metrics.dorobantimedia.com/en` and privacy URL `https://core-metrics.dorobantimedia.com/en/privacy`. Support/privacy email is `support@dorobantimedia.com`; account-specific review contact stays in App Store Connect only. Sign-in is not required.

The screenshot set was refreshed from the accepted real candidate, preserving provenance and excluding Debug/sample fixtures. The final upload/readback is recorded below. The first live 12 October public-draft check showed build 5 selected, copyright blank and automatic release selected. A subsequent authenticated save/reload verified copyright `2026 DOROBANTI NETWORK S.R.L.`, review-contact email `support@dorobantimedia.com` and the exact 1918-character review notes below. Support and marketing URLs remain correct, Sign-in required remains off, and automatic release remains selected. Build 5 was still selected at that check, pending candidate-8 processing. Actual copyright ownership, release/territory choices, complete legal notices and the final app-privacy assessment must not be inferred from a binary upload. The source remains on-device, but actual optional support and developer-held TestFlight processing require their own assessment.

## Prepared App Review notes

Saved and verified exactly after an authenticated App Store Connect reload on 12 October. 1918 characters / 1920 UTF-8 bytes.

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

Saved for build 8 and verified exactly after an authenticated reload on 12 October, with Save disabled. 2607 characters / 2607 UTF-8 bytes. Existing Internal Testers was subsequently assigned. The later external beta submission below reused these exact notes; no new tester or group was created.

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

## Validated upload and production delivery

Native source commit `df1e22607892b5829f5887d8f80d4e94fe3f8dad` is pushed. The retained private release configuration produces **1.0 (8)** without changing the neutral tracked development identity. The archive passes **23/23** checks and the expanded exported installer **24/24**, including identity/version, arm64/minimum OS, authorized signatures, sandbox/hardened runtime, exact privacy manifest, normal bundle permissions, icon slots/approved bytes, matching dSYMs and exclusion of Debug fixtures. Apple validation and upload both finish with exit code 0 and explicit success markers. Post-upload committed-input, runtime/test/tooling/configuration fingerprints still pass. The private archive, dSYMs, installer and receipts remain ignored. This receipt establishes upload acceptance; the later account readback below establishes completed processing, but not installed acceptance.

Website source `3cd28153fbacad99388071c0e91832d39cc4caff` is pushed and Vercel deployment `dpl_8rCzogVB7Dmc2Vfe9nXof6Y1Cvok` is READY in production with the correct custom-domain alias. All ten public pages return 200, retain draft/noindex state and the current support address and legal revision. Six production Chromium checks and two WebKit mobile-contact checks pass. The [website receipt](<../../core-metrics-website/docs/audit/RELEASE_PREPARATION_2026-10-12.md>) owns its full validation and known GitHub billing block.

No public App Review submission, release, new tester invitation, legal approval or mailbox delivery test occurred in this delivery. Broader installed runtime/accessibility acceptance and the remaining privacy/support operational facts are still open.

## Genuine candidate capture and policy follow-up

The real uploaded archive app was opened separately from the ordinary running development app. Fresh Settings top/lower and Metric Help captures now produce three **1280×800** opaque JPEG compositions; [assets and exact provenance](app-store/screenshots/README.md) distinguish source-window dimensions from the marketing canvas. Privacy support text, explicit email action, lower scrolling and Done/Escape dismissal were also inspected. No settings/login/clipboard/mail action was changed. The owned candidate quit normally and the user's original process remained running. Initial CUA timeout and one noWindowsAvailable response recovered by rebinding; no app crash was observed. This targeted dark-appearance check is not complete runtime or installed-TestFlight acceptance.

The owner further confirmed Trash emptying and removal of downloaded attachments/exports at the routine 90-day-after-resolution deadline, plus no downloading or retaining TestFlight feedback/crash reports. The website's equivalent EN/RO drafts and current input lists now include these facts. Forwarding, local/device/provider backups/recovery, in-console beta use and other beta records, exception periods, provider arrangements and legal approval remain unresolved. No native runtime change or replacement upload is needed for this website/legal clarification.

## Final authenticated account readback — 12 October

Build Uploads lists **1.0 (8) Complete**, dated 12 October at **00:41**. The distribution build picker displays the processed build at **00:42**; both are their respective Apple UI timestamps. The exact What to Test text above was checked before Save, then compared again after reload: **2607 characters, exact match, Save disabled**.

Build 8 was added to the **existing Internal Testers** group. Its page shows **0 testers**, **3 builds** (2, 6 and 8) and build 8 **Ready to Test**, expiring in 90 days. At that first assignment check, the overall build list said **Ready to Submit**. No user was invited or group created. The later external submission below supersedes that initial no-external-assignment state. Ready to Test with zero testers must not be described as active Testing or installed acceptance.

The public macOS 1.0 draft was changed from build **5 to 8** using Add Build, then saved. The build-8 row was visible and **Save became disabled**. Copyright, shared review email, the complete 1918-character review notes, correct support/marketing URLs, Sign-in required off and automatic release remained intact. Safari then stalled during reload, including one bounded navigation retry. A later fresh-tab check recovered the page and verified **build 8 persisted, Save disabled**, the exact notes and the same contact/copyright/sign-in/release fields. No Add for Review or public release action was taken.

The page initially contained the two older screenshots. After Safari recovered in a fresh tab, all three new build-8 JPEGs uploaded successfully. The temporary five-image old/new set was cleared using the version-association removal control, whose confirmation explicitly retained the assets in Asset Library, then the three current files were attached in their intended order. Apple’s remote viewer rendered every image completely and each was visually inspected, including the revised Restore Defaults wording in Preferences. A fresh 12 October reload confirms **3 of 10** in exact order: **01-settings.jpg → 02-metric-help.jpg → 03-preferences.jpg**. Earlier assets and local provenance remain preserved. No screenshot or app binary was synthesized or changed during this upload. Remaining public-launch fields, legal approval and installed-candidate acceptance remain separate.

## Existing external tester delivery — 12 October

The owner’s request to put the new builds into TestFlight authorized delivery to existing testers, including the required Beta App Review step. The authenticated External Testers page retained **one Accepted tester** and no public link; five older builds were already associated. Build **1.0 (8)** was selected through Add Build to Group. The What to Test form matched the exact **2607-character** text above and its existing **Automatically notify testers** option remained checked. Submit for Review was the beta-only action; it presented no new business, privacy or legal attestation.

The group immediately showed six builds with **1.0 (8) Waiting for Review**. A fresh reload verified that same group count and status. At that observation this was queued Beta App Review, not external Testing, installation or public App Review. The existing internal group still has zero testers; the earlier Ready to Test observation is not installed acceptance. No tester or group was created, no public link was enabled, no invitation was resent and no public version was submitted or released. Apple’s decision and subsequent installed-candidate acceptance were outstanding at that observation; the later group readback below supersedes the review status. No application source or binary changed, and no duplicate upload is needed.

## External build 8 available — 12 October, approximately 01:52 EEST

A fresh authenticated Safari read of the actual **External Testers → Builds** page confirms **1 tester / 6 builds** and the **1.0 (8) Testing** row, expiring in **90 days**. This is independent group-level evidence, in addition to the macOS build inventory showing Testing; it supersedes the earlier Waiting for Review observation without erasing it. The existing tester had previously been confirmed Accepted. No new group, tester, invitation or public link was created.

The beta is now available to the existing external tester. Installation, launched sessions and acceptance of the installed candidate remain unverified. This readback did not alter the prepared public draft or submit public App Review/release, and no source/binary change, new test pass or duplicate upload is claimed.
