# Architecture Decisions

## ADR-001 — Native dependency-free application

**Decision:** Build Core Metrics with Swift, SwiftUI, Foundation, SF Symbols, and documented Apple system APIs, with no third-party dependencies.

**Reasoning:** The product is small, privacy-sensitive, Mac App Store-bound, and fully covered by platform frameworks. A minimal dependency surface improves auditability, launch cost, and long-term maintenance.

**Alternatives considered:** Cross-platform UI frameworks and third-party system-monitor packages.

**Consequences:** Platform behavior remains native and the code owns a few thin system API adapters. Any future dependency requires an explicit new decision.

## ADR-002 — Layered providers with pure calculations

**Decision:** Separate raw system acquisition, pure snapshot calculations, sampling coordination, observable application state, and presentation.

**Reasoning:** Mach counters are cumulative and error-prone; keeping their math pure allows deterministic fixtures and fast parallel tests. UI code remains readable and sandbox/API audits stay localized.

**Alternatives considered:** Reading metrics directly from SwiftUI views or a single global monitoring singleton.

**Consequences:** There are several small focused types, but no broad framework or excessive protocol hierarchy.

## ADR-003 — Current snapshots only

**Decision:** Retain only the latest CPU, memory, and storage snapshots. Do not build or retain chart history in version 1.

**Reasoning:** The menu-bar utility is most useful as a fast numeric glance. Removing charts and their buffers reduces sampling-side work, presentation code, memory use, and binary surface while matching the requested minimalist interface.

**Alternatives considered:** Bounded in-memory charts, UserDefaults arrays, files, SwiftData, and a database.

**Consequences:** The app presents current values only and has no historical trend view.

## ADR-004 — macOS 27 minimum and platform-native appearance

**Decision:** Set the minimum deployment target to macOS 27 across the app, unit-test, and UI-test configurations. Build the interface from standard SwiftUI controls and platform chrome, letting the system provide its current material appearance. The status item uses the native window presentation so macOS owns its Liquid Glass popover. Custom content stays on one clear plane. Do not add custom blur stacks or decorative glass replicas.

**Reasoning:** The product explicitly requires macOS 27 and can therefore use one current UI baseline without availability branches for older releases. Apple's [Liquid Glass adoption guide](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass) says standard controls adopt the current appearance automatically, and its [custom-view guidance](https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views) warns against excessive effects and containers.

**Alternatives considered:** Retaining the former macOS 14 compatibility range; adding version-specific appearance branches; manually recreating platform materials.

**Consequences:** The binary cannot launch on macOS 26 or earlier. UI code and testing are simpler, but every release must validate the platform glass, semantic monochrome hierarchy, and legibility on macOS 27 with light/dark appearance, Increased Contrast, Reduce Transparency, Reduce Motion, and supported accessibility text sizes.

## ADR-005 — Menu-bar-only primary lifecycle

**Decision:** Use [`MenuBarExtra`](https://developer.apple.com/documentation/swiftui/menubarextra) as the primary scene with `.menuBarExtraStyle(.window)`, set [`LSUIElement`](https://developer.apple.com/documentation/bundleresources/information-property-list/lsuielement) to `true`, and expose a SwiftUI [`Settings`](https://developer.apple.com/documentation/swiftui/settings) scene through [`SettingsLink`](https://developer.apple.com/documentation/swiftui/settingslink) inside the extra. Keep live metric values in the status item and configuration in the persistent panel or Settings; do not retain a separate detailed window or expose an `isInserted` switch in version 1.

**Reasoning:** Apple explicitly supports a menu-bar-only `MenuBarExtra`, recommends `LSUIElement` for hiding its Dock and app-switcher presence, and identifies window style for data-rich extras with standard controls. A pull-down menu necessarily closes after a toggle on macOS; the window style keeps multi-selection controls available and still uses system presentation. Persisting `isInserted = false` could leave a relaunched menu-only app with no recoverable scene.

**Alternatives considered:** A permanent Dock icon, runtime activation-policy changes, AppKit `NSStatusItem`, a separate on-demand metrics window, and a persistently hideable extra.

**Consequences:** Direct customization, display mode, Settings, and Quit remain available in a persistent status panel, while live values appear only in the status item. Relaunch, label updates, Settings activation, fixed-width behavior, and behavior when menu-bar space is constrained require real-app testing.

## ADR-006 — Activity Monitor-aligned memory categories

**Decision:** Define Cached Files from the public file-backed `external_page_count`, define Memory Used as physical total minus free and cached bytes, and read Swap Used through the public `CTL_VM` / `VM_SWAPUSAGE` sysctl. Clamp all physical-memory arithmetic defensively. Treat a failed swap read as a partial-value failure rather than discarding Memory Used and Cached Files.

**Reasoning:** Apple's [Activity Monitor guide](https://support.apple.com/guide/activity-monitor/view-memory-usage-actmntr1004/mac) defines the three requested categories. The documented [`vm_statistics64_data_t`](https://developer.apple.com/documentation/kernel/vm_statistics64_data_t) and Apple's public XNU `sysctl.h` expose corresponding aggregate counters without process inspection or private frameworks.

**Alternatives considered:** The former App Estimate + Wired + Compressor approximation, parsing command output, inspecting Activity Monitor, private frameworks, and treating swap failure as failure of the entire memory sample.

**Consequences:** The categories and units align with Activity Monitor, but independently timed samples can differ briefly. Documentation must not claim that Core Metrics reads Activity Monitor's private implementation.

## ADR-007 — Conservative macOS privacy manifest

**Decision:** Include `PrivacyInfo.xcprivacy` with Disk Space reason `85F4.1`, User Defaults reason `CA92.1`, and `NSPrivacyTracking = false`; declare no collected data or tracking domains.

**Reasoning:** Apple's [privacy manifest overview](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files) currently omits macOS from its Required Reason mandate, but the covered Foundation APIs give generic declaration warnings and Apple defines a macOS manifest location. These two approved reasons exactly describe user-visible disk capacity and app-only settings; no reason is invented.

**Alternatives considered:** Omitting a manifest from the macOS-only target; adding unrelated File Timestamp or System Boot Time reasons.

**Consequences:** The manifest and Apple's [`NSPrivacyAccessedAPIType`](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitype) list must be re-audited at submission and whenever covered APIs change.
