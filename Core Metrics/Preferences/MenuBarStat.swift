import Foundation

/// A concrete aggregate statistic that can occupy one menu-bar slot.
///
/// Raw values are persistence identifiers. Keep them stable when changing
/// user-facing names.
nonisolated enum MenuBarStat: String, CaseIterable, Codable, Hashable, Identifiable, Sendable {
    case cpuUsed = "cpuTotal"
    case cpuUser
    case cpuSystem
    case cpuIdle
    case memoryUsed
    case memoryUsedPercentage = "memoryPercentage"
    case memoryWired
    case memoryCompressed
    case memoryCached
    case memorySwap
    case memoryTotal
    case storageUsed
    case storageUsedPercentage = "storagePercentage"
    case storageFree = "storageAvailable"
    case storageTotal

    var id: String {
        rawValue
    }

    var metric: MetricKind {
        switch self {
        case .cpuUsed, .cpuUser, .cpuSystem, .cpuIdle:
            .cpu
        case .memoryUsed, .memoryUsedPercentage, .memoryWired,
             .memoryCompressed, .memoryCached, .memorySwap, .memoryTotal:
            .memory
        case .storageUsed, .storageUsedPercentage, .storageFree, .storageTotal:
            .storage
        }
    }

    var displayName: String {
        switch self {
        case .cpuUsed:
            "CPU Used"
        case .cpuUser:
            "CPU User"
        case .cpuSystem:
            "CPU System"
        case .cpuIdle:
            "CPU Idle"
        case .memoryUsed:
            "Memory Used"
        case .memoryUsedPercentage:
            "RAM Used %"
        case .memoryWired:
            "Wired Memory"
        case .memoryCompressed:
            "Compressed Memory"
        case .memoryCached:
            "Cached Files"
        case .memorySwap:
            "Swap Used"
        case .memoryTotal:
            "Physical Memory"
        case .storageUsed:
            "SSD Used Space"
        case .storageUsedPercentage:
            "SSD Used %"
        case .storageFree:
            "SSD Free Space"
        case .storageTotal:
            "SSD Total Space"
        }
    }

    /// Concise wording used inside the metric-grouped status panel.
    var panelName: String {
        switch self {
        case .cpuUsed:
            "Used"
        case .cpuUser:
            "User"
        case .cpuSystem:
            "System"
        case .cpuIdle:
            "Idle"
        case .memoryUsed:
            "Memory Used"
        case .memoryUsedPercentage:
            "Used %"
        case .memoryWired:
            "Wired Memory"
        case .memoryCompressed:
            "Compressed Memory"
        case .memoryCached:
            "Cached Files"
        case .memorySwap:
            "Swap Used"
        case .memoryTotal:
            "Physical Memory"
        case .storageUsed:
            "Used Space"
        case .storageUsedPercentage:
            "Used %"
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
        case .cpuUsed:
            "CPU Used"
        case .cpuUser:
            "CPU User"
        case .cpuSystem:
            "CPU System"
        case .cpuIdle:
            "CPU Idle"
        case .memoryUsed:
            "RAM Used"
        case .memoryUsedPercentage:
            "RAM Usage"
        case .memoryWired:
            "RAM Wired"
        case .memoryCompressed:
            "RAM Compressed"
        case .memoryCached:
            "Cached"
        case .memorySwap:
            "Swap"
        case .memoryTotal:
            "Physical RAM"
        case .storageUsed:
            "SSD Used"
        case .storageUsedPercentage:
            "SSD Usage"
        case .storageFree:
            "SSD Free"
        case .storageTotal:
            "SSD Total"
        }
    }

    /// Stable, terse text that distinguishes each stat in compact mode.
    var shortCode: String {
        switch self {
        case .cpuUsed:
            "C%"
        case .cpuUser:
            "CU"
        case .cpuSystem:
            "CS"
        case .cpuIdle:
            "CI"
        case .memoryUsed:
            "MU"
        case .memoryUsedPercentage:
            "M%"
        case .memoryWired:
            "MW"
        case .memoryCompressed:
            "MC"
        case .memoryCached:
            "CF"
        case .memorySwap:
            "SW"
        case .memoryTotal:
            "PM"
        case .storageUsed:
            "SU"
        case .storageUsedPercentage:
            "S%"
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
        case "memoryAppEstimate": .memoryUsed
        case "memoryAvailable": .memoryCached
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
