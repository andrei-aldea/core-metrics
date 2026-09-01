# Mac App Store Readiness

Core Metrics is designed for App Sandbox distribution through the Mac App Store.

## Baseline policy

- Public documented APIs only.
- No root access, helper tools, private frameworks, injected code, broad file access, network entitlement, or unnecessary capability.
- No telemetry, analytics, tracking, ads, account, or network service.
- Neutral placeholder bundle identifier and automatic signing disabled in repository-owned configuration.
- Publisher bundle identifier, team, signing certificate, provisioning profile, App Store Connect record, screenshots, privacy answers, and final metadata are release-time local steps.

## Audit checklist

- Confirm App Sandbox entitlement is enabled and minimal.
- Audit linked frameworks and symbols for private API use.
- Re-check deployment target and current App Store Review Guidelines.
- Review `PrivacyInfo.xcprivacy` and Required Reason API use against Apple's current list.
- Archive with the publisher's local signing configuration and validate through Xcode.
- Confirm no personal data or signing information is present in the repository or archive source.

Specific API decisions and authoritative sources will be recorded here as implementation proceeds.
