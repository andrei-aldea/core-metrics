# Contributing to Core Metrics

Keep changes focused on aggregate CPU, memory, startup-volume information, native presentation, accessibility, reliability, or release preparation. The canonical scope and engineering rules are in [AGENTS.md](AGENTS.md); setup and checks are in [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md).

## Workflow

1. Read the existing code and docs, inspect the working tree, and preserve unrelated edits.
2. Use Xcode 27, the macOS 27 SDK, and the existing Swift 6 settings. Open `Core Metrics.xcodeproj`; use the shared `Core Metrics` scheme.
3. Implement the smallest supported change. Keep system acquisition out of views and retain the provider/calculator/state/preferences separation. New dependencies require explicit review and a written justification.
4. Add focused Swift Testing regressions for changed calculations, persistence, or lifecycle behavior. Use XCTest for native UI automation.
5. Build Debug and Release, run relevant tests, inspect diagnostics and the final diff. Exercise UI changes in the running app, including Settings, keyboard navigation, appearance, and accessibility.
6. Update metric formulas, architecture decisions, development instructions, and the remediation report when the corresponding behavior or validation status changes.

No formatting/lint dependency is configured. Follow neighboring Swift style and use `git diff --check`. Do not suppress warnings or relax concurrency, privacy, sandbox, or test requirements.

## Issues and pull requests

Search existing issues before filing one. Describe a reproducible symptom or the smallest useful proposal. Include the macOS/Xcode version and a sanitized revision/build reference. PRs should explain the resulting behavior, relevant validation, and any remaining limitations; screenshots help when appearance changes.

Never post secrets, personal paths, device identifiers, signing information, sensitive logs, or unredacted test bundles. Before any requested commit, inspect the working and staged diffs, scan staged content for private material, and verify that the change is coherent and buildable. Do not publish, push, commit, or alter signing as part of an unrequested cleanup.

## License

The repository does not currently grant an open-source license. By submitting a contribution, you confirm that you have the right to submit it. Licensing terms may be clarified before external contributions are merged.
