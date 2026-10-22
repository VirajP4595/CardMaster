# Card Master — Getting Expenses In

Card benefits are only useful if the app knows what you spent. Manual entry alone gets abandoned within weeks [Likely], so we need near-zero-effort capture, without breaking "data never leaves the phone" and without Play-restricted permissions.

## 1. What we can't do (in the Play build)

| Idea | Why not |
|---|---|
| Read the SMS inbox (`READ_SMS` / `RECEIVE_SMS`) | Restricted by Play: only the default SMS app or an approved exception [Certain]. Money-management apps have reportedly been approved before, but approval isn't guaranteed and can be revoked [Guessing]. Never make a core feature depend on it. |
| Read Gmail | Needs a *restricted* Gmail scope: OAuth verification + yearly third-party security assessment [Likely]. Too costly, and it brings back an online account link. |
| Bank account aggregator / bank APIs | Needs a licensed partner and a server. Against the download-only rule. |

## 2. Capture methods, in build order

| # | Method | Permission | Effort for user | Release |
|---|---|---|---|---|
| 1 | **Quick add** sheet (3 taps) | none | Type the amount | 1.0 |
| 2 | **Share SMS to Card Master** (Android share sheet) | none | Long-press SMS → Share → Save | 1.0 |
| 3 | **Clipboard pick-up**: on app open, if the clipboard holds a bank message, offer to add it | none (Android 12+ shows a "pasted from clipboard" toast, which is fine) | Copy → open app → Save | 1.0 |
| 4 | **Home-screen widget + Quick Settings tile** → quick add | none | 1 tap to open | 1.2 (widget is Pro) |
| 5 | **Statement PDF import** (Pro) | none (user picks the file) | Monthly, whole statement | 1.2 |
| ~~6~~ | ~~Auto-capture from SMS notifications~~ | Notification access | | **Dropped**: invites Play review scrutiny |
| ~~7~~ | ~~Full SMS inbox import~~ | `READ_SMS` | | **Dropped**: restricted permission, even in a sideload build |

**Decision: safe path only.** Every capture method uses no sensitive or restricted permission, so no declaration forms, no permission reviews, no audits.

## 2b. Bulk import (many messages at once, still no SMS permission)

| Method | How the user does it | Notes |
|---|---|---|
| **Multi-copy → clipboard** | In the messages app, open the bank thread, long-press, select many messages, Copy; open Card Master | The clipboard pick-up splits the text into messages and runs the parser on each. Multi-select copy works in common SMS apps [Guessing; test on Google Messages and Samsung Messages] |
| **SMS backup file** | Export the inbox with an SMS backup app (e.g. "SMS Backup & Restore", XML), then Money → Import → pick the file | Months of history in one go. The XML format of that app is widely documented [Likely]. Parse with a streaming XML reader; only messages from known bank sender IDs (e.g. `*-AXISBK`, `*-HDFCBK`, kept in the catalog) are read, the rest are ignored without being stored |

Both end on the **review screen** (canvas board 12):
- Counts: card spends found / duplicates skipped / OTPs, credits and promos ignored.
- One row per spend with a checkbox: merchant, card (matched by last 4), category, date, amount.
- Unknown last 4 → amber "Card ••5566 not in wallet · pick a card".
- "Import N expenses" saves the ticked rows with `source = CLIPBOARD | SMS_FILE`.
- Duplicate check also runs against spends already in the app (same card, amount, date ±1 day).
- Message text is discarded after parsing; the backup file is never copied into the app.

## 3. On-device SMS parser (shared by share-to-app, clipboard and SMS backup file)

Indian bank alerts follow a few templates per bank. Example shapes (illustrative, not exact bank text):
```
INR 2,400.00 spent on <Bank> Credit Card XX7302 at BESCOM on 21-10-26. Avl Lmt: INR 1,08,600
Rs.1860 debited from card ending 1190 for UPI txn to SWIGGY on 20/10/2026
```
Pipeline (pure Dart, `domain/parsing/`, unit-tested with a corpus of anonymised samples):
1. **Detect**: does the text contain a currency amount + "card"/"XX1234"/"ending 1234"?
2. **Extract** with per-bank regex sets shipped in the **catalog** (so fixes arrive with catalog updates, no app release):
   `{"bankId":"axis","patterns":[{"amount":"…","last4":"…","merchant":"…","date":"…"}]}`
3. **Match card** by `last4` → `user_cards.last4`. No match → ask which card (this is why last 4 is worth entering).
4. **Category** from merchant memory (`merchant_rules` table: "BESCOM" → Utilities), else a keyword list, else ask.
5. **Flags**: `via_upi` if the text mentions UPI; `is_international` if the currency isn't INR or the text says "intl".
6. **Bonus**: "Avl Lmt" in the message → offer to update the card's available limit.
7. **Duplicates**: same card + amount + date within 10 min → "Looks like you already added this".

The raw SMS text is **never stored**, only the parsed fields.

## 4. Quick-add sheet
Amount (big keypad) → category chips (last-used first) → card (pre-selected = best card for that category, or the matched card) → Save. Optional: note, date, UPI/international toggles. After saving, show "+₹240 back" so the user sees the point of logging.

## 5. Data model additions
```text
merchant_rules(id PK, pattern TEXT, category TEXT, user_card_id NULL, hits INT)
spends += source TEXT   -- MANUAL | SHARE | CLIPBOARD | SMS_FILE | PDF
```

## 6. Approved privacy claims (use exactly these)
- ✅ "Your data never leaves your phone."
- ✅ "No account. No tracking. No uploads."
- ✅ "Works fully offline. An internet connection is only used to download card-benefit updates."
- ❌ "Offline-only app", "no internet permission", "100% offline". These are false now.
