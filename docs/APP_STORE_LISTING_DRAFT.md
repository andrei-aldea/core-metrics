# App Store listing — current draft and saved fields

**Fresh field review — October 8, 2026:** the public version remains **Prepare for Submission**, with build **1.0 (5)** selected. Both screenshots are persisted in the intended Settings → Metric Help order. The existing four-mode description, review notes, URLs and private review-contact fields match the saved draft; Sign-in required remains off and copyright remains empty. The revised 1,640-character description and 1,768-byte review notes below were saved and verified exactly after a fresh reload; Save was disabled. TestFlight delivery and candidate acceptance are recorded separately in the [launch checklist](APP_STORE_LAUNCH_CHECKLIST.md). No public submission or release has occurred.

| Field | Current evidence |
| --- | --- |
| Review contact and instructions | Private contact fields are populated; private values are not stored here. Revised four-mode notes with the English-interface clarification were saved and verified exactly after reload October 8. |
| Sign-in required | Off; no demo account is needed. |
| Support URL | https://core-metrics.dorobantimedia.com/en/support |
| Marketing URL | https://core-metrics.dorobantimedia.com/en — saved |
| Privacy Policy URL | https://core-metrics.dorobantimedia.com/en/privacy — saved; policy itself still needs factual completion/approval. |
| Age rating | Questionnaire completed from implemented features: **4+ with regional exceptions**, no Made for Kids categorization or override. |
| Content Rights | Saved No: the utility contains no third-party content feed, media or remote content. Native system UI/SF Symbols remain platform resources. |
| Screenshots | Two real-build 1280×800 opaque JPEGs are persisted, freshly verified October 8 in Settings → Metric Help order. Their current UI content was also visually rechecked against source. [Assets and provenance](app-store/screenshots/README.md). |
| Copyright / storefronts | Actual copyright owner remains unresolved. Romania is the confirmed launch intention; saved availability still requires verification, and wider distribution is a separate choice. Free pricing is already saved; pricing regions do not configure availability. |
| App Privacy | Saved **Data Not Collected** draft remains unpublished. Final assessment and policy completion are separate from saving the URL. |
| Release control | Automatic release remains selected. Choose manual release before submission if a separate launch decision is wanted. No public review submission occurred. |

Use the [current launch checklist](APP_STORE_LAUNCH_CHECKLIST.md) for the remaining facts, native acceptance and authorization sequence.

## English listing copy

Use Memory and Storage in UI references, with Used (%) for selectable percentage variants. This local draft reflects all four display modes and their shared text size. Reconcile it with the saved online copy before submission.

Apple limits the name and subtitle to 30 characters each. Promotional text allows 170 characters, the plain-text description 4,000 characters, and keywords **100 bytes**. The ASCII keyword draft below also meets a 100-character limit. [App information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information), [platform version information](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information).

| Field | Draft | Length |
| --- | --- | --- |
| Name | Core Metrics: Mac Stats | 23 / 30 characters; retain the existing name |
| Subtitle | CPU, memory and disk usage | 26 / 30 characters |
| Promotional text | Keep CPU, memory and startup-disk readings in your menu bar. Choose the stats you need, adjust their display and copy a current snapshot. | 137 / 170 characters |
| Keywords | monitor,system,performance,ram,storage,processor,swap,capacity,desktop,utility | 78 / 100 bytes |
| Platform | macOS | Existing app target |
| Primary category | Utilities | Confirmed saved in App Store Connect; matches the current Xcode category |
| Primary language | English (U.S.) | Confirmed existing primary language and version locale; retain it |
| Price | Free | Saved zero-price schedule for 175 pricing countries/regions; verified after reopening. Distribution availability remains pending. |

Description — **1,640 / 4,000 characters**; paste only the following plain text:

```text
Keep an eye on your Mac's CPU, memory and startup-volume storage from the menu bar.

Choose one to seven readings and keep the numbers you need within reach. Open the status panel to change your selection while the panel stays open.

CPU, memory and storage
See aggregate CPU Used, User, System and Idle percentages. Check memory use, wired and compressed memory, cached files, swap and physical memory. View startup-volume used space, free space, total capacity or used percentage.

Your preferred view
Choose Label and Value, Compact, Icon and Value, or Values Only in Settings. Every mode supports one to seven readings at the same native text size. A live preview shows your full selection. The app interface is in English. Numbers follow your locale, and your choices are saved for next time. Available menu-bar space depends on your Mac and other menu-bar items.

Current readings, ready to use
Copy Readings copies the full names and current values of your selected stats. Metric Help in Settings explains what each reading means. CPU and memory refresh about every two seconds; storage refreshes about every thirty seconds. No metric history is saved.

Local by design
Core Metrics runs on your Mac without accounts, network connections, analytics, tracking or advertising. Only menu-bar preferences are saved by the app. Launch at Login is optional and managed by macOS. Copying happens only when you choose Copy Readings; macOS manages the clipboard.

Requires macOS 27 or later on a compatible Apple silicon Mac. Launch Core Metrics and look for its readings in the menu bar; it does not open a main window or appear in the Dock.
```

Feature evidence: [metric definitions](METRICS.md), [presentation architecture](ARCHITECTURE.md), [menu panel](../Core%20Metrics/Views/MenuBar/MenuBarMenuView.swift), [Settings](../Core%20Metrics/Views/Settings/SettingsView.swift) and [copy action](../Core%20Metrics/Views/MenuBar/CopyCurrentReadingsButton.swift). The existing record name was confirmed during the accompanying App Store Connect review.

## App Review notes

These revised four-mode notes, including the accurate English-interface clarification, were saved and verified exactly after reload October 8. The revised notes are **1,766 characters / 1,768 UTF-8 bytes**. Review contact fields are filled in Connect only. [Apple review-information requirements](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information#app-review-information).

```text
Core Metrics is a macOS menu-bar utility. It requires macOS 27 or later on a compatible Apple silicon Mac. The interface is in English; numeric formatting follows the macOS locale.

1. Launch the app and locate its live readings in the menu bar. There is intentionally no Dock icon or main app window. Allow a few seconds for the initial CPU sample.
2. Click the status label to open the persistent selection panel. Choose one to seven CPU, Memory and Storage stats. The panel remains open as choices change.
3. Use Settings in the panel footer to open the native Settings window. Menu Bar Text changes the representation; all four modes remain available for every selection count. Add Stat and the remove controls change the selection. Live Preview can scroll horizontally.
4. Copy Readings in the panel footer writes the full selected names and current values to this Mac’s clipboard. It is an explicit action, replaces the current clipboard content and excludes these copies from Universal Clipboard.
5. Metric Help, Support and Privacy are available in Settings. Privacy also links to the public policy in the browser. Launch at Login is optional, starts off for an unregistered app, and reflects macOS registration or approval state. No helper or administrator access is required.
6. Quit in the panel footer exits the app.

The app reads aggregate system values through public Apple APIs. It has no accounts, network connections, purchases or retained metric history. A dash indicates an unavailable reading. Storage represents startup-volume capacity, not a file scan. Long selections need sufficient menu-bar space; Compact, Icon and Value, or Values Only use less room. If the readings are hidden, open the already-running app in Finder to recover Settings.
```

## TestFlight — What to Test

Prepared testing instructions for the next candidate; no candidate-specific pass or App Store Connect save is claimed here. **2,304 characters / 2,304 UTF-8 bytes**. Paste only this plain text:

```text
Please test Core Metrics on macOS 27 or later on a compatible Apple silicon Mac. The interface is in English; numbers follow your locale.

1. Launch the app, find its readings in the menu bar, and allow a few seconds for the first CPU sample. There is no main window or Dock icon.
2. Open the selection panel and try one, three and seven readings from CPU, Memory and Storage, including several from one category. Choices should update immediately in canonical order while the panel stays open. At least one and at most seven must remain selected.
3. Open Settings and repeatedly change between Label and Value, Compact, Icon and Value, and Values Only. All modes should support every selection count and retain complete values and units. Use Add Stat, remove controls and the horizontally scrollable Live Preview. Reopen Settings, then quit and relaunch, and check that choices are saved.
4. Watch changing readings with an unchanged selection and mode. The status item should keep its allocated width and position; changing selection or mode may resize it. If a long selection is hidden, open the already-running app from Finder to recover Settings and choose fewer readings or a narrower mode.
5. Confirm that checkbox clicks keep the panel open, another status-item click closes it, and real outside clicks or Escape dismiss it. Reopen it after each dismissal. Settings and Command-comma should close the panel and raise Settings.
6. Use Copy Readings only when you want to replace this Mac's clipboard. Check the complete selected names and current values, Copied feedback, Metric Help, Support, and Privacy in Settings. Help and Privacy should scroll and close with Done, Return or Escape.
7. On a test setup, check sleep/wake recovery, VoiceOver, keyboard traversal and accessibility display settings. If testing Launch at Login, use an installed signed copy and your own explicit choice; macOS manages registration and approval separately from menu-bar defaults. A real login cycle and minimum macOS 27.0 acceptance remain separate from local automated tests.

A dash means a reading is unavailable; CPU needs a baseline after launch or a sampling gap. Swap may be unavailable while other memory readings remain valid. The app saves no metric history and does not inspect processes or scan files.
```

## App Privacy assessment

The shipping app contains no network client, third-party SDK, analytics, accounts, tracking or advertising. Aggregate readings remain in memory, preferences remain local, and Copy Readings is explicit and excluded from Universal Clipboard. Local diagnostic messages contain category/state only. The source and archived manifest support on-device processing.

Apple distinguishes on-device processing from data transmitted for developer/partner access. Apple-only App Analytics collection is not automatically developer collection; do not infer a label solely from the presence of an Apple dashboard. Actual developer use of Apple/TestFlight data and optional support still needs resolution before the final declaration. The beta/support website disclosures are independently required. [Collection definitions](https://developer.apple.com/app-store/app-privacy-details/), [Apple-only data guidance](https://support.apple.com/en-gb/102399), [TestFlight data sharing](https://www.apple.com/legal/privacy/data/en/test-flight/).

The public Privacy page remains a publisher draft. Do not substitute an accurate App Privacy label for complete website/support/beta processing information. [Manage App Privacy](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy/).

## Candidate and screenshot evidence

The previously delivered builds passed their recorded archive/export/signature/sandbox/manifest checks, Apple validation and upload; their receipts and source fingerprints remain in the dated project report. October 8 current-source Debug/Release builds, **75 unit tests**, analysis and packaged checks pass. Two command-line desktop attempts time out during runner initialization, and a GUI attempt fails before connection; **zero app scenarios execute**. The last complete desktop receipt remains October 4, **13/13** scenarios. New **1.0 (7)** archives and exports from `0a8e2a0`, passing **23 archive / 24 export** artifact checks; Apple validation exits 70 because Xcode cannot use its account, and no upload has been attempted. [October 8 receipt](PROJECT_ANALYSIS_REPORT.md#build-7-validation-and-delivery-attempt--october-8-2026).

Direct build-5 archive-copy checks passed one/three/seven readings in all modes, selection limits, horizontal preview, Finder recovery and Help/Privacy dismissal. Neither those historical checks nor current local packaging replace installed-TestFlight, minimum macOS 27.0, VoiceOver/display accommodations, sleep/wake or a real login cycle.

The screenshot set shows real, live Settings and native Metric Help in use, with matching artwork and captions. Preserve source captures and check exported image dimensions/opacity and visual legibility. No fabricated metric values, debug fixtures, website illustrations or personal desktop content were used. A third panel image and preview video are optional. [Screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications), [accurate metadata](https://developer.apple.com/app-store/review/guidelines/#accurate-metadata).
