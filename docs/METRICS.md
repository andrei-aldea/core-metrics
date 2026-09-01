# Metric Definitions

This document is the source of truth for Core Metrics formulas. Raw API details and verified Apple references are added alongside each implemented provider.

## CPU

CPU values are derived from deltas between two cumulative host CPU tick samples. The first raw sample establishes a baseline and produces no percentage snapshot. Subsequent samples calculate user, system, idle, and nice deltas with wrapping subtraction where the underlying counter width requires it.

`totalDelta = userDelta + systemDelta + idleDelta + niceDelta`

`userPercent = (userDelta + niceDelta) / totalDelta`

`systemPercent = systemDelta / totalDelta`

`idlePercent = idleDelta / totalDelta`

`totalUsedPercent = userPercent + systemPercent = 1 - idlePercent`

Core Metrics folds `nice` into User so the displayed User, System, and Idle values remain a complete, understandable partition. A zero total delta produces no new snapshot. Percentages are clamped only at the presentation boundary after validating arithmetic.

## Memory

The exact Used and Available formulas will be recorded after the provider is implemented and verified against documented macOS VM counter semantics. Core Metrics will state its own definition and will not claim exact Activity Monitor parity unless that is supportable through public semantics.

## Storage

Version 1 reads capacity for the startup/root volume only and performs no directory or category scanning. The exact capacity keys and the meaning of Available will be recorded after implementation. The label will match the chosen API semantics rather than presenting reclaimable or important-usage capacity as literal free blocks.

## Sampling

- CPU: approximately 1 second.
- Memory: approximately 1 second.
- Storage: approximately 30 seconds.
- CPU and memory history: bounded, in memory, and not persisted.
