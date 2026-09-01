import SwiftUI

struct MetricSectionView<Content: View>: View {
    let title: String
    let systemImage: String
    let primaryLabel: String
    let primaryValue: String
    let primaryAccessibilityValue: String
    @ViewBuilder let content: Content

    init(
        title: String,
        systemImage: String,
        primaryLabel: String,
        primaryValue: String,
        primaryAccessibilityValue: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.systemImage = systemImage
        self.primaryLabel = primaryLabel
        self.primaryValue = primaryValue
        self.primaryAccessibilityValue = primaryAccessibilityValue
            ?? (primaryValue == MetricFormatting.unavailable ? "Unavailable" : primaryValue)
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DashboardLayout.sectionSpacing) {
            HStack(alignment: .firstTextBaseline) {
                Label {
                    Text(title)
                } icon: {
                    Image(systemName: systemImage)
                        .foregroundStyle(Color.accentColor)
                }
                .font(.headline)

                Spacer()

                VStack(alignment: .trailing, spacing: 0) {
                    Text(primaryValue)
                        .font(.title2)
                        .bold()
                        .monospacedDigit()

                    Text(primaryLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(primaryLabel))
                .accessibilityValue(Text(primaryAccessibilityValue))
            }

            content
        }
        .padding(.horizontal)
        .padding(.vertical, DashboardLayout.sectionVerticalPadding)
    }
}
