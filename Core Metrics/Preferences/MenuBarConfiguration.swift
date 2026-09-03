import Foundation

/// Durable, validated menu-bar preferences.
///
/// `enabledStats` is always unique, follows the widget's canonical order, and
/// contains between one and seven concrete aggregate statistics. All mutations
/// preserve this invariant, including values decoded from UserDefaults.
nonisolated struct MenuBarConfiguration: Codable, Equatable, Sendable {
    static let maximumEnabledStatCount = 7

    static var defaultValue: MenuBarConfiguration {
        MenuBarConfiguration(
            enabledStats: [.cpuUser],
            displayMode: .labelAndValue
        )
    }

    private(set) var enabledStats: [MenuBarStat]
    var displayMode: MenuBarDisplayMode {
        didSet {
            displayMode = Self.validatedDisplayMode(
                displayMode,
                enabledStatCount: enabledStats.count
            )
        }
    }

    init(
        enabledStats: [MenuBarStat] = [.cpuUser],
        displayMode: MenuBarDisplayMode = .labelAndValue
    ) {
        let normalizedStats = Self.normalized(enabledStats)
        self.enabledStats = normalizedStats
        self.displayMode = Self.validatedDisplayMode(
            displayMode,
            enabledStatCount: normalizedStats.count
        )
    }

    func isStatEnabled(_ stat: MenuBarStat) -> Bool {
        enabledStats.contains(stat)
    }

    func canEnable(_ stat: MenuBarStat) -> Bool {
        !isStatEnabled(stat)
            && enabledStats.count < Self.maximumEnabledStatCount
    }

    func canDisable(_ stat: MenuBarStat) -> Bool {
        isStatEnabled(stat) && enabledStats.count > 1
    }

    var availableStats: [MenuBarStat] {
        MenuBarStat.allCases.filter(canEnable)
    }

    var availableDisplayModes: [MenuBarDisplayMode] {
        enabledStats.count > 1
            ? MenuBarDisplayMode.allCases.filter { $0 != .valueOnly }
            : MenuBarDisplayMode.allCases
    }

    /// Returns `true` only when the configuration actually changed.
    @discardableResult
    mutating func setStat(_ stat: MenuBarStat, enabled: Bool) -> Bool {
        if enabled {
            guard canEnable(stat) else {
                return false
            }

            enabledStats = Self.normalized(enabledStats + [stat])
            if displayMode == .valueOnly {
                displayMode = .compact
            }
            return true
        }

        guard canDisable(stat), let index = enabledStats.firstIndex(of: stat) else {
            return false
        }

        enabledStats.remove(at: index)
        return true
    }

    private enum CodingKeys: String, CodingKey {
        case enabledStats
        case displayMode

        // Version 1 keys retained only to migrate existing local preferences.
        case enabledMetrics
        case cpuValueStyle
        case memoryValueStyle
        case storageValueStyle
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let displayMode = try container.decodeIfPresent(
            MenuBarDisplayMode.self,
            forKey: .displayMode
        ) ?? .labelAndValue

        if let enabledStats = try container.decodeIfPresent(
            [MenuBarStat].self,
            forKey: .enabledStats
        ) {
            self.init(enabledStats: enabledStats, displayMode: displayMode)
            return
        }

        let enabledMetrics = try container.decodeIfPresent(
            [MetricKind].self,
            forKey: .enabledMetrics
        ) ?? [.cpu]
        let cpuStyle = try container.decodeIfPresent(
            LegacyCPUValueStyle.self,
            forKey: .cpuValueStyle
        ) ?? .total
        let memoryStyle = try container.decodeIfPresent(
            LegacyMemoryValueStyle.self,
            forKey: .memoryValueStyle
        ) ?? .percentage
        let storageStyle = try container.decodeIfPresent(
            LegacyStorageValueStyle.self,
            forKey: .storageValueStyle
        ) ?? .percentage

        self.init(
            enabledStats: enabledMetrics.map { metric in
                switch metric {
                case .cpu:
                    switch cpuStyle {
                    case .total, .user: .cpuUser
                    case .system: .cpuSystem
                    case .idle: .cpuIdle
                    }
                case .memory:
                    switch memoryStyle {
                    case .available: .memoryCached
                    case .percentage, .used, .appEstimate, .wired,
                         .compressed, .total: .memoryUsed
                    }
                case .storage:
                    switch storageStyle {
                    case .available: .storageFree
                    case .percentage, .used: .storageUsed
                    case .total: .storageTotal
                    }
                }
            },
            displayMode: displayMode
        )
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(enabledStats, forKey: .enabledStats)
        try container.encode(displayMode, forKey: .displayMode)
    }

    private static func normalized(_ stats: [MenuBarStat]) -> [MenuBarStat] {
        let selectedStats = Set(stats)
        let widgetOrderedStats = MenuBarStat.allCases.filter(selectedStats.contains)
        let boundedStats = Array(
            widgetOrderedStats.prefix(Self.maximumEnabledStatCount)
        )
        return boundedStats.isEmpty ? [.cpuUser] : boundedStats
    }

    private static func validatedDisplayMode(
        _ displayMode: MenuBarDisplayMode,
        enabledStatCount: Int
    ) -> MenuBarDisplayMode {
        if displayMode == .valueOnly, enabledStatCount > 1 {
            return .compact
        }

        return displayMode
    }

    /// Version 1 representation enums remain private because they only decode
    /// preferences written by older builds.
    private enum LegacyCPUValueStyle: String, Decodable {
        case total
        case user
        case system
        case idle
    }

    private enum LegacyMemoryValueStyle: String, Decodable {
        case percentage
        case used
        case available
        case appEstimate
        case wired
        case compressed
        case total
    }

    private enum LegacyStorageValueStyle: String, Decodable {
        case percentage
        case used
        case available
        case total
    }
}
