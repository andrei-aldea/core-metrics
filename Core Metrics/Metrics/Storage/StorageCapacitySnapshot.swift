import Foundation

/// Raw startup-volume values copied from Foundation URL resource values.
/// `availableBytes` comes from `volumeAvailableCapacity`, not the broader
/// important-usage estimate.
nonisolated struct StorageCapacitySnapshot: Equatable, Sendable {
    let totalBytes: UInt64
    let availableBytes: UInt64
}
