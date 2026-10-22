import 'package:card_master/domain/card_value.dart';
import 'package:card_master/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

const _card = UserCard(
  id: 'c',
  productId: 'p',
  bankName: 'Axis Bank',
  name: 'Airtel Axis',
  network: CardNetwork.mastercard,
  creditLimitPaise: 0,
  statementDay: 12,
  dueDay: 2,
  annualFeePaise: 50000,
  waiverSpendPaise: 20000000,
  anniversaryMonth: 1,
);

const _benefits = [
  Benefit(
    id: 'util',
    category: SpendCategory.utilities,
    kind: BenefitKind.reward,
    title: 'Utilities',
    rateBps: 1000,
    monthlyCapPaise: 25000,
  ),
  Benefit(
    id: 'other',
    category: SpendCategory.other,
    kind: BenefitKind.reward,
    title: 'Other',
    rateBps: 100,
  ),
];

Spend _s(String id, int paise, SpendCategory c, DateTime d,
        {bool intl = false}) =>
    Spend(
      id: id,
      amountPaise: paise,
      category: c,
      paymentKind: PaymentKind.card,
      userCardId: 'c',
      international: intl,
      spentOn: d,
    );

void main() {
  final now = DateTime(2026, 10, 22);

  test('applies monthly caps per month, subtracts fee and forex', () {
    final v = cardYearValue(_card, _benefits, [
      // Two months of ₹3,000 utilities: capped at ₹250 each month.
      _s('a', 300000, SpendCategory.utilities, DateTime(2026, 3, 5)),
      _s('b', 300000, SpendCategory.utilities, DateTime(2026, 4, 5)),
      // ₹10,000 abroad: 1% back, 3.5% default markup.
      _s('c', 1000000, SpendCategory.shopping, DateTime(2026, 5, 1),
          intl: true),
      // Last card year: ignored.
      _s('d', 900000, SpendCategory.other, DateTime(2025, 12, 31)),
    ], now);
    expect(v.rewardsPaise, 25000 + 25000 + 10000);
    expect(v.forexPaidPaise, 35000);
    expect(v.feePaise, 50000);
    expect(v.netPaise, 60000 - 50000 - 35000);
    expect(v.verdict, Verdict.reconsider);
    expect(v.from, DateTime(2026, 1, 1));
  });

  test('fee waived when the spend target is met', () {
    final v = cardYearValue(_card, _benefits, [
      _s('a', 20000000, SpendCategory.other, DateTime(2026, 6, 1)),
    ], now);
    expect(v.feeWaived, isTrue);
    expect(v.feePaise, 0);
    expect(v.netPaise, 200000);
    expect(v.verdict, Verdict.keep);
  });

  test('small net on a fee card is borderline', () {
    final v = cardYearValue(_card, _benefits, [
      _s('a', 9000000, SpendCategory.other, DateTime(2026, 6, 1)),
    ], now);
    expect(v.netPaise, 90000 - 50000);
    expect(v.verdict, Verdict.borderline);
  });
}
