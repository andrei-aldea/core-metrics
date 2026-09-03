import Foundation

/// Pure storage relationship calculation. Values are clamped defensively
/// because a transient or unusual filesystem report must never underflow.
nonisolated enum StorageUsageCalculator {
    static func calculate(from snapshot: StorageCapacitySnapshot) -> StorageUsage? {
        guard snapshot.totalBytes > 0 else {
            return nil
        }

        let availableBytes = min(snapshot.availableBytes, snapshot.totalBytes)
        let usedBytes = snapshot.totalBytes - availableBytes

        return StorageUsage(
            usedBytes: usedBytes,
            availableBytes: availableBytes,
            totalBytes: snapshot.totalBytes
        )
    }
}
