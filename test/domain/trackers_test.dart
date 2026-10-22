import 'package:card_master/domain/models.dart';
import 'package:card_master/domain/trackers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 22); // Q4: Oct–Dec

  test('lounge status counts this quarter and the spend still needed', () {
    final s = loungeStatus(
      const LoungeRule(
          cardId: 'c', visitsPerQuarter: 2, spendGatePaise: 5000000),
      [DateTime(2026, 10, 3), DateTime(2026, 9, 30)],
      [
        Spend(
          id: '1',
          amountPaise: 3200000,
          category: SpendCategory.shopping,
          paymentKind: PaymentKind.card,
          userCardId: 'c',
          spentOn: DateTime(2026, 10, 10),
        ),
      ],
      now,
    );
    expect(s.quarterStart, DateTime(2026, 10, 1));
    expect(s.quarterEnd, DateTime(2027, 1, 1));
    expect(s.used, 1);
    expect(s.left, 1);
    expect(s.toUnlockNextPaise, 1800000);
  });

  test('EMI months left and remaining amount', () {
    final emi = Emi(
      id: 'e',
      cardId: 'c',
      title: 'Phone',
      monthlyPaise: 500000,
      totalMonths: 12,
      firstMonth: DateTime(2026, 6, 1),
    );
    expect(emi.monthsPaid(now), 5); // Jun–Oct
    expect(emi.monthsLeft(now), 7);
    expect(emi.remainingPaise(now), 3500000);
    expect(emi.isActive(DateTime(2027, 5, 15)), isFalse);
  });

  test('offers: active ones for the category, soonest expiry first', () {
    final offers = [
      SavedOffer(
          id: 'a',
          title: '10% off',
          category: SpendCategory.shopping,
          validUntil: DateTime(2026, 10, 31)),
      SavedOffer(
          id: 'b',
          title: 'Expired',
          category: SpendCategory.shopping,
          validUntil: DateTime(2026, 10, 21)),
      SavedOffer(
          id: 'c',
          title: 'Ends today',
          category: SpendCategory.shopping,
          validUntil: DateTime(2026, 10, 22)),
      SavedOffer(
          id: 'd',
          title: 'Food',
          category: SpendCategory.foodDelivery,
          validUntil: DateTime(2026, 12, 1)),
    ];
    expect(activeOffersFor(offers, SpendCategory.shopping, now).map((o) => o.id),
        ['c', 'a']);
  });
}
