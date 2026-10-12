# Build 9 marketing pack — 12 October 2026

Three English **2560×1600 opaque sRGB PNGs** form the replacement pack. Open [preview.html](preview.html) to compare the panels, or inspect the full-resolution exports individually:

| Order | Benefit | Genuine native source |
| --- | --- | --- |
| [01 — Selection](exports/01-selection.png) | Keep the readings you need. | Fresh signed Release 9 Settings, three selected stats, visible Add Stat control. |
| [02 — Display styles](exports/02-styles.png) | Make your menu bar yours. | Four independent fresh signed Release 9 Settings captures: Label and Value, Compact, Icon and Value, Values Only. |
| [03 — Explanations](exports/03-explanations.png) | Know what the numbers mean. | Earlier 12 October signed Release 9 Metric Help sheet, reused unchanged with its original hash. |

The Silver `#e7e8ea` / Graphite `#17191c` canvas uses installed system typography and real dark-appearance app surfaces. Large benefit headings and short subtitles sit outside captured UI. Mac content is framed as native windows/details, never as a phone. The layout adapts the portfolio's deterministic AppKit renderer. Panel 1 removes the window title chrome; panel 2 crops the actual style controls and live previews; panel 3 retains the complete sheet and Done control. Crops are recorded in [artwork.json](artwork.json). Uniform placement never exceeds **one exported pixel per source pixel**. Rounded masks and shadows are outside the app-content treatment; no readings, labels, controls or UI state are synthesized or retouched.

## Source identity and provenance

The unmodified distribution archive is **1.0 (9)**, frozen source `401f9c2363bb1846a2ae376d7c7b877f49a4cab0`. Its executable SHA-256 is `5f291d829ddc933e2acf90ab622b4578c9f0de4007d6c867ccee51813847ac58`; strict signature validation passed before this capture. Current product/project files match the frozen source. No build/version, app resource, functionality or entitlement changed for artwork.

Four fresh Settings files were saved directly from the owned archive app's Computer Use window screenshots on 12 October. They are original JPEG bytes, each 1160×1064. The metric values naturally differ across the four capture times; the composition does not present them as simultaneous samples. The reused 960×920 Help source is byte-identical to `../source/metric-help-build9-real.jpg`, captured during the earlier build-9 delivery check. Its earlier capture session is recorded in [the historical manifest](../history/2026-10-12-window-compositions/provenance-build9.json), and is not relabeled as fresh.

[manifest.json](manifest.json) records every source/export hash, dimensions, source session, crop/scale behavior and tool identity. Original captures contain only app surfaces and aggregate readings; no computer name, serial, process list or unrelated app is pictured. The private capture checkpoint, automation runner, logs and result bundle remain ignored, not shipped or committed.

## Verification and limits

All three full-resolution renders were visually inspected locally and independently for complete copy, readable native controls, clipping and unrelated content. Mechanical checks validate hashes, JPEG source formats/dimensions, in-bounds crops, the three 2560×1600 8-bit RGB PNGs without alpha and renderer/config parity. A repeated render remained byte-identical for all three exports. All 93 frozen runtime/project/test/tooling inputs match both working files and Git; the signed archive still passes strict deep signature verification with its original executable hash. No new native build/test pass is needed for image-only composition.

The capture changed only the separately launched distribution app's selected readings and four display modes. **Cleanup completed after unlock on 12 October.** The coordinator bound Computer Use to the exact signed archive app, dismissed Privacy with Done, and confirmed the temporary three-stat selection, Label and Value, and Launch at Login off/unregistered. Removing Memory Used (%) produced a fresh two-stat readback; removing Storage Used (%) produced a fresh one-stat readback containing only CPU User. Label and Value and the login state remained unchanged. Normal Command-Q then closed only this owned distribution instance; Computer Use reported the process absent and a shell process check confirmed the ordinary development app remained at its original path. No clipboard copy, Launch at Login toggle, external link, browser/mail launch, appearance change or signed-app modification occurred.

A separately built attachment-only XCTest harness was prepared to capture the status item/selection panel without launching or terminating either app. Automation-mode initialization timed out before test execution and produced no app screenshots. Computer Use then reported the Mac locked; further native actions stopped. Rather than use older DEBUG material or repeat Settings into five panels, the pack contains three distinct, truthful concepts. Actual status-item/selector and Copy Readings panels remain optional future additions; the later successful preference cleanup did not add captures. This task does not establish installed-TestFlight, VoiceOver, complete menu geometry or minimum-OS acceptance.

**Later account delivery — 12 October:** all three unchanged PNGs uploaded through the authenticated in-app browser and persist after fresh app navigation as **3 of 10**, ordered **01-selection.png → 02-styles.png → 03-explanations.png**. The first two fully branded remote images were visually inspected; **the third is still processing**, so complete remote visual acceptance is pending. Public draft **9**, Save disabled and the existing automatic-release choice remain. The two earlier associations were removed recoverably while their originals remain in Asset Library. No Mac header, public submission or release occurred. [The active directory](../README.md) retains the earlier account-history boundary.

## Reproduction

From the repository root, with final Xcode selected per command:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift scripts/store-artwork/render.swift docs/app-store/screenshots/marketing-build9/artwork.json
python3 scripts/store-artwork/verify.py
```

No network, image generation, external font or third-party image library is required. The renderer refuses overflowing copy, invalid/out-of-bounds crops and the wrong number of Mac display-style details. The verifier rejects changed source/export pixels or a renderer/config change until the reviewed manifest is deliberately regenerated.
