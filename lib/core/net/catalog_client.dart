import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:http/http.dart' as http;

/// The only code in the app allowed to touch the network (rule R1).
/// It performs GET requests to one allow-listed host and never sends user
/// data. test/core/net_isolation_test.dart enforces that no other file
/// imports `package:http`.
class CatalogConfig {
  const CatalogConfig({required this.baseUrl, required this.publicKeyBase64});

  /// e.g. https://cdn.example.com/catalog/ . Null until a host exists.
  final Uri? baseUrl;

  /// Ed25519 public key of the offline catalog signing key.
  final String publicKeyBase64;

  bool get enabled => baseUrl != null && publicKeyBase64.isNotEmpty;

  /// Not configured yet: no catalog host has been set up. Sync is skipped and
  /// the bundled catalog is used. Fill these in when the host exists.
  static const current = CatalogConfig(baseUrl: null, publicKeyBase64: '');
}

/// One row of the in-app network log shown in the Trust Center.
class NetworkLogEntry {
  const NetworkLogEntry({
    required this.at,
    required this.method,
    required this.url,
    required this.bytes,
    required this.status,
  });

  final DateTime at;
  final String method;
  final String url;
  final int bytes;
  final int status;
}

typedef NetworkLogger = Future<void> Function(NetworkLogEntry entry);

class CatalogUpdate {
  const CatalogUpdate(this.version, this.json);
  final int version;
  final String json;
}

class CatalogVerificationException implements Exception {
  CatalogVerificationException(this.message);
  final String message;
  @override
  String toString() => 'CatalogVerificationException: $message';
}

class CatalogClient {
  CatalogClient({
    required this.config,
    required this.log,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final CatalogConfig config;
  final NetworkLogger log;
  final http.Client _client;

  /// Returns a verified newer catalog, or null when there is none (or sync
  /// is disabled, or the phone is offline).
  Future<CatalogUpdate?> fetchIfNewer(int localVersion) async {
    if (!config.enabled) return null;
    try {
      final manifestRes = await _get(config.baseUrl!.resolve('manifest.json'));
      if (manifestRes.statusCode != 200) return null;
      final manifest = jsonDecode(manifestRes.body) as Map<String, dynamic>;
      final latest = manifest['latest'] as int;
      if (latest <= localVersion) return null;

      final res = await _get(config.baseUrl!.resolve('v$latest.json'));
      if (res.statusCode != 200) return null;
      await verifySignature(
        res.bodyBytes,
        manifest['sig'] as String,
        config.publicKeyBase64,
      );
      return CatalogUpdate(latest, utf8.decode(res.bodyBytes));
    } on CatalogVerificationException {
      rethrow;
    } catch (_) {
      return null; // Offline or host down: keep using the local copy.
    }
  }

  Future<http.Response> _get(Uri url) async {
    if (url.scheme != 'https' || url.host != config.baseUrl!.host) {
      throw StateError('Blocked request to non-allow-listed host: $url');
    }
    final res = await _client.get(url);
    await log(NetworkLogEntry(
      at: DateTime.now(),
      method: 'GET',
      url: url.toString(),
      bytes: res.bodyBytes.length,
      status: res.statusCode,
    ));
    return res;
  }
}

/// Throws unless [signatureBase64] is a valid Ed25519 signature of [data].
/// A forged catalog (e.g. from a compromised host) is rejected.
Future<void> verifySignature(
  List<int> data,
  String signatureBase64,
  String publicKeyBase64,
) async {
  final algorithm = Ed25519();
  final ok = await algorithm.verify(
    data,
    signature: Signature(
      base64Decode(signatureBase64),
      publicKey: SimplePublicKey(
        base64Decode(publicKeyBase64),
        type: KeyPairType.ed25519,
      ),
    ),
  );
  if (!ok) throw CatalogVerificationException('Signature does not match');
}
