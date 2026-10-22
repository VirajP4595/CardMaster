import 'package:card_master/domain/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('groups digits the Indian way', () {
    expect(groupIndian(0), '0');
    expect(groupIndian(999), '999');
    expect(groupIndian(1000), '1,000');
    expect(groupIndian(123456), '1,23,456');
    expect(groupIndian(123456789), '12,34,56,789');
  });

  test('formats paise as rupees', () {
    expect(formatInr(85000000), '₹8,50,000');
    expect(formatInr(240050, showPaise: true), '₹2,400.50');
    expect(formatInr(-32000), '−₹320');
  });

  test('parses rupee strings', () {
    expect(parseRupeesToPaise('1,23,456.50'), 12345650);
    expect(parseRupeesToPaise('2400'), 240000);
    expect(parseRupeesToPaise(''), isNull);
    expect(parseRupeesToPaise('abc'), isNull);
  });

  test('applies basis points and formats them', () {
    expect(applyBps(240000, 1000), 24000);
    expect(formatBps(1000), '10%');
    expect(formatBps(150), '1.5%');
    expect(formatBps(0), '0%');
  });
}
