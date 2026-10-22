import 'models.dart';

class FeeWaiverStatus {
  const FeeWaiverStatus({
    required this.spentPaise,
    required this.targetPaise,
    required this.yearStart,
    required this.yearEnd,
    required this.daysLeft,
  });

  final int spentPaise;
  final int targetPaise;
  final DateTime yearStart;
  final DateTime yearEnd;
  final int daysLeft;

  int get remainingPaise => (targetPaise - spentPaise).clamp(0, targetPaise);
  bool get achieved => spentPaise >= targetPaise;
  double get progress =>
      targetPaise == 0 ? 1 : (spentPaise / targetPaise).clamp(0.0, 1.0);
}

/// Fee-waiver progress for the card year containing [today]. Free feature
/// (decision D2). Returns null when the card has no fee or no waiver rule.
FeeWaiverStatus? feeWaiverStatus(
  UserCard card,
  Iterable<Spend> spends,
  DateTime today,
) {
  final target = card.waiverSpendPaise;
  final month = card.anniversaryMonth;
  if (card.annualFeePaise == 0 || target == null || month == null) return null;

  final t = DateTime(today.year, today.month, today.day);
  var start = DateTime(t.year, month, 1);
  if (start.isAfter(t)) start = DateTime(t.year - 1, month, 1);
  final end = DateTime(start.year + 1, month, 1);

  final spent = spends
      .where((s) =>
          s.userCardId == card.id &&
          s.paymentKind == PaymentKind.card &&
          !s.spentOn.isBefore(start) &&
          s.spentOn.isBefore(end))
      .fold<int>(0, (sum, s) => sum + s.amountPaise);

  return FeeWaiverStatus(
    spentPaise: spent,
    targetPaise: target,
    yearStart: start,
    yearEnd: end,
    daysLeft: end.difference(t).inDays,
  );
}
