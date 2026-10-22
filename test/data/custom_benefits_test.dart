import 'dart:io';

import 'package:card_master/app/providers.dart';
import 'package:card_master/data/backup/backup.dart';
import 'package:card_master/data/catalog/catalog.dart';
import 'package:card_master/data/db/database.dart';
import 'package:card_master/domain/models.dart';
import 'package:card_master/domain/recommender.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _custom = UserCard(
  id: 'c1',
  productId: 'custom',
  bankName: 'Kotak',
  name: 'My Kotak card',
  network: CardNetwork.visa,
  creditLimitPaise: 10000000,
  statementDay: 5,
  dueDay: 25,
);

Future<void> _addFoodBenefit(AppDatabase db) =>
    db.saveCustomBenefit(CustomBenefitsCompanion(
      id: const Value('b1'),
      userCardId: const Value('c1'),
      category: Value(SpendCategory.foodDelivery.code),
      title: const Value('5% on Swiggy'),
      rateBps: const Value(500),
      createdAt: Value(DateTime(2026, 10, 1)),
    ));

void main() {
  test('custom benefits feed the recommender for a custom card', () async {
    final db = AppDatabase(NativeDatabase.memory());
    await db.upsertCard(_custom);
    await _addFoodBenefit(db);
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      catalogProvider.overrideWith(() => CatalogNotifier(
          const Catalog(version: 1, banks: [], products: []))),
    ]);
    // Wait for the drift streams.
    final sub1 = container.listen(cardsProvider, (_, _) {});
    final sub2 = container.listen(customBenefitsProvider, (_, _) {});
    await container.read(cardsProvider.future);
    await container.read(customBenefitsProvider.future);

    final benefits = container.read(benefitsForCardProvider('c1'));
    expect(benefits.single.title, '5% on Swiggy');
    final r = recommend(
      const Purchase(category: SpendCategory.foodDelivery, amountPaise: 100000),
      [CardWithBenefits(card: _custom, benefits: benefits)],
    );
    expect(r.single.netPaise, 5000);

    sub1.close();
    sub2.close();
    container.dispose();
    await db.close();
  });

  test('custom benefits survive a backup round trip and card removal cleans them', () async {
    final db = AppDatabase(NativeDatabase.memory());
    await db.upsertCard(_custom);
    await _addFoodBenefit(db);
    final codec = BackupCodec(memoryKib: 64, iterations: 1);
    final file = await createBackup(db, 'pw', codec: codec);

    final other = AppDatabase(NativeDatabase.memory());
    await restoreBackup(other, 'pw', file, codec: codec);
    expect(await other.select(other.customBenefits).get(), hasLength(1));

    await other.deleteCard('c1');
    expect(await other.select(other.customBenefits).get(), isEmpty);
    await db.close();
    await other.close();
  });

  test('upgrading a version 1 database adds every table and column added since', () async {
    final dir = await Directory.systemTemp.createTemp('cm_mig');
    final file = File('${dir.path}/v1.db');

    // Make a database, then turn it back into a version 1 database.
    final v2 = AppDatabase(NativeDatabase(file));
    await v2.upsertCard(_custom);
    await v2.customStatement('DROP TABLE custom_benefits');
    for (final t in [
      'budgets',
      'recurrings',
      'points_balances',
      'lounge_rules',
      'lounge_visits',
      'emis',
      'offers',
    ]) {
      await v2.customStatement('DROP TABLE $t');
    }
    await v2.customStatement('ALTER TABLE user_cards DROP COLUMN helpline');
    await v2.customStatement('PRAGMA user_version = 1');
    await v2.close();

    final upgraded = AppDatabase(NativeDatabase(file));
    await _addFoodBenefit(upgraded);
    expect(await upgraded.select(upgraded.customBenefits).get(), hasLength(1));
    expect((await upgraded.allCards()).single.id, 'c1');
    await upgraded.setHelpline('c1', '1860 000 0000');
    expect(await upgraded.watchHelpline('c1').first, '1860 000 0000');
    await upgraded.setBudget(SpendCategory.dining, 500000);
    expect(await upgraded.watchBudgets().first, {SpendCategory.dining: 500000});
    // Every later table exists again and works.
    for (final t in ['recurrings', 'points_balances', 'lounge_rules',
        'lounge_visits', 'emis', 'offers']) {
      await upgraded.customSelect('SELECT count(*) FROM $t').get();
    }
    await upgraded.close();
    await dir.delete(recursive: true);
  });
}
