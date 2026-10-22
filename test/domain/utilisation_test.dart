import 'package:card_master/domain/models.dart';
import 'package:card_master/domain/utilisation.dart';
import 'package:flutter_test/flutter_test.dart';

const _card = UserCard(
  id: 'c',
  productId: 'p',
  bankName: 'Bank',
  name: 'Card',
  network: CardNetwork.visa,
  creditLimitPaise: 10000000, // ₹1,00,000
  statementDay: 12,
  dueDay: 2,
);

Spend _s(String id, int paise, DateTime d) => Spend(
      id: id,
      amountPaise: paise,
      category: SpendCategory.shopping,
      paymentKind: PaymentKind.card,
      userCardId: 'c',
      spentOn: d,
    );

void main() {
  test('counts the current cycle and how much to pay before the statement', () {
    final a = utilisationAdvice(_card, [
      _s('old', 9000000, DateTime(2026, 10, 12)), // on last statement: excluded
      _s('a', 3000000, DateTime(2026, 10, 13)),
      _s('b', 1000000, DateTime(2026, 10, 20)),
      _s('today', 1000000, DateTime(2026, 10, 22, 18, 30)), // later today
    ], DateTime(2026, 10, 22, 9));
    expect(a.cycleStart, DateTime(2026, 10, 13));
    expect(a.nextStatement, DateTime(2026, 11, 12));
    expect(a.loggedPaise, 5000000);
    expect(a.ratio, 0.5);
    // Keep under ₹30,000: pay ₹20,000 before 12 Nov.
    expect(a.payBeforeStatementPaise, 2000000);
    expect(a.overTarget, isTrue);
  });

  test('before the statement day this month, the cycle began last month', () {
    final a = utilisationAdvice(_card, [
      _s('a', 1000000, DateTime(2026, 10, 1)),
    ], DateTime(2026, 10, 5));
    expect(a.cycleStart, DateTime(2026, 9, 13));
    expect(a.nextStatement, DateTime(2026, 10, 12));
    expect(a.overTarget, isFalse);
  });
}
