import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/money.dart';
import '../../ui/amount_input.dart';

/// Editable card details (Add card step 3, and Edit card).
class CardFormValues {
  CardFormValues({
    this.nickname = '',
    this.last4 = '',
    this.limitRupees = '',
    this.statementDay = '',
    this.dueDay = '',
    this.annualFeeRupees = '',
    this.waiverRupees = '',
    this.anniversaryMonth,
  });

  String nickname;
  String last4;
  String limitRupees;
  String statementDay;
  String dueDay;
  String annualFeeRupees;
  String waiverRupees;
  int? anniversaryMonth;

  int? get statement => _day(statementDay);
  int? get due => _day(dueDay);
  int? get limitPaise => parseRupeesToPaise(limitRupees);
  int get feePaise => parseRupeesToPaise(annualFeeRupees) ?? 0;
  int? get waiverPaise =>
      waiverRupees.trim().isEmpty ? null : parseRupeesToPaise(waiverRupees);

  bool get valid =>
      (limitPaise ?? 0) > 0 &&
      statement != null &&
      due != null &&
      (last4.isEmpty || RegExp(r'^\d{4}$').hasMatch(last4));

  static int? _day(String s) {
    final v = int.tryParse(s.trim());
    return v != null && v >= 1 && v <= 31 ? v : null;
  }
}

class CardForm extends StatefulWidget {
  const CardForm({super.key, required this.values, required this.onChanged});
  final CardFormValues values;
  final VoidCallback onChanged;

  @override
  State<CardForm> createState() => _CardFormState();
}

class _CardFormState extends State<CardForm> {
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final v = widget.values;
    Widget field(
      String label,
      String initial,
      void Function(String) set, {
      String? hint,
      String? helper,
      bool digits = false,
      bool amount = false,
      int? maxLength,
      String? prefix,
    }) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            initialValue: initial,
            keyboardType: digits || amount ? TextInputType.number : TextInputType.text,
            inputFormatters: [
              if (amount)
                const IndianAmountFormatter()
              else if (digits)
                FilteringTextInputFormatter.digitsOnly,
              if (maxLength != null)
                LengthLimitingTextInputFormatter(maxLength),
            ],
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              helperText: helper,
              prefixText: prefix,
            ),
            onChanged: (s) {
              set(s);
              widget.onChanged();
            },
          ),
        );

    return Column(children: [
      field('Nickname (optional)', v.nickname, (s) => v.nickname = s,
          hint: 'e.g. Travel card'),
      field('Last 4 digits (optional)', v.last4, (s) => v.last4 = s,
          digits: true,
          maxLength: 4,
          helper: 'Used to match bank SMS. Never the full number.'),
      field('Credit limit', v.limitRupees, (s) => v.limitRupees = s,
          amount: true, prefix: '₹ '),
      Row(children: [
        Expanded(
          child: field('Statement day', v.statementDay,
              (s) => v.statementDay = s,
              digits: true, maxLength: 2, hint: '1–31'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: field('Due day', v.dueDay, (s) => v.dueDay = s,
              digits: true, maxLength: 2, hint: '1–31'),
        ),
      ]),
      Row(children: [
        Expanded(
          child: field('Annual fee', v.annualFeeRupees,
              (s) => v.annualFeeRupees = s,
              amount: true, prefix: '₹ '),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: field('Fee waived at', v.waiverRupees,
              (s) => v.waiverRupees = s,
              amount: true, prefix: '₹ ', hint: 'yearly spend'),
        ),
      ]),
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField<int>(
          isExpanded: true,
          initialValue: v.anniversaryMonth,
          decoration:
              const InputDecoration(labelText: 'Card anniversary month'),
          items: [
            for (var m = 1; m <= 12; m++)
              DropdownMenuItem(value: m, child: Text(_months[m - 1])),
          ],
          onChanged: (m) {
            v.anniversaryMonth = m;
            widget.onChanged();
          },
        ),
      ),
    ]);
  }
}
