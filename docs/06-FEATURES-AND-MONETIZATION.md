# Card Master — More Features & How It Makes Money

Confidence tags: [Certain] hard evidence · [Likely] strong inference · [Guessing] filling gaps.

## 1. The constraint that shapes everything
The app's promise is now "your data never leaves the phone" (download-only: the app fetches the signed benefits catalog and never uploads anything, see 07). Ads are discarded. Every money idea below is checked against it.

| Model | Fits the promise? | Verdict |
|---|---|---|
| Ad-supported (AdMob etc.) | **No.** Needs INTERNET; ad SDKs collect device IDs; Data safety becomes "data shared" [Certain] | **Reject** |
| One-time Pro unlock (Play Billing) | Yes. Billing runs through the Play Store app over IPC; the app only needs `com.android.vending.BILLING` [Likely; verify on device with INTERNET removed] | **Primary** |
| Subscription | Weak. There is no ongoing service (no server, no sync) to justify it [Likely] | Skip at launch |
| Card referral suggestions (affiliate) | Fits technically, but needs a regulatory check (RBI card-marketing rules) | **Dropped (safe path)**: suggestions ship with no referral links |
| Tip jar / "Supporter" purchase | Yes | Add with Pro (cheap to build) |
| Selling data | Impossible and against the product | Never |

### 1.1 Pro, a one-time unlock
- **Price** [Guessing, test it]: ₹199 launch, ₹299 regular. Indian users rarely pay subscriptions for utility apps; one-time with a launch discount is the norm.
- **Rule**: anything that protects the user stays free (app lock, encrypted backup, reminders for due dates). Pro sells *insight and convenience*, never safety.
- **Verification**: check the purchase signature on-device with the Play public key. Weaker against piracy than server checks, but you have no server and piracy of a ₹299 niche app isn't worth fighting [Likely].
- **Trial**: all Pro features free for the first 14 days, so users experience the insights before the paywall.

### 1.2 "Cards that would earn you more" (referral suggestions)
- The app already knows (locally) where you spend. It can compute: "With card X, your last 90 days would have earned ₹4,120 more/year after its fee."
- Ranked purely by the user's benefit. (No "Sponsored" label is needed since there are no referral links.)
- Tapping opens the bank/affiliate page **in the browser** (an `ACTION_VIEW` intent). The app itself sends nothing; the browser does, only on tap.
- Card referral commissions in India can be large compared with app prices [Guessing on exact amounts; affiliate networks publish payout tables, so check them].
- **Decision: no referral links.** They would need a regulatory check, and we're taking the safe path. Suggestions stay as a free, unbiased feature with no link and no "Sponsored" label. Revisit only if the app grows enough to afford proper legal advice.

### 1.3 Free vs Pro

| Feature | Free | Pro |
|---|---|---|
| Unlimited cards, catalog, benefits, editing | ✓ | ✓ |
| Best-card recommender | ✓ | ✓ |
| App lock, screenshot block, encrypted backup/restore | ✓ | ✓ |
| Due-date reminders | ✓ | ✓ |
| Styled card faces | ✓ | ✓ |
| Photo card faces / import card image | | ✓ |
| Spend log | Current month only | Full history |
| Fee-waiver progress | ✓ | ✓ |
| Milestone tracker | | ✓ |
| Cap tracking (monthly caps used) | | ✓ |
| "Is this card worth keeping?" report | | ✓ |
| Missed-rewards insights | | ✓ |
| Statement PDF import | | ✓ |
| Home-screen widgets | | ✓ |
| Card suggestions (§1.2) | ✓ (it's the second revenue line, so keep it free) | ✓ |

## 2. New features

### Tier 1 (high value, fully offline, build next)
1. **Interest-free days optimiser** [Certain the maths works]: from each card's statement and due day, show "Use Airtel Axis today → 48 days to pay; Scapia → 21 days". Free, and unique among most card apps.
2. **"Is this card worth keeping?"** yearly report: rewards earned + benefit value (lounges used × value) − annual fee − forex fees paid = net. Verdicts: Keep / Downgrade / Close. Includes a reminder before the anniversary. (Pro)
3. **Reward points wallet**: points balance per card, value per point (editable), expiry dates with reminders, "₹ value of all points". (Pro)
4. **Lounge tracker**: visits used this quarter/year, spend-gated eligibility ("Spend ₹18,000 more this quarter to unlock lounge access next quarter"). (Pro)
5. **Lost card emergency button**: bank helpline numbers stored in the catalog → one tap opens the phone dialer (no internet needed). Free, a big trust-builder.
6. **Merchant memory**: when logging a spend, the app learns "Swiggy → Food delivery" so the category is pre-filled next time.

### Tier 2
7. **Statement PDF import**: you pick your monthly statement PDF; the app extracts transactions on-device (PDF text extraction + per-bank parsers) and logs spends automatically. Big convenience, big build effort (one parser per bank). Password-protected PDFs: ask for the password, never store it. (Pro)
8. **Travel mode**: switch it on before a trip; the Best card screen defaults to Foreign, and you see each card's forex markup + reward rate as a single "true cost abroad".
9. **Offers vault**: save bank sale offers (e.g. "10% off on X with HDFC during sale") with an expiry; they show up in Best card for that merchant.
10. **Home-screen widgets**: "Best card for…" quick buttons and a due-dates widget. (Pro)
11. **EMI tracker**: active EMIs per card, months left, how much of the limit they block.
12. **Utilisation coach**: per-card and overall, with "pay ₹X before the statement date to report under 30% utilisation" [Likely helps the credit score; bureaus see the statement balance].

### Tier 3 / later
13. Hindi and other Indian-language UI.
14. Add-on/family cards sharing one limit.
15. "Close this card" checklist (clear dues, redeem points, cancel standing instructions, get the closure letter).
16. **Dropped**: SMS inbox reading and notification auto-capture (see 08). Safe path only.

## 3. Revenue reality check [Guessing; these are planning numbers, not a forecast]
- Organic installs for a niche finance utility without marketing: low thousands in year one.
- At a 2–4% Pro conversion, that's tens to low hundreds of purchases: pocket money, not a salary.
- With referral links dropped, Pro + coffee tips are the only income.
- So: build Pro because it's simple and honest; treat card suggestions as the real upside; never add ads.

## 4. Build impact
- `in_app_purchase` (official Flutter plugin for Play Billing). Products: `pro_lifetime`, `supporter_tip`.
- A `Entitlement` provider: `isPro` computed from the purchase or the trial start date (stored encrypted).
- Every Pro feature checks `ref.watch(entitlementProvider)` and shows the upgrade screen instead of an error.
- No referral fields in the catalog.
