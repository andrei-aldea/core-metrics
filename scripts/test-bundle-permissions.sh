#!/bin/bash
# Regression fixtures for permissions that can pass codesign but fail upload.
set -euo pipefail
umask 077

script_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/core-metrics-permissions.XXXXXX")
# This directory contains only fixtures created by this invocation.
trap 'rm -rf -- "$test_dir"' EXIT
app="$test_dir/Fixture.app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/_CodeSignature"
cat > "$app/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict><key>CFBundleExecutable</key><string>Fixture</string></dict></plist>
PLIST
printf 'fixture\n' > "$app/Contents/MacOS/Fixture"
printf 'signature resource fixture\n' > "$app/Contents/_CodeSignature/CodeResources"
chmod 755 "$app" "$app/Contents" "$app/Contents/MacOS" "$app/Contents/_CodeSignature"
chmod 644 "$app/Contents/Info.plist" "$app/Contents/_CodeSignature/CodeResources"
chmod 755 "$app/Contents/MacOS/Fixture"

verify() {
    xcrun swift -module-cache-path "$test_dir/ModuleCache" \
        "$script_dir/validate-artifacts.swift" permissions "$app" > "$test_dir/result.log" 2>&1
}

expect_failure() {
    local expected=$1
    if verify; then
        printf '%s\n' 'Permission regression: invalid fixture was accepted.' >&2
        exit 1
    fi
    if ! /usr/bin/grep -Fq "$expected" "$test_dir/result.log"; then
        cat "$test_dir/result.log" >&2
        exit 1
    fi
}

verify || { cat "$test_dir/result.log" >&2; exit 1; }
chmod 600 "$app/Contents/_CodeSignature/CodeResources"
expect_failure 'App bundle files must be readable by all users.'
chmod 644 "$app/Contents/_CodeSignature/CodeResources"
chmod 700 "$app/Contents/_CodeSignature"
expect_failure 'App bundle directories must be readable and traversable by all users.'
chmod 755 "$app/Contents/_CodeSignature"
chmod 644 "$app/Contents/MacOS/Fixture"
expect_failure 'App bundle executable must be executable by all users.'
chmod 755 "$app/Contents/MacOS/Fixture"
verify || { cat "$test_dir/result.log" >&2; exit 1; }
printf '%s\n' 'Bundle permission regression checks passed: valid, unreadable signature resource, inaccessible directory, nonexecutable binary, restored bundle.'
