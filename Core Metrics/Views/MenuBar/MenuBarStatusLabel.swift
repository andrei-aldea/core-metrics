import CoreGraphics
import SwiftUI

/// MenuBarExtra adapts text to a native status title and can drop its layout.
/// A template image preserves the measured font/width and system tint.
struct MenuBarStatusLabel: View {
    static let maximumWidth: CGFloat = 320

    let text: String
    let width: CGFloat
    let spokenSummary: String

    @Environment(\.displayScale) private var displayScale
    @State private var renderedLabel: RenderedLabel?

    var body: some View {
        Group {
            if let renderedLabel {
                Image(
                    renderedLabel.image,
                    scale: renderedLabel.scale,
                    label: Text(verbatim: renderedLabel.accessibilityLabel)
                )
                .renderingMode(.template)
            } else {
                Image(systemName: "gauge.with.dots.needle.33percent")
                    .accessibilityLabel(Text("Core Metrics, \(spokenSummary)"))
            }
        }
        .help(spokenSummary)
        .onChange(of: renderInput, initial: true) { _, input in
            let renderer = ImageRenderer(
                content: Text(verbatim: input.text)
                    .font(Font(MenuBarLabelLayout.font))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(width: input.width, alignment: .leading)
            )
            renderer.scale = input.scale
            if let image = renderer.cgImage {
                renderedLabel = RenderedLabel(
                    image: image,
                    scale: input.scale,
                    accessibilityLabel: "Core Metrics, \(input.spokenSummary)"
                )
            } else {
                renderedLabel = nil
            }
        }
    }

    private var renderInput: RenderInput {
        RenderInput(
            text: text,
            width: min(width, Self.maximumWidth),
            scale: displayScale,
            spokenSummary: spokenSummary
        )
    }

    private struct RenderedLabel {
        let image: CGImage
        let scale: CGFloat
        let accessibilityLabel: String
    }

    private struct RenderInput: Equatable {
        let text: String
        let width: CGFloat
        let scale: CGFloat
        let spokenSummary: String
    }
}
