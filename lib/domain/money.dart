/// Money is always stored as integer paise (1 rupee = 100 paise) to avoid
/// floating-point rounding. Rates are stored in basis points (1% = 100 bps).
library;

/// Applies a rate in basis points to an amount in paise, rounding down.
int applyBps(int amountPaise, int bps) => amountPaise * bps ~/ 10000;

/// Converts whole rupees to paise.
int rupees(num value) => (value * 100).round();

/// Formats paise as Indian rupees with Indian digit grouping,
/// e.g. 12345600 -> "₹1,23,456". Paise are dropped unless [showPaise].
String formatInr(int paise, {bool showPaise = false, bool symbol = true}) {
  final negative = paise < 0;
  final abs = paise.abs();
  final rupeesPart = abs ~/ 100;
  final paisePart = abs % 100;
  final grouped = groupIndian(rupeesPart);
  final decimals =
      showPaise ? '.${paisePart.toString().padLeft(2, '0')}' : '';
  return '${negative ? '−' : ''}${symbol ? '₹' : ''}$grouped$decimals';
}

/// Groups an integer the Indian way: last three digits, then pairs.
/// 123456789 -> "12,34,56,789".
String groupIndian(int value) {
  final s = value.toString();
  if (s.length <= 3) return s;
  final last3 = s.substring(s.length - 3);
  var rest = s.substring(0, s.length - 3);
  final parts = <String>[];
  while (rest.length > 2) {
    parts.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) parts.insert(0, rest);
  return '${parts.join(',')},$last3';
}

/// Parses "1,23,456.50" or "2400" (rupees) into paise. Returns null if invalid.
int? parseRupeesToPaise(String input) {
  final cleaned = input.replaceAll(',', '').trim();
  if (cleaned.isEmpty) return null;
  final value = double.tryParse(cleaned);
  if (value == null || value < 0) return null;
  return (value * 100).round();
}

/// Formats basis points as a percentage, e.g. 250 -> "2.5%", 1000 -> "10%".
String formatBps(int bps) {
  final pct = bps / 100;
  final text = pct == pct.roundToDouble()
      ? pct.toStringAsFixed(0)
      : pct.toStringAsFixed(pct * 10 == (pct * 10).roundToDouble() ? 1 : 2);
  return '$text%';
}
