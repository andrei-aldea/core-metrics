import Foundation

/// Startup-volume capacity based on Foundation's standard available-capacity
/// value.
nonisolated struct StorageUsage: Equatable, Sendable {
    let usedBytes: UInt64
    let availableBytes: UInt64
    let totalBytes: UInt64

    var usedFraction: Double {
        guard totalBytes > 0 else {
            return 0
        }

        return Double(usedBytes) / Double(totalBytes)
    }
}
