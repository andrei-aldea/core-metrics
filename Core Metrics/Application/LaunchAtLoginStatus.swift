/// The current registration state reported by macOS, rather than a persisted
/// preference that could become stale after a System Settings change.
nonisolated enum LaunchAtLoginStatus: CaseIterable, Equatable, Sendable {
    case notRegistered
    case enabled
    case requiresApproval
    case notFound
    case unknown
}
