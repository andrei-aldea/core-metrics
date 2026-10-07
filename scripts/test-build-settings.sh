#!/bin/bash
# Ensure resolved concurrency drift is rejected before compiling the app.
set -euo pipefail
umask 077

script_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/core-metrics-build-settings.XXXXXX")
# This directory contains only fixtures created by this invocation.
trap 'rm -rf -- "$test_dir"' EXIT
# Compile once so each mutation exercises the same verifier without repeated
# Swift interpreter startup and compilation.
xcrun swiftc -warnings-as-errors -module-cache-path "$test_dir/ModuleCache" \
    "$script_dir/validate-artifacts.swift" -o "$test_dir/verify-settings" \
    > "$test_dir/compiler.log" 2>&1 \
    || { cat "$test_dir/compiler.log" >&2; exit 1; }

write_fixture() {
    local isolation=$1 approachable=$2
    cat > "$test_dir/settings.json" <<JSON
[{"target":"Core Metrics","buildSettings":{
"SWIFT_VERSION":"6.0","MACOSX_DEPLOYMENT_TARGET":"27.0",
"ENABLE_APP_SANDBOX":"YES","ENABLE_HARDENED_RUNTIME":"YES",
"SWIFT_STRICT_CONCURRENCY":"complete","SWIFT_TREAT_WARNINGS_AS_ERRORS":"YES",
"SWIFT_DEFAULT_ACTOR_ISOLATION":"$isolation","SWIFT_APPROACHABLE_CONCURRENCY":"$approachable",
"CODE_SIGNING_ALLOWED":"NO","CODE_SIGN_ENTITLEMENTS":"Core Metrics/Core_Metrics.entitlements"
}}]
JSON
}

verify() {
    "$test_dir/verify-settings" settings "$test_dir/settings.json" "$1" \
        > "$test_dir/result.log" 2>&1
}

expect_failure() {
    local configuration=$1 expected=$2
    if verify "$configuration"; then
        printf '%s\n' 'Build-settings regression: concurrency drift was accepted.' >&2
        exit 1
    fi
    if ! /usr/bin/grep -Fq "$expected" "$test_dir/result.log"; then
        cat "$test_dir/result.log" >&2
        exit 1
    fi
}

for configuration in Debug Release; do
    write_fixture MainActor YES
    verify "$configuration" || { cat "$test_dir/result.log" >&2; exit 1; }
    write_fixture nonisolated YES
    expect_failure "$configuration" SWIFT_DEFAULT_ACTOR_ISOLATION
    write_fixture '' YES
    expect_failure "$configuration" SWIFT_DEFAULT_ACTOR_ISOLATION
    write_fixture MainActor NO
    expect_failure "$configuration" SWIFT_APPROACHABLE_CONCURRENCY
    write_fixture MainActor ''
    expect_failure "$configuration" SWIFT_APPROACHABLE_CONCURRENCY
done
printf '%s\n' 'Build-settings regression checks passed: Debug/Release accept reviewed settings and reject disabled/empty default isolation and approachable concurrency.'
