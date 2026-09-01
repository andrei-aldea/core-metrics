import SwiftUI

struct ContentView: View {
    var body: some View {
        ContentUnavailableView(
            "Core Metrics",
            systemImage: "gauge.with.dots.needle.67percent",
            description: Text("Native menu-bar metrics are being prepared.")
        )
        .frame(minWidth: 360, minHeight: 240)
    }
}

#Preview {
    ContentView()
}
