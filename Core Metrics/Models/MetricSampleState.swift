import Foundation

/// Current acquisition state for one aggregate metric.
///
/// A missing first CPU delta is expected and remains `collecting`. Provider
/// errors and invalid memory/storage snapshots become `unavailable` until a
/// valid sample arrives. This keeps the UI from treating startup latency as a
/// fault or stale data as live.
nonisolated enum MetricSampleState: Equatable, Sendable {
    case collecting
    case available
    case unavailable
}
