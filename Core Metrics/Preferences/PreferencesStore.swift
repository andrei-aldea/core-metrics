import Foundation
import Observation

/// Main-actor-owned preferences with an immediately observable in-memory value
/// and native UserDefaults persistence.
@MainActor
@Observable
final class PreferencesStore {
    var configuration: MenuBarConfiguration {
        didSet {
            if configuration != oldValue {
                persistConfiguration()
            }
        }
    }

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let persistenceKey: String

    init(
        defaults: UserDefaults = .standard,
        persistenceKey: String = "menuBarConfiguration.v1"
    ) {
        self.defaults = defaults
        self.persistenceKey = persistenceKey

        let hasStoredValue = defaults.object(forKey: persistenceKey) != nil
        if
            let data = defaults.data(forKey: persistenceKey),
            let storedConfiguration = try? JSONDecoder().decode(
                MenuBarConfiguration.self,
                from: data
            )
        {
            configuration = storedConfiguration
        } else {
            configuration = .defaultValue

            // Replace malformed or wrongly typed persistence once so later
            // launches start from a valid configuration instead of repeating
            // the same decode failure.
            if
                hasStoredValue,
                let repairedData = try? JSONEncoder().encode(configuration)
            {
                defaults.set(repairedData, forKey: persistenceKey)
            }
        }
    }

    var enabledStats: [MenuBarStat] {
        configuration.enabledStats
    }

    var displayMode: MenuBarDisplayMode {
        get { configuration.displayMode }
        set {
            var updatedConfiguration = configuration
            updatedConfiguration.displayMode = newValue
            configuration = updatedConfiguration
        }
    }

    var availableStats: [MenuBarStat] {
        configuration.availableStats
    }

    var availableDisplayModes: [MenuBarDisplayMode] {
        configuration.availableDisplayModes
    }

    func isStatEnabled(_ stat: MenuBarStat) -> Bool {
        configuration.isStatEnabled(stat)
    }

    func canDisable(_ stat: MenuBarStat) -> Bool {
        configuration.canDisable(stat)
    }

    func canEnable(_ stat: MenuBarStat) -> Bool {
        configuration.canEnable(stat)
    }

    @discardableResult
    func setStat(_ stat: MenuBarStat, enabled: Bool) -> Bool {
        var updatedConfiguration = configuration
        guard updatedConfiguration.setStat(stat, enabled: enabled) else {
            return false
        }

        configuration = updatedConfiguration
        return true
    }

    func reset() {
        configuration = .defaultValue
    }

    private func persistConfiguration() {
        guard let data = try? JSONEncoder().encode(configuration) else {
            return
        }

        defaults.set(data, forKey: persistenceKey)
    }
}
