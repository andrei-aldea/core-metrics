import Foundation

/// A concrete aggregate statistic that can occupy one menu-bar slot.
///
/// Raw values are persistence identifiers. Keep them stable when changing
/// user-facing names.
nonisolated enum MenuBarStat: String, CaseIterable, Codable, Hashable, Identifiable, Sendable {
    case cpuTotal
    case cpuUser
    case cpuSystem
    case cpuIdle
    case memoryPercentage
    case memoryUsed
    case memoryAvailable
    case memoryAppEstimate
    case memoryWired
    case memoryCompressed
    case memoryTotal
    case storagePercentage
    case storageUsed
    case storageAvailable
    case storageTotal

    enum ValueWidth: Sendable {
        case percentage
        case bytes
    }

    var id: String {
        rawValue
    }

    var metric: MetricKind {
        switch self {
        case .cpuTotal, .cpuUser, .cpuSystem, .cpuIdle:
            .cpu
        case .memoryPercentage, .memoryUsed, .memoryAvailable, .memoryAppEstimate,
             .memoryWired, .memoryCompressed, .memoryTotal:
            .memory
        case .storagePercentage, .storageUsed, .storageAvailable, .storageTotal:
            .storage
        }
    }

    var displayName: String {
        switch self {
        case .cpuTotal:
            "CPU Total Used"
        case .cpuUser:
            "CPU User"
        case .cpuSystem:
            "CPU System"
        case .cpuIdle:
            "CPU Idle"
        case .memoryPercentage:
            "Memory Used Percentage"
        case .memoryUsed:
            "Memory Used"
        case .memoryAvailable:
            "Memory Available"
        case .memoryAppEstimate:
            "Memory App Estimate"
        case .memoryWired:
            "Memory Wired"
        case .memoryCompressed:
            "Memory Compressed"
        case .memoryTotal:
            "Memory Total"
        case .storagePercentage:
            "Storage Used Percentage"
        case .storageUsed:
            "Storage Used"
        case .storageAvailable:
            "Storage Available"
        case .storageTotal:
            "Storage Total"
        }
    }

    /// Compact wording for the dashboard's selected-stat summary. Percentage
    /// variants keep the suffix so they remain distinct from byte variants.
    var dashboardName: String {
        switch self {
        case .cpuTotal:
            "CPU Used"
        case .cpuUser:
            "CPU User"
        case .cpuSystem:
            "CPU System"
        case .cpuIdle:
            "CPU Idle"
        case .memoryPercentage:
            "Memory Used %"
        case .memoryUsed:
            "Memory Used"
        case .memoryAvailable:
            "Memory Available"
        case .memoryAppEstimate:
            "Memory App Estimate"
        case .memoryWired:
            "Memory Wired"
        case .memoryCompressed:
            "Memory Compressed"
        case .memoryTotal:
            "Memory Total"
        case .storagePercentage:
            "Storage Used %"
        case .storageUsed:
            "Storage Used"
        case .storageAvailable:
            "Storage Available"
        case .storageTotal:
            "Storage Total"
        }
    }

    /// Stable, terse text that distinguishes each stat in compact mode.
    var shortCode: String {
        switch self {
        case .cpuTotal:
            "CT"
        case .cpuUser:
            "CU"
        case .cpuSystem:
            "CS"
        case .cpuIdle:
            "CI"
        case .memoryPercentage:
            "M%"
        case .memoryUsed:
            "MU"
        case .memoryAvailable:
            "MA"
        case .memoryAppEstimate:
            "ME"
        case .memoryWired:
            "MW"
        case .memoryCompressed:
            "MC"
        case .memoryTotal:
            "MT"
        case .storagePercentage:
            "S%"
        case .storageUsed:
            "SU"
        case .storageAvailable:
            "SA"
        case .storageTotal:
            "ST"
        }
    }

    /// One-character qualifier paired with the category icon.
    var detailCode: String {
        switch self {
        case .cpuTotal:
            "T"
        case .cpuUser:
            "U"
        case .cpuSystem:
            "S"
        case .cpuIdle:
            "I"
        case .memoryPercentage, .storagePercentage:
            "%"
        case .memoryUsed, .storageUsed:
            "U"
        case .memoryAvailable, .storageAvailable:
            "A"
        case .memoryAppEstimate:
            "E"
        case .memoryWired:
            "W"
        case .memoryCompressed:
            "C"
        case .memoryTotal, .storageTotal:
            "T"
        }
    }

    var valueWidth: ValueWidth {
        switch self {
        case .cpuTotal, .cpuUser, .cpuSystem, .cpuIdle,
             .memoryPercentage, .storagePercentage:
            .percentage
        case .memoryUsed, .memoryAvailable, .memoryAppEstimate, .memoryWired,
             .memoryCompressed, .memoryTotal, .storageUsed, .storageAvailable,
             .storageTotal:
            .bytes
        }
    }

    static func values(for metric: MetricKind) -> [MenuBarStat] {
        allCases.filter { $0.metric == metric }
    }

    init(cpuStyle: CPUMenuValueStyle) {
        self = switch cpuStyle {
        case .total: .cpuTotal
        case .user: .cpuUser
        case .system: .cpuSystem
        case .idle: .cpuIdle
        }
    }

    init(memoryStyle: MemoryMenuValueStyle) {
        self = switch memoryStyle {
        case .percentage: .memoryPercentage
        case .used: .memoryUsed
        case .available: .memoryAvailable
        case .appEstimate: .memoryAppEstimate
        case .wired: .memoryWired
        case .compressed: .memoryCompressed
        case .total: .memoryTotal
        }
    }

    init(storageStyle: StorageMenuValueStyle) {
        self = switch storageStyle {
        case .percentage: .storagePercentage
        case .used: .storageUsed
        case .available: .storageAvailable
        case .total: .storageTotal
        }
    }
}
