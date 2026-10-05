# Core Metrics brand

Core Metrics is a quiet native Mac utility for current CPU, memory and startup-volume readings. The artwork should be recognizable; the interface should give the readings the space.

- **Name:** Core Metrics in the app and website. The existing store discovery name is Core Metrics: Mac Stats. Use the same capitalization; no additional product names or invented performance claims.
- **Mark:** three silver metric pillars on graphite, medium / tall / short from left to right. Preserve their order, proportions and surrounding space. The approved source is [the master PNG](assets/Core-Metrics-AppIcon-Master.png). Do not redraw the mark with a chart-library icon, add a pulse line, recolor the pillars or place text inside it.
- **Palette:** neutral graphite and silver. The website uses `#242629` on `#fafafa` in light appearance, `#f5f5f7` on `#111214` in dark appearance, and the existing accessible blue for interactive controls. The app uses macOS semantic colors and the person's system accent.
- **Typography:** installed system fonts. Product headings and the wordmark use restrained semibold weight; live numbers use tabular digits. The native status text stays 12 points in every mode. No font files or SF Symbols artwork are redistributed to the web.
- **Presentation:** macOS supplies the icon mask and native chrome. Website icon tiles use a consistent 22% corner radius. Use 36-pixel navigation/footer tiles and 48-pixel closing tiles. Shared-link previews use the unmodified square 512-pixel app icon. Decorative copies beside the product name have empty alternative text.
- **Product truth:** the status bar shows readings or category symbols, not a logo. The website's interactive illustration remains labeled as a demo with sample values. Actual App Store screenshots must come from the shipping app.

## Exports

Run `bash scripts/export-brand-assets.sh ../core-metrics-website` from the native repository. This resizes the same approved master into all ten macOS catalog slots and copies the 512-pixel website icon and 64-pixel favicon. It does not run during an app build. Equal pixel dimensions still serve distinct 1×/2× catalog slots and must be retained.

Following the publisher's October 5 preference, Open Graph and Twitter previews in both website languages use that same 512-pixel icon directly, with localized alternative text. Preserve its exact PNG bytes; add no headline, release text, frame or crop. The legacy social-image URLs also return the icon and must be revalidated, not cached as immutable assets.

## Artwork provenance

On October 3, 2026, the built-in ImageGen tool refined the existing original raster artwork. The generated source was normalized to a 1024 × 1024 opaque PNG; all shipping sizes are mechanical exports. The source is outside app target membership. No third-party logo, Apple hardware drawing or SF Symbol was used in the mark. This records how the artwork was made; it does not assert trademark registration or exclusive rights in generated artwork.

The refinement brief (abridged from the generation prompt) was: “Refine this existing Core Metrics app icon for final macOS app and website branding. Preserve exactly three upright silver capsule-shaped metric pillars, left medium height, center tallest, right shortest, equal widths and gaps, centered as a group on charcoal. Remove grain and mottled texture; use smooth crisp silhouettes, balanced optical spacing, restrained silver shading and a subtle neutral graphite background. Keep the silver legible at 16 pixels. No exaggerated 3D, extra marks, text, chart axes, reflections, Apple logo or watermark. Use a fully opaque full-bleed square, generous clear space and no rounded outer mask.”

Apple accepts an asset-catalog icon carried in the uploaded build; it is not a separate App Store Connect image upload. Verify the processed build and selected public candidate visually. [Apple icon delivery](https://developer.apple.com/help/app-store-connect/manage-app-information/add-an-app-icon/), [design guidance](https://developer.apple.com/design/human-interface-guidelines/app-icons/).
