import 'package:card_master/data/backup/backup.dart';
import 'package:card_master/data/db/database.dart';
import 'package:card_master/domain/models.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Cheap Argon2 settings so the test runs fast; the app uses the defaults.
  final codec = BackupCodec(memoryKib: 64, iterations: 1);

  Future<AppDatabase> seeded() async {
    final db = AppDatabase(NativeDatabase.memory());
    await db.upsertCard(const UserCard(
      id: 'c1',
      productId: 'federal_scapia',
      bankName: 'Federal Bank',
      name: 'Scapia Federal Bank',
      network: CardNetwork.visa,
      last4: '4821',
      creditLimitPaise: 30000000,
      statementDay: 20,
      dueDay: 10,
    ));
    await db.addSpend(Spend(
      id: 's1',
      amountPaise: 975000,
      category: SpendCategory.travel,
      paymentKind: PaymentKind.card,
      userCardId: 'c1',
      international: true,
      spentOn: DateTime(2026, 10, 18),
    ));
    await db.remember('AGODA', SpendCategory.travel);
    return db;
  }

  test('backup round-trips into an empty database', () async {
    final source = await seeded();
    final file = await createBackup(source, 'correct horse', codec: codec);

    final target = AppDatabase(NativeDatabase.memory());
    await restoreBackup(target, 'correct horse', file, codec: codec);
    expect((await target.allCards()).single.last4, '4821');
    expect((await target.allSpends()).single.international, isTrue);
    expect(await target.categoryFor('AGODA'), SpendCategory.travel);
    await source.close();
    await target.close();
  });

  test('backup file contains no readable data', () async {
    final db = await seeded();
    final file = await createBackup(db, 'pw', codec: codec);
    final text = String.fromCharCodes(file);
    expect(text.contains('Scapia'), isFalse);
    expect(text.contains('4821'), isFalse);
    await db.close();
  });

  test('wrong passphrase and junk files are rejected', () async {
    final db = await seeded();
    final file = await createBackup(db, 'right', codec: codec);
    expect(() => codec.decrypt('wrong', file), throwsA(isA<BackupException>()));
    expect(() => codec.decrypt('right', [1, 2, 3]),
        throwsA(isA<BackupException>()));
    await db.close();
  });

  test('file name uses the date', () {
    expect(backupFileName(DateTime(2026, 1, 5)), 'cardmaster-2026-01-05.cmbackup');
  });
}
