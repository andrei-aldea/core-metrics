# Website-agent handoff

Updated September 12, 2026 from the current Mac app and final local validation. This replaces the September 6 website-building brief, including its obsolete missing-site/link statements. The text below is ready to paste into the existing website task.

---

Update the existing Core Metrics website’s copy and UI to match the current Mac app. Implement and verify the changes in your website project. Use this handoff as the product reference; it supersedes earlier briefs that described three modes, smaller Compact text, or missing in-app website links. Inspect the existing website first and preserve its working stack, branding, routes, approved publisher information and maintained locales.

PRODUCT AND RELEASE STATUS

- Public product name: Core Metrics: Mac Stats. Use Core Metrics naturally in the interface and copy.
- A focused native macOS menu-bar utility showing current aggregate CPU, memory and startup-volume storage readings.
- Requires macOS 27 or later on a compatible Apple silicon Mac. There is no Intel, iPhone, iPad or Windows app.
- Intended App Store price: Free. There are no purchases, subscriptions, ads, accounts or app sign-in.
- The app is still preparing for its App Store release. The existing macOS 1.0 record is in Prepare for Submission, with no selected build or listing screenshots at the last September 12 review. The owner chose to keep local development identity/signing for now.
- Do not claim it is released, approved by Apple, available worldwide or downloadable today. Use a restrained “App Store release in preparation” state until availability and the real public destination are confirmed. Do not invent a release date, download link, store badge, reviews or ratings.
- “Launch at Login” means opening the app when the person signs into macOS. It does not mean a Core Metrics account. Apple’s private App Review contact fields are unrelated to customer sign-in and must not appear as a website login requirement.

CURRENT PUBLIC ROUTES — ALREADY LINKED FROM THE MAC APP

- Product: https://core-metrics.dorobantimedia.com/en
- Support: https://core-metrics.dorobantimedia.com/en/support
- Privacy Policy: https://core-metrics.dorobantimedia.com/en/privacy

Keep these exact destinations working over HTTPS without authentication. Preserve existing localized routes and canonical/locale behavior. The native app already opens Support from Settings and Privacy Policy from its Privacy sheet. Descriptions saying these links still need to be implemented are obsolete.

THE MAIN PRODUCT CHANGES TO REFLECT EVERYWHERE

1. Four display modes are available for every selection of one to seven stats:
   • Label and Value — readable metric names followed by their values.
   • Compact — shorter labels followed by the same complete values.
   • Icon and Value — the category icon before each value: CPU, Memory or Storage. Multiple selections in one category each receive that category’s icon.
   • Values Only — just the selected values and their units, with no visible label or icon.

2. All four modes use the same native 12-point text size. Labels use the system font; values use its tabular-digit variant. Compact saves space through abbreviations, not smaller text, condensed fonts, reduced weight or omitted units. Icons use a matching size and baseline. Every mode uses the same inter-stat spacing and locale-aware value columns. For an unchanged selection/mode/locale, changing readings does not resize the app’s reserved menu-bar allocation; changing configuration can resize it.

3. Values Only now supports multiple stats, up to seven. Adding or removing a stat preserves the chosen display mode. Selection order is always CPU → Memory → Storage, including the order within each category listed below; it is not a draggable custom ordering feature. Fresh preferences start with CPU User in Label and Value mode. The person’s selections and display mode are saved locally for the next launch.

4. Settings now uses a native 580-point-wide window with vertical scrolling and a horizontally scrollable Live Preview. Four native radio choices appear immediately below that preview. Settings also includes selected rows with remove controls, Add Stat, optional Launch at Login, Privacy, Metric Help, Support and Restore Defaults. Do not use screenshots showing the old three-mode picker or oversized Settings presentation.

5. First-time Launch at Login registration was fixed. A previously unseen registration now allows an explicit enable attempt instead of disabling the control. It remains optional and initially off for an unregistered app. macOS owns its actual registration and approval state; Settings explains pending approval/errors and provides access to Login Items settings. Restore Defaults resets menu-bar preferences, not login registration. The developer’s installed copy being enabled does not change the default for new users.

EXACT STAT NAMES AND COMPACT CODES

There are 15 available stats; users select at least one and at most seven, including several from the same category.

CPU: CPU Used (C%), CPU User (CU), CPU System (CS), CPU Idle (CI).
Memory: Memory Used (MU), Memory Used (%) (M%), Wired Memory (MW), Compressed Memory (MC), Cached Files (CF), Swap Used (SW), Physical Memory (PM).
Storage: Storage Used (SU), Storage Used (%) (S%), Storage Free (SF), Storage Total (ST).

Use Memory and Storage consistently. Do not call storage “SSD”: the app does not identify hardware type. Selection controls and copied/spoken readings distinguish the (%) variants. The full menu-bar labels omit that parenthesized marker because the value already shows a percent sign. Compact codes are stable and must not be invented or translated without app changes.

METRIC MEANINGS AND LIMITS

- CPU combines all cores into a total of 100%. CPU Used is User plus System; User, System and Idle form the total. These are aggregate readings, not per-process or per-core lists.
- Memory Used excludes free memory and cached files. Its percentage compares that amount with installed Physical Memory. A high used percentage alone does not establish memory pressure.
- Wired Memory must remain in RAM. Compressed Memory is RAM occupied by compressed data. Cached Files is reclaimable file-backed memory. Swap Used is disk space used for memory management. These categories overlap and should not be added together as a partition of total RAM.
- Storage describes the startup volume only. Used is Total minus Free; Used (%) is the corresponding fraction. Free is the file system’s reported available capacity and can differ from Finder estimates including reclaimable space. The app does not scan files, classify storage, report purgeable space or monitor every attached drive.
- CPU and memory refresh about every two seconds; storage about every thirty seconds. Say “current readings” or “regular updates,” not instantaneous or continuous measurement.
- A dash means unavailable. CPU needs an initial baseline after launch or a sampling gap. Swap can be unavailable while other memory readings remain valid. Failures clear stale values and retry.
- Percentages show whole numbers; byte values retain one decimal place and their units. Memory scales by 1,024; storage by 1,000. The app uses compact B/KB/MB/GB/TB/PB/EB labels. Numbers follow the person’s locale; that does not mean the app has translated UI in every language. There are currently no bundled app translations.
- No metric history is retained. Do not add history graphs, performance scores, memory-pressure gauges or screenshots implying these features. Avoid claims of exact agreement with Activity Monitor.

ACTUAL USER FLOW

Launch Core Metrics and find its readings in the menu bar; there is intentionally no Dock icon or main app window. Click the readings to open the selection panel. Its CPU, Memory and Storage checkbox groups stay open while selections change. The selectors do not duplicate live numeric readings next to every checkbox.

The panel footer contains exactly Settings, Copy Readings and Quit in one row. Display-mode controls and Metric Help belong in Settings, not in the panel. Clicking Settings closes the panel and opens or raises native Settings. Ordinary outside clicks, Escape and a second single click on the status item dismiss the panel. Do not promise rapid-double-click behavior.

Copy Readings copies full selected names and current locale-aware values on an explicit click, regardless of the visible display mode. The button says Copied after success without moving the adjacent controls. Copying replaces the clipboard contents and includes no machine identity or timestamp.

Long selections can exceed the menu-bar space available beside a notch or other items. Do not promise that every seven-stat selection always fits, that values automatically shrink, or that the app removes selected readings. Narrower modes or fewer selections use less space. Opening the already-running app again in Finder opens Settings even if its menu-bar item is hidden. Live Preview can scroll horizontally to show the full selection.

PRIVACY AND PRODUCT BOUNDARIES

The app reads aggregate metrics locally through public Apple APIs and is sandboxed. Current readings remain in memory; only menu-bar selection and display preferences are saved locally. macOS separately manages login registration. The app has no network client, telemetry, tracking, analytics, accounts or third-party SDKs. App-authored diagnostic messages contain only metric category and availability state and are not transmitted by the app.

Support and Privacy Policy links open fixed public URLs in the person’s browser without attaching readings or preferences. Explicit clipboard copying is managed by macOS, which may share it through enabled Universal Clipboard.

Do not introduce claims or product visuals for temperature, fan control, GPU/battery/network monitoring, cleaning, optimization, process inspection/killing, file scanning, malware detection, privileged helpers, hardware tuning, cloud sync, accounts or history. Macs Fan Control was only a visual sizing reference; it is not an integration or affiliation. Do not claim zero resource use, guaranteed speed/battery improvements, complete accessibility certification or bug-free operation.

Keep app privacy, website visitor processing and support correspondence distinct. The proposed App Store Data Not Collected response concerns the app; it is not a blanket claim that the website/host/email provider collects nothing. The current public policy is still a publisher draft. Verify hosting/email practices and obtain missing publisher facts before finalizing it. Do not invent names, public contacts, retention periods, effective dates, legal guarantees or regulatory compliance. Preserve existing approved facts and flag only unresolved ones. Private App Review contacts must not automatically become public website contacts.

WEBSITE COPY AND UI WORK

- Audit the homepage, feature sections, mode demonstrations, screenshots/captions, onboarding, FAQ, Support, Privacy, navigation/footer, SEO/social metadata and every maintained site locale for outdated or conflicting claims.
- Explain the purpose immediately. A suitable direction is “Your Mac’s readings, in the menu bar.” Show the platform requirement, intended free price and honest release status clearly.
- Update any mode selector/demo to all four exact modes. A comparison should keep the same stats and values while changing only the representation. Preserve equal typography across modes. The native 12-point rule applies to the app illustration; it does not mean shrinking website body text to 12 pixels. Scale an illustration uniformly if necessary.
- Keep the product recognizable as a focused Mac menu-bar utility. Use the existing visual identity, approved app icon, readable system-style typography, restrained colors and generous spacing. Improve the existing responsive UI without turning the product into a dashboard.
- Use approved, real screenshots of the current app for screenshot claims. Never pass off an AI-generated image, obsolete UI or automated-test fixture as a current app screenshot. A clearly labeled code-rendered demo may use illustrative sample values, but must not imply it reads visitors’ hardware. If current captures are unavailable, complete the surrounding work and list the precise captures needed.
- Support should cover finding the app, selecting stats, four modes, crowded menu bars/Finder reopen recovery, unavailable readings, memory/storage interpretation, Copy Readings, Metric Help, Launch at Login approval, Restore Defaults and Quit.
- Keep Support and Privacy easily reachable. Use the approved public support destination. Suggest app/macOS version and a brief reproduction description; do not request credentials, device identifiers or uncensored logs/screenshots.
- Do not introduce accounts, waitlists, contact forms, tracking, third-party fonts or new data processing without an existing authorization and a reviewed need. Preserve the project’s established deployment workflow and prior authorizations.

VERIFICATION AND HANDOFF

Check desktop and narrow layouts, all four demo modes, keyboard navigation, visible focus, meaningful headings/labels, contrast, reduced motion, image alternatives, navigation and the exact Support/Privacy URLs. Check for clipping, stale three-mode copy, old smaller-Compact claims, broken links and false download/availability metadata. Run the website project’s relevant checks and inspect the resulting pages in a browser.

For internal context only: the latest local Mac build passed Debug/Release builds, 171 unit-test executions, all 12 desktop tests, analysis and sandbox/privacy packaging checks on Xcode 27 RC. Real login registration survived an app relaunch and app replacement. A full logout/login cycle, the wider accessibility/display matrix and some runtime diagnostics remain unresolved. This is not App Store approval or a website marketing claim.

Complete the website changes and return a reviewable preview, a concise description of changed pages, verification results, and a separate list of missing publisher facts/assets. Apply any existing publishing authorization from your task; otherwise leave a concrete preview for approval. Do not alter the Mac app, signing, App Store account or publisher declarations as part of this website work.
