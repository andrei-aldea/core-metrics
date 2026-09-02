# App Icon

Core Metrics uses an original, flattened macOS app icon selected through the `AppIcon` asset catalog. The strictly monochrome mark uses three aggregate-metric pillars in neutral gray on charcoal, with no graph line, endpoint dot, decorative ribbon, text, third-party mark, or baked-in system mask. Its simple silhouette is designed to remain recognizable at the 16-pixel menu/Finder scale.

## Sources

- Editable generation master: `docs/assets/Core-Metrics-AppIcon-Master.png` at 1024 × 1024.
- Shipping variants: `Core Metrics/Assets.xcassets/AppIcon.appiconset` at every macOS 1× and 2× size from 16 through 512 points.
- Xcode build setting: `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon` for Debug and Release.

The asset catalog route is a supported flattened-icon workflow. Icon Composer is installed with the current beta Xcode but requires its own first-run agreement. That agreement was intentionally left for the publisher to review and accept. If layered effects are desired before submission, import or recreate the retained master in Icon Composer and compare the result at every system-provided appearance.

## Generation prompt

The built-in image generation tool received this prompt:

> Use case: precise-object-edit. Asset type: 1024 × 1024 master artwork for the native macOS 27 Core Metrics app icon. Use the existing icon as the edit target. Remove the entire rising pulse curve and its endpoint dot. Convert the icon to a strictly neutral monochrome grayscale design. Preserve the recognizable three rounded vertical metric pillars and their overall proportions, spacing, centered composition, and strong silhouette. Simplify each pillar to a clean solid or extremely subtle neutral-gray tonal treatment; remove the colored diagonal ribbon highlights inside the pillars. Use a full-bleed neutral charcoal-to-black grayscale background with no blue, green, cyan, or other chromatic tint. Keep all important artwork inside the central 70% with generous edge padding and no pre-rendered rounded-square border or outer system mask. Include no line crossing the pillars, dot, text, letters, numbers, trademarks, watermark, extra symbols, tiny details, glow, colored lighting, or drop shadow. Do not add new objects.

Before release, verify the final icon in Finder, System Settings, Spotlight, and the App Store upload preview using the stable Xcode required by App Store Connect.
