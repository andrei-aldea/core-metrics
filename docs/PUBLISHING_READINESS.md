# Historical app and website publishing review — September 14, 2026

**Retained historical assessment, committed after the September 21 delivery request.** The dated observations below are preserved; they are not the current task list. Since this review, TestFlight 1.0(2) was uploaded, the website defects and publication-state coverage were fixed, and the quiet website redesign was deployed. Use the [current findings register](<../../core-metrics-website/docs/audit/FINDINGS.md>), [verification report](<../../core-metrics-website/docs/audit/VERIFICATION.md>) and [ordered owner actions](<../../core-metrics-website/docs/audit/OWNER_ACTIONS.md>) for remaining work. The September 20 release evidence is recorded in [PROJECT_ANALYSIS_REPORT.md](PROJECT_ANALYSIS_REPORT.md#testflight-build-preparation-and-upload--september-20-2026). This record does not authorize a new upload or public release.

Reviewed September 14, 2026. This report covers the native Core Metrics repository, the companion `core-metrics-website` repository, the live website, current website CI/deployment status, and official publishing requirements. It is an assessment, not authorization to submit, change publisher identity, accept agreements, or publish legal declarations.

**Verdict: the product implementation is substantially complete, but the app and website are not ready for a coordinated public launch.** The remaining work is final legal/operational disclosure, shipping identity and App Store preparation, reliable desktop validation, and verification of the website's final publication/release states. A major redesign or additional monitoring features are not prerequisites.

## Verified evidence

| Area | Evidence from this review | Interpretation |
| --- | --- | --- |
| Native baseline | App commit `7b38038`; initially clean working tree. macOS 27 minimum; version 1.0/build 1; neutral development identifier. | Existing development configuration, not a distribution build. |
| Native toolchain | Installed Xcode 27 RC `27A266a`, selected with a per-command override. Machine-wide selection still points to beta 6. | The accepted RC is available; another installation is unnecessary. |
| Native build and analysis | Fresh Debug and Release builds, dependency resolution, Xcode analysis, source/packaged property-list checks, privacy checks and Release fixture-exclusion checks passed. | No new compiler, calculation or packaging blocker was established by these checks. |
| Native unit tests | 71 Swift Testing declarations, 171 execution leaves, no failures or skips. | Covers arithmetic, formatting, preference migration, sampling lifetime/cancellation, failure recovery, login service and isolated clipboard behavior. |
| Native geometry | Current exported measurements retained 361/208/198/140-point widths for Label and Value/Compact/Icon and Value/Values Only at 9% → 100% → 9%, in both appearances. The single-stat fixture retained 55×24 points across six readings. | Width and position stability passed for these fixtures; available menu-bar space and other configurations remain separate. |
| Native desktop tests | Final outcome is recorded in the desktop-validation section below. | A build or older UI pass cannot substitute for a clean current desktop run. |
| Website local validation | 10 configuration/publication tests; 312 matching bilingual strings; 15 readings; 10 routes; TypeScript, ESLint and production build passed. Installed top-level dependency graph resolves successfully. | The current preview implementation builds and has consistent content structure. |
| Website CI | Read the completed CI log for commit `9214768`: 46 Chromium browser tests passed in 3.6 minutes, with content/types/lint/configuration/build steps also successful. | This is current recorded CI evidence, inspected during the audit; the complete browser suite was not rerun locally during this review. |
| Vercel | Connected project reports Node 24, a READY production deployment at commit `9214768`, and the approved custom domain. Team plan is Pro. | Hosting setup and deployment are in place; no plan upgrade is established as necessary. |
| Live public routes | All ten English/Romanian home, Support, Privacy, Terms and Sitemap pages returned HTTP 200. Root resolves to English; a missing English route returned 404. | Public reachability works. This does not establish legal completeness. |
| Live metadata and infrastructure | Correct locale/canonical URLs, ten XML sitemap entries, working localized social images and manifest. HSTS, CSP, content-type protection, referrer and permission policies are present. No Set-Cookie header observed in these requests. | Useful baseline; no claim about all provider processing or complete browser storage behavior follows from HTTP headers. |
| Publication state | All ten pages have `noindex, nofollow`; robots.txt disallows crawling; legal drafts remain visible. | The domain is deployed as a preview, not an indexable finished launch. |

Apple explicitly accepts Xcode 27 RC/macOS 27 RC uploads for the App Store and TestFlight in its [September 9 release notes](https://developer.apple.com/help/app-store-connect/release-notes/). Do not lower the deployment target or change machine-wide toolchain settings to address the release checklist.

## Work required before publication

### 1. Finalize the factual website policy and operating procedures

With the approved origin supplied, `npm run check:publication` correctly reports **seven remaining inputs**:

1. Hosting request data, purposes and access, in both languages.
2. Lawful grounds for each processing activity and any specific legitimate interests, in both languages.
3. Retention/deletion criteria for logs, correspondence and provider backups, in both languages.
4. Recipients, processing locations and international-transfer safeguards, in both languages.
5. A real, non-future effective date.
6. Approval of the equivalent final English/Romanian legal copy.
7. Confirmation of the standard or custom App Store EULA choice.

The company details, registered office, named support providers and 30-day correspondence rule are already supplied; they do not need to be invented or collected again. Remaining facts belong in website `src/lib/publication.ts` and the final bilingual copy. Verify the actual account/contract settings and implement the stated support deletion and rights-request procedures. A 30-day promise in text is not evidence that older correspondence or provider backups have been deleted.

The current legal base paragraphs also need a final edit. `src/messages/en.ts:366` and `src/messages/ro.ts:368` explicitly say backup timing is unverified; the sitemap's Apple-license descriptions at lines 117/119 say the license selection is unconfirmed. Completing `publication.ts` does not replace those strings. Remove or revise those statements only when the underlying facts support the change, and inspect the complete rendered documents for contradictions.

The local checkout does not currently supply the approved origin by default. This adds an eighth local check failure, but the live site's canonical URLs demonstrate that its deployment has the origin. Use the documented public origin when performing release validation; do not mistake this local difference for a broken production domain.

Apple requires an accessible privacy-policy link both in the app and App Store Connect under [Guideline 5.1.1](https://developer.apple.com/app-store/review/guidelines/#data-collection-and-storage). The in-app link already exists. Website/support processing still needs truthful disclosure; the native app's local-only behavior does not describe server requests. [GDPR Article 13](https://eur-lex.europa.eu/legal-content/EN/TXT/PDF/?uri=CELEX%3A32016R0679) identifies the relevant disclosure categories. Vercel's [DPA](https://vercel.com/legal/dpa) describes its contractual framework but cannot prove this project's log retention, access or processor configuration.

**Completion evidence:** no unresolved factual paragraphs in either language; approved effective date/license choice; operational responsibilities documented; publication check passes; final public Support/Privacy/Terms pages inspected without authentication.

### 2. Configure and validate the actual shipping app

`Core Metrics.xcodeproj/project.pbxproj:394` and `:428` still use `org.example.CoreMetrics`, and no publisher team is configured. The existing App Store Connect record has a different registered identifier according to the prior account review. An unsigned or ad-hoc build cannot satisfy distribution signing.

After the publisher authorizes release configuration, align the shipping bundle identifier, team and signing with the existing record. Preserve the development setup where appropriate. Decide whether local development preferences should migrate; changing the identifier changes the app's defaults/container identity and affects UI-test instance lookup and login registration. Do not assume a previous ad-hoc Launch at Login result verifies the distribution-signed identity.

Create the distribution archive with the accepted toolchain, inspect its effective signature, sandbox/hardened-runtime entitlements, version/build, privacy manifest and Xcode privacy report, then validate and upload it through the intended App Store workflow. Retain the archive and dSYMs. Verify the resulting processed build before selecting it for review.

The reviewed app uses public acquisition and scene/status-item APIs, app-only preferences, explicit clipboard actions and OS-managed login registration. No network client, third-party SDK, helper, account system or metric history was found in the reviewed source. The existing Disk Space `85F4.1` and User Defaults `CA92.1` declarations align with their local display/preferences uses in Apple's [Required Reason API documentation](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitype). Recheck the final artifact; source declarations alone are insufficient.

**Completion evidence:** distribution identity matches the existing record; archive validation succeeds; uploaded build finishes processing; final signature/privacy checks pass.

### 3. Complete App Store Connect metadata and publisher declarations

The App Store account itself was **not freshly inspected in this audit**. The last documented September 12 inspection reported Prepare for Submission, no selected build or screenshots, missing review contact/copyright, and unfinished content rights and age rating. Revised description/support/reviewer text was prepared, but Save was rejected because review contact was missing. Treat these as fields to verify now, not a claim that their current values were observed today.

Verify and finish:

- The private App Review contact, copyright and current four-mode description/review notes; keep app sign-in requirements off because the app has no accounts.
- Marketing, Support and Privacy URLs, with the final policy actually accessible.
- Accurate app-privacy answers, content rights, the current age-rating questionnaire and export-compliance answers.
- Developer membership/current agreements, intended free pricing, availability territories, app EULA, and release timing.
- EU DSA trader status and verification where relevant. Free pricing does not by itself decide trader status; use Apple's [trader requirements](https://developer.apple.com/help/app-store-connect/manage-compliance-information/manage-european-union-digital-services-act-trader-requirements).
- A processed build and genuine screenshots of that release candidate.

Apple requires 1–10 Mac screenshots at one of 1280×800, 1440×900, 2560×1600 or 2880×1800, without transparency. Capture at least the menu panel, Settings with the four modes, and Metric Help from the real app. The website's HTML demo and DEBUG fixture screenshots are not substitutes. See [Apple's screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications#mac) and the local [listing draft](APP_STORE_LISTING_DRAFT.md).

**Completion evidence:** saved fields verified after reopening the record, approved real screenshots, processed build selected, and no unresolved submission requirements. Publisher declarations and agreement acceptance remain publisher actions.

### 4. Close desktop reliability and accessibility validation

Obtain a clean current native UI suite with the desktop left undisturbed, and investigate any reproducible failure. Confirm the actual shipping candidate through launch/reopen, panel selection, all four modes, Settings, outside clicks, Escape, help/privacy and current-reading copy. Recheck fixed width/position across changing readings and resizing after configuration changes, including one/three/seven selections and constrained menu-bar space.

Complete the remaining manual release matrix: real login after logout/restart, sleep/wake recovery, long-running sampling/resource behavior, crowded/notched and external displays, large text, VoiceOver/keyboard traversal, Increased Contrast, Reduce Motion, Reduce Transparency and Differentiate Without Color. Use an isolated test profile where preferences need changing. Do not interrupt the person's login session as part of this audit.

The prior report retains `layoutSubtreeIfNeeded` and `com.apple.linkd.autoShortcut` runtime diagnostics. A new build pass does not resolve their cause. Triage their reproducibility and user impact on the shipping candidate; do not suppress them or represent every framework message as an app defect. Do not make Accessibility Nutrition Label claims beyond completed verification.

**Completion evidence:** repeatable current desktop checks, reviewed failure evidence, documented manual matrix and final signed-candidate validation.

### 5. Verify the website's published and released states

Website publication and app availability are intentionally separate. Once legal content is approved, the site can use `NEXT_PUBLIC_PUBLICATION_STATE=published` while the app remains in `preparation`. Verify that the rebuilt deployment removes preview/draft presentation appropriately, allows indexing, and keeps correct canonical/hreflang/social/sitemap data.

**The current CI does not test that final state.** Website `tests/website.spec.ts:28–30` expects legal drafts, no App Store links and `noindex`; its robots test expects `Disallow: /`. The workflow builds with default preview configuration and no approved-origin environment. Consequently, current green CI cannot prove published metadata or the real download path works. Preserve preview coverage and add a separate published/preparation and released-state test matrix with explicit expectations. Test-only release fixtures must remain isolated from the public deployment and cannot stand in for real listing verification.

The homepage price label and note also need a released variant: `src/app/[locale]/page.tsx:20` always renders `common.free`/`home.freeNote`, which currently say “Intended price: Free”/“Intended App Store price: Free.” These remain provisional even when the release flag changes the badge and availability message. Keep the intended wording during preparation; use the verified price after release.

After the app is publicly available, verify the actual HTTPS App Store destination, free price and compatibility, record its verification date, install the unmodified official Mac App Store badge and required credits, and enable `released`. Check both languages, the hero/closing download actions, FAQ/Terms/social copy, badge dimensions/clear space and the real destination. Follow [Apple's badge guidelines](https://developer.apple.com/app-store/marketing/guidelines/).

Run Safari/WebKit and Firefox checks in addition to the current Chromium coverage, plus a short manual keyboard/VoiceOver, 200% zoom, mobile-width and performance pass. No new analytics integration is needed for launch. Public-domain uptime/error observation and a tested rollback procedure are useful operational controls; Vercel deployment currently runs independently of the GitHub validation job.

**Completion evidence:** state-appropriate tests pass, final domain verified after deployment, no preview wording/indexing restrictions in published mode, and real download links work after app release.

## Smaller confirmed issues and optional improvements

| Priority | Finding | Recommended action |
| --- | --- | --- |
| Low | Website `src/app/manifest.ts:14–15` advertises `/icon.png` as 512×512; the actual source PNG is 64×64. `public/images/app-icon.png` is a real 512×512 asset. | Point the manifest at the existing 512 image or declare its actual size. Verify saved/bookmarked presentation. This is not an App Store blocker. |
| Low | `APP_STORE_LISTING_DRAFT.md` still instructs installing the RC and correcting three-mode website copy, although the RC is installed and the live site has four modes. Website README lists older Next/next-intl versions than the current pinned packages. | Reconcile the handoff documents before someone follows stale instructions. Use this review and the latest artifact/CI evidence. |
| Optional | The website uses a clearly disclosed interactive illustration, with no current real app screenshots. | Add a few approved release screenshots to strengthen product trust; keep the interactive demo if useful. Store screenshots are required separately. |
| Optional | The native app has English text with locale-aware numbers; the website has English and Romanian. | Keep language claims accurate. Native Romanian localization can follow later; it is not a prerequisite for an English app release. |
| Optional | No long-duration performance or full cross-browser/assistive-technology certification was performed here. | Record a small representative performance baseline and complete the manual checks before making specific performance/accessibility claims. |

## Desktop-validation outcome and visual evidence

The current isolated validation run is `core-metrics-validation.6SuR04`; raw logs and result bundles are retained outside the checkout. The complete desktop suite finished with **9/12 passing and three assertion failures**, so the validator correctly exited nonzero. Configuration fingerprints and whitespace checks passed. Five known AppIntents metadata-skipped warning lines were recorded, with zero other build warning lines and zero missing-display rectangle diagnostics. These counts do not replace a complete runtime-log review.

The failures were: initial panel opening in `testAddingThirdStatInSettingsKeepsFullStatusText` (test line 449); the CPU heading's hittability in `testDarkAppearanceCopyFailureWithSingleStat` while opening Metric Help (line 1014); and Settings-window hittability after an outside click in `testOutsideClicksDismissPanelAndAllowReopening` (line 268). In the last case the preceding assertion confirmed that the popover dismissed, so this is not evidence that outside-click dismissal itself failed.

Early browser interactions overlapped the beginning of the desktop run. A same-build selective recheck of the three failures was therefore attempted without further browser interaction. The panel scenario reached all its assertions and captured reopened Settings, but the runner then stalled at teardown for several minutes without recording a final test result or beginning the other two cases. Only this audit's matching `xcodebuild` process was interrupted; it exited 75. This is an incomplete recheck, **not a passing selective suite**. Another Xcode test process was present, so complete desktop isolation was not established. No unrelated process or permission setting was changed. Failure names alone do not establish a production root cause, and partial assertion progress does not rewrite the full-suite result.

A supplemental effective-entitlement check confirmed App Sandbox on the ad-hoc UI test app. Its first helper invocation failed because `/tmp` and `/private/tmp` aliases produced duplicate Darwin module-cache paths; using a distinct canonical-path helper cache passed. No app source or warning suppression was needed. The native computer-use tool subsequently timed out when selecting the installed app, so no additional manual native-flow pass is claimed.

Current-run website captures cover: (1) English landing page, (2) interactive Settings/display-mode switching, and (3) Romanian navigation at 375 CSS pixels. The observed mobile document had no horizontal overflow, and no browser warning/error was recorded during the initial demo checks. Native screenshots from this run show (4) the complete Settings footer at 580-point window width and (5) the scrolled Metric Help sheet with readable text and Done. Subsequent browser captures show (6) the live Privacy draft and pending effective date, and (7) Support with its launch-help accordion open. The native captures use test configuration and are review evidence, not approved App Store screenshots. These samples are not full accessibility certification. The temporary browser viewport override was reset.

The accepted screenshots and step notes are in the ignored local [visual review](../.codex/publication-audit-2026-09-14/VISUAL_REVIEW.md). Raw result bundles stay outside the checkout; private identifiers and raw log contents are not copied into this report.

## Recommended launch order

1. Resolve the seven policy/license inputs and final bilingual copy; verify operational procedures.
2. Authorize the shipping identity and finish a validated distribution candidate; resolve desktop failures and complete the manual matrix.
3. Capture real screenshots and save/verify the remaining App Store record fields and declarations.
4. Test and publish the final legal/marketing website while retaining app preparation state.
5. Submit the app; after approval and real public availability, verify the listing and activate the website download/badge state.

The audit leaves product source, signing, entitlements, deployment targets, account declarations and production settings unchanged. No distribution archive, upload, commit or push was performed. No simulator/cache cleanup or external repository scan was used. Documentation records the assessment and its limits.
