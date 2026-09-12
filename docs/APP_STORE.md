# App Store, privacy, and release preparation

**Reviewed September 12, 2026.** Technical verification and remaining limits are in [PROJECT_ANALYSIS_REPORT.md](PROJECT_ANALYSIS_REPORT.md#production-readiness-review--september-12-2026). Local validation is not an App Store submission. No distribution archive, upload, publisher declaration, or account/signing change was performed in this review.

## Current release requirements

| Area | State and next action |
| --- | --- |
| Source and installed app | The fetched upstream matches the baseline checkout. The working changes add four display modes, shared 12-point typography, first-time login registration recovery, and public support/privacy links. See the report for the installed artifact and final validation evidence. |
| Accepted toolchain | Apple accepts **Xcode 27 RC (`27A266a`) / macOS 27 RC SDK** for App Store and TestFlight uploads as of September 9. The official RC is now installed alongside beta 6; its signature and first-launch setup were verified. Final validation uses a per-command toolchain override. |
| Shipping identity | The publisher explicitly chose **Keep the local development setup** after local validation. The neutral `org.example.CoreMetrics` identifier and local signing remain. An uploadable build requires a separately authorized release configuration matching the existing App Store Connect record. Coordinate any identifier change with UI-test app-instance lookup and preference migration. |
| Public pages | [Support](https://core-metrics.dorobantimedia.com/en/support) and [Privacy Policy](https://core-metrics.dorobantimedia.com/en/privacy) respond over HTTPS. Settings and its Privacy sheet now link to them. The policy is visibly a **publisher draft** with unresolved factual inputs; approve and finalize it before submission. |
| Listing and declarations | Reconcile the refreshed [listing draft](APP_STORE_LISTING_DRAFT.md) with the saved App Store Connect copy, then complete screenshots, review contact, copyright, content rights, age rating, territories, agreements and export/privacy declarations. Do not invent or sign answers. |
| Final validation | The earlier RC validator passed builds, 171 unit executions, all 12 desktop tests, analysis and artifact checks. The latest follow-up repeated the build/unit/analysis passes, but both UI attempts timed out during XCTest automation initialization before app assertions. The installed ad-hoc Release passed strict signature, hardened runtime and sandbox-only entitlement checks; real login registration remained enabled after the update. Complete a real login cycle, the remaining accessibility/display matrix and final shipping archive/privacy validation. Recorded runtime diagnostics remain unresolved. |

Apple's [September 9 App Store Connect release notes](https://developer.apple.com/help/app-store-connect/release-notes/) establish RC acceptance for both channels; the earlier August 25 beta-6 notice established TestFlight acceptance only. The [developer release list](https://developer.apple.com/news/releases/) identifies the RC build. A successful beta build is not evidence that its archive qualifies for customer distribution.

## Existing App Store Connect record

The September 6 preparation inspected **Core Metrics: Mac Stats**, macOS version **1.0**, in **Prepare for Submission**. It saved the English (U.S.) subtitle, promotional text, description, keywords and review notes, with Utilities as the category and Sign-in required unchecked. The Data Not Collected answer was saved as an unpublished draft. The user-selected Free price schedule was saved and verified; pricing coverage is distinct from distribution availability. The existing automatic-release selection was left unchanged.

A fresh September 12 inspection confirmed **Prepare for Submission**, no uploaded/selected build, no screenshots or previews, an empty review contact and copyright, and unfinished content rights and age rating. Utilities remains the primary category and **Sign-in required remains unchecked**: Core Metrics has no user account or login. Apple's separate review-contact fields identify the publisher contact and do not create an app sign-in requirement.

The updated four-mode description, Support URL and review notes were entered into the existing version draft. **Save was rejected because First name, Last name, Phone number and Email were empty.** Those prepared edits are not claimed as saved. Contact entry was handed to the publisher; no contact details were invented or copied into this repository. Other saved metadata and declarations described above remain September 6 observations unless explicitly rechecked. The public policy's draft status still prevents treating it as finalized release policy.

The registered publisher identifier differs from the neutral source identifier. Actual publisher IDs, signing material and private review contacts remain outside this repository.

## Repository and binary requirements

The app targets **macOS 27**, version **1.0 / build 1**, with Utilities category, AppIcon and `LSUIElement = true`. macOS 27 supports compatible Apple silicon Macs; there is no Intel or mobile target. [Apple's platform compatibility](https://www.apple.com/os/macos/).

Both source configurations enable App Sandbox and hardened runtime. The accepted RC toolchain resolves Debug hardening to NO and Release to YES. The installed local Release has hardened runtime and exactly the required `com.apple.security.app-sandbox` entitlement, without debugger/test exceptions. Unsigned validation and ad-hoc local installation do not establish distribution signing.

No network entitlement, ATS exception, URL handler, associated domain, push registration, background helper, extension or sensitive permission usage description is needed. Native [Link](https://developer.apple.com/documentation/swiftui/link) controls open the two public pages in the default browser on request; their URLs carry no readings, preferences, identifiers or query parameters. No in-app networking was added.

The existing `ITSAppUsesNonExemptEncryption = false` declaration matches the reviewed absence of custom cryptography or third-party SDKs. Reconfirm it against the shipping app and Apple's [encryption declaration guidance](https://developer.apple.com/documentation/bundleresources/information-property-list/itsappusesnonexemptencryption).

The native status item reserves a positive width per selection/mode/locale. All four representations support one to seven stats with shared **12-point** fonts, tabular-digit values, localized fixed columns and full accessibility summaries. Compact abbreviates labels; Icon and Value uses category symbols; Values Only omits labels. Native popover focus, outside-click dismissal, repeated toggling and Finder reopen recovery remain part of desktop validation. Wider selections can exceed the menu-bar space macOS makes available.

## Launch at Login

Registration uses public [`SMAppService.mainApp`](https://developer.apple.com/documentation/servicemanagement/smappservice/mainapp). Initialization only reads the system state. Explicit enable/disable actions register or unregister; the app persists no duplicate login preference and installs no helper.

A `.notFound` status no longer disables the toggle. Apple DTS explains that the framework can return it before the system has seen a service. An explicit attempt lets ServiceManagement validate registration. Failure keeps the actual off state, shows a concise error and permits retry. `.requiresApproval` stays visibly distinct from enabled; unknown states stay disabled. [Apple DTS explanation](https://developer.apple.com/forums/thread/719862).

Unit tests cover first registration, removal, approval, failure/retry, cancellation and lifetime. Desktop fixtures start from `.notFound` using a fake service and never change real login items. Real installed-app registration and subsequent-login evidence are recorded separately in the report. A successful register call or enabled status does not itself prove a completed logout/login cycle.

## Privacy and API review

This was a manual source/privacy review and local Xcode analysis; no Codex Security Scan or external scanner was used. Reviewed areas include public provider APIs, pointer/port ownership, arithmetic bounds, structured cancellation, migration, logging, target/resource membership, signature assumptions, effective entitlements and packaged files.

Data flow remains aggregate CPU/memory/swap and startup-volume capacity → current in-memory snapshots → local display. The app stores menu-bar preferences only. Logs contain category/availability transitions. Copy Readings writes complete selected readings only on request; automated checks use an isolated pasteboard or injected writer. macOS may share clipboard contents through enabled Universal Clipboard.

The bundled `Contents/Resources/PrivacyInfo.xcprivacy` declares no tracking or collected data:

| Required Reason API category | Reason | Reviewed use |
| --- | --- | --- |
| Disk Space | `85F4.1` | Display startup-volume capacity locally. |
| User Defaults | `CA92.1` | Read/write app-only menu-bar preferences. |

The [current Apple reason list](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitype) was rechecked. Login registration and browser links introduce no additional covered category. Retain truthful declarations; do not add speculative timestamp/boot-time reasons. Final archive validation must include Xcode's privacy report and [TN3181](https://developer.apple.com/documentation/technotes/tn3181-debugging-invalid-privacy-manifest).

Settings → Privacy provides the local explanation and an accessible public-policy link. Apple's [Guideline 5.1.1](https://developer.apple.com/app-store/review/guidelines/#data-collection-and-storage) requires policy access in the app and metadata. The existing website's hosting and support correspondence require their own verified policy facts; the app's Data Not Collected draft does not cover those services. Recheck and obtain publisher approval before publishing [App Privacy answers](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy).

## Submission handoff

After the remaining publisher inputs and accepted-toolchain checks are complete, review final listing copy and real screenshots at Apple's [Mac screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications). Do not use DEBUG metric fixtures for listing screenshots. Complete Apple's evaluation before making [Accessibility Nutrition Label](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/overview-of-accessibility-nutrition-labels/) claims.

Only after explicit release authorization, archive through Xcode Organizer, inspect the effective signature/entitlements and privacy report, validate, and submit through the current Apple workflow. Preserve certificates, profiles, archives, dSYMs and legal notices. No open-source license has been selected. App Store approval is not claimed.

## Companion-site legal follow-up

The website now contains the four-mode product copy and revised bilingual Privacy/Terms explanations. Operational disclosures must be verified and completed before removing draft status. The website repository’s `docs/PUBLISHER_INPUTS.md` lists the remaining company address, provider/access/retention/transfer facts, lawful grounds, effective date and license confirmation. These are separate from private App Store review contact and release signing. The latest source updates are authorized for commit/push; no App Store account declaration is implied.
