// Builds the benefits catalog from one source file per bank.
//
//   dart run tool/build_catalog.dart [--check]
//
// Reads catalog/cards/*.json ({"bank": {...}, "products": [...]}), checks
// them with lintCatalog, and writes catalog/catalog.json (published, signed
// by the catalog workflow) plus assets/catalog/catalog_v1.json (bundled in
// the APK). The version goes up only when the content changes.
//
// --check writes nothing and fails if the outputs are stale or invalid
// (run in CI).
import 'dart:convert';
import 'dart:io';

import 'package:card_master/data/catalog/catalog.dart';
import 'package:card_master/data/catalog/catalog_lint.dart';

const _note =
    'Researched from bank websites and MITC documents (sourceUrl on every '
    'product and benefit). Not checked by a person yet: lastVerified stays '
    'null so the app shows a Verify badge. Rates convert points at the '
    'standard cashback/statement-credit value.';

void main(List<String> args) {
  final check = args.contains('--check');
  final files = Directory('catalog/cards')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  final banks = <Map<String, dynamic>>[];
  final products = <Map<String, dynamic>>[];
  for (final f in files) {
    final j = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
    banks.add(j['bank'] as Map<String, dynamic>);
    products.addAll((j['products'] as List).cast<Map<String, dynamic>>());
  }

  final out = File('catalog/catalog.json');
  final previous = out.existsSync()
      ? jsonDecode(out.readAsStringSync()) as Map<String, dynamic>
      : null;
  final same = previous != null &&
      jsonEncode(previous['banks']) == jsonEncode(banks) &&
      jsonEncode(previous['products']) == jsonEncode(products);
  final version = previous == null
      ? 1
      : (previous['version'] as int) + (same ? 0 : 1);

  final catalog = <String, dynamic>{
    'version': version,
    'generatedOn': same
        ? previous['generatedOn']
        : DateTime.now().toIso8601String().substring(0, 10),
    'note': _note,
    'banks': banks,
    'products': products,
  };

  final issues = lintCatalog(catalog);
  for (final w in issues.warnings) {
    stdout.writeln('warning: $w');
  }
  for (final e in issues.errors) {
    stderr.writeln('error: $e');
  }
  if (!issues.ok) exit(1);
  Catalog.fromJson(catalog); // must also load in the app

  final text = '${const JsonEncoder.withIndent('  ').convert(catalog)}\n';
  final asset = File('assets/catalog/catalog_v1.json');
  if (check) {
    if (!same || asset.readAsStringSync() != text) {
      stderr.writeln('catalog is stale: run dart run tool/build_catalog.dart');
      exit(1);
    }
    stdout.writeln('catalog v$version OK: ${products.length} cards, '
        '${banks.length} banks, ${issues.warnings.length} warnings');
    return;
  }
  out.writeAsStringSync(text);
  asset.writeAsStringSync(text);
  stdout.writeln('catalog v$version: ${products.length} cards from '
      '${banks.length} banks, ${issues.warnings.length} warnings');
}
