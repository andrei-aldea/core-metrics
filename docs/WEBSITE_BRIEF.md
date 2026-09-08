# Website brief and reusable prompt

Prepared September 6, 2026. The user confirmed the app will be **Free** and that public Support and Privacy pages do not yet exist. This document supplies the requested prompt; no website has been created or published.

Copy the prompt below into a website-building task. Replace the publisher fields when approved information is available. The product facts are sufficient to prepare a local draft while those fields remain pending.

---

Build a simple, polished, accessible English website for **Core Metrics: Mac Stats**, a free native macOS menu-bar utility. Deliver a product landing page at `/`, a support page at `/support`, and a factual privacy-policy draft at `/privacy`. Prepare the website for review first. Do not publish it or change the Mac app unless separately authorized.

## Product facts

Core Metrics shows current aggregate CPU, memory and startup-volume storage readings in the Mac menu bar. It requires **macOS 27 or later on a compatible Apple silicon Mac**. It has no iPhone, iPad or Intel Mac version.

People choose **one to seven statistics** from a persistent selection panel. Choices stay in CPU → Memory → Storage order. The native text label uses normal system typography for names and separators, with tabular-digit live values and locale-aware number formatting. Compact uses a consistent smaller native size for codes, values and separators (11 points on the reviewed runtime); the other modes use the normal 13-point system size. Measured columns are cached for each size and locale. Measured columns align values through changing digits and units, and percent symbols receive a small gap at the visible numeric edge where needed, including right-to-left formats, without replacing locale-owned spacing or changing the formatted text. The app reserves space for the selected configuration so changing values do not request a new width. The current revision passed local stability, three-stat full-name and seven-stat Compact checks on the reviewed display. Use approved current screenshots and keep claims within that verified scope; never promise every long selection fits beside a notch or other menu-bar items.

- CPU: Used, User, System and Idle percentages across all cores. Used is User plus System; User, System and Idle together total 100%.
- Memory: Memory Used, Memory Used (%), Wired Memory, Compressed Memory, Cached Files, Swap Used and Physical Memory. These categories overlap; used percentage is not a memory-pressure reading.
- Storage: Storage Used, Storage Used (%), Storage Free and Storage Total for the startup volume. This reads aggregate volume capacity; it does not scan files or classify storage contents, or determine whether the hardware is an SSD.

Use those names consistently in screenshots and help text. The menu bar uses Memory Used and Storage Used for both representations because live values already show byte units or a percent sign. Selection controls, copied readings and spoken summaries retain the (%) distinction. Existing compact codes remain unchanged.

CPU and memory refresh about every two seconds; storage about every thirty seconds. A dash means unavailable. CPU needs an initial sample before showing usage. Memory uses units scaled by 1,024; storage uses 1,000. No metric history is saved.

The app opens in the **menu bar**, with no main window or Dock icon. Clicking its readings opens the persistent selection panel. If a long selection is hidden by limited menu-bar space, opening the already-running app again in Finder opens native Settings, where the person can choose Compact or fewer readings. Its footer contains exactly **Settings**, **Copy Readings** and **Quit**. Settings includes a horizontally scrollable Live Preview, Menu Bar Text choices, selection controls, optional Launch at Login, Metric Help, Privacy and Restore Defaults. There is no panel-level Metric Help or About button in the current design.

Menu Bar Text supports **Label and Value**, **Compact**, and **Value Only** when one stat is selected. Copy Readings copies the full selected names and current values only when clicked. Launch at Login starts off for an unregistered app and reflects macOS registration/approval state. Restore Defaults resets menu-bar preferences, not login registration. The app has no purchases, subscription, ads, accounts, network connections, tracking or analytics. Do not describe it as a cleaner, optimizer, process manager or hardware tuner, or invent performance/energy-saving claims.

The App Store listing exists in preparation. **Do not claim the app is available to download yet.** The confirmed intended price is Free. Use a restrained “App Store release in preparation” message until the publisher confirms availability. Add a download button or official store badge only when the real destination and release state are verified.

## Pages and design

**`/` — Product.** Explain the purpose immediately: current CPU, memory and disk readings in the menu bar. Show the platform requirement, intended free price, a short feature overview and a clear three-step flow: launch, select readings, customize in Settings. Include a small screenshot gallery, a link to Support and a link to Privacy. A suitable draft headline is “Your Mac's readings, in the menu bar.” Avoid exaggerated claims and unnecessary technical implementation details.

**`/support` — Practical help.** Provide the approved public support contact and concise answers covering: finding the app after launch; selecting stats; changing display mode; finding Metric Help; interpreting unavailable values; startup-volume free space differing from Finder estimates; long labels on crowded menu bars and reopening the running app in Finder to reach Settings; Copy Readings replacing clipboard contents; optional Launch at Login approval; restoring defaults; and quitting. For support requests, suggest app/macOS versions and a short reproduction description. Do not request credentials, full logs, device identifiers or uncensored desktop screenshots. Prefer an approved email link over a contact form; adding a form requires a separately reviewed data-handling plan.

**`/privacy` — Clear, scoped privacy information.** Write an understandable factual draft for publisher review, with distinct sections for the Mac app, website visitors and support correspondence. Include the approved publisher identity, contact and effective date. Do not invent legal guarantees, retention periods, regulatory compliance, international-transfer arrangements or user-rights procedures.

Use a restrained monochrome visual style, generous spacing, readable system fonts and semantic HTML. Support narrow screens, keyboard navigation, visible focus, meaningful headings and links, sufficient contrast, reduced motion and descriptive image alternatives. Do not imitate a complex Mac dashboard or add charts. Prefer a small static site without third-party fonts, analytics, advertising, embedded trackers, signup forms or unnecessary scripts. Choose hosting only after the publisher approves it.

Use only approved app-icon assets and **real screenshots of the current app**, with the native text label and the Settings / Copy Readings / Quit footer. Useful images show the selection panel, Settings preview/customization and Metric Help opened from Settings. Keep text readable and exclude personal desktop/account content. Do not generate fake app screenshots, fabricate metrics or reuse obsolete UI. If approved assets are missing, leave clearly labeled placeholders in the local review build; do not publish placeholder images as product evidence.

## Privacy facts and boundaries

The app reads aggregate system values locally. Current readings remain in memory; only menu-bar selection and display preferences persist in app-scoped storage. macOS manages optional login registration. Local diagnostic messages contain only metric category and availability state; the app does not transmit them. Copy Readings writes to the system clipboard on request. macOS manages that clipboard and may share it between the person's devices through enabled Universal Clipboard.

These app facts support the proposed App Store **Data Not Collected** response. That response is currently a saved draft, not a published declaration. It does **not** establish that the website or support service processes no personal data.

Website hosting may process visitor IP addresses, request information or access/security logs. Support email may include sender addresses, message content and attachments. Confirm the actual hosting/email providers, configuration, purposes, access and retention with the publisher before describing them. Do not state “we collect nothing” for the entire website/business, promise that the host keeps no logs, or invent a deletion schedule. Avoid unnecessary tracking technologies; if the chosen setup uses cookies or similar storage, document the actual behavior and obtain appropriate review. Keep unknown facts visibly pending in the review draft.

Apple requires a public Privacy Policy URL for macOS and an easily accessible policy link inside the app. The current in-app Privacy sheet contains local information but no public policy link. The final website should provide the approved URL for a **future, separately authorized app change**; creating this website does not add that link to the app. The Support URL must lead to a usable support destination with contact information. Verify current Apple requirements before final handoff: [app information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information), [support fields](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information), [Review Guideline 5.1.1(i)](https://developer.apple.com/app-store/review/guidelines/#data-collection-and-storage), and [app privacy definitions](https://developer.apple.com/app-store/app-privacy-details/).

## Publisher inputs

Keep these as explicit placeholders until the publisher supplies and approves them. Never infer identity or contact details from the repository, computer account, Git history or signing configuration.

| Placeholder | Needed information |
| --- | --- |
| `{{PUBLIC_HTTPS_ORIGIN}}` | Approved public HTTPS domain/origin; no invented example domain |
| `{{PUBLISHER_PUBLIC_NAME}}` | Approved public publisher identity |
| `{{PUBLIC_SUPPORT_CONTACT}}` | Approved public contact address/details; distinct from private App Review contact |
| `{{PRIVACY_CONTACT}}` | Approved privacy contact, which may match Support if confirmed |
| `{{COPYRIGHT_OWNER_AND_YEAR}}` | Approved owner and copyright year; preserve existing asset notices |
| `{{PRIVACY_EFFECTIVE_DATE}}` | Publisher-approved effective date for the reviewed policy |
| `{{HOSTING_AND_EMAIL_PRACTICES}}` | Actual providers, relevant data processing and verified retention practices |
| `{{APP_STORE_URL}}` | Verified real public listing URL, when available; do not construct one from guesses |
| `{{APPROVED_ASSETS}}` | Approved icon/screenshots and confirmation they may be used publicly |

## Deliverables

Provide the responsive website source, locally reviewable pages, final page copy and a short list of unresolved publisher inputs. Verify navigation, keyboard use, readable layouts, screenshot accuracy and the absence of broken or invented links. Keep the privacy page explicitly a draft until factual and publisher review is complete. Do not claim legal compliance or accept terms for the publisher.

After separate publishing authorization and validation, return the actual public HTTPS URLs for `/`, `/support` and `/privacy`, plus the verified support destination. The Support and Privacy pages must be reachable without signing in. Identify which URLs belong in App Store Connect and which Privacy URL needs to be added to the app later. Until then, report those URLs as pending; do not present a local preview as a published site.

---

The accompanying [listing draft](APP_STORE_LISTING_DRAFT.md) contains the prepared store copy and screenshot plan. This prompt is self-contained and does not require a future website builder to access the app's source.
