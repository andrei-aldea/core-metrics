# Mac App Store screenshots

Two English screenshots prepared October 4, 2026 for **Core Metrics 1.0 (5)**:

1. `01-settings.jpg` — native Settings, three live CPU/Memory/Storage readings and all four display choices.
2. `02-metric-help.jpg` — native Metric Help with CPU and memory definitions and the real Done control.

Both exports are **1280 × 800, opaque JPEGs**. App Store Connect showed two uploaded screenshots; keyboard reordering placed Settings first. Apple then expired the session on reload, so a signed-in fresh-page persistence check remains required.

## Provenance and reproduction

`source/settings-real.jpg` and `source/metric-help-real.jpg` are Computer Use captures from a running copy of the distribution archive's app. Nonvisual EXIF/IPTC metadata was removed without changing the compressed image data. Its executable SHA-256 matched the original build-5 archive; no re-signing or debug fixtures were used. Actual live readings, native control text and focus indicators are preserved. The captures show only this app, with no account or personal desktop content. Review preferences were restored and the isolated copy was quit; the archive remains unchanged.

The HTML files and shared CSS frame the captures using the shared graphite/silver brand. CSS crops approximately 64 source pixels from Settings' title bar to omit the macOS window-sharing overlay, and 20 pixels from the Help capture's top plus its bottom margin to omit underlying window/cursor fragments. The layouts use viewport crops and uniform scaling; no app UI, reading, text, control or translation is synthesized or retouched. Both compositions reference the canonical `docs/assets/Core-Metrics-AppIcon-Master.png`; no duplicate brand master is maintained.

To reproduce, serve the repository’s `docs` directory on localhost, open each `/app-store/screenshots/` HTML file in a browser at 1280 × 800 and take a full-page JPEG screenshot after local images load. There are no remote resources, scripts or added dependencies. Do not use a default 1280 × 720 viewport export. Verify width, height, opacity, sharp text and complete visible controls before any replacement upload.

[Apple screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications) require 1–10 Mac screenshots at one of the permitted 16:10 sizes. A third image or app-preview video is optional. These images do not establish installed-TestFlight acceptance or complete the broader accessibility/runtime matrix.
