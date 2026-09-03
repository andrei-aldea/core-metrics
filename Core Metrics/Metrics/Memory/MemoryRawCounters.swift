import Foundation

/// VM counters needed by Core Metrics' user-facing memory definition.
nonisolated struct MemoryRawCounters: Equatable, Sendable {
    let totalBytes: UInt64
    let pageSizeBytes: UInt64
    let freePageCount: UInt64
    let externalPageCount: UInt64
    let wiredPageCount: UInt64
    let compressorPageCount: UInt64
    let swapUsedBytes: UInt64?
}
