# Design

Core Metrics should feel like a restrained, independent macOS utility: dense enough to scan quickly, calm enough to live in the menu bar all day.

## Principles

- The menu bar shows only the enabled metrics and never the full app name.
- The dashboard uses one clear vertical hierarchy instead of a webpage-like grid of decorative cards.
- Live numbers use monospaced digits, locale-aware formatting, and useful precision.
- System typography, semantic colors, native controls, SF Symbols, separators, progress indicators, and Swift Charts are preferred.
- The interface is strictly monochrome. Semantic primary, secondary, and separator styles establish hierarchy without chromatic accents. CPU, memory, and storage remain distinguishable through labels, SF Symbols, values, and structure rather than color.
- Live samples update without a forced one-second animation loop, so Reduce Motion requires no alternate continuous-animation path.
- Native Liquid Glass defines the macOS 27 platform chrome and the small interactive/status layer. Core Metrics uses the system effect directly and sparingly; it does not build decorative glass replicas or stack blur effects behind data content.

## Implemented visual system

- The native window-style menu-bar extra provides the top-level Liquid Glass surface and automatically adopts the current macOS appearance. Data sections remain clear and flat so values have one readable visual plane.
- A compact header uses the real application icon and reports `Live`, `Limited`, or `Paused` in a text-and-symbol status badge, never through color alone.
- CPU, memory, and storage are stacked in one scrollable column with full-width separators. There are no card grids, ornamental borders, or per-metric background treatments.
- Metric symbols, chart traces, progress, controls, and status treatments use semantic monochrome styles. Native glass is reserved for the live-status badge, Settings preview, and footer actions where it communicates a distinct functional layer.
- Secondary labels and status text use semantic foreground styles, so light, dark, Increased Contrast, and Reduce Transparency remain system-managed.
- The Settings window uses a grouped `Form`, a horizontally scrollable glass live preview, a native add menu, a segmented picker, compact order/removal buttons, help text, and a standard restore action.

## Dashboard hierarchy

- CPU: total utilization, quiet history line, and user/system/idle breakdown.
- Memory: used percentage, App Estimate/Wired/Compressed breakdown, used/available/total values, and quiet history line.
- Storage: startup volume usage with used/available/total and a native progress treatment.

When a live provider is unavailable, the primary value and detail rows display an unavailable state instead of retaining stale numbers. Each affected section explains that the read is temporary and automatically retrying. Valid chart history can remain visible as historical context, while the header's limited status makes the current sampling condition explicit. Initial CPU delta collection has a distinct neutral state so normal startup is not presented as an error.

## Accessibility checks

Every metric group provides visible text and a combined VoiceOver description. Charts are a single accessibility element that summarizes sample count, latest value, minimum, and maximum rather than exposing every point. Menu-bar values have explicit semantic descriptions, reorder buttons have action labels and help, and native controls retain standard keyboard focus behavior.

Menu-bar customization remains deliberately bounded. People can select and order up to five documented aggregate stats, including multiple details from one metric, and choose a compact display mode. Icon mode pairs the category symbol with a one-character detail qualifier; compact mode uses a unique two-character code. Each stat reserves a fixed percentage or byte-value column so updates do not shift neighboring slots. Core Metrics does not add arbitrary precision, threshold colors, or unrelated hardware/process statistics that would make the status item harder to scan.

Before release, verify the running app in light and dark appearance, Increased Contrast, Reduce Transparency, and Reduce Motion; test keyboard traversal and VoiceOver; and inspect the fixed-width panel and Settings at larger accessibility text sizes for clipping or loss of hierarchy.
