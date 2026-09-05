import AppKit
import Testing
@testable import Core_Metrics

@MainActor
@Suite("Current readings pasteboard")
struct CurrentReadingsPasteboardTests {
    @Test("Copies readings to an isolated pasteboard and replaces previous content")
    func writesToNamedPasteboard() throws {
        let pasteboard = NSPasteboard.withUniqueName()
        defer { pasteboard.releaseGlobally() }
        pasteboard.clearContents()
        try #require(pasteboard.setString("Previous contents", forType: .string))

        let text = "CPU User: 15%\nMemory Used: 12.0GB\nSSD Free Space: 143.0GB"

        #expect(CurrentReadingsPasteboard.write(text, to: pasteboard))
        #expect(pasteboard.string(forType: .string) == text)
    }
}
