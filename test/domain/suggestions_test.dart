import 'package:card_master/domain/models.dart';
import 'package:card_master/domain/recommender.dart';
import 'package:card_master/domain/suggestions.dart';
import 'package:flutter_test/flutter_test.dart';

UserCard _card(String id) => UserCard(
      id: id,
      productId: id,
      bankName: 'Bank',
      name: id,
      network: CardNetwork.visa,
      creditLimitPaise: 0,
      statementDay: 1,
      dueDay: 20,
    );

Benefit _b(String id, SpendCategory c, int bps) => Benefit(
    id: id, category: c, kind: BenefitKind.reward, title: id, rateBps: bps);

void main() {
  final now = DateTime(2026, 10, 22);
  final mine = [
    CardWithBenefits(
        card: _card('basic'), benefits: [_b('b', SpendCategory.other, 100)]),
  ];
  final food = CardWithBenefits(
      card: _card('food'),
      benefits: [
        _b('f', SpendCategory.foodDelivery, 1000),
        _b('fo', SpendCategory.other, 100),
      ]);
  final travel = CardWithBenefits(
      card: _card('travel'),
      benefits: [_b('t', SpendCategory.travel, 500)]);

  Spend s(int paise, SpendCategory c, {PayeeType payee = PayeeType.merchant}) =>
      Spend(
        id: '$paise$c',
        amountPaise: paise,
        category: c,
        paymentKind: PaymentKind.cash,
        payee: payee,
        spentOn: now.subtract(const Duration(days: 10)),
      );

  test('suggests the card that fits the spending, net of its fee', () {
    final r = suggestCards(
      mine: mine,
      candidates: [
        (id: 'food', name: 'Food card', card: food, fee: 50000),
        (id: 'travel', name: 'Travel card', card: travel, fee: 0),
      ],
      // ₹30,000 food delivery in 90 days: +9% → ₹2,700 / 90 days.
      spends: [s(3000000, SpendCategory.foodDelivery)],
      now: now,
    );
    expect(r.single.productId, 'food');
    // 2,700 × 365/90 ≈ ₹10,950, minus ₹500 fee.
    expect(r.single.extraPerYearPaise, (270000 * 365 / 90).round() - 50000);
  });

  test('ignores payments to people and rent; nothing when there is no gain', () {
    final r = suggestCards(
      mine: mine,
      candidates: [(id: 'food', name: 'Food card', card: food, fee: 0)],
      spends: [
        s(3000000, SpendCategory.foodDelivery, payee: PayeeType.person),
        s(3000000, SpendCategory.rent),
      ],
      now: now,
    );
    expect(r, isEmpty);
  });

  test('never suggests a card the user already has', () {
    final r = suggestCards(
      mine: [...mine, food],
      candidates: [(id: 'food', name: 'Food card', card: food, fee: 0)],
      spends: [s(3000000, SpendCategory.foodDelivery)],
      now: now,
    );
    expect(r, isEmpty);
  });
}
