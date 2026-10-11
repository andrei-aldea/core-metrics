import Foundation

/// Public companion pages open in the person's browser only on request.
/// No readings, preferences or device identifiers are attached.
/// The email subject identifies only the product and purpose.
nonisolated enum PublicAppLinks {
    private static let website: URL = {
        guard let url = URL(string: "https://core-metrics.dorobantimedia.com/en") else {
            preconditionFailure("The public website URL must be valid.")
        }
        return url
    }()

    static let support = website.appending(path: "support")
    static let privacyPolicy = website.appending(path: "privacy")
    static let privacyEmail: URL = {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = "support@dorobantimedia.com"
        components.queryItems = [URLQueryItem(name: "subject", value: "Core Metrics - Privacy request")]
        guard let url = components.url else {
            preconditionFailure("The privacy contact URL must be valid.")
        }
        return url
    }()
}
