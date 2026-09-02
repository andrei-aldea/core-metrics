import Foundation

/// Core Metrics' aggregate memory estimate and its documented category values.
nonisolated struct MemoryUsage: Equatable, Sendable {
    let usedBytes: UInt64
    let availableBytes: UInt64
    let totalBytes: UInt64
    let appEstimateBytes: UInt64
    let wiredBytes: UInt64
    let compressedBytes: UInt64
    let usedFraction: Double
}
