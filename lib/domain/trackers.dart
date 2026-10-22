import 'models.dart';

// ---------------------------------------------------------------- Lounges

class LoungeRule {
  const LoungeRule({
    required this.cardId,
    required this.visitsPerQuarter,
    this.spendGatePaise,
  });

  final String cardId;
  final int visitsPerQuarter;

  /// Many cards unlock next quarter's visits only after spending this much
  /// in the current quarter. Null = no spend condition.
  final int? spendGatePaise;
}

class LoungeStatus {
  const LoungeStatus({
    required this.quarterStart,
    required this.quarterEnd,
    required this.used,
    required this.allowed,
    required this.spentThisQuarterPaise,
    required this.spendGatePaise,
  });

  final DateTime quarterStart;
  final DateTime quarterEnd;
  final int used;
  final int allowed;
  final int spentThisQuarterPaise;
  final int? spendGatePaise;

  int get left => (allowed - used).clamp(0, allowed);

  /// Spend still needed this quarter to unlock next quarter's visits.
  int get toUnlockNextPaise => spendGatePaise == null
      ? 0
      : (spendGatePaise! - spentThisQuarterPaise).clamp(0, spendGatePaise!);
}

/// Calendar quarters (Jan–Mar, Apr–Jun, …), as most Indian cards use.
LoungeStatus loungeStatus(
  LoungeRule rule,
  List<DateTime> visits,
  List<Spend> spends,
  DateTime now,
) {
  final qStartMonth = ((now.month - 1) ~/ 3) * 3 + 1;
  final start = DateTime(now.year, qStartMonth, 1);
  final end = DateTime(now.year, qStartMonth + 3, 1);
  bool inQuarter(DateTime d) => !d.isBefore(start) && d.isBefore(end);
  return LoungeStatus(
    quarterStart: start,
    quarterEnd: end,
    used: visits.where(inQuarter).length,
    allowed: rule.visitsPerQuarter,
    spentThisQuarterPaise: spends
        .where((s) =>
            s.userCardId == rule.cardId &&
            s.paymentKind == PaymentKind.card &&
            inQuarter(s.spentOn))
        .fold(0, (a, s) => a + s.amountPaise),
    spendGatePaise: rule.spendGatePaise,
  );
}

// ------------------------------------------------------------------- EMIs

class Emi {
  const Emi({
    required this.id,
    required this.cardId,
    required this.title,
    required this.monthlyPaise,
    required this.totalMonths,
    required this.firstMonth,
  });

  final String id;
  final String cardId;
  final String title;
  final int monthlyPaise;
  final int totalMonths;

  /// Month of the first instalment (day ignored).
  final DateTime firstMonth;

  int monthsPaid(DateTime now) {
    final elapsed = (now.year - firstMonth.year) * 12 +
        (now.month - firstMonth.month) +
        1;
    return elapsed.clamp(0, totalMonths);
  }

  int monthsLeft(DateTime now) => totalMonths - monthsPaid(now);

  /// Remaining instalments (approximately the credit limit still blocked;
  /// banks block the outstanding principal, which is a little less).
  int remainingPaise(DateTime now) => monthsLeft(now) * monthlyPaise;

  bool isActive(DateTime now) => monthsLeft(now) > 0;
}

// ----------------------------------------------------------------- Offers

class SavedOffer {
  const SavedOffer({
    required this.id,
    required this.title,
    required this.category,
    required this.validUntil,
    this.cardId,
  });

  final String id;
  final String title;
  final SpendCategory category;
  final DateTime validUntil;

  /// Card the offer is for (bank sale offers usually need a specific card).
  final String? cardId;

  bool isActive(DateTime now) =>
      !DateTime(now.year, now.month, now.day).isAfter(validUntil);
}

List<SavedOffer> activeOffersFor(
  List<SavedOffer> offers,
  SpendCategory category,
  DateTime now,
) =>
    offers
        .where((o) => o.isActive(now) && o.category == category)
        .toList()
      ..sort((a, b) => a.validUntil.compareTo(b.validUntil));
