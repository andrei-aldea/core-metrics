# Metric Definitions

This document is the source of truth for Core Metrics formulas. Acquisition stays behind thin providers; calculations use independently testable integer or floating-point inputs.

## CPU

The provider calls Apple's documented [`host_statistics`](https://developer.apple.com/documentation/kernel/1502546-host_statistics) with `HOST_CPU_LOAD_INFO` and reads cumulative ticks from [`host_cpu_load_info_t`](https://developer.apple.com/documentation/kernel/host_cpu_load_info_t). Apple defines the four states and their order in the public XNU [`machine.h`](https://github.com/apple-oss-distributions/xnu/blob/main/osfmk/mach/machine.h) and describes the values as ticks spent in each mode in [`host_info.h`](https://github.com/apple-oss-distributions/xnu/blob/main/osfmk/mach/host_info.h).

The first sample establishes a baseline and produces no percentage snapshot. Later samples use wrapping subtraction at the underlying unsigned counter width:

`totalDelta = userDelta + systemDelta + idleDelta + niceDelta`

`userPercent = (userDelta + niceDelta) / totalDelta`

`systemPercent = systemDelta / totalDelta`

`idlePercent = idleDelta / totalDelta`

`totalUsedPercent = userPercent + systemPercent = 1 - idlePercent`

Core Metrics folds `nice` into User so the displayed User, System, and Idle values remain a complete, understandable partition. A zero total delta produces no new snapshot. Percentages are clamped only at the presentation boundary after validating arithmetic.

The provider resets its baseline after sleep, wake, or a suspicious discontinuity rather than presenting a long or invalid interval as current load. Aggregate host statistics are sufficient; [`host_processor_info`](https://developer.apple.com/documentation/kernel/1502854-host_processor_info) is reserved for a future per-core feature.

## Memory

The provider calls Apple's documented [`host_statistics64`](https://developer.apple.com/documentation/kernel/1502863-host_statistics64) with `HOST_VM_INFO64`, reads [`vm_statistics64_data_t`](https://developer.apple.com/documentation/kernel/vm_statistics64_data_t), obtains the byte multiplier from [`host_page_size`](https://developer.apple.com/documentation/kernel/1502512-host_page_size), and obtains total physical memory from [`ProcessInfo.physicalMemory`](https://developer.apple.com/documentation/foundation/processinfo/physicalmemory).

For nonnegative page counters and `pageSize` in bytes:

`appEstimateBytes = max(internalPageCount - purgeablePageCount, 0) * pageSize`

`wiredBytes = wirePageCount * pageSize`

`compressedBytes = compressorPageCount * pageSize`

`usedBytes = clamp(appEstimateBytes + wiredBytes + compressedBytes, 0 ... totalBytes)`

`availableBytes = totalBytes - usedBytes`

`usedPercent = usedBytes / totalBytes`

This is the **Core Metrics memory estimate**. It follows the App Memory + Wired + Compressed category model described in Apple's [Activity Monitor guide](https://support.apple.com/guide/activity-monitor/view-memory-usage-actmntr1004/mac), while using documented Mach counters. Apple doesn't publish Activity Monitor's exact counter formula, so Core Metrics does not claim numeric parity with Activity Monitor.

Apple's public XNU [`vm_statistics.h`](https://github.com/apple-oss-distributions/xnu/blob/main/osfmk/mach/vm_statistics.h) defines `internal_page_count` as anonymous pages, `purgeable_count` as purgeable pages, `wire_count` as wired pages, and `compressor_page_count` as physical pages occupied by compressed data. `total_uncompressed_pages_in_compressor` is not physical usage and is excluded. `speculative_count` is already included in `free_count`; code must never add the two. Active, inactive, free, and speculative values are retained for diagnostics but aren't independently added to this formula.

Calculations use overflow-safe conversion and clamp inconsistent snapshots. A zero total produces no percentage.

## Storage

Version 1 queries `URL(fileURLWithPath: "/")` for Foundation's [`volumeTotalCapacityKey`](https://developer.apple.com/documentation/foundation/urlresourcekey/volumetotalcapacitykey) and [`volumeAvailableCapacityKey`](https://developer.apple.com/documentation/foundation/urlresourcekey/volumeavailablecapacitykey):

`usedBytes = clamp(totalCapacityBytes - availableCapacityBytes, 0 ... totalCapacityBytes)`

`usedPercent = usedBytes / totalCapacityBytes`

The UI says **Available**, not Free. Core Metrics doesn't perform directory or storage-category scans.

[`volumeAvailableCapacityForImportantUsageKey`](https://developer.apple.com/documentation/foundation/urlresourcekey/volumeavailablecapacityforimportantusagekey) and [`volumeAvailableCapacityForOpportunisticUsageKey`](https://developer.apple.com/documentation/foundation/urlresourcekey/volumeavailablecapacityforopportunisticusagekey) aren't used for the dashboard. Apple's [volume-capacity guidance](https://developer.apple.com/documentation/foundation/checking-volume-storage-capacity) defines them as estimates for user-requested/app-required writes and predictive/nonessential writes, respectively, not as neutral disk-utilization values. Core Metrics neither derives nor displays purgeable space.

## Sampling

- CPU: approximately 1 second.
- Memory: approximately 1 second.
- Storage: approximately 30 seconds.
- CPU and memory history: bounded, in memory, and not persisted.
