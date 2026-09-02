import Testing
@testable import Core_Metrics

@Suite("Memory usage calculation")
struct MemoryUsageCalculatorTests {
    @Test("Calculates app estimate plus wired and compressed pages")
    func calculatesDocumentedFormula() throws {
        let raw = MemoryRawCounters(
            totalBytes: 1_000,
            pageSizeBytes: 10,
            internalPageCount: 50,
            purgeablePageCount: 10,
            wiredPageCount: 20,
            compressorPageCount: 10
        )

        let usage = try #require(MemoryUsageCalculator.calculate(from: raw))

        #expect(usage.availableBytes == 300)
        #expect(usage.usedBytes == 700)
        #expect(usage.totalBytes == 1_000)
        #expect(usage.appEstimateBytes == 400)
        #expect(usage.wiredBytes == 200)
        #expect(usage.compressedBytes == 100)
        #expect(isClose(usage.usedFraction, 0.7))
    }

    @Test("Clamps inconsistent page totals to physical memory")
    func clampsUsedBytes() throws {
        let raw = MemoryRawCounters(
            totalBytes: 1_000,
            pageSizeBytes: 100,
            internalPageCount: 10,
            purgeablePageCount: 0,
            wiredPageCount: 10,
            compressorPageCount: 0
        )

        let usage = try #require(MemoryUsageCalculator.calculate(from: raw))
        #expect(usage.availableBytes == 0)
        #expect(usage.usedBytes == 1_000)
        #expect(usage.appEstimateBytes == 1_000)
        #expect(usage.wiredBytes == 1_000)
        #expect(usage.compressedBytes == 0)
        #expect(usage.usedFraction == 1)
    }

    @Test("Saturating arithmetic remains bounded")
    func handlesArithmeticOverflow() throws {
        let raw = MemoryRawCounters(
            totalBytes: 4_096,
            pageSizeBytes: .max,
            internalPageCount: .max,
            purgeablePageCount: 0,
            wiredPageCount: .max,
            compressorPageCount: .max
        )

        let usage = try #require(MemoryUsageCalculator.calculate(from: raw))
        #expect(usage.availableBytes == 0)
        #expect(usage.usedBytes == 4_096)
        #expect(usage.appEstimateBytes == .max)
        #expect(usage.wiredBytes == .max)
        #expect(usage.compressedBytes == .max)
    }

    @Test("Purgeable pages cannot make the app estimate negative")
    func clampsPurgeableSubtraction() throws {
        let raw = MemoryRawCounters(
            totalBytes: 1_000,
            pageSizeBytes: 10,
            internalPageCount: 10,
            purgeablePageCount: 20,
            wiredPageCount: 5,
            compressorPageCount: 5
        )

        let usage = try #require(MemoryUsageCalculator.calculate(from: raw))
        #expect(usage.usedBytes == 100)
        #expect(usage.availableBytes == 900)
        #expect(usage.appEstimateBytes == 0)
        #expect(usage.wiredBytes == 50)
        #expect(usage.compressedBytes == 50)
    }

    @Test("Rejects an unusable total or page size", arguments: [
        MemoryRawCounters(
            totalBytes: 0,
            pageSizeBytes: 4_096,
            internalPageCount: 0,
            purgeablePageCount: 0,
            wiredPageCount: 0,
            compressorPageCount: 0
        ),
        MemoryRawCounters(
            totalBytes: 1,
            pageSizeBytes: 0,
            internalPageCount: 0,
            purgeablePageCount: 0,
            wiredPageCount: 0,
            compressorPageCount: 0
        ),
    ])
    func rejectsInvalidInput(_ raw: MemoryRawCounters) {
        #expect(MemoryUsageCalculator.calculate(from: raw) == nil)
    }

    private func isClose(_ lhs: Double, _ rhs: Double, tolerance: Double = 1e-12) -> Bool {
        abs(lhs - rhs) <= tolerance
    }
}
