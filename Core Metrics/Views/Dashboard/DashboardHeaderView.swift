import AppKit
import SwiftUI

struct DashboardHeaderView: View {
    let isSampling: Bool
    let hasSamplingIssue: Bool

    var body: some View {
        HStack(spacing: 10) {
            Label {
                VStack(alignment: .leading) {
                    Text("Core Metrics")
                        .font(.headline)

                    Text("System overview")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Image(nsImage: NSApplication.shared.applicationIconImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .accessibilityHidden(true)
            }
            .accessibilityElement(children: .combine)

            Spacer()

            Label(statusTitle, systemImage: statusSymbol)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .glassEffect(.regular, in: .capsule)
                .accessibilityLabel("Sampling status")
                .accessibilityValue(statusTitle)
                .help(statusHelp)
        }
    }

    private var statusTitle: String {
        if !isSampling {
            "Paused"
        } else if hasSamplingIssue {
            "Limited"
        } else {
            "Live"
        }
    }

    private var statusSymbol: String {
        if !isSampling {
            "pause.circle"
        } else if hasSamplingIssue {
            "exclamationmark.triangle"
        } else {
            "dot.radiowaves.left.and.right"
        }
    }

    private var statusHelp: String {
        if !isSampling {
            "Metric sampling is paused."
        } else if hasSamplingIssue {
            "One or more metrics are temporarily unavailable and will retry automatically."
        } else {
            "All aggregate metrics are sampling normally."
        }
    }
}
