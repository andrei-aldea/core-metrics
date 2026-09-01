import Foundation

/// Pure delta-based CPU usage calculation, independent of the Mach API.
nonisolated enum CPUUsageCalculator {
    /// Calculates normalized CPU usage between two cumulative counter samples.
    ///
    /// Returns `nil` when no ticks elapsed. Mach's `nice` ticks are folded into
    /// `user`, which keeps the four values shown by Core Metrics consistent.
    static func calculate(previous: CPUTicks, current: CPUTicks) -> CPUUsage? {
        let userDelta = delta(from: previous.user, to: current.user)
        let systemDelta = delta(from: previous.system, to: current.system)
        let idleDelta = delta(from: previous.idle, to: current.idle)
        let niceDelta = delta(from: previous.nice, to: current.nice)

        // Four UInt32 deltas cannot overflow UInt64 when summed.
        let effectiveUserDelta = userDelta + niceDelta
        let usedDelta = effectiveUserDelta + systemDelta
        let totalDelta = usedDelta + idleDelta

        guard totalDelta > 0 else {
            return nil
        }

        let denominator = Double(totalDelta)
        return CPUUsage(
            total: Double(usedDelta) / denominator,
            user: Double(effectiveUserDelta) / denominator,
            system: Double(systemDelta) / denominator,
            idle: Double(idleDelta) / denominator
        )
    }

    /// A single modulo-2^32 delta. At the one-second sampling cadence, a
    /// counter can wrap at most once between samples.
    private static func delta(from previous: UInt32, to current: UInt32) -> UInt64 {
        UInt64(current &- previous)
    }
}
