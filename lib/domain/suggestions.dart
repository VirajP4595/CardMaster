import 'models.dart';
import 'recommender.dart';

/// A catalog card the user doesn't have, valued on their own recent spends.
class CardSuggestion {
  const CardSuggestion({
    required this.productId,
    required this.name,
    required this.extraPerYearPaise,
    required this.annualFeePaise,
  });

  final String productId;
  final String name;

  /// Extra rewards per year vs. the best of the user's current cards,
  /// after the suggested card's annual fee.
  final int extraPerYearPaise;
  final int annualFeePaise;
}

/// Ranks catalog cards purely by what the user would gain (docs/06 §1.2):
/// replays the last [days] of card/UPI/cash spends on "my best card for
/// each spend" vs. "same, plus this card", scales to a year, and subtracts
/// the fee. No referral links and no paid placement.
List<CardSuggestion> suggestCards({
  required List<CardWithBenefits> mine,
  required List<({String id, String name, CardWithBenefits card, int fee})>
      candidates,
  required List<Spend> spends,
  required DateTime now,
  int days = 90,
  int minGainPaise = 50000,
}) {
  final from = now.subtract(Duration(days: days));
  final recent = spends
      .where((s) =>
          !s.spentOn.isBefore(from) &&
          s.payee == PayeeType.merchant &&
          s.category != SpendCategory.rent)
      .toList();
  if (recent.isEmpty) return const [];

  int bestTotal(List<CardWithBenefits> cards) {
    var total = 0;
    for (final s in recent) {
      final r = recommend(
        Purchase(
          category: s.category,
          amountPaise: s.amountPaise,
          international: s.international,
        ),
        // Caps are ignored here: this is an estimate, and per-month caps
        // would only lower both sides.
        cards,
      );
      final best = r.where((x) => x.eligible).firstOrNull;
      if (best != null && best.netPaise > 0) total += best.netPaise;
    }
    return total;
  }

  final ownedIds = {for (final c in mine) c.card.productId};
  final base = bestTotal(mine);
  final out = <CardSuggestion>[];
  for (final c in candidates) {
    if (ownedIds.contains(c.id)) continue;
    final withIt = bestTotal([...mine, c.card]);
    final gain = ((withIt - base) * 365 / days).round() - c.fee;
    if (gain >= minGainPaise) {
      out.add(CardSuggestion(
        productId: c.id,
        name: c.name,
        extraPerYearPaise: gain,
        annualFeePaise: c.fee,
      ));
    }
  }
  out.sort((a, b) => b.extraPerYearPaise.compareTo(a.extraPerYearPaise));
  return out;
}
