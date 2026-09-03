import Foundation

/// Converts VM page counters into Core Metrics' documented memory model.
///
/// Definition:
///
///     cached = clamp(externalPages * pageSize, 0...total)
///     free   = clamp(freePages * pageSize, 0...total)
///     used   = total - clamp(cached + free, 0...total)
///
/// Apple's Activity Monitor guide defines Cached Files as unused file-backed
/// memory and Memory Used as RAM currently in use. The public counters can
/// follow those definitions, although sampling times can differ between apps.
nonisolated enum MemoryUsageCalculator {
    static func calculate(from raw: MemoryRawCounters) -> MemoryUsage? {
        guard raw.totalBytes > 0, raw.pageSizeBytes > 0 else {
            return nil
        }

        let cachedBytes = min(
            raw.totalBytes,
            saturatingMultiply(raw.externalPageCount, raw.pageSizeBytes)
        )
        let freeBytes = min(
            raw.totalBytes,
            saturatingMultiply(raw.freePageCount, raw.pageSizeBytes)
        )
        let reclaimableBytes = min(
            raw.totalBytes,
            saturatingAdd(cachedBytes, freeBytes)
        )
        let usedBytes = raw.totalBytes - reclaimableBytes

        return MemoryUsage(
            usedBytes: usedBytes,
            cachedBytes: cachedBytes,
            swapUsedBytes: raw.swapUsedBytes
        )
    }

    private static func saturatingAdd(_ lhs: UInt64, _ rhs: UInt64) -> UInt64 {
        let (value, overflow) = lhs.addingReportingOverflow(rhs)
        return overflow ? .max : value
    }

    private static func saturatingMultiply(_ lhs: UInt64, _ rhs: UInt64) -> UInt64 {
        let (value, overflow) = lhs.multipliedReportingOverflow(by: rhs)
        return overflow ? .max : value
    }
}
