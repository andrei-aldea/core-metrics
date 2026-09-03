# Architecture

Core Metrics uses a small layered architecture designed to keep system acquisition thin, calculations independently testable, and the menu-bar presentation free of low-level system code.

## Data flow

1. System providers acquire aggregate raw counters from documented Apple APIs.
2. Pure calculation types convert raw values into validated snapshots.
3. `MetricsStore` coordinates independent refresh cadences and handles CPU delta discontinuities.
4. A main-actor observable metrics store publishes only the current validated snapshots.
5. SwiftUI menu-bar and dashboard views render the metrics store, while Settings and the status label observe a dedicated preferences store.

The UI never calls Mach or volume-capacity APIs directly. Provider errors clear the affected current snapshot so an old reading is never represented as live. The UI renders an unavailable value and the affected section explains that recovery is automatic. A separate collecting state represents normal first-sample latency.

## Application surfaces

- `MenuBarExtra` is the primary scene and uses the native window style so its controls remain open during multi-selection and macOS supplies the surrounding Liquid Glass presentation.
- The label shows an ordered, validated selection of one to five concrete stats as one text value. Each numeric value reserves a five-character column in a monospaced design, so updates cannot drop part of a composed label or resize an individual slot.
- The status panel shows stat names and selection state—but no duplicate live values—and provides direct checkbox controls, a segmented display-mode picker, About, Settings, and Quit.
- `Open Core Metrics` opens a suppressed-at-launch standard window containing three grouped, aligned sections for CPU, memory, and startup disk. It has a 540-point minimum width and 460-point minimum height, uses system body text, and contains no charts or progress visualizations.
- A native `Settings` scene adds, removes, and orders menu-bar stats chosen from the supported CPU, memory, and storage representations. Its horizontally scrollable live preview reuses the production menu-bar slot view without forcing the Settings window wider.
- `LSUIElement` keeps the app out of the Dock and application switcher. The dashboard window activates the app only when explicitly opened. The extra does not persist an inserted/hidden state, avoiding an unrecoverable hidden configuration on relaunch.

## Concurrency

Sampling uses structured concurrency with one owned utility-priority task and cancellable, result-discarding child loops. The loops suspend with `Task.sleep(for:)`; they never busy-wait or retain an ever-growing list of child results. CPU and memory acquisition is completed off the main actor and published through one main-actor hop per fast cycle. Mutable observable state is main-actor isolated. Pure calculation value types have no global state and are safe to test in parallel.

Each Mach provider balances the send right returned by `mach_host_self()` with `mach_port_deallocate()` after its host call. The menu-bar view observes only the metric categories represented by its enabled slots, so an unshown storage or memory refresh cannot invalidate a CPU-only label. The memory provider treats its public swap sysctl as independent: an unavailable swap value becomes `nil` without hiding valid physical-memory values.

CPU and memory normally refresh once per second. Storage refreshes every 30 seconds after a valid sample, but a failed or invalid storage read temporarily retries on the fast cadence until it recovers. A wall-clock discontinuity longer than the configured threshold invalidates the CPU baseline, so a suspended interval is not presented as current load. The next valid delta resumes CPU presentation.

## Failure and stale-data behavior

- A thrown provider error clears that metric's current value immediately and marks sampling as limited.
- The first CPU read, a reset baseline, or a zero-tick delta can temporarily produce no current CPU snapshot without being treated as a provider failure.
- A missing swap value affects only Swap Used; the rest of the memory snapshot remains live.
- Thrown read failures and later recovery are logged once per state transition with `OSLog`. A provider that returns no sample marks the value unavailable without repetitive error logging. Metric values, paths, and machine identity are not logged.
- Recovery publishes a fresh value and clears the affected failure state without requiring an app restart.

## State and persistence

Version 1 retains no history, has no database, and persists no telemetry. Only user-facing menu-bar preferences are stored in `UserDefaults` as a validated configuration. The preferences model owns the serialization boundary, repairs decoded uniqueness/count invariants, replaces a malformed stored payload with defaults, migrates both earlier schemas into the current nine concrete stat slots, and publishes changes immediately to the status label, panel, and Settings.

## Dependency policy

The application has no third-party dependencies. SwiftUI, Foundation, Observation, OSLog, and public Darwin/Mach APIs cover the lifecycle, UI, preferences, diagnostics, and system metrics needed by this focused product.

Release builds enable dead-code stripping and the asset catalog's space optimization. Standard Swift whole-module optimization remains enabled because measurement showed it produced a smaller executable than `-Osize` for this project while preserving the normal Release performance profile.
