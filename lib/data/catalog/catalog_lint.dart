import '../../domain/models.dart';

/// Checks a merged catalog (the JSON shipped in the app and published) for
/// mistakes that would mislead the recommender. Errors block a build;
/// warnings are printed for review. Used by tool/build_catalog.dart and the
/// catalog test.
class CatalogIssues {
  final errors = <String>[];
  final warnings = <String>[];
  bool get ok => errors.isEmpty;
}

CatalogIssues lintCatalog(Map<String, dynamic> catalog) {
  final r = CatalogIssues();
  final categories = {for (final c in SpendCategory.values) c.code};
  final kinds = {for (final k in BenefitKind.values) k.code};
  final networks = {for (final n in CardNetwork.values) n.code};
  final hex = RegExp(r'^#[0-9A-Fa-f]{6}$');
  final id = RegExp(r'^[a-z0-9_]+$');

  bool https(Object? u) => u is String && u.startsWith('https://');

  final bankIds = <String>{};
  for (final b in (catalog['banks'] as List).cast<Map<String, dynamic>>()) {
    final bid = b['id'] as String? ?? '';
    if (!id.hasMatch(bid)) r.errors.add('bank "$bid": bad id');
    if (!bankIds.add(bid)) r.errors.add('bank "$bid": duplicate id');
    final phone = b['helpline'] as String?;
    if (phone != null && !RegExp(r'^\+?[0-9 ]{8,16}$').hasMatch(phone)) {
      r.errors.add('bank "$bid": helpline "$phone" is not a phone number');
    }
  }

  final productIds = <String>{};
  final benefitIds = <String>{};
  for (final p in (catalog['products'] as List).cast<Map<String, dynamic>>()) {
    final pid = p['id'] as String? ?? '';
    void err(String m) => r.errors.add('$pid: $m');
    void warn(String m) => r.warnings.add('$pid: $m');

    if (!id.hasMatch(pid)) err('bad id');
    if (!productIds.add(pid)) err('duplicate product id');
    if (!bankIds.contains(p['bankId'])) err('unknown bank ${p['bankId']}');
    if (!networks.contains(p['network'])) err('bad network ${p['network']}');
    final fee = p['annualFeePaise'];
    if (fee is! int || fee < 0) err('annualFeePaise must be ≥ 0 paise');
    if (fee is int && fee > 0 && fee % 100 != 0) {
      warn('annual fee ${fee / 100} has paise — GST included by mistake?');
    }
    final waiver = p['waiverSpendPaise'];
    if (waiver != null && (waiver is! int || waiver <= 0)) {
      err('waiverSpendPaise must be > 0 or null');
    }
    if (fee == 0 && waiver != null) warn('waiver on a free card');
    final face = p['face'] as Map<String, dynamic>?;
    if (face == null || !hex.hasMatch(face['base'] as String? ?? '')) {
      err('face.base must be #RRGGBB');
    }
    if (!https(p['sourceUrl'])) err('sourceUrl must be an https link');

    final benefits = (p['benefits'] as List? ?? const [])
        .cast<Map<String, dynamic>>();
    if (benefits.isEmpty) err('no benefits');
    var hasBase = false;
    for (final b in benefits) {
      final bid = b['id'] as String? ?? '';
      void berr(String m) => err('$bid: $m');
      if (!id.hasMatch(bid) || !bid.startsWith('${pid}_')) {
        berr('benefit id must start with "${pid}_"');
      }
      if (!benefitIds.add(bid)) berr('duplicate benefit id');
      final kind = b['kind'];
      final cat = b['category'];
      if (!kinds.contains(kind)) berr('bad kind $kind');
      if (!categories.contains(cat)) berr('bad category $cat');
      if ((b['title'] as String? ?? '').trim().isEmpty) berr('no title');
      if (!https(b['sourceUrl'])) berr('sourceUrl must be an https link');
      final rate = b['rateBps'];
      final cap = b['monthlyCapPaise'];
      if (cap != null && (cap is! int || cap <= 0)) berr('bad monthly cap');
      switch (kind) {
        case 'REWARD':
          if (rate is! int || rate < 0) {
            berr('REWARD needs rateBps ≥ 0');
          } else if (rate > 3000) {
            berr('reward ${rate / 100}% is not believable');
          } else if (rate > 1000) {
            r.warnings.add('$pid: $bid: reward ${rate / 100}% — check');
          }
          if (cat == 'OTHER') hasBase = true;
        case 'FOREX_MARKUP':
          if (cat != 'FOREIGN') berr('forex markup must be category FOREIGN');
          if (rate is! int || rate < 0 || rate > 500) {
            berr('forex markup must be 0–5%');
          }
        case 'INFO':
          if (rate != null) berr('INFO benefits carry no rate');
      }
    }
    if (!hasBase) warn('no base rate (REWARD in OTHER)');
    if (!benefits.any((b) => b['kind'] == 'FOREX_MARKUP')) {
      warn('no forex markup');
    }
  }
  return r;
}
