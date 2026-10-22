import 'package:flutter/services.dart';

import '../domain/money.dart';

/// Groups rupee amounts the Indian way while typing: 150000 → 1,50,000.
/// Keeps up to two decimals and puts the cursor back after the same digit.
class IndianAmountFormatter extends TextInputFormatter {
  const IndianAmountFormatter({this.decimals = true});
  final bool decimals;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final raw = newValue.text;
    final cursor = newValue.selection.baseOffset.clamp(0, raw.length);
    final digitsBeforeCursor =
        raw.substring(0, cursor).replaceAll(RegExp(r'[^\d.]'), '').length;

    var clean = raw.replaceAll(RegExp(decimals ? r'[^\d.]' : r'[^\d]'), '');
    final dot = clean.indexOf('.');
    var whole = dot < 0 ? clean : clean.substring(0, dot);
    var fraction = dot < 0
        ? null
        : clean.substring(dot + 1).replaceAll('.', '');
    if (fraction != null && fraction.length > 2) {
      fraction = fraction.substring(0, 2);
    }
    whole = whole.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (whole.length > 13) return oldValue;

    final grouped = whole.isEmpty ? '' : groupIndian(int.parse(whole));
    final text = fraction == null ? grouped : '${grouped.isEmpty ? '0' : grouped}.$fraction';

    // Walk the new text until as many digits/dots as before the cursor.
    var seen = 0, offset = 0;
    while (offset < text.length && seen < digitsBeforeCursor) {
      if (text[offset] != ',') seen++;
      offset++;
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}

/// A paise amount as the text an [IndianAmountFormatter] field starts with.
String amountFieldText(int? paise) {
  if (paise == null) return '';
  final whole = groupIndian(paise ~/ 100);
  final p = paise % 100;
  return p == 0 ? whole : '$whole.${p.toString().padLeft(2, '0')}';
}
