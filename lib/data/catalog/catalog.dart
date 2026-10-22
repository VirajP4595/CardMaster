import 'dart:convert';

import '../../domain/models.dart';

/// How a styled card face looks (docs/02-DESIGN.md §7). No bank artwork.
class CardFaceStyle {
  const CardFaceStyle({
    this.finish = 'matte',
    this.base = 0xFF3A2A8C,
    this.ink = 0xFFFFFFFF,
    this.chip = 'gold',
    this.numberless = false,
  });

  final String finish; // matte | metal | gloss | pattern
  final int base;
  final int ink;
  final String chip; // gold | silver
  final bool numberless;

  factory CardFaceStyle.fromJson(Map<String, dynamic>? j) {
    if (j == null) return const CardFaceStyle();
    return CardFaceStyle(
      finish: j['finish'] as String? ?? 'matte',
      base: _hex(j['base']) ?? 0xFF3A2A8C,
      ink: _hex(j['ink']) ?? 0xFFFFFFFF,
      chip: j['chip'] as String? ?? 'gold',
      numberless: j['numberless'] as bool? ?? false,
    );
  }
}

class CatalogBank {
  const CatalogBank({required this.id, required this.name, this.helpline});
  final String id;
  final String name;

  /// Card-blocking helpline, opened in the dialer by the lost-card button.
  final String? helpline;
}

class CatalogProduct {
  const CatalogProduct({
    required this.id,
    required this.bankId,
    required this.name,
    required this.network,
    required this.benefits,
    this.tagline,
    this.annualFeePaise = 0,
    this.waiverSpendPaise,
    this.face = const CardFaceStyle(),
    this.sourceUrl,
  });

  final String id;
  final String bankId;
  final String name;
  final String? tagline;
  final CardNetwork network;
  final int annualFeePaise;
  final int? waiverSpendPaise;
  final CardFaceStyle face;
  final List<Benefit> benefits;

  /// The bank page the benefits were taken from, for the user to check.
  final String? sourceUrl;
}

class Catalog {
  const Catalog({
    required this.version,
    required this.banks,
    required this.products,
  });

  final int version;
  final List<CatalogBank> banks;
  final List<CatalogProduct> products;

  CatalogBank? bank(String id) =>
      banks.where((b) => b.id == id).firstOrNull;

  CatalogProduct? product(String id) =>
      products.where((p) => p.id == id).firstOrNull;

  List<CatalogProduct> productsOf(String bankId) =>
      products.where((p) => p.bankId == bankId).toList();

  factory Catalog.fromJsonString(String source) =>
      Catalog.fromJson(jsonDecode(source) as Map<String, dynamic>);

  factory Catalog.fromJson(Map<String, dynamic> j) {
    final banks = (j['banks'] as List)
        .cast<Map<String, dynamic>>()
        .map((b) => CatalogBank(
              id: b['id'] as String,
              name: b['name'] as String,
              helpline: b['helpline'] as String?,
            ))
        .toList();
    final products = (j['products'] as List)
        .cast<Map<String, dynamic>>()
        .map(_product)
        .toList();
    return Catalog(
      version: j['version'] as int,
      banks: banks,
      products: products,
    );
  }

  static CatalogProduct _product(Map<String, dynamic> p) => CatalogProduct(
        id: p['id'] as String,
        bankId: p['bankId'] as String,
        name: p['name'] as String,
        tagline: p['tagline'] as String?,
        network: CardNetwork.fromCode(p['network'] as String),
        annualFeePaise: p['annualFeePaise'] as int? ?? 0,
        waiverSpendPaise: p['waiverSpendPaise'] as int?,
        face: CardFaceStyle.fromJson(p['face'] as Map<String, dynamic>?),
        sourceUrl: p['sourceUrl'] as String?,
        benefits: (p['benefits'] as List? ?? const [])
            .cast<Map<String, dynamic>>()
            .map((b) => Benefit(
                  id: b['id'] as String,
                  category: SpendCategory.fromCode(b['category'] as String),
                  kind: BenefitKind.fromCode(b['kind'] as String),
                  title: b['title'] as String,
                  rateBps: b['rateBps'] as int?,
                  monthlyCapPaise: b['monthlyCapPaise'] as int?,
                  minTxnPaise: b['minTxnPaise'] as int?,
                  channel: b['channel'] as String?,
                  conditions: b['conditions'] as String?,
                  lastVerified: b['lastVerified'] == null
                      ? null
                      : DateTime.parse(b['lastVerified'] as String),
                ))
            .toList(),
      );
}

int? _hex(Object? value) {
  if (value is! String) return null;
  final v = value.replaceFirst('#', '');
  final parsed = int.tryParse(v, radix: 16);
  if (parsed == null) return null;
  return v.length == 6 ? 0xFF000000 | parsed : parsed;
}
