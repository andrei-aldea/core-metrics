# Design and accessibility

Core Metrics is a restrained native Mac utility. The menu bar is the primary surface; its persistent panel and Settings configure the values. There is no mobile layout, dashboard chart, process list or optimizer UI.

## Visual contract

- Use system typography, semantic monochrome colors, native controls, SF Symbols and platform spacing. Selection is visible through checkboxes and labels, never color alone.
- The status item presents native live text for one to seven selected stats in CPU → Memory → Storage order. It shows no branded header. Supply the full selection without an app-imposed width cap; Settings provides a scrollable preview of every selected value.
- Label and Value, Compact, and single-stat Value Only are the supported modes. Names/short codes stay recognizable; values use locale-aware digits, zero-decimal percentages, and one-decimal byte units.
- Reserve numeric space independently of live readings to reduce width jitter. Account for locale glyph widths as well as character count. Keep the requested locale-specific reservation stable between samples.
- Use a single native attributed Text with the existing system monospaced font and locale-aware layout. The menu-bar host may adapt its font and width. Check typography, complete readings and actual width as values change; a standalone text-width calculation does not guarantee fixed native status-item dimensions.
- macOS owns the window-style MenuBarExtra material and Settings chrome; the preview uses the native glass modifier. Do not stack custom blur layers or imitate system glass.
- There are no continuous animations, charts, decorative cards, progress bars, or color severity scales.

## Surfaces and layout

The status panel begins with CPU, then Memory and Storage checkbox sections, followed by Copy Current Readings and Metric Help, then About, Settings and Quit. The panel contains no Menu Bar Text heading or representation picker; the space is available for its scrollable metric choices. Changing a stat keeps the panel open. No live number is duplicated beside each selector.

The panel has a 420-point normal width and a 500-point accessibility-size branch. Its grouped form can scroll. Settings has a 520-point minimum width, a horizontally scrollable live preview of the full selection, Menu Bar Text choices immediately below it, selected rows with remove buttons, an Add Stat menu, optional Launch at Login, Privacy, Metric Help and Restore Defaults. The preview participates in keyboard focus, retains native scroll indicators, and explains horizontal scrolling. Test actual macOS text/display settings; a SwiftUI dynamicTypeSize branch alone does not prove desktop large-text support.

SettingsLink uses a narrowly scoped native button style that requests application activation before forwarding the link’s action. Clicking Settings or using Command-comma should open or raise the native Settings window in front; testing must not activate the app afterward to make this work.

Privacy opens a native sheet with semantic headings and selectable, wrapping text. Its content can scroll and receive keyboard focus; Done remains outside the scrolling area. Return and Escape dismiss the sheet. The content explains the implemented local data handling without inventing publisher contacts, public URLs, or legal guarantees. Public release-policy and support requirements remain in [APP_STORE.md](APP_STORE.md).

Metric Help is a native sheet available from the panel and Settings, with the same scrolling, selectable text, semantic headings, and Done/Return/Escape behavior as Privacy. It explains the app’s current definitions without implying that all memory categories add together or that usage percentage measures memory pressure. Copy Current Readings includes full selected names and locale-aware values, with inline “Copied” feedback, a spoken accessibility announcement for every successful copy, and a native failure alert. It runs only when requested.

Launch at Login starts off for an unregistered app. The toggle reflects macOS state, disables during a registration change, and displays pending approval or unavailable states in text. Approval and errors offer a native System Settings action. Restore Defaults resets menu-bar choices only.

macOS manages available menu-bar space. Long selections may not fit on crowded desktops or beside a notch; Compact mode or fewer selections require less room. The app supplies every selected reading, while Settings and Copy Current Readings provide the full selection independently of available status-item space. Wider localized glyphs consume additional real space.

## Failure and accessibility semantics

An unavailable provider clears its old value and displays an em dash; VoiceOver says “Unavailable.” CPU needs an initial baseline before showing a delta, and unavailable swap does not hide valid RAM values.

The native Text supplies “Core Metrics” as its accessibility label and the full metric/value summary as its accessibility value. Inspect how the native status-item host exposes that information and verify spoken output in the running app. Panel checkboxes expose full metric context to distinguish, for example, Memory Used Percentage from Storage Used Percentage. Native selection state remains available. Remove controls identify their stat and explain when at least one selection must remain. Decorative short codes in Settings are hidden from accessibility.

Descriptive strings use localization-aware APIs and existing SwiftUI extraction. There are no bundled translations yet. Compact menu-bar abbreviations intentionally retain their established English spelling; translation requires width and meaning review. Number formatting accepts the locale without inventing translated content.

## Required runtime review

Verify status selection, one/seven boundaries, persistent-panel behavior, canonical ordering, all three modes, Settings opening/closing, immediate updates and horizontal preview. Check native typography and complete readings with one, three and seven selections, the accessible summary, and live status width across several sampling updates with an unchanged configuration. Distinguish space imposed by macOS from missing application content. Exercise login toggling and approval/error guidance, explicit copy success/failure, and Metric Help from both entry points. Exercise Privacy opening/reopening, vertical scrolling, Done/Return/Escape dismissal, and focus restoration. Check keyboard traversal/scrolling, VoiceOver navigation and focus, labels/values/hints, light/dark appearance, Increased Contrast, Reduce Transparency, Reduce Motion, Differentiate Without Color, supported larger text, constrained windows and long locale glyphs.

Interactive test launches use an isolated preferences suite and an application-only appearance override compiled into Debug. The dark seven-stat scenario adds selections after opening the panel, then uses an explicit test relaunch flag to preserve them and exercise startup. Alongside the broad light and dark flows, a focused Settings test adds Memory Used and SSD Free Space in Label and Value mode, verifies all three status names and width growth, and closes and reopens Settings to check the selections. Additional crowded-menu-bar configurations still require review. Restore preferences and system display settings after any manual testing. Automated AX inspection and width fixtures help find regressions but do not replace a complete VoiceOver/Switch Control and display-matrix review. See the [report](PROJECT_ANALYSIS_REPORT.md) for completed checks and outstanding coverage.
