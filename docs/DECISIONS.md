# Architecture Decisions

## ADR-001 — Native dependency-free application

**Decision:** Build Core Metrics with Swift, SwiftUI, Foundation, Swift Charts, SF Symbols, and documented Apple system APIs, with no third-party dependencies.

**Reasoning:** The product is small, privacy-sensitive, Mac App Store-bound, and fully covered by platform frameworks. A minimal dependency surface improves auditability, launch cost, and long-term maintenance.

**Alternatives considered:** Cross-platform UI frameworks and third-party chart/system-monitor packages.

**Consequences:** Platform behavior remains native and the code owns a few thin system API adapters. Any future dependency requires an explicit new decision.

## ADR-002 — Layered providers with pure calculations

**Decision:** Separate raw system acquisition, pure snapshot calculations, sampling coordination, observable application state, and presentation.

**Reasoning:** Mach counters are cumulative and error-prone; keeping their math pure allows deterministic fixtures and fast parallel tests. UI code remains readable and sandbox/API audits stay localized.

**Alternatives considered:** Reading metrics directly from SwiftUI views or a single global monitoring singleton.

**Consequences:** There are several small focused types, but no broad framework or excessive protocol hierarchy.

## ADR-003 — In-memory history only

**Decision:** Retain a bounded recent CPU and memory history in memory and never persist samples in version 1.

**Reasoning:** The dashboard needs short visual context, not telemetry. Persistence would add privacy, storage, migration, and lifecycle complexity without advancing the product goal.

**Alternatives considered:** UserDefaults arrays, files, SwiftData, and a database.

**Consequences:** History resets at launch and consumes a small fixed amount of memory.
