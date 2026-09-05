import Foundation

private nonisolated enum RootVolumeStorageError: Error, Sendable {
    case capacityUnavailable
}

/// Reads the startup/root volume's standard total and available capacity.
/// It intentionally does not use the important- or opportunistic-usage keys.
nonisolated struct RootVolumeStorageProvider: StorageMetricsProviding {
    private let rootURL: URL

    init(rootURL: URL = URL(fileURLWithPath: "/", isDirectory: true)) {
        self.rootURL = rootURL
    }

    func sample() throws -> StorageUsage? {
        // Resource values are cached on URL instances. Off-main sampling has
        // no main-run-loop invalidation, so every poll must discard that cache.
        var sampleURL = rootURL
        sampleURL.removeAllCachedResourceValues()
        let values = try sampleURL.resourceValues(forKeys: [
            .volumeTotalCapacityKey,
            .volumeAvailableCapacityKey,
        ])

        guard
            let totalCapacity = values.volumeTotalCapacity,
            let availableCapacity = values.volumeAvailableCapacity,
            totalCapacity >= 0,
            availableCapacity >= 0
        else {
            throw RootVolumeStorageError.capacityUnavailable
        }

        let snapshot = StorageCapacitySnapshot(
            totalBytes: UInt64(totalCapacity),
            availableBytes: UInt64(availableCapacity)
        )
        return StorageUsageCalculator.calculate(from: snapshot)
    }
}
