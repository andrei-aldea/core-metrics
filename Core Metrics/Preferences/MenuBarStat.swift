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
            String(localized: "CPU Used")
        case .cpuUser:
            String(localized: "CPU User")
        case .cpuSystem:
            String(localized: "CPU System")
        case .cpuIdle:
            String(localized: "CPU Idle")
        case .memoryUsed:
            String(localized: "Memory Used")
        case .memoryUsedPercentage:
            String(localized: "Memory Used (%)")
        case .memoryWired:
            String(localized: "Wired Memory")
        case .memoryCompressed:
            String(localized: "Compressed Memory")
        case .memoryCached:
            String(localized: "Cached Files")
        case .memorySwap:
            String(localized: "Swap Used")
        case .memoryTotal:
            String(localized: "Physical Memory")
        case .storageUsed:
            String(localized: "Storage Used")
        case .storageUsedPercentage:
            String(localized: "Storage Used (%)")
        case .storageFree:
            String(localized: "Storage Free")
        case .storageTotal:
            String(localized: "Storage Total")
        }
    }

    /// Concise wording used inside the metric-grouped status panel.
    var panelName: String {
        switch self {
        case .cpuUsed:
            String(localized: "Used")
        case .cpuUser:
            String(localized: "User")
        case .cpuSystem:
            String(localized: "System")
        case .cpuIdle:
            String(localized: "Idle")
        case .memoryUsed:
            String(localized: "Used")
        case .memoryUsedPercentage:
            String(localized: "Used (%)")
        case .memoryWired:
            String(localized: "Wired Memory")
        case .memoryCompressed:
            String(localized: "Compressed Memory")
        case .memoryCached:
            String(localized: "Cached Files")
        case .memorySwap:
            String(localized: "Swap Used")
        case .memoryTotal:
            String(localized: "Physical Memory")
        case .storageUsed:
            String(localized: "Used")
        case .storageUsedPercentage:
            String(localized: "Used (%)")
        case .storageFree:
            String(localized: "Free")
        case .storageTotal:
            String(localized: "Total")
        }
    }

    /// Shares the full names used by Settings and copied readings. Percentage
    /// values already include their unit, so their labels omit the (%) suffix.
    var menuBarName: String {
        switch self {
        case .memoryUsedPercentage:
            Self.memoryUsed.displayName
        case .storageUsedPercentage:
            Self.storageUsed.displayName
        default:
            displayName
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
