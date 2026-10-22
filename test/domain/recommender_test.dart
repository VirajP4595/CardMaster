import 'package:card_master/domain/models.dart';
import 'package:card_master/domain/recommender.dart';
import 'package:flutter_test/flutter_test.dart';

UserCard _card(String id, CardNetwork network) => UserCard(
      id: id,
      productId: id,
      bankName: 'Bank',
      name: id,
      network: network,
      creditLimitPaise: 25000000,
      statementDay: 12,
      dueDay: 2,
    );

Benefit _reward(String id, SpendCategory c, int bps, {int? cap, int? min}) =>
    Benefit(
      id: id,
      category: c,
      kind: BenefitKind.reward,
      title: id,
      rateBps: bps,
      monthlyCapPaise: cap,
      minTxnPaise: min,
    );

void main() {
  final airtel = CardWithBenefits(
    card: _card('airtel', CardNetwork.mastercard),
    benefits: [
      _reward('a_util', SpendCategory.utilities, 1000, cap: 25000),
      _reward('a_other', SpendCategory.other, 100),
    ],
  );
  final scapia = CardWithBenefits(
    card: _card('scapia', CardNetwork.visa),
    benefits: [
      _reward('s_util', SpendCategory.utilities, 0),
      _reward('s_other', SpendCategory.other, 200),
      const Benefit(
        id: 's_fx',
        category: SpendCategory.foreign,
        kind: BenefitKind.forexMarkup,
        title: 'Zero forex',
        rateBps: 0,
      ),
    ],
  );
  final neu = CardWithBenefits(
    card: _card('neu', CardNetwork.rupay),
    benefits: [_reward('n_other', SpendCategory.other, 150)],
  );

  test('picks the highest net reward', () {
    final r = recommend(
      const Purchase(category: SpendCategory.utilities, amountPaise: 240000),
      [scapia, neu, airtel],
    );
    expect(r.first.card.id, 'airtel');
    expect(r.first.netPaise, 24000);
  });

  test('excluded category earns nothing and warns', () {
    final r = recommend(
      const Purchase(category: SpendCategory.utilities, amountPaise: 240000),
      [scapia],
    );
    expect(r.single.netPaise, 0);
    expect(r.single.warning, contains('Earns nothing'));
  });

  test('only RuPay cards are eligible on UPI', () {
    final r = recommend(
      const Purchase(
          category: SpendCategory.groceries, amountPaise: 100000, viaUpi: true),
      [airtel, scapia, neu],
    );
    expect(r.first.card.id, 'neu');
    expect(r.where((x) => !x.eligible).length, 2);
    expect(r.last.eligible, isFalse);
  });

  test('monthly cap limits the reward', () {
    final capped = CardWithBenefits(
      card: airtel.card,
      benefits: airtel.benefits,
      capUsedPaise: const {'a_util': 12000},
    );
    final r = recommend(
      const Purchase(category: SpendCategory.utilities, amountPaise: 240000),
      [capped],
    );
    expect(r.single.netPaise, 13000);
    expect(r.single.warning, contains('left this month'));
  });

  test('foreign spends subtract the forex markup', () {
    final r = recommend(
      const Purchase(category: SpendCategory.foreign, amountPaise: 1000000),
      [airtel, scapia],
    );
    // Scapia: 2% back, 0% markup. Airtel: 1% back - 3.5% default markup.
    expect(r.first.card.id, 'scapia');
    expect(r.first.netPaise, 20000);
    expect(r.last.netPaise, 10000 - 35000);
  });

  test('min transaction falls back to the general rate', () {
    final card = CardWithBenefits(
      card: _card('x', CardNetwork.visa),
      benefits: [
        _reward('x_shop', SpendCategory.shopping, 500, min: 100000),
        _reward('x_other', SpendCategory.other, 100),
      ],
    );
    final r = recommend(
      const Purchase(category: SpendCategory.shopping, amountPaise: 50000),
      [card],
    );
    expect(r.single.rateBps, 100);
  });
}
