import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../domain/models.dart';
import '../../domain/money.dart';
import '../../domain/recurring.dart';
import '../../ui/widgets.dart';

/// Recurring expenses on the Money tab (docs/09 §4): rent, subscriptions,
/// EMIs. Auto rules add themselves on app open; others ask here.
class RecurringSection extends ConsumerWidget {
  const RecurringSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rules = ref.watch(recurringProvider).value ?? const <RecurringRule>[];
    final pending = dueOccurrences(
        rules.where((r) => !r.autoAdd).toList(), DateTime.now());
    final db = ref.watch(databaseProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 18),
        SectionTitle('Recurring',
            trailing: TextButton(
              onPressed: () => editRecurring(context, ref, null),
              child: const Text('Add'),
            )),
        for (final (rule, date) in pending)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Tile(
              color: AppColors.attentionContainer,
              child: Row(children: [
                Expanded(
                  child: Text(
                      '${rule.title} ${formatInr(rule.amountPaise)} was due on ${date.day}/${date.month}. Add it?',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                TextButton(
                  onPressed: () => db.skipOccurrence(rule, date),
                  child: const Text('Skip'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
                  onPressed: () => db.addOccurrence(rule, date),
                  child: const Text('Add'),
                ),
              ]),
            ),
          ),
        if (rules.isEmpty)
          const Caption(
              'Rent, subscriptions, EMIs: add them once and they\'re logged every month.')
        else
          Tile(
            padding: EdgeInsets.zero,
            child: Column(children: [
              for (final r in rules)
                ListTile(
                  title: Text(r.title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                      'Every month on the ${r.dayOfMonth}${_suffix(r.dayOfMonth)} · ${r.autoAdd ? 'added automatically' : 'asks first'}'),
                  trailing: Text(formatInr(r.amountPaise),
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  onTap: () => editRecurring(context, ref, r),
                ),
            ]),
          ),
      ],
    );
  }

  static String _suffix(int d) {
    if (d >= 11 && d <= 13) return 'th';
    return switch (d % 10) { 1 => 'st', 2 => 'nd', 3 => 'rd', _ => 'th' };
  }
}

Future<void> editRecurring(
    BuildContext context, WidgetRef ref, RecurringRule? existing) async {
  final title = TextEditingController(text: existing?.title ?? '');
  final amount = TextEditingController(
      text: existing == null ? '' : '${existing.amountPaise ~/ 100}');
  final day = TextEditingController(text: '${existing?.dayOfMonth ?? 1}');
  var category = existing?.category ?? SpendCategory.rent;
  var auto = existing?.autoAdd ?? true;
  final cards = ref.read(cardsProvider).value ?? const <UserCard>[];
  var method = existing?.userCardId ??
      (existing?.paymentKind == PaymentKind.cash ? 'cash' : 'upi');

  final result = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceHigh,
    builder: (ctx) => StatefulBuilder(builder: (ctx, set) {
      final d = int.tryParse(day.text);
      final valid = title.text.trim().isNotEmpty &&
          (parseRupeesToPaise(amount.text) ?? 0) > 0 &&
          d != null &&
          d >= 1 &&
          d <= 31;
      return Padding(
        padding: EdgeInsets.fromLTRB(
            24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(existing == null ? 'Recurring expense' : 'Edit recurring',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              TextField(
                controller: title,
                decoration: const InputDecoration(
                    labelText: 'Name', hintText: 'Rent, Netflix, phone EMI…'),
                onChanged: (_) => set(() {}),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: amount,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Amount', prefixText: '₹ '),
                    onChanged: (_) => set(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 110,
                  child: TextField(
                    controller: day,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    decoration:
                        const InputDecoration(labelText: 'Day of month'),
                    onChanged: (_) => set(() {}),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              DropdownButtonFormField<SpendCategory>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: [
                  for (final c in SpendCategory.values)
                    DropdownMenuItem(value: c, child: Text(c.label)),
                ],
                onChanged: (c) => set(() => category = c!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: method,
                decoration: const InputDecoration(labelText: 'Paid with'),
                items: [
                  for (final c in cards)
                    DropdownMenuItem(value: c.id, child: Text(c.displayName)),
                  const DropdownMenuItem(value: 'upi', child: Text('UPI · bank')),
                  const DropdownMenuItem(value: 'cash', child: Text('Cash')),
                ],
                onChanged: (v) => set(() => method = v!),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Add automatically'),
                subtitle: const Text('Off: Money asks you each month'),
                value: auto,
                onChanged: (v) => set(() => auto = v),
              ),
              FilledButton(
                onPressed: valid ? () => Navigator.pop(ctx, 'save') : null,
                child: const Text('Save'),
              ),
              if (existing != null)
                TextButton(
                  onPressed: () => Navigator.pop(ctx, 'delete'),
                  child: const Text('Delete (keeps past expenses)'),
                ),
            ],
          ),
        ),
      );
    }),
  );
  final db = ref.read(databaseProvider);
  if (result == 'delete' && existing != null) {
    await db.deleteRecurring(existing.id);
    return;
  }
  if (result != 'save') return;
  final isCard = method != 'upi' && method != 'cash';
  final dayOfMonth = int.parse(day.text);
  final now = DateTime.now();
  await db.saveRecurring(RecurringRule(
    id: existing?.id ?? const Uuid().v4(),
    title: title.text.trim(),
    amountPaise: parseRupeesToPaise(amount.text)!,
    category: category,
    paymentKind: isCard
        ? PaymentKind.card
        : method == 'cash'
            ? PaymentKind.cash
            : PaymentKind.bankUpi,
    userCardId: isCard ? method : null,
    dayOfMonth: dayOfMonth,
    autoAdd: auto,
    // A new rule whose day already passed this month starts next month,
    // so it doesn't add an expense the user may have logged already.
    lastAddedMonth: existing?.lastAddedMonth ??
        (dayOfMonth <= now.day ? monthKey(now) : null),
  ));
}
