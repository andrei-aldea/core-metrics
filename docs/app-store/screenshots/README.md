# Mac App Store screenshots

## Current build-9 replacement set — 12 October 2026

The three current `01-settings.jpg`, `02-metric-help.jpg` and `03-preferences.jpg` exports are now **1280×800 opaque JPEG compositions of genuine signed Release 1.0 (9) captures**. They preserve the existing Settings → Metric Help → Preferences order. The third image now shows actual Version 1.0 (9) and the confirmed 2026 publisher copyright. The images are prepared and visually inspected locally; uploading them to the listing and verifying remote rendering/order remain separate steps.

Source `401f9c2363bb1846a2ae376d7c7b877f49a4cab0` was archived, strictly verified, Apple-validated and uploaded. The unmodified signed archive app was opened separately using its distribution bundle identifier; the ordinary development app remained running. Capture used Settings opening/scrolling and Metric Help only. No preference/login/copy/mail control or system appearance changed; Help dismissed with Escape and the owned candidate quit normally. The binary/signature were rechecked unchanged. Raw Settings captures are 1160×1064; Help is 960×920. [Exact hashes and provenance](provenance-build9.json) cover sources and exports. No source capture was re-signed, retouched, synthesized or made with DEBUG fixtures.

The HTML/CSS method described below is unchanged and truthfully distinguishes native window pixels from the store marketing canvas. All earlier build-8/build-5 source images remain preserved; old exported compositions remain in Git history and uploaded assets remain in Apple’s library.

## Historical build-8 preparation and upload

Three English screenshots prepared 12 October 2026 from the real **Core Metrics 1.0 (8)** distribution archive:

1. `01-settings.jpg` — native Settings at the current default CPU User selection, with a live reading and all four display choices.
2. `02-metric-help.jpg` — native Metric Help with CPU and memory definitions and its real Done control.
3. `03-preferences.jpg` — the same Settings window scrolled to Startup, Help and Preferences, including the new reset explanation.

All exports are **1280 × 800, opaque JPEGs**. They are marketing compositions of genuine native captures, not claims that the native window itself has those dimensions. Upload, remote rendering and persisted ordering were verified in App Store Connect on 12 October, as recorded below. No screenshot uses Debug fixtures or website sample readings.

## Build-8 provenance and reproduction

`source/settings-build8-real.png`, `source/metric-help-build8-real.png` and `source/preferences-build8-real.png` are unmodified Computer Use screenshots saved directly from the running build-8 archive app on 12 October. The executable SHA-256 is `cf44975d2ea1e92047469a44a0ac2891c6309614058a62749cc1a78e336441ea`, from archived source `df1e22607892b5829f5887d8f80d4e94fe3f8dad`. No copy was re-signed and the archive was not rebuilt or modified. Strict signature/package checks and Apple validation/upload completed before capture. Raw Settings images are 1160 × 1064; Metric Help is 960 × 920. Actual live readings, native text, current appearance and controls are preserved.

The ordinary development app remained running under its original process and different bundle identifier. Only the owned distribution instance was opened and quit. No selection/display preference, clipboard, Launch at Login registration or system appearance was changed; the capture only opened Settings/Help/Privacy and scrolled. The initial Computer Use connection timed out, a bounded retry recovered, and one attempt to raise/resize the window returned noWindowsAvailable; reconnection recovered the same unchanged window geometry. These tool limitations are not a claim of an app crash. Metric Help content/Done and Privacy scrolling/Escape were visually checked, including the privacy email action; no email or browser link was opened. This targeted dark-appearance capture does not establish full VoiceOver, menu geometry, login-cycle, sleep/wake or installed-TestFlight acceptance.

The HTML files and CSS retain the shared graphite/silver brand. Settings compositions crop the native title bar by approximately 65 source pixels; the top view additionally stops before the partially visible Startup section. Metric Help retains the entire captured sheet and Done control. Rounded viewport masks exclude only outside-window corner pixels. Uniform CSS scaling fits the real captures into the artwork; no app UI, reading, text, control or translation is synthesized, stitched or retouched. Each composition references the canonical `docs/assets/Core-Metrics-AppIcon-Master.png`.

To reproduce, serve the repository’s `docs` directory on localhost and open each `/app-store/screenshots/` HTML file in a browser at **1280 × 800**, device scale factor 1. Wait for local images and fonts, then capture a full-page JPEG. Local file URLs are also supported; there are no remote resources, scripts or added dependencies. Verify dimensions, opacity, sharp text and complete pictured controls before replacement upload.

[Apple screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications), checked 12 October, accept 1280 × 800 for Mac apps. A third image or app preview is optional. These assets do not establish public-release readiness.

## Historical build-5 assets

The older `source/settings-real.jpg` and `source/metric-help-real.jpg` remain preserved as the 4 October build-5 source captures. The previous two compositions were confirmed persisted in Settings → Metric Help order on 8 October. That observation does not establish upload of the new build-8 artwork.

## App Store Connect follow-up — 12 October

The old Safari tab initially stalled before screenshot work; a fresh tab recovered account access. All three JPEGs above uploaded successfully. The temporary five-image old/new set was cleared through the version-association removal control, which explicitly retains assets in Asset Library, then the three current files were attached in order. Each image rendered completely in Apple’s remote viewer and was visually inspected, including the current Restore Defaults explanation in Preferences. A fresh 12 October reload confirms **3 of 10** in exact order: **01-settings.jpg → 02-metric-help.jpg → 03-preferences.jpg**. Earlier assets and local source captures remain preserved. This verifies the prepared listing media, not a public App Store submission or release.
