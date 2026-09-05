# Design and accessibility

Core Metrics is a restrained native Mac utility. The menu bar is the primary surface; its persistent panel and Settings configure the values. There is no mobile layout, dashboard chart, process list or optimizer UI.

## Visual contract

- Use system typography, semantic monochrome colors, native controls, SF Symbols and platform spacing. Selection is visible through checkboxes and labels, never color alone.
- The status item presents live text for one to seven selected stats in CPU → Memory → Storage order. It shows no branded header. Its text image is capped at 320 points and uses a tail ellipsis when the full selection is wider; Settings and the accessible summary retain every selected value.
- Label and Value, Compact, and single-stat Value Only are the supported modes. Names/short codes stay recognizable; values use locale-aware digits, zero-decimal percentages, and one-decimal byte units.
- Reserve numeric space independently of live readings to prevent width jitter. Account for locale glyph widths as well as character count. A larger locale-specific reservation must remain stable between samples.
- Render the system monospaced status text into a fixed-size template image using public APIs. The native menu bar supplies the tint. Check the actual status item as values change; a successful standalone text-width calculation does not prove the displayed status item is stable.
- macOS owns the window-style MenuBarExtra material and Settings chrome; the preview uses the native glass modifier. Do not stack custom blur layers or imitate system glass.
- There are no continuous animations, charts, decorative cards, progress bars, or color severity scales.

## Surfaces and layout

The status panel begins with CPU, then Memory and Storage checkbox sections, followed by text-mode controls, About, Settings and Quit. Changing a stat keeps the panel open. No live number is duplicated beside each selector.

The panel has a 420-point normal width and a 500-point accessibility-size branch. Its grouped form can scroll. Settings has a 520-point minimum width, a horizontally scrollable live preview of the full selection, selected rows with remove buttons, an Add Stat menu, representation choices, Privacy and Restore Defaults. The preview participates in keyboard focus, retains native scroll indicators, and explains both horizontal scrolling and menu-bar truncation. Test actual macOS text/display settings; a SwiftUI dynamicTypeSize branch alone does not prove desktop large-text support.

Privacy opens a native sheet with semantic headings and selectable, wrapping text. Its content can scroll and receive keyboard focus; Done remains outside the scrolling area. Return and Escape dismiss the sheet. The content explains the implemented local data handling without inventing publisher contacts, public URLs, or legal guarantees. Public release-policy and support requirements remain in [APP_STORE.md](APP_STORE.md).

The 320-point text-image cap limits space taken by long selections. Compact mode or fewer selections can keep more complete values visible, while the full preview and accessible summary remain available. macOS manages available space, so the cap cannot guarantee visibility on every crowded desktop or beside every notch. Wider localized glyphs consume additional real space.

## Failure and accessibility semantics

An unavailable provider clears its old value and displays an em dash; VoiceOver says “Unavailable.” CPU needs an initial baseline before showing a delta, and unavailable swap does not hide valid RAM values.

The status image's intrinsic accessibility label includes “Core Metrics” followed by the full metric/value summary, including values omitted by visual truncation. Native UI assertions inspect the status item's `title` attribute. Panel checkboxes expose full metric context to distinguish, for example, Memory Used Percentage from Storage Used Percentage. Native selection state remains available. Remove controls identify their stat and explain when at least one selection must remain. Decorative short codes in Settings are hidden from accessibility.

Descriptive strings use localization-aware APIs and existing SwiftUI extraction. There are no bundled translations yet. Compact menu-bar abbreviations intentionally retain their established English spelling; translation requires width and meaning review. Number formatting accepts the locale without inventing translated content.

## Required runtime review

Verify status selection, one/seven boundaries, persistent-panel behavior, canonical ordering, all three modes, Settings opening/closing, immediate updates and horizontal preview. Check short and truncated long status text, the complete accessible summary, and live status width across several sampling updates with an unchanged configuration. Exercise Privacy opening/reopening, vertical scrolling, Done/Return/Escape dismissal, and focus restoration. Check keyboard traversal/scrolling, VoiceOver navigation and focus, labels/values/hints, light/dark appearance, Increased Contrast, Reduce Transparency, Reduce Motion, Differentiate Without Color, supported larger text, constrained windows and long locale glyphs.

Interactive test launches use an isolated preferences suite and an application-only appearance override compiled into Debug. The dark seven-stat scenario adds selections after opening the panel, then uses an explicit test relaunch flag to preserve them and exercise startup. Additional crowded-menu-bar configurations still require review. Restore preferences and system display settings after any manual testing. Automated AX inspection and width fixtures help find regressions but do not replace a complete VoiceOver/Switch Control and display-matrix review. See the [report](PROJECT_ANALYSIS_REPORT.md) for completed checks and outstanding coverage.
