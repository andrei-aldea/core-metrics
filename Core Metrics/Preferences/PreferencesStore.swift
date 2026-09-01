import Foundation
import Observation

/// Main-actor-owned preferences with an immediately observable in-memory value
/// and asynchronous-on-disk UserDefaults persistence.
@MainActor
@Observable
final class PreferencesStore {
    var configuration: MenuBarConfiguration {
        didSet {
            persistConfiguration()
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
        }
    }

    var enabledMetrics: [MetricKind] {
        configuration.enabledMetrics
    }

    var displayMode: MenuBarDisplayMode {
        get { configuration.displayMode }
        set {
            var updatedConfiguration = configuration
            updatedConfiguration.displayMode = newValue
            configuration = updatedConfiguration
        }
    }

    var memoryValueStyle: MemoryMenuValueStyle {
        get { configuration.memoryValueStyle }
        set {
            var updatedConfiguration = configuration
            updatedConfiguration.memoryValueStyle = newValue
            configuration = updatedConfiguration
        }
    }

    var storageValueStyle: StorageMenuValueStyle {
        get { configuration.storageValueStyle }
        set {
            var updatedConfiguration = configuration
            updatedConfiguration.storageValueStyle = newValue
            configuration = updatedConfiguration
        }
    }

    func isMetricEnabled(_ metric: MetricKind) -> Bool {
        configuration.isMetricEnabled(metric)
    }

    func canDisable(_ metric: MetricKind) -> Bool {
        configuration.canDisable(metric)
    }

    @discardableResult
    func setMetric(_ metric: MetricKind, enabled: Bool) -> Bool {
        var updatedConfiguration = configuration
        guard updatedConfiguration.setMetric(metric, enabled: enabled) else {
            return false
        }

        configuration = updatedConfiguration
        return true
    }

    @discardableResult
    func moveMetric(
        _ metric: MetricKind,
        direction: MenuBarConfiguration.MoveDirection
    ) -> Bool {
        var updatedConfiguration = configuration
        guard updatedConfiguration.moveMetric(metric, direction: direction) else {
            return false
        }

        configuration = updatedConfiguration
        return true
    }

    @discardableResult
    func moveMetricUp(_ metric: MetricKind) -> Bool {
        moveMetric(metric, direction: .up)
    }

    @discardableResult
    func moveMetricDown(_ metric: MetricKind) -> Bool {
        moveMetric(metric, direction: .down)
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
