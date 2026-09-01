import Foundation

/// Small stateful adapter that supplies first-sample and reset behavior while
/// leaving the calculation itself pure.
nonisolated struct CPUSampleAccumulator: Sendable {
    private var previous: CPUTicks?

    /// Stores every sample as the next baseline. Pass `isContinuous: false`
    /// after a long scheduling gap (for example, sleep/wake); that sample then
    /// becomes a fresh baseline and produces no usage value.
    mutating func consume(_ current: CPUTicks, isContinuous: Bool = true) -> CPUUsage? {
        defer { previous = current }

        guard isContinuous, let previous else {
            return nil
        }

        return CPUUsageCalculator.calculate(previous: previous, current: current)
    }

    mutating func reset() {
        previous = nil
    }
}
