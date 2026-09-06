# App Store listing draft

**Draft only — not submitted.** Prepared September 6, 2026 for the existing **Core Metrics: Mac Stats** App Store Connect record, macOS version 1.0 in Prepare for Submission, and the Settings / Copy Readings / Quit footer. This drafting task made no upload, signing change, publisher declaration or screenshot submission. Complete the pending publisher fields before submission.

The accompanying App Store Connect preparation saved the subtitle, Utilities category, promotional text, description, keywords and review notes below, and cleared Sign-in required. The existing English (U.S.) locale is retained. The privacy response is a saved, unpublished draft. The user-selected Free price schedule was saved and verified after reopening the pricing page. App availability remains unconfigured. No build or screenshots have been uploaded. See [APP_STORE.md](APP_STORE.md) for remaining release requirements.

## English listing copy

Naming follow-up for the next listing review: use Memory and Storage in UI references, with Used (%) for selectable percentage variants. The saved text blocks and metadata below remain unchanged; the screenshot plan uses the updated UI names. No revised listing copy was saved as part of this naming follow-up.

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

Description — **1,541 / 4,000 characters**; paste only the following plain text:

```text
Keep an eye on your Mac's CPU, memory and startup-volume storage from the menu bar.

Choose one to seven readings and keep the numbers you need within reach. Open the status panel to change your selection while the panel stays open.

CPU, memory and storage
See aggregate CPU Used, User, System and Idle percentages. Check memory use, wired and compressed memory, cached files, swap and physical memory. View startup-volume used space, free space, total capacity or used percentage.

Your preferred view
Choose Label and Value or Compact in Settings, or Value Only for a single reading. A live preview shows your full selection. Numbers follow your locale, and your choices are saved for next time. Available menu-bar space depends on your Mac and other menu-bar items.

Current readings, ready to use
Copy Readings copies the full names and current values of your selected stats. Metric Help in Settings explains what each reading means. CPU and memory refresh about every two seconds; storage refreshes about every thirty seconds. No metric history is saved.

Local by design
Core Metrics runs on your Mac without accounts, network connections, analytics, tracking or advertising. Only menu-bar preferences are saved by the app. Launch at Login is optional and managed by macOS. Copying happens only when you choose Copy Readings; macOS manages the clipboard.

Requires macOS 27 or later on a compatible Apple silicon Mac. Launch Core Metrics and look for its readings in the menu bar; it does not open a main window or appear in the Dock.
```

Feature evidence: [metric definitions](METRICS.md), [presentation architecture](ARCHITECTURE.md), [menu panel](../Core%20Metrics/Views/MenuBar/MenuBarMenuView.swift), [Settings](../Core%20Metrics/Views/Settings/SettingsView.swift) and [copy action](../Core%20Metrics/Views/MenuBar/CopyCurrentReadingsButton.swift). The existing record name was confirmed during the accompanying App Store Connect review.

## App Review notes

Sign-in required: **No**, saved with the checkbox unchecked. No demo account is needed. Notes: **1,442 / 4,000 bytes**, saved in App Store Connect. [App Review information](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information#app-review-information).

```text
Core Metrics is a macOS menu-bar utility. It requires macOS 27 or later on a compatible Apple silicon Mac.

1. Launch the app and locate its live readings in the menu bar. There is intentionally no Dock icon or main app window. Allow a few seconds for the initial CPU sample.
2. Click the status label to open the persistent selection panel. Choose one to seven CPU, Memory and Storage stats. The panel remains open as choices change.
3. Use Settings in the panel footer to open the native Settings window. Menu Bar Text changes the representation; Value Only is available with one selected stat. Add Stat and the remove controls change the selection. Live Preview can scroll horizontally.
4. Copy Readings in the panel footer writes the full selected names and current values to the clipboard. It is an explicit action and replaces the current clipboard content.
5. Metric Help and Privacy are available in Settings. Launch at Login is optional, starts off for an unregistered app, and reflects macOS registration or approval state. No helper or administrator access is required.
6. Quit in the panel footer exits the app.

The app reads aggregate system values through public Apple APIs. It has no accounts, network connections, purchases or retained metric history. A dash indicates an unavailable reading. Storage represents startup-volume capacity, not a file scan. Long selections need sufficient menu-bar space; Compact uses less room.
```

Reviewer contact name, email and international-format phone number remain **pending publisher entry**. These private fields must not be added to the repository. [Review contact requirements](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information#app-review-information).

## App Privacy answers for publisher review

Saved draft answer: **“No, we do not collect data from this app.”** The product-page preview shows **Data Not Collected**; the answer has **not been published**. Apple's questionnaire ends the data-type questions after this answer. The publisher must verify the final binary and approve the declaration before publishing it. [Manage app privacy](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy).

| Topic | Source-backed draft rationale |
| --- | --- |
| Collection, tracking and third-party SDKs | No app networking, tracking, analytics, accounts, advertising or third-party dependencies. No collected data types or tracking purposes are proposed. |
| Readings and preferences | Aggregate readings remain in memory; only menu-bar selections/display mode persist locally. macOS manages optional login registration. |
| Diagnostics | Local system logs contain metric category and availability state; the app does not transmit logs. |
| Clipboard | Copy Readings writes only on request. macOS may share clipboard contents through enabled Universal Clipboard; the app sends no data to the developer or a partner. |

This is an inference from the implemented data flow and Apple's distinction between on-device processing and data transmitted off-device for developer/partner access. [Apple's collection definition](https://developer.apple.com/app-store/app-privacy-details/), [in-app privacy text](../Core%20Metrics/Views/Settings/PrivacyInformationView.swift), [privacy manifest](../Core%20Metrics/PrivacyInfo.xcprivacy).

**Privacy Policy URL: pending.** A public publisher-approved policy URL is required for macOS, and the app needs an easily accessible policy link. The existing local Privacy sheet does not supply that URL. Privacy Choices URL is optional and remains pending if applicable. This draft is not a legal policy or an attestation on the publisher's behalf. [App information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information), [privacy URL fields](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy#entering-privacy-policy-information), [Review Guideline 5.1.1(i)](https://developer.apple.com/app-store/review/guidelines/#data-collection-and-storage).

## Screenshot capture plan

Mac screenshots are required: **1–10** JPEG/JPG/PNG images, with **no alpha channel or transparency**, at one of **1280 × 800, 1440 × 900, 2560 × 1600 or 2880 × 1800 pixels** (16:10). Use 2880 × 1800 for this set if available. These are output pixel dimensions, not window sizes. [Apple screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications#mac).

| Order | Capture from the final app | What it demonstrates |
| --- | --- | --- |
| 1 | Light appearance; menu bar plus open panel with CPU User, Memory Used and Storage Free selected; complete footer visible | Current readings and persistent selection; Settings, Copy Readings and Quit |
| 2 | Settings with full Live Preview, Menu Bar Text and the same three selected stats visible | Customization and adding readings; use a readable native window size |
| 3 | Settings with Metric Help open, its title, explanations and Done visible | Built-in explanations; capture enough of Settings to show where help lives |

Capture real app UI and real current readings on a clean desktop without personal files, account details or unrelated app content. Check text at full size, complete status readings and footer visibility. Do not reuse obsolete bitmap-label/footer screenshots or fabricate metric values. Screenshots must show the app in use. [Review Guidelines 2.3.3 and 2.3.9](https://developer.apple.com/app-store/review/guidelines/#accurate-metadata). No listing screenshots have been captured by this task.

## Submission prerequisites and pending publisher fields

**Toolchain acceptance remains unresolved.** The local toolchain is Xcode 27 beta 6 (`27A5252f`) with the macOS 27 SDK; Apple's current release entry and SDK table identify it as a beta. Apple's guidance directs developers to use Xcode and OS release candidates when available for submission. Plan final validation with an Apple-supported Xcode 27 RC/final toolchain supporting the existing macOS 27 target; acceptance of this beta-built app has not been demonstrated. [Xcode beta 6 release](https://developer.apple.com/news/releases/?id=08102026g), [SDK table](https://developer.apple.com/xcode/system-requirements), [Apple beta-software guidance](https://developer.apple.com/support/install-beta).

The April 28, 2026 SDK notice names iOS/iPadOS, tvOS, visionOS and watchOS 26; it does not establish a macOS 26 SDK minimum or approve a macOS 27 beta archive. Recheck Apple's upload requirements before the authorized distribution build. [Current submission requirements](https://developer.apple.com/app-store/submitting/), [upload guidance](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds).

| Pending item | Publisher action |
| --- | --- |
| Developer account and agreements | Confirm Apple Developer Program membership, App Store Connect access and current agreements. App creation requires Account Holder, Admin or App Manager access; the Account Holder handles agreements. |
| Existing app record | Retain Core Metrics: Mac Stats, macOS 1.0 and the verified English (U.S.) locale. Confirm SKU and access. Its registered bundle ID differs from the source placeholder; reconcile the shipping identity only with explicit authorization, and keep the actual publisher ID outside this document. |
| Public support and policy | The user confirmed these pages do not exist yet. Supply a working Support URL with contact information, Privacy Policy URL and the in-app policy link. Marketing URL is optional. [WEBSITE_BRIEF.md](WEBSITE_BRIEF.md) contains the requested website-building prompt. |
| Publisher declarations | Confirm seller/developer identity, copyright owner/year, content rights, age-rating questionnaire, license choice, export compliance and any territory/trader declarations. No answers are signed or invented here. |
| Commercial and release choices | The Free price schedule is saved and verified. Its 175-country/region price coverage does not configure app availability. Distribution territories, applicable tax/category information and release timing remain pending. Preserve the existing automatic-release selection until the publisher decides. |
| Final evidence | Approve screenshots/copy, final version/build, signed archive validation, real login-registration behavior and accessibility claims. Complete Apple's evaluation before claiming [Accessibility Nutrition Labels](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/overview-of-accessibility-nutrition-labels/). |

Account/record requirements: [App Store Connect workflow](https://developer.apple.com/help/app-store-connect/get-started/app-store-connect-workflow), [add a new app](https://developer.apple.com/help/app-store-connect/create-an-app-record/add-a-new-app), [app information fields](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information). Support/copyright fields: [platform version information](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information). Free-app distribution agreement: [Apple's agreement guidance](https://developer.apple.com/help/app-store-connect/manage-agreements/sign-and-update-agreements/). Existing release gates remain in [APP_STORE.md](APP_STORE.md).
