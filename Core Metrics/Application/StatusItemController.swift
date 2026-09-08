import AppKit
import Observation
import SwiftUI

/// Owns the actual status-bar allocation. Samples change only the native title;
/// selection, representation and locale changes may change its reserved width.
@MainActor
final class StatusItemController: NSObject, NSStatusItemExpandedInterfaceDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let metricsStore: MetricsStore
    private let preferencesStore: PreferencesStore
    private var panelPresenter: StatusPanelPresenter?
    private var observationTask: Task<Void, Never>?
    private var localeTask: Task<Void, Never>?
    private var renderedConfiguration: MenuBarConfiguration?
    private var layout = MenuBarLabelLayout(locale: .current)

    init(
        metricsStore: MetricsStore,
        preferencesStore: PreferencesStore,
        openSettings: OpenSettingsAction,
        writeToClipboard: @escaping @MainActor (String) -> Bool
    ) {
        self.metricsStore = metricsStore
        self.preferencesStore = preferencesStore
        super.init()
        panelPresenter = StatusPanelPresenter(
            openSettings: openSettings,
            metricsStore: metricsStore,
            preferencesStore: preferencesStore,
            writeToClipboard: writeToClipboard,
            onClose: { [weak self] in self?.statusItem.expandedInterfaceSession?.cancel() }
        )
        statusItem.expandedInterfaceDelegate = self
        statusItem.button?.alignment = .left
        statusItem.button?.setAccessibilityIdentifier("coreMetrics.statusItem")
        observePresentation(locale: .current)

        let notifications = NotificationCenter.default.notifications(
            named: NSLocale.currentLocaleDidChangeNotification
        )
        localeTask = Task { @MainActor [weak self] in
            for await _ in notifications {
                guard !Task.isCancelled else { return }
                self?.observePresentation(locale: .current)
            }
        }
    }

    deinit {
        observationTask?.cancel()
        localeTask?.cancel()
    }

    func stop() {
        observationTask?.cancel()
        observationTask = nil
        localeTask?.cancel()
        localeTask = nil
        dismissPanel()
        NSStatusBar.system.removeStatusItem(statusItem)
    }

    func dismissPanel() {
        panelPresenter?.close()
        statusItem.expandedInterfaceSession?.cancel()
    }

    func statusItem(
        _ statusItem: NSStatusItem,
        didBegin expandedInterfaceSession: NSStatusItemExpandedInterfaceSession
    ) {
        guard let button = statusItem.button else {
            expandedInterfaceSession.cancel()
            return
        }
        panelPresenter?.show(relativeTo: button)
    }

    func statusItemDidEndExpandedInterfaceSession(_ statusItem: NSStatusItem, animated: Bool) {
        panelPresenter?.close()
    }

    private func observePresentation(locale: Locale) {
        observationTask?.cancel()
        layout = MenuBarLabelLayout(locale: locale)
        renderedConfiguration = nil
        let metrics = metricsStore
        let preferences = preferencesStore
        let presentations = Observations {
            StatusItemPresentation(
                configuration: MenuBarConfiguration(
                    enabledStats: preferences.enabledStats,
                    displayMode: preferences.displayMode
                ),
                cpuUsage: metrics.cpuUsage,
                memoryUsage: metrics.memoryUsage,
                storageUsage: metrics.storageUsage,
                locale: locale
            )
        }
        observationTask = Task { @MainActor [weak self] in
            for await presentation in presentations {
                guard !Task.isCancelled else { return }
                self?.render(presentation)
            }
        }
    }

    private func render(_ presentation: StatusItemPresentation) {
        guard let button = statusItem.button else { return }
        if renderedConfiguration != presentation.configuration {
            // Leave native button padding on both sides. A positive length
            // prevents AppKit from sizing the item to each changing title.
            statusItem.length = layout.width(
                stats: presentation.configuration.enabledStats,
                displayMode: presentation.configuration.displayMode
            ) + 16
            renderedConfiguration = presentation.configuration
        }
        button.attributedTitle = layout.attributedTitle(
            stats: presentation.configuration.enabledStats,
            values: presentation.values,
            displayMode: presentation.configuration.displayMode
        )
        button.toolTip = presentation.accessibilitySummary
        button.setAccessibilityLabel(presentation.accessibilityLabel)
        button.setAccessibilityTitle(presentation.accessibilityLabel)
    }
}
