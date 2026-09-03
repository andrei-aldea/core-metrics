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

The provider calls Apple's documented [`host_statistics64`](https://developer.apple.com/documentation/kernel/1502863-host_statistics64) with `HOST_VM_INFO64`, reads [`vm_statistics64_data_t`](https://developer.apple.com/documentation/kernel/vm_statistics64_data_t), obtains the byte multiplier from [`host_page_size`](https://developer.apple.com/documentation/kernel/1502512-host_page_size), and obtains total physical memory from [`ProcessInfo.physicalMemory`](https://developer.apple.com/documentation/foundation/processinfo/physicalmemory). Swap Used comes from the public `CTL_VM` / `VM_SWAPUSAGE` sysctl and `xsw_usage.xsu_used` declared in Apple's public [XNU `sysctl.h`](https://github.com/apple-oss-distributions/xnu/blob/main/bsd/sys/sysctl.h).

For nonnegative page counters and `pageSize` in bytes:

`cachedBytes = clamp(externalPageCount * pageSize, 0 ... totalBytes)`

`freeBytes = clamp(freePageCount * pageSize, 0 ... totalBytes)`

`usedBytes = totalBytes - clamp(cachedBytes + freeBytes, 0 ... totalBytes)`

`swapUsedBytes = xsw_usage.xsu_used`

Apple's [Activity Monitor guide](https://support.apple.com/guide/activity-monitor/view-memory-usage-actmntr1004/mac) defines Memory Used as RAM in use, Cached Files as files cached into otherwise unused memory, and Swap Used as startup-disk space used by memory management. Apple's public XNU [`vm_statistics.h`](https://github.com/apple-oss-distributions/xnu/blob/main/osfmk/mach/vm_statistics.h) defines `external_page_count` as file-backed non-swap pages and `free_count` as free pages, so the formula follows the same visible categories.

Activity Monitor and Core Metrics sample independently, so displayed values can differ briefly even when their category definitions align. Core Metrics does not inspect Activity Monitor or use its private implementation. If the independent swap read fails, Memory Used and Cached Files remain available while Swap Used displays an unavailable placeholder.

Calculations use overflow-safe conversion and clamp inconsistent snapshots. A zero physical-memory total produces no snapshot.

## Storage

Version 1 queries `URL(fileURLWithPath: "/")` for Foundation's [`volumeTotalCapacityKey`](https://developer.apple.com/documentation/foundation/urlresourcekey/volumetotalcapacitykey) and [`volumeAvailableCapacityKey`](https://developer.apple.com/documentation/foundation/urlresourcekey/volumeavailablecapacitykey):

`usedBytes = clamp(totalCapacityBytes - availableCapacityBytes, 0 ... totalCapacityBytes)`

The UI says **Free Space** as the familiar user-facing name for Foundation's available-capacity value. Core Metrics doesn't perform directory or storage-category scans.

The menu bar can show free space, used space, or total startup-volume capacity.

[`volumeAvailableCapacityForImportantUsageKey`](https://developer.apple.com/documentation/foundation/urlresourcekey/volumeavailablecapacityforimportantusagekey) and [`volumeAvailableCapacityForOpportunisticUsageKey`](https://developer.apple.com/documentation/foundation/urlresourcekey/volumeavailablecapacityforopportunisticusagekey) aren't used. Apple's [volume-capacity guidance](https://developer.apple.com/documentation/foundation/checking-volume-storage-capacity) defines them as estimates for user-requested/app-required writes and predictive/nonessential writes, respectively, not as neutral disk-utilization values. Core Metrics neither derives nor displays purgeable space.

## Sampling

- CPU: approximately 1 second.
- Memory: approximately 1 second.
- Storage: approximately 30 seconds after valid reads; temporarily retries on the one-second cadence after a failure or invalid snapshot.
- History: not collected or retained.

## Menu-bar representations

- CPU: User, System, or Idle percentage from the current aggregate delta sample.
- Memory: Memory Used, Cached Files, or Swap Used from the current memory snapshot.
- Storage: Free Space, Used Space, or Total Capacity from the current startup-volume snapshot.

One to seven of these concrete stats can be selected, including multiple stats from the same metric. Selected values always follow the panel's CPU → Memory → Storage order, regardless of click or persisted order. The status item is emitted as one text value, and each formatted number reserves a fixed seven-character column so live updates do not resize its slot. Memory and storage values always use one decimal place, such as `13.9G` or `143.0G`. Only the selection and display mode are persisted. Metric values are current in-memory snapshots and reset when the app exits.
