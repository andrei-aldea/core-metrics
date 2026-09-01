# Design

Core Metrics should feel like a restrained, independent macOS utility: dense enough to scan quickly, calm enough to live in the menu bar all day.

## Principles

- The menu bar shows only the enabled metrics and never the full app name.
- The dashboard uses one clear vertical hierarchy instead of a webpage-like grid of decorative cards.
- Live numbers use monospaced digits, locale-aware formatting, and useful precision.
- System typography, semantic colors, native controls, SF Symbols, separators, progress indicators, and Swift Charts are preferred.
- One system accent color provides continuity across the header symbol, metric symbols, charts, and storage progress. CPU, memory, and storage remain distinguishable through labels, SF Symbols, values, and structure rather than separate colors.
- Live samples update without a forced one-second animation loop, so Reduce Motion requires no alternate continuous-animation path.
- Native Liquid Glass is reserved for platform chrome and interactive hierarchy where supported. Older systems use their native material/control behavior, not a hand-built glass imitation.

## Implemented visual system

- The native window-style menu-bar extra provides the top-level platform surface and automatically adopts the current macOS appearance. Core Metrics does not layer custom blur or decorative glass behind content.
- A compact header identifies the app and reports `Live`, `Limited`, or `Paused` using text and an SF Symbol, never color alone.
- CPU, memory, and storage are stacked in one scrollable column with full-width separators. There are no card grids, ornamental borders, or per-metric background treatments.
- The accent color is deliberately singular. It marks metric identity and data traces without turning the dashboard into a multicolor monitoring display.
- Secondary labels and status text use semantic foreground styles, so light, dark, Increased Contrast, and Reduce Transparency remain system-managed.
- The Settings window uses a grouped `Form`, native toggles, segmented and standard pickers, borderless reorder buttons, help text, and a standard restore action.

## Dashboard hierarchy

- CPU: total utilization, quiet history line, and user/system/idle breakdown.
- Memory: used percentage, used/available/total values, and quiet history line.
- Storage: startup volume usage with used/available/total and a native progress treatment.

When a live provider is unavailable, the primary value and detail rows display an unavailable state instead of retaining stale numbers. Valid chart history can remain visible as historical context, while the header's limited status makes the current sampling condition explicit.

## Accessibility checks

Every metric group provides visible text and a combined VoiceOver description. Charts are a single accessibility element that summarizes sample count, latest value, minimum, and maximum rather than exposing every point. Menu-bar values have explicit semantic descriptions, reorder buttons have action labels and help, and native controls retain standard keyboard focus behavior.

Before release, verify the running app in light and dark appearance, Increased Contrast, Reduce Transparency, and Reduce Motion; test keyboard traversal and VoiceOver; and inspect the fixed-width panel and Settings at larger accessibility text sizes for clipping or loss of hierarchy.
