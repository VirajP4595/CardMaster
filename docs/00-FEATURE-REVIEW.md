# Card Master — Feature Review (single source of truth)

Positioning: **Private by design. Works offline.** Card-first money manager. Download-only, safe path (R1–R7).
Canvas: https://claude.ai/artifact/BvkVB6EfYGENbxdeNK5wpX (board numbers in brackets).

## 1. Release 1.0 — Free (first public release)
| Area | Feature | Board / doc |
|---|---|---|
| Trust | First-launch: 3 honest screens, ends by choosing the backup folder | [0] · 10 |
| Trust | Trust Center: promise, WHY/COST decisions, permission reasons, "never asked for", network log | [13] · 10 |
| Security | Biometric/PIN lock, re-lock timer, screenshot block, encrypted DB, last-4 only | [1] · 01 R3–R5 |
| Cards | Add card: bank → variant → personalise; custom card | [4] · 05 §4 |
| Cards | Styled card faces (matte/metal/gloss/pattern, chip, contactless, portrait) | Card faces · 02 §7 |
| Cards | Wallet: total limit + utilisation, carousel, "Needs attention" | [2] |
| Cards | Card detail: stats, benefits by category, "Verify" badges, edit benefits | [3] |
| Benefits | Signed catalog sync + "What changed" | 07 §2 |
| Benefits | Best-card recommender: categories, UPI/RuPay rule, caps, forex | [5] |
| Benefits | "Pay today with…": interest-free days per card | [9] · 06 |
| Money | Quick add: keypad, categories, cards + UPI + cash, live reward hint | [11] · 09 |
| Money | Money tab: totals, 3 budgets, monthly "would have earned" | [6] · 09 |
| Capture | Share an SMS to the app, clipboard pick-up (incl. multi-copy), merchant memory, duplicate check | [10] [12] · 08 |
| Reminders | Due dates, backup reminder (inexact, no exact-alarm permission) | 05 §7 |
| Backup | Manual export/restore + weekly auto-export to a chosen folder | 07 §3.4 |
| Safety | Lost-card button → bank helpline in the dialer | [9] |
| Brand | Logo mark, wordmarks C (primary) and B (splash), adaptive icon, splash | Brand · 02 §6 |

## 2. Release 1.1 — Pro launch
| Feature | Free/Pro |
|---|---|
| Play Billing, 14-day trial, upgrade screen with "found you ₹X", made-by-one-person note | — [8] |
| Coffee tips ₹49/99/199 + custom tiers ₹29–999, Play fee note | Tip [8] |
| "Is this card worth keeping?" yearly report | Pro [9] |
| Milestone and cap tracking | Pro (fee waiver is free, D2) |
| Reward points wallet + expiry reminders | Pro |
| Photo card faces (number blurred) / import card image | Pro (Card faces) |
| Unlimited budgets, recurring expenses, full history, CSV export | Pro · 09 |
| SMS backup-file import | Free · 08 §2b |

## 3. Release 1.2 – 1.3 and later
- **1.2**: statement PDF import (Pro), home-screen widgets (Pro) + Quick Settings tile, lounge tracker (Pro), travel mode (Pro).
- **1.3**: card suggestions without referral links, offers vault, EMI tracker, utilisation coach.
- **Later**: Hindi, light theme, add-on cards, card compare, "close this card" checklist, open-sourcing decision.

## 4. Dropped (and why)
| Dropped | Reason |
|---|---|
| Ads / ad-supported version | Needs tracking SDKs; breaks trust |
| Accounts, server database | DPDP Act duties, breach target, no user value |
| Google Drive / any cloud backup | Download-only rule |
| Reading SMS inbox, notification capture, Gmail | Restricted permissions, Play review, audits |
| Referral/affiliate links | Needs regulatory check |
| Bank logos, official card artwork | Banks' IP; Play rejection risk |
| Exact alarms | Reviewed permission; inexact is fine for bills |
| Subscriptions | No recurring service to justify them |
| External tip links (UPI, Buy Me a Coffee) | Play payments policy |
| Full card number, CVV | PCI rules; R3 |

## 5. Open decisions and placeholders
- **D1 Name**: "Card Master" is close to "Mastercard". Fine for building, re-check before Play release.
- **D2 Fee waiver: decided FREE.** Fee-waiver progress (ring, "₹X left · N days") is free; milestones, caps tracking and the worth-it report stay Pro.
- **D3 1.0 scope: decided, the smaller cut in §6.**
- Placeholders: your name, city and photo [8]; your domain [13]; your email (privacy policy); which ~15 cards ship in the first catalog; launch price test.
- Not yet drawn: empty wallet, Add card steps 1 and 3, What-changed sheet, Edit benefit sheet.
- To check on the canvas: Wallet "Needs attention" may push the banner behind the + button.

## 6. 1.0 cut (DECIDED)
§1 is roughly 3–4 months of evenings for one developer [Guessing]. Ship a smaller **1.0** first:
cards + styled faces · fee-waiver progress · benefits + signed sync · best card · interest-free days · quick add (cards/UPI/cash) · share-SMS + clipboard · Money tab without budgets · due reminders · backup (manual + weekly) · lock/encryption · onboarding + Trust Center.
Move to 1.0.x: budgets, multi-copy import, lost-card button, merchant memory.

## 7. Build status (branch `build/v1.0`)

**Built and tested** (92 automated tests; analysis clean; APK built by CI with the permission allow-list check):
- Everything in §1 (1.0) plus, ahead of schedule: monthly budgets, lost-card button, merchant memory.
- From 1.1: worth-it report, caps, reward points wallet (+ expiry reminders), photo card faces (blur burned in, encrypted), recurring expenses, full history, CSV export, SMS backup (XML) import, your own benefits on any card, Pro plumbing (Play Billing, 14-day trial, upgrade screen, coffee tips with custom tiers). **Pro gating is switched off** (`proGatingEnabled` in `lib/app/billing.dart`) until the products exist on Play.
- From 1.2: statement PDF import (beta, generic parser), Quick Settings tile, home-screen widget, lounge tracker, travel mode.
- From 1.3: card suggestions (no links), saved offers, EMI tracker.
- Later list: card comparison, closing checklist, utilisation coach (from logged spends; says so).
- Light theme (Settings → Appearance), Indian comma grouping while typing amounts.
- Infrastructure: weekly automatic backup to Downloads, local reminders, signed benefits publishing (off until the key is created), release APKs on GitHub.

**Not built**
- Hindi / other languages, add-on/family cards.

**Benefits data** (109 cards, 16 banks): researched from search-result snippets — the build environment's network policy blocked every bank website, so no page was opened. Each product and benefit keeps its `sourceUrl` and `confidence: secondary`; `lastVerified` stays null so the app shows Verify. Pipeline: `catalog/cards/<bank>.json` → `tool/build_catalog.dart` (lint + build) → shipped asset and published catalog.

**Needs you**
- Verify the sample benefit rates against each bank's MITC (`catalog/catalog.json`, then bump `version`).
- Create the signing keys (APK: `ANDROID_KEYSTORE_*` secrets; benefits: `CATALOG_SIGNING_KEY` + public key in the app) — see README.
- Re-enable "Read and write permissions" for GitHub Actions so releases publish again (Settings → Actions → General → Workflow permissions).
- Play Console: create `pro_lifetime`, `coffee_*` and `tip_*` products, then set `proGatingEnabled = true`.
- Test on a real phone: share-to-app, notifications, camera, tile and widget can only be checked on a device.
