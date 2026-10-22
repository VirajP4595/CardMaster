import 'package:card_master/domain/entitlement.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final start = DateTime(2026, 10, 1);

  test('trial lasts 14 days', () {
    const gated = true;
    final e = Entitlement(purchased: false, trialStart: start, gatingEnabled: gated);
    expect(e.trialDaysLeft(DateTime(2026, 10, 4)), 11);
    expect(e.hasPro(DateTime(2026, 10, 14)), isTrue);
    expect(e.hasPro(DateTime(2026, 10, 15)), isFalse);
  });

  test('purchase unlocks for good', () {
    final e = Entitlement(purchased: true, trialStart: start, gatingEnabled: true);
    expect(e.hasPro(DateTime(2030, 1, 1)), isTrue);
  });

  test('everything is unlocked while gating is off', () {
    final e = Entitlement(purchased: false, trialStart: start, gatingEnabled: false);
    expect(e.hasPro(DateTime(2030, 1, 1)), isTrue);
  });

  test('product ids include pro, coffees and tip tiers', () {
    expect(ProductIds.all, contains('pro_lifetime'));
    expect(ProductIds.all.length, 1 + 3 + 8);
  });
}
