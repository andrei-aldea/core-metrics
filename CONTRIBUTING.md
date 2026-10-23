# Contributing to Core Metrics

Keep changes focused on aggregate CPU, memory, startup-volume information, native presentation, accessibility, reliability, or release preparation. The canonical scope and engineering rules are in [AGENTS.md](AGENTS.md); setup and checks are in [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md). Read [docs/PRODUCT.md](docs/PRODUCT.md) for product intent and [docs/PLAN.md](docs/PLAN.md) for prioritized work and acceptance criteria.

## Workflow

1. Read the existing code and docs, inspect the working tree, and preserve unrelated edits.
2. Verify full Xcode 27+, a macOS 27+ SDK, first-launch setup and the existing Swift 6 settings on the current Mac; do not assume the previous machine’s tools or permissions transferred. Open `Core Metrics.xcodeproj`; use the shared `Core Metrics` scheme.
3. Implement the smallest supported change. Keep system acquisition out of views and retain the provider/calculator/state/preferences separation. New dependencies require explicit review and a written justification.
4. Add focused Swift Testing regressions for changed calculations, persistence, or lifecycle behavior. Use XCTest for native UI automation.
5. Choose the verification tier in the development guide. Documentation-only changes need source/link/diff checks. Code changes need relevant builds and tests; share necessary Debug/Release, analysis and desktop checks across the final batch. Exercise UI changes in the running app, including Settings, keyboard navigation, appearance and accessibility. Preserve mandatory build, privacy, concurrency and release gates.
6. Update metric formulas, architecture decisions, development instructions, product/plan status and the analysis report when the corresponding behavior or validation status changes. Distinguish implementation from verified completion.

No formatting/lint dependency is configured. Follow neighboring Swift style and use `git diff --check`. Do not suppress warnings or relax concurrency, privacy, sandbox, or test requirements.

## Issues and pull requests

Search existing issues before filing one. Describe a reproducible symptom or the smallest useful proposal. Include the macOS/Xcode version and a sanitized revision/build reference. PRs should explain the resulting behavior, relevant validation, and any remaining limitations; screenshots help when appearance changes.

Never post secrets, personal paths, device identifiers, signing information, sensitive logs, or unredacted test bundles. Before an authorized commit, inspect the working and staged diffs, scan staged content for private material, and complete the checks appropriate to the change. Follow the current user’s Git authorization and global default-branch policy; do not create branches or PRs unless requested. Git delivery does not authorize distribution, production changes or signing changes. Never bypass hooks or branch protections.

## License

The repository does not currently grant an open-source license. By submitting a contribution, you confirm that you have the right to submit it. Licensing terms may be clarified before external contributions are merged.
