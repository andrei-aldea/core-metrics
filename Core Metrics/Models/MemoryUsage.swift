import Foundation

/// Core Metrics' intentionally simple memory model.
nonisolated struct MemoryUsage: Equatable, Sendable {
    let usedBytes: UInt64
    let availableBytes: UInt64
    let totalBytes: UInt64
    let usedFraction: Double
}
