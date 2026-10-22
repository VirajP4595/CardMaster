import 'money.dart';
import 'sms_parser.dart';

/// Spends found in a credit card statement's text (docs/06 Tier 2, beta).
class StatementResult {
  const StatementResult({
    required this.spends,
    required this.linesRead,
    required this.creditsSkipped,
    this.last4,
  });

  final List<ParsedSpend> spends;
  final int linesRead;
  final int creditsSkipped;

  /// Card number ending found in the statement, used to pick the card.
  final String? last4;
}

const _mon = {
  'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
  'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
};

// A transaction line: date, description, amount, optional Cr/Dr marker.
//   21/10/2026  BESCOM BANGALORE           2,400.00
//   21 Oct 26   SWIGGY*ORDER 1234            486.00 Dr
//   20-10-2026  PAYMENT RECEIVED - THANK YOU 18,240.00 Cr
final _line = RegExp(
  r'^\s*(\d{1,2})[\s/\-.]([A-Za-z]{3}|\d{1,2})[\s/\-.,]+(\d{2,4})\s+'
  r'(.+?)\s+'
  r'(?:(?:INR|Rs\.?|₹)\s*)?([\d,]+\.\d{2})\s*(Cr|CR|Dr|DR|C|D)?\s*$',
);
final _creditWords = RegExp(
  r'\b(payment|thank you|refund|reversal|cashback|credit adj|neft|imps)\b',
  caseSensitive: false,
);
final _last4 = RegExp(
  r'(?:X{4}[\s\-]?){3}(\d{4})|(?:\*{4}[\s\-]?){3}(\d{4})|card (?:no\.?|number)\s*:?\s*\S*?(\d{4})\b',
  caseSensitive: false,
);

/// Generic parser for statement text. Banks lay statements out
/// differently, so this reads any line shaped like "date … description …
/// amount" and skips credits (payments, refunds, cashback). Results go to
/// the review screen, where the user confirms each one.
StatementResult parseStatementText(String text) {
  final lines = text.split(RegExp(r'\r?\n'));
  final spends = <ParsedSpend>[];
  var credits = 0;
  for (final raw in lines) {
    final m = _line.firstMatch(raw);
    if (m == null) continue;
    final day = int.parse(m.group(1)!);
    final monthRaw = m.group(2)!;
    final month = int.tryParse(monthRaw) ?? _mon[monthRaw.toLowerCase()];
    var year = int.parse(m.group(3)!);
    if (year < 100) year += 2000;
    if (month == null || month > 12 || day > 31) continue;

    final desc = m.group(4)!.trim();
    final marker = m.group(6)?.toUpperCase();
    final isCredit =
        marker == 'CR' || marker == 'C' || _creditWords.hasMatch(desc);
    if (isCredit) {
      credits++;
      continue;
    }
    final amount = parseRupeesToPaise(m.group(5)!);
    if (amount == null || amount == 0) continue;
    spends.add(ParsedSpend(
      amountPaise: amount,
      merchant: _cleanMerchant(desc),
      date: DateTime(year, month, day),
      viaUpi: RegExp(r'\bUPI\b', caseSensitive: false).hasMatch(desc),
      international: RegExp(r'\b(USD|EUR|GBP|AED|SGD|THB|JPY|AUD)\b')
          .hasMatch(desc),
    ));
  }

  String? last4;
  final l = _last4.firstMatch(text);
  if (l != null) last4 = l.group(1) ?? l.group(2) ?? l.group(3);

  return StatementResult(
    spends: [for (final s in spends) _withCard(s, last4)],
    linesRead: lines.where((l) => l.trim().isNotEmpty).length,
    creditsSkipped: credits,
    last4: last4,
  );
}

ParsedSpend _withCard(ParsedSpend s, String? last4) => ParsedSpend(
      amountPaise: s.amountPaise,
      last4: last4,
      merchant: s.merchant,
      date: s.date,
      viaUpi: s.viaUpi,
      international: s.international,
    );

/// "SWIGGY*ORDER 1234 BANGALORE IN" -> "SWIGGY ORDER BANGALORE".
String _cleanMerchant(String d) => d
    .toUpperCase()
    .replaceAll(RegExp(r'[*#]'), ' ')
    // Drop order/reference numbers, but not amounts like 120.50.
    .replaceAll(RegExp(r'(?<![\d.,])\b\d{3,}\b(?![\d.,])'), '')
    .replaceAll(RegExp(r'\b(IN|IND)\s*$'), '')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();
