import Foundation

/// Durable, validated menu-bar preferences.
///
/// `enabledMetrics` is always unique, ordered, and contains between one and
/// three metrics. All mutations go through helpers that preserve this
/// invariant, including values decoded from UserDefaults.
nonisolated struct MenuBarConfiguration: Codable, Equatable, Sendable {
    private static let maximumEnabledMetricCount = 3

    enum MoveDirection: Sendable {
        case up
        case down
    }

    static var defaultValue: MenuBarConfiguration {
        MenuBarConfiguration(
            enabledMetrics: [.cpu],
            displayMode: .iconAndValue,
            memoryValueStyle: .percentage,
            storageValueStyle: .percentage
        )
    }

    private(set) var enabledMetrics: [MetricKind]
    var displayMode: MenuBarDisplayMode {
        didSet {
            displayMode = Self.validatedDisplayMode(
                displayMode,
                enabledMetricCount: enabledMetrics.count
            )
        }
    }
    var memoryValueStyle: MemoryMenuValueStyle
    var storageValueStyle: StorageMenuValueStyle

    init(
        enabledMetrics: [MetricKind] = [.cpu],
        displayMode: MenuBarDisplayMode = .iconAndValue,
        memoryValueStyle: MemoryMenuValueStyle = .percentage,
        storageValueStyle: StorageMenuValueStyle = .percentage
    ) {
        let normalizedMetrics = Self.normalized(enabledMetrics)
        self.enabledMetrics = normalizedMetrics
        self.displayMode = Self.validatedDisplayMode(
            displayMode,
            enabledMetricCount: normalizedMetrics.count
        )
        self.memoryValueStyle = memoryValueStyle
        self.storageValueStyle = storageValueStyle
    }

    func isMetricEnabled(_ metric: MetricKind) -> Bool {
        enabledMetrics.contains(metric)
    }

    func canDisable(_ metric: MetricKind) -> Bool {
        isMetricEnabled(metric) && enabledMetrics.count > 1
    }

    /// Returns `true` only when the configuration actually changed.
    @discardableResult
    mutating func setMetric(_ metric: MetricKind, enabled: Bool) -> Bool {
        if enabled {
            guard
                !isMetricEnabled(metric),
                enabledMetrics.count < Self.maximumEnabledMetricCount
            else {
                return false
            }

            enabledMetrics.append(metric)
            if displayMode == .valueOnly {
                displayMode = .compact
            }
            return true
        }

        guard canDisable(metric), let index = enabledMetrics.firstIndex(of: metric) else {
            return false
        }

        enabledMetrics.remove(at: index)
        return true
    }

    /// Moves an enabled metric one position and returns whether it moved.
    @discardableResult
    mutating func moveMetric(_ metric: MetricKind, direction: MoveDirection) -> Bool {
        guard let sourceIndex = enabledMetrics.firstIndex(of: metric) else {
            return false
        }

        let destinationIndex: Int
        switch direction {
        case .up:
            destinationIndex = sourceIndex - 1
        case .down:
            destinationIndex = sourceIndex + 1
        }

        guard enabledMetrics.indices.contains(destinationIndex) else {
            return false
        }

        enabledMetrics.swapAt(sourceIndex, destinationIndex)
        return true
    }

    @discardableResult
    mutating func moveMetricUp(_ metric: MetricKind) -> Bool {
        moveMetric(metric, direction: .up)
    }

    @discardableResult
    mutating func moveMetricDown(_ metric: MetricKind) -> Bool {
        moveMetric(metric, direction: .down)
    }

    mutating func reset() {
        self = .defaultValue
    }

    private enum CodingKeys: String, CodingKey {
        case enabledMetrics
        case displayMode
        case memoryValueStyle
        case storageValueStyle
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            enabledMetrics: try container.decodeIfPresent(
                [MetricKind].self,
                forKey: .enabledMetrics
            ) ?? [.cpu],
            displayMode: try container.decodeIfPresent(
                MenuBarDisplayMode.self,
                forKey: .displayMode
            ) ?? .iconAndValue,
            memoryValueStyle: try container.decodeIfPresent(
                MemoryMenuValueStyle.self,
                forKey: .memoryValueStyle
            ) ?? .percentage,
            storageValueStyle: try container.decodeIfPresent(
                StorageMenuValueStyle.self,
                forKey: .storageValueStyle
            ) ?? .percentage
        )
    }

    private static func normalized(_ metrics: [MetricKind]) -> [MetricKind] {
        var seen: Set<MetricKind> = []
        let uniqueMetrics = metrics.filter { seen.insert($0).inserted }
        let boundedMetrics = Array(uniqueMetrics.prefix(Self.maximumEnabledMetricCount))
        return boundedMetrics.isEmpty ? [.cpu] : boundedMetrics
    }

    private static func validatedDisplayMode(
        _ displayMode: MenuBarDisplayMode,
        enabledMetricCount: Int
    ) -> MenuBarDisplayMode {
        if displayMode == .valueOnly, enabledMetricCount > 1 {
            return .compact
        }

        return displayMode
    }
}
