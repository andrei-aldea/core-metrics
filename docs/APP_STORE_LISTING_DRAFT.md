# App Store listing draft

**Public App Store listing draft — not a new submission.**

September 22 direct Safari verification: the public version page now contains the four-mode description and Support URL shown below. It still has zero screenshots, no selected build, empty copyright and four empty public App Review contact fields. Sign-in required is off and automatic release is selected. Saved review notes still incorrectly restrict Values Only to one stat; replace them with the current draft when completing the public review information. The corrected signed **1.0 (3)** candidate from `a82a4ad` passed Apple validation, upload and processing. Following the user's TestFlight-only instruction, build 3 is assigned to External Testers and **Waiting for Review**, with the requested tester confirmed **Invited** and automatic build notification enabled. The earlier build **1.0 (2)** is **Approved**, and beta contact/feedback fields are present. The completed processing follow-up is paused. **Public submission/publication is explicitly excluded**; this public listing remains a draft. These observations supersede the older records below.

September 21 reconciliation: release records and the existing signed archive identify TestFlight build **1.0 (2)** from `96edf35`, uploaded September 20. Fresh local checks confirm the archive's signature, sandbox, hardened runtime, version/build, matching privacy manifest and absence of quarantine attributes. Saved beta metadata/contact, zero testers and pending external beta review are September 20 account observations; current Connect state could not be read because Safari screen capture failed. No public version submission is recorded. The later local cleanup at `4906017` is not in that archive. Select the public candidate explicitly; the existing build does not automatically need replacement merely because documentation or unused code changed.

The public listing copy was refreshed September 12 from the September 6 preparation for **Core Metrics: Mac Stats**, macOS version 1.0 in Prepare for Submission. Verify the public-version fields before submission; this audit made no upload, signing change, publisher declaration or screenshot submission.

The September 6 App Store Connect preparation saved the subtitle, Utilities category, promotional text, description, keywords and the then-current review notes, and cleared Sign-in required. On September 12, the revised four-mode description, Support URL and reviewer instructions were entered in the existing version page, but **Save was rejected because the four review-contact fields were empty**. These prepared edits have not been verified as saved. Sign-in required remains off; the app needs no credentials. Apple's review-contact fields are separate publisher information.

The existing English (U.S.) locale is retained. The privacy response is a saved, unpublished draft. The user-selected Free price schedule was saved and verified on September 6; pricing and availability were not rechecked on September 12. The fresh version-page inspection confirmed no selected build or screenshots. See [APP_STORE.md](APP_STORE.md) for remaining release requirements.

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

Description — **1,607 / 4,000 characters**; paste only the following plain text:

```text
Keep an eye on your Mac's CPU, memory and startup-volume storage from the menu bar.

Choose one to seven readings and keep the numbers you need within reach. Open the status panel to change your selection while the panel stays open.

CPU, memory and storage
See aggregate CPU Used, User, System and Idle percentages. Check memory use, wired and compressed memory, cached files, swap and physical memory. View startup-volume used space, free space, total capacity or used percentage.

Your preferred view
Choose Label and Value, Compact, Icon and Value, or Values Only in Settings. Every mode supports one to seven readings at the same native text size. A live preview shows your full selection. Numbers follow your locale, and your choices are saved for next time. Available menu-bar space depends on your Mac and other menu-bar items.

Current readings, ready to use
Copy Readings copies the full names and current values of your selected stats. Metric Help in Settings explains what each reading means. CPU and memory refresh about every two seconds; storage refreshes about every thirty seconds. No metric history is saved.

Local by design
Core Metrics runs on your Mac without accounts, network connections, analytics, tracking or advertising. Only menu-bar preferences are saved by the app. Launch at Login is optional and managed by macOS. Copying happens only when you choose Copy Readings; macOS manages the clipboard.

Requires macOS 27 or later on a compatible Apple silicon Mac. Launch Core Metrics and look for its readings in the menu bar; it does not open a main window or appear in the Dock.
```

Feature evidence: [metric definitions](METRICS.md), [presentation architecture](ARCHITECTURE.md), [menu panel](../Core%20Metrics/Views/MenuBar/MenuBarMenuView.swift), [Settings](../Core%20Metrics/Views/Settings/SettingsView.swift) and [copy action](../Core%20Metrics/Views/MenuBar/CopyCurrentReadingsButton.swift). The existing record name was confirmed during the accompanying App Store Connect review.

## App Review notes

Sign-in required: **No**, saved with the checkbox unchecked. No demo account is needed. Notes: **1,637 / 4,000 bytes**, revised locally for the final implementation. [App Review information](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information#app-review-information).

```text
Core Metrics is a macOS menu-bar utility. It requires macOS 27 or later on a compatible Apple silicon Mac.

1. Launch the app and locate its live readings in the menu bar. There is intentionally no Dock icon or main app window. Allow a few seconds for the initial CPU sample.
2. Click the status label to open the persistent selection panel. Choose one to seven CPU, Memory and Storage stats. The panel remains open as choices change.
3. Use Settings in the panel footer to open the native Settings window. Menu Bar Text changes the representation; all four modes remain available for every selection count. Add Stat and the remove controls change the selection. Live Preview can scroll horizontally.
4. Copy Readings in the panel footer writes the full selected names and current values to the clipboard. It is an explicit action and replaces the current clipboard content.
5. Metric Help, Support and Privacy are available in Settings. Privacy also links to the public policy in the browser. Launch at Login is optional, starts off for an unregistered app, and reflects macOS registration or approval state. No helper or administrator access is required.
6. Quit in the panel footer exits the app.

The app reads aggregate system values through public Apple APIs. It has no accounts, network connections, purchases or retained metric history. A dash indicates an unavailable reading. Storage represents startup-volume capacity, not a file scan. Long selections need sufficient menu-bar space; Compact, Icon and Value, or Values Only use less room. If the readings are hidden, open the already-running app in Finder to recover Settings.
```

The September 12 public-version review-contact fields were pending; the September 20 release notes subsequently confirm saved TestFlight review/feedback contacts and beta metadata. Verify the public-version fields independently before submission. These private fields must not be added to the repository. [Review contact requirements](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information#app-review-information).

## App Privacy answers for publisher review

Saved draft answer: **“No, we do not collect data from this app.”** The product-page preview shows **Data Not Collected**; the answer has **not been published**. Apple's questionnaire ends the data-type questions after this answer. The publisher must verify the final binary and approve the declaration before publishing it. [Manage app privacy](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy).

| Topic | Source-backed draft rationale |
| --- | --- |
| Collection, tracking and third-party SDKs | No app networking, tracking, analytics, accounts, advertising or third-party dependencies. No collected data types or tracking purposes are proposed. |
| Readings and preferences | Aggregate readings remain in memory; only menu-bar selections/display mode persist locally. macOS manages optional login registration. |
| Diagnostics | Local system logs contain metric category and availability state; the app does not transmit logs. |
| Clipboard | Copy Readings writes only on request. macOS may share clipboard contents through enabled Universal Clipboard; the app sends no data to the developer or a partner. |

This is an inference from the implemented data flow and Apple's distinction between on-device processing and data transmitted off-device for developer/partner access. [Apple's collection definition](https://developer.apple.com/app-store/app-privacy-details/), [in-app privacy text](../Core%20Metrics/Views/Settings/PrivacyInformationView.swift), [privacy manifest](../Core%20Metrics/PrivacyInfo.xcprivacy).

**Privacy Policy URL:** https://core-metrics.dorobantimedia.com/en/privacy. The page responds over HTTPS and the native Privacy sheet now links to it. It is still visibly a publisher draft: the registered office and core support practices were confirmed September 14; finalize remaining hosting/support practices, provider backups/transfers, lawful grounds and the effective date before submission. **Support URL:** https://core-metrics.dorobantimedia.com/en/support. Public availability does not confirm that either URL has been saved in App Store Connect. Privacy Choices URL is optional and remains pending if applicable. This draft is not a legal policy or an attestation on the publisher's behalf. [App information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information), [privacy URL fields](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy#entering-privacy-policy-information), [Review Guideline 5.1.1(i)](https://developer.apple.com/app-store/review/guidelines/#data-collection-and-storage).

## Screenshot capture plan

Mac screenshots are required: **1–10** JPEG/JPG/PNG images, with **no alpha channel or transparency**, at one of **1280 × 800, 1440 × 900, 2560 × 1600 or 2880 × 1800 pixels** (16:10). Use 2880 × 1800 for this set if available. These are output pixel dimensions, not window sizes. [Apple screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications#mac).

| Order | Capture from the final app | What it demonstrates |
| --- | --- | --- |
| 1 | Light appearance; menu bar plus open panel with CPU User, Memory Used and Storage Free selected; complete footer visible | Current readings and persistent selection; Settings, Copy Readings and Quit |
| 2 | Settings with full Live Preview, Menu Bar Text and the same three selected stats visible | Customization and adding readings; use a readable native window size |
| 3 | Settings with Metric Help open, its title, explanations and Done visible | Built-in explanations; capture enough of Settings to show where help lives |

Capture real app UI and real current readings on a clean desktop without personal files, account details or unrelated app content. Check text at full size, complete status readings and footer visibility. Do not reuse obsolete bitmap-label/footer screenshots or fabricate metric values. Screenshots must show the app in use. [Review Guidelines 2.3.3 and 2.3.9](https://developer.apple.com/app-store/review/guidelines/#accurate-metadata). No listing screenshots have been captured by this task.

## Submission prerequisites and pending publisher fields

**Submission requirements rechecked September 21, 2026.** The installed **Xcode 27 RC (`27A266a`)** was accepted for the recorded September 20 validation/upload and passed current local non-UI validation. Select it per invocation; keep the actual candidate's archive/validation receipt. Beta 6 results are historical. [Apple developer releases](https://developer.apple.com/news/releases/), [App Store Connect release notes](https://developer.apple.com/help/app-store-connect/release-notes/).
Apple's April 2026 SDK 26 notice and announced April 2027 SDK 27 requirement name their mobile/TV/spatial/watch platforms; neither establishes a Mac SDK minimum by analogy. Recheck the applicable Mac upload requirements at the next authorized upload. [Current submission requirements](https://developer.apple.com/app-store/submitting/), [upcoming requirements](https://developer.apple.com/news/upcoming-requirements/), [upload guidance](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds).

| Pending item | Publisher action |
| --- | --- |
| Developer account and agreements | Confirm Apple Developer Program membership, App Store Connect access and current agreements. App creation requires Account Holder, Admin or App Manager access; the Account Holder handles agreements. |
| Existing app record | Retain Core Metrics: Mac Stats, macOS 1.0 and English (U.S.). The existing release-only overrides produced signed/uploaded 1.0 (2); the neutral tracked development identity remains intentional. Verify the chosen build belongs to this record and preserve its matching bundle ID/profile/signature. Keep private identifiers outside this document. |
| Public support and policy | Both URLs respond over HTTPS; native links and all four modes in website source/live copy are already implemented. Finalize the remaining legal disclosures, authorize website deployment, verify the resulting public policies, and verify the URLs saved on the public version. Marketing URL is optional. |
| Publisher declarations | Confirm seller/developer identity, copyright owner/year, content rights, age-rating questionnaire, license choice, export compliance and any territory/trader declarations. No answers are signed or invented here. |
| Commercial and release choices | Free pricing was verified September 6; its 175 pricing regions do not configure availability. Verify territories and current agreement state. A free app without IAP does not inherently require a Paid Apps Agreement or payout banking/tax setup. Apple's EU trader workflow separately requires payment-account details for traders if not already supplied. The Account Holder must verify these account requirements. |
| Release control | The historical automatic-release selection is unverified now. If the owner wants a separate release decision after approval, choose manual release before submission through a separately authorized account action. Add for Review and Submit for Review are distinct; manual release adds a later Release This Version action. Phased release is for updates, not the first launch. |
| Final evidence | Approve real screenshots/copy and the exact candidate; complete native geometry, focus, accessibility, sleep/wake and signed login-cycle checks. Accessibility Nutrition Labels are currently voluntary; assess every claimed feature first. Apple's Larger Text label is unavailable for Mac, although practical text sizing still needs testing. |

Account/record requirements: [App Store Connect workflow](https://developer.apple.com/help/app-store-connect/get-started/app-store-connect-workflow), [add a new app](https://developer.apple.com/help/app-store-connect/create-an-app-record/add-a-new-app), [app information fields](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information). Support/copyright fields: [platform version information](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information). Free-app distribution agreement: [Apple's agreement guidance](https://developer.apple.com/help/app-store-connect/manage-agreements/sign-and-update-agreements/). Existing release gates remain in [APP_STORE.md](APP_STORE.md).

Current control references: [EU trader requirements](https://developer.apple.com/help/app-store-connect/manage-compliance-information/manage-european-union-digital-services-act-trader-requirements/), [submission](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-app), [release options](https://developer.apple.com/help/app-store-connect/manage-your-apps-availability/select-an-app-store-version-release-option), [phased updates](https://developer.apple.com/help/app-store-connect/update-your-app/release-a-version-update-in-phases), [voluntary accessibility labels](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/overview-of-accessibility-nutrition-labels/). The single cross-repository [ordered launch checklist](<../../core-metrics-website/docs/audit/OWNER_ACTIONS.md>) distinguishes preparation, submission and public release, with owners and acceptance criteria.
