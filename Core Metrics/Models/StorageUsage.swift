import Foundation

/// Startup-volume capacity based on Foundation's standard available-capacity
/// value.
nonisolated struct StorageUsage: Equatable, Sendable {
    let usedBytes: UInt64
    let availableBytes: UInt64
    let totalBytes: UInt64
    let usedFraction: Double
}
