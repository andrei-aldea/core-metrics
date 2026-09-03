import SwiftUI

struct MetricRowView: View {
    let label: String
    let value: String
    let accessibilityValue: String

    init(label: String, value: String, accessibilityValue: String? = nil) {
        self.label = label
        self.value = value
        self.accessibilityValue = accessibilityValue
            ?? (value == MetricFormatting.unavailable ? "Unavailable" : value)
    }

    var body: some View {
        LabeledContent {
            Text(value)
                .monospacedDigit()
        } label: {
            Text(label)
                .foregroundStyle(.secondary)
        }
        .font(.body)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(label))
        .accessibilityValue(Text(accessibilityValue))
    }
}
