# App Store, privacy, and release preparation

Core Metrics is development-ready only within the validation recorded in [PROJECT_ANALYSIS_REPORT.md](PROJECT_ANALYSIS_REPORT.md). It is not yet submission-ready. No archive for distribution, upload, signing-account change or App Store Connect action was performed during remediation.

## Repository configuration

The app targets macOS 27 with version 1.0/build 1, a neutral placeholder bundle identifier, generated Info.plist, Utilities category, AppIcon, and `LSUIElement = true`. Debug and Release both enable App Sandbox and hardened runtime. The source entitlement file contains only `com.apple.security.app-sandbox = true`.

Apple's [macOS 27 compatibility list](https://www.apple.com/os/macos/) includes only Apple silicon Macs. Intel hardware validation is outside this deployment target's supported device matrix; it is not an unresolved release gate. The native arm64 app still needs final validation on supported Macs and the accepted release toolchain.

The existing `ITSAppUsesNonExemptEncryption = false` setting was preserved. Source contains no custom cryptography or third-party SDK. Reconfirm this declaration against the shipping app and Apple's [encryption-key documentation](https://developer.apple.com/documentation/bundleresources/information-property-list/itsappusesnonexemptencryption); the publisher remains responsible for export-compliance answers.

No network client/server entitlement, ATS exception, URL handler, associated domain, push environment, background mode, helper, extension, purchase framework, remote configuration, or sensitive permission usage string is present or required by current behavior.

The native `MenuBarExtra` uses a template `CGImage` rendered in memory by SwiftUI `ImageRenderer`. Status content is capped at 320 points with an ellipsis for long text; Settings retains the full scrollable preview, and the image carries the full accessibility summary. This presentation change adds no persisted metric data, networking or entitlement.

## Manual privacy and security review

No Codex Security Scan or dedicated security-scanning workflow was started. The review used source/configuration inspection, local build tools, tests, and official Apple documentation. No repository or application data was uploaded to a third-party scanner.

Reviewed areas include provider pointer/port ownership, input arithmetic, concurrency/cancellation, UserDefaults schema repair/migration, logging, resources, target membership, signing assumptions, entitlements, build settings, manifest use, linked frameworks, bundled executables and source hygiene. No account, authentication/token/Keychain flow, database, web view, file import/export, arbitrary command execution, backend authorization, analytics, ad SDK or dependency network exists in this app.

Current data flow is aggregate CPU/memory/swap and startup-volume capacity → current in-memory snapshots → local display. Only menu-bar configuration is persisted in app-scoped UserDefaults. Failure/recovery logging contains metric category/state only. The app makes no network requests and saves no metric history. Copy Current Readings writes selected names and values to the macOS clipboard only on request; the OS may share those contents through enabled Universal Clipboard. System-wide aggregates are visible in the status label and therefore can appear in ordinary user screenshots; there are no secrets or personal identifiers in those values.

Settings → Privacy now opens a native sheet describing aggregate readings, local preferences, no metric history or network connections, and category-only diagnostics. It is available without a network request and closes with Done, Return or Escape. These are factual implementation statements; a publisher identity, contact, legal policy or public URL has not been invented.

The release follow-up checked current repository files and all reachable historical source blobs for known personal-path, credential, private-key, signing-team and token patterns. No confirmed sensitive source material was found; apparent email matches were icon filenames ending in `@2x.png`. This bounded check does not prove the absence of arbitrary secrets or replace author/committer metadata review before a public push.

Public interfaces include `host_statistics`, `host_statistics64`, `host_page_size`, `mach_host_self`/`mach_port_deallocate`, `ProcessInfo.physicalMemory`, Foundation URL volume resource keys and the public VM_SWAPUSAGE sysctl. Sources and formulas are linked in [METRICS.md](METRICS.md). Documented APIs and a minimal entitlement surface support these choices; they are not an App Review allowlist or a guarantee of security.

## Optional login registration and clipboard

Launch at Login uses the documented [main-app service](https://developer.apple.com/documentation/servicemanagement/smappservice/mainapp) only after an explicit Settings action. It adds no helper or entitlement and stores no duplicate preference. Before release, validate enable/disable, approval in System Settings, and a subsequent login using the final signed, installed application. The isolated tests validate app behavior but do not establish real signed login registration.

Copy Current Readings uses public [NSPasteboard](https://developer.apple.com/documentation/appkit/nspasteboard) writes only when requested. Privacy information describes OS clipboard handling. The source privacy manifest remains unchanged. Apple’s [published Required Reason API categories](https://developer.apple.com/documentation/technotes/tn3183-adding-required-reason-api-entries-to-your-privacy-manifest) were rechecked for this addition; ServiceManagement registration and pasteboard writes do not introduce one of those categories. Recheck current policy and final publisher disclosures at release.

## Privacy manifest

`Core Metrics/PrivacyInfo.xcprivacy` is bundled at `Contents/Resources/PrivacyInfo.xcprivacy`. It declares no tracking, tracking domains or collected data, with two accessed-API categories:

| Category | Approved reason | Actual use |
| --- | --- | --- |
| Disk Space | `85F4.1` | Show local startup-volume capacity to the person using the Mac. |
| User Defaults | `CA92.1` | Read/write the app's menu-bar preferences. |

Reasons were checked against Apple's [accessed API category/reason list](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitype). Apple's [manifest overview](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files) currently names Required Reason requirements for several platforms while omitting macOS; the existing conservative truthful declaration is retained. Recheck policy at submission and after any covered API change. Do not add speculative File Timestamp or System Boot Time reasons. URL cache invalidation adds no new reason category.

Use Xcode's archive privacy report and [TN3181](https://developer.apple.com/documentation/technotes/tn3181-debugging-invalid-privacy-manifest) when validating a final distribution artifact. Plist syntax checks do not replace archive validation.

## Release gates requiring publisher action

1. Validate with a stable Xcode/macOS SDK accepted by App Store Connect at submission. Current testing used Xcode 27 beta 6, and deployment remains macOS 27.
2. Choose a publisher-controlled identifier and configure local distribution signing/provisioning. Do not commit team IDs, certificates, profiles or credentials. Coordinate any identifier change with the UI test's existing app-instance lookup.
3. Supply reviewed publisher privacy-policy and support pages at stable public URLs, and configure the required App Store metadata. The native Privacy sheet already provides factual local information; reconcile its content and policy access with the final publisher policy. Apple's [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) require privacy-policy access in metadata and within the app.
4. Confirm App Store privacy answers against the final binary. Current implementation supports “no data collected,” but the publisher must re-audit before submitting.
5. Prepare screenshots, description, review notes, copyright, age rating and current metadata. Preserve legal notices; the repository currently has no selected license.
6. Review icons at all system/App Store sizes, native layouts, accessibility, runtime behavior and the remaining test limitations in the report. The capped status label and seven-stat relaunch are covered on the reviewed desktop; broader crowded/notched display testing remains in the release matrix.
7. Only after explicit release authorization, archive through Xcode Organizer, inspect effective entitlements, generate the privacy report, validate and submit through the current Apple workflow.

Unsigned builds cannot prove effective sandbox entitlements. Local ad-hoc Debug runs may inject `get-task-allow`; UI-test instrumentation may also inject testing exceptions. Never treat those artifacts as distribution approval. The signed shipping archive must preserve sandboxing and omit debugger/test exceptions, test fixtures, private paths and unintended nested executables.

The UI test launch configuration is guarded by `#if DEBUG`. Only an explicit test launch selects its separate preference suite and app appearance; ordinary launches keep the person's settings, and Release compiles out this configuration. Both tests initially launch with one Value Only statistic; the dark test selects seven through the native panel, then uses `CORE_METRICS_UI_RELAUNCH=1` to relaunch with the same isolated preferences and open the panel again. Both scenarios check bounded width, accessibility, Privacy, Metric Help, fake login toggling and injected clipboard success/failure. Actual OS login registration is not changed by automated tests, and the general clipboard is untouched. Consult the report for final execution results, including the corrected image accessibility assertions; the presence of tests does not establish a pass.

No backend, authentication provider, purchase service or remote operational checklist applies. Remaining organizational work is publisher configuration, legal/privacy content, App Store metadata and real release validation. App Store approval and complete security are not claimed.
