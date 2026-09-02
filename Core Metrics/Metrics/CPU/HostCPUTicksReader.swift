import Darwin

/// Reads cumulative aggregate CPU ticks through the documented Mach
/// `host_statistics(HOST_CPU_LOAD_INFO)` API.
nonisolated struct HostCPUTicksReader: CPUTicksReading {
    func readTicks() throws -> CPUTicks {
        let host = mach_host_self()
        defer {
            mach_port_deallocate(mach_task_self_, host)
        }

        var information = host_cpu_load_info_data_t()
        let expectedCount = mach_msg_type_number_t(
            MemoryLayout<host_cpu_load_info_data_t>.stride
                / MemoryLayout<integer_t>.stride
        )
        var count = expectedCount

        let result = withUnsafeMutablePointer(to: &information) { pointer in
            pointer.withMemoryRebound(
                to: integer_t.self,
                capacity: Int(count)
            ) { reboundPointer in
                host_statistics(
                    host,
                    HOST_CPU_LOAD_INFO,
                    reboundPointer,
                    &count
                )
            }
        }

        guard result == KERN_SUCCESS else {
            throw HostCPUStatisticsError.machCallFailed(result)
        }
        guard count >= expectedCount else {
            throw HostCPUStatisticsError.incompleteResult
        }

        return CPUTicks(
            user: UInt32(information.cpu_ticks.0),
            system: UInt32(information.cpu_ticks.1),
            idle: UInt32(information.cpu_ticks.2),
            nice: UInt32(information.cpu_ticks.3)
        )
    }
}
