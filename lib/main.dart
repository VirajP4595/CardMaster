import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/auto_backup.dart';
import 'app/billing.dart';
import 'app/providers.dart';
import 'app/services.dart';
import 'data/db/open.dart';
import 'domain/recurring.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await openEncryptedDatabase();
  final catalog = await loadCatalog(db);
  final blockScreenshots =
      (await db.getValue(SettingKeys.screenshotsBlocked)) != 'false';
  await setScreenSecure(blockScreenshots);

  final photos = await openPhotoStore();
  if (await db.getValue(SettingKeys.trialStart) == null) {
    await db.setValue(SettingKeys.trialStart, DateTime.now().toIso8601String());
  }
  final container = ProviderContainer(overrides: [
    databaseProvider.overrideWithValue(db),
    photoStoreProvider.overrideWithValue(photos),
    proGatingProvider.overrideWithValue(proGatingEnabled),
    catalogProvider.overrideWith(() => CatalogNotifier(catalog)),
  ]);

  runApp(UncontrolledProviderScope(
    container: container,
    child: const CardMasterApp(),
  ));

  Billing.instance.listen(db);

  // Recurring expenses set to add themselves (rent, subscriptions…).
  final rules = (await db.allRecurring()).where((r) => r.autoAdd).toList();
  for (final (rule, date) in dueOccurrences(rules, DateTime.now())) {
    await db.addOccurrence(rule, date);
  }

  // Weekly automatic backup to Downloads/Card Master, if switched on.
  AutoBackup.runIfDue(db).catchError((_) => false);

  // Background, non-blocking: download newer benefits if a host is set up.
  syncCatalog(db, catalog).then((c) {
    if (c != null) container.read(catalogProvider.notifier).replace(c);
  });
}
