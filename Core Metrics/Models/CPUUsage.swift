import Foundation

/// A normalized CPU sample. Every value is a fraction in `0...1`.
///
/// `user` includes Mach's `nice` category so the public breakdown remains
/// internally consistent: `total == user + system` and
/// `user + system + idle == 1`, subject to floating-point rounding.
nonisolated struct CPUUsage: Equatable, Sendable {
    let total: Double
    let user: Double
    let system: Double
    let idle: Double
}
