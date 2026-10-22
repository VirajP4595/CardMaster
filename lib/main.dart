import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'app/services.dart';
import 'data/db/open.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await openEncryptedDatabase();
  final catalog = await loadCatalog(db);
  final blockScreenshots =
      (await db.getValue(SettingKeys.screenshotsBlocked)) != 'false';
  await setScreenSecure(blockScreenshots);

  final container = ProviderContainer(overrides: [
    databaseProvider.overrideWithValue(db),
    catalogProvider.overrideWith(() => CatalogNotifier(catalog)),
  ]);

  runApp(UncontrolledProviderScope(
    container: container,
    child: const CardMasterApp(),
  ));

  // Background, non-blocking: download newer benefits if a host is set up.
  syncCatalog(db, catalog).then((c) {
    if (c != null) container.read(catalogProvider.notifier).replace(c);
  });
}
