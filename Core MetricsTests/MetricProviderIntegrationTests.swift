import Foundation
import Testing
@testable import Core_Metrics

/// Exercises the public OS boundaries on the test host without depending on
/// a particular workload, tick interval, memory pressure, or swap allocation.
@Suite("Public system metric providers")
struct MetricProviderIntegrationTests {
    @Test("Host CPU statistics return usable aggregate counters")
    func readsHostCPUCounters() throws {
        let reader = HostCPUTicksReader()
        let first = try reader.readTicks()
        let second = try reader.readTicks()

        for ticks in [first, second] {
            let total = UInt64(ticks.user) + UInt64(ticks.system)
                + UInt64(ticks.idle) + UInt64(ticks.nice)
            #expect(total > 0)
        }

        // Back-to-back calls may land in the same tick. When time elapsed,
        // the live counters must form a finite, normalized CPU partition.
        if let usage = CPUUsageCalculator.calculate(previous: first, current: second) {
            #expect([usage.user, usage.system, usage.idle].allSatisfy {
                $0.isFinite && (0...1).contains($0)
            })
            #expect(abs(usage.user + usage.system + usage.idle - 1) < 1e-12)
        }
    }

    @Test("Host memory statistics support repeated reads and bounded snapshots")
    func readsHostMemoryCounters() throws {
        var provider = MemoryMetricsProvider()
        let first = try provider.readRawCounters()
        let second = try provider.readRawCounters()

        try #require(first.pageSizeBytes > 0)
        #expect(first.pageSizeBytes == second.pageSizeBytes)
        #expect(first.totalBytes == ProcessInfo.processInfo.physicalMemory)
        #expect(second.totalBytes == first.totalBytes)

        let usage = try #require(try provider.sample())
        #expect(usage.totalBytes == first.totalBytes)
        #expect([
            usage.usedBytes,
            usage.cachedBytes,
            usage.wiredBytes,
            usage.compressedBytes,
        ].allSatisfy { $0 <= usage.totalBytes })
        #expect(usage.usedFraction.isFinite)
        #expect((0...1).contains(usage.usedFraction))
        // Swap may legitimately be unavailable independently of physical RAM.
    }
}
