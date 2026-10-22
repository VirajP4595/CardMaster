import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../app/intake.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../domain/models.dart';
import '../../domain/money.dart';
import '../../domain/recommender.dart';

/// One-screen expense entry with a keypad (design board 11, docs/09 §2).
class QuickAddScreen extends ConsumerStatefulWidget {
  const QuickAddScreen({super.key, this.prefill});
  final QuickAddPrefill? prefill;

  @override
  ConsumerState<QuickAddScreen> createState() => _QuickAddScreenState();
}

/// Selected payment method: a card id, or bank UPI / cash.
sealed class _Method {
  const _Method();
}

class _CardMethod extends _Method {
  const _CardMethod(this.cardId);
  final String cardId;
  @override
  bool operator ==(Object o) => o is _CardMethod && o.cardId == cardId;
  @override
  int get hashCode => cardId.hashCode;
}

class _OtherMethod extends _Method {
  const _OtherMethod(this.kind);
  final PaymentKind kind;
  @override
  bool operator ==(Object o) => o is _OtherMethod && o.kind == kind;
  @override
  int get hashCode => kind.hashCode;
}

class _QuickAddScreenState extends ConsumerState<QuickAddScreen> {
  String _digits = '';
  SpendCategory _category = SpendCategory.foodDelivery;
  _Method? _method;
  bool _methodTouched = false;
  bool _toPerson = false;
  DateTime _date = DateTime.now();
  final _note = TextEditingController();
  bool _saved = false;

  static const _categories = [
    SpendCategory.foodDelivery,
    SpendCategory.groceries,
    SpendCategory.utilities,
    SpendCategory.shopping,
    SpendCategory.dining,
    SpendCategory.fuel,
    SpendCategory.travel,
    SpendCategory.telecom,
    SpendCategory.rent,
    SpendCategory.insurance,
    SpendCategory.foreign,
    SpendCategory.other,
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.prefill;
    if (p != null) {
      if (p.amountPaise != null) _digits = '${p.amountPaise! ~/ 100}';
      if (p.category != null) _category = p.category!;
      if (p.international) _category = SpendCategory.foreign;
      if (p.cardId != null) {
        _method = _CardMethod(p.cardId!);
        _methodTouched = true;
      }
      if (p.date != null) _date = p.date!;
      _note.text = p.merchant ?? '';
    }
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  int get _amount => int.tryParse(_digits.isEmpty ? '0' : _digits)! * 100;

  void _press(String d) => setState(() {
        _saved = false;
        if (d == '⌫') {
          if (_digits.isNotEmpty) {
            _digits = _digits.substring(0, _digits.length - 1);
          }
        } else if (_digits.length < 8) {
          _digits = (_digits + d).replaceFirst(RegExp(r'^0+'), '');
        }
      });

  Future<void> _save() async {
    final m = _method!;
    final db = ref.read(databaseProvider);
    final note = _note.text.trim();
    final card = m is _CardMethod ? ref.read(cardProvider(m.cardId)) : null;
    await db.addSpend(
      Spend(
        id: const Uuid().v4(),
        amountPaise: _amount,
        category: _category,
        paymentKind: m is _OtherMethod ? m.kind : PaymentKind.card,
        userCardId: m is _CardMethod ? m.cardId : null,
        viaUpi: m is _OtherMethod && m.kind == PaymentKind.bankUpi ||
            (widget.prefill?.viaUpi ?? false) && card != null,
        international: _category == SpendCategory.foreign ||
            (widget.prefill?.international ?? false),
        payee: _toPerson ? PayeeType.person : PayeeType.merchant,
        note: note.isEmpty ? null : note,
        spentOn: _date,
      ),
      merchant: note.isEmpty ? null : note.toUpperCase(),
      source: widget.prefill?.source ?? 'MANUAL',
    );
    if (note.isNotEmpty) await db.remember(note, _category);
    if (widget.prefill != null) {
      if (mounted) context.pop();
      return;
    }
    setState(() => _saved = true);
  }

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(cardsWithBenefitsProvider);
    final ranked = recommend(
      Purchase(category: _category, amountPaise: _amount),
      cards,
    );
    final best = ranked.where((r) => r.eligible).firstOrNull;
    // Until the user picks a method, follow the best card for the current
    // amount and category.
    if (!_methodTouched) {
      _method = best != null && best.netPaise > 0
          ? _CardMethod(best.card.id)
          : (_method ?? const _OtherMethod(PaymentKind.bankUpi));
    }
    final canSave = _amount > 0 && _method != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add expense'),
        actions: [
          TextButton.icon(
            onPressed: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (d != null) setState(() => _date = d);
            },
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            label: Text(_isToday(_date)
                ? 'Today'
                : DateFormat('d MMM').format(_date)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              children: [
                Center(
                  child: Text(formatInr(_amount),
                      style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1)),
                ),
                TextField(
                  controller: _note,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    hintText: 'Add a note (Swiggy, rent…)',
                    filled: false,
                    border: InputBorder.none,
                  ),
                  onChanged: (s) async {
                    final c = await ref
                        .read(databaseProvider)
                        .categoryFor(s.trim());
                    if (c != null && mounted) setState(() => _category = c);
                  },
                ),
                const _Label('Category'),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  for (final c in _categories)
                    ChoiceChip(
                      label: Text(c.label),
                      selected: c == _category,
                      onSelected: (_) => setState(() {
                        _category = c;
                        _saved = false;
                      }),
                    ),
                ]),
                const _Label('Paid with'),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  for (final c in cards)
                    ChoiceChip(
                      avatar: Container(
                        width: 20,
                        height: 13,
                        decoration: BoxDecoration(
                          color: Color(c.card.faceColor),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      label: Text(c.card.displayName),
                      selected: _method == _CardMethod(c.card.id),
                      onSelected: (_) => setState(() {
                        _method = _CardMethod(c.card.id);
                        _methodTouched = true;
                      }),
                    ),
                  for (final k in [PaymentKind.bankUpi, PaymentKind.cash])
                    ChoiceChip(
                      label: Text(k == PaymentKind.cash ? 'Cash' : 'UPI · bank'),
                      selected: _method == _OtherMethod(k),
                      onSelected: (_) => setState(() {
                        _method = _OtherMethod(k);
                        _methodTouched = true;
                      }),
                    ),
                ]),
                if (_method is _OtherMethod)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Paid a person, not a shop'),
                    value: _toPerson,
                    onChanged: (v) => setState(() => _toPerson = v),
                  ),
                const SizedBox(height: 8),
                if (settingOn(ref, SettingKeys.rewardHints))
                  _Hint(
                    method: _method,
                    ranked: ranked,
                    amount: _amount,
                    toPerson: _toPerson,
                    category: _category,
                  ),
              ],
            ),
          ),
          _Keypad(onPress: _press),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: FilledButton(
              onPressed: _saved
                  ? () => setState(() {
                        _digits = '';
                        _note.clear();
                        _saved = false;
                      })
                  : canSave
                      ? _save
                      : null,
              child: Text(_saved
                  ? 'Saved ✓  Add another'
                  : 'Save ${formatInr(_amount)}'),
            ),
          ),
        ]),
      ),
    );
  }

  static bool _isToday(DateTime d) {
    final n = DateTime.now();
    return d.year == n.year && d.month == n.month && d.day == n.day;
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 8),
        child: Text(text.toUpperCase(),
            style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                letterSpacing: 1)),
      );
}

/// Live reward hint (docs/09 §7): honest, never "spend more".
class _Hint extends StatelessWidget {
  const _Hint({
    required this.method,
    required this.ranked,
    required this.amount,
    required this.toPerson,
    required this.category,
  });

  final _Method? method;
  final List<Recommendation> ranked;
  final int amount;
  final bool toPerson;
  final SpendCategory category;

  @override
  Widget build(BuildContext context) {
    if (amount == 0 || ranked.isEmpty) return const SizedBox.shrink();
    final best = ranked.where((r) => r.eligible).firstOrNull;
    final m = method;
    String? text;
    var good = false;
    if (m is _CardMethod) {
      final chosen = ranked.where((r) => r.card.id == m.cardId).firstOrNull;
      if (chosen == null) return const SizedBox.shrink();
      if (best == null || chosen.card.id == best.card.id) {
        text = chosen.netPaise > 0
            ? 'Best choice: earns ${formatInr(chosen.netPaise)} (${formatBps(chosen.rateBps)})'
            : 'None of your cards earn on ${category.label.toLowerCase()}';
        good = true;
      } else {
        text =
            'Earns ${formatInr(chosen.netPaise)}. ${best.card.displayName} would earn ${formatInr(best.netPaise)}';
      }
    } else if (!toPerson &&
        category != SpendCategory.rent &&
        best != null &&
        best.netPaise > 0) {
      text =
          'Paying with ${best.card.displayName} would earn ${formatInr(best.netPaise)}';
    }
    if (text == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: good ? AppColors.earnedContainer : AppColors.attentionContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: good ? AppColors.earned : AppColors.attention)),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onPress});
  final void Function(String) onPress;

  @override
  Widget build(BuildContext context) {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '00', '0', '⌫'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.6,
        children: [
          for (final k in keys)
            Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => onPress(k),
                child: Center(
                  child: k == '⌫'
                      ? const Icon(Icons.backspace_outlined,
                          semanticLabel: 'Delete digit')
                      : Text(k,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
