# Mac App Store Readiness

Core Metrics is designed for App Sandbox distribution through the Mac App Store.

## Baseline policy

- Public documented APIs only.
- No root access, helper tools, private frameworks, injected code, broad file access, network entitlement, or unnecessary capability.
- No telemetry, analytics, tracking, ads, account, or network service.
- Neutral placeholder bundle identifier and automatic signing disabled in repository-owned configuration.
- Publisher bundle identifier, team, signing certificate, provisioning profile, App Store Connect record, screenshots, privacy answers, and final metadata are release-time local steps.

## Verified platform decisions

- App Sandbox is mandatory for Mac App Store distribution. The app carries only `com.apple.security.app-sandbox = true`; version 1 needs no network, broad file-access, hardware, Apple Events, helper-tool, or temporary-exception entitlement. See Apple's [App Sandbox overview](https://developer.apple.com/documentation/security/app-sandbox) and [Xcode configuration guide](https://developer.apple.com/documentation/xcode/configuring-the-macos-app-sandbox).
- CPU and memory acquisition uses Apple's documented [`host_statistics`](https://developer.apple.com/documentation/kernel/1502546-host_statistics) and [`host_statistics64`](https://developer.apple.com/documentation/kernel/1502863-host_statistics64) Mach APIs. They require no documented entitlement, privileged helper, or private framework.
- Storage acquisition uses Foundation's documented [`volumeTotalCapacityKey`](https://developer.apple.com/documentation/foundation/urlresourcekey/volumetotalcapacitykey) and [`volumeAvailableCapacityKey`](https://developer.apple.com/documentation/foundation/urlresourcekey/volumeavailablecapacitykey). It reads volume metadata for `/` and does not scan files.
- Release audits must apply the current [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/), especially sections 2.4.5 (sandboxed, self-contained Mac apps) and 2.5.1 (public APIs).

Apple doesn't publish an API-by-API App Review allowlist. Documentation in the public SDK and the absence of special entitlements support these choices, but a signed sandboxed archive must still be validated before submission.

## Privacy manifest

Core Metrics includes `PrivacyInfo.xcprivacy` as a conservative, truthful declaration. Apple's [privacy manifest overview](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files) currently requires collected-data declarations on all platforms but lists Required Reason API declarations for iOS, iPadOS, tvOS, visionOS, and watchOS, omitting macOS. Individual Foundation API pages nevertheless instruct apps to declare covered API use, and Apple defines the [macOS manifest bundle location](https://developer.apple.com/documentation/bundleresources/placing-content-in-a-bundle). The repository therefore declares actual use and rechecks the policy before submission.

Required Reason API entries:

| Category | Reason | Core Metrics use |
| --- | --- | --- |
| `NSPrivacyAccessedAPICategoryDiskSpace` | `85F4.1` | Display startup-volume capacity to the person using the Mac; values and derivatives remain on-device. |
| `NSPrivacyAccessedAPICategoryUserDefaults` | `CA92.1` | Store app-only preferences through `UserDefaults` / `AppStorage`. |

The approved categories, covered APIs, and reason text are defined by Apple under [`NSPrivacyAccessedAPIType`](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitype).

- Do not declare file-timestamp access unless product code starts using a covered creation/modification-date, `stat`, or related API. Core Metrics currently has no such use.
- Avoid direct `ProcessInfo.systemUptime` and `mach_absolute_time()` use. If either becomes necessary for in-app elapsed-time calculation, add System Boot Time reason `35F9.1`.
- The Mach host-statistics APIs and `ProcessInfo.physicalMemory` aren't in Apple's current Required Reason API list.
- Declare `NSPrivacyTracking = false`; don't add tracking domains or collected-data declarations while the app performs no tracking or collection.
- Validate the manifest with Xcode's privacy report and Apple's [TN3181](https://developer.apple.com/documentation/technotes/tn3181-debugging-invalid-privacy-manifest) guidance.

## Audit checklist

- Confirm App Sandbox entitlement is enabled and minimal.
- Audit linked frameworks and symbols for private API use.
- Re-check deployment target and current App Store Review Guidelines.
- Review `PrivacyInfo.xcprivacy` and Required Reason API use against Apple's current list.
- Confirm the privacy manifest contains Disk Space `85F4.1` and User Defaults `CA92.1`, with no unsupported or unused reasons.
- Archive with the publisher's local signing configuration and validate through Xcode.
- Confirm no personal data or signing information is present in the repository or archive source.
