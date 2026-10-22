import 'dart:convert';
import 'dart:io';

import 'package:card_master/core/net/catalog_client.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

/// End to end: tool/sign_catalog.dart output verifies with the app's code.
void main() {
  test('signed catalog from the publish tool verifies in the app', () async {
    final pair = await Ed25519().newKeyPair();
    final seed = base64Encode(await pair.extractPrivateKeyBytes());
    final pub = base64Encode((await pair.extractPublicKey()).bytes);
    final out = await Directory.systemTemp.createTemp('cm_catalog');

    final r = await Process.run(
      'dart',
      ['run', 'tool/sign_catalog.dart', out.path],
      environment: {'CATALOG_SIGNING_KEY': seed},
    );
    expect(r.exitCode, 0, reason: '${r.stdout}\n${r.stderr}');

    final manifest = jsonDecode(
            File('${out.path}/manifest.json').readAsStringSync())
        as Map<String, dynamic>;
    final body =
        File('${out.path}/v${manifest['latest']}.json').readAsBytesSync();
    await verifySignature(body, manifest['sig'] as String, pub);

    // A different key must not verify.
    final other = await Ed25519().newKeyPair();
    final otherPub = base64Encode((await other.extractPublicKey()).bytes);
    expect(verifySignature(body, manifest['sig'] as String, otherPub),
        throwsA(isA<CatalogVerificationException>()));
    await out.delete(recursive: true);
  }, timeout: const Timeout(Duration(minutes: 3)));
}
