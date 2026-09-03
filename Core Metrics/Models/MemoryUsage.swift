import Foundation

/// Activity Monitor-aligned aggregate memory values from public system counters.
nonisolated struct MemoryUsage: Equatable, Sendable {
    let usedBytes: UInt64
    let cachedBytes: UInt64
    let swapUsedBytes: UInt64?
    let wiredBytes: UInt64
    let compressedBytes: UInt64
    let totalBytes: UInt64

    var usedFraction: Double {
        guard totalBytes > 0 else {
            return 0
        }

        return Double(usedBytes) / Double(totalBytes)
    }
}
