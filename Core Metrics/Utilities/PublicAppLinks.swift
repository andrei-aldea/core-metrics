import Foundation

/// Public companion pages open in the person's browser only on request.
/// No readings, preferences, identifiers or query parameters are attached.
nonisolated enum PublicAppLinks {
    private static let website: URL = {
        guard let url = URL(string: "https://core-metrics.dorobantimedia.com/en") else {
            preconditionFailure("The public website URL must be valid.")
        }
        return url
    }()

    static let support = website.appending(path: "support")
    static let privacyPolicy = website.appending(path: "privacy")
}
