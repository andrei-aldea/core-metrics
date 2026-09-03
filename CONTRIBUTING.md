# Contributing to Core Metrics

Thank you for helping improve Core Metrics. Contributions should preserve its focus as a small, private, native macOS menu-bar utility.

## Before opening an issue

- Search existing issues for the same problem or proposal.
- Confirm the request belongs to aggregate CPU, memory, startup-volume storage, menu-bar presentation, accessibility, reliability, or App Store readiness.
- Do not post credentials, signing identities, provisioning information, personal paths, device names, or sensitive logs.

Fan control, SMC/private APIs, temperature probing, privileged helpers, daemons, kernel extensions, cleaning, process inspection, file scanning, malware features, hardware tuning, battery/network monitoring, accounts, cloud features, analytics, ads, subscriptions, and purchases are outside the project scope.

## Development setup

Requirements:

- macOS 27 or later
- Xcode 27 or later

Open `Core Metrics.xcodeproj` in Xcode or use the command line:

```sh
xcodebuild -list -project "Core Metrics.xcodeproj"
xcodebuild \
  -project "Core Metrics.xcodeproj" \
  -scheme "Core Metrics" \
  -destination 'platform=macOS' \
  CODE_SIGNING_ALLOWED=NO \
  build
xcodebuild \
  -project "Core Metrics.xcodeproj" \
  -scheme "Core Metrics" \
  -destination 'platform=macOS' \
  CODE_SIGNING_ALLOWED=NO \
  test
```

For UI changes, also run the app and verify the status item, persistent status panel, and Settings in light and dark appearance. Check repeated panel selections, keyboard focus, VoiceOver labels, Increased Contrast, Reduce Motion, Reduce Transparency, accessibility text sizes, and live-value width stability.

## Implementation guidelines

- Use Swift, SwiftUI, Foundation, SF Symbols, and documented public Apple APIs.
- Keep App Sandbox enabled and do not add an entitlement without a documented need.
- Do not add a third-party dependency without prior discussion and a strong justification.
- Keep system acquisition out of views and preserve the separation between providers, calculations, current snapshots, preferences, and presentation.
- Treat warnings, concurrency diagnostics, deprecations, sandbox issues, and privacy-manifest diagnostics as defects.
- Update `docs/METRICS.md` when a formula or metric meaning changes.
- Record meaningful architectural choices in `docs/DECISIONS.md`.

## Pull requests

Keep each pull request focused and buildable. Include:

- A concise description of the user-visible or architectural change.
- Tests for changed pure logic or preference behavior.
- Manual verification notes for UI work.
- Documentation updates when behavior, scope, privacy, or architecture changes.

Before committing, inspect both the working and staged diffs and confirm no personal names, email addresses, usernames, home paths, device names, developer team IDs, certificates, provisioning profiles, credentials, tokens, or Xcode user data are included.

## License

The repository does not currently grant an open-source license. By submitting a contribution, you confirm that you have the right to submit it. Licensing terms may be clarified before external contributions are merged.
