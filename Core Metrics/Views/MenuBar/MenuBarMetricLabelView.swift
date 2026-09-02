import SwiftUI

struct MenuBarMetricLabelView: View {
    let stat: MenuBarStat
    let displayMode: MenuBarDisplayMode
    let value: String

    var body: some View {
        Group {
            switch displayMode {
            case .iconAndValue:
                HStack(spacing: 3) {
                    Image(systemName: stat.metric.systemImage)
                        .frame(width: 14)
                    Text(stat.detailCode)
                        .frame(width: 10, alignment: .trailing)
                    valueText
                }
                .frame(width: 30 + valueWidth, alignment: .trailing)
            case .valueOnly:
                valueText
            case .compact:
                HStack(spacing: 3) {
                    Text(stat.shortCode)
                        .frame(width: 18, alignment: .trailing)
                    valueText
                }
                .frame(width: 21 + valueWidth, alignment: .trailing)
            }
        }
        .help("\(stat.displayName): \(value)")
    }

    private var valueText: some View {
        Text(value)
            .frame(width: valueWidth, alignment: .trailing)
            .minimumScaleFactor(0.8)
    }

    /// The value column is intentionally fixed so live samples cannot resize
    /// this stat's menu-bar slot. Byte values need more room than percentages.
    private var valueWidth: CGFloat {
        switch stat.valueWidth {
        case .percentage:
            42
        case .bytes:
            66
        }
    }
}
