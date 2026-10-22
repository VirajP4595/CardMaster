import 'models.dart';

/// Statement and due dates for a purchase made on [purchase].
class CycleDates {
  const CycleDates(this.statement, this.due);
  final DateTime statement;
  final DateTime due;

  int interestFreeDaysFrom(DateTime purchase) =>
      _dateOnly(due).difference(_dateOnly(purchase)).inDays;
}

/// A purchase on or before the statement day lands on this month's statement;
/// later purchases land on next month's. The due date follows the statement:
/// same month if the due day is after the statement day, otherwise next month.
CycleDates cycleFor(UserCard card, DateTime purchase) {
  final p = _dateOnly(purchase);
  var statement = _safeDate(p.year, p.month, card.statementDay);
  if (p.isAfter(statement)) {
    statement = _safeDate(p.year, p.month + 1, card.statementDay);
  }
  final dueMonth =
      card.dueDay > card.statementDay ? statement.month : statement.month + 1;
  final due = _safeDate(statement.year, dueMonth, card.dueDay);
  return CycleDates(statement, due);
}

class PayTodayOption {
  const PayTodayOption(this.card, this.days, this.dates);
  final UserCard card;
  final int days;
  final CycleDates dates;
}

/// Cards ranked by interest-free days for a purchase today.
List<PayTodayOption> payTodayRanking(List<UserCard> cards, DateTime today) {
  final options = cards.map((c) {
    final dates = cycleFor(c, today);
    return PayTodayOption(c, dates.interestFreeDaysFrom(today), dates);
  }).toList()
    ..sort((a, b) => b.days.compareTo(a.days));
  return options;
}

/// Next due date on or after [today] (for reminders and "due in N days").
DateTime nextDueDate(UserCard card, DateTime today) {
  final t = _dateOnly(today);
  var due = _safeDate(t.year, t.month, card.dueDay);
  if (due.isBefore(t)) due = _safeDate(t.year, t.month + 1, card.dueDay);
  return due;
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Builds a date, clamping the day to the month's length (e.g. 31 Feb -> 28/29).
/// Months above 12 roll into the next year.
DateTime _safeDate(int year, int month, int day) {
  final firstOfMonth = DateTime(year, month, 1);
  final lastDay = DateTime(firstOfMonth.year, firstOfMonth.month + 1, 0).day;
  return DateTime(firstOfMonth.year, firstOfMonth.month,
      day.clamp(1, lastDay));
}
