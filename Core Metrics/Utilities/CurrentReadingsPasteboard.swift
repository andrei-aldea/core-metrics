import AppKit

/// Performs an explicit copy operation. Tests supply a privately named
/// pasteboard instead of reading or replacing the person's clipboard.
@MainActor
enum CurrentReadingsPasteboard {
    static func write(_ text: String, to pasteboard: NSPasteboard) -> Bool {
        // Disk-space reason 85F4.1 permits local display, not Internet transfer.
        // Prevent Universal Clipboard from automatically exporting copied readings.
        pasteboard.prepareForNewContents(with: .currentHostOnly)
        return pasteboard.setString(text, forType: .string)
    }
}
