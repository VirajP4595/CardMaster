import 'package:card_master/domain/billing_cycle.dart';
import 'package:card_master/domain/fee_waiver.dart';
import 'package:card_master/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

UserCard _card({
  required int statement,
  required int due,
  int fee = 0,
  int? waiver,
  int? month,
}) =>
    UserCard(
      id: 'c',
      productId: 'p',
      bankName: 'Bank',
      name: 'Card',
      network: CardNetwork.visa,
      creditLimitPaise: 0,
      statementDay: statement,
      dueDay: due,
      annualFeePaise: fee,
      waiverSpendPaise: waiver,
      anniversaryMonth: month,
    );

void main() {
  final purchase = DateTime(2026, 10, 22);

  test('matches the design examples for interest-free days', () {
    // Statement 12, due 2 -> statement 12 Nov, due 2 Dec.
    expect(cycleFor(_card(statement: 12, due: 2), purchase)
        .interestFreeDaysFrom(purchase), 41);
    // Statement 20, due 10 -> statement 20 Nov, due 10 Dec.
    expect(cycleFor(_card(statement: 20, due: 10), purchase)
        .interestFreeDaysFrom(purchase), 49);
    // Statement 5, due 25 -> statement 5 Nov, due 25 Nov.
    expect(cycleFor(_card(statement: 5, due: 25), purchase)
        .interestFreeDaysFrom(purchase), 34);
  });

  test('purchase on statement day goes on that statement', () {
    final d = cycleFor(_card(statement: 22, due: 12), purchase);
    expect(d.statement, DateTime(2026, 10, 22));
    expect(d.due, DateTime(2026, 11, 12));
  });

  test('clamps day 31 to short months and rolls the year', () {
    final d = cycleFor(_card(statement: 31, due: 20), DateTime(2026, 2, 10));
    expect(d.statement, DateTime(2026, 2, 28));
    final dec = cycleFor(_card(statement: 5, due: 25), DateTime(2026, 12, 10));
    expect(dec.statement, DateTime(2027, 1, 5));
  });

  test('ranks cards by interest-free days', () {
    final ranking = payTodayRanking(
      [_card(statement: 5, due: 25), _card(statement: 20, due: 10)],
      purchase,
    );
    expect(ranking.first.days, 49);
  });

  test('fee waiver counts card spends in the current card year', () {
    final card = _card(
        statement: 12, due: 2, fee: 50000, waiver: 20000000, month: 1);
    Spend s(int paise, DateTime d, {PaymentKind kind = PaymentKind.card}) =>
        Spend(
          id: '$paise$d',
          amountPaise: paise,
          category: SpendCategory.shopping,
          paymentKind: kind,
          userCardId: 'c',
          spentOn: d,
        );
    final status = feeWaiverStatus(card, [
      s(14200000, DateTime(2026, 3, 1)),
      s(5000000, DateTime(2025, 12, 31)), // previous card year
      s(100000, DateTime(2026, 4, 1), kind: PaymentKind.cash),
    ], purchase)!;
    expect(status.spentPaise, 14200000);
    expect(status.remainingPaise, 5800000);
    expect(status.yearEnd, DateTime(2027, 1, 1));
    expect(status.daysLeft, 71);
  });

  test('no waiver status for a free card', () {
    expect(feeWaiverStatus(_card(statement: 1, due: 20), const [], purchase),
        isNull);
  });
}
