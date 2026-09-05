import SwiftUI

struct MetricHelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("What the Numbers Mean")
                .font(.title2)
                .bold()
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("metricHelp.title")

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        heading("CPU")
                        Text("CPU readings combine all cores into a total of 100%. Used is User plus System; Idle is the remaining capacity. User measures work by apps and other software. System measures operating-system work.")
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        heading("Memory")
                        Text("RAM Used excludes free memory and cached files. RAM Used % compares that amount with installed memory. A high used percentage alone does not indicate memory pressure.")
                        Text("Wired memory must stay in RAM. Compressed is the RAM occupied by compressed data. Cached Files is file-backed memory that macOS can reclaim. Swap is disk space used for memory management.")
                        Text("These categories overlap, so adding every memory reading does not give the total.")
                        Text("Memory units use multiples of 1,024; storage units use multiples of 1,000.")
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        heading("Storage")
                        Text("Storage readings describe the startup volume. Used is Total minus Free. Free is the available space reported by the file system, which can differ from Finder’s estimates that include reclaimable space.")
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        heading("Reading Updates")
                        Text("CPU and memory refresh about every two seconds; storage refreshes about every thirty seconds. A dash means a reading is unavailable. CPU needs an initial reading after launch or a sampling gap. Swap can be unavailable while other memory readings remain valid.")
                        Text("Core Metrics shows current readings and saves no metric history.")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)
            }
            .focusable()
            .accessibilityIdentifier("metricHelp.content")
            .accessibilityLabel("Metric Explanations")
            .accessibilityHint("Scroll vertically to read all metric explanations.")

            HStack {
                Spacer()
                Button("Done", action: close)
                    .keyboardShortcut(.defaultAction)
                    .accessibilityIdentifier("metricHelp.done")
            }
        }
        .padding(24)
        .frame(minWidth: 480, idealWidth: 560, minHeight: 440, idealHeight: 540)
        .onExitCommand(perform: close)
    }

    private func heading(_ title: LocalizedStringKey) -> some View {
        Text(title)
            .font(.headline)
            .accessibilityAddTraits(.isHeader)
    }

    private func close() {
        dismiss()
    }
}
