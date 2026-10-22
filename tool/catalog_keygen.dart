// Creates the Ed25519 key pair that signs benefit updates.
//
//   dart run tool/catalog_keygen.dart
//
// Put the PRIVATE key in the repo secret CATALOG_SIGNING_KEY (never commit
// it) and paste the PUBLIC key into CatalogConfig.current in
// lib/core/net/catalog_client.dart.
import 'dart:convert';

import 'package:cryptography/cryptography.dart';

Future<void> main() async {
  final pair = await Ed25519().newKeyPair();
  final seed = await pair.extractPrivateKeyBytes();
  final pub = await pair.extractPublicKey();
  // ignore: avoid_print
  print('PRIVATE (secret CATALOG_SIGNING_KEY): ${base64Encode(seed)}');
  // ignore: avoid_print
  print('PUBLIC  (CatalogConfig.publicKeyBase64): ${base64Encode(pub.bytes)}');
}
