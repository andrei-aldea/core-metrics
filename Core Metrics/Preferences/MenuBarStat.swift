import Foundation

/// A concrete aggregate statistic that can occupy one menu-bar slot.
///
/// Raw values are persistence identifiers. Keep them stable when changing
/// user-facing names.
nonisolated enum MenuBarStat: String, CaseIterable, Codable, Hashable, Identifiable, Sendable {
    case cpuUser
    case cpuSystem
    case cpuIdle
    case memoryUsed
    case memoryCached
    case memorySwap
    case storageUsed
    case storageFree = "storageAvailable"
    case storageTotal

    var id: String {
        rawValue
    }

    var metric: MetricKind {
        switch self {
        case .cpuUser, .cpuSystem, .cpuIdle:
            .cpu
        case .memoryUsed, .memoryCached, .memorySwap:
            .memory
        case .storageUsed, .storageFree, .storageTotal:
            .storage
        }
    }

    var displayName: String {
        switch self {
        case .cpuUser:
            "CPU User"
        case .cpuSystem:
            "CPU System"
        case .cpuIdle:
            "CPU Idle"
        case .memoryUsed:
            "Memory Used"
        case .memoryCached:
            "Cached Files"
        case .memorySwap:
            "Swap Used"
        case .storageUsed:
            "SSD Used Space"
        case .storageFree:
            "SSD Free Space"
        case .storageTotal:
            "SSD Total Space"
        }
    }

    /// Concise wording used inside the metric-grouped status panel.
    var panelName: String {
        switch self {
        case .cpuUser:
            "User"
        case .cpuSystem:
            "System"
        case .cpuIdle:
            "Idle"
        case .memoryUsed:
            "Memory Used"
        case .memoryCached:
            "Cached Files"
        case .memorySwap:
            "Swap Used"
        case .storageUsed:
            "Used Space"
        case .storageFree:
            "Free Space"
        case .storageTotal:
            "Total Capacity"
        }
    }

    /// Descriptive text used in the menu-bar status item. The status item is
    /// deliberately text-only so macOS can't drop part of a composed label.
    var menuBarName: String {
        switch self {
        case .cpuUser:
            "CPU User"
        case .cpuSystem:
            "CPU System"
        case .cpuIdle:
            "CPU Idle"
        case .memoryUsed:
            "RAM Used"
        case .memoryCached:
            "Cached"
        case .memorySwap:
            "Swap"
        case .storageUsed:
            "SSD Used"
        case .storageFree:
            "SSD Free"
        case .storageTotal:
            "SSD Total"
        }
    }

    /// Stable, terse text that distinguishes each stat in compact mode.
    var shortCode: String {
        switch self {
        case .cpuUser:
            "CU"
        case .cpuSystem:
            "CS"
        case .cpuIdle:
            "CI"
        case .memoryUsed:
            "MU"
        case .memoryCached:
            "CF"
        case .memorySwap:
            "SW"
        case .storageUsed:
            "SU"
        case .storageFree:
            "SF"
        case .storageTotal:
            "ST"
        }
    }

    static func values(for metric: MetricKind) -> [MenuBarStat] {
        allCases.filter { $0.metric == metric }
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let persistedValue = try container.decode(String.self)

        if let currentValue = Self(rawValue: persistedValue) {
            self = currentValue
            return
        }

        // Older builds exposed more representations. Map them to the closest
        // supported macOS 27 statistic instead of discarding all preferences.
        self = switch persistedValue {
        case "cpuTotal": .cpuUser
        case "memoryPercentage", "memoryAppEstimate", "memoryWired",
             "memoryCompressed", "memoryTotal": .memoryUsed
        case "memoryAvailable": .memoryCached
        case "storagePercentage": .storageUsed
        default:
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unknown menu-bar statistic: \(persistedValue)"
            )
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
