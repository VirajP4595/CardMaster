import 'models.dart';
import 'money.dart';

/// Forex markup assumed when a card's catalog entry doesn't state one.
const defaultForexMarkupBps = 350;

class Purchase {
  const Purchase({
    required this.category,
    required this.amountPaise,
    this.viaUpi = false,
    this.international = false,
  });

  final SpendCategory category;
  final int amountPaise;
  final bool viaUpi;
  final bool international;

  bool get isForeign => international || category == SpendCategory.foreign;
}

class CardWithBenefits {
  const CardWithBenefits({
    required this.card,
    required this.benefits,
    this.capUsedPaise = const {},
  });

  final UserCard card;
  final List<Benefit> benefits;

  /// Reward already earned this month per benefit id, for monthly caps.
  final Map<String, int> capUsedPaise;
}

class Recommendation {
  const Recommendation({
    required this.card,
    required this.eligible,
    required this.netPaise,
    required this.rateBps,
    required this.reason,
    this.warning,
  });

  final UserCard card;
  final bool eligible;

  /// Reward minus forex markup. Can be negative for foreign spends.
  final int netPaise;
  final int rateBps;
  final String reason;
  final String? warning;
}

/// Ranks cards for a purchase by net return. Pure function; see
/// docs/03-ARCHITECTURE.md §5.
List<Recommendation> recommend(Purchase p, List<CardWithBenefits> cards) {
  final results = cards.map((c) => _evaluate(p, c)).toList();
  results.sort((a, b) {
    if (a.eligible != b.eligible) return a.eligible ? -1 : 1;
    return b.netPaise.compareTo(a.netPaise);
  });
  return results;
}

Recommendation _evaluate(Purchase p, CardWithBenefits c) {
  final card = c.card;
  if (p.viaUpi && !card.network.worksOnUpi) {
    return Recommendation(
      card: card,
      eligible: false,
      netPaise: 0,
      rateBps: 0,
      reason: '${card.network.label}: not usable on UPI',
      warning: 'Only RuPay credit cards work on UPI',
    );
  }

  final rewardCategory =
      p.category == SpendCategory.foreign ? SpendCategory.foreign : p.category;
  var benefit = _rewardFor(c.benefits, rewardCategory);
  if (benefit != null &&
      benefit.minTxnPaise != null &&
      p.amountPaise < benefit.minTxnPaise!) {
    benefit = _rewardFor(c.benefits, SpendCategory.other);
  }
  benefit ??= _rewardFor(c.benefits, SpendCategory.other);

  final rate = benefit?.rateBps ?? 0;
  var reward = applyBps(p.amountPaise, rate);
  String? warning;

  if (benefit != null && benefit.monthlyCapPaise != null) {
    final used = c.capUsedPaise[benefit.id] ?? 0;
    final left = (benefit.monthlyCapPaise! - used).clamp(0, 1 << 62);
    if (reward > left) {
      reward = left;
      warning = left == 0
          ? 'Monthly cap already used up'
          : 'Capped: ${formatInr(left)} left this month';
    }
  }
  if (rate == 0) warning ??= 'Earns nothing on ${p.category.label.toLowerCase()}';

  var net = reward;
  var reason = '${formatBps(rate)} back';
  if (benefit?.channel != null) reason += ' · via ${benefit!.channel}';

  if (p.isForeign) {
    final markup = _forexMarkup(c.benefits);
    net = reward - applyBps(p.amountPaise, markup);
    reason = '${formatBps(rate)} back − ${formatBps(markup)} forex markup';
  }

  return Recommendation(
    card: card,
    eligible: true,
    netPaise: net,
    rateBps: rate,
    reason: reason,
    warning: warning,
  );
}

Benefit? _rewardFor(List<Benefit> benefits, SpendCategory category) {
  for (final b in benefits) {
    if (b.kind == BenefitKind.reward && b.category == category) return b;
  }
  return null;
}

int _forexMarkup(List<Benefit> benefits) {
  for (final b in benefits) {
    if (b.kind == BenefitKind.forexMarkup) {
      return b.rateBps ?? defaultForexMarkupBps;
    }
  }
  return defaultForexMarkupBps;
}
