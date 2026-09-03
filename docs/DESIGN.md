# Design

Core Metrics should feel like a restrained macOS utility: fast to scan, calm enough to live in the menu bar all day, and visibly native rather than styled like a web dashboard.

## Principles

- The menu bar shows only the enabled metrics and never an app icon or the full app name.
- The status item uses locale-aware formatting, a monospaced system design, useful precision, and reserved width so ordinary updates do not move adjacent stats.
- System typography, semantic monochrome colors, aligned native controls, SF Symbols, separators, and platform spacing establish hierarchy.
- The interface contains no charts, decorative graphs, progress visualizations, colored status coding, branded cards, or imitation menu rows.
- Samples update without a forced animation loop, so Reduce Motion needs no alternate continuous-animation path.
- macOS owns Liquid Glass on the status panel and Settings window chrome. Core Metrics does not stack blur materials or draw a decorative glass replica behind data.

## Menu bar and status panel

- The status item is one complete text value. This avoids partial rendering of a composed hierarchy and keeps every chosen stat visible when menu-bar space permits.
- People can select one to seven stats. Their display order always follows the panel's CPU → Memory → Storage order rather than click order. Each formatted value reserves a seven-character column inside a fixed-width monospaced frame; Label and Value, Value Only, and Compact remain the only representations.
- The system-presented window-style `MenuBarExtra` stays open while checkboxes are changed, unlike a transient pull-down menu. It receives the platform's Liquid Glass presentation automatically.
- The panel begins directly with the CPU section, followed by Memory, Storage, a display-style picker, About, Settings, and Quit.
- Panel controls show stat names and selection state only. Live numbers appear in the status item, never duplicated beside selection controls.
- There is no application icon, branded header, live badge, chart, or custom card in the panel.

The Settings window has a useful minimum size. It offers the exact live status-text preview, removal controls, a native add menu, display-mode selection, and Restore Defaults.

## Failure behavior

When a provider is unavailable, its status-item slot shows an em dash rather than retaining a stale number, and sampling retries automatically. Initial CPU delta collection uses the same neutral placeholder without being treated as a failure. If only the swap read fails, Memory Used and Cached Files remain available while Swap Used alone shows the placeholder.

## Accessibility checks

The status item exposes one combined VoiceOver label and value summary. Selection controls have explicit add/remove hints. Native controls retain system keyboard behavior, and labels never rely on color alone.

Before release, verify the running app in light and dark appearance, Increased Contrast, Reduce Transparency, and Reduce Motion. Test repeated checkbox changes without panel dismissal, keyboard traversal, VoiceOver, all three status-text modes, one-to-seven selections, canonical ordering, constrained menu-bar space, and Settings at larger accessibility text sizes.
