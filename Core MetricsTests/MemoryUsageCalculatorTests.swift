import Testing
@testable import Core_Metrics

@Suite("Memory usage calculation")
struct MemoryUsageCalculatorTests {
    @Test("Calculates memory used and cached files from public VM counters")
    func calculatesDocumentedFormula() throws {
        let raw = MemoryRawCounters(
            totalBytes: 1_000,
            pageSizeBytes: 10,
            freePageCount: 10,
            externalPageCount: 20,
            wiredPageCount: 30,
            compressorPageCount: 15,
            swapUsedBytes: 50
        )

        let usage = try #require(MemoryUsageCalculator.calculate(from: raw))

        #expect(usage.usedBytes == 700)
        #expect(usage.cachedBytes == 200)
        #expect(usage.wiredBytes == 300)
        #expect(usage.compressedBytes == 150)
        #expect(usage.totalBytes == 1_000)
        #expect(usage.usedFraction == 0.7)
        #expect(usage.swapUsedBytes == 50)
    }

    @Test("Clamps free and cached page totals to physical memory")
    func clampsReclaimableBytes() throws {
        let raw = MemoryRawCounters(
            totalBytes: 1_000,
            pageSizeBytes: 100,
            freePageCount: 10,
            externalPageCount: 10,
            wiredPageCount: 20,
            compressorPageCount: 20,
            swapUsedBytes: 0
        )

        let usage = try #require(MemoryUsageCalculator.calculate(from: raw))
        #expect(usage.usedBytes == 0)
        #expect(usage.cachedBytes == 1_000)
        #expect(usage.wiredBytes == 1_000)
        #expect(usage.compressedBytes == 1_000)
        #expect(usage.swapUsedBytes == 0)
    }

    @Test("Saturating arithmetic remains bounded")
    func handlesArithmeticOverflow() throws {
        let raw = MemoryRawCounters(
            totalBytes: 4_096,
            pageSizeBytes: .max,
            freePageCount: .max,
            externalPageCount: .max,
            wiredPageCount: .max,
            compressorPageCount: .max,
            swapUsedBytes: .max
        )

        let usage = try #require(MemoryUsageCalculator.calculate(from: raw))
        #expect(usage.usedBytes == 0)
        #expect(usage.cachedBytes == 4_096)
        #expect(usage.wiredBytes == 4_096)
        #expect(usage.compressedBytes == 4_096)
        #expect(usage.swapUsedBytes == .max)
    }

    @Test("A missing swap value does not discard physical-memory values")
    func preservesValuesWhenSwapIsUnavailable() throws {
        let raw = MemoryRawCounters(
            totalBytes: 1_000,
            pageSizeBytes: 10,
            freePageCount: 10,
            externalPageCount: 20,
            wiredPageCount: 30,
            compressorPageCount: 15,
            swapUsedBytes: nil
        )

        let usage = try #require(MemoryUsageCalculator.calculate(from: raw))
        #expect(usage.usedBytes == 700)
        #expect(usage.cachedBytes == 200)
        #expect(usage.wiredBytes == 300)
        #expect(usage.compressedBytes == 150)
        #expect(usage.totalBytes == 1_000)
        #expect(usage.swapUsedBytes == nil)
    }

    @Test("Rejects an unusable total or page size", arguments: [
        MemoryRawCounters(
            totalBytes: 0,
            pageSizeBytes: 4_096,
            freePageCount: 0,
            externalPageCount: 0,
            wiredPageCount: 0,
            compressorPageCount: 0,
            swapUsedBytes: 0
        ),
        MemoryRawCounters(
            totalBytes: 1,
            pageSizeBytes: 0,
            freePageCount: 0,
            externalPageCount: 0,
            wiredPageCount: 0,
            compressorPageCount: 0,
            swapUsedBytes: 0
        ),
    ])
    func rejectsInvalidInput(_ raw: MemoryRawCounters) {
        #expect(MemoryUsageCalculator.calculate(from: raw) == nil)
    }
}
