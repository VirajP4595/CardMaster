import 'package:card_master/domain/csv_export.dart';
import 'package:card_master/domain/models.dart';
import 'package:card_master/domain/recurring.dart';
import 'package:flutter_test/flutter_test.dart';

RecurringRule _rule({int day = 5, int? last}) => RecurringRule(
      id: 'r',
      title: 'Rent',
      amountPaise: 2500000,
      category: SpendCategory.rent,
      paymentKind: PaymentKind.bankUpi,
      dayOfMonth: day,
      autoAdd: true,
      lastAddedMonth: last,
    );

void main() {
  final now = DateTime(2026, 10, 22);

  test('new rule is due this month once its day has passed', () {
    expect(dueOccurrences([_rule(day: 5)], now).single.$2,
        DateTime(2026, 10, 5));
    expect(dueOccurrences([_rule(day: 25)], now), isEmpty);
  });

  test('nothing due when this month is already added', () {
    expect(dueOccurrences([_rule(last: monthKey(now))], now), isEmpty);
  });

  test('catches up missed months, at most three', () {
    final r = dueOccurrences([_rule(last: monthKey(DateTime(2026, 1, 1)))], now);
    expect(r.map((x) => x.$2), [
      DateTime(2026, 8, 5),
      DateTime(2026, 9, 5),
      DateTime(2026, 10, 5),
    ]);
  });

  test('day 31 lands on the last day of short months', () {
    expect(dateForMonth(monthKey(DateTime(2026, 2, 1)), 31),
        DateTime(2026, 2, 28));
  });

  test('CSV quotes, escapes and blocks formula injection', () {
    final csv = spendsToCsv([
      Spend(
        id: '1',
        amountPaise: 240050,
        category: SpendCategory.utilities,
        paymentKind: PaymentKind.card,
        userCardId: 'c',
        note: 'Bill, "October"',
        spentOn: DateTime(2026, 10, 21),
      ),
      Spend(
        id: '2',
        amountPaise: 50000,
        category: SpendCategory.other,
        paymentKind: PaymentKind.cash,
        note: '=HYPERLINK("x")',
        spentOn: DateTime(2026, 10, 1),
      ),
    ], {'c': 'Airtel Axis'});
    final lines = csv.trim().split('\r\n');
    expect(lines[0], startsWith('date,amount_inr'));
    expect(lines[1], startsWith('2026-10-01,500.00,Other,cash,'));
    expect(lines[1], contains('"\'=HYPERLINK(""x"")"'));
    expect(lines[2],
        '2026-10-21,2400.50,Utilities,card,Airtel Axis,no,no,"Bill, ""October"""');
  });
}
