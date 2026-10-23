# Core Metrics delivery plan

This is the maintained native-app plan. Scope and journeys are in [PRODUCT.md](PRODUCT.md); implementation contracts are in [ARCHITECTURE.md](ARCHITECTURE.md), [DESIGN.md](DESIGN.md), [METRICS.md](METRICS.md) and [DECISIONS.md](DECISIONS.md). The opening [analysis report](PROJECT_ANALYSIS_REPORT.md#fresh-mac-onboarding--24-october-2026) owns actual environment observations and check results. Dated release receipts remain evidence of their own checkpoint.

The October 24 request authorizes repository analysis and documentation improvements, with focused commits and one final default-branch push. Application changes, dependency upgrades, UI redesign, storage cleanup, installations, distribution and production/account operations are outside this batch. The follow-up phases below are proposed work, not authorization to implement them.

## Outcomes and status

| Phase | Outcome | Dependency | Status |
| --- | --- | --- | --- |
| 0 | Practical fresh-Mac orientation, product brief, prioritized plan and evidence boundaries | Actual files, global/repository guidance and independent source/workflow/product reviews | Complete: documents and combined review verified; commit/push outcome belongs to the Git receipt |
| 1 | Reproducible current-machine development baseline | Selected full Xcode and source configuration; interactive desktop for UI portion | Tool/source/resolved-setting probes pass; application build/test/runtime verification pending |
| 2 | Close remaining behavior and accessibility acceptance | Phase 1 desktop initialization; intended artifact and supported OS available | Open; historical partial acceptance does not close this phase |
| 3 | Address evidenced engineering gaps without changing product intent | Phase 1 baseline and separately authorized code task | Proposed; no confirmed runtime defect found in this review |
| 4 | Reassess the intended release candidate and publication prerequisites | Phase 2, publisher policy review, artifact/account evidence and explicit release authorization | Gated; no account or distribution work in onboarding |

## Phase 0 — Documentation and instruction readiness

- Read the global instructions from disk and discover ancestor/override/nested guidance. Resolve clear stale-toolchain/build statements and the unconditional-build-for-docs conflict; preserve signing, sandbox, privacy, release and UI gates.
- Confirm checkout, remote/default branch, starting changes, setup/tools, scripts, test ownership, hooks and CI. Preserve unrelated work.
- Reuse existing architecture/design/formula/decision/runbook files. Add PRODUCT and PLAN, repair current entry points, and keep historical receipts recognizable.
- Complete independent architecture, workflow and product reviews. Main agent integrates edits, performs a second repository-wide consistency review, stages explicit documentation files and delivers one complete batch on `main`.

**Acceptance:** claims agree with source/scripts; changed local links resolve or explicitly identify missing external prerequisites; no runtime/configuration/resource changes; no private data added; working/staged whitespace checks pass. No app rebuild or desktop suite is required solely for these prose changes. Main agent owns final Git operations; delivery status must reflect the actual push result.

## Phase 1 — Establish the new Mac baseline (P1; next task)

1. Reuse the recorded tool inventory, then confirm it remains applicable. Run `./scripts/validate.sh` once for Debug/Release, units, analysis, source/resolved-setting and packaged policy checks. Retain private logs/results and warning counts. No package installation, publisher credentials or simulator is expected.
2. If desktop automation is part of the same task and ready, choose `./scripts/validate.sh --ui` instead of first running the non-UI command. The UI suite terminates existing app instances; coordinate the active development session first. Otherwise perform one focused UI initialization attempt later before the remaining desktop suite, reusing valid non-UI results.
3. Diagnose initialization failures from the actual result bundle. Earlier-machine authentication/timeouts are context, not proof this machine is blocked. Do not change permissions, signing, entitlements or test timeouts to obtain a pass. Xcode connector access is optional; CLI checks can proceed while project access is unapproved.

**Acceptance:** report exact toolchain, revision, executed checks, warning/diagnostic counts and test results. A runner failure before scenario execution is blocked UI verification, never passing scenarios or a proven app defect. Unsigned success does not establish signed sandbox behavior, publisher signing or distribution readiness. Use [DEVELOPMENT.md](DEVELOPMENT.md#choose-checks-for-the-change); avoid repeated fresh-DerivedData full runs without invalidated inputs.

## Phase 2 — Complete runtime acceptance (P1)

- Verify the real status item/popover and Settings on the current desktop: one/three/seven selections, four modes, persistence, stable allocation across live values, expected resizing after selection/mode/locale changes, stationary panel, real outside clicks, repeated reopen and Escape, Settings activation and Finder recovery when space is constrained.
- Complete full keyboard/spoken VoiceOver review, light/dark and accessibility display settings, larger text/long locales and constrained menu-bar/window configurations. Record actual frames and observations; static accessibility attributes are insufficient.
- Exercise failure/recovery and sleep/wake on the intended artifact. Verify a real signed Launch at Login cycle only when explicitly authorized; automated fixtures must retain fake login and private clipboard isolation.
- Validate the minimum supported macOS 27.0 separately from this newer host. Identify an appropriate existing machine/environment before claiming coverage; no simulator or storage changes are implied.

**Acceptance:** evidence covers the [required design matrix](DESIGN.md#required-runtime-review) and remaining [candidate checklist](APP_STORE_LAUNCH_CHECKLIST.md). Label partial coverage and unavailable environments. Restore test-changed preferences/display settings. Do not redesign the UI to resolve a verification gap.

## Phase 3 — Focused engineering follow-ups (P2/P3)

| Priority | Proposed task and evidence | Acceptance and proportionate checks |
| --- | --- | --- |
| P2 | When sampling code next changes, add deterministic coverage for the coordinator's negative/long/boundary wall-clock gaps (`MetricsStore.isContinuous` and `Date.now`); existing accumulator and restart tests cover different boundaries. | A small approved test seam or pure-helper test demonstrates baseline reset/recovery without long sleeps. Keep structured sampling, weak ownership and obsolete-result rejection. Run the store/CPU suites, then appropriate combined checks for the final change. No clock/observer rewrite is preapproved. |
| P3 | Measure cold launch and steady-state resource use before further locale-cache or rendering optimization. The cache retains only immutable locale measurements; unbounded key count is not an established leak. | Record toolchain, workload, timing/energy methodology and baseline. Optimize only an evidenced problem; retain glyph/bidirectional/geometry contracts and rerun affected layout/UI checks. |

No dead-code removal, provider rewrite, framework migration or dependency addition is currently justified. CPU, memory and storage providers all have host-facing coverage, including storage cache invalidation in `StorageUsageCalculatorTests.swift`; do not infer a missing test from filenames alone. Preference identifiers, Objective-C menu actions, DEBUG fixtures and icon variants have runtime, compatibility or target/resource roles.

## Phase 4 — Release prerequisites (P1 before distribution)

- Read the [shared business policy](../../../iOS/BluffArtist/BUSINESS_POLICY.md) before changing public publisher/support/privacy/legal copy. Its verified new location replaces the former sibling path; unresolved final approvals remain separate from policy availability.
- Recheck the current artifact, source fingerprints, accepted Apple toolchain, signing prerequisites and App Store Connect state under separate authorization. The last recorded 1.0 (9) installation/account receipts are historical; old local release artifacts and credentials are not assumed to have transferred.
- Reconcile remaining website policy approval, candidate acceptance and publisher decisions against the existing release checklist. Website implementation/deployment belongs to its own repository and authorization.

**Acceptance:** gates in [APP_STORE.md](APP_STORE.md) and the [launch checklist](APP_STORE_LAUNCH_CHECKLIST.md) are satisfied with current evidence and explicit authorization for each relevant distribution/account action. Commit/push authorization alone permits none of these actions.

## Current blockers and next action

The shared business policy was located in the renamed iOS checkout and its maintained references repaired. Xcode's connector has no approved/open project; signed desktop permissions, distribution credentials/artifacts and minimum-OS access have not been established. The CLI toolchain, project discovery, package resolution and source/resolved policies work. No confirmed prerequisite currently blocks an unsigned application baseline, but that baseline has not run in this documentation batch.

**Next concrete task:** establish Phase 1 with one canonical non-UI validation run on this Mac, preserving its warnings/results, then attempt one signed desktop scenario when the session is ready. Application fixes should follow evidence from that baseline and require their own scoped request.
