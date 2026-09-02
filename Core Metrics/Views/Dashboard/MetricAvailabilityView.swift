import SwiftUI

/// Compact, non-color-only feedback for expected startup latency and provider
/// failures. Failed metrics retry automatically in `MetricsStore`.
struct MetricAvailabilityView: View {
    let metricName: String
    let state: MetricSampleState

    var body: some View {
        if state != .available {
            Label(message, systemImage: systemImage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityElement(children: .combine)
        }
    }

    private var message: String {
        switch state {
        case .collecting:
            "Collecting the first \(metricName) sample…"
        case .available:
            ""
        case .unavailable:
            "\(metricName) is temporarily unavailable. Retrying automatically."
        }
    }

    private var systemImage: String {
        switch state {
        case .collecting:
            "clock"
        case .available:
            "checkmark.circle"
        case .unavailable:
            "exclamationmark.triangle"
        }
    }
}
