import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../data/backup/backup.dart';
import '../data/db/database.dart';
import 'providers.dart';

/// Weekly automatic backup, run when the app is opened (docs/07 §3.4).
/// The encrypted file goes to Downloads/Card Master on this phone. Nothing
/// is uploaded. The passphrase is kept in the Android Keystore so this can
/// run without asking each time.
abstract final class AutoBackup {
  static const interval = Duration(days: 7);
  static const keep = 4;
  static const _passKey = 'auto_backup_passphrase_v1';
  static const _storage = FlutterSecureStorage();
  static const _channel = MethodChannel('cardmaster/files');

  static bool isDue(DateTime? lastBackup, DateTime now) =>
      lastBackup == null || now.difference(lastBackup) >= interval;

  static Future<void> enable(AppDatabase db, String passphrase) async {
    await _storage.write(key: _passKey, value: passphrase);
    await db.setValue(SettingKeys.autoBackup, 'true');
  }

  static Future<void> disable(AppDatabase db) async {
    await _storage.delete(key: _passKey);
    await db.setValue(SettingKeys.autoBackup, 'false');
  }

  /// Makes a backup now if automatic backups are on and one is due.
  /// Returns true when a file was written.
  static Future<bool> runIfDue(AppDatabase db, {bool force = false}) async {
    if (await db.getValue(SettingKeys.autoBackup) != 'true') return false;
    final last = await db.getValue(SettingKeys.lastBackupAt);
    final now = DateTime.now();
    if (!force && !isDue(last == null ? null : DateTime.parse(last), now)) {
      return false;
    }
    final pass = await _storage.read(key: _passKey);
    if (pass == null) return false;
    final bytes = await createBackup(db, pass);
    final saved = await _channel.invokeMethod<bool>('saveBackup', {
      'name': backupFileName(now),
      'bytes': bytes,
      'keep': keep,
    });
    if (saved == true) {
      await db.setValue(SettingKeys.lastBackupAt, now.toIso8601String());
    }
    return saved == true;
  }
}
