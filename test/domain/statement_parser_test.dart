import 'package:card_master/domain/statement_parser.dart';
import 'package:flutter_test/flutter_test.dart';

// Illustrative statement text in a few common layouts (not a real bank's).
const _text = '''
CREDIT CARD STATEMENT
Card Number: XXXX XXXX XXXX 7302
Statement Date 12/11/2026     Payment Due Date 02/12/2026
Date        Transaction Details                 Amount (Rs.)
21/10/2026  BESCOM BANGALORE                    2,400.00
21 Oct 26   SWIGGY*ORDER 1234 BANGALORE IN        486.00 Dr
22-10-2026  UPI-ZEPTO MARKETPLACE                 1,860.50
25/10/2026  PAYMENT RECEIVED - THANK YOU        18,240.00 Cr
26/10/2026  AMAZON REFUND                          999.00 Cr
28/10/2026  AGODA USD 120.50                    10,120.00
Total Amount Due                                23,866.50
''';

void main() {
  test('reads spends, skips credits and finds the card', () {
    final r = parseStatementText(_text);
    expect(r.last4, '7302');
    expect(r.creditsSkipped, 2);
    expect(r.spends.map((s) => s.amountPaise),
        [240000, 48600, 186050, 1012000]);
    expect(r.spends.map((s) => s.merchant), [
      'BESCOM BANGALORE',
      'SWIGGY ORDER BANGALORE',
      'UPI-ZEPTO MARKETPLACE',
      'AGODA USD 120.50',
    ]);
    expect(r.spends[1].date, DateTime(2026, 10, 21));
    expect(r.spends[2].viaUpi, isTrue);
    expect(r.spends[3].international, isTrue);
    expect(r.spends.every((s) => s.last4 == '7302'), isTrue);
  });

  test('ignores totals and headers', () {
    final r = parseStatementText('Total Amount Due 23,866.50\nMinimum Due 1,200.00');
    expect(r.spends, isEmpty);
  });
}
