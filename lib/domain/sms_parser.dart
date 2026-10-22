import 'money.dart';

/// A card spend read from a bank SMS. The raw message text is never stored
/// (docs/08-EXPENSE-CAPTURE.md §3); only these fields are kept.
class ParsedSpend {
  const ParsedSpend({
    required this.amountPaise,
    this.last4,
    this.merchant,
    this.date,
    this.viaUpi = false,
    this.international = false,
    this.availableLimitPaise,
  });

  final int amountPaise;
  final String? last4;
  final String? merchant;
  final DateTime? date;
  final bool viaUpi;
  final bool international;
  final int? availableLimitPaise;
}

final _amount = RegExp(
  r'(?:INR|Rs\.?|₹)\s?([\d,]+(?:\.\d{1,2})?)',
  caseSensitive: false,
);
final _foreignAmount = RegExp(
  r'\b(USD|EUR|GBP|AED|SGD|THB|JPY|AUD)\s?([\d,]+(?:\.\d{1,2})?)',
  caseSensitive: false,
);
final _last4 = RegExp(
  r'(?:XX+|\*{2,}|x{2,}|ending\s*(?:with|in)?\s*|card\s*(?:no\.?\s*)?)(\d{4})\b',
  caseSensitive: false,
);
final _merchantAt = RegExp(
  // The terminator is a lookahead so "… XX7302 at BESCOM on …" can still
  // match "at BESCOM" after skipping the card number.
  r'\b(?:at|to|towards|on)\s+([A-Za-z0-9][A-Za-z0-9 *&@._\-/]{1,40}?)(?=\s+(?:on|dt|dated|at|for|via|ref|avl)\b|\s*[.,;]|\s*$)',
  caseSensitive: false,
);
final _date = RegExp(
  r'\b(\d{1,2})[-/ ]([A-Za-z]{3}|\d{1,2})[-/ ](\d{2,4})\b',
);
final _availableLimit = RegExp(
  r'(?:avl\.?|available)\s*(?:lmt|limit|credit limit|bal(?:ance)?)\s*(?:is|:)?\s*(?:INR|Rs\.?|₹)\s?([\d,]+(?:\.\d{1,2})?)',
  caseSensitive: false,
);
final _spendWords = RegExp(
  r'\b(spent|debited|used|purchase|txn|transaction|paid|charged)\b',
  caseSensitive: false,
);
final _notSpendWords = RegExp(
  r'\b(OTP|one time password|credited|refund|reversal|reversed|received|cashback of|payment of .* received|thank you for your payment|due date|min(?:imum)? amount due|statement)\b',
  caseSensitive: false,
);
const _months = {
  'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
  'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
};

/// Parses one bank message. Returns null when it isn't a card spend
/// (OTPs, credits, refunds, statements, promos).
ParsedSpend? parseBankSms(String text) {
  final t = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (!_spendWords.hasMatch(t) || _notSpendWords.hasMatch(t)) return null;

  int? amount;
  var international = false;
  final inr = _amount.firstMatch(t);
  if (inr != null) {
    amount = parseRupeesToPaise(inr.group(1)!);
  } else {
    final fx = _foreignAmount.firstMatch(t);
    if (fx != null) {
      // Foreign currency: keep the number; the user confirms the INR value.
      amount = parseRupeesToPaise(fx.group(2)!);
      international = true;
    }
  }
  if (amount == null || amount == 0) return null;

  final last4 = _last4.firstMatch(t)?.group(1);
  final limitMatch = _availableLimit.firstMatch(t);

  return ParsedSpend(
    amountPaise: amount,
    last4: last4,
    merchant: _merchant(t),
    date: _parseDate(t),
    viaUpi: RegExp(r'\bUPI\b', caseSensitive: false).hasMatch(t),
    international: international ||
        RegExp(r'\b(intl|international|foreign)\b', caseSensitive: false)
            .hasMatch(t),
    availableLimitPaise:
        limitMatch == null ? null : parseRupeesToPaise(limitMatch.group(1)!),
  );
}

String? _merchant(String t) {
  for (final m in _merchantAt.allMatches(t)) {
    final candidate = m.group(1)!.trim();
    final lower = candidate.toLowerCase();
    // Skip matches that are really the card or a date ("on 21-10-26").
    if (RegExp(r'^\d').hasMatch(candidate)) continue;
    if (lower.contains('card') || lower.startsWith('xx')) continue;
    if (lower.startsWith('your ') || lower == 'a/c') continue;
    return candidate.toUpperCase();
  }
  return null;
}

DateTime? _parseDate(String t) {
  final m = _date.firstMatch(t);
  if (m == null) return null;
  final day = int.parse(m.group(1)!);
  final rawMonth = m.group(2)!;
  final month = int.tryParse(rawMonth) ?? _months[rawMonth.toLowerCase()];
  var year = int.parse(m.group(3)!);
  if (year < 100) year += 2000;
  if (month == null || month < 1 || month > 12 || day < 1 || day > 31) {
    return null;
  }
  return DateTime(year, month, day);
}

/// Splits copied text that may hold several messages (multi-select copy).
/// Messages are separated by blank lines, or each starts on a new line.
List<String> splitMessages(String text) {
  final blocks = text
      .split(RegExp(r'\n\s*\n'))
      .map((b) => b.trim())
      .where((b) => b.isNotEmpty)
      .toList();
  if (blocks.length > 1) return blocks;
  // One block: treat each line containing an amount as its own message.
  final lines = text
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList();
  final withAmounts = lines.where((l) => _amount.hasMatch(l)).length;
  return withAmounts > 1 ? lines : [text.trim()];
}

/// Parses every spend in copied text, dropping duplicates within the batch.
List<ParsedSpend> parseMany(String text) {
  final seen = <String>{};
  final out = <ParsedSpend>[];
  for (final msg in splitMessages(text)) {
    final p = parseBankSms(msg);
    if (p == null) continue;
    final key = '${p.amountPaise}|${p.last4}|${p.merchant}|${p.date}';
    if (seen.add(key)) out.add(p);
  }
  return out;
}

/// True when two spends are likely the same transaction (same card and
/// amount, dates within a day).
bool isLikelyDuplicate(
  ParsedSpend a, {
  required int amountPaise,
  required String? last4,
  required DateTime date,
}) {
  if (a.amountPaise != amountPaise) return false;
  if (a.last4 != null && last4 != null && a.last4 != last4) return false;
  final d = a.date ?? date;
  return d.difference(date).inHours.abs() <= 24;
}
