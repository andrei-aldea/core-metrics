import AppKit

/// Performs an explicit copy operation. Tests supply a privately named
/// pasteboard instead of reading or replacing the person's clipboard.
@MainActor
enum CurrentReadingsPasteboard {
    static func write(_ text: String, to pasteboard: NSPasteboard) -> Bool {
        pasteboard.clearContents()
        return pasteboard.setString(text, forType: .string)
    }
}
