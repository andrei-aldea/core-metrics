import SwiftUI

struct MenuBarMetricLabelView: View {
    let metric: MetricKind
    let displayMode: MenuBarDisplayMode
    let value: String

    var body: some View {
        switch displayMode {
        case .iconAndValue:
            HStack(spacing: 4) {
                Image(systemName: metric.systemImage)
                Text(value)
            }
        case .valueOnly:
            Text(value)
        case .compact:
            Text("\(metric.shortCode) \(value)")
        }
    }
}
