# Core Metrics project analysis and remediation report

Review dates: **2026-09-04–2026-09-05**. Baseline revision: **`4fc4e62`**, `feat(metrics): add aggregate utilization choices`. This report records implemented work, validation and limits; it is not a submission approval or a guarantee of security.

Current status-label behavior is recorded in [Native text regression repair](#native-text-regression-repair). Earlier bitmap-renderer measurements and screenshots below describe a superseded implementation.

## Scope, baseline and preservation

The request described an iOS application, but repository discovery established a **native macOS-only menu-bar utility**. The review followed the actual product and retained macOS 27. No iPhone/iPad layouts, orientations, multitasking, mobile deployment targets or new platform features were introduced.

The complete tracked repository was inspected across source, tests, project/workspace metadata, shared schemes, asset catalog, entitlement/manifest files, documentation, contribution templates, agent guidance and ignore rules. Relevant local Xcode, SDK, simulator, cache, archive, symbol and device-support categories were inventoried read-only. Manual privacy/security review covered the actual data flows and build artifacts. There was no Codex Security Scan, dedicated security-scanning workflow or third-party source upload.

Four files were already modified at entry:

| File | Pre-existing work preserved |
| --- | --- |
| `.gitignore` | Seven additional ignore entries for build/distribution/signing artifacts. |
| `Core Metrics.xcodeproj/project.pbxproj` | Export-compliance key set false in Debug and Release. |
| `Core MetricsUITests/CoreMetricsUITests.swift` | AppKit import and termination of earlier app instances before UI launch. |
| `docs/APP_STORE.md` | Export-compliance explanation/checklist. Meaning retained in rewritten release guidance. |

The initial diff was saved outside the repository before editing. A temporary Xcode-only ordering change in the project file was reverted; its final diff contains only the two original export-compliance additions. The initial review made no commits. The follow-up explicitly authorizes separate task commits and a push. No Git-history rewrite, distribution archive, publisher-account/signing change or unrelated source reset is part of this work. License paragraphs in README and CONTRIBUTING were preserved verbatim.

### Actual application inventory

| Area | Verified state |
| --- | --- |
| Toolchain | Xcode 27.0 beta 6 (`27A5252f`), Apple Swift 6.4 compiler, macOS 27 SDK/host. |
| Language/isolation | Swift 6 language mode; complete strict concurrency; app MainActor default isolation and approachable concurrency. |
| Platform/deployment | macOS 27.0 across app and both test targets. Apple silicon host exercised; macOS 27 supports Apple silicon Macs, so Intel execution is outside the supported platform. |
| Entry point | `Core Metrics.xcodeproj`; internal project workspace only, no independent workspace setup. |
| Targets | `Core Metrics`, `Core MetricsTests`, `Core MetricsUITests`. |
| Schemes | `Core Metrics`, `Core Metrics UI Tests`. |
| Configurations | Debug and Release; no staging/production endpoint split is needed. |
| Lifecycle/navigation | SwiftUI App, window-style MenuBarExtra, native Settings/SettingsLink, AppKit About/Quit; LSUIElement. |
| State/persistence | MainActor observable MetricsStore and PreferencesStore; immutable current snapshots; app-only JSON preferences in UserDefaults. |
| Acquisition | Public host CPU/VM/page-size counters, physicalMemory, public swap sysctl, Foundation volume metadata for `/`. |
| History | None: no history array, chart, metric persistence or telemetry. |
| Dependencies | No SwiftPM/Pods/Carthage/local packages, third-party binaries, framework bundles, install scripts or code generation. |
| Extensions/services | No widgets, App Clips, Catalyst target, notification/share extensions, helper, daemon or background service. |
| External behavior | No network/API/backend, authentication/Keychain, purchases, notifications, deep/universal links, cloud, analytics, crash SDK or remote configuration. |
| Resources/localization | One AppIcon catalog with ten opaque size/scale variants; retained 1024-pixel documentation master. No bundled translations/string catalog. |
| Build automation | Shared schemes; no CI workflow, shell build phases, SwiftLint or formatter configuration, snapshot or benchmark framework. |
| Release metadata | Version 1.0/build 1, Utilities category, placeholder bundle identity, sandbox/hardened runtime, encryption indicator false. |

## Initial assessment and priorities

The initial assessment was recorded before architectural edits. The project already had coherent boundaries, defensive metric arithmetic, injected providers, weak task ownership, narrow entitlements, a useful unit suite and no dependency debt. A wholesale architecture replacement would have increased risk without evidence of benefit.

| Priority | Finding | Disposition |
| --- | --- | --- |
| Critical | No critical source defect confirmed by the reviewed paths. | No claim of exhaustive security proof. |
| High release gate | Beta-only validated toolchain, placeholder publisher setup, policy/support URLs and final distribution validation missing. | Documented; publisher actions remain. |
| Medium correctness | Cancelled synchronous sampling could publish after stop/restart. | Fixed with generation/cancellation validation. |
| Medium correctness | Reused URL resource cache could supply stale storage capacity off-main. | Fixed with explicit cache invalidation per sample. |
| Medium accessibility | Repeated short checkbox labels lacked metric context. | Full descriptive accessible labels added. |
| Medium layout | Some locale fallback digits exceeded an ASCII-derived fixed width. | Measured, fixed and regression-tested. |
| Medium test reliability | UI toggle restoration could change single-stat Value Only to Compact. | Original representation restoration added. |
| Low energy/work | Equal preference assignments re-encoded and rewrote UserDefaults. | Equality guard and persistence regression added. |
| Low build work | Unit scheme built unused UI runner. | Redundant build entry removed; dedicated UI scheme retained. |
| Low documentation | Root guidance referenced nonexistent UI/history structure, some semantics and validation claims were stale. | Documentation and canonical agent guidance rewritten. |
| Environment | Large recent simulator/device-support/cache data, no verified stale/corrupt entries. | Retained; zero bytes recovered. |

Initial Debug build and unit run passed **43 test declarations / 88 parameterized executions**. Baseline Release build passed. Dependency resolution found no packages. There were no Swift compiler/concurrency diagnostics. Xcode emitted the App Intents metadata warning described below. No configured lint/snapshot/performance/secondary-platform suite existed to run. Initial cold/warm launch and energy baselines were not measured under controlled conditions.

## Implemented changes and rationale

### Sampling lifecycle and storage freshness

`Core Metrics/Application/MetricsStore.swift` now creates a UUID for each start and checks it, plus cancellation, before publishing on the main actor. `stop()` invalidates publication immediately, cancels the task and returns its handle for callers that need to await completion. An already-running synchronous provider call can finish, but its retired result cannot modify new state or emit misleading recovery/failure logs. Cancelled CPU acquisition also skips the subsequent memory query. Existing weak captures and structured child loops remain.

The redundant private `recordStorageFailure()` helper was removed; nil and thrown storage failures now share the guarded publication path. The label’s former `statusWidth` function was also extracted into the new locale-aware layout helper. Sampling cadence, snapshot formulas, provider protocols and preference contracts did not change.

`Core Metrics/Metrics/Storage/RootVolumeStorageProvider.swift` clears cached resource values on a local URL copy before every read. Apple's [resourceValues documentation](https://developer.apple.com/documentation/foundation/url/resourcevalues(forkeys:)) documents caching and main-thread automatic invalidation; this app samples off-main. [Explicit invalidation](https://developer.apple.com/documentation/foundation/url/removeallcachedresourcevalues()) avoids stale readings without a new cache layer or entitlement.

Reviewed and retained: unsigned CPU tick wrapping, zero-delta handling, overflow-safe memory arithmetic, physical-memory clamping, structure-size checks, independent swap failure, startup-volume clamping and Mach send-right deallocation. No private API or process/file scan was introduced.

### Locale layout, accessibility and preference writes

New `Core Metrics/Views/MenuBar/MenuBarLabelLayout.swift` measures locale digit/separator/percent glyph widths with the existing system monospaced font. `MenuBarLabelView` holds the reservation in state and updates it on locale changes. Established English names/codes and eight-character value padding remain. The full Settings preview keeps measured text and horizontal scrolling.

Repeated native testing showed that MenuBarExtra's adaptation of a Text title did not reliably retain the fixed font/layout: both a default font modifier and attributed text still drifted with seven live values. `MenuBarStatusLabel` now renders the same text with the public [ImageRenderer API](https://developer.apple.com/documentation/swiftui/imagerenderer) and supplies a template image to the existing native scene. It caches only the current CGImage, scale and full accessible description, rerendering when text, reserved width, scale or description changes. The image's intrinsic accessibility label includes every selected metric, even when the visible text is shortened.

The status image is capped at 320 logical points with a trailing ellipsis. This prevents large selections from demanding excessive menu-bar width while keeping the full selection in Settings and its accessibility description. Native template tint handles appearance changes. No private status-item introspection, coordinator, custom window or retained image history was introduced. Ordinary short labels preserve their measured width; full seven-stat text cannot be shown on every crowded/notched menu bar.

Panel checkboxes now expose full descriptive labels (for example CPU System and RAM Used %) while retaining concise visible rows. Settings removal controls explain their action or the last-selection restriction. Descriptive metric/mode names and hints use `String(localized:)` so extraction includes dynamic text. No authoritative translations were invented; status abbreviations remain unchanged. [Apple localization preparation](https://developer.apple.com/documentation/xcode/preparing-your-apps-text-for-translation) informed this change.

`PreferencesStore.configuration.didSet` skips persistence when the validated configuration is equal. No-op mode assignment/reset therefore avoids JSON encoding and a UserDefaults write. Real changes still publish and persist immediately; preference identifiers and both migration paths remain intact.

### Build and UI-test cleanup

Removed the `Core MetricsUITests` BuildActionEntry only from `Core Metrics.xcscheme`. Its TestAction never ran those tests, and the dedicated UI scheme already owns the runner. Baseline logs confirmed that the unused runner was built. All three targets and both schemes remain.

The UI tests retain the pre-existing duplicate-instance cleanup and now run two deterministic flows: light appearance with one Value Only stat, and dark appearance selecting seven Compact stats through the opened native panel. Both launch with one stat so initial activation can be tested on the crowded desktop. A DEBUG-only launch configuration resets an isolated test preference suite and sets only the application's appearance. The dark flow then relaunches with its test-suite selections preserved to verify startup with seven stats. Normal launches retain normal preferences; Release compiles out the test configuration and call site. Tests stop after a missing panel prerequisite, retry initial panel activation once, restore selection/representation, check full accessible labels, scroll to offscreen controls, verify status-item width changes and test the Privacy sheet. Panel, Settings and sheet screenshots target finite elements and remain outside tracked source.

### Privacy information and reachable Settings content

Settings now offers a native Privacy sheet describing aggregate readings, current-memory-only values, locally saved preferences, no network connections, and category/state-only diagnostics. Its selectable text is scrollable and keyboard-focusable; Done/Return and Escape dismiss it. Runtime testing identified SwiftUI propagating the root accessibility identifier over child identifiers; removing the unnecessary root identifier preserves the title, content and Done identifiers. The live preview exposes native scroll indicators, focus, an accessible label/hint and clear horizontal-scroll guidance.

This factual in-app information is implemented. Publisher-approved policy content and public privacy/support URLs remain a submission requirement; no contact, legal promise or URL was invented.

### Live provider integration coverage

Two additional integration tests exercise repeated real CPU and memory system reads, check usable counters and normalized/clamped snapshots, and permit legitimate unavailable swap. They complement deterministic calculator and failure-injection fixtures without assuming a particular host workload.

No app identity, signing setting, entitlement, deployment target, resource membership, dependency manager or provider/preference contract was changed. A new xcconfig hierarchy or navigation framework was not justified.

## Measurements, performance, memory and energy

| Measurement | Before | After | Interpretation |
| --- | ---: | ---: | --- |
| Unit declarations / case executions | 43 / 88 | 50 / 103 | Focused new regressions and real provider reads; no tests disabled. |
| Locale width probe | 35 overflowing cases | 0 overflowing cases | 1,072 installed locale IDs × 20 representative formatted values; local probe, not all possible strings/fonts. |
| English eight-character value reservation | 66 pt | 66 pt | Existing English layout preserved. |
| Chakma example | 83.7805-pt text in 66-pt frame | 105-pt fixed reservation | Wider fallback glyphs now fit; all corresponding regression modes pass. |
| Release executable logical bytes | 626,656 | 754,912 | +128,256 bytes for correctness/layout/privacy support, not a size optimization claim. |
| Release app logical bytes | 2,313,401 | 2,441,657 | +128,256 bytes, approximately 5.54%; same resources. |
| Developer artifacts deleted / recovered | — | 0 / 0 bytes | No unsupported cleanup claim. |

Release size comparisons used the same host, configuration and architecture with unsigned products. Allocated disk sizes differ from logical sizes. Build/test timings were affected by a busy shared desktop, indexing and other local workloads; no reliable cold-build or launch-speed improvement is claimed.

Sampling remains roughly every two seconds for CPU/memory and 30 seconds for valid storage, with faster retry after failures. No additional polling, background service, network work, chart buffers, unbounded cache, forced animation or history was added. The rendered status label retains one image and rerenders only when its display inputs change; this adds UI rendering work whose long-duration energy cost has not been benchmarked. Locale measurement is not performed per sampling tick. Avoided no-op preference writes and removed UI-runner build work are concrete reductions; battery or wall-clock savings were not benchmarked.

Ownership/lifetime fixtures and focused Thread Sanitizer execution passed. The reviewed source has bounded current-state storage and weak task captures. No controlled Instruments allocation/leak/energy/launch comparison was completed; leak freedom, launch latency and long-duration energy behavior are not asserted. Available xctrace templates were inventoried. A follow-up 10-second Time Profiler launch completed, but trace metadata showed Launch Services selected the previously registered Xcode product rather than the requested isolated product. That trace is retained locally and is not evidence for final-binary performance. No before/after profiling claim is made.

## Manual security and privacy review

**No Codex Security Scan was started, invoked, suggested or used.** No dedicated security workflow or external scanner received source, symbols, repository metadata, credentials or application data.

Reviewed manually:

- System API boundaries, pointer rebinding/count checks, Mach resource ownership and arithmetic validation.
- MainActor state, Sendable/provider boundaries, cancellation, late-result publication and task lifetime.
- App-only UserDefaults payload validation/repair/migration, equality behavior and test-suite isolation.
- Logging payloads, shipped resources, ignored artifacts, generated Info.plist, build phases and dependencies.
- Sandbox/hardened-runtime configuration, source/effective development entitlements and public binary linkage.
- Required Reason categories, no-data/no-tracking manifest entries, network/capability absence and release metadata.
- Current repository text for absolute personal home paths, credentials/private-key patterns and signing-team assignments; no true matches found. A bounded follow-up also checked all 301 reachable source blobs across 34 baseline commits and their filenames; this is not proof against arbitrary sensitive material.

Authentication, authorization, token/session/Keychain handling, web views, TLS/pinning, import/export, archive extraction, database migrations, push links, purchases and backend assumptions are absent, so no fictitious remediation was added for them. No secrets, test credentials, network endpoints, third-party SDKs, privacy-sensitive permission requests or excessive source entitlements were found in the reviewed tree.

The existing manifest retains Disk Space `85F4.1` for local capacity display and User Defaults `CA92.1` for app-only preferences, with no tracking or collection. These match Apple's [current category/reason definitions](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitype). macOS applicability and all declarations must be rechecked before submission. The source manifest/entitlements lint and are correctly packaged.

Unsigned Release has no effective distribution signature to validate. Ad-hoc UI Debug includes sandbox and debugger access plus generated test exceptions for read-only paths and global Mach lookup. The runner itself has broader XCTest capabilities. These are generated development/test artifacts absent from the source entitlement file; they do not establish final shipping permissions. No entitlement was added to silence a sandbox error.

No source-level security vulnerability was claimed fixed. The cancellation/cache fixes improve reliability and truthful local display. Security limits remain: no formal proof, exhaustive historical/metadata audit, distribution validation, organization/legal review, or exhaustive dynamic API analysis. See [APP_STORE.md](APP_STORE.md).

## Code, resource, dependency and documentation inventory

Production changes: MetricsStore, RootVolumeStorageProvider, PreferencesStore, MenuBarDisplayMode, MenuBarStat, MetricKind, MenuBarLabelView, MenuBarStatToggleView, MenuBarStatSettingsRow SettingsView, Core_MetricsApp, and new MenuBarLabelLayout, MenuBarStatusLabel, PrivacyInformationView and DEBUG-only UITestLaunchConfiguration. Tests changed: MetricsStoreTests, StorageUsageCalculatorTests, PreferencesStoreTests, CoreMetricsUITests and new MenuBarLabelLayoutTests and MetricProviderIntegrationTests. Shared main scheme changed as described above.

Removed: one superseded private storage-failure helper, the former label width function (replaced by locale-aware layout), and one redundant unit-scheme UI build entry. **No files, types required by migration, assets, targets, schemes, dependencies, runtime features or translations were deleted.** No dependency was added, removed, replaced or upgraded. Ten catalog slots remain valid, opaque and correctly sized; their source PNG total is 1,633,152 bytes. Equal pixel-size files are required scale variants, and the source master remains outside the app target.

Documentation rewritten or revised to match final code:

- `README.md`: actual platform/toolchain, setup, targets, dependencies, commands, architecture, privacy, maintenance, release and troubleshooting.
- `AGENTS.md`: canonical actual paths, concurrency/lifecycle rules, commands, resource/migration precautions, privacy/signing constraints, cleanup limits and explicit scan prohibition.
- `CONTRIBUTING.md`: focused workflow linked to canonical rules; license wording retained.
- `docs/ARCHITECTURE.md`, `DECISIONS.md`, `DESIGN.md`, `METRICS.md`, `APP_STORE.md`, `ICON.md`: corrected ownership, no-history model, gap heuristic, cache freshness, format units, accessible layout, provenance and release facts.
- New `docs/DEVELOPMENT.md`: consolidated setup/configuration/testing/Xcode-maintenance/troubleshooting runbook.
- New `docs/PROJECT_ANALYSIS_REPORT.md`: this permanent record.
- Bug template now requests Xcode version for build problems; PR template requests concrete checks/limitations and configuration preservation.

The existing feature template and issue configuration were reviewed and retained because they already match scope. No nested AGENTS, CLAUDE, GEMINI, Copilot, Cursor or Windsurf instruction files existed. No redundant instruction adapters were added. No legal file, copyright notice, maintainer identity, privacy contact or organizational promise was invented.

## Development-environment inventory and cleanup

All figures below are sanitized. Sizes use `du -sk` converted to MiB, except the runtime image size reported by simctl. Entry modification ages are not last-use evidence. The inventory preceded cleanup decisions; later review builds naturally generated additional temporary outputs.

| Category | Observed baseline | Action |
| --- | --- | --- |
| Active Xcode / command-line tools | One Xcode beta installation ~3.58 GiB; CLT ~1,340.5 MiB, version 27 package. | Retained; developer selection unchanged. |
| DerivedData total | 1,463.7 MiB; 11 immediate entries, 0–3.3 days. | Retained. |
| Active Core Metrics build data | 302.9 MiB. | Retained. |
| Module / SDK stat / symbol caches | 581.9 / 16.1 / 30.4 MiB. | No verified fault; retained. |
| Other project build data | ~532.5 MiB, recent. | Unrelated work preserved. |
| Xcode / SwiftPM caches | 4.7 / 0.2 MiB. | Retained. |
| Recent result bundles | 6, 147.5 MiB. | Diagnostic evidence retained. |
| Recent dSYMs | 2, 6.1 MiB. | Retained. |
| SourcePackages/doc archives | None found in inventoried DerivedData. | No action. |
| Simulator runtime | iOS 27, Ready, image 8,014,997,345 bytes (~7.46 GiB). | Retained for other projects. |
| Simulator devices/data | 15 available/shutdown devices across 11 types; 37,079.4 MiB. | Retained; no unavailable device. |
| Same-type simulator extras | Four extras; no demonstrated redundancy. | Manual-review candidates only. |
| iOS DeviceSupport | 6,685.9 MiB; one recent entry ~2.2 days. | Retained. |
| Other device support / archives | Absent in inventoried locations. | No action. |
| CoreSimulator logs | 9.5 MiB. | Retained. |
| Preview/simulator caches | Empty/negligible. | No action. |

**Exact deletion count: zero. Exact disk space recovered: 0 bytes.** No simulator device/runtime was erased or removed, no archive/dSYM/device support/signing material was deleted, and no broad developer-directory cleanup was run. The Mac-only product needs no simulator boot test; the installed unrelated runtime was reported Ready and all devices available. They were not booted unnecessarily.

Temporary review products/logs/result bundles were created outside the repository for reproducibility and retained as local diagnostics. These are new artifacts, not recovered disk space. There was no cache deletion, so no cleanup-induced cold rebuild. Future cache deletion will make the next build slower and requires a verified stale/faulty candidate.

## Validation commands and outcomes

Commands were run from the repository root; local output paths are intentionally not tied to a user's home directory. Some equivalent checks were performed through read-only scripts to summarize output without private identifiers.

| Command/check | Outcome |
| --- | --- |
| `xcodebuild -list -project "Core Metrics.xcodeproj"` | Three targets/two schemes and Debug/Release confirmed. |
| `xcodebuild -version`, `xcrun swift --version`, `xcode-select -p`, `xcodebuild -showsdks`, `sw_vers -productVersion` | Compatible selected beta toolchain/host confirmed; no selection change. |
| `xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics" -resolvePackageDependencies` | Passed; no source packages. |
| Debug build + unit test, macOS arm64, `CODE_SIGNING_ALLOWED=NO` | Baseline 43/88 and follow-up 50/103 passed, zero failures/skips. |
| Release build, same project/scheme/arm64 destination, `CODE_SIGNING_ALLOWED=NO` | Baseline and final passed. |
| `xcodebuild ... -scheme "Core Metrics" ... CODE_SIGNING_ALLOWED=NO analyze` | Final Release analysis passed; the initial standalone Debug analysis also passed. |
| Unit test with `-enableThreadSanitizer YES '-only-testing:Core MetricsTests/MetricsStoreTests'` | Five declarations/seven executions passed; no TSan finding reported. |
| UI scheme with `CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=YES test` | Final follow-up run passed: two UI tests, zero failures/skips; seven-stat relaunch and both appearances covered. Intermediate failures retained below. |
| `xcrun xcresulttool get test-results summary ... --format json` | Test counts/results inspected; final standard unit summary has no runtime warnings. |
| `xcrun xcresulttool export attachments ...` | Panel/Settings screenshots inspected locally; unredacted desktop captures kept outside repo. |
| `plutil -lint` on project/manifest/entitlements; plist/resource inspection | Passed. |
| `otool -L`, `codesign -d --entitlements :-` on review products | Public Apple linkage/resources; development-signing limitations recorded above. |
| Icon dimension/opacity checks (`sips` and file inspection) | Ten catalog entries valid/opaque. |
| Locale real-source Swift/AppKit probe and layout regressions | 35 overflows reduced to zero for measured matrix; unit regressions pass. |
| `xcrun simctl list runtimes --json`, `list devices --json`, `runtime list -j` | Healthy runtime/available device inventory; no deletion. |
| `pkgutil --pkg-info com.apple.pkg.CLTools_Executables`, scoped `du`/age inventory | Completed read-only. |
| `xcrun xctrace list templates` | 10-second launch recording completed; registered-product mismatch prevents using it as final-build performance evidence. |
| `git diff --check`, current-tree private-data pattern checks, local-link checks | Passed for completed files; final report checked after writing. |

Representative exact build commands (each used an isolated review DerivedData directory where appropriate):

```sh
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics" -destination 'platform=macOS,arch=arm64' CODE_SIGNING_ALLOWED=NO build test
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics" -configuration Release -destination 'platform=macOS,arch=arm64' CODE_SIGNING_ALLOWED=NO build
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics" -destination 'platform=macOS,arch=arm64' CODE_SIGNING_ALLOWED=NO analyze
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics" -destination 'platform=macOS,arch=arm64' CODE_SIGNING_ALLOWED=NO -enableThreadSanitizer YES '-only-testing:Core MetricsTests/MetricsStoreTests' test
xcodebuild -project "Core Metrics.xcodeproj" -scheme "Core Metrics UI Tests" -destination 'platform=macOS,arch=arm64' CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=YES -test-timeouts-enabled YES -default-test-execution-time-allowance 60 -maximum-test-execution-time-allowance 60 test
```

### Failed/intermediate checks and diagnostics

1. The first new cached-capacity test used `#require(provider.sample())` without the inner `try`. Swift macro expansion correctly rejected it. Added `try` inside the expression. The combined build/test/analyze invocation failed; subsequent independent build/unit/analyze checks passed. No check was weakened.
2. Initial UI run launched the app and found its status item but failed to open the panel, producing fourteen dependent assertions. It overlapped desktop/Xcode activity; the precise cause was not established. An isolated rerun opened the panel and Settings.
3. A new accessibility assertion incorrectly expected “Memory Used Percentage”; the actual established label is “RAM Used %”. The assertion was corrected to the source's unchanged wording. The next panel/Settings UI run passed.
4. Direct CUA attachment to the menu-bar-only app timed out. Xcode Run launched the app but logged App Intents system-service connection errors. A later desktop-control stop request also timed out. Native XCTest supplied the successful interaction evidence instead; no protection or permission was weakened to make automation pass.
5. Xcode beta emits `Metadata extraction skipped, no AppIntents.framework dependency found`. The app has no App Intents feature. This build-tool warning remains; there are no final Swift compiler/concurrency warnings. No unused framework was added and no warning was suppressed.
6. The added Settings mutation check initially treated radio-button values as String. The exported accessibility hierarchy showed numeric `value: 1`; support for NSNumber was added (including Value Only restoration). A diagnostic rerun stalled in teardown after the failed assertion and its owned xcodebuild command was interrupted. That partial run ended with exit 75 and a beta build-tool assertion/stack trace; its failed result was retained. No unrelated process was terminated.
7. UI runner logs include missing debugger-version lookup and DisplayManager messages about an infinite empty rectangle during screenshot capture. Successful interaction tests do not remove these beta/tooling diagnostics. Their root cause has not been proven.

8. Follow-up native UI checks exposed root accessibility-identifier propagation in the privacy sheet and an unsuitable Settings-window query. Removed the root identifier, kept explicit child identifiers, and selected the observed Settings window identifier. Scrolling now reveals offscreen controls and Local Diagnostics. Both issues were corrected without weakening assertions.
9. Starting directly with seven stats left an accessibility status-item frame but no visible/clickable item on the crowded/notched desktop. The root cause was not established as app, OS or menu-manager behavior. A later bounded status renderer addresses excessive requested width. The dark test selects seven through the UI and then relaunches that saved test configuration. The broader crowded/notched-device matrix remains unverified; selected stats are preserved, with a visible ellipsis when the image width is capped.
10. Seven-stat status width changed while preferences were unchanged. Both relative monospaced styling and attributed text failed repeated checks, even though one attributed-text run passed. The bounded template-image implementation replaced native title adaptation and passed the width checks. The unsuccessful intermediate runs are retained locally.
11. A combined follow-up UI run overlapped the native unit-test host and failed initial panel activation in both appearances. Subsequent desktop UI checks run separately from native unit hosts. This is an observed test-environment failure, not proof of a production root cause.

12. Template-image accessibility assertions initially read XCUIElement.label; native status items expose their spoken title through the separate title attribute. The tests now check that title, including metric names after seven-stat relaunch. The renderer embeds a full accessibility label in the public CGImage-based Image initializer.

13. One follow-up run could not find a scroll hit point in Settings on the active desktop. The test now explicitly activates its application after following SettingsLink before querying/scrolling its window. The final combined run passed both scenarios.

### Runtime coverage and remaining gaps

App launch was observed through Xcode and XCTest. XCTest verified the status item, persistent panel, repeated toggle behavior, expected controls, full accessible labels, Settings preview and Restore Defaults control. Captured dark-appearance screenshots were inspected: native grouped forms, stable three-stat label and scrolling content were visible. These earlier captures include other desktop content and were not committed or published. Follow-up attachments capture individual panel, Settings and sheet elements; light and dark captures were inspected locally.

The September 4 bounded UI run passed (one test, zero failures, 27.527 seconds reported by XCTest). It changed Settings from Label and Value to Compact, verified immediate status-item width change, restored the original mode and confirmed the original width. Selection/representation restoration code handles both String and NSNumber accessibility values. That earlier run exercised an existing three-stat configuration. The follow-up adds isolated one-stat Value Only and seven-stat selection flows, privacy scrolling and Return/Escape dismissal. Full VoiceOver spoken navigation, keyboard-only traversal, largest desktop text, Increased Contrast, Reduce Motion/Transparency, Differentiate Without Color, Switch Control, notch/small-screen extremes, long-running leak/energy behavior were not exhaustively verified. Native controls and targeted layout tests support the implementation but do not substitute for that matrix. No iPhone/iPad/simulator/rotation test applies to this Mac-only repository. Address Sanitizer was not run; no suspicious new raw-memory manipulation was introduced.

The final September 5 combined UI run passed **two tests, zero failures/skips**: dark/seven-stat flow **109.958 seconds** and light/Value Only flow **29.250 seconds** reported by XCTest. It verified stable bounded status width, native title accessibility containing full metric context, selection/representation changes, privacy scrolling and Return/Escape, and persisted seven-stat relaunch with a clickable panel. The seven-stat status frame was **338 pt**, including platform margins around the **320-pt** image. Locally inspected screenshots show a crisp monospaced label with an ellipsis for the long selection, the complete readable Settings content, and accessible focus outlines in both app appearances. App-local appearance does not change the system-wide menu-bar theme.

Final builds also include a nil-image fallback, reviewed statically; no renderer failure was induced. All DEBUG test-launch markers are absent from the final arm64 Release executable. Full VoiceOver spoken navigation, all keyboard actions, all display/accessibility settings and long-duration profiling remain beyond the evidence above.

## Release disposition, intentional deferrals and rollback

Repository-level improvements are implemented and locally tested within the evidence above. Submission remains blocked by publisher work: stable accepted Xcode validation, publisher-controlled identity/signing/provisioning, public privacy/support pages and publisher approval of in-app policy content, App Store metadata, legal/license decisions, full accessibility/display review, and a signed distribution archive with privacy report/effective-entitlement validation. No backend or account-service action is required because none exists.

Intentionally not changed: deployment target, platforms, identities, signing assumptions, entitlement/manifest entries, metric formulas/cadences, status abbreviations, visual identity, icons, persistence keys/migrations, legal notices, dependencies and unrelated user edits. No general architecture rewrite, new CI provider, UI framework, package manager, lockfile, helper or optimizer feature was justified. Uncertain developer artifacts were retained.

Rollback is local and separable: revert the relevant task commit or its individual hunks. The authorized build commit includes the pre-existing ignore/export-compliance work; preserve those hunks when rolling back only remediation changes. Do not reset the entire working tree. There is no database/schema migration, new entitlement or persisted preference format to roll back. Reverting the lifecycle/cache/locale fixes would restore the corresponding defects. The follow-up UI tests use an isolated DEBUG-only preference suite; normal application preferences are never reset by that configuration.

Future work, **not completed**: publisher release gates; complete interactive accessibility/display matrix; controlled Instruments launch/energy/long-duration memory profiling; translated string catalog after human review; optional CI with the actual supported stable Xcode; exhaustive additional historical/metadata hygiene review if needed before public release. None of these are claimed as implemented.

## Final reconciliation

Compared this report with the final working diff, including all four pre-existing modified files and eight new files (layout helper/tests, status renderer, privacy sheet, DEBUG-only launch configuration, provider integration tests, development runbook and this report). All material source/test/scheme/documentation changes and both extracted/removed functions are accounted for. No file/resource/target/scheme/dependency deletion or environment deletion is omitted. All 83 tracked-plus-new files were included in final path/private-pattern review; local documentation links resolve and `git diff --check` passes. Project, source entitlement and privacy-manifest plists lint successfully. The follow-up changed privacy/UI-test code after initial validation; final results below distinguish those checks from the earlier review.

Completed: targeted implementation and documentation remediation, successful Debug/Release builds, 50 unit declarations/103 executions, focused TSan coverage, two final native UI/Settings/privacy tests, source/artifact review and safe environment inventory. Unresolved: beta system/tool diagnostics, unexercised accessibility/display/performance coverage, and the publisher release gates above. No claim of complete security or guaranteed App Store approval is made.


## Authorized task commits

The September 5 follow-up explicitly requested separate commits and a push. Storage freshness, sampling cancellation, preference writes, contextual accessibility, public-provider tests, privacy information, Settings scrolling, build preparation, locale layout, bounded status rendering, and isolated desktop tests are separate commits. Documentation and this evidence record are committed together afterward. Commit authorship uses a neutral contributor identity; no signing, publisher or account configuration was changed.


## September 5 feature follow-up

After the remediation commits were pushed, the user approved all four proposed additions: optional Launch at Login, Metric Help, Copy Current Readings, and one-command local validation. This section records that separate feature follow-up; measurements and counts above describe the preceding remediation.

### Implementation and boundaries

- **Launch at Login:** Settings reflects actual macOS registration through public `SMAppService.mainApp`. Initialization only reads state; explicit toggles register/unregister. Pending approval, unavailable states, sanitized errors and a System Settings action are exposed without a helper, extra entitlement, signing change or shadow UserDefaults flag. The owned operation rejects overlap and does not retain the store during suspended unregister. Restore Defaults still affects menu-bar preferences only.
- **Metric Help:** Native sheets from the panel and Settings explain CPU normalization, overlapping memory categories, memory use versus pressure, binary memory versus decimal storage units, startup-volume capacity and unavailable/update behavior. Text is selectable and scrollable, headings are semantic, and Done/Return/Escape dismiss. The metric formulas are unchanged; a stale text-only status-rendering sentence in METRICS was corrected.
- **Copy Current Readings:** Explicit copying includes the full selected names and locale-aware current values, even when the status label truncates them. Unavailable is spelled out; no timestamp or machine identity is added. Success is shown inline and announced through the public accessibility notification API; failure uses a native alert. Privacy describes the macOS clipboard and potential Universal Clipboard sharing. The app adds no network connection or retained metric history.
- **Validation:** `scripts/validate.sh` serializes isolated Debug build, unit tests, Release build, analysis and optional signed UI tests. A native Foundation helper verifies source/packaged plists, reviewed privacy and sandbox declarations, metadata agreement, Release test-hook exclusion and effective UI sandboxing. Build outputs remain in a private external run directory. Failure stops dependent work; unexpected warnings fail validation, while the known AppIntents metadata warning is counted and explicitly retained as a limitation. There is no distribution archive or publishing step.

New source is limited to login service/state types and its Settings section, the help sheet, copy formatting/pasteboard/button helpers, three unit-test files, and two validation scripts. App/Settings/panel composition, Privacy, desktop tests and documentation integrate those additions. No resource, target, scheme, entitlement, privacy declaration, migration or dependency was removed or changed for these features.

### Verification and remaining release checks

The validation driver passed Bash syntax/help, Swift helper checks and 13 mocked guard/driver scenarios: default/UI success, paths with spaces and another working directory, serial ordering, failed-unit early stop, unexpected warnings, Release marker rejection, bundle identity mismatch, input mutation, old toolchain, invalid arguments and checkout-output rejection (including symlinks). These checks establish script behavior, not app correctness.

The first real invocation stopped before app builds because a concurrent final edit shifted the running shell’s read offset. Both scripts were then frozen and the full command restarted. This was an orchestration failure. The next invocation passed Debug build, all 64 unit declarations/139 executions, Release build and Xcode analysis, then exposed an overly strict verifier assumption: resolved Debug hardening was NO while both source app configurations were YES and resolved Release was YES. The verifier now checks both source configurations, enforces resolved Release hardening, and explicitly reports the Debug result as a development/test limitation. The artifact check passed against those real products after correction. No project setting was changed.

Second source reviews covered new UI composition, metric explanations, privacy text, login-task lifetime, clipboard formatting and test isolation. All 98 tracked-plus-new repository paths were reconciled; local Markdown links resolve. UI fixtures use a DEBUG fake login service and injected clipboard result, while a separate unit fixture uses a private named pasteboard and releases it. Automated tests never register a real login item or write the general clipboard.

Actual registration/approval/revocation and a subsequent login with the final signed installed application remain release checks. Full VoiceOver spoken navigation and the wider accessibility/display/performance matrix remain beyond the isolated tests. Publisher identity, signing, public privacy/support URLs, accepted stable toolchain and distribution validation remain unchanged external release gates. No cache, simulator, archive, dSYM, credential or signing cleanup was performed; recovered space remains 0 bytes.


The first new desktop attempt compiled successfully but XCTest timed out while enabling automation mode, before any app assertions ran. Several other-project Xcode processes were active on the host; they were left untouched. A cached retry and a third attempt at the previously successful UI-runner location also failed during automation initialization, with zero app test cases started. The runner path therefore did not resolve the failure. `DevToolsSecurity -status` reported developer mode disabled, but the cause of the XCTest timeout was not established; no authorization setting was changed. Direct CUA attachment to the exact running test build timed out; Finder had no capturable window, and the desktop tool refused access to Codex itself. No tool restriction was bypassed. The directly launched isolated test app was stopped before resuming unit validation. These are environment/tool failures, not app-test passes.


The expanded desktop suite compiles and contains checks for Copy success/failure, Help from both entry points and sheet dismissal, login toggling through a fake service, plus the previous selection, width, privacy and relaunch flows. Those new runtime assertions and screenshots were **not executed successfully** in this follow-up. No claim of validated new layouts, focus restoration, clipping, spoken announcements or real login behavior is made. Complete the desktop suite and manual visual/accessibility review in an authorized interactive test environment before release. Apple documents macOS UI-testing authorization in [its UI automation guidance](https://developer.apple.com/documentation/XCUIAutomation/recording-ui-automation-for-testing). Changes to ad-hoc code identity can affect privacy authorization continuity ([TN3127](https://developer.apple.com/documentation/technotes/tn3127-inside-code-signing-requirements)), but neither that mechanism nor a particular permission was established as this failure’s cause.

The real Release product measures 982,992 executable bytes and 2,669,737 logical bundle bytes, each 228,080 bytes above the preceding remediation build. This includes the new native views, service state and formatting code; no performance or energy improvement is claimed. Script follow-up also removed deprecated codesign entitlement-output syntax and verified the supported XML form against the signed UI app. Four further negative verifier cases reject source Debug hardening removal, resolved Release hardening removal, a missing resolved Debug setting, and the new DEBUG fake-service marker in Release.


### Final feature verification result

The corrected `./scripts/validate.sh --output-root /tmp` completed successfully: toolchain/project discovery, no-package dependency resolution, Debug build, 64 unit declarations/139 executions, Release build, Xcode analysis, source/packaged plist and privacy checks, metadata agreement, Release test-hook exclusion, unchanged configuration fingerprints, and working/staged whitespace checks. The final unit summary reports zero failures or skips. This default invocation explicitly skipped UI tests; the three separate signed UI attempts failed during runner initialization as documented above. The signed UI app’s effective sandbox and the source/packaged verifier modes were additionally verified against real artifacts.

The run retained three occurrences of the known AppIntents metadata-extraction warning and zero other warning lines. It is not warning-free or distribution-ready. The final source, tests and report received a second review; no further actionable source defect was identified. Local documentation links and staged personal/signing/secret-pattern checks pass. Source project configuration, source entitlements, privacy declarations, publisher identifiers and signing setup remain unchanged from the preceding remediation.

The additions are committed separately as optional login registration, metric explanations, current-reading copy, and the local validation tooling/runbook. The remaining product/architecture/privacy guidance and this evidence record form a separate documentation commit. The authorized push follows those commits; no distribution artifact or App Store upload is part of this action.


## Menu Bar Text and Settings follow-up

The user supplied a panel screenshot and clarified that **only the Menu Bar Text selector** should move to Settings; all metric checkboxes remain. The panel now omits that heading and segmented picker, allowing its grouped metric form to use the space. Settings presents the same three validated display modes directly below Live Preview. Selection limits/order, preference migration and formatting are unchanged. Removing the panel’s unused PreferencesStore environment read and Bindable projection also removes its root display-mode observation; the child stat/copy controls retain their own dependencies.

The existing desktop test explicitly called `app.activate()` after clicking Settings, which could hide a real activation failure. `ActivatingSettingsLinkStyle` now requests public `NSApplication.activate()` as part of a native button action before forwarding `SettingsLink` through `configuration.trigger()`. It preserves role, native styling, mouse/keyboard/accessibility interaction and scene navigation, with no private selector, window lookup, delay or gesture interception. Regression flows first activate Finder to establish a background Core Metrics process, then open Settings before any modal can activate the app, require foreground/hittable Settings without test assistance, verify the display picker only in Settings, and close/reopen through clicking and Command-comma.

Independent second reviews found no further confirmed metrics, cancellation, ownership, arithmetic, cache-freshness or status-rendering defect. Existing off-main polling remains bounded, old generations cannot publish after cancellation, and status rasterization occurs only when its Equatable render inputs change. No speculative sampling coordination or cache layer was added. APP_STORE’s hardening description was corrected to distinguish source configuration from the resolved Debug development setting.

The full validator passed Debug/Release builds, all 64 unit declarations/139 executions, Xcode analysis, source and packaged metadata/privacy checks, Release test-hook exclusion and configuration fingerprints. Its UI phase compiled but again failed while enabling XCTest automation mode, before any app assertion ran. The host had no other Xcode build/test processes at the preceding inventory; the exact cause remains unknown, and no security/automation setting was changed. Therefore the full `--ui` command exited nonzero and is not reported as an all-checks pass. The sole Command-comma shortcut is attached directly to the style’s inner native Button so its intended action includes activation. Final Release build/analysis passed after that relocation, and `build-for-testing` passed after the foreground setup and fresh-launch/reopening assertions were complete. No new desktop runtime assertion, focus behavior or screenshot was validated by those commands. The user was asked to confirm the updated Settings flow manually while other work continued.

A 30.05-second read-only observation of the already-running development process recorded 1.231% of one CPU core on average and resident memory between 39,216 and 39,312 KB (+96 KB). The new UI revision could not be confirmed in that process, and UI activity was uncontrolled: this is a baseline observation, not a benchmark of the new build or evidence of an optimization gain. No running app was stopped or launched for this observation. The actual new Release executable is 972,608 bytes and its logical bundle is 2,659,353 bytes, 10,384 bytes smaller than the preceding feature build. No long-duration energy or leak claim follows from these measurements.

The validator retained five occurrences of the known AppIntents extraction warning and zero other warning lines. A later incidental Xcode project-key reorder was restored without changing setting values. Source project configuration, entitlements, privacy declarations, signing identity, publisher identifiers, assets and deployment minimum are unchanged. Full desktop/focus/accessibility validation, real signed login behavior and publisher/distribution release work remain open. No caches, simulators, archives, dSYMs or signing material were removed.


## Native text regression repair

After the installation was consolidated, the user reported unfamiliar menu-bar typography and an inability to add more readings, while the earlier native-text version had worked. The saved app configuration contained three selected statistics in Label and Value mode; it was below the unchanged seven-stat limit. Independent source/history reviews found no selection mutation regression. The template image introduced by `f1c5d3b` imposed a 320-point tail truncation even when the third selected reading needed more space. It also rasterized the explicit monospaced font instead of allowing native title typography adaptation. The clipping is established from the implementation; the exact perceived font difference was not independently observed through desktop automation.

The repair restores the pre-renderer native attributed Text path in `MenuBarLabelView` and removes `MenuBarStatusLabel`, its image state and its arbitrary width cap. The existing font, locale measurement, full formatted string, spoken summary, one-to-seven selection model, preference decoding and sampling ownership remain. The Menu Bar Text selector remains only in Settings, all panel metric checkboxes remain, and SettingsLink retains its activation fix. Settings guidance now recommends Compact for space; it no longer describes an application-imposed cutoff. The Add Stat menu has a stable accessibility identifier for the new regression scenario.

The focused desktop regression opens Settings, adds Memory Used and SSD Free Space to the initial CPU statistic, checks all three native status names and selected rows, checks two-to-three width growth, then reopens Settings and confirms the third selection remains. It captures finite status-item and Settings screenshots for visual inspection. Existing scenarios now check native title content and representation expansion/contraction instead of the retired image's full-summary title and fixed 320/350-point bounds. A native title's accessibility contents and its frame do not by themselves establish visual font quality or full VoiceOver behavior.

The complete default validator passed Debug and Release builds, all 64 unit declarations/139 executions with zero failures or skips, Xcode analysis, source and packaged privacy/metadata checks, Release test-hook exclusion and unchanged configuration fingerprints. It retained three occurrences of the known AppIntents metadata warning and zero other warning lines. The separate local Release build passed strict signature verification with hardened runtime and exactly the sandbox-only source entitlements. It used the existing local ad-hoc identity and the documented command-only `CODE_SIGN_INJECT_BASE_ENTITLEMENTS=NO` to omit Xcode's injected debugger entitlement; project/publisher signing configuration was not changed. This locally signed Release measures 922,352 executable bytes and 2,612,017 logical bundle bytes. These are artifact sizes, not a runtime performance benchmark.

Native text allows macOS to adapt font and width. The older evidence of live width drift and crowded/notched menu-bar limits remains relevant, so this repair does not assert perfectly stable native geometry or universal seven-stat visibility. Complete supplied readings and the user's previously working native typography take precedence over the removed bitmap constraint. No formula, provider, preference migration, identity, entitlement source, asset or deployment-target change is part of this repair.


The focused native UI command built the updated app and all UI test code with no compiler errors, then exited 65 because XCTest timed out while enabling automation mode before executing the app assertions. The result bundle reports a runner-initialization failure, not a failed selection assertion or a visual pass. That invocation retained two known AppIntents metadata warnings; the separate signed Release build retained one. Direct CUA inspection of the installed app timed out both before the repair and after installing it, including a fresh tool session. No automation/security permission was changed, and no desktop test restriction was bypassed. Current font appearance, interactive Add Stat behavior and the wider desktop matrix therefore remain unverified by automation.

The verified local Release replaced the existing app in Applications after its process quit, then launched from that exact installed path. Its executable hash matches the reviewed Release artifact; strict signature, hardened runtime and effective sandbox-only entitlement checks pass. Exactly one application registration and one fully launched process remain for the app identity. The normal preferences file is byte-for-byte unchanged across replacement. The immediately preceding bundle-consolidation task moved 29 older app/build bundles (48,123,247 logical bytes) to Trash. This repair moved the superseded installed app and its two temporary Debug app products (9,444,262 logical bytes) to Trash after launch verification; logs, result bundles, source, symbols, archives and signing material were preserved. Trash was not emptied, so recovered disk space is 0 bytes.

A second independent source review verified retired-renderer references and filesystem-synchronized target membership, retained locale/accessibility declarations and sampling ownership, and unchanged project/privacy/signing configuration. Documentation now distinguishes the restored native behavior from the superseded bitmap measurements. This is a focused repair of label presentation; it does not establish a fully validated release or claim a font/selection UI test pass.
