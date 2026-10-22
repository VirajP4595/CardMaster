# Card Master — How to Build It (step by step, on YOUR machine)

## 0. Check toolchain
```bash
flutter --version          # want 3.24+ stable
flutter doctor -v          # Android toolchain + licenses must be ✓
flutter doctor --android-licenses
```

## 1. Create project
```bash
flutter create --org com.viraj --platforms android cardmaster
cd cardmaster
flutter pub add flutter_riverpod riverpod_annotation go_router drift sqlcipher_flutter_libs \
  path_provider path flutter_secure_storage local_auth flutter_local_notifications timezone \
  freezed_annotation json_annotation fl_chart cryptography file_picker uuid intl
flutter pub add --dev build_runner drift_dev riverpod_generator freezed json_serializable
```

## 2. Lock down Android (do this first, before any feature)
1. `android/app/src/main/AndroidManifest.xml`: INTERNET is allowed (catalog sync only, see 07); add `networkSecurityConfig` (no cleartext), `allowBackup="false"`, `fullBackupContent="false"`, `dataExtractionRules`.
2. Create `android/app/src/main/res/xml/data_extraction_rules.xml`:
   ```xml
   <data-extraction-rules>
     <cloud-backup><exclude domain="root"/><exclude domain="database"/><exclude domain="sharedpref"/><exclude domain="file"/></cloud-backup>
     <device-transfer><exclude domain="root"/><exclude domain="database"/><exclude domain="sharedpref"/><exclude domain="file"/></device-transfer>
   </data-extraction-rules>
   ```
3. Change `MainActivity` to `FlutterFragmentActivity` + `FLAG_SECURE` (see Architecture §6).
4. Add `<uses-permission android:name="android.permission.USE_BIOMETRIC"/>`.
5. `android/app/build.gradle(.kts)`: `minSdk = 23`, enable `isMinifyEnabled = true` for release.

## 3. Build order (each step is runnable)
1. `core/security` + `LockGate` → app opens behind biometric prompt.
2. `core/db` drift tables + encrypted open → write a smoke test.
3. `assets/catalog/catalog_v1.json` + loader → seed `banks`, `card_products`, `benefits` on first run.
4. Add-card flow → Wallet carousel → Card detail.
5. Recommender (TDD: write tests in `test/domain/recommender_test.dart` first).
6. Spend log → fee-waiver ring → caps.
7. Local notifications → encrypted export/import.

Run code generation whenever you touch models/tables/providers:
```bash
dart run build_runner watch -d
```

## 4. Run on your phone
```bash
# enable Developer options + USB debugging on phone
flutter devices
flutter run
```

## 5. Build the APK
```bash
# one-time: signing key (keep this file + passwords safe, OFFLINE)
keytool -genkey -v -keystore ~/cardmaster-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias cardmaster
```
Create `android/key.properties` (add to `.gitignore`!):
```
storePassword=...
keyPassword=...
keyAlias=cardmaster
storeFile=/home/you/cardmaster-release.jks
```
Wire it into `signingConfigs` in `android/app/build.gradle(.kts)`, then:
```bash
flutter build apk --release --split-per-abi
# → build/app/outputs/flutter-apk/app-arm64-v8a-release.apk   (install this one on modern phones)
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

## 6. Verify privacy before you trust it
```bash
$ANDROID_HOME/build-tools/<ver>/aapt2 dump permissions build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
# expect only: INTERNET, ACCESS_NETWORK_STATE, USE_BIOMETRIC, POST_NOTIFICATIONS, CAMERA, BILLING, RECEIVE_BOOT_COMPLETED
# anything else (SMS, notification listener, exact alarm, accessibility…) = release blocker
```
Then on the phone, use a proxy (e.g. mitmproxy on a test device) once per release: the only traffic should be GET requests to the catalog host, plus Play Store billing. Any upload is a release blocker.

## 7. Seeding your real cards
Before entering Scapia / Airtel Axis etc., open each bank's current **MITC** (Most Important Terms & Conditions) PDF and fix the numbers in `catalog_v1.json`, setting `lastVerified` to today.
