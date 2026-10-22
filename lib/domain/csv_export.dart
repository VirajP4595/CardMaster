import 'models.dart';

/// Expenses as CSV (RFC 4180 quoting), for the user's own spreadsheet.
/// Amounts in rupees with two decimals; dates as YYYY-MM-DD.
String spendsToCsv(List<Spend> spends, Map<String, String> cardNames) {
  final b = StringBuffer(
      'date,amount_inr,category,paid_with,card,upi,international,note\r\n');
  final sorted = [...spends]..sort((a, c) => a.spentOn.compareTo(c.spentOn));
  for (final s in sorted) {
    final d = s.spentOn;
    final date = '${d.year}-${_pad2(d.month)}-${_pad2(d.day)}';
    final amount =
        '${s.amountPaise ~/ 100}.${_pad2(s.amountPaise.remainder(100).abs())}';
    final method = switch (s.paymentKind) {
      PaymentKind.card => 'card',
      PaymentKind.bankUpi => 'upi_bank',
      PaymentKind.cash => 'cash',
    };
    b
      ..write([
        date,
        amount,
        s.category.label,
        method,
        s.userCardId == null ? '' : cardNames[s.userCardId] ?? '',
        s.viaUpi ? 'yes' : 'no',
        s.international ? 'yes' : 'no',
        s.note ?? '',
      ].map(_cell).join(','))
      ..write('\r\n');
  }
  return b.toString();
}

String _pad2(int n) => n.toString().padLeft(2, '0');

String _cell(String v) {
  // Guard against spreadsheet formula injection, then quote if needed.
  var s = v;
  if (s.isNotEmpty && '=+-@'.contains(s[0]) && double.tryParse(s) == null) {
    s = "'$s";
  }
  if (s.contains(RegExp(r'[",\r\n]'))) return '"${s.replaceAll('"', '""')}"';
  return s;
}
