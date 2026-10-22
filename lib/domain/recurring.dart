import 'models.dart';

class RecurringRule {
  const RecurringRule({
    required this.id,
    required this.title,
    required this.amountPaise,
    required this.category,
    required this.paymentKind,
    required this.dayOfMonth,
    required this.autoAdd,
    this.userCardId,
    this.lastAddedMonth,
  });

  final String id;
  final String title;
  final int amountPaise;
  final SpendCategory category;
  final PaymentKind paymentKind;
  final String? userCardId;
  final int dayOfMonth;

  /// true: added automatically when due; false: shown as "Add?" in Money.
  final bool autoAdd;

  /// year * 12 + month of the last month this rule produced an expense.
  final int? lastAddedMonth;
}

int monthKey(DateTime d) => d.year * 12 + (d.month - 1);

DateTime dateForMonth(int key, int day) {
  final year = key ~/ 12;
  final month = key % 12 + 1;
  final last = DateTime(year, month + 1, 0).day;
  return DateTime(year, month, day.clamp(1, last));
}

/// Occurrences due on or before [now] that haven't been added yet, oldest
/// first. Catches up at most [maxCatchUp] months (e.g. app unused for a
/// while); a brand-new rule starts with the current month.
List<(RecurringRule, DateTime)> dueOccurrences(
  List<RecurringRule> rules,
  DateTime now, {
  int maxCatchUp = 3,
}) {
  final out = <(RecurringRule, DateTime)>[];
  final current = monthKey(now);
  for (final r in rules) {
    final start = r.lastAddedMonth == null
        ? current
        : (r.lastAddedMonth! + 1).clamp(current - maxCatchUp + 1, current + 1);
    for (var k = start; k <= current; k++) {
      final date = dateForMonth(k, r.dayOfMonth);
      if (!date.isAfter(now)) out.add((r, date));
    }
  }
  out.sort((a, b) => a.$2.compareTo(b.$2));
  return out;
}
