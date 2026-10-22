import 'models.dart';

class UtilisationAdvice {
  const UtilisationAdvice({
    required this.cycleStart,
    required this.nextStatement,
    required this.loggedPaise,
    required this.limitPaise,
  });

  final DateTime cycleStart;
  final DateTime nextStatement;

  /// Card spends the user logged since the last statement. The app can't
  /// see the real balance, so this is a lower bound.
  final int loggedPaise;
  final int limitPaise;

  static const targetBps = 3000; // keep reported use under 30%

  double get ratio => limitPaise == 0 ? 0 : loggedPaise / limitPaise;

  /// Pay at least this before the statement date to report under 30%.
  int get payBeforeStatementPaise {
    final target = limitPaise * targetBps ~/ 10000;
    return (loggedPaise - target).clamp(0, loggedPaise);
  }

  bool get overTarget => payBeforeStatementPaise > 0;
}

/// Bureaus see the balance on the statement date, so paying part of it
/// before that date lowers reported utilisation [Likely]. Based only on
/// logged spends (docs/06 Tier 2 #12).
UtilisationAdvice utilisationAdvice(
  UserCard card,
  List<Spend> spends,
  DateTime now,
) {
  final today = DateTime(now.year, now.month, now.day);
  DateTime statementIn(int year, int month) {
    final last = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, card.statementDay.clamp(1, last));
  }

  final thisMonth = statementIn(today.year, today.month);
  final lastStatement = today.isAfter(thisMonth)
      ? thisMonth
      : statementIn(today.year, today.month - 1);
  final next = today.isAfter(thisMonth)
      ? statementIn(today.year, today.month + 1)
      : thisMonth;
  final logged = spends
      .where((s) =>
          s.userCardId == card.id &&
          s.paymentKind == PaymentKind.card &&
          !_day(s.spentOn).isBefore(lastStatement.add(const Duration(days: 1))) &&
          !_day(s.spentOn).isAfter(today))
      .fold<int>(0, (a, s) => a + s.amountPaise);
  return UtilisationAdvice(
    cycleStart: lastStatement.add(const Duration(days: 1)),
    nextStatement: next,
    loggedPaise: logged,
    limitPaise: card.creditLimitPaise,
  );
}

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);
