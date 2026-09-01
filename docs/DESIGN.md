# Design

Core Metrics should feel like a restrained, independent macOS utility: dense enough to scan quickly, calm enough to live in the menu bar all day.

## Principles

- The menu bar shows only the enabled metrics and never the full app name.
- The dashboard uses one clear vertical hierarchy instead of a webpage-like grid of decorative cards.
- Live numbers use monospaced digits, locale-aware formatting, and useful precision.
- System typography, semantic colors, native controls, SF Symbols, separators, progress indicators, and Swift Charts are preferred.
- CPU, memory, and storage have stable semantic accents, but labels and values always communicate meaning without color.
- Motion is subtle and never forces a one-second animation loop. Reduce Motion removes nonessential transitions.
- Native Liquid Glass is reserved for platform chrome and interactive hierarchy where supported. Older systems use their native material/control behavior, not a hand-built glass imitation.

## Dashboard hierarchy

- CPU: total utilization, quiet history line, and user/system/idle breakdown.
- Memory: used percentage, used/available/total values, and quiet history line.
- Storage: startup volume usage with used/available/total and a native progress treatment.

## Accessibility checks

Every metric group provides a combined VoiceOver description, charts provide useful summaries instead of noisy point-by-point focus, controls use visible labels and native focus behavior, and the layout remains readable under Increased Contrast, Reduce Transparency, and larger accessibility text settings.
