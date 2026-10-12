# Core Metrics comprehensive review — 12 October 2026

Current native candidate: **1.0 (9), Apple-validated and upload accepted at 04:08:10.573 EEST on 12 October**. Frozen source: `401f9c2363bb1846a2ae376d7c7b877f49a4cab0`. Starting clean native revision: `938da31f4426cebdb29faa404098e15f661dcfce`; companion website: `ff7ba975c2111c1b03f09b8282b515e8f6297097`. The [build-8 delivery receipt](RELEASE_PREPARATION_2026-10-12.md) and [owner-only beta cleanup](<../../Pe langa/Verification/TestFlightCleanup2026-10-12.md>) remain dated account evidence. The later authenticated account readback on 12 October confirms build 9 processed and **Testing in the sole-owner internal group**, with builds **1–8 Expired**. A fresh post-expiry group read confirms **1 tester / 1 build: 9 Testing, 90 days**, and the tester tab contains only the specified owner. Public draft **9** and its exact **2006-character review notes** are saved and verified after a full reload, including the confirmed company/copyright. The exact 2696-character TestFlight notes are now saved and full-reload verified. The three marketing panels are now uploaded and persisted after fresh app navigation in Selection → Styles → Explanations order (3 of 10). All three remote renders are now visually verified; the earlier third-panel processing wait is resolved. Installed acceptance remains unverified.

## Later artwork-only follow-up — 12 October

The [three-panel marketing pack](app-store/screenshots/marketing-build9/README.md) uses fresh genuine signed build-9 Settings captures and an unchanged earlier build-9 Help capture. Exports are 2560×1600 opaque PNGs; all three passed local and independent visual review, exact source/export checks and byte-identical repeat rendering. Source pixels are never enlarged. All **93/93 frozen inputs** and the signed executable still match; no product, project, version, account or TestFlight state changed. Older window compositions and their raw capture bytes are preserved as dated history.

This later capture temporarily changed only the separately launched distribution app to three stats and cycled its four display modes. A private attachment-only XCTest runner built but timed out while enabling automation before any test method. The Mac then locked. **Cleanup completed after unlock on 12 October:** the coordinator bound Computer Use to the exact signed archive app, dismissed Privacy, and removed Memory Used (%) then Storage Used (%), with fresh accessibility readbacks confirming three → two → one stat. CPU User only, Label and Value, and Launch at Login off/unregistered matched the recorded baseline. Normal Command-Q closed the owned distribution instance; Computer Use reported its process absent, and a shell process check confirmed the ordinary development app remained at its original path. The ordinary app was not configured or terminated; clipboard/login/external-link actions were not used. Release exposes no safe preference CLI, and the denied container read was not bypassed. The screenshot README and private capture checkpoint retain the observations. At this cleanup checkpoint, artwork upload was still pending; cleanup changed neither native source nor the earlier saved gallery. The later upload checkpoint below supersedes only that pending account step.

## Initial marketing upload checkpoint — 12 October, approximately 16:50 EEST (historical)

Authenticated in-app browser uploads accepted all three unchanged English 2560×1600 PNGs. Fresh app navigation verifies **3 of 10**, ordered **01-selection.png → 02-styles.png → 03-explanations.png**, with public build **9**, **Save disabled** and the existing automatic-release selection preserved. The first two branded panels rendered completely in the remote gallery screenshot. **At that checkpoint, the third remained in cloud processing and its complete remote render was not yet verified.** The two earlier product-page associations were removed through recoverable Remove actions; original files remain in Asset Library. No Mac header, new build, public review submission or release occurred.

The independent read-only upload-handoff check matched all three sources, staging copies, committed pixels and approved manifest hashes; dimensions, PNG integrity, opaque 8-bit RGB and sRGB checks pass. Existing local visual reviews remain valid for those exact bytes. At that upload checkpoint, file and account checks did not yet establish complete server-side rendering. The later render verification below resolves that image-processing gate without establishing release readiness. Earlier picker failures and the earlier two-image gallery below retain their original observation dates.

### Final remote render verification — 12 October

After the approximately **16:50 EEST** third-panel processing observation above, fresh app navigation confirms all **three** images are draggable in the exact saved order, **3 of 10**. DOM-backed inspection confirms all three Apple CDN image elements are complete with positive natural width. The third image's full preview was opened and visually checked: **“Know what the numbers mean.”**, the genuine native Help sheet and the correct brand background are complete. Together with the earlier first-two-panel inspection, **3/3 remote visual checks pass**. The processing gate for this Core artwork set is resolved. No native binary/image bytes changed, and no public submission or release occurred.

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

The exact **2006-character [App Review notes](APP_REVIEW_BUILD_9_NOTES_EN.txt)** are saved and full-reload verified with public draft 9. The exact **2696-character [build-9 TestFlight notes](TESTFLIGHT_BUILD_9_NOTES_EN.txt)** are now saved and verified after a full reload, with heading **1.0 (9)**, matching text and **Save disabled**. Earlier attempts could not focus/type in the blank What to Test field. After a fully loaded reload, native double-click in the blank area followed by paste worked; the coordinator compared the full text before saving, observed Saved, and then verified persistence. This supersedes the beta-note input blocker only. Build 9 was committed/pushed and frozen to **93 runtime/project/test/tooling inputs**, archived with final Xcode and the retained authorized release configuration (only its build number changed), then Apple-validated and uploaded. Strict checks pass **24/24 archive**, **25/25 exported installer** and **25/25 actual-upload installer**, including identity, version, macOS 27/arm64, confirmed copyright, hardened runtime, exact sandbox entitlements, privacy manifest, DEBUG exclusion, icons, permissions and matching dSYM. Independent peer review also matched all 93 inputs to Git and freshly checked both app signatures/metadata. The actual uploaded package is **1,995,072 bytes**, SHA-256 `054bbfb438a06312c8f3e18258269b08923d15606eb3aa29f4f04689cb5f8d5c`; it is distinct from the locally exported **1,995,048-byte** package (`330f2d2834b2a5f3b3729d614b843ea1378722f549ec690becbdc054c8cbd944`). Exact copies, expansion, logs and receipts remain in the ignored build-9 release directory. No frozen runtime/project/validation input changed after upload. The coordinator independently verified processing, sole-owner-group Testing, expiry of all builds 1–8 and public-draft 9 selection in App Store Connect. These are account observations, not inferences from local checks. Earlier screenshot attempts kept Upload disabled. A later upload of **core9-01-settings.jpg** succeeded; subsequent Metric Help upload attempts remained disabled despite reloads, exact paths and byte-identical temporary copies. The final gallery instead retains the existing **02-metric-help.jpg**, independently proven byte-identical to the current export. A full reload confirms **2 of 10**, ordered **core9-01-settings.jpg → 02-metric-help.jpg**, with Save disabled. Both Asset Library detail images rendered fully and were visually inspected, with recent usage in macOS App Version 1.0 (English US) at Today 5:24 AM; gallery thumbnails remain blank in the account renderer. Old Settings/Preferences version associations were removed with Asset Library originals explicitly preserved. At that earlier account checkpoint, the two-image gallery was complete and accurate; the optional Preferences composition remained local. The later three-panel marketing upload above supersedes that saved gallery. [Capture and remote-asset provenance](app-store/screenshots/README.md) preserves the original three-image plan and these delivery limits. Exact prepared text is 2696 TestFlight / 2006 App Review characters when trimmed.

The isolated light-appearance Debug9 fixture was inspected through native accessibility and an actual screenshot: the scrollbar reaches the entire footer, Version 1.0 (9), copyright and restore explanation are visible without clipped controls. The fixture quit normally; all baseline application processes remained running. Private evidence is `VisualDebug9/settings-footer-light.png` and `ownership.json` alongside the logs. This confirms the focused footer rendering, not full keyboard/VoiceOver acceptance or genuine App Store artwork. A subsequent genuine signed Release 9 capture now confirms Settings top/lower footer and Metric Help in dark appearance. All three images were visually inspected; Escape dismissed Help, the owned candidate quit, all baseline app processes stayed running, and the executable/signature remained unchanged. No setting, clipboard, mail or login control was changed. See the capture provenance and the earlier two-image gallery evidence above; the later marketing upload has its own processing boundary. Broader current desktop behavior, VoiceOver and accessibility display settings, constrained menu-bar space, sleep/wake, a complete login cycle, installed TestFlight acceptance and minimum macOS **27.0** acceptance remain separate from this macOS 27.2 non-GUI run. Reachable hardware is not evidence that the delivered candidate is installed.

Website legal notices remain marked drafts with noindex and failed-closed publication approval. Confirmed ownership does not approve final legal wording, verify provider retention/transfers, prove mailbox delivery or authorize a public App Review submission/release. Preserve the remaining facts in the shared policy.


## Later bounded desktop authorization check — 12 October 2026

At 19:53 EEST, one correctly selected current-source Settings-width XCTest
completed its fresh ad-hoc Debug build but failed during runner initialization:
“Timed out while enabling automation mode.” The result records one runner
infrastructure failure, zero passes and no scenario body; earlier rejection of
a selector missing the target's space was a separate command error. Read-only
macOS status reports Automation Mode disabled with user authentication required;
DevToolsSecurity reports developer mode disabled. No permission dialog appeared
in the observed Xcode state or app inventory. These statuses identify the
remaining authorization boundary, not a proven product defect or a guarantee
that changing one setting resolves it. No TCC/security setting was changed.

The attempt used a dedicated DerivedData/result folder, two Xcode jobs, the
existing isolated test suite/fake login/no-op clipboard controls and a 240-second
outer limit (not reached). The installed development app's executable hash is
unchanged; no Core app/runner process remained afterwards. Logs, command,
result summary and status receipts are retained under
`~/Library/Logs/PortfolioReleaseContinuation20261012/core-desktop-corrected/`.
At that checkpoint no TestFlight candidate was installed. The later actual
installation is recorded below. The latest invitation/availability status is in
the current launch checklist; no release input or native source changed.


## Actual TestFlight build-9 manual checkpoint — 12 October 2026

At approximately 19:58–20:02 EEST, after the owner-authorized resend and
successful redemption, the official TestFlight page independently showed Core
Metrics **1.0 (9)** with **Open**, **Works on this Mac**, 90 days and the current
support address. It was already installed when inspected; the agent used Open
rather than claiming to have performed the install. The installed location is
`/Applications/Core Metrics 2.app`, bundle `com.dorobantimedia.CoreMetrics`,
version/build **1.0 (9)**. Strict signature verification passes and an Apple
receipt is present. Its executable SHA-256 is
`e7b75dacfe8a2f139c8e76b7134588d932bb2704704c54ddc39f18c6964be2e2`.
This is distinct from both the local signed archive and the unchanged old
`org.example.CoreMetrics` build-1 application.

The preceding local-archive alternative had a Launch Services/CUA timeout and
prevent-launch assertion; its transient process was gone before the TestFlight
checks and no local-archive UI interaction was completed. No signing change was
made to force launch.

Observed manual checks on the actual installed TestFlight candidate:

- Initial Settings: CPU User only, Label and Value, Launch at Login off with no
  registration; footer visibly identifies **Version 1.0 (9)**.
- Added Memory Used (%) and Storage Used (%) and cycled Compact, Icon and Value,
  Values Only and Label and Value. Each selection and live preview updated;
  four window captures were visually inspected.
- Added CPU Used, CPU System, CPU Idle and Memory Used. The canonical list grew
  to seven, Add Stat became disabled and the full accessibility preview retained
  all seven readings. The horizontally scrollable preview intentionally exceeds
  the viewport for long selections; no claim of every stat visible at once.
- Metric Help opened with its explanations; Escape dismissed it. Privacy
  opened with current local-data/support explanations and correct displayed
  email/website destinations; Done dismissed it. No external link was activated.
- Normal Quit followed by rebinding the installed path produced a new process
  identifier and retained all seven choices and Label and Value. CUA's immediate
  post-Quit read timed out; the subsequent process/readback established the
  relaunch and persisted preferences.
- Restore Defaults returned CPU User only / Label and Value, with removing the
  last reading disabled. Launch at Login remained off/unregistered. A final
  normal Quit followed by observation of TestFlight left no Core process.

The attempt to scroll a sheet through CUA returned `noWindowsAvailable` twice;
Page Down did not visibly advance the Privacy sheet. The app remained running
and both sheets dismissed normally. Complete sheet scrolling remains unverified,
not recorded as a product failure. The real menu-bar popover and constrained
space/outside-click behavior, spoken VoiceOver and display-accessibility matrix,
sleep/wake, a full login cycle and minimum macOS **27.0** remain separate; this
host is macOS **27.2**. No XCTest pass is inferred from the manual observations.

Private captures/readbacks, installed identity and cleanup receipts are under
`~/Library/Logs/PortfolioReleaseContinuation20261012/core-testflight-manual/`,
with the official TestFlight page in `core-testflight-build9-installed.png`.
Final executable hashes match initial values for the installed TestFlight and
old development apps. No clipboard, login-item, external-message or security
setting was changed. No native source, project, frozen release input, App Store
declaration or public App Review state changed.

At 20:08 EEST, a final bounded keyboard follow-up on that same TestFlight copy
showed a visible Live Preview focus ring. Further Tab/Option-Tab did not visibly
traverse the Settings controls, so complete keyboard use remains unverified.
The app accessibility tree and window screenshot did not expose the real
menu-bar status item; Control-F8 did not make it observable and selecting
SystemUIServer timed out. No status-item position was guessed. Command-F5
produced no observed VoiceOver process or prompt, and no further system toggle
was attempted; accessibility labels are not evidence of spoken VoiceOver use.
These are bounded interaction/tool limitations, not diagnosed product failures.
No security setting, clipboard, login registration, sleep or login/logout action
was used. `final-baseline.txt` again confirms CPU User only / Label and Value /
Launch at Login off; `final-cleanup.json` confirms normal Quit left no Core or
VoiceOver process and both installed executable hashes remain unchanged.
