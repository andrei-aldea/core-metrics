#!/bin/bash
# Mechanical size exports only; the approved master owns the artwork.
set -euo pipefail
repo_root="$(cd "$(dirname "$0")/.." && pwd)"
master="$repo_root/docs/assets/Core-Metrics-AppIcon-Master.png"
catalog="$repo_root/Core Metrics/Assets.xcassets/AppIcon.appiconset"
for size in 16 32 128 256 512; do
    for scale in 1 2; do
        suffix=""
        if [[ "$scale" == 2 ]]; then suffix="@2x"; fi
        pixels=$((size * scale))
        sips --resampleHeightWidth "$pixels" "$pixels" "$master" \
            --out "$catalog/AppIcon-$size$suffix.png" >/dev/null
    done
done
if [[ $# -gt 0 ]]; then
    website_root="$1"
    test -f "$website_root/package.json"
    test -d "$website_root/public/images"
    test -d "$website_root/src/app"
    cp "$catalog/AppIcon-512.png" "$website_root/public/images/app-icon.png"
    cp "$catalog/AppIcon-32@2x.png" "$website_root/src/app/icon.png"
fi
printf 'Exported all ten macOS icon slots from the approved master.\n'
