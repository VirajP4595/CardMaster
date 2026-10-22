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
- Screens: onboarding, lock, Wallet, Card detail, Add card, Best card, Money, Quick add, Import review, Settings, Trust Center

Not done yet (honest list):
- **Not run on a real phone yet.** It's tested in Flutter's test environment and built by GitHub Actions; install the APK and report anything off.
- Benefits data is **sample data** (`assets/catalog/catalog_v1.json`): every rate shows a "Verify" badge until checked against the bank's MITC.
- No benefits server yet, so updates are switched off (`CatalogConfig.current` in `lib/core/net/catalog_client.dart`).
- Due-date **notifications** (only shown in Wallet → Needs attention for now) and the **weekly automatic backup** (manual export works).
- Adding your own benefits to a custom card.
- Moved to 1.0.x as decided: budgets, lost-card button.

## Build

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter build apk --release --split-per-abi
```
Every push also builds the APKs on GitHub Actions (Actions tab → latest run → `card-master-apks`).
