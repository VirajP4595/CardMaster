import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/catalog/catalog.dart';
import '../data/db/database.dart';
import '../domain/fee_waiver.dart';
import '../domain/models.dart';
import '../domain/recommender.dart';

/// Overridden in main() with the opened encrypted database.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);

/// Overridden in main() with the bundled (or newer downloaded) catalog.
final catalogProvider = NotifierProvider<CatalogNotifier, Catalog>(
  CatalogNotifier.new,
);

class CatalogNotifier extends Notifier<Catalog> {
  CatalogNotifier([this._initial]);
  final Catalog? _initial;

  @override
  Catalog build() =>
      _initial ?? const Catalog(version: 0, banks: [], products: []);

  void replace(Catalog c) => state = c;
}

final cardsProvider = StreamProvider<List<UserCard>>(
  (ref) => ref.watch(databaseProvider).watchCards(),
);

final spendsProvider = StreamProvider<List<Spend>>(
  (ref) => ref.watch(databaseProvider).watchSpends(),
);

final overridesProvider = StreamProvider<List<BenefitOverride>>(
  (ref) => ref.watch(databaseProvider).watchOverrides(),
);

final cardProvider = Provider.family<UserCard?, String>((ref, id) {
  final cards = ref.watch(cardsProvider).value ?? const [];
  return cards.where((c) => c.id == id).firstOrNull;
});

/// Catalog benefits for a card with the user's overrides applied.
final benefitsForCardProvider =
    Provider.family<List<Benefit>, String>((ref, cardId) {
  final card = ref.watch(cardProvider(cardId));
  if (card == null) return const [];
  final product = ref.watch(catalogProvider).product(card.productId);
  final overrides = {
    for (final o in ref.watch(overridesProvider).value ?? const <BenefitOverride>[])
      if (o.userCardId == cardId) o.benefitId: o,
  };
  return [
    for (final b in product?.benefits ?? const <Benefit>[])
      if (overrides[b.id] case final o?)
        Benefit(
          id: b.id,
          category: b.category,
          kind: b.kind,
          title: b.title,
          rateBps: o.rateBps ?? b.rateBps,
          monthlyCapPaise: o.monthlyCapPaise ?? b.monthlyCapPaise,
          minTxnPaise: b.minTxnPaise,
          channel: b.channel,
          conditions: b.conditions,
          lastVerified: o.verifiedOn ?? b.lastVerified,
        )
      else
        b,
  ];
});

/// Reward already earned this month per benefit, for monthly caps.
Map<String, int> capUsageThisMonth(
  UserCard card,
  List<Benefit> benefits,
  List<Spend> spends,
  DateTime now,
) {
  final start = DateTime(now.year, now.month, 1);
  final used = <String, int>{};
  for (final s in spends) {
    if (s.userCardId != card.id || s.spentOn.isBefore(start)) continue;
    final r = recommend(
      Purchase(
        category: s.category,
        amountPaise: s.amountPaise,
        viaUpi: s.viaUpi,
        international: s.international,
      ),
      [CardWithBenefits(card: card, benefits: benefits, capUsedPaise: used)],
    ).single;
    final b = benefits
        .where((b) =>
            b.kind == BenefitKind.reward &&
            b.monthlyCapPaise != null &&
            b.category == s.category)
        .firstOrNull;
    if (b != null && r.netPaise > 0) {
      used[b.id] = (used[b.id] ?? 0) + r.netPaise;
    }
  }
  return used;
}

/// All the user's cards with benefits and this month's cap usage, ready for
/// the recommender.
final cardsWithBenefitsProvider = Provider<List<CardWithBenefits>>((ref) {
  final cards = ref.watch(cardsProvider).value ?? const [];
  final spends = ref.watch(spendsProvider).value ?? const [];
  final now = DateTime.now();
  return [
    for (final c in cards)
      () {
        final benefits = ref.watch(benefitsForCardProvider(c.id));
        return CardWithBenefits(
          card: c,
          benefits: benefits,
          capUsedPaise: capUsageThisMonth(c, benefits, spends, now),
        );
      }(),
  ];
});

final feeWaiverProvider =
    Provider.family<FeeWaiverStatus?, String>((ref, cardId) {
  final card = ref.watch(cardProvider(cardId));
  if (card == null) return null;
  final spends = ref.watch(spendsProvider).value ?? const [];
  return feeWaiverStatus(card, spends, DateTime.now());
});

/// Simple settings stored in the encrypted database.
abstract final class SettingKeys {
  static const onboardingDone = 'onboarding_done';
  static const lockEnabled = 'lock_enabled';
  static const screenshotsBlocked = 'screenshots_blocked';
  static const rewardHints = 'reward_hints';
  static const lastBackupAt = 'last_backup_at';
  static const catalogVersion = 'catalog_version';
  static const catalogJson = 'catalog_json';
  static const lastClipboardHash = 'last_clipboard_hash';
  static const remindersEnabled = 'reminders_enabled';
}

final settingProvider = StreamProvider.family<String?, String>(
  (ref, key) => ref.watch(databaseProvider).watchValue(key),
);

bool settingOn(WidgetRef ref, String key, {bool fallback = true}) {
  final v = ref.watch(settingProvider(key)).value;
  return v == null ? fallback : v == 'true';
}
