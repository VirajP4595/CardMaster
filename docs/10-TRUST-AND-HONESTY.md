# Card Master — Trust & Honesty

Positioning: **"Private by design. Works offline."** Trust is the product. Every claim must be true, and users should be able to verify it themselves.

## 1. Principles
1. **Say the cost, not just the benefit.** Every privacy decision is explained as *why* + *what it costs you*.
2. **Never overstate.** Use only the approved claims (08 §6). "Offline-only", "100% offline" and "no internet" are banned because the app downloads benefit updates.
3. **Let people check.** In-app network log, permission list matching Android Settings, plain-language privacy policy, honest Play Data safety form.
4. **Ask for permissions in context**, with a one-line reason, only when the feature is first used (except Internet and boot, which Android grants at install).
5. **No dark patterns.** No pre-ticked consent, no guilt copy, no hidden "Sponsored", no fake urgency on the Pro screen except the real launch price end date.

## 2. Where users see it
| Place | What | Canvas board |
|---|---|---|
| First launch | 3 screens: "Your data stays on this phone" → "Honest trade-offs" → "Keep a backup. Seriously." (last one picks the weekly backup folder) | 0 · First launch |
| Settings banner | Promise + "Why we built it this way →" | 7 · Settings |
| Trust Center | Promise · decisions with WHY/COST · permissions with reasons + "never asked for" · network log · "Don't just trust us. Check." | 13 · Trust Center |
| Permission prompts | One line before the Android dialog (texts below) | — |
| Play listing | First line of the description = the promise; a "What we don't do" bullet list | — |
| Pro screen | "Made by one person", Play fee note | 8 · Pro |

## 3. Decisions with their costs (exact copy)
| Decision | Why | Cost |
|---|---|---|
| No account, no server | Nothing about you exists on the internet, so it can't be hacked, leaked or sold. | No sync between devices. Your phone is the only copy. |
| No cloud backup | Your data never sits on someone else's computer, ours or Google's. | If you lose your phone without a backup file, your data is gone. Turn on weekly backups. |
| We don't read your SMS | Reading every message would give the app access to OTPs and private chats. | You share or copy bank messages yourself. It takes a few taps. |
| Only the last 4 digits | Even if someone opened the app, they can't use your card. | You can't copy your full card number from here. |
| Benefit updates are downloaded | Banks change rewards often; stale data would give you wrong advice. | Like any website visit, our server sees your phone's internet address (IP), but nothing about you or your cards. |

## 4. Permission rationale strings (shown before the Android prompt)
- **Notifications**: "So we can remind you before bills are due and before fee-waiver deadlines. Nothing else."
- **Camera**: "To photograph your card's front. We'll blur the number before saving, and the photo never leaves this phone."
- **Biometrics**: "So only you can open Card Master."
- **Never asked for** (listed in the Trust Center): SMS, contacts, location, call logs, notification access, accessibility, photos/gallery. "If an update ever asks for one of these, something is wrong. Please tell us."

## 5. Network log (verifiability feature)
- `core/net` writes one row per request: time, method, host, path, response size, result. No request bodies exist (GET only).
- Table: `network_log(id, at, method, host, path, bytes, status)`, kept 90 days, shown in the Trust Center, exportable as text.
- A unit test fails the build if any code outside `core/net` imports `package:http` or opens a socket.
- Optional later: open-source `core/net` (or the whole app) so the claim is independently checkable [Guessing: many paid apps on Play are open source; decide later, it doesn't block anything].

## 6. Privacy policy outline (one page, plain language)
1. What we collect: nothing. There's no account and no server storing your data.
2. What stays on your phone: cards (last 4 only), spends, budgets, photos (number blurred), all encrypted.
3. What goes over the internet: downloads of the public benefits file. The host sees your IP address, as any website does. We don't log or keep it beyond the host's standard access logs [state your host's actual retention].
4. Purchases: handled by Google Play under Google's privacy policy. We receive no payment details.
5. Backups: files you create and store where you choose. We never see them.
6. Contact: [your email].

## 7. Release checklist additions
- [ ] Every user-facing claim matches §3 and 08 §6 wording.
- [ ] Trust Center permission list matches the merged manifest exactly.
- [ ] Network log shows only catalog GETs after a full test pass.
- [ ] Play Data safety answers re-checked against Google's current definitions.
