import 'dart:io';

import 'package:card_master/data/db/database.dart';
import 'package:card_master/domain/models.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as s3;

const _card = UserCard(
  id: 'c1',
  productId: 'axis_airtel',
  bankName: 'Axis Bank',
  name: 'Airtel Axis Bank',
  network: CardNetwork.mastercard,
  last4: '7302',
  creditLimitPaise: 25000000,
  statementDay: 12,
  dueDay: 2,
);

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('stores and reads cards and spends', () async {
    await db.upsertCard(_card);
    await db.addSpend(
      Spend(
        id: 's1',
        amountPaise: 240000,
        category: SpendCategory.utilities,
        paymentKind: PaymentKind.card,
        userCardId: 'c1',
        spentOn: DateTime(2026, 10, 21),
      ),
      merchant: 'BESCOM',
      source: 'SHARE',
    );
    expect((await db.allCards()).single.last4, '7302');
    expect((await db.allSpends()).single.note, 'BESCOM');
  });

  test('rejects anything but exactly 4 card digits', () async {
    expect(
      () => db.upsertCard(const UserCard(
        id: 'bad',
        productId: 'p',
        bankName: 'b',
        name: 'n',
        network: CardNetwork.visa,
        last4: '4111111111111111',
        creditLimitPaise: 0,
        statementDay: 1,
        dueDay: 20,
      )),
      throwsA(anything),
    );
  });

  test('deleting a card keeps its spends as history', () async {
    await db.upsertCard(_card);
    await db.addSpend(Spend(
      id: 's1',
      amountPaise: 100,
      category: SpendCategory.other,
      paymentKind: PaymentKind.card,
      userCardId: 'c1',
      spentOn: DateTime(2026, 10, 1),
    ));
    await db.deleteCard('c1');
    final spend = (await db.allSpends()).single;
    expect(spend.userCardId, isNull);
  });

  test('merchant memory learns categories', () async {
    await db.remember('bescom', SpendCategory.utilities);
    expect(await db.categoryFor('BESCOM'), SpendCategory.utilities);
    expect(await db.categoryFor('unknown'), isNull);
  });

  test('database file is encrypted on disk', () async {
    final dir = await Directory.systemTemp.createTemp('cm');
    final file = File('${dir.path}/enc.db');
    const key = "x'00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff'";
    final enc = AppDatabase(NativeDatabase(file,
        setup: (raw) => raw.execute('PRAGMA key = "$key";')));
    await enc.upsertCard(_card);
    await enc.close();

    // Plaintext markers must not appear in the file.
    final bytes = await file.readAsBytes();
    expect(String.fromCharCodes(bytes).contains('Airtel'), isFalse);
    expect(String.fromCharCodes(bytes.take(16)).startsWith('SQLite format'),
        isFalse);

    // Without the key, the file can't be read.
    final raw = s3.sqlite3.open(file.path);
    expect(() => raw.select('SELECT count(*) FROM sqlite_master'),
        throwsA(isA<s3.SqliteException>()));
    raw.dispose();
    await dir.delete(recursive: true);
  });

  test('key/value settings round-trip', () async {
    await db.setValue('catalog_version', '1');
    expect(await db.getValue('catalog_version'), '1');
    await db.setValue('catalog_version', '2');
    expect(await db.getValue('catalog_version'), '2');
    expect(await db.select(db.keyValues).get(), hasLength(1));
  });
}

// Keeps the drift `Value` import used for future companion-based tests.
// ignore: unused_element
const _unused = Value.absent();
