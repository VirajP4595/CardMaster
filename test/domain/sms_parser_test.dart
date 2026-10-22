import 'package:card_master/domain/sms_parser.dart';
import 'package:flutter_test/flutter_test.dart';

// Illustrative messages in the common shapes Indian banks use. Not real
// bank text; add anonymised real samples here as the parser is tuned.
void main() {
  test('reads a typical card spend alert', () {
    final p = parseBankSms(
        'INR 2,400.00 spent on Credit Card XX7302 at BESCOM on 21-10-26. '
        'Avl Lmt: INR 1,08,600')!;
    expect(p.amountPaise, 240000);
    expect(p.last4, '7302');
    expect(p.merchant, 'BESCOM');
    expect(p.date, DateTime(2026, 10, 21));
    expect(p.availableLimitPaise, 10860000);
    expect(p.viaUpi, isFalse);
  });

  test('reads a UPI card debit with ending-in wording', () {
    final p = parseBankSms(
        'Rs.1860 debited from card ending 1190 for UPI txn to SWIGGY on '
        '20/10/2026')!;
    expect(p.amountPaise, 186000);
    expect(p.last4, '1190');
    expect(p.merchant, 'SWIGGY');
    expect(p.viaUpi, isTrue);
    expect(p.date, DateTime(2026, 10, 20));
  });

  test('reads month names and foreign currency', () {
    final p = parseBankSms(
        'USD 120.50 spent on your card XX4821 at AGODA BANGKOK on 18-Oct-26')!;
    expect(p.amountPaise, 12050);
    expect(p.international, isTrue);
    expect(p.date, DateTime(2026, 10, 18));
  });

  test('ignores OTPs, credits, refunds and statements', () {
    expect(parseBankSms('123456 is your OTP for txn of INR 500 at AMAZON'),
        isNull);
    expect(parseBankSms('INR 500 credited to your card XX7302 as refund'),
        isNull);
    expect(
        parseBankSms('Statement for card XX7302: Total due INR 18,240. '
            'Min amount due INR 920'),
        isNull);
    expect(parseBankSms('Get 10% off on your next purchase!'), isNull);
  });

  test('splits and dedupes multi-copied messages', () {
    const copied = '''
INR 2,400.00 spent on Credit Card XX7302 at BESCOM on 21-10-26.

INR 2,400.00 spent on Credit Card XX7302 at BESCOM on 21-10-26.

123456 is your OTP. Do not share.

Rs.486 spent on card XX7302 at SWIGGY on 20-10-26.
''';
    final spends = parseMany(copied);
    expect(spends.length, 2);
    expect(spends.map((s) => s.merchant), ['BESCOM', 'SWIGGY']);
  });

  test('duplicate check allows a day of difference', () {
    final p = parseBankSms(
        'INR 486 spent on card XX7302 at SWIGGY on 20-10-26')!;
    expect(
        isLikelyDuplicate(p,
            amountPaise: 48600, last4: '7302', date: DateTime(2026, 10, 21)),
        isTrue);
    expect(
        isLikelyDuplicate(p,
            amountPaise: 48600, last4: '1190', date: DateTime(2026, 10, 20)),
        isFalse);
  });
}
