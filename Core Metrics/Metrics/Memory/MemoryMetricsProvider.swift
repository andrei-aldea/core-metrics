import Darwin
import Foundation

/// Reads documented 64-bit host VM statistics and feeds the pure Core Metrics
/// memory calculator.
nonisolated struct MemoryMetricsProvider: MemoryMetricsProviding {
    private var cachedPageSizeBytes: UInt64?

    mutating func sample() throws -> MemoryUsage? {
        MemoryUsageCalculator.calculate(from: try readRawCounters())
    }

    mutating func readRawCounters() throws -> MemoryRawCounters {
        let host = mach_host_self()
        var statistics = vm_statistics64_data_t()
        let requestedCount = mach_msg_type_number_t(
            MemoryLayout<vm_statistics64_data_t>.stride
                / MemoryLayout<integer_t>.stride
        )
        let requiredCount = mach_msg_type_number_t(
            (MemoryLayout<vm_statistics64_data_t>.offset(
                of: \.total_uncompressed_pages_in_compressor
            ) ?? MemoryLayout<vm_statistics64_data_t>.stride)
                / MemoryLayout<integer_t>.stride
        )
        var count = requestedCount

        let result = withUnsafeMutablePointer(to: &statistics) { pointer in
            pointer.withMemoryRebound(
                to: integer_t.self,
                capacity: Int(requestedCount)
            ) { reboundPointer in
                host_statistics64(
                    host,
                    HOST_VM_INFO64,
                    reboundPointer,
                    &count
                )
            }
        }

        guard result == KERN_SUCCESS else {
            throw HostMemoryStatisticsError.vmStatisticsCallFailed(result)
        }
        // Later SDKs append counters to this versioned structure. Accept any
        // successful result that includes the final field Core Metrics reads.
        guard count >= requiredCount else {
            throw HostMemoryStatisticsError.incompleteResult
        }

        let pageSizeBytes = try pageSize(for: host)
        return MemoryRawCounters(
            totalBytes: ProcessInfo.processInfo.physicalMemory,
            pageSizeBytes: pageSizeBytes,
            internalPageCount: UInt64(statistics.internal_page_count),
            purgeablePageCount: UInt64(statistics.purgeable_count),
            wiredPageCount: UInt64(statistics.wire_count),
            compressorPageCount: UInt64(statistics.compressor_page_count)
        )
    }

    private mutating func pageSize(for host: host_t) throws -> UInt64 {
        if let cachedPageSizeBytes {
            return cachedPageSizeBytes
        }

        var pageSize: vm_size_t = 0
        let result = host_page_size(host, &pageSize)
        guard result == KERN_SUCCESS, pageSize > 0 else {
            throw HostMemoryStatisticsError.pageSizeCallFailed(result)
        }

        let bytes = UInt64(pageSize)
        cachedPageSizeBytes = bytes
        return bytes
    }
}
