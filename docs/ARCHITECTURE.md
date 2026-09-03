# Architecture

Core Metrics uses a small layered architecture designed to keep system acquisition thin, calculations independently testable, and the menu-bar presentation free of low-level system code.

## Data flow

1. System providers acquire aggregate raw counters from documented Apple APIs.
2. Pure calculation types convert raw values into validated snapshots.
3. `MetricsStore` coordinates independent refresh cadences and handles CPU delta discontinuities.
4. A main-actor observable metrics store publishes only the current validated snapshots.
5. The SwiftUI status label renders the metrics store, while the panel and Settings observe a dedicated preferences store.

The UI never calls Mach or volume-capacity APIs directly. Provider errors clear the affected current snapshot so an old reading is never represented as live. The status label renders an unavailable placeholder until automatic retry produces a fresh value. Normal first-sample CPU latency uses the same neutral placeholder without being logged as a failure.

## Application surfaces

- `MenuBarExtra` is the primary scene and uses the native window style so its controls remain open during multi-selection and macOS supplies the surrounding Liquid Glass presentation.
- The label shows a validated selection of one to seven concrete stats as one text value. Selection is normalized to the same CPU → Memory → Storage order shown in the panel, independent of click order. Each numeric value reserves an eight-character column in an explicitly measured monospaced frame, so sampling updates cannot resize the status item.
- The status panel begins with the CPU section, shows stat names and selection state—but no duplicate live values—and provides direct checkbox controls, a segmented display-mode picker, About, Settings, and Quit.
- A native `Settings` scene adds and removes menu-bar stats chosen from the supported CPU, memory, and storage representations. Its horizontally scrollable live preview reuses the production menu-bar label without forcing the Settings window wider.
- `LSUIElement` keeps the app out of the Dock and application switcher. The extra does not persist an inserted/hidden state, avoiding an unrecoverable hidden configuration on relaunch.

## Concurrency

Sampling uses structured concurrency with one owned utility-priority task and cancellable, result-discarding child loops. The loops suspend with `Task.sleep(for:)`; they never busy-wait or retain an ever-growing list of child results. CPU and memory acquisition is completed off the main actor and published through one main-actor hop per fast cycle. Mutable observable state is main-actor isolated. Pure calculation value types have no global state and are safe to test in parallel.

Each Mach provider balances the send right returned by `mach_host_self()` with `mach_port_deallocate()` after its host call. The menu-bar view observes only the metric categories represented by its enabled slots, so an unshown storage or memory refresh cannot invalidate a CPU-only label. The memory provider treats its public swap sysctl as independent: an unavailable swap value becomes `nil` without hiding valid physical-memory values.

CPU and memory normally refresh every two seconds. Storage refreshes every 30 seconds after a valid sample, but a failed or invalid storage read temporarily retries on the two-second cadence until it recovers. A wall-clock discontinuity longer than the configured threshold invalidates the CPU baseline, so a suspended interval is not presented as current load. The next valid delta resumes CPU presentation.

## Failure and stale-data behavior

- A thrown provider error clears that metric's current value immediately and records an internal unavailable transition.
- The first CPU read, a reset baseline, or a zero-tick delta can temporarily produce no current CPU snapshot without being treated as a provider failure.
- A missing swap value affects only Swap Used; the rest of the memory snapshot remains live.
- Thrown read failures and later recovery are logged once per state transition with `OSLog`. A provider that returns no sample marks the value unavailable without repetitive error logging. Metric values, paths, and machine identity are not logged.
- Recovery publishes a fresh value and clears the internal failure state without requiring an app restart.

## State and persistence

Version 1 retains no history, has no database, and persists no telemetry. Only user-facing menu-bar preferences are stored in `UserDefaults` as a validated configuration. The preferences model owns the serialization boundary, repairs decoded uniqueness/count invariants, replaces a malformed stored payload with defaults, migrates both earlier schemas into the current fifteen concrete stat choices, and publishes changes immediately to the status label, panel, and Settings.

## Dependency policy

The application has no third-party dependencies. SwiftUI, Foundation, Observation, OSLog, and public Darwin/Mach APIs cover the lifecycle, UI, preferences, diagnostics, and system metrics needed by this focused product.

Release builds enable dead-code stripping and the asset catalog's space optimization. Standard Swift whole-module optimization remains enabled because measurement showed it produced a smaller executable than `-Osize` for this project while preserving the normal Release performance profile.
