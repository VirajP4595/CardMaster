# Card Master — Architecture Document

## 1. Stack

| Concern | Choice | Why |
|---------|--------|-----|
| UI | Flutter 3.x, Material 3 | Already installed on your machine; single codebase |
| State | `flutter_riverpod` (+ `riverpod_generator`) | Testable, no BuildContext coupling |
| Navigation | `go_router` | Declarative, deep-linkable (widgets) |
| DB | `drift` + `sqlcipher_flutter_libs` | Typed SQL, migrations, encrypted file |
| Key storage | `flutter_secure_storage` (Android Keystore) | DB key never in plain prefs |
| App lock | `local_auth` | Biometric / device credential |
| Screenshot block | `MainActivity` sets `FLAG_SECURE` (5 lines of Kotlin) | Avoid an extra plugin |
| Notifications | `flutter_local_notifications` + `timezone` | Local only, no FCM |
| Models | `freezed` + `json_serializable` | Immutable models, catalog JSON parsing |
| Charts | `fl_chart` | Pure Dart, offline |
| Backup crypto | `cryptography` (AES-GCM + Argon2id/PBKDF2) | Passphrase-encrypted export |
| File pick/save | `file_picker` | User-initiated import/export |
| Card photo | `camera` + `image` | In-app capture, number blurred into the pixels, encrypted file |
| Gloss effect | `sensors_plus` | Tilt-reactive sheen on card faces |

Banned: `google_fonts`, `firebase_*` (analytics/crashlytics), any ads/analytics/attribution SDK. Allowed for network: `http` (catalog GET only, in `core/net`) and `in_app_purchase`. Not allowed: `google_sign_in`, `googleapis` or any upload code.

## 2. Layering (feature-first, clean-ish)

```
lib/
├── main.dart                     # bootstrap: lock → open DB → runApp
├── app/
│   ├── router.dart
│   ├── theme.dart
│   └── lock_gate.dart            # re-auth on resume after timeout
├── core/
│   ├── db/                       # drift database, tables, migrations
│   ├── security/                 # key mgmt, secure storage, local_auth wrapper
│   ├── money.dart                # integer paise, formatting (₹1,23,456)
│   └── result.dart
├── data/
│   ├── catalog/                  # assets/catalog/*.json loader + importer
│   └── repositories/             # CardRepo, BenefitRepo, SpendRepo
├── domain/
│   ├── models/                   # Card, Benefit, Spend, Bank (freezed)
│   └── engine/
│       ├── recommender.dart      # pure Dart, 100% unit-tested
│       └── fee_waiver.dart
└── features/
    ├── wallet/  (screens + providers)
    ├── card_detail/
    ├── add_card/
    ├── best_card/
    ├── money/
    └── settings/
assets/
├── catalog/catalog_v1.json
├── fonts/
└── bank_logos/
```

Rule: `domain/` imports nothing from Flutter. `features/` only talk to repositories through providers.

## 3. Data model

Money stored as **integer paise** (no floating point). Rates stored as basis points (1% = 100 bps).

```text
banks(id TEXT PK, name, logo_asset)

card_products(                     -- catalog: one row per variant
  id TEXT PK,                      -- "federal_scapia", "axis_airtel"
  bank_id FK, name, network,       -- VISA|MASTERCARD|RUPAY|AMEX|DINERS
  default_annual_fee_paise, default_waiver_spend_paise,
  catalog_version INT, is_custom BOOL)

benefits(
  id TEXT PK, product_id FK,
  category TEXT,                   -- UTILITIES|TELECOM_AIRTEL|DINING|FOREX|UPI|FUEL|LOUNGE|...
  kind TEXT,                       -- CASHBACK|POINTS|FOREX_MARKUP|LOUNGE|WAIVER|INSURANCE|INFO
  rate_bps INT NULL,               -- 2500 = 25%
  point_value_paise INT NULL,      -- for POINTS kind
  monthly_cap_paise INT NULL,
  min_txn_paise INT NULL,
  channel TEXT NULL,               -- e.g. "Airtel Thanks app"
  conditions TEXT, source_note TEXT,
  last_verified DATE, user_edited BOOL)

user_cards(
  id TEXT PK (uuid), product_id FK,
  nickname, last4 CHAR(4) NULL,    -- NEVER full PAN, NEVER CVV
  credit_limit_paise, statement_day, due_day,
  anniversary_month, annual_fee_paise, waiver_spend_paise,
  color_hex, sort_order, created_at, archived BOOL,
  face_finish, face_base_hex, face_ink_hex, face_chip, face_numberless BOOL,
  face_photo_path NULL)        -- encrypted, number already blurred

user_card_benefit_overrides(user_card_id, benefit_id, ...same columns...)

spends(id PK, user_card_id FK, amount_paise, category, via_upi BOOL,
       is_international BOOL, note, spent_on DATE)

reminders(id PK, user_card_id FK, type, fire_at, enabled)
```

Overrides let you correct a benefit for *your* card without mutating the shared catalog, so a catalog re-import doesn't wipe your edits.

## 4. Catalog JSON (asset + importable)

```json
{
  "version": 1,
  "generatedOn": "2026-10-22",
  "banks": [{"id": "axis", "name": "Axis Bank"}, {"id": "federal", "name": "Federal Bank"}],
  "products": [
    {
      "id": "axis_airtel", "bankId": "axis", "name": "Airtel Axis Bank Credit Card",
      "network": "MASTERCARD", "annualFeePaise": 50000, "waiverSpendPaise": 20000000,
      "benefits": [
        {"id": "axis_airtel_airtel_bills", "category": "TELECOM_AIRTEL", "kind": "CASHBACK",
         "rateBps": 2500, "channel": "Airtel Thanks app", "monthlyCapPaise": 25000,
         "lastVerified": "2026-10-01", "sourceNote": "Bank MITC — VERIFY"},
        {"id": "axis_airtel_utilities", "category": "UTILITIES", "kind": "CASHBACK",
         "rateBps": 1000, "channel": "Airtel Thanks app", "monthlyCapPaise": 25000,
         "lastVerified": "2026-10-01", "sourceNote": "VERIFY"},
        {"id": "axis_airtel_other", "category": "OTHER", "kind": "CASHBACK", "rateBps": 100,
         "lastVerified": "2026-10-01", "sourceNote": "VERIFY"}
      ]
    },
    {
      "id": "federal_scapia", "bankId": "federal", "name": "Scapia Federal Bank Credit Card",
      "network": "VISA", "annualFeePaise": 0,
      "benefits": [
        {"id": "scapia_forex", "category": "FOREX", "kind": "FOREX_MARKUP", "rateBps": 0,
         "lastVerified": "2026-10-01", "sourceNote": "VERIFY"}
      ]
    }
  ]
}
```
All numbers above are **placeholders to verify against each bank's current MITC/website** before trusting them.

## 5. Recommender engine (pure function)

```
input : Purchase{category, amountPaise, viaUpi, international, date}
        List<UserCardWithBenefits>, Map<benefitId, capUsedThisMonthPaise>
output: List<Recommendation{card, effectiveReturnPaise, effectiveBps, reasons[], warnings[]}>

for each card:
  if viaUpi and card.network != RUPAY        -> ineligible ("UPI needs RuPay credit card")
  b = most specific benefit matching category (fallback OTHER)
  if b has min_txn and amount < min          -> fall back to OTHER
  reward = amount * rate_bps / 10000  (POINTS: * point_value)
  if cap: reward = min(reward, cap - capUsed); warn if exhausted
  if international: reward -= amount * forex_markup_bps / 10000  (default 350 bps if unknown)
sort by reward desc, then by lower utilisation
```
Unit tests: one per rule (UPI gate, cap exhaustion, forex deduction, min-txn, fallback).

## 6. Security architecture

```
First launch:
  key = 32 random bytes (Random.secure)
  flutter_secure_storage.write("db_key", base64(key))   # wrapped by Android Keystore
Each launch:
  local_auth.authenticate(biometricOnly:false)  -> fail = stay on lock screen
  key = secure_storage.read("db_key")
  open drift NativeDatabase with PRAGMA key
On pause > timeout: drop decrypted state, show LockGate
```

Android manifest (release, `android/app/src/main/AndroidManifest.xml`):
```xml
<!-- Online-lite (see 07-PRO-AND-ONLINE.md): INTERNET is allowed, but -->
<uses-permission android:name="android.permission.INTERNET"/>
<application android:networkSecurityConfig="@xml/network_security_config" ...>
<!-- network_security_config.xml: cleartextTrafficPermitted="false" everywhere.
     Audit merged manifests every release for permissions libraries sneak in. -->
<application
    android:allowBackup="false"
    android:fullBackupContent="false"
    android:dataExtractionRules="@xml/data_extraction_rules" ...>
```
Note: Flutter's template adds INTERNET in `src/debug` and `src/profile` manifests (needed for hot reload). That's fine — only the release manifest matters. Verify after each build:
```
aapt2 dump permissions build/app/outputs/flutter-apk/app-release.apk
```
(Should list only `USE_BIOMETRIC`, `POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`/`RECEIVE_BOOT_COMPLETED` if reminders are on.)

`FLAG_SECURE` in `MainActivity.kt`:
```kotlin
class MainActivity : FlutterFragmentActivity() {   // FragmentActivity required by local_auth
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)
    }
}
```

## 7. Testing
- `domain/` unit tests (recommender, waiver, money formatting) — target 90%+.
- Repository tests with in-memory drift DB.
- Widget tests for Add-card flow and Best-card result list.
- Release checklist: permission dump, `allowBackup` check, `strings` grep of APK for `http` hosts, R8 enabled.
