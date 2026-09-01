import Foundation

/// Converts VM page counters into Core Metrics' documented memory model.
///
/// Definition:
///
///     appPages = max(internal - purgeable, 0)
///     used     = clamp((appPages + wired + compressor) * pageSize, 0...total)
///     available = total - used
///
/// This approximates the understandable categories of app, wired, and
/// compressed memory using documented VM counters. It is a transparent Core
/// Metrics estimate, not a claim of byte-for-byte parity with Activity Monitor.
nonisolated enum MemoryUsageCalculator {
    static func calculate(from raw: MemoryRawCounters) -> MemoryUsage? {
        guard raw.totalBytes > 0, raw.pageSizeBytes > 0 else {
            return nil
        }

        let appPageCount = raw.internalPageCount >= raw.purgeablePageCount
            ? raw.internalPageCount - raw.purgeablePageCount
            : 0
        let usedPageCount = saturatingAdd(
            saturatingAdd(appPageCount, raw.wiredPageCount),
            raw.compressorPageCount
        )
        let usedBytes = min(
            raw.totalBytes,
            saturatingMultiply(usedPageCount, raw.pageSizeBytes)
        )
        let availableBytes = raw.totalBytes - usedBytes

        return MemoryUsage(
            usedBytes: usedBytes,
            availableBytes: availableBytes,
            totalBytes: raw.totalBytes,
            usedFraction: Double(usedBytes) / Double(raw.totalBytes)
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
