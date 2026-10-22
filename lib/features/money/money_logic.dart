import '../../domain/models.dart';
import '../../domain/recommender.dart';

/// Reward earned by each card spend in a month, applying monthly caps in
/// date order. Keyed by spend id.
Map<String, int> earnedBySpend(
  List<Spend> monthSpends,
  List<CardWithBenefits> cards,
) {
  final used = <String, Map<String, int>>{};
  final out = <String, int>{};
  final sorted = [...monthSpends]..sort((a, b) => a.spentOn.compareTo(b.spentOn));
  for (final s in sorted) {
    if (s.paymentKind != PaymentKind.card || s.userCardId == null) continue;
    final c = cards.where((c) => c.card.id == s.userCardId).firstOrNull;
    if (c == null) continue;
    final caps = used.putIfAbsent(c.card.id, () => {});
    final r = recommend(
      Purchase(
        category: s.category,
        amountPaise: s.amountPaise,
        international: s.international,
      ),
      [CardWithBenefits(card: c.card, benefits: c.benefits, capUsedPaise: caps)],
    ).single;
    out[s.id] = r.netPaise;
    final capped = c.benefits
        .where((b) =>
            b.kind == BenefitKind.reward &&
            b.category == s.category &&
            b.monthlyCapPaise != null)
        .firstOrNull;
    if (capped != null && r.netPaise > 0) {
      caps[capped.id] = (caps[capped.id] ?? 0) + r.netPaise;
    }
  }
  return out;
}

/// What the best card would have earned for a UPI/cash expense, or null when
/// a hint would be misleading (docs/09 §7): payments to people, rent (fees
/// usually cancel the reward), or nothing to gain.
Recommendation? missedReward(Spend s, List<CardWithBenefits> cards) {
  if (s.paymentKind == PaymentKind.card) return null;
  if (s.payee == PayeeType.person) return null;
  if (s.category == SpendCategory.rent) return null;
  if (cards.isEmpty) return null;
  final best = recommend(
    Purchase(
      category: s.category,
      amountPaise: s.amountPaise,
      viaUpi: s.viaUpi && s.paymentKind == PaymentKind.bankUpi,
      international: s.international,
    ),
    cards,
  ).first;
  if (!best.eligible || best.netPaise <= 0) return null;
  return best;
}
