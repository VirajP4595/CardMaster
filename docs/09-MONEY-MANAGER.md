# Card Master — Money Manager (card-first)

Goal: people log **every** expense here easily, not just card spends, while card rewards stay the reason the app exists.

## 1. Scope

| In | Out (on purpose) |
|---|---|
| Expenses from any payment method: cards, UPI from a bank account, cash | Bank balances, transfers between accounts, net worth |
| Monthly budgets per category | Investments, loans, income tracking (maybe later) |
| Recurring expenses (rent, subscriptions, EMIs) | Bill payment (would need a licence + server) |
| "Which card would have earned more" on every expense | Splitting bills with friends (needs accounts/sync) |
| Monthly and category summaries, CSV export to a local file | Anything that uploads (rule R1) |

Why not a full money manager [Likely]: dedicated budgeting apps already do balances and net worth well; copying them dilutes the card focus and multiplies the build.

## 2. The quick-add screen (canvas board 11)
One screen, no navigation, under 5 seconds for a normal entry:
1. **Big keypad**, amount at the top (Indian grouping as you type). `00` key for round amounts.
2. **Category chips**: last-used first; long-press to add a new one.
3. **"Paid with" chips**: your cards + `UPI · bank` + `Cash`. Pre-selected: the matched card (from SMS share), else the best card for the category, else the last method used.
4. **Live hint** under the chips:
   - green "Best choice: earns ₹45 (10%)" when you picked the best card
   - amber "Earns ₹5. Airtel Axis would earn ₹45" when a better card exists
   - amber "Paying with Airtel Axis would earn ₹45" for UPI/cash
5. **Note** (optional, feeds merchant memory) and **date** (defaults to today).
6. **Save** → "Saved ✓ Add another" so batches are fast.

Entry points: the + on the Money tab, the Wallet's + menu, the home-screen widget, the Quick Settings tile, and Android's share sheet (SMS text).

## 3. Money tab (was "Activity")
- Month switcher, total spent across all methods, rewards earned.
- **Budgets this month**: bar per category, `spent / budget`. Green < 85%, amber 85–100%, red over (with "over" label). Categories without a budget show as plain bars.
- Insight card (missed rewards), recent expenses list, "+ Add expense".
- Filters: by payment method, by category.

## 4. Data model changes
```text
payment_methods(id PK, kind TEXT,          -- CARD | BANK_UPI | CASH
                user_card_id FK NULL,      -- set when kind = CARD
                name TEXT, color_hex, sort_order, archived BOOL)

spends: user_card_id → payment_method_id   -- every expense has a method
spends += note TEXT, recurring_id FK NULL

budgets(id PK, category TEXT, month_start DATE NULL,  -- NULL = every month
        amount_paise INT)

recurring(id PK, title, amount_paise, category, payment_method_id,
          rule TEXT,                       -- MONTHLY:5 (5th of month), YEARLY:03-15 …
          next_due DATE, auto_add BOOL)    -- auto_add=false → reminder "Add rent ₹25,000?"
```
Card benefit maths (caps, fee waivers, milestones) only looks at spends whose method `kind = CARD`.

## 5. Free vs Pro
| Free | Pro |
|---|---|
| Quick add, all payment methods, categories | Recurring expenses (auto-add / reminders) |
| Budgets for up to 3 categories | Unlimited budgets |
| Current + previous month | Full history, trends, year view |
| | CSV export (saved locally via the save dialog) |

## 6. Release
- **1.0**: quick add (cards + UPI + cash), Money tab, 3 budgets.
- **1.1 (Pro launch)**: unlimited budgets, recurring, history, CSV export.

## 7. "You could have earned" nudges (UPI and cash expenses)
Decision: card-first money manager = faster expense entry + show what a card would have earned.

**Where it shows**
- Quick add, live: "Paying with Airtel Axis would earn ₹45".
- Money tab insight card, monthly: "₹12,400 went via UPI and cash this month. On your best cards it would have earned ₹310."
- Expense detail: "Best card for this: Airtel Axis, ₹45 back".

**Rules (so the advice is honest)** [Likely, all of these]
1. **Payments to people** (UPI to a person, or a category of Rent-to-landlord / Transfer): no nudge. A card can't pay them without a fee platform.
2. **UPI at a merchant**: if the user has a **RuPay credit card**, say "Scan with your RuPay card on UPI: earns ₹X". Otherwise suggest a card only if the category is usually card-accepting.
3. **Fees eat the reward**: subtract known costs before claiming a gain. Rent via card platforms charges a fee; fuel has a surcharge (often waived only within a range). If net ≤ 0 → no nudge.
4. **Never encourage spending**: wording is always about the expense already made ("would have earned"), never "spend more". No nudge if the card's utilisation is above 30%, or if its bill is overdue.
5. **Off switch**: Settings → Money → "Show card reward hints" (on by default).
6. Card rates come from the same catalog + user overrides as the Best-card screen, so one source of truth.

**Data**: expenses get a `payee_type` field (`MERCHANT | PERSON | UNKNOWN`, defaults to MERCHANT; Rent/Transfer categories default to PERSON).
