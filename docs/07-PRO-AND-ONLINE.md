# Card Master — Pro Plan & Online-Lite Architecture

Decisions so far: **no ad version** · **Pro = one-time purchase** · **download-only: the app fetches the benefits catalog and never uploads anything** · **no Google Drive / cloud backup**.

## 1. What "online-lite" means

| Goes over the network | Never goes over the network |
|---|---|
| `GET` of the public benefits catalog (same file for every user) | Cards, limits, last 4, spends, photos, points, reminders |
| Play Billing (handled by the Play Store app) | Any user ID, device ID, advertising ID, analytics events |
| | Backups: they are only written to a local file/folder the user picks |
| Browser opens when the user taps a card-suggestion link | Which cards the user holds (suggestions are computed on-device) |

Why not full online (accounts + server DB)? [Likely]
- India's DPDP Act 2023 obligations (consent, breach notification, a grievance contact) start the moment you store personal data on a server.
- A server full of people's card data is a breach target and a monthly bill.
- It adds no user value at this stage that online-lite doesn't already give.

## 2. Catalog sync (the main reason to go online)

```
CDN (GitHub Pages / Cloudflare Pages, free)
 ├── catalog/manifest.json      {"latest": 14, "minApp": "1.2.0", "sha256": "...", "sig": "..."}
 └── catalog/v14.json           full catalog, signed
App
 1. On launch (max once per 24 h, Wi-Fi or mobile): GET manifest.json
 2. If latest > local: GET v14.json → verify Ed25519 signature with the public key embedded in the app
 3. Merge into DB: catalog rows replaced; user_card_benefit_overrides untouched
 4. Show "What changed" sheet: "Airtel Axis: food delivery cap ₹500 → ₹400 (from 1 Nov)"
 5. Offline? Keep using the local copy; retry next launch
```
- **Signing** (`cryptography` package, Ed25519): even if the CDN is hacked, a forged catalog is rejected. Keep the private key offline.
- **No identifiers**: plain GET, no cookies, no query params beyond the version. The CDN still sees the IP address. Say so in the privacy policy.
- **Who maintains it** [Certain this is the real cost]: you. Plan a monthly verification pass per card (bank MITC/website) plus urgent updates on devaluations. Start with ~15 popular cards, not 40.
- **Later**: opt-in "Report a change" button that sends only `{productId, benefitId, userText}`, with no personal data. Helps you keep up.

## 3. Pro: product definition

| Item | Decision |
|---|---|
| Model | One-time, non-consumable `pro_lifetime` via Google Play Billing (`in_app_purchase` plugin) |
| Price [Guessing, test it] | ₹199 launch for the first ~2 months, then ₹299. Play auto-converts for other countries. Use Play Console price experiments when there's traffic. |
| Trial | 14 days of all Pro features from first launch, no card details asked. Trial start stored in the encrypted DB (a reinstall resets it; acceptable) |
| Coffee tips | Consumables via Play Billing: presets `coffee_chai` ₹49, `coffee_regular` ₹99, `coffee_snack` ₹199, plus a **Custom** stepper over fixed tiers `tip_29 … tip_999` (₹29, 49, 99, 149, 199, 299, 499, 999). Play products have fixed prices, so a free-typed amount is impossible [Likely]. Unlock nothing; supporters get a ☆ on Settings. **No external donation links** (Buy Me a Coffee, UPI, Patreon): Play's payments policy requires Play Billing for in-app tips to the developer [Likely] |
| Subscription | Not at launch. Revisit only if there's a real recurring cost (e.g. statement-parser maintenance) |
| Refunds | Play handles them; on launch call `queryPastPurchases`, and if `pro_lifetime` is gone, drop Pro (keep the data, lock the screens) |
| Verification | On-device signature check with the app's Play public key. No server [Likely good enough for a ₹299 app] |
| Measuring | No analytics SDK. Play Console already shows installs, conversion and revenue [Certain] |

### 3.1 Free vs Pro (final)

| Free, forever | Pro |
|---|---|
| Unlimited cards, catalog + **automatic benefit updates**, **fee-waiver progress** | "Is this card worth keeping?" yearly report |
| Best-card recommender, interest-free days ("Pay today with…") | Milestone and cap tracking |
| App lock, screenshot block, encrypted export/restore + **weekly auto-export to a folder you pick** | Lounge tracker, travel mode |
| Due-date reminders, lost-card helpline button | Reward points wallet + expiry reminders |
| Styled card faces | Photo / imported card faces |
| Spend log (current month) | Full spend history, missed-reward insights |
| Card suggestions | Statement PDF import |
| | Home-screen widgets |

Principle: free makes the app *trustworthy and useful daily* (so it earns ratings); Pro makes it *save you money and time*.

### 3.2 How the upgrade screen persuades (value first, story second)
1. **The user's own number first**: "During your trial, Card Master found you ₹4,120", computed on the phone from extra rewards vs. a 1% baseline, caps not wasted, and fee waivers on track. If the number is under ₹300, show the feature list first instead (a small number argues against buying).
2. Feature list, price, Unlock button.
3. **"Made by one person"**: a real photo, your name, two honest sentences (no investors, no ads, never sees your data; your support pays for monthly benefit updates). No guilt wording ("please", "I'm struggling").
4. **Buy me a coffee**: ₹49 / ₹99 / ₹199, default ₹99, clearly labelled "a tip, unlocks nothing".
   - Fee note, worded exactly: "Google Play keeps a share of every payment for its fees, and taxes are taken out too. What's left goes into keeping Card Master going." No exact percentage (fees and GST treatment vary) [Guessing], and **never** a pointer to paying outside Play (UPI, website): that's steering and breaks Play's payments policy [Likely].
5. Pro buyers see a one-time thank-you; tippers too. Neither is asked again for 90 days.

### 3.3 Where the upgrade screen appears
1. Tapping any Pro feature → its own teaser first (e.g. the worth-it report with the net value blurred: "Airtel Axis: ₹•,••• net this year"), then the upgrade sheet.
2. Settings → "Card Master Pro".
3. Trial ending: one notification 2 days before, one in-app banner on the last day. No nagging after that.
Never: pop-ups on launch, or locking data the user already entered.

### 3.4 Backup without uploading (free, because it's a safety feature)
- **No cloud backup of any kind.** Decision: the app never uploads.
- **Manual export**: Settings → Backup → Export. The app asks for a passphrase twice, encrypts with AES-GCM (key from Argon2id), and saves `cardmaster-YYYY-MM-DD.cmbackup` through Android's save dialog.
- **Weekly auto-export**: the user picks a folder once (Storage Access Framework, persisted permission). `workmanager` writes a new encrypted file weekly and keeps the last 4. The passphrase is entered once and stored in the Android Keystore so the weekly job can run (trade-off: a person who can unlock the phone could restore it; acceptable, since they could open the app anyway).
- **Nagging, deliberately**: after 30 days without an export, a "Back up now" item appears in Wallet → Needs attention; the Settings backup row turns amber.
- **Phone-to-phone**: Android's device-transfer stays disabled. The DB key lives in this phone's Keystore and can't move, so the export file is the only migration path. Say this during onboarding.
- If the user chooses a cloud folder in the save dialog, that's their choice; the file is already encrypted. The app itself never talks to any storage service.

## 4. Roadmap

| Release | Contents |
|---|---|
| **1.0 Free** | Phase 1–2 features, catalog sync, local backup, no Pro yet. Goal: closed test → production, first ratings |
| **1.1 Pro launch** | Billing, trial, worth-it report, fee-waiver/caps, points wallet, photo faces |
| **1.2** | Statement PDF import (2–3 biggest banks first), widgets, lounge tracker |
| **1.3** | Card suggestions (no referral links, see 06 §1.2) |

## 5. Play Store impact
- **Data safety** [Likely; confirm against Google's current definitions]: "No data collected, no data shared". The only request is a GET of a public file with no user data. Disclose that the catalog host sees IP addresses.
- **Permissions** added: INTERNET (+ ACCESS_NETWORK_STATE for "Wi-Fi only" backup).
- **In-app products** must be set up in Play Console, and the app published to at least a test track, before purchases can be tested.

## 6. Code impact
```
lib/core/net/catalog_client.dart     # the only http user; host allow-list
lib/core/net/signature.dart          # Ed25519 verify
lib/features/pro/entitlement.dart    # isPro = purchased || inTrial
lib/features/pro/paywall_sheet.dart
lib/features/backup/export_service.dart  # manual + weekly auto-export, local only
```
`entitlementProvider` gates every Pro screen; a Pro screen without entitlement shows its teaser + upgrade sheet, never an error.
