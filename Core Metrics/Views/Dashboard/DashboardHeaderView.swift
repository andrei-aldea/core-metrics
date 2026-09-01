import SwiftUI

struct DashboardHeaderView: View {
    let isSampling: Bool
    let hasSamplingIssue: Bool

    var body: some View {
        HStack {
            Label {
                VStack(alignment: .leading) {
                    Text("Core Metrics")
                        .font(.headline)

                    Text("System overview")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: "gauge.with.dots.needle.67percent")
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)
            }
            .accessibilityElement(children: .combine)

            Spacer()

            Label(statusTitle, systemImage: statusSymbol)
                .font(.subheadline)
                .foregroundStyle(.secondary)
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
}
