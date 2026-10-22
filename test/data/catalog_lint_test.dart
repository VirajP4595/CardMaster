import 'package:card_master/data/catalog/catalog_lint.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _catalog(Map<String, dynamic> product) => {
      'version': 1,
      'banks': [
        {'id': 'demo', 'name': 'Demo Bank', 'helpline': '1800 123 4567'},
      ],
      'products': [product],
    };

Map<String, dynamic> _product({List<Map<String, dynamic>>? benefits}) => {
      'id': 'demo_cash',
      'bankId': 'demo',
      'name': 'Demo Cashback',
      'network': 'VISA',
      'annualFeePaise': 50000,
      'waiverSpendPaise': 20000000,
      'face': {'base': '#123456'},
      'sourceUrl': 'https://demo.example/cash',
      'benefits': benefits ??
          [
            {
              'id': 'demo_cash_other',
              'category': 'OTHER',
              'kind': 'REWARD',
              'title': 'Everything else',
              'rateBps': 100,
              'sourceUrl': 'https://demo.example/cash',
            },
            {
              'id': 'demo_cash_fx',
              'category': 'FOREIGN',
              'kind': 'FOREX_MARKUP',
              'title': 'Forex markup',
              'rateBps': 350,
              'sourceUrl': 'https://demo.example/cash',
            },
          ],
    };

void main() {
  test('a clean product has no errors or warnings', () {
    final issues = lintCatalog(_catalog(_product()));
    expect(issues.errors, isEmpty);
    expect(issues.warnings, isEmpty);
  });

  test('catches unbelievable rates, bad forex and missing sources', () {
    final issues = lintCatalog(_catalog(_product(benefits: [
      {
        'id': 'demo_cash_shop',
        'category': 'SHOPPING',
        'kind': 'REWARD',
        'title': 'Shopping',
        'rateBps': 5000,
        'sourceUrl': 'https://demo.example/cash',
      },
      {
        'id': 'demo_cash_fx',
        'category': 'TRAVEL',
        'kind': 'FOREX_MARKUP',
        'title': 'Forex',
        'rateBps': 900,
        'sourceUrl': 'http://demo.example',
      },
      {
        'id': 'other_card_x',
        'category': 'NOPE',
        'kind': 'REWARD',
        'title': 'x',
        'rateBps': 100,
      },
    ])));
    final all = issues.errors.join('\n');
    expect(all, contains('not believable'));
    expect(all, contains('must be category FOREIGN'));
    expect(all, contains('forex markup must be 0–5%'));
    expect(all, contains('https'));
    expect(all, contains('must start with "demo_cash_"'));
    expect(all, contains('bad category NOPE'));
    expect(issues.warnings.join(), contains('no base rate'));
  });
}
