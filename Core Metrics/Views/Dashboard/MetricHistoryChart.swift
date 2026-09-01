import Charts
import SwiftUI

struct MetricHistoryChart<Sample>: View {
    @Environment(\.locale) private var locale

    let metricName: String
    let samples: [Sample]
    let value: KeyPath<Sample, Double>

    var body: some View {
        Chart(samples.indices, id: \.self) { index in
            LineMark(
                x: .value("Sample", index + 1),
                y: .value("Percentage", fraction(at: index))
            )
            .foregroundStyle(Color.accentColor)
            .lineStyle(
                StrokeStyle(
                    lineWidth: 1.5,
                    lineCap: .round,
                    lineJoin: .round
                )
            )

            if samples.count == 1 {
                PointMark(
                    x: .value("Sample", index + 1),
                    y: .value("Percentage", fraction(at: index))
                )
                .foregroundStyle(Color.accentColor)
                .symbolSize(18)
            }
        }
        .chartYScale(domain: 0...1)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .frame(maxWidth: .infinity)
        .frame(height: DashboardLayout.chartHeight)
        .overlay {
            if samples.isEmpty {
                Text("Collecting history…")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(metricName) history"))
        .accessibilityValue(Text(accessibilitySummary))
    }

    private var accessibilitySummary: String {
        guard let firstSample = samples.first else {
            return "No history samples available."
        }

        var minimum = normalized(firstSample[keyPath: value])
        var maximum = minimum

        for sample in samples.dropFirst() {
            let sampleValue = normalized(sample[keyPath: value])
            minimum = min(minimum, sampleValue)
            maximum = max(maximum, sampleValue)
        }

        let latest = normalized(samples[samples.count - 1][keyPath: value])
        let latestText = MetricFormatting.percentage(latest, locale: locale)

        guard samples.count > 1 else {
            return "One recent sample: \(latestText)."
        }

        let minimumText = MetricFormatting.percentage(minimum, locale: locale)
        let maximumText = MetricFormatting.percentage(maximum, locale: locale)
        return "\(samples.count) recent samples. Latest \(latestText), minimum \(minimumText), maximum \(maximumText)."
    }

    private func fraction(at index: Int) -> Double {
        normalized(samples[index][keyPath: value])
    }

    private func normalized(_ value: Double) -> Double {
        value.isFinite ? min(max(value, 0), 1) : 0
    }
}
