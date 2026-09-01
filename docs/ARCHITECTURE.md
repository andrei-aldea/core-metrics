# Architecture

Core Metrics uses a small layered architecture designed to keep system acquisition thin and calculations independently testable.

## Data flow

1. System providers acquire aggregate raw counters from documented Apple APIs.
2. Pure calculation types convert raw values into validated snapshots.
3. A sampling coordinator applies independent refresh cadences and handles lifecycle resets.
4. A main-actor observable metrics store publishes current snapshots and bounded in-memory history.
5. SwiftUI views render the store and read a dedicated preferences model.

The UI never calls Mach or volume-capacity APIs directly. Provider errors preserve the last valid sample where appropriate and expose an unavailable state without crashing or logging repeatedly.

## Concurrency

Sampling uses structured concurrency with cancellable tasks and `ContinuousClock` intervals. Mutable UI state is main-actor isolated. Pure calculation and bounded-history value types have no global state and are safe to test in parallel.

CPU and memory normally refresh once per second. Storage refreshes every 30 seconds. A wake/resume event resets CPU baselines before the next delta so a long suspended interval cannot produce a misleading result.

## State and persistence

Metric history is a bounded in-memory buffer; version 1 has no database and persists no telemetry. Only user-facing preferences are stored in `UserDefaults`. The preferences model owns the serialization boundary and publishes changes immediately to the menu-bar label and Settings.

## Dependency policy

The application has no third-party dependencies. Apple frameworks cover the lifecycle, UI, charts, preferences, and system metric APIs needed by this focused product.
