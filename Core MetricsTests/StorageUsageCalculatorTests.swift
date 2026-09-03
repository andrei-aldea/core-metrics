import Testing
@testable import Core_Metrics

@Suite("Storage usage calculation")
struct StorageUsageCalculatorTests {
    @Test("Maintains used, available, and total relationships")
    func calculatesExpectedCapacity() throws {
        let snapshot = StorageCapacitySnapshot(totalBytes: 1_000, availableBytes: 250)
        let usage = try #require(StorageUsageCalculator.calculate(from: snapshot))

        #expect(usage.usedBytes == 750)
        #expect(usage.availableBytes == 250)
        #expect(usage.usedBytes + usage.availableBytes == usage.totalBytes)
        #expect(usage.usedFraction == 0.75)
    }

    @Test("Clamps an inconsistent available value")
    func clampsAvailableCapacity() throws {
        let snapshot = StorageCapacitySnapshot(totalBytes: 100, availableBytes: 150)
        let usage = try #require(StorageUsageCalculator.calculate(from: snapshot))

        #expect(usage.availableBytes == 100)
        #expect(usage.usedBytes == 0)
        #expect(usage.usedFraction == 0)
    }

    @Test("Rejects a zero-capacity volume")
    func rejectsZeroTotal() {
        let snapshot = StorageCapacitySnapshot(totalBytes: 0, availableBytes: 0)
        #expect(StorageUsageCalculator.calculate(from: snapshot) == nil)
    }
}
