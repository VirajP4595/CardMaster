import 'dart:io';
import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'database.dart';

const _keyName = 'db_key_v1';

/// Opens the encrypted database. The 256-bit key is generated once and kept
/// in the Android Keystore via flutter_secure_storage (rule R4). It never
/// leaves the phone, which is also why a copied database file is useless.
Future<AppDatabase> openEncryptedDatabase() async {
  const storage = FlutterSecureStorage();
  var key = await storage.read(key: _keyName);
  if (key == null) {
    final rnd = Random.secure();
    key = List.generate(32, (_) => rnd.nextInt(256))
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    await storage.write(key: _keyName, value: key);
  }
  final dir = await getApplicationSupportDirectory();
  final file = File(p.join(dir.path, 'cardmaster.db'));
  final hexKey = key;
  return AppDatabase(NativeDatabase.createInBackground(
    file,
    setup: (db) {
      // SQLite3MultipleCiphers (pubspec hooks). Raw 256-bit hex key.
      db.execute("PRAGMA key = \"x'$hexKey'\";");
      // Fails loudly if the library isn't the encrypting build.
      db.select('SELECT count(*) FROM sqlite_master;');
    },
  ));
}
