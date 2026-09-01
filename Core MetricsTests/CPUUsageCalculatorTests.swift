import Testing
@testable import Core_Metrics

@Suite("CPU usage calculation")
struct CPUUsageCalculatorTests {
    @Test("Calculates deltas and folds nice into user")
    func calculatesExpectedBreakdown() throws {
        let previous = CPUTicks(user: 100, system: 200, idle: 700, nice: 50)
        let current = CPUTicks(user: 110, system: 220, idle: 760, nice: 60)

        let usage = try #require(CPUUsageCalculator.calculate(previous: previous, current: current))

        #expect(isClose(usage.user, 0.2))
        #expect(isClose(usage.system, 0.2))
        #expect(isClose(usage.idle, 0.6))
        #expect(isClose(usage.total, 0.4))
        #expect(isClose(usage.total, usage.user + usage.system))
        #expect(isClose(usage.user + usage.system + usage.idle, 1))
    }

    @Test("Returns no value when no ticks elapsed")
    func zeroDeltaIsUnavailable() {
        let sample = CPUTicks(user: 1, system: 2, idle: 3, nice: 4)
        #expect(CPUUsageCalculator.calculate(previous: sample, current: sample) == nil)
    }

    @Test("Handles a UInt32 counter rollover")
    func handlesRollover() throws {
        let previous = CPUTicks(user: .max - 4, system: 10, idle: 20, nice: 30)
        let current = CPUTicks(user: 5, system: 20, idle: 30, nice: 40)

        let usage = try #require(CPUUsageCalculator.calculate(previous: previous, current: current))

        // User wraps by 10; system, idle, and nice each advance by 10.
        #expect(isClose(usage.user, 0.5))
        #expect(isClose(usage.system, 0.25))
        #expect(isClose(usage.idle, 0.25))
        #expect(isClose(usage.total, 0.75))
    }

    @Test("Counter scale does not change normalized usage", arguments: [UInt32(1), 2, 8, 64])
    func normalizesAggregatedCounters(scale: UInt32) throws {
        let previous = CPUTicks(user: 0, system: 0, idle: 0, nice: 0)
        let current = CPUTicks(
            user: 20 * scale,
            system: 10 * scale,
            idle: 70 * scale,
            nice: 0
        )

        let usage = try #require(CPUUsageCalculator.calculate(previous: previous, current: current))
        #expect(isClose(usage.total, 0.3))
        #expect(isClose(usage.idle, 0.7))
    }

    @Test("Accumulator warms up and resets across discontinuities")
    func accumulatorLifecycle() throws {
        var accumulator = CPUSampleAccumulator()
        let first = CPUTicks(user: 0, system: 0, idle: 0, nice: 0)
        let second = CPUTicks(user: 10, system: 10, idle: 80, nice: 0)
        let afterGap = CPUTicks(user: 20, system: 20, idle: 160, nice: 0)
        let resumed = CPUTicks(user: 30, system: 30, idle: 240, nice: 0)

        let firstUsage = accumulator.consume(first)
        let secondUsage = accumulator.consume(second)
        let gapUsage = accumulator.consume(afterGap, isContinuous: false)

        #expect(firstUsage == nil)
        #expect(secondUsage != nil)
        #expect(gapUsage == nil)

        let resumedUsage = accumulator.consume(resumed)
        let usage = try #require(resumedUsage)
        #expect(isClose(usage.total, 0.2))

        accumulator.reset()
        let resetUsage = accumulator.consume(resumed)
        #expect(resetUsage == nil)
    }

    private func isClose(_ lhs: Double, _ rhs: Double, tolerance: Double = 1e-12) -> Bool {
        abs(lhs - rhs) <= tolerance
    }
}
