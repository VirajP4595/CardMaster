# Card Master

Private by design. Works offline. A card-first money manager for Android (Flutter): add your credit cards, see their benefits, pick the best card for every spend, and log expenses fast. Your data never leaves your phone.

- Docs: [`docs/`](docs/) (start with [`00-FEATURE-REVIEW.md`](docs/00-FEATURE-REVIEW.md))
- Design: [`design/canvas/`](design/canvas/) (source of the design canvas)

## Status (branch `build/v1.0`)

Built and covered by tests (`flutter test`, 45 tests):
- Encrypted database (SQLite3MultipleCiphers, key in the Android Keystore); a test proves the file is unreadable without the key
- Best-card recommender (UPI/RuPay rule, monthly caps, forex), interest-free days, free fee-waiver progress
- Bank SMS parser (share to app, clipboard, paste; multi-message, dedupe, card match by last 4)
- Download-only benefits client with Ed25519 signature check and a network log; a test fails if any other code uses the network
- Passphrase-encrypted backup export/restore (Argon2id + AES-GCM)
- Local reminders: bills (3 days and 1 day before), fee waiver, backup; inexact alarms only, asked in context
- Weekly automatic encrypted backup to Downloads/Card Master (Android 10+), on app open
- Your own benefits on any card; monthly budgets; lost-card button that dials the helpline you saved
- Screens: onboarding, lock, Wallet, Card detail, Add card, Best card, Money, Quick add, Import review, Settings, Trust Center

Not done yet (honest list):
- **Not run on a real phone yet.** It's tested in Flutter's test environment and built by GitHub Actions; install the APK and report anything off.
- Benefits data is **sample data** (`assets/catalog/catalog_v1.json`): every rate shows a "Verify" badge until checked against the bank's MITC.
- Benefit updates are built (signed, published from `catalog/` by GitHub Actions) but **switched off until you create the signing key** (see below).

## Build

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter build apk --release --split-per-abi
```
Every push builds the APKs on GitHub Actions and publishes them as a GitHub Release:
**https://github.com/VirajP4595/CardMaster/releases/latest** → `card-master-arm64.apk`.

### Signing key (so updates install over each other)
Create your own key once and add it as two repository secrets (Settings → Secrets and variables → Actions):
```bash
keytool -genkeypair -keystore cardmaster.jks -alias cardmaster -keyalg RSA -keysize 2048 -validity 10000
base64 -w0 cardmaster.jks   # paste as ANDROID_KEYSTORE_BASE64
# the password you chose      -> ANDROID_KEYSTORE_PASSWORD
```
Keep `cardmaster.jks` and the password safe and offline. Without these secrets, builds are signed with a throwaway key and each new build must be installed fresh (uninstalling deletes app data).

### Turning on benefit updates
```bash
dart run tool/catalog_keygen.dart
```
Put the PRIVATE line in repo secret `CATALOG_SIGNING_KEY`; paste the PUBLIC line into `publicKeyBase64` in `CatalogConfig.current` (`lib/core/net/catalog_client.dart`). Then edit `catalog/catalog.json`, bump `"version"`, and push: the workflow signs and publishes it, and phones pick it up within a day.
