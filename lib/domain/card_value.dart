import 'fee_waiver.dart';
import 'models.dart';
import 'money.dart';
import 'recommender.dart';

enum Verdict { keep, borderline, reconsider }

/// "Is this card worth keeping?" for the current card year (design board 9).
class CardYearValue {
  const CardYearValue({
    required this.from,
    required this.to,
    required this.spentPaise,
    required this.rewardsPaise,
    required this.feePaise,
    required this.feeWaived,
    required this.forexPaidPaise,
  });

  final DateTime from;
  final DateTime to;
  final int spentPaise;
  final int rewardsPaise;

  /// Annual fee that applies this year (0 if waived or a free card).
  final int feePaise;
  final bool feeWaived;
  final int forexPaidPaise;

  int get netPaise => rewardsPaise - feePaise - forexPaidPaise;

  Verdict get verdict {
    if (netPaise < 0) return Verdict.reconsider;
    // Earns less than ₹500 a year net: worth a second look.
    if (netPaise < 50000 && feePaise > 0) return Verdict.borderline;
    return Verdict.keep;
  }
}

/// Card year = from the anniversary month (or 1 Jan for cards without one).
/// Rewards apply monthly caps month by month.
CardYearValue cardYearValue(
  UserCard card,
  List<Benefit> benefits,
  List<Spend> allSpends,
  DateTime now,
) {
  final month = card.anniversaryMonth ?? 1;
  var from = DateTime(now.year, month, 1);
  if (from.isAfter(now)) from = DateTime(now.year - 1, month, 1);
  final to = DateTime(from.year + 1, month, 1);

  final spends = allSpends
      .where((s) =>
          s.userCardId == card.id &&
          s.paymentKind == PaymentKind.card &&
          !s.spentOn.isBefore(from) &&
          s.spentOn.isBefore(to))
      .toList()
    ..sort((a, b) => a.spentOn.compareTo(b.spentOn));

  var rewards = 0;
  var forex = 0;
  final capsByMonth = <int, Map<String, int>>{};
  final markup = benefits
          .where((b) => b.kind == BenefitKind.forexMarkup)
          .firstOrNull
          ?.rateBps ??
      defaultForexMarkupBps;

  for (final s in spends) {
    final key = s.spentOn.year * 12 + s.spentOn.month;
    final caps = capsByMonth.putIfAbsent(key, () => {});
    final r = recommend(
      Purchase(category: s.category, amountPaise: s.amountPaise),
      [CardWithBenefits(card: card, benefits: benefits, capUsedPaise: caps)],
    ).single;
    rewards += r.netPaise;
    final capped = benefits
        .where((b) =>
            b.kind == BenefitKind.reward &&
            b.category == s.category &&
            b.monthlyCapPaise != null)
        .firstOrNull;
    if (capped != null && r.netPaise > 0) {
      caps[capped.id] = (caps[capped.id] ?? 0) + r.netPaise;
    }
    if (s.international || s.category == SpendCategory.foreign) {
      forex += applyBps(s.amountPaise, markup);
    }
  }

  final waiver = feeWaiverStatus(card, allSpends, now);
  final waived = waiver?.achieved ?? false;
  return CardYearValue(
    from: from,
    to: to,
    spentPaise: spends.fold(0, (a, s) => a + s.amountPaise),
    rewardsPaise: rewards,
    feePaise: waived ? 0 : card.annualFeePaise,
    feeWaived: waived,
    forexPaidPaise: forex,
  );
}
