# Card Master — Design Document (UX / UI)

## 1. Design principles
1. **Answer one question fast**: "Which card do I use for this?" — reachable in ≤2 taps from launch.
2. **Cards look like cards**: realistic gradient card faces, so recognition is visual, not textual.
3. **Numbers with context**: never show "₹58,000" alone; show "₹58,000 left to waive fee · 74 days".
4. **Calm, private feel**: dark-first, no ads, no clutter, masked numbers by default.

## 2. Visual system
- **Framework**: Material 3 (`useMaterial3: true`) with a custom `ColorScheme.fromSeed`.
- **Theme**: Dark default. Light theme is a Phase 4 item.
- **Colour tokens** (all text pairs pass 4.5:1):

  | Token | Hex | Use |
  |---|---|---|
  | background | `#0E0F13` | screen |
  | surface | `#171922` | tiles, lists |
  | surfaceHigh | `#14161D` | bottom nav, bottom sheets |
  | track | `#262938` | progress-bar tracks, ring backgrounds |
  | primary | `#6A5AE0` | filled buttons, FAB (white text = 5:1) |
  | primaryContainer | `#2A2550` / `#1F1B3A` | selected nav pill, selected rows |
  | onPrimaryContainer | `#B7ACFF` / `#D4CCFF` | links, accent text |
  | textPrimary / textSecondary | `#F2F3F7` / `#9AA0B4` | body / captions |
  | earned | `#3DD68C` on `#15261E` | rewards, best-card highlight |
  | attention | `#F5B54A` on `#3A3320` | fee waiver, "Verify" chips |
  | danger | `#FF6B6B` / `#FF8A8A` on `#3A1F24` | caps full, due soon, ineligible |
- **Typography**: Manrope, bundled in `assets/fonts/` (NOT the `google_fonts` package — it downloads at runtime). Scale: Display 28/800 · Title 24/800 · Heading 16/700 · Body 14/600 · Caption 12/500 · Nav label 11/600. Numbers use tabular figures and Indian grouping (`NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0)`).
- **Card faces**: per-card gradient (user-picked or bank default), network logo bottom-right, masked `•••• 4821`, nickname top-left. Aspect ratio 1.586 (ISO ID-1).
- **Motion**: Hero animation card → detail; spring physics on carousel; progress rings animate on first view.
- **Radius**: 20 on cards, 16 on sheets, 12 on chips. Spacing scale 4/8/12/16/24/32.

## 3. Information architecture

```
Lock screen (biometric)
└── Bottom nav
    ├── Wallet (home)
    │   ├── Summary header: total limit · used · utilisation %
    │   ├── Card carousel (swipe) → Card Detail
    │   ├── "Fee waiver" strip (cards nearing anniversary)
    │   └── FAB: + Add card / + Log spend
    ├── Best Card (recommender)
    │   ├── Category grid (Utilities, Airtel, Dining, Fuel, Travel, Foreign, UPI, Shopping…)
    │   ├── Amount input + toggles (UPI? International? Online?)
    │   └── Ranked results with explanation
    ├── Money
    │   ├── Spend log (filter by card/month)
    │   └── Insights (rewards earned, best per category)
    └── Settings
        ├── Security (lock timeout, biometrics)
        ├── Benefits catalog (import/export JSON, view versions)
        ├── Backup (encrypted export / import)
        └── About / privacy statement (Trust Center, see 10)
```

## 4. Key screens

### 4.1 Wallet
```
┌────────────────────────────────┐
│ Good evening, Viraj        🔒  │
│ Total limit  ₹8,50,000         │
│ Used ₹1,12,400 · 13% ▓▓░░░░░░  │
│ ┌────────────────────────────┐ │
│ │ SCAPIA          Federal    │ │  ← swipeable carousel
│ │                            │ │
│ │ •••• 4821            VISA  │ │
│ └────────────────────────────┘ │
│  ● ○ ○                         │
│ ⚠ Airtel Axis: ₹58k to waive   │
│   fee · 74 days left   ◔ 71%   │
│ Quick: [Best card for…]        │
│                       ( + )    │
└────────────────────────────────┘
```

### 4.2 Card detail
- Hero card face at top; below it **stat chips**: Limit · Annual fee · Waiver at · Due day · Statement day.
- **Top benefits** (max 3, highlighted): e.g. Scapia → "0% forex markup", "Unlimited domestic lounge (spend-gated)", Airtel Axis → "25% on Airtel bills via Airtel Thanks".
- **Benefits by category** — expandable sections; each row: icon, title, rate, cap, conditions, `lastVerified` chip (amber "Verify" if stale). Long-press → edit.
- **Fee waiver ring** + milestone bars.
- **This month**: spend on this card, cap consumption per benefit.

### 4.3 Add card (3-step bottom sheet)
1. Search/select bank (logos grid) → 2. select variant (shows catalog preview of benefits) → 3. personalise (nickname, last 4, limit, statement/due day, anniversary month, colour). "Custom card" path skips catalog.

### 4.4 Best Card
- Big category tiles; amount keypad; toggles.
- Result list: rank, card face mini, **effective return** (₹ and %), reason line, warning line ("Cap reached this month", "Not usable on UPI — Mastercard").

## 5. Accessibility & safety UX
- All amounts readable by TalkBack with currency words.
- Min touch target 48dp, contrast ≥ 4.5:1.
- Masked digits unless user taps "reveal" (requires re-auth if lock older than 60s).
- `FLAG_SECURE` on every screen.

## 6. Brand
See the "Brand" board on the design canvas.
- **Mark**: two fanned cards (teal `#1C8C7A` behind, violet `#7C6CF2` in front with a cut-out outline in the background colour) plus a gold 4-point spark `#F5B54A`, meaning "the card the app picks for you". Built on a 120×120 grid.
- **Wordmarks** (each has one job, never swapped):
  - **C, primary**: `card ✦ master`, Unbounded 700, gold 4-point spark between the words. Used in the app header (Wallet), the Play listing, and anywhere the name appears inline. In Flutter: a `Row` of two `Text` widgets with the spark as a `CustomPaint` or SVG between them.
  - **B, splash lockup**: `CARD` (Unbounded 500, 12px letter-spacing, muted) over `MASTER.` (Unbounded 800, gold full stop). Used only on Splash, Unlock and About, always under the big mark.
  - Option A (gradient "cardmaster") is not used.
- **Fonts**: Unbounded is used only for the logo and splash; Manrope is the UI font. Both are bundled as assets (SIL OFL licence).
- **App icon**: Android adaptive icon. Foreground = the mark, background = `#6A5AE0`, plus a monochrome layer for Android 13 themed icons. Generate it with `flutter_launcher_icons` (dev dependency, runs at build time, no network at runtime) from a 1024 px PNG/SVG export.
- **Splash**: `flutter_native_splash`, background `#0E0F13`, mark centred.
- **Name risk**: "Card Master" is close to the "Mastercard" trademark. Fine for a personal APK, but rename before any Play Store release.

## 7. Card faces (look like the physical card, without copying bank artwork)
See the "Card faces" board on the design canvas.

**Styled face (default).** Rendered by a `CardFace` widget from catalog data, with:
- real-card details: EMV chip (gold/silver), contactless symbol, embossed-style last 4 or a "numberless front"
- finish: `matte` (flat colour), `metal` (brushed stripes), `gloss` (light sheen that moves with the phone's motion sensor, via `sensors_plus`), `pattern` (circles/waves/lines)
- the bank and variant name in plain text, the network name as plain-text wordmark
- landscape or portrait orientation (some cards are vertical)

Catalog: `"face": {"finish","base","ink","chip","numberless","orientation"}`. Users can change any of these.

**Photo face (optional).**
1. In-app camera (`camera` package, not `image_picker`), so nothing is saved to the gallery. A card-shaped guide frame helps alignment.
2. Required privacy step: a blur box is pre-placed over the usual number position. The user drags it and can add boxes for name/expiry. "Blur & save" burns the blur into the pixels (`image` package), downsizes to 1012×638, and saves the result as AES-GCM encrypted bytes in app-private storage. The full-quality original lives only in memory and is discarded.
3. The face switcher (Styled / Photo) is on the card's edit screen. Deleting the card deletes the photo file.
Later option: on-device OCR (ML Kit, bundled model) to place the blur boxes automatically. Its library manifest adds INTERNET, so it needs the `tools:node="remove"` rule below.
