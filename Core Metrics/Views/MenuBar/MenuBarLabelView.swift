import AppKit
import SwiftUI

/// The full, scrollable Settings preview. Native status geometry is owned by
/// StatusItemController rather than inferred from a SwiftUI label's frame.
struct MenuBarLabelView: View {
    @Environment(\.locale) private var locale
    @Environment(MetricsStore.self) private var metricsStore
    @Environment(PreferencesStore.self) private var preferencesStore
    @State private var layout = MenuBarLabelLayout(locale: .current)

    var body: some View {
        let configuration = MenuBarConfiguration(
            enabledStats: preferencesStore.enabledStats,
            displayMode: preferencesStore.displayMode
        )
        let presentation = StatusItemPresentation(
            configuration: configuration,
            cpuUsage: metricsStore.cpuUsage,
            memoryUsage: metricsStore.memoryUsage,
            storageUsage: metricsStore.storageUsage,
            locale: locale
        )

        Text(previewTitle(layout.attributedTitle(
            stats: configuration.enabledStats,
            values: presentation.values,
            displayMode: configuration.displayMode
        )))
            .lineLimit(1)
            .frame(
                width: layout.width(
                    stats: configuration.enabledStats,
                    displayMode: configuration.displayMode
                ),
                alignment: .leading
            )
            .help(presentation.accessibilitySummary)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(presentation.accessibilityLabel)
            .onChange(of: locale, initial: true) { _, locale in
                layout = MenuBarLabelLayout(locale: locale)
            }
    }

    private func previewTitle(_ nativeTitle: NSAttributedString) -> AttributedString {
        var title = AttributedString()
        nativeTitle.enumerateAttributes(
            in: NSRange(location: 0, length: nativeTitle.length)
        ) { attributes, range, _ in
            var run = AttributedString(nativeTitle.attributedSubstring(from: range).string)
            if let font = attributes[.font] as? NSFont {
                // NSAttributedString's default bridge keeps AppKit metadata;
                // Text requires a font in the SwiftUI attribute scope.
                run.font = Font(font)
            }
            if let kern = attributes[.kern] as? NSNumber {
                run.kern = CGFloat(kern.doubleValue)
            }
            title.append(run)
        }
        return title
    }
}
