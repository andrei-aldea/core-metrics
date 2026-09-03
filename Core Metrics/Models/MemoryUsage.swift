import Foundation

/// Activity Monitor-aligned aggregate memory values from public system counters.
nonisolated struct MemoryUsage: Equatable, Sendable {
    let usedBytes: UInt64
    let cachedBytes: UInt64
    let swapUsedBytes: UInt64?
}
