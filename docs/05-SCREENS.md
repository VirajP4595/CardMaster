# Card Master — Screen Specifications

Visual mockups: **Card Master Screens** design canvas (https://claude.ai/artifact/BvkVB6EfYGENbxdeNK5wpX). Interactive in Play mode: bottom nav, card tap, add-card variant picker, best-card categories + UPI toggle, settings switches.
All bank rates in the mockups are **sample data**, not verified.

## Navigation map

```
Unlock ──(auth ok)──▶ Wallet ◀─┬─▶ Best card ◀─▶ Money ◀─▶ Settings   (bottom nav, 4 tabs)
                        │      │
                        ├─tap card──▶ Card detail ──edit──▶ Edit card sheet
                        ├─FAB +──▶ Add card: 1 Bank ▶ 2 Variant ▶ 3 Personalise ▶ Wallet
                        └─"Which card?" banner ──▶ Best card
App to background > lock timeout ──▶ Unlock
```

## 1. Unlock
| Element | Spec |
|---|---|
| Hero | Two stacked mini card faces + "Card Master" + one-line tagline |
| Primary action | 88dp fingerprint button; `local_auth.authenticate(biometricOnly: false)` fires automatically on open |
| Fallback | "Use device PIN instead" (device credential, not an app PIN — nothing to store) |
| Trust line | "Your data stays encrypted on this phone" |
| States | Auth failed → shake + "Try again"; 5 failures → OS lockout message; no biometrics enrolled → straight to device PIN |

## 2. Wallet (home)
| Element | Spec |
|---|---|
| Header | Greeting + lock button (locks immediately) |
| Summary tile | Total limit, % used (green < 30%, amber 30–60%, red > 60%), used / available |
| Carousel | `PageView` with `viewportFraction: 0.85`; card face 1.586 ratio; tap → detail (Hero animation); long-press → reorder |
| Needs attention | Max 3 items, sorted by urgency: bill due ≤ 5 days, fee waiver < 90 days with gap, cap about to reset, stale benefits |
| Banner | "Which card should I use?" → Best card |
| FAB | + → Add card |
| Empty state | No cards: illustration + "Add your first card" primary button; carousel and summary hidden |

## 3. Card detail
| Element | Spec |
|---|---|
| Top bar | Back · title · Edit |
| Card face | Full width; digits masked `•••• •••• •••• 7302`; tap to reveal last 4 only (full number is never stored) |
| Stat grid | 3×2: Limit, Annual fee, Waived at, Statement day, Due day, UPI yes/no (derived from network = RuPay) |
| Fee waiver | 76dp ring + "₹X of ₹Y" + "₹Z left · N days to anniversary"; hidden if fee = 0 |
| Benefits | Segmented filter (Rewards / Travel / Fees / Insurance); rows = icon, title, condition line, rate; "Verify · N mo old" chip if `lastVerified` > 180 days; long-press → edit sheet |
| Caps this month | One bar per capped benefit; red when full |
| Footer | "Sample rates / Long-press to edit" (shown until the user verifies each benefit once) |

## 4. Add card (3-step sheet)
1. **Bank** — grid of bank logos + search; "Other bank" at the end.
2. **Variant** — list of variants with mini face + one-line tag; radio selection; bottom sheet previews top benefits; "My card isn't listed" → custom card.
3. **Personalise** — nickname, last 4 (optional, `maxLength: 4`, digits only), limit, statement day, due day, anniversary month, annual fee + waiver spend (pre-filled from catalog, editable), colour picker.
Validation: limit > 0; days 1–31; save disabled until valid. On save → Wallet, new card centred in carousel.

## 5. Best card
| Element | Spec |
|---|---|
| Categories | 3-col grid of chips (Utilities, Airtel bill, Food delivery, Foreign, Shopping, Fuel, Rent, Insurance, Travel, Other); last used first |
| Amount | Numeric keypad sheet; default = last amount |
| Pay-via toggle | Card / UPI. UPI → non-RuPay cards show "ineligible" with the reason |
| Results | Ranked rows: rank, mini face, name, reason ("10% back · via Airtel Thanks"), warning (cap left / cap full / excluded), ₹ value + effective %. #1 has green border |
| Foreign | Net = reward − forex markup; negative shown in red ("−₹60") |
| Logic | See Architecture §5; caps use this month's logged spends |

## 6. Money (was Activity), see 09-MONEY-MANAGER.md
| Element | Spec |
|---|---|
| Month switcher | ‹ Oct 2026 › |
| Summary | Spent · Rewards earned (+ effective %) |
| By category | Horizontal bars, max 6, rest grouped as "Other" |
| Insight card | Missed-reward nudge: compares each spend to the best card at that time |
| Recent | Colour stripe = card colour; title, card · date, amount, reward earned; swipe to delete; "+ Log spend" opens quick-add sheet (amount, category, card pre-selected = best card, UPI toggle, date) |

## 7. Settings
| Section | Items |
|---|---|
| Privacy banner | "Your data never leaves this phone" + link to Trust Center — always visible |
| Security | App lock, Hide card digits, Block screenshots (`FLAG_SECURE`), Lock again after (immediately / 30 s / 1 min / 5 min) |
| Reminders | Bill due (3 days + 1 day before), Fee waiver alerts (60 days before anniversary) |
| Benefits catalog | Version, last update, "N to verify" chip, See what changed |
| Backup | Last export age (amber after 30 days), Export (asks for passphrase twice), Restore (passphrase, then replace-all confirmation) |
| About | Version, open-source licences, privacy statement |

## Design system
See the "Design system" board on the canvas and the colour/type tables in `02-DESIGN.md`. In Flutter this becomes `lib/app/theme.dart`: a `ThemeData` built from those tokens plus a `ThemeExtension<CardMasterColors>` for earned/attention/danger and their container colours.
