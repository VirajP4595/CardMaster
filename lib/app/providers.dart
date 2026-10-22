import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/catalog/catalog.dart';
import '../data/db/database.dart';
import '../domain/fee_waiver.dart';
import '../domain/models.dart';
import '../domain/recommender.dart';
import '../domain/recurring.dart';
import '../domain/suggestions.dart';

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

final recurringProvider = StreamProvider<List<RecurringRule>>(
  (ref) => ref.watch(databaseProvider).watchRecurring(),
);

final pointsProvider = StreamProvider<List<PointsBalance>>(
  (ref) => ref.watch(databaseProvider).watchPoints(),
);

final budgetsProvider = StreamProvider<Map<SpendCategory, int>>(
  (ref) => ref.watch(databaseProvider).watchBudgets(),
);

final helplineProvider = StreamProvider.family<String?, String>(
  (ref, cardId) => ref.watch(databaseProvider).watchHelpline(cardId),
);

final customBenefitsProvider = StreamProvider<List<CustomBenefit>>(
  (ref) => ref.watch(databaseProvider).watchCustomBenefits(),
);

/// Ids of benefits the user created (shown with edit/delete).
const customBenefitPrefix = 'custom:';

/// Awaits a stream provider's current value from outside build. Riverpod 3
/// pauses providers nobody listens to, so a bare `read(p.future)` would
/// never complete; this listens while waiting.
Future<T> readLoaded<T>(WidgetRef ref, StreamProvider<T> provider) async {
  final sub = ref.listenManual(provider, (_, _) {});
  try {
    return await ref.read(provider.future);
  } finally {
    sub.close();
  }
}

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
  final custom = [
    for (final c in ref.watch(customBenefitsProvider).value ??
        const <CustomBenefit>[])
      if (c.userCardId == cardId)
        Benefit(
          id: '$customBenefitPrefix${c.id}',
          category: SpendCategory.fromCode(c.category),
          kind: BenefitKind.fromCode(c.kind),
          title: c.title,
          rateBps: c.rateBps,
          monthlyCapPaise: c.monthlyCapPaise,
          channel: c.channel,
          conditions: 'Added by you',
          lastVerified: c.createdAt,
        ),
  ];
  // Custom benefits come first: the recommender uses the first match per
  // category, so the user's own entry wins over the catalog.
  return [
    ...custom,
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
  static const autoBackup = 'auto_backup';
  static const travelMode = 'travel_mode';
}

final settingProvider = StreamProvider.family<String?, String>(
  (ref, key) => ref.watch(databaseProvider).watchValue(key),
);

bool settingOn(WidgetRef ref, String key, {bool fallback = true}) {
  final v = ref.watch(settingProvider(key)).value;
  return v == null ? fallback : v == 'true';
}

/// "A card that fits your spending" (docs/06 §1.2): catalog cards the user
/// doesn't have, ranked only by what they'd gain. No referral links.
final suggestionsProvider = Provider<List<CardSuggestion>>((ref) {
  final mine = ref.watch(cardsWithBenefitsProvider);
  if (mine.isEmpty) return const [];
  final catalog = ref.watch(catalogProvider);
  final spends = ref.watch(spendsProvider).value ?? const <Spend>[];
  return suggestCards(
    mine: mine,
    candidates: [
      for (final p in catalog.products)
        (
          id: p.id,
          name: p.name,
          fee: p.annualFeePaise,
          card: CardWithBenefits(
            card: UserCard(
              id: 'suggest:${p.id}',
              productId: p.id,
              bankName: catalog.bank(p.bankId)?.name ?? '',
              name: p.name,
              network: p.network,
              creditLimitPaise: 0,
              statementDay: 1,
              dueDay: 20,
            ),
            benefits: p.benefits,
          ),
        ),
    ],
    spends: spends,
    now: DateTime.now(),
  );
});
