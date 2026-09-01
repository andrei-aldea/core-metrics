# Architecture

Core Metrics uses a small layered architecture designed to keep system acquisition thin, calculations independently testable, and the menu-bar presentation free of low-level system code.

## Data flow

1. System providers acquire aggregate raw counters from documented Apple APIs.
2. Pure calculation types convert raw values into validated snapshots.
3. `MetricsStore` coordinates independent refresh cadences, handles CPU delta discontinuities, and owns bounded history.
4. A main-actor observable metrics store publishes current snapshots and bounded in-memory history.
5. SwiftUI menu-bar and dashboard views render the metrics store, while Settings and the status label observe a dedicated preferences store.

The UI never calls Mach or volume-capacity APIs directly. Provider errors clear the affected current snapshot so an old reading is never represented as live. The UI renders an unavailable value and the dashboard header changes to a limited status until sampling recovers.

## Application surfaces

- `MenuBarExtra` is the primary scene and uses the native window style for a popover-like dashboard.
- The label shows an ordered, validated selection of one to three metrics with locale-aware, width-stable formatting.
- The dashboard presents CPU and memory history, metric detail rows, startup-volume progress, sampling status, Settings, and Quit.
- A native `Settings` scene edits menu-bar metric visibility/order and the small supported set of representations.
- `LSUIElement` keeps the app out of the Dock and application switcher. The extra does not persist an inserted/hidden state, avoiding an unrecoverable hidden configuration on relaunch.

## Concurrency

Sampling uses structured concurrency with one owned task and cancellable child loops. The loops suspend with `Task.sleep(for:)`; they never busy-wait. Mutable observable state is main-actor isolated. Pure calculation and bounded-history value types have no global state and are safe to test in parallel.

CPU and memory normally refresh once per second. Storage refreshes every 30 seconds. A wall-clock discontinuity longer than the configured threshold invalidates the CPU baseline, so a suspended interval is not presented as current load. The next valid delta resumes CPU presentation.

## Failure and stale-data behavior

- A thrown provider error clears that metric's current value immediately and marks sampling as limited.
- The first CPU read, a reset baseline, or a zero-tick delta can temporarily produce no current CPU snapshot without being treated as a provider failure.
- Only valid CPU and memory snapshots enter the 120-sample history buffers. Existing history stays in memory through a temporary failure but is never substituted for the current value.
- Thrown read failures and later recovery are logged once per state transition with `OSLog`. A provider that returns no sample marks the value unavailable without repetitive error logging. Metric values, paths, and machine identity are not logged.
- Recovery publishes a fresh value and clears the affected failure state without requiring an app restart.

## State and persistence

Metric history is a bounded in-memory buffer; version 1 has no database and persists no telemetry. Only user-facing menu-bar preferences are stored in `UserDefaults` as a validated configuration. The preferences model owns the serialization boundary, repairs decoded ordering invariants, and publishes changes immediately to the status label and Settings.

## Dependency policy

The application has no third-party dependencies. SwiftUI, Foundation, Observation, Swift Charts, OSLog, and public Darwin/Mach APIs cover the lifecycle, UI, preferences, diagnostics, and system metrics needed by this focused product.
