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

        #expect(store.setStat(.cpuSystem, enabled: true))
        #expect(store.setStat(.memoryUsed, enabled: true))
        store.displayMode = .compact

        #expect(store.enabledStats == [.cpuUser, .cpuSystem, .memoryUsed])
        #expect(store.displayMode == .compact)

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
            enabledStats: [.storageFree, .cpuUser, .memoryCached],
            displayMode: .compact
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

        let repairedData = try #require(
            fixture.defaults.data(forKey: fixture.persistenceKey)
        )
        let repairedConfiguration = try JSONDecoder().decode(
            MenuBarConfiguration.self,
            from: repairedData
        )
        #expect(repairedConfiguration == .defaultValue)
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
        #expect(store.setStat(.storageTotal, enabled: true))
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
