# Mac App Store Readiness

Core Metrics is designed for App Sandbox distribution through the Mac App Store.

## Baseline policy

- Public documented APIs only.
- No root access, helper tools, private frameworks, injected code, broad file access, network entitlement, or unnecessary capability.
- No telemetry, analytics, tracking, ads, account, or network service.
- The repository uses a neutral placeholder bundle identifier. Xcode's automatic signing mode is present, but no publisher team, certificate, identity, or provisioning profile is committed; unsigned command-line builds use `CODE_SIGNING_ALLOWED=NO`.
- Publisher-controlled bundle identity, team and distribution signing, App Store Connect configuration, and submission metadata remain release-time local steps.

## Current development audit

The MVP was most recently validated with Xcode 27.0 beta (build `27A5252f`), Apple Swift 6.4, and the macOS 27 SDK on Apple silicon. The project compiles in Swift 6 mode with complete concurrency checking and warnings as errors, while targeting macOS 27.

This development audit found:

- The generated product has `LSUIElement = true`, a macOS 27 minimum version, the selected `AppIcon` asset, and the Utilities application category.
- The repository entitlement file contains only `com.apple.security.app-sandbox = true`; hardened runtime is enabled by the project.
- The privacy manifest is valid and is copied to `Contents/Resources/PrivacyInfo.xcprivacy` in the app bundle.
- Linked application frameworks are public Apple frameworks. There are no third-party packages, private frameworks, privileged helpers, nested executables, or network capabilities.
- CPU, memory, and startup-volume APIs are present in the public SDK and are isolated behind provider boundaries.
- Tracked source and project files contain no publisher signing identity, developer team, credential, home path, or Xcode user data.

The Xcode beta currently prints an App Intents metadata-extraction warning even though Core Metrics has no App Intents dependency. Treat this as a beta-toolchain issue to recheck rather than suppressing metadata warnings. A submission archive must be produced and validated without warnings using a stable Xcode version supported by App Store Connect.

## Verified platform decisions

- App Sandbox is mandatory for Mac App Store distribution. The app carries only `com.apple.security.app-sandbox = true`; version 1 needs no network, broad file-access, hardware, Apple Events, helper-tool, or temporary-exception entitlement. See Apple's [App Sandbox overview](https://developer.apple.com/documentation/security/app-sandbox) and [Xcode configuration guide](https://developer.apple.com/documentation/xcode/configuring-the-macos-app-sandbox).
- CPU and physical-memory acquisition uses Apple's documented [`host_statistics`](https://developer.apple.com/documentation/kernel/1502546-host_statistics) and [`host_statistics64`](https://developer.apple.com/documentation/kernel/1502863-host_statistics64) Mach APIs. Swap Used comes from the public `CTL_VM` / `VM_SWAPUSAGE` sysctl and `xsw_usage` structure declared in Apple's public [XNU `sysctl.h`](https://github.com/apple-oss-distributions/xnu/blob/main/bsd/sys/sysctl.h). These aggregate reads require no documented entitlement, privileged helper, or private framework.
- Storage acquisition uses Foundation's documented [`volumeTotalCapacityKey`](https://developer.apple.com/documentation/foundation/urlresourcekey/volumetotalcapacitykey) and [`volumeAvailableCapacityKey`](https://developer.apple.com/documentation/foundation/urlresourcekey/volumeavailablecapacitykey). It reads volume metadata for `/` and does not scan files.
- Release audits must apply the current [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/), especially sections 2.4.5 (sandboxed, self-contained Mac apps), 2.5.1 (public APIs), and 5.1.1(i) (privacy-policy access and metadata).

Apple doesn't publish an API-by-API App Review allowlist. Documentation in the public SDK and the absence of special entitlements support these choices, but a signed sandboxed archive must still be validated before submission.

## Privacy manifest

Core Metrics includes `PrivacyInfo.xcprivacy` as a conservative, truthful declaration. Apple's [privacy manifest overview](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files) currently requires collected-data declarations on all platforms but lists Required Reason API declarations for iOS, iPadOS, tvOS, visionOS, and watchOS, omitting macOS. Individual Foundation API pages nevertheless instruct apps to declare covered API use, and Apple defines the [macOS manifest bundle location](https://developer.apple.com/documentation/bundleresources/placing-content-in-a-bundle). The repository therefore declares actual use and rechecks the policy before submission.

Required Reason API entries:

| Category | Reason | Core Metrics use |
| --- | --- | --- |
| `NSPrivacyAccessedAPICategoryDiskSpace` | `85F4.1` | Display startup-volume capacity to the person using the Mac; values and derivatives remain on-device. |
| `NSPrivacyAccessedAPICategoryUserDefaults` | `CA92.1` | Store app-only menu-bar preferences through `UserDefaults`. |

The approved categories, covered APIs, and reason text are defined by Apple under [`NSPrivacyAccessedAPIType`](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitype).

- Do not declare file-timestamp access unless product code starts using a covered creation/modification-date, `stat`, or related API. Core Metrics currently has no such use.
- Avoid direct `ProcessInfo.systemUptime` and `mach_absolute_time()` use. If either becomes necessary for in-app elapsed-time calculation, add System Boot Time reason `35F9.1`.
- The Mach host-statistics APIs and `ProcessInfo.physicalMemory` aren't in Apple's current Required Reason API list.
- Declare `NSPrivacyTracking = false`; don't add tracking domains or collected-data declarations while the app performs no tracking or collection.
- Validate the manifest with Xcode's privacy report and Apple's [TN3181](https://developer.apple.com/documentation/technotes/tn3181-debugging-invalid-privacy-manifest) guidance.

## Release blockers

The current source tree is intentionally development-ready rather than submission-ready. Complete all of the following before uploading a build:

- Review the integrated original icon at all Finder, Settings, and App Store sizes. The flattened asset catalog is valid and selected; optionally recreate the retained master as a layered Icon Composer source for platform-managed material effects before the final archive.
- Replace `org.example.CoreMetrics` with a bundle identifier controlled by the publisher, then configure the publisher's team, App Store distribution certificate, and provisioning profile outside the public repository.
- Publish a privacy policy and support page at stable public URLs. Add the privacy-policy URL to App Store Connect and expose it in an easily accessible in-app location as required by App Review Guideline 5.1.1(i).
- Complete the App Store privacy label truthfully. If the implementation remains local-only, with no transmission or third-party SDKs, the expected declaration is that no data is collected; re-audit before answering.
- Supply screenshots, description, support URL, copyright, age rating, review notes, and other current App Store Connect metadata.
- Build and archive with a non-beta Xcode version that App Store Connect supports at submission time. Re-run all tests and real-app visual/accessibility checks against that toolchain.
- Generate Xcode's privacy report and validate the archive through Organizer or the current App Store validation workflow.

Development or ad-hoc signing may inject `com.apple.security.get-task-allow = true` as a base entitlement. The final distribution archive must not contain `get-task-allow`; App Sandbox must remain present, and every effective capability must be expected for the publisher's distribution configuration.

## Final audit checklist

- Confirm App Sandbox entitlement is enabled and minimal.
- Audit linked frameworks and symbols for private API use.
- Re-check deployment target and current App Store Review Guidelines.
- Review `PrivacyInfo.xcprivacy` and Required Reason API use against Apple's current list.
- Confirm the privacy manifest contains Disk Space `85F4.1` and User Defaults `CA92.1`, with no unsupported or unused reasons.
- Confirm the in-app privacy-policy link and public privacy/support URLs work.
- Confirm the App Store privacy label matches the shipping binary and policy.
- Inspect the signed archive's effective entitlements and confirm `get-task-allow` is absent.
- Archive with the publisher's local signing configuration and validate through a supported stable Xcode.
- Confirm no personal data or signing information is present in tracked files, Git author metadata, project user data, or archive source.
- Before each public release, audit the complete Git history as well as the working tree and select an explicit repository license.
