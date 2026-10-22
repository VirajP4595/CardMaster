# Card Master — Product Plan

A private-by-design Android app (Flutter) that works offline to track your credit cards, see what each card is good for, and pick the right card at the moment of payment.

## 0. Hard rules (non-negotiable)

| # | Rule | How it is enforced |
|---|------|--------------------|
| R1 | **Download-only.** User data never leaves the phone. The only network use is downloading the public, signed benefits catalog (and Play Billing via the Play Store app). Nothing is ever uploaded. | INTERNET permission allowed, but all network code lives in one module (`core/net`) doing GET requests to one allow-listed host; no analytics/ads/crash SDKs; no Google sign-in; requests carry no user or device identifiers. See 07-PRO-AND-ONLINE.md. |
| R2 | No cloud backup of any kind | `android:allowBackup="false"` and `android:fullBackupContent="false"` + `dataExtractionRules` excluding everything. Otherwise Android silently copies app data to Google Drive. |
| R3 | Never store full card number or CVV | Model only has `last4`. CVV field does not exist in the schema. (Storing CVV is forbidden by PCI-DSS even for banks.) |
| R4 | Encrypted at rest | SQLite3MultipleCiphers (via `package:sqlite3` hooks); key held in Android Keystore via `flutter_secure_storage`. |
| R5 | Lock screen | Biometric/device-PIN unlock on open and after N seconds in background; `FLAG_SECURE` blocks screenshots and recents thumbnail. |
| R6 | No analytics / crash SDKs | No Firebase, no Sentry. Dependency allow-list reviewed per release. |
| R7 | Safe path only: no restricted or sensitive permissions (SMS, call log, notification access, accessibility, contacts), no referral links, nothing that triggers extra Play review or audits | Permission list reviewed per release (see 04 §6) |

## 1. Benefits go stale (now solved by catalog sync, see 07)

Banks change card benefits several times a year (devaluations, caps, excluded categories). A bundled benefits catalog will be wrong within months and the app cannot fetch updates. Mitigation:

1. **Seed catalog** shipped as a JSON asset, each benefit tagged with `sourceNote` + `lastVerified` date.
2. **Every benefit is user-editable** — the catalog is a starting point, your copy is the truth.
3. **Staleness badge**: benefits not verified in >180 days show "Verify".
4. **Catalog sync**: signed catalog updates are downloaded automatically (07 §2), with a "What changed" screen. Update the JSON yourself or share one with friends.

## 2. Feature roadmap

### Phase 1 — MVP (≈1–2 weekends)
- Add card: pick **bank → card variant** from catalog (e.g. Axis → Airtel Axis, Federal → Scapia), or create a custom card.
- Card fields: nickname, network (Visa/MC/RuPay/Amex/Diners), last 4 (optional), credit limit, statement day, due day, annual fee, fee-waiver spend threshold, card anniversary month, color/theme.
- Card detail screen: visual card + benefit list grouped by category (Rewards, Forex, Lounge, Fee waiver, Fuel, Insurance, Milestones).
- Home: wallet carousel of cards, total credit limit across cards.
- Local encrypted storage, app lock, network limited to the catalog download.

### Phase 2 — "Which card should I use?" (the killer feature)
- Enter a purchase: category (Utilities, Airtel bill, Dining, Fuel, Foreign, UPI, Online shopping, Rent, Insurance…) + amount + optional "via UPI".
- App ranks your cards by effective return, respecting: reward rate, monthly caps, excluded categories, UPI eligibility (only RuPay credit cards work on UPI), forex markup.
- Shows *why*: "Airtel Axis: 10% on utilities via Airtel Thanks, cap ₹250/month, ₹180 left this month".

### Phase 3 — Spend tracking & fee waiver
- Manual spend log per card (amount, category, date) — quick-add from home.
- **Fee-waiver progress ring**: "₹1.42L of ₹2L spent — ₹58k left, 74 days to anniversary".
- Milestone tracker (e.g. "spend ₹X in a quarter → bonus points/voucher").
- Monthly cap usage per benefit.
- Utilisation per card and overall (spend ÷ limit), with a warning above 30%.

### Phase 4 — Reminders & insights (all local)
- Local notifications (`flutter_local_notifications`, no FCM): due-date reminder, statement generated, fee-waiver deadline, "lounge visits reset this quarter".
- Insights: rewards earned this year, best card per category, cards that don't earn their annual fee.
- Encrypted export/import (`.cardmaster` file, AES-GCM with a passphrase) for moving phones — user carries the file, the app never uploads.

### Phase 5 — Nice-to-have
- Home-screen widget: "Best card for…" quick buttons.
- Compare two cards side-by-side.
- ~~SMS parsing via `READ_SMS`~~ **dropped** (rule R7); see 08 for share/clipboard/backup-file import instead. (was: sideload builds only).

## 3. Milestones & definition of done

| Milestone | Done when |
|-----------|-----------|
| M1 Skeleton | `flutter build apk` succeeds; merged manifest contains only approved permissions; app lock works |
| M2 Cards CRUD | Add/edit/delete cards from catalog + custom; persists across restarts, DB file is unreadable without key |
| M3 Benefits | Detail screen shows grouped benefits; edit benefit; staleness badge |
| M4 Recommender | Unit-tested engine; ranked results with explanation |
| M5 Spend & waiver | Spend log, waiver ring, caps consumed |
| M6 Reminders & backup | Local notifications; encrypted export/import round-trip test |

## 4. Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Catalog data wrong/outdated | Wrong card recommended → lost rewards | `lastVerified`, editable benefits, file import |
| Phone lost, no backup | All data gone | Encrypted export reminder every 30 days |
| A dependency adds network code | Privacy violation | Only `core/net` may touch the network (build test + in-app network log); audit `pubspec.lock` |
| Over-engineering before use | Never ships | Ship Phase 1 and use it for 2 weeks before Phase 2 |

## 5. Play Store readiness (target: someday, so design for it now)

| Area | Requirement | Plan |
|------|-------------|------|
| Name | Must not be confusable with an existing trademark | "Card Master" / "Card Master" is close to "Mastercard", which is also shown inside the app. **Pick a new name before the first public build**; check the Indian trademark registry (ipindia.gov.in) and search Play. |
| Bank/network logos & card artwork | Owned by banks/networks; using them breaks Play's impersonation and IP rules | Ship none. Styled faces + optional user photo (see 02-DESIGN §7). Network names as plain text only. |
| Package | App Bundle, not APK | `flutter build appbundle --release`; keep sideload APK builds for yourself |
| Target SDK | Must meet Play's current target-API requirement (it goes up each year) | Bump `targetSdk` each release cycle |
| Data safety form | Must be accurate | "No data collected, no data shared". True because the app only downloads a public file and uploads nothing. |
| Privacy policy URL | Required (and the camera permission makes it doubly so) | One static page (e.g. GitHub Pages): what's stored, that it never leaves the device |
| Financial features declaration | Required for finance-category apps | Declare "personal finance management, no loans, no payments" |
| New personal developer account | Must run a closed test with a minimum number of testers for a minimum period before production (the numbers have changed over time, so check them in Play Console) | Recruit friends early; this takes weeks |
| Permissions | Minimum needed, none restricted | INTERNET, ACCESS_NETWORK_STATE, CAMERA (optional photo face), USE_BIOMETRIC, POST_NOTIFICATIONS, RECEIVE_BOOT_COMPLETED. Use inexact alarms (WorkManager) instead of SCHEDULE_EXACT_ALARM, which Play also reviews [Likely]. |
