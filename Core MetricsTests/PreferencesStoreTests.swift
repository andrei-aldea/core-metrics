import Foundation
import Testing
@testable import Core_Metrics

@Suite("Preferences persistence")
struct PreferencesStoreTests {
    @MainActor
    @Test("Mutations update accessors and UserDefaults immediately")
    func mutationsPersistImmediately() throws {
        let fixture = try makeDefaultsFixture()
        defer { fixture.defaults.removePersistentDomain(forName: fixture.suiteName) }

        let store = PreferencesStore(
            defaults: fixture.defaults,
            persistenceKey: fixture.persistenceKey
        )

        #expect(store.setMetric(.memory, enabled: true))
        store.displayMode = .compact
        store.memoryValueStyle = .used
        store.storageValueStyle = .available

        #expect(store.enabledMetrics == [.cpu, .memory])
        #expect(store.displayMode == .compact)
        #expect(store.memoryValueStyle == .used)
        #expect(store.storageValueStyle == .available)

        let data = try #require(fixture.defaults.data(forKey: fixture.persistenceKey))
        let persisted = try JSONDecoder().decode(MenuBarConfiguration.self, from: data)
        #expect(persisted == store.configuration)
    }

    @MainActor
    @Test("A new store restores the saved configuration")
    func reloadsConfiguration() throws {
        let fixture = try makeDefaultsFixture()
        defer { fixture.defaults.removePersistentDomain(forName: fixture.suiteName) }

        let firstStore = PreferencesStore(
            defaults: fixture.defaults,
            persistenceKey: fixture.persistenceKey
        )
        firstStore.configuration = MenuBarConfiguration(
            enabledMetrics: [.storage, .cpu],
            displayMode: .valueOnly,
            memoryValueStyle: .used,
            storageValueStyle: .available
        )

        let restoredStore = PreferencesStore(
            defaults: fixture.defaults,
            persistenceKey: fixture.persistenceKey
        )
        #expect(restoredStore.configuration == firstStore.configuration)
    }

    @MainActor
    @Test("Malformed persistence falls back to defaults")
    func malformedDataFallsBack() throws {
        let fixture = try makeDefaultsFixture()
        defer { fixture.defaults.removePersistentDomain(forName: fixture.suiteName) }
        fixture.defaults.set(Data("not-json".utf8), forKey: fixture.persistenceKey)

        let store = PreferencesStore(
            defaults: fixture.defaults,
            persistenceKey: fixture.persistenceKey
        )
        #expect(store.configuration == .defaultValue)
    }

    @MainActor
    @Test("Reset is immediately persistent")
    func resetPersists() throws {
        let fixture = try makeDefaultsFixture()
        defer { fixture.defaults.removePersistentDomain(forName: fixture.suiteName) }

        let store = PreferencesStore(
            defaults: fixture.defaults,
            persistenceKey: fixture.persistenceKey
        )
        #expect(store.setMetric(.storage, enabled: true))
        store.displayMode = .compact
        store.reset()

        #expect(store.configuration == .defaultValue)
        let restoredStore = PreferencesStore(
            defaults: fixture.defaults,
            persistenceKey: fixture.persistenceKey
        )
        #expect(restoredStore.configuration == .defaultValue)
    }

    private func makeDefaultsFixture() throws -> (
        defaults: UserDefaults,
        suiteName: String,
        persistenceKey: String
    ) {
        let suiteName = "CoreMetrics.PreferencesStoreTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        return (defaults, suiteName, "configuration")
    }
}
