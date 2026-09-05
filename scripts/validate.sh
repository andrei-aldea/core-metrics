#!/bin/bash
# Compatible with the Bash 3.2 supplied by macOS. Build output stays local.
set -u
set -o pipefail
umask 077

usage() {
    cat <<'USAGE'
Usage: scripts/validate.sh [--ui] [--output-root DIRECTORY] [--help]

Validate the macOS app with the selected Xcode (27+), macOS SDK (27+),
and Swift compiler (6+) on macOS 27+ / Apple silicon.

Default: inspect configuration, resolve dependencies, build Debug, run unit
tests, build Release, analyze, verify packaged metadata and Release isolation,
then check working/staged diffs. Builds are unsigned.

--ui                  Also run ad-hoc signed native UI tests serially after
                      the other checks. Requires an interactive desktop and
                      existing automation permissions; tests close earlier
                      instances of this app.
--output-root DIR     Existing directory outside the checkout. Each run gets
                      a new private subdirectory. Default: ${TMPDIR:-/tmp}.
--help                Show this help without invoking Xcode.

Raw logs, resolved settings, products and test results remain in the run
directory. Nothing is deleted, archived for distribution, signed with a
publisher identity, uploaded, or committed. Existing Xcode selection and
signing/project configuration are not changed. Respect DEVELOPER_DIR when
selecting an already installed Xcode for this invocation.

Failed commands or checks return nonzero. Unexpected warning lines also fail
validation. The known AppIntents metadata-skipped warning is counted and
reported as an outstanding toolchain limitation, without suppression.
USAGE
}

with_ui=0
output_root=${TMPDIR:-/tmp}
while [ "$#" -gt 0 ]; do
    case "$1" in
        --ui) with_ui=1; shift ;;
        --output-root)
            if [ "$#" -lt 2 ] || [ -z "$2" ]; then
                printf '%s\n' 'Missing directory for --output-root.' >&2
                exit 2
            fi
            output_root=$2
            shift 2
            ;;
        --help|-h) usage; exit 0 ;;
        *) printf 'Unknown argument: %s\n' "$1" >&2; usage >&2; exit 2 ;;
    esac
done

script_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P) || exit 2
repo_root=$(CDPATH= cd -- "$script_dir/.." && pwd -P) || exit 2
if [ ! -d "$output_root" ]; then
    printf '%s\n' '--output-root must be an existing directory outside the checkout.' >&2
    exit 2
fi
output_root=$(CDPATH= cd -- "$output_root" && pwd -P) || exit 2
case "$output_root/" in
    "$repo_root/"*) printf '%s\n' 'Refusing to store validation artifacts inside the checkout.' >&2; exit 2 ;;
esac
run_dir=$(mktemp -d "$output_root/core-metrics-validation.XXXXXX") || exit 2
logs_dir="$run_dir/logs"
mkdir "$logs_dir" || exit 2
summary="$run_dir/summary.tsv"
printf 'step\tresult\texit_code\n' > "$summary"
printf 'Validation artifacts: %s\n' "$run_dir"

project="$repo_root/Core Metrics.xcodeproj"
source_privacy="$repo_root/Core Metrics/PrivacyInfo.xcprivacy"
source_entitlements="$repo_root/Core Metrics/Core_Metrics.entitlements"
derived_data="$run_dir/DerivedData"
ui_data="$run_dir/UIData"
helper="$script_dir/validate-artifacts.swift"
destination='platform=macOS,arch=arm64'

run_step() {
    local name=$1
    shift
    local log="$logs_dir/$name.log"
    local code=0
    printf '[RUN] %s\n' "$name"
    {
        printf 'Command: '
        printf '%q ' "$@"
        printf '\n\n'
        "$@"
    } > "$log" 2>&1 || code=$?
    if [ "$code" -eq 0 ]; then
        printf '[PASS] %s\n' "$name"
        printf '%s\tPASS\t0\n' "$name" >> "$summary"
    else
        printf '[FAIL] %s (exit %s); see its local log.\n' "$name" "$code" >&2
        printf '%s\tFAIL\t%s\n' "$name" "$code" >> "$summary"
    fi
    return "$code"
}

finish() {
    local result=$?
    local known_warnings other_warnings display_diagnostics
    trap - EXIT
    if [ -f "$run_dir/inputs.sha256" ]; then
        run_step configuration-unchanged shasum -a 256 -c "$run_dir/inputs.sha256" || result=1
    fi
    run_step git-diff-check git -C "$repo_root" diff --check || result=1
    run_step git-staged-diff-check git -C "$repo_root" diff --cached --check || result=1
    known_warnings=$(awk '/warning:.*Metadata extraction skipped, no AppIntents.framework dependency found/ { n++ } END { print n+0 }' "$logs_dir"/*.log)
    other_warnings=$(awk '/warning:/ && !/Metadata extraction skipped, no AppIntents.framework dependency found/ { n++ } END { print n+0 }' "$logs_dir"/*.log)
    display_diagnostics=$(awk '/Could not find any displays containing rect/ { n++ } END { print n+0 }' "$logs_dir"/*.log)
    if [ "$other_warnings" -gt 0 ]; then
        result=1
    fi
    {
        printf 'Known AppIntents warning lines: %s\n' "$known_warnings"
        printf 'Other warning lines: %s\n' "$other_warnings"
        printf 'DisplayManager rectangle diagnostic lines: %s\n' "$display_diagnostics"
        if [ "$known_warnings" -gt 0 ]; then
            printf '%s\n' 'AppIntents metadata extraction remains a toolchain limitation; recheck accepted stable Xcode.'
        fi
        if [ "$other_warnings" -gt 0 ]; then
            printf '%s\n' 'Unexpected warnings require review; validation fails without filtering them.'
        fi
        if [ "$display_diagnostics" -gt 0 ]; then
            printf '%s\n' 'DisplayManager diagnostics remain in raw UI logs; passing assertions do not resolve those diagnostics.'
        fi
        if [ "$result" -eq 0 ]; then
            printf '%s\n' 'Requested validation steps passed. Distribution signing and the wider runtime/release matrix remain separate.'
        else
            printf '%s\n' 'Validation failed or was interrupted. Consult summary.tsv and the raw step logs; later dependent steps may not have run.'
        fi
    } | tee "$run_dir/outcome.txt"
    printf 'Local results: %s\n' "$run_dir"
    exit "$result"
}
trap finish EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

require_major() {
    local description=$1 value=$2 minimum=$3
    case "$value" in
        ''|*[!0-9]*) printf 'Could not determine %s version.\n' "$description" >&2; return 1 ;;
    esac
    if [ "$value" -lt "$minimum" ]; then
        printf '%s %s or later is required.\n' "$description" "$minimum" >&2
        return 1
    fi
}

check_toolchain() {
    local tool xcode_version swift_version sdk_version host_version
    for tool in xcodebuild xcrun plutil git shasum awk sw_vers sysctl; do
        command -v "$tool" >/dev/null 2>&1 || { printf 'Required tool missing: %s\n' "$tool" >&2; return 1; }
    done
    [ "$(uname -s)" = Darwin ] || { printf '%s\n' 'macOS is required.' >&2; return 1; }
    [ "$(sysctl -n hw.optional.arm64)" = 1 ] || { printf '%s\n' 'Apple silicon is required by the macOS 27 deployment matrix.' >&2; return 1; }
    host_version=$(sw_vers -productVersion) || return 1
    xcode_version=$(xcodebuild -version) || return 1
    swift_version=$(xcrun swift --version) || return 1
    sdk_version=$(xcrun --sdk macosx --show-sdk-version) || return 1
    printf 'macOS %s\n%s\n%s\nmacOS SDK %s\n' "$host_version" "$xcode_version" "$swift_version" "$sdk_version"
    require_major macOS "${host_version%%.*}" 27 || return 1
    require_major Xcode "$(printf '%s\n' "$xcode_version" | awk '/^Xcode / { split($2, v, "."); print v[1]; exit }')" 27 || return 1
    require_major Swift "$(printf '%s\n' "$swift_version" | awk '{ for (i=1; i<NF; i++) if ($i == "version") { split($(i+1), v, "."); print v[1]; exit } }')" 6 || return 1
    require_major 'macOS SDK' "${sdk_version%%.*}" 27 || return 1
    git -C "$repo_root" rev-parse --is-inside-work-tree || return 1
    printf '%s\n' 'Tool availability does not establish App Store acceptance of this Xcode version.'
}

record_inputs() {
    shasum -a 256 "$project/project.pbxproj" "$source_entitlements" "$source_privacy" > "$run_dir/inputs.sha256"
}

capture_settings() {
    local configuration=$1
    local code=0
    xcodebuild -project "$project" -scheme 'Core Metrics' -configuration "$configuration" \
        -destination "$destination" -derivedDataPath "$derived_data" \
        CODE_SIGNING_ALLOWED=NO -showBuildSettings -json > "$run_dir/$configuration-settings.json" || code=$?
    # Preserve stdout in the raw step log as well, including any diagnostics
    # that would make the structured settings file unparseable.
    cat "$run_dir/$configuration-settings.json"
    return "$code"
}

capture_ui_entitlements() {
    codesign --display --entitlements - --xml "$ui_data/Build/Products/Debug/Core Metrics.app" \
        > "$run_dir/ui-entitlements.plist"
}

run_step toolchain check_toolchain || exit 1
run_step input-fingerprints record_inputs || exit 1
run_step source-plist-syntax plutil -lint "$project/project.pbxproj" "$source_privacy" "$source_entitlements" || exit 1
run_step source-policy xcrun swift -module-cache-path "$run_dir/SwiftModuleCache" "$helper" source "$repo_root" || exit 1
run_step project-list xcodebuild -list -project "$project" || exit 1
run_step dependencies xcodebuild -project "$project" -scheme 'Core Metrics' \
    -derivedDataPath "$derived_data" -clonedSourcePackagesDirPath "$run_dir/SourcePackages" \
    -resolvePackageDependencies || exit 1
run_step debug-settings capture_settings Debug || exit 1
run_step release-settings capture_settings Release || exit 1
run_step debug-build xcodebuild -project "$project" -scheme 'Core Metrics' -configuration Debug \
    -destination "$destination" -derivedDataPath "$derived_data" CODE_SIGNING_ALLOWED=NO build || exit 1
run_step unit-tests xcodebuild -project "$project" -scheme 'Core Metrics' -configuration Debug \
    -destination "$destination" -derivedDataPath "$derived_data" -resultBundlePath "$run_dir/UnitTests.xcresult" \
    CODE_SIGNING_ALLOWED=NO test || exit 1
run_step release-build xcodebuild -project "$project" -scheme 'Core Metrics' -configuration Release \
    -destination "$destination" -derivedDataPath "$derived_data" CODE_SIGNING_ALLOWED=NO build || exit 1
run_step analyze xcodebuild -project "$project" -scheme 'Core Metrics' -configuration Debug \
    -destination "$destination" -derivedDataPath "$derived_data" CODE_SIGNING_ALLOWED=NO analyze || exit 1
run_step packaged-plist-syntax plutil -lint \
    "$derived_data/Build/Products/Debug/Core Metrics.app/Contents/Info.plist" \
    "$derived_data/Build/Products/Debug/Core Metrics.app/Contents/Resources/PrivacyInfo.xcprivacy" \
    "$derived_data/Build/Products/Release/Core Metrics.app/Contents/Info.plist" \
    "$derived_data/Build/Products/Release/Core Metrics.app/Contents/Resources/PrivacyInfo.xcprivacy" || exit 1
run_step packaged-policy xcrun swift -module-cache-path "$run_dir/SwiftModuleCache" "$helper" \
    artifacts "$repo_root" "$run_dir" || exit 1

if [ "$with_ui" -eq 1 ]; then
    run_step ui-tests xcodebuild -project "$project" -scheme 'Core Metrics UI Tests' -configuration Debug \
        -destination "$destination" -derivedDataPath "$ui_data" -resultBundlePath "$run_dir/UITests.xcresult" \
        -parallel-testing-enabled NO CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=YES test || exit 1
    run_step ui-entitlements capture_ui_entitlements || exit 1
    run_step ui-entitlements-syntax plutil -lint "$run_dir/ui-entitlements.plist" || exit 1
    run_step ui-sandbox xcrun swift -module-cache-path "$run_dir/SwiftModuleCache" "$helper" \
        ui "$run_dir/ui-entitlements.plist" || exit 1
else
    printf '[SKIP] Native UI tests (request --ui to run them).\n'
    printf 'ui-tests\tSKIP\t0\n' >> "$summary"
fi
exit 0
