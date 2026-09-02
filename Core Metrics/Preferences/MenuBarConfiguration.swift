import Foundation

/// Durable, validated menu-bar preferences.
///
/// `enabledStats` is always unique, ordered, and contains between one and five
/// concrete aggregate statistics. All mutations preserve this invariant,
/// including values decoded from UserDefaults.
nonisolated struct MenuBarConfiguration: Codable, Equatable, Sendable {
    static let maximumEnabledStatCount = 5

    enum MoveDirection: Sendable {
        case up
        case down
    }

    static var defaultValue: MenuBarConfiguration {
        MenuBarConfiguration(
            enabledStats: [.cpuTotal],
            displayMode: .iconAndValue
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
        enabledStats: [MenuBarStat] = [.cpuTotal],
        displayMode: MenuBarDisplayMode = .iconAndValue
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

    func canDisable(_ stat: MenuBarStat) -> Bool {
        isStatEnabled(stat) && enabledStats.count > 1
    }

    /// Returns `true` only when the configuration actually changed.
    @discardableResult
    mutating func setStat(_ stat: MenuBarStat, enabled: Bool) -> Bool {
        if enabled {
            guard
                !isStatEnabled(stat),
                enabledStats.count < Self.maximumEnabledStatCount
            else {
                return false
            }

            enabledStats.append(stat)
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

    /// Moves an enabled stat one position and returns whether it moved.
    @discardableResult
    mutating func moveStat(_ stat: MenuBarStat, direction: MoveDirection) -> Bool {
        guard let sourceIndex = enabledStats.firstIndex(of: stat) else {
            return false
        }

        let destinationIndex: Int
        switch direction {
        case .up:
            destinationIndex = sourceIndex - 1
        case .down:
            destinationIndex = sourceIndex + 1
        }

        guard enabledStats.indices.contains(destinationIndex) else {
            return false
        }

        enabledStats.swapAt(sourceIndex, destinationIndex)
        return true
    }

    @discardableResult
    mutating func moveStatUp(_ stat: MenuBarStat) -> Bool {
        moveStat(stat, direction: .up)
    }

    @discardableResult
    mutating func moveStatDown(_ stat: MenuBarStat) -> Bool {
        moveStat(stat, direction: .down)
    }

    mutating func reset() {
        self = .defaultValue
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
        ) ?? .iconAndValue

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
            CPUMenuValueStyle.self,
            forKey: .cpuValueStyle
        ) ?? .total
        let memoryStyle = try container.decodeIfPresent(
            MemoryMenuValueStyle.self,
            forKey: .memoryValueStyle
        ) ?? .percentage
        let storageStyle = try container.decodeIfPresent(
            StorageMenuValueStyle.self,
            forKey: .storageValueStyle
        ) ?? .percentage

        self.init(
            enabledStats: enabledMetrics.map { metric in
                switch metric {
                case .cpu:
                    MenuBarStat(cpuStyle: cpuStyle)
                case .memory:
                    MenuBarStat(memoryStyle: memoryStyle)
                case .storage:
                    MenuBarStat(storageStyle: storageStyle)
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
        var seen: Set<MenuBarStat> = []
        let uniqueStats = stats.filter { seen.insert($0).inserted }
        let boundedStats = Array(uniqueStats.prefix(Self.maximumEnabledStatCount))
        return boundedStats.isEmpty ? [.cpuTotal] : boundedStats
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
}
