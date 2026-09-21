# Cross-repository reconciliation — 2026-09-21

The website repository owns the single current [37-item findings register](../../../core-metrics-website/docs/audit/FINDINGS.md), [launch-readiness report and commit ledger](../../../core-metrics-website/docs/audit/VERIFICATION.md), [ordered release checklist and owner inputs](../../../core-metrics-website/docs/audit/OWNER_ACTIONS.md), [product/data inventory](../../../core-metrics-website/docs/audit/PRODUCT_AND_DATA.md) and [legal/Apple source matrix](../../../core-metrics-website/docs/audit/LEGAL_APPLICABILITY.md). These links assume sibling checkouts. This native document is a bridge to that assessment, not a second findings register.

## Initial state and attribution

This reconciliation began on native main `45009336419b49bccab3e66e6d61072850b792ea` and website main `8aef7eddb8611398b944f23a7695e78f2f8f7a50`. The prior implementation audit contains native `4906017`/`4500933` and website `bb80a03` through `8aef7ed` (nine commits). Older changes, including `96edf35` panel anchoring, are historical work rather than new audit changes.

Pre-existing native APP_STORE.md and PROJECT_ANALYSIS_REPORT.md changes and untracked PUBLISHING_READINESS.md remain owner work. Baseline patches/hashes were captured; this task appends and selectively stages only its own report section. None of those existing changes is discarded or committed. Website was initially clean.

## What was verified again

Xcode27RC27A266a validator `0O14hz` passes project/schemes, dependency resolution (none), Debug/Release builds, **71 app-hosted unit declarations /169 execution leaves**, analysis, source/packaged plist/privacy checks, Release fixture exclusion, unchanged configuration fingerprints and whitespace. Units have zero failures/skips. APP-01's production-renderer tests and both native anchor tests pass.

The optional desktop phase exits65: XCTest times out enabling automation before any of 13 app cases starts. Its xcresult contains one runner-initialization failure, not a failed product assertion. Five known AppIntents metadata warning lines remain; zero other build warnings and zero missing-display rectangle diagnostics. Historical runtime layout/autoShortcut messages remain unverified. Computer-use inventory works, but Safari selection fails with screen-capture error -10005. No automation/security preference was changed. The selected candidate still needs the full desktop/manual matrix, actual signed login cycle and basic sleep/wake checks in checklist A3. Extended profiling is optional unless a symptom warrants it.

Read-only inspection of the existing September20 archive confirms **1.0(2)**, source recorded as `96edf35`, macOS27 SDK/Xcode27A266a, strict signature, sandbox, hardened runtime, no debugger entitlement, matching release identity/privacy manifest, no quarantine, known test markers, debug library or unexpected nested bundles. Existing installer signature also verifies. Recorded Apple validation/upload and beta metadata are historical; current Connect processing/review/public fields could not be read. There was no new archive, export, installed-app replacement, upload or tester invitation. No testers for now remains the recorded choice.

The native local cleanup `4906017` is absent from existing 1.0(2). Public candidate selection is unresolved; dead-code cleanup and documentation alone do not mandate a replacement upload. The neutral tracked development identity stays intentional; preserve the existing release-only configuration and app association.

Website fresh checks pass content/types/lint/build, 11 units, 58 Chromium, three synthetic production-state builds and final isolated 22 WebKit journeys. The first WebKit run had one Settings-click timeout; three unchanged focused repeats and the complete rerun pass, but root cause is unproven and retained as REC-03. Firefox still fails at profile initialization. Real publication validation correctly fails on seven unresolved inputs. All ten live pages load; legal pages remain drafts.

Fresh authenticated GitHub/Vercel read-only evidence ties latest successful hosted CI and READY production to website `9214768`, before the local fixes. Native remote main remains `96edf35`. Deployment region `iad1` does not establish all processing locations or retention; project-detail connector inspection is blocked by an argument-adapter mismatch. No credentials, private signing/account values or customer data are copied into tracked reports.

## Changes and completion boundary

Native `90d5e25` corrects stale listing instructions that still said release signing was deferred and website copy had only three modes. It distinguishes beta/public metadata and candidate selection, current asset/field rules, free distribution versus EU trader payment details, voluntary accessibility labels and initial-release controls. Listing copy and screenshot plan remain local drafts. No production Swift, tests, project/signing/privacy settings, assets or dependencies changed this pass.

Website paired commit **`ad05414`**, `docs(audit): reconcile findings and define evidence-gated launch path`, holds the current register/report/checklist. It separates 34 prior items from three new findings, current source from delivered versions, required submission/release work from optional follow-up, and operational evidence from policy text. The native report commit containing this bridge pairs with it under LEG-08, APP-02, OPS-01, STORE-01 and REC-01/02.

The second repository-wide review checked runtime ownership/cancellation, native geometry/anchor/Settings paths, privacy/resources/migrations, website route/publication/storage/CI boundaries, historical fixes, all changed documentation and preserved owner work. No further confirmed production-code defect justified a speculative change. All new work is committed locally; no push, deployment, account declaration, agreement acceptance, submission or release occurred. System caches, simulators, archives, dSYMs and credentials were retained; recovered system-cache bytes: **0**.

Technical candidate readiness is **NOT VERIFIED**; testing, submission and public launch remain **BLOCKED** for the specific evidence and authorization gates in the shared checklist. No compliance certification, public availability or Apple approval is claimed.
