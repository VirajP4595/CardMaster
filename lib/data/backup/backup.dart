import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';

import '../db/database.dart';

/// Encrypted, passphrase-protected backup file (docs/07 §3.4). Written only
/// to a place the user picks; the app never uploads it.
///
/// File layout: "CMBK" | format(1) | salt(16) | nonce(12) | ciphertext | mac(16)
class BackupCodec {
  BackupCodec({this.memoryKib = 19456, this.iterations = 2});

  /// Argon2id cost. Defaults follow OWASP's minimum; tests use lower values.
  final int memoryKib;
  final int iterations;

  static const _magic = [0x43, 0x4D, 0x42, 0x4B]; // "CMBK"
  static const _format = 1;

  Future<Uint8List> encrypt(String passphrase, List<int> plain) async {
    final rnd = Random.secure();
    final salt = List<int>.generate(16, (_) => rnd.nextInt(256));
    final key = await _deriveKey(passphrase, salt);
    final box = await AesGcm.with256bits().encrypt(plain, secretKey: key);
    return Uint8List.fromList([
      ..._magic,
      _format,
      ...salt,
      ...box.nonce,
      ...box.cipherText,
      ...box.mac.bytes,
    ]);
  }

  /// Throws [BackupException] for a wrong passphrase or a damaged file.
  Future<List<int>> decrypt(String passphrase, List<int> file) async {
    if (file.length < 4 + 1 + 16 + 12 + 16 ||
        !_startsWithMagic(file) ||
        file[4] != _format) {
      throw BackupException('This is not a Card Master backup file.');
    }
    final salt = file.sublist(5, 21);
    final nonce = file.sublist(21, 33);
    final cipherText = file.sublist(33, file.length - 16);
    final mac = Mac(file.sublist(file.length - 16));
    final key = await _deriveKey(passphrase, salt);
    try {
      return await AesGcm.with256bits().decrypt(
        SecretBox(cipherText, nonce: nonce, mac: mac),
        secretKey: key,
      );
    } on SecretBoxAuthenticationError {
      throw BackupException('Wrong passphrase, or the file is damaged.');
    }
  }

  Future<SecretKey> _deriveKey(String passphrase, List<int> salt) =>
      Argon2id(
        parallelism: 1,
        memory: memoryKib,
        iterations: iterations,
        hashLength: 32,
      ).deriveKeyFromPassword(password: passphrase, nonce: salt);

  bool _startsWithMagic(List<int> f) =>
      Iterable<int>.generate(4).every((i) => f[i] == _magic[i]);
}

class BackupException implements Exception {
  BackupException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Tables included in a backup. The network log is left out on purpose:
/// it describes this phone, not the user's data.
Future<Map<String, Object?>> exportData(AppDatabase db) async => {
      'format': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'userCards': [for (final r in await db.select(db.userCards).get()) r.toJson()],
      'spends': [for (final r in await db.select(db.spends).get()) r.toJson()],
      'benefitOverrides': [
        for (final r in await db.select(db.benefitOverrides).get()) r.toJson()
      ],
      'customBenefits': [
        for (final r in await db.select(db.customBenefits).get()) r.toJson()
      ],
      'recurrings': [
        for (final r in await db.select(db.recurrings).get()) r.toJson()
      ],
      'pointsBalances': [
        for (final r in await db.select(db.pointsBalances).get()) r.toJson()
      ],
      'budgets': [for (final r in await db.select(db.budgets).get()) r.toJson()],
      'merchantRules': [
        for (final r in await db.select(db.merchantRules).get()) r.toJson()
      ],
      'keyValues': [for (final r in await db.select(db.keyValues).get()) r.toJson()],
    };

/// Replaces everything in [db] with the backup contents, in one transaction.
Future<void> importData(AppDatabase db, Map<String, Object?> data) async {
  if (data['format'] != 1) {
    throw BackupException('This backup was made by a newer app version.');
  }
  List<Map<String, dynamic>> rows(String k) =>
      (data[k] as List? ?? const []).cast<Map<String, dynamic>>();

  await db.transaction(() async {
    for (final t in <TableInfo<Table, dynamic>>[
      db.userCards,
      db.spends,
      db.benefitOverrides,
      db.customBenefits,
      db.budgets,
      db.recurrings,
      db.pointsBalances,
      db.merchantRules,
      db.keyValues,
    ]) {
      await db.delete(t).go();
    }
    await db.batch((b) {
      b.insertAll(db.userCards, rows('userCards').map(UserCardRow.fromJson));
      b.insertAll(db.spends, rows('spends').map(SpendRow.fromJson));
      b.insertAll(db.benefitOverrides,
          rows('benefitOverrides').map(BenefitOverride.fromJson));
      b.insertAll(db.customBenefits,
          rows('customBenefits').map(CustomBenefit.fromJson));
      b.insertAll(db.budgets, rows('budgets').map(Budget.fromJson));
      b.insertAll(
          db.recurrings, rows('recurrings').map(RecurringRow.fromJson));
      b.insertAll(db.pointsBalances,
          rows('pointsBalances').map(PointsRow.fromJson));
      b.insertAll(
          db.merchantRules, rows('merchantRules').map(MerchantRule.fromJson));
      b.insertAll(db.keyValues, rows('keyValues').map(KeyValue.fromJson));
    });
  });
}

Future<Uint8List> createBackup(
  AppDatabase db,
  String passphrase, {
  BackupCodec? codec,
}) async {
  final json = utf8.encode(jsonEncode(await exportData(db)));
  return (codec ?? BackupCodec()).encrypt(passphrase, json);
}

Future<void> restoreBackup(
  AppDatabase db,
  String passphrase,
  List<int> file, {
  BackupCodec? codec,
}) async {
  final plain = await (codec ?? BackupCodec()).decrypt(passphrase, file);
  await importData(
      db, jsonDecode(utf8.decode(plain)) as Map<String, Object?>);
}

/// Name like cardmaster-2026-10-22.cmbackup.
String backupFileName(DateTime now) =>
    'cardmaster-${now.year}-${now.month.toString().padLeft(2, '0')}-'
    '${now.day.toString().padLeft(2, '0')}.cmbackup';
