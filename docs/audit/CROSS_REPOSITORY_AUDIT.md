# Cross-repository audit — 2026-09-21

This task reviewed and implemented changes in the native Core Metrics repository and the adjacent `core-metrics-website` repository. The shared [product/data inventory](../../../core-metrics-website/docs/audit/PRODUCT_AND_DATA.md), [findings](../../../core-metrics-website/docs/audit/FINDINGS.md), [current legal/Apple applicability](../../../core-metrics-website/docs/audit/LEGAL_APPLICABILITY.md), [owner questionnaire/actions](../../../core-metrics-website/docs/audit/OWNER_ACTIONS.md) and [verification/commit ledger](../../../core-metrics-website/docs/audit/VERIFICATION.md) live in the website repository to avoid duplicate reports. These relative links assume the two sibling checkouts used for this audit.

## Scope and recorded release facts

Native baseline was main at `96edf35e688f39b14d2b8535d664f4cf2884de1c`; website baseline was main at `9214768a3ff51e00f465d119325f2c46a4d0ad60`. Pre-existing edits to APP_STORE.md and PROJECT_ANALYSIS_REPORT.md, and untracked PUBLISHING_READINESS.md, belong to earlier work and are excluded from this task's commits. Their content, including September 20 TestFlight evidence, is preserved.

Source defaults are version 1.0/build 1 with the neutral development identity. Existing release notes separately record distribution-signed TestFlight 1.0 (2) from `96edf35`, uploaded September 20: Internal Testers Ready to Test, External Testers Waiting for Review, zero testers in both and no public invitation/public App Store submission. Beta contact/metadata was saved. No account status was freshly verified or changed during this audit. Website release preparation remains consistent with the lack of recorded public availability.

Manual source/privacy review covered all production layers, tests, project/schemes, build/artifact validators, resources and release guidance. AppKit/SwiftUI ownership, public metric acquisition, pure arithmetic, strict MainActor/Sendable boundaries, cancellation and weak ownership, stale-result rejection, migration, native geometry, transient popover/Settings recovery, clipboard and login operations were reviewed. No account, StoreKit, network client, SDK, telemetry, privileged helper or backend is present. No dedicated security scan, external source upload, dependency addition or broad refactor was performed.

## APP-01 — Retire the obsolete character-padding renderer

**Severity:** low maintenance/test relevance. Production titles are built by MenuBarLabelLayout using native point measurements. The character-padding implementation in MenuBarLabelFormatting was referenced only by its own tests and could mislead future work about the geometry owner.

Commit `4906017` removes that obsolete path and four exclusive tests, retains live prefix/direction/separator helpers, and adds two tests of the production attributed renderer: all available locales, percentages 0–100 and all four modes; mismatched input fallback. Existing byte/glyph/column, symbol/typography, bidirectional, preference migration, lifetime and OS-provider tests remain. No asset, runtime selector, conditional registration, persistence identifier, metric formula, signing, entitlement or deployment target was removed or changed. ARCHITECTURE, DEVELOPMENT, METRICS and ADR-025 explain the retained design.

**Status:** FIXED AND VERIFIED at build/unit/artifact level. No user-facing speed improvement is claimed. Desktop interaction verification is a separate unresolved item below.

## Validation and runtime limits

Used per-command `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`: Xcode 27 RC 27A266a, Swift 6.4, macOS 27/arm64. Machine-wide selection remains unchanged. Baseline validator `MbHAhB` passed non-UI checks. The cleanup's focused app-hosted unit run passed. Final validator `ybmZJC` passed project listing, dependency resolution (none), Debug/Release builds, **71 declarations / 169 execution leaves**, static analysis, source/packaged plist/privacy policy, Release fixture exclusion and unchanged configuration fingerprints. There were no unit failures/skips. The declaration count is two lower than the baseline's 73 because four obsolete tests were replaced by two production-renderer tests.

The `--ui` validator exited 65: XCTest timed out while enabling automation mode, before any of the 13 desktop cases started. This is runner initialization evidence, not a reproduced app assertion failure or a pass. Read-only DevToolsSecurity status was disabled, but that alone does not establish the cause; no permission setting was changed. The computer-use entry point also timed out. Current Xcode Run/manual status-panel/Settings checks could not be completed.

Five known AppIntents metadata-extraction warning lines remain in the full build/UI compilation; zero other build warning lines and zero missing-display rectangle diagnostic lines were counted. Existing historical layout/autoShortcut messages are not declared fixed. Unsigned/ad-hoc development validation does not establish effective distribution signing/hardening for a new shipping build. The earlier signed TestFlight artifact is a separate recorded delivery and was not replaced.

**APP-02 — medium, EXTERNAL ACTION REQUIRED:** a working authorized desktop session must exercise all 13 tests and the manual matrix: one/three/seven choices; all modes; native outside-click/Escape and repeated reopening; fixed status width/position across changing samples and expected resizing after preferences/locale; saved startup and Finder recovery; light/dark, keyboard/VoiceOver and display accommodations. Real login cycle, sleep/wake, constrained displays and long-running resource/energy behavior are not newly verified. Existing fixtures/fakes do not replace those checks.

No caches, simulators, archives, dSYMs, signing material or user data were removed; recovered bytes are zero. Raw validation results and temporary browser measurements remain outside tracked source. No commit includes logs or private release evidence.

## Release assessment

App/site functionality and product terminology are aligned with reviewed source. Local website fixes cover repeated removal/focus, perpetual decorative motion, consumer links, publication-state wording/coverage, asset metadata and duplicate payload. Public support/privacy routes work, but live pages remain drafts; no local change was deployed.

High publication dependencies remain actual hosting/retention/transfer/ground disclosures, support deletion/rights operations, final EN/RO legal approval/effective date and Connect/EULA/trader/public-release verification. The shared questionnaire acknowledges previously recorded Vercel Pro, Free pricing and TestFlight facts instead of inventing or re-requesting identity details. Local code fixes do not approve those facts. Neither full legal compliance nor App Store/public-release readiness is claimed.

A second repository-wide review rechecked source/resource references, both repositories' final changes and the original dirty-tree boundary. Local cohesive commits are authorized for this task; push, deployment, account actions and new distribution archives are not and were not performed.
