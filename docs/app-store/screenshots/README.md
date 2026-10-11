# Mac App Store screenshots

Three English screenshots prepared 12 October 2026 from the real **Core Metrics 1.0 (8)** distribution archive:

1. `01-settings.jpg` — native Settings at the current default CPU User selection, with a live reading and all four display choices.
2. `02-metric-help.jpg` — native Metric Help with CPU and memory definitions and its real Done control.
3. `03-preferences.jpg` — the same Settings window scrolled to Startup, Help and Preferences, including the new reset explanation.

All exports are **1280 × 800, opaque JPEGs**. They are marketing compositions of genuine native captures, not claims that the native window itself has those dimensions. Upload and persisted ordering must be verified separately in App Store Connect. No screenshot uses Debug fixtures or website sample readings.

## Build-8 provenance and reproduction

`source/settings-build8-real.png`, `source/metric-help-build8-real.png` and `source/preferences-build8-real.png` are unmodified Computer Use screenshots saved directly from the running build-8 archive app on 12 October. The executable SHA-256 is `cf44975d2ea1e92047469a44a0ac2891c6309614058a62749cc1a78e336441ea`, from archived source `df1e22607892b5829f5887d8f80d4e94fe3f8dad`. No copy was re-signed and the archive was not rebuilt or modified. Strict signature/package checks and Apple validation/upload completed before capture. Raw Settings images are 1160 × 1064; Metric Help is 960 × 920. Actual live readings, native text, current appearance and controls are preserved.

The ordinary development app remained running under its original process and different bundle identifier. Only the owned distribution instance was opened and quit. No selection/display preference, clipboard, Launch at Login registration or system appearance was changed; the capture only opened Settings/Help/Privacy and scrolled. The initial Computer Use connection timed out, a bounded retry recovered, and one attempt to raise/resize the window returned noWindowsAvailable; reconnection recovered the same unchanged window geometry. These tool limitations are not a claim of an app crash. Metric Help content/Done and Privacy scrolling/Escape were visually checked, including the privacy email action; no email or browser link was opened. This targeted dark-appearance capture does not establish full VoiceOver, menu geometry, login-cycle, sleep/wake or installed-TestFlight acceptance.

The HTML files and CSS retain the shared graphite/silver brand. Settings compositions crop the native title bar by approximately 65 source pixels; the top view additionally stops before the partially visible Startup section. Metric Help retains the entire captured sheet and Done control. Rounded viewport masks exclude only outside-window corner pixels. Uniform CSS scaling fits the real captures into the artwork; no app UI, reading, text, control or translation is synthesized, stitched or retouched. Each composition references the canonical `docs/assets/Core-Metrics-AppIcon-Master.png`.

To reproduce, serve the repository’s `docs` directory on localhost and open each `/app-store/screenshots/` HTML file in a browser at **1280 × 800**, device scale factor 1. Wait for local images and fonts, then capture a full-page JPEG. Local file URLs are also supported; there are no remote resources, scripts or added dependencies. Verify dimensions, opacity, sharp text and complete pictured controls before replacement upload.

[Apple screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications), checked 12 October, accept 1280 × 800 for Mac apps. A third image or app preview is optional. These assets do not establish public-release readiness.

## Historical build-5 assets

The older `source/settings-real.jpg` and `source/metric-help-real.jpg` remain preserved as the 4 October build-5 source captures. The previous two compositions were confirmed persisted in Settings → Metric Help order on 8 October. That observation does not establish upload of the new build-8 artwork.

## App Store Connect follow-up — 12 October

The current public draft still showed the two older images in Settings → Metric Help order. No old asset was removed. Safari stalled during the separate build-8 association reload, before a screenshot upload could be attempted. The three new JPEGs above are ready but their upload, processing and persisted order remain unverified.
