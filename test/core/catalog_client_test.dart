import 'dart:convert';
import 'dart:io';

import 'package:card_master/core/net/catalog_client.dart';
import 'package:card_master/data/catalog/catalog.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  late SimpleKeyPair keyPair;
  late String publicKey;
  const catalogJson = '{"version":2,"banks":[],"products":[]}';

  setUp(() async {
    keyPair = await Ed25519().newKeyPair();
    publicKey = base64Encode((await keyPair.extractPublicKey()).bytes);
  });

  Future<String> sign(String body) async {
    final sig = await Ed25519().sign(utf8.encode(body), keyPair: keyPair);
    return base64Encode(sig.bytes);
  }

  CatalogClient client(
    MockClient http, {
    required List<NetworkLogEntry> log,
    Uri? base,
  }) =>
      CatalogClient(
        config: CatalogConfig(
          baseUrl: base ?? Uri.parse('https://cdn.example.com/catalog/'),
          publicKeyBase64: publicKey,
        ),
        log: (e) async => log.add(e),
        client: http,
      );

  test('downloads, verifies and logs a newer catalog', () async {
    final sig = await sign(catalogJson);
    final log = <NetworkLogEntry>[];
    final mock = MockClient((req) async {
      expect(req.method, 'GET');
      expect(req.body, isEmpty); // nothing is uploaded
      if (req.url.path.endsWith('manifest.json')) {
        return http.Response(jsonEncode({'latest': 2, 'sig': sig}), 200);
      }
      return http.Response(catalogJson, 200);
    });
    final update = await client(mock, log: log).fetchIfNewer(1);
    expect(update!.version, 2);
    expect(Catalog.fromJsonString(update.json).version, 2);
    expect(log.map((e) => e.method), ['GET', 'GET']);
  });

  test('rejects a tampered catalog', () async {
    final sig = await sign(catalogJson);
    final mock = MockClient((req) async {
      if (req.url.path.endsWith('manifest.json')) {
        return http.Response(jsonEncode({'latest': 2, 'sig': sig}), 200);
      }
      return http.Response(catalogJson.replaceAll('2', '9'), 200);
    });
    expect(
      client(mock, log: []).fetchIfNewer(1),
      throwsA(isA<CatalogVerificationException>()),
    );
  });

  test('skips the download when already up to date', () async {
    final log = <NetworkLogEntry>[];
    final mock = MockClient((req) async =>
        http.Response(jsonEncode({'latest': 1, 'sig': ''}), 200));
    expect(await client(mock, log: log).fetchIfNewer(1), isNull);
    expect(log.length, 1);
  });

  test('does nothing while no catalog host is configured', () async {
    final c = CatalogClient(
      config: CatalogConfig.current,
      log: (_) async => fail('must not connect'),
      client: MockClient((_) async => fail('must not connect')),
    );
    expect(await c.fetchIfNewer(0), isNull);
  });

  test('bundled sample catalog parses', () async {
    final catalog = Catalog.fromJsonString(
        await File('assets/catalog/catalog_v1.json').readAsString());
    expect(catalog.products, isNotEmpty);
    for (final p in catalog.products) {
      expect(catalog.bank(p.bankId), isNotNull, reason: p.id);
    }
  });
}
