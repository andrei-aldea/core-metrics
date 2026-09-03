# Design

Core Metrics should feel like a restrained macOS utility: fast to scan, calm enough to live in the menu bar all day, and visibly native rather than styled like a web dashboard.

## Principles

- The menu bar shows only the enabled metrics and never an app icon or the full app name.
- The status item uses locale-aware formatting, a monospaced system design, useful precision, and reserved width so ordinary updates do not move adjacent stats.
- System typography, semantic monochrome colors, aligned native controls, SF Symbols, separators, and platform spacing establish hierarchy.
- The interface contains no charts, decorative graphs, progress visualizations, colored status coding, branded cards, or imitation menu rows.
- Samples update without a forced animation loop, so Reduce Motion needs no alternate continuous-animation path.
- macOS owns Liquid Glass on the status panel and window chrome. Core Metrics does not stack blur materials or draw a decorative glass replica behind data.

## Menu bar and status panel

- The status item is one complete text value. This avoids partial rendering of a composed hierarchy and keeps every chosen stat visible when menu-bar space permits.
- People can select and order one to five stats. Each formatted value reserves a five-character column; Label and Value, Value Only, and Compact remain the only representations.
- The system-presented window-style `MenuBarExtra` stays open while checkboxes are changed, unlike a transient pull-down menu. It receives the platform's Liquid Glass presentation automatically.
- The panel contains a clear Open Core Metrics action, the selected count, direct CPU/Memory/Storage checkboxes, a display-style picker, About, Settings, and Quit.
- Panel controls show stat names and selection state only. Live numbers appear in the status item and detailed window, never duplicated beside selection controls.
- There is no application icon, branded header, live badge, chart, or custom card in the panel.

## Detailed window

The detailed window uses a grouped native `Form`, standard body text, trailing-aligned numeric values, and a 540 × 460 point minimum content size. Its three sections contain exactly:

- CPU: User, System, and Idle percentages.
- Memory: Memory Used, Cached Files, and Swap Used byte values.
- Startup Disk: Free Space, Used Space, and Total Capacity byte values.

The Settings window also has a useful minimum size. It offers the exact live status-text preview, ordering and removal controls, a native add menu, display-mode selection, and Restore Defaults.

## Failure behavior

When a provider is unavailable, its status item and detail rows show an em dash rather than retaining stale numbers. The affected detailed section explains that the read is temporary and retries automatically. Initial CPU delta collection has a separate neutral collecting state. If only the swap read fails, Memory Used and Cached Files remain available while Swap Used alone shows the placeholder.

## Accessibility checks

Every numeric row exposes a combined VoiceOver label and value. Selection controls have explicit add/remove hints; ordering buttons have action labels and help. Native controls retain system keyboard behavior, and labels never rely on color alone.

Before release, verify the running app in light and dark appearance, Increased Contrast, Reduce Transparency, and Reduce Motion. Test repeated checkbox changes without panel dismissal, keyboard traversal, VoiceOver, all three status-text modes, one-to-five selections, constrained menu-bar space, and both windows at larger accessibility text sizes.
