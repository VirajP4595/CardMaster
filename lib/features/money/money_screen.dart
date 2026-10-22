import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../domain/models.dart';
import '../../domain/money.dart';
import '../../ui/widgets.dart';
import 'money_logic.dart';

/// Money tab (was Activity), card-first: every expense, plus what a card
/// would have earned, and monthly budgets (docs/09).
class MoneyScreen extends ConsumerStatefulWidget {
  const MoneyScreen({super.key});

  @override
  ConsumerState<MoneyScreen> createState() => _MoneyScreenState();
}

class _MoneyScreenState extends ConsumerState<MoneyScreen> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(spendsProvider).value ?? const <Spend>[];
    final cards = ref.watch(cardsWithBenefitsProvider);
    final next = DateTime(_month.year, _month.month + 1);
    final spends = all
        .where((s) => !s.spentOn.isBefore(_month) && s.spentOn.isBefore(next))
        .toList();
    final earned = earnedBySpend(spends, cards);
    final total = spends.fold<int>(0, (a, s) => a + s.amountPaise);
    final rewards = earned.values.fold<int>(0, (a, v) => a + v);
    final hintsOn = settingOn(ref, SettingKeys.rewardHints);

    var missedTotal = 0;
    var nonCardTotal = 0;
    for (final s in spends) {
      if (s.paymentKind == PaymentKind.card) continue;
      final m = missedReward(s, cards);
      if (m != null) {
        missedTotal += m.netPaise;
        nonCardTotal += s.amountPaise;
      }
    }

    final byCategory = <SpendCategory, int>{};
    for (final s in spends) {
      byCategory[s.category] = (byCategory[s.category] ?? 0) + s.amountPaise;
    }
    final budgets = ref.watch(budgetsProvider).value ?? const {};
    // (category, spent, budget): budgeted categories first, then the
    // biggest other categories.
    final rows = <(SpendCategory, int, int?)>[
      for (final e in budgets.entries) (e.key, byCategory[e.key] ?? 0, e.value),
      ...(byCategory.entries
              .where((e) => !budgets.containsKey(e.key))
              .toList()
            ..sort((a, b) => b.value.compareTo(a.value)))
          .take(6)
          .map((e) => (e.key, e.value, null)),
    ];
    final maxCategory = byCategory.values.fold<int>(1, (a, v) => v > a ? v : a);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/quick-add'),
        icon: const Icon(Icons.add),
        label: const Text('Add expense'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
          children: [
            Row(children: [
              const Expanded(
                child: Text('Money',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              ),
              IconButton.filledTonal(
                tooltip: 'Previous month',
                onPressed: () => setState(
                    () => _month = DateTime(_month.year, _month.month - 1)),
                icon: const Icon(Icons.chevron_left),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(DateFormat('MMM yyyy').format(_month),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              IconButton.filledTonal(
                tooltip: 'Next month',
                onPressed: next.isAfter(DateTime.now())
                    ? null
                    : () => setState(() => _month = next),
                icon: const Icon(Icons.chevron_right),
              ),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: Tile(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Caption('Spent'),
                      Text(formatInr(total),
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w800)),
                      const Caption('cards, UPI & cash'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Tile(
                  color: AppColors.earnedContainer,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Caption('Rewards earned'),
                      Text(formatInr(rewards),
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.earned)),
                      const Caption('estimated from card benefits'),
                    ],
                  ),
                ),
              ),
            ]),
            if (hintsOn && missedTotal > 0) ...[
              const SizedBox(height: 10),
              Tile(
                color: AppColors.primaryContainerLow,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline,
                        color: AppColors.onPrimaryContainer),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${formatInr(nonCardTotal)} went via UPI and cash. Paid with your best cards, it would have earned ${formatInr(missedTotal)}. Payments to people and rent aren\'t counted.',
                        style: const TextStyle(color: Color(0xFFD4CCFF)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            SectionTitle('Budgets this month',
                trailing: TextButton(
                  onPressed: () => _editBudget(context, null, budgets),
                  child: const Text('Set a budget'),
                )),
            if (rows.isEmpty)
              const Caption('Set a monthly budget for a category, or add expenses to see where money goes.')
            else
              Tile(
                child: Column(children: [
                  for (final r in rows)
                    InkWell(
                      onTap: () => _editBudget(context, r.$1, budgets),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(children: [
                          Row(children: [
                            Expanded(child: Text(r.$1.label)),
                            Text(formatInr(r.$2),
                                style: TextStyle(
                                    color: r.$3 != null && r.$2 > r.$3!
                                        ? AppColors.dangerText
                                        : null)),
                            if (r.$3 != null)
                              Text(
                                  ' / ${formatInr(r.$3!)}${r.$2 > r.$3! ? ' · over' : ''}',
                                  style: const TextStyle(
                                      color: AppColors.textSecondary)),
                          ]),
                          const SizedBox(height: 5),
                          Bar(
                            value: r.$3 == null
                                ? r.$2 / maxCategory
                                : r.$2 / r.$3!,
                            color: r.$3 == null
                                ? AppColors.primary
                                : r.$2 > r.$3!
                                    ? AppColors.danger
                                    : r.$2 >= r.$3! * 0.85
                                        ? AppColors.attention
                                        : AppColors.earned,
                          ),
                        ]),
                      ),
                    ),
                ]),
              ),
            const SizedBox(height: 18),
            SectionTitle('Expenses',
                trailing: TextButton(
                  onPressed: () => _pasteMessages(context),
                  child: const Text('Paste bank messages'),
                )),
            if (spends.isEmpty)
              const Caption(
                  'Nothing logged this month. Add an expense, or share a bank SMS to Card Master.')
            else
              for (final s in spends)
                _SpendRow(
                  spend: s,
                  earned: earned[s.id],
                  missed: hintsOn ? missedReward(s, cards)?.netPaise : null,
                ),
          ],
        ),
      ),
    );
  }

  Future<void> _editBudget(BuildContext context, SpendCategory? category,
      Map<SpendCategory, int> budgets) async {
    var picked = category ?? SpendCategory.foodDelivery;
    final amount = TextEditingController(
        text: budgets[picked] == null ? '' : '${budgets[picked]! ~/ 100}');
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceHigh,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Monthly budget',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              DropdownButtonFormField<SpendCategory>(
                initialValue: picked,
                decoration: const InputDecoration(labelText: 'Category'),
                items: [
                  for (final c in SpendCategory.values)
                    DropdownMenuItem(value: c, child: Text(c.label)),
                ],
                onChanged: category != null
                    ? null
                    : (c) => set(() {
                          picked = c!;
                          amount.text = budgets[picked] == null
                              ? ''
                              : '${budgets[picked]! ~/ 100}';
                        }),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Budget per month', prefixText: '₹ '),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, 'save'),
                child: const Text('Save'),
              ),
              if (budgets.containsKey(picked))
                TextButton(
                  onPressed: () => Navigator.pop(ctx, 'remove'),
                  child: const Text('Remove budget'),
                ),
            ],
          ),
        ),
      ),
    );
    if (result == null) return;
    await ref.read(databaseProvider).setBudget(
        picked, result == 'remove' ? null : parseRupeesToPaise(amount.text));
  }

  Future<void> _pasteMessages(BuildContext context) async {
    final controller = TextEditingController();
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceHigh,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Paste bank messages',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Caption(
                'In your messages app, select bank messages, Copy, and paste here. Read on this phone; the text isn\'t saved.'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 8,
              decoration: const InputDecoration(hintText: 'Paste here'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Find expenses'),
            ),
          ],
        ),
      ),
    );
    if (text != null && text.trim().isNotEmpty && context.mounted) {
      context.push('/import', extra: text);
    }
  }
}

class _SpendRow extends ConsumerWidget {
  const _SpendRow({required this.spend, this.earned, this.missed});
  final Spend spend;
  final int? earned;
  final int? missed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = spend;
    final card =
        s.userCardId == null ? null : ref.watch(cardProvider(s.userCardId!));
    final method = switch (s.paymentKind) {
      PaymentKind.card => card?.displayName ?? 'Card',
      PaymentKind.bankUpi => 'UPI · bank',
      PaymentKind.cash => 'Cash',
    };
    final stripe = card != null
        ? Color(card.faceColor)
        : s.paymentKind == PaymentKind.cash
            ? AppColors.earnedBorder
            : const Color(0xFF3A3E52);
    return Dismissible(
      key: ValueKey(s.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: AppColors.dangerContainer,
        child: const Icon(Icons.delete_outline, color: AppColors.dangerText),
      ),
      onDismissed: (_) => ref.read(databaseProvider).deleteSpend(s.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Container(
            width: 6,
            height: 38,
            decoration: BoxDecoration(
                color: stripe, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.note ?? s.category.label,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Caption(
                    '$method · ${DateFormat('d MMM').format(s.spentOn)}${s.viaUpi && s.paymentKind == PaymentKind.card ? ' · UPI' : ''}'),
              ],
            ),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(formatInr(s.amountPaise),
                style: const TextStyle(fontWeight: FontWeight.w700)),
            if (earned != null && earned! > 0)
              Text('+${formatInr(earned!)}',
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.earned))
            else if (missed != null)
              Text('card: +${formatInr(missed!)}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.attention)),
          ]),
        ]),
      ),
    );
  }
}
