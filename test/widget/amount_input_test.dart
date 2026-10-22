import 'package:card_master/domain/money.dart';
import 'package:card_master/ui/amount_input.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

TextEditingValue _type(String text, {int? cursor, bool decimals = true}) =>
    IndianAmountFormatter(decimals: decimals).formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: cursor ?? text.length),
      ),
    );

void main() {
  test('groups lakhs and crores while typing', () {
    expect(_type('999').text, '999');
    expect(_type('1000').text, '1,000');
    expect(_type('150000').text, '1,50,000');
    expect(_type('12345678').text, '1,23,45,678');
    expect(_type('1,50,0000').text, '15,00,000');
  });

  test('keeps two decimals, drops junk and leading zeros', () {
    expect(_type('2400.505').text, '2,400.50');
    expect(_type('.5').text, '0.5');
    expect(_type('0042').text, '42');
    expect(_type('₹1a2b3').text, '123');
    expect(_type('12.5', decimals: false).text, '125');
  });

  test('cursor stays after the same digit', () {
    // Typed "5" after "1,0" in "1,000" → "10500" → "10,500", cursor after 5.
    final v = _type('1,0500', cursor: 4);
    expect(v.text, '10,500');
    expect(v.selection.baseOffset, 4);
    expect(_type('100000').selection.baseOffset, '1,00,000'.length);
  });

  test('formatted text parses back to the same paise', () {
    for (final paise in [0, 5000, 2500000, 12345678900, 1050]) {
      expect(parseRupeesToPaise(amountFieldText(paise)), paise);
    }
    expect(amountFieldText(null), '');
    expect(amountFieldText(25000000), '2,50,000');
  });
}
