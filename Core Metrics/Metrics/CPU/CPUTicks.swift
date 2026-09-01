import Foundation

/// Cumulative tick counters copied from `host_cpu_load_info_data_t`.
///
/// Keeping the values as `UInt32` preserves the width of Mach's `natural_t`
/// counters and lets the calculator handle rollover with wrapping subtraction.
nonisolated struct CPUTicks: Equatable, Sendable {
    let user: UInt32
    let system: UInt32
    let idle: UInt32
    let nice: UInt32
}
