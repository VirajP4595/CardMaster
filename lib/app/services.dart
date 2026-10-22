import 'package:flutter/services.dart';

import '../core/net/catalog_client.dart';
import '../data/catalog/catalog.dart';
import '../data/db/database.dart';
import 'providers.dart';

/// Toggles FLAG_SECURE (screenshots and recents thumbnail), see MainActivity.
Future<void> setScreenSecure(bool secure) async {
  try {
    await const MethodChannel('cardmaster/window')
        .invokeMethod<void>('setSecure', secure);
  } on MissingPluginException {
    // Not on Android (tests): nothing to do.
  }
}

/// The newest verified catalog: a previously downloaded one if it is newer
/// than the bundled asset, otherwise the asset.
Future<Catalog> loadCatalog(AppDatabase db) async {
  final bundled = Catalog.fromJsonString(
      await rootBundle.loadString('assets/catalog/catalog_v1.json'));
  final cached = await db.getValue(SettingKeys.catalogJson);
  if (cached != null) {
    final c = Catalog.fromJsonString(cached);
    if (c.version > bundled.version) return c;
  }
  return bundled;
}

/// Checks for a newer signed catalog at most once a day. Download only.
Future<Catalog?> syncCatalog(AppDatabase db, Catalog current) async {
  final last = await db.getValue('catalog_checked_at');
  final now = DateTime.now();
  if (last != null &&
      now.difference(DateTime.parse(last)) < const Duration(hours: 24)) {
    return null;
  }
  await db.setValue('catalog_checked_at', now.toIso8601String());
  final client = CatalogClient(
    config: CatalogConfig.current,
    log: (e) => db.logRequest(e.at, e.method, e.url, e.bytes, e.status),
  );
  try {
    final update = await client.fetchIfNewer(current.version);
    if (update == null) return null;
    await db.setValue(SettingKeys.catalogJson, update.json);
    await db.setValue(SettingKeys.catalogVersion, '${update.version}');
    return Catalog.fromJsonString(update.json);
  } on CatalogVerificationException {
    return null; // Forged or corrupted file: ignore it, keep the local copy.
  }
}
