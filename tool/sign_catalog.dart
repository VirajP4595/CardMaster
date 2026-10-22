// Validates and signs catalog/catalog.json for publishing.
//
//   CATALOG_SIGNING_KEY=<base64 seed> dart run tool/sign_catalog.dart <outDir>
//
// Writes <outDir>/v<version>.json (exact bytes that are signed) and
// <outDir>/manifest.json {"latest", "sha256", "sig"}. Fails if the catalog
// doesn't parse or every product's bank is missing.
import 'dart:convert';
import 'dart:io';

import 'package:card_master/data/catalog/catalog.dart';
import 'package:cryptography/cryptography.dart';

Future<void> main(List<String> args) async {
  final out = Directory(args.isEmpty ? 'dist/catalog' : args.first)
    ..createSync(recursive: true);
  final key = Platform.environment['CATALOG_SIGNING_KEY'];
  if (key == null || key.isEmpty) {
    stderr.writeln('CATALOG_SIGNING_KEY is not set');
    exit(2);
  }
  final bytes = File('catalog/catalog.json').readAsBytesSync();
  final catalog = Catalog.fromJsonString(utf8.decode(bytes));
  for (final p in catalog.products) {
    if (catalog.bank(p.bankId) == null) {
      stderr.writeln('Product ${p.id} has unknown bank ${p.bankId}');
      exit(1);
    }
  }
  final pair = await Ed25519().newKeyPairFromSeed(base64Decode(key));
  final sig = await Ed25519().sign(bytes, keyPair: pair);
  final hash = await Sha256().hash(bytes);
  File('${out.path}/v${catalog.version}.json').writeAsBytesSync(bytes);
  File('${out.path}/manifest.json').writeAsStringSync(jsonEncode({
    'latest': catalog.version,
    'sha256': base64Encode(hash.bytes),
    'sig': base64Encode(sig.bytes),
  }));
  stdout.writeln('Signed catalog v${catalog.version}: '
      '${catalog.products.length} cards, ${catalog.banks.length} banks');
}
