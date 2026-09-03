import Darwin
import Foundation

/// Reads documented 64-bit host VM statistics and the public VM swap-usage
/// sysctl, then feeds the pure Core Metrics memory calculator.
nonisolated struct MemoryMetricsProvider: MemoryMetricsProviding {
    private var cachedPageSizeBytes: UInt64?

    mutating func sample() throws -> MemoryUsage? {
        MemoryUsageCalculator.calculate(from: try readRawCounters())
    }

    mutating func readRawCounters() throws -> MemoryRawCounters {
        let host = mach_host_self()
        defer {
            mach_port_deallocate(mach_task_self_, host)
        }

        var statistics = vm_statistics64_data_t()
        let requestedCount = mach_msg_type_number_t(
            MemoryLayout<vm_statistics64_data_t>.stride
                / MemoryLayout<integer_t>.stride
        )
        guard let externalFieldOffset = MemoryLayout<vm_statistics64_data_t>.offset(
            of: \.external_page_count
        ) else {
            throw HostMemoryStatisticsError.incompleteResult
        }

        let externalFieldEnd = externalFieldOffset
            + MemoryLayout<natural_t>.stride
        let integerStride = MemoryLayout<integer_t>.stride
        let requiredCount = mach_msg_type_number_t(
            (externalFieldEnd + integerStride - 1) / integerStride
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
            freePageCount: UInt64(statistics.free_count),
            externalPageCount: UInt64(statistics.external_page_count),
            swapUsedBytes: swapUsedBytes()
        )
    }

    /// Swap is useful but not required for the other memory values. Returning
    /// `nil` keeps Memory Used and Cached Files live when this independent read
    /// is temporarily unavailable.
    private func swapUsedBytes() -> UInt64? {
        var name = [CTL_VM, VM_SWAPUSAGE]
        var usage = xsw_usage()
        var size = MemoryLayout<xsw_usage>.size

        let result = name.withUnsafeMutableBufferPointer { namePointer in
            withUnsafeMutablePointer(to: &usage) { usagePointer in
                sysctl(
                    namePointer.baseAddress,
                    UInt32(namePointer.count),
                    usagePointer,
                    &size,
                    nil,
                    0
                )
            }
        }

        guard result == 0, size >= MemoryLayout<xsw_usage>.size else {
            return nil
        }

        return usage.xsu_used
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
