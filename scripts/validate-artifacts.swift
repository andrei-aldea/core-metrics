// Native Foundation helper for validate.sh; no packages or project mutations.
import CoreFoundation
import Foundation

enum ValidationFailure: Error, CustomStringConvertible {
    case check(String)
    var description: String {
        switch self { case .check(let message): return message }
    }
}

func require(_ condition: Bool, _ message: String) throws {
    if !condition { throw ValidationFailure.check(message) }
}

func plist(_ url: URL) throws -> [String: Any] {
    let value = try PropertyListSerialization.propertyList(from: Data(contentsOf: url), format: nil)
    guard let dictionary = value as? [String: Any] else {
        throw ValidationFailure.check("Expected a property-list dictionary.")
    }
    return dictionary
}

func boolean(_ value: Any?, equals expected: Bool) -> Bool {
    guard let number = value as? NSNumber, CFGetTypeID(number) == CFBooleanGetTypeID() else { return false }
    return number.boolValue == expected
}

func verifyPrivacy(_ value: [String: Any]) throws {
    let permittedKeys: Set<String> = [
        "NSPrivacyAccessedAPITypes", "NSPrivacyCollectedDataTypes", "NSPrivacyTracking", "NSPrivacyTrackingDomains",
    ]
    try require(Set(value.keys).isSubset(of: permittedKeys), "Privacy manifest has unreviewed top-level keys.")
    try require(boolean(value["NSPrivacyTracking"], equals: false), "Privacy tracking must be false.")
    try require((value["NSPrivacyCollectedDataTypes"] as? [Any])?.isEmpty == true, "Collected-data declarations must be empty.")
    if let domains = value["NSPrivacyTrackingDomains"] {
        try require((domains as? [Any])?.isEmpty == true, "Tracking domains must be absent or empty.")
    }
    let expected = [
        "NSPrivacyAccessedAPICategoryDiskSpace": "85F4.1",
        "NSPrivacyAccessedAPICategoryUserDefaults": "CA92.1",
    ]
    guard let entries = value["NSPrivacyAccessedAPITypes"] as? [[String: Any]] else {
        throw ValidationFailure.check("Required Reason API declarations must be an array of dictionaries.")
    }
    try require(entries.count == expected.count, "Required Reason API category count changed; review actual use and policy.")
    var seen = Set<String>()
    for entry in entries {
        try require(Set(entry.keys) == ["NSPrivacyAccessedAPIType", "NSPrivacyAccessedAPITypeReasons"], "Required Reason API entry has unexpected keys.")
        guard let category = entry["NSPrivacyAccessedAPIType"] as? String,
              let reason = expected[category],
              let reasons = entry["NSPrivacyAccessedAPITypeReasons"] as? [String] else {
            throw ValidationFailure.check("Required Reason API category or reason has changed.")
        }
        try require(seen.insert(category).inserted && reasons == [reason], "Required Reason API declarations differ from reviewed local use.")
    }
}

func verifySourceHardening(_ root: URL) throws {
    let project = try plist(root.appendingPathComponent("Core Metrics.xcodeproj/project.pbxproj"))
    guard let objects = project["objects"] as? [String: [String: Any]] else {
        throw ValidationFailure.check("Source project objects are missing or malformed.")
    }
    let appTargets = objects.values.filter {
        $0["isa"] as? String == "PBXNativeTarget"
            && $0["name"] as? String == "Core Metrics"
            && $0["productType"] as? String == "com.apple.product-type.application"
    }
    guard appTargets.count == 1,
          let listID = appTargets[0]["buildConfigurationList"] as? String,
          let configurationIDs = objects[listID]?["buildConfigurations"] as? [String] else {
        throw ValidationFailure.check("Source app build configurations are missing or ambiguous.")
    }
    var names = Set<String>()
    for identifier in configurationIDs {
        guard let configuration = objects[identifier],
              let name = configuration["name"] as? String,
              let values = configuration["buildSettings"] as? [String: Any] else {
            throw ValidationFailure.check("Source app build configuration is malformed.")
        }
        try require(names.insert(name).inserted, "Source app has duplicate build configuration names.")
        try require(values["ENABLE_HARDENED_RUNTIME"] as? String == "YES", "Source app configuration must enable hardened runtime: \(name).")
    }
    try require(names == ["Debug", "Release"], "Source app must have the reviewed Debug and Release configurations.")
    print("Source app Debug and Release configurations both enable hardened runtime.")
}

func verifySource(_ root: URL) throws {
    try verifySourceHardening(root)
    let entitlements = try plist(root.appendingPathComponent("Core Metrics/Core_Metrics.entitlements"))
    try require(Set(entitlements.keys) == ["com.apple.security.app-sandbox"], "Source entitlements must contain only App Sandbox.")
    try require(boolean(entitlements["com.apple.security.app-sandbox"], equals: true), "Source App Sandbox entitlement must be true.")
    try verifyPrivacy(plist(root.appendingPathComponent("Core Metrics/PrivacyInfo.xcprivacy")))
    print("Source sandbox and reviewed privacy declarations verified.")
}

func settings(_ url: URL, configuration: String) throws -> [String: String] {
    guard let targets = try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [[String: Any]],
          let app = targets.first(where: { $0["target"] as? String == "Core Metrics" }),
          let values = app["buildSettings"] as? [String: String] else {
        throw ValidationFailure.check("Resolved app build settings are missing or malformed.")
    }
    let expected = [
        "SWIFT_VERSION": "6.0", "MACOSX_DEPLOYMENT_TARGET": "27.0",
        "ENABLE_APP_SANDBOX": "YES",
        "SWIFT_STRICT_CONCURRENCY": "complete", "SWIFT_TREAT_WARNINGS_AS_ERRORS": "YES",
        "CODE_SIGNING_ALLOWED": "NO",
    ]
    for (key, value) in expected {
        try require(values[key] == value, "Resolved setting differs from the reviewed configuration: \(key).")
    }
    if configuration == "Release" {
        try require(values["ENABLE_HARDENED_RUNTIME"] == "YES", "Resolved Release must enable hardened runtime.")
    } else {
        let hardening = values["ENABLE_HARDENED_RUNTIME"]
        try require(hardening == "YES" || hardening == "NO", "Resolved Debug hardened-runtime setting is missing or invalid.")
        if hardening == "NO" {
            print("Development/test limitation: Debug resolves ENABLE_HARDENED_RUNTIME=NO despite source YES. This does not validate runtime hardening; Release must resolve YES and its distribution signature still needs review.")
        }
    }
    try require(values["CODE_SIGN_ENTITLEMENTS"] == "Core Metrics/Core_Metrics.entitlements", "Resolved source entitlement path changed.")
    return values
}

func verifyBundle(_ bundle: URL, settings values: [String: String], sourcePrivacy: [String: Any]) throws {
    let info = try plist(bundle.appendingPathComponent("Contents/Info.plist"))
    for (key, setting) in [
        "CFBundleIdentifier": "PRODUCT_BUNDLE_IDENTIFIER",
        "CFBundleExecutable": "EXECUTABLE_NAME",
        "CFBundleVersion": "CURRENT_PROJECT_VERSION",
        "CFBundleShortVersionString": "MARKETING_VERSION",
        "LSMinimumSystemVersion": "MACOSX_DEPLOYMENT_TARGET",
    ] {
        guard let expected = values[setting], !expected.isEmpty else {
            throw ValidationFailure.check("Resolved metadata setting missing: \(setting).")
        }
        try require(info[key] as? String == expected, "Packaged metadata disagrees with resolved configuration: \(key).")
    }
    try require(info["CFBundlePackageType"] as? String == "APPL", "Packaged product must be a macOS application.")
    try require(info["LSApplicationCategoryType"] as? String == "public.app-category.utilities", "Packaged app category changed.")
    try require(boolean(info["LSUIElement"], equals: true), "Packaged app must remain a menu-bar agent.")
    try require(boolean(info["ITSAppUsesNonExemptEncryption"], equals: false), "Packaged encryption declaration changed.")
    try require(info["NSAppTransportSecurity"] == nil && info["CFBundleURLTypes"] == nil, "Unexpected networking or URL-handler metadata.")
    try require(!info.keys.contains(where: { $0.hasSuffix("UsageDescription") }), "Unexpected permission usage description.")
    let packagedPrivacy = try plist(bundle.appendingPathComponent("Contents/Resources/PrivacyInfo.xcprivacy"))
    try verifyPrivacy(packagedPrivacy)
    try require(NSDictionary(dictionary: sourcePrivacy).isEqual(to: packagedPrivacy), "Packaged privacy manifest differs from source.")
}

func verifyReleaseIsolation(_ bundle: URL) throws {
    guard let files = FileManager.default.enumerator(at: bundle, includingPropertiesForKeys: [.isRegularFileKey]) else {
        throw ValidationFailure.check("Cannot enumerate the Release app.")
    }
    let markers = [
        "CORE_METRICS_UI_", "UITestLaunchConfiguration", "UITestLaunchAtLoginService",
    ].map { Data($0.utf8) }
    for case let file as URL in files {
        try require(!["app", "appex", "xctest", "framework"].contains(file.pathExtension), "Release contains an unexpected nested bundle.")
        if try file.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile == true {
            try require(!file.lastPathComponent.hasSuffix(".debug.dylib"), "Release contains a Debug support library.")
            let data = try Data(contentsOf: file, options: .mappedIfSafe)
            try require(!markers.contains(where: { data.range(of: $0) != nil }), "Release contains a DEBUG UI-test marker.")
        }
    }
    print("Release app contains no known DEBUG UI-test markers or unexpected nested bundles.")
}

do {
    let arguments = Array(CommandLine.arguments.dropFirst())
    switch arguments.first {
    case "source" where arguments.count == 2:
        try verifySource(URL(fileURLWithPath: arguments[1], isDirectory: true))
    case "artifacts" where arguments.count == 3:
        let root = URL(fileURLWithPath: arguments[1], isDirectory: true)
        let run = URL(fileURLWithPath: arguments[2], isDirectory: true)
        try verifySource(root)
        let sourcePrivacy = try plist(root.appendingPathComponent("Core Metrics/PrivacyInfo.xcprivacy"))
        for configuration in ["Debug", "Release"] {
            let values = try settings(run.appendingPathComponent("\(configuration)-settings.json"), configuration: configuration)
            let bundle = run.appendingPathComponent("DerivedData/Build/Products/\(configuration)/Core Metrics.app")
            guard let targetPath = values["TARGET_BUILD_DIR"] else {
                throw ValidationFailure.check("Resolved product directory is missing.")
            }
            let targetDirectory = URL(fileURLWithPath: targetPath, isDirectory: true).resolvingSymlinksInPath().standardizedFileURL
            let expectedDirectory = bundle.deletingLastPathComponent().resolvingSymlinksInPath().standardizedFileURL
            try require(targetDirectory.path == expectedDirectory.path, "Build products escaped the isolated validation directory.")
            try verifyBundle(bundle, settings: values, sourcePrivacy: sourcePrivacy)
            if configuration == "Release" {
                let conditions = (values["SWIFT_ACTIVE_COMPILATION_CONDITIONS"] ?? "").split(whereSeparator: { $0.isWhitespace })
                try require(!conditions.contains("DEBUG"), "Release enables the DEBUG compilation condition.")
                try verifyReleaseIsolation(bundle)
            }
            print("\(configuration) packaged metadata, identity agreement, privacy and configuration verified.")
        }
        print("Unsigned products do not prove effective signing entitlements or distribution readiness.")
    case "ui" where arguments.count == 2:
        let entitlements = try plist(URL(fileURLWithPath: arguments[1]))
        try require(boolean(entitlements["com.apple.security.app-sandbox"], equals: true), "Ad-hoc UI app is missing effective App Sandbox.")
        print("Ad-hoc UI app has effective App Sandbox. Debug/test exceptions do not validate a distribution signature.")
    default:
        throw ValidationFailure.check("Invalid artifact-verifier arguments; use scripts/validate.sh.")
    }
} catch {
    // Underlying Foundation errors may contain local paths; this output belongs
    // only in the private raw validation log, never in committed reports.
    FileHandle.standardError.write(Data("Artifact validation failed: \(error)\n".utf8))
    exit(1)
}
