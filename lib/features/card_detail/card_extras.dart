import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../domain/models.dart';
import '../../domain/money.dart';
import '../../domain/trackers.dart';
import '../../ui/widgets.dart';

/// Lounge tracker for a card: visits used this quarter and the spend that
/// unlocks next quarter's access.
class LoungeTile extends ConsumerWidget {
  const LoungeTile({super.key, required this.card});
  final UserCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rule = ref.watch(loungeRuleProvider(card.id)).value;
    final visits = ref.watch(loungeVisitsProvider(card.id)).value ?? const [];
    final spends = ref.watch(spendsProvider).value ?? const <Spend>[];
    final status =
        rule == null ? null : loungeStatus(rule, visits, spends, DateTime.now());
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Tile(
        onTap: () => _editRule(context, ref, rule),
        child: Row(children: [
          Icon(Icons.weekend_outlined,
              color: AppColors.onPrimaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: status == null
                ? const Text('Track airport lounge visits',
                    style: TextStyle(fontWeight: FontWeight.w700))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Lounge: ${status.used} of ${status.allowed} used this quarter',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      if (status.spendGatePaise != null)
                        Text(
                          status.toUnlockNextPaise == 0
                              ? 'Next quarter unlocked'
                              : 'Spend ${formatInr(status.toUnlockNextPaise)} more by ${DateFormat('d MMM').format(status.quarterEnd.subtract(const Duration(days: 1)))} to unlock next quarter',
                          style: TextStyle(
                              fontSize: 12,
                              color: status.toUnlockNextPaise == 0
                                  ? AppColors.earned
                                  : AppColors.attention),
                        ),
                    ],
                  ),
          ),
          if (status != null)
            TextButton(
              onPressed: () => ref.read(databaseProvider).logLoungeVisit(
                  const Uuid().v4(), card.id, DateTime.now()),
              child: const Text('Log visit'),
            ),
        ]),
      ),
    );
  }

  Future<void> _editRule(
      BuildContext context, WidgetRef ref, LoungeRule? rule) async {
    final visits =
        TextEditingController(text: '${rule?.visitsPerQuarter ?? 2}');
    final gate = TextEditingController(
        text: rule?.spendGatePaise == null
            ? ''
            : '${rule!.spendGatePaise! ~/ 100}');
    final result = await showModalBottomSheet<String>(
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
            const Text('Lounge access',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Caption(
                "Copy these from your card's terms. Many cards need a minimum spend in one quarter to unlock lounges in the next."),
            const SizedBox(height: 16),
            TextField(
              controller: visits,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration:
                  const InputDecoration(labelText: 'Free visits per quarter'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: gate,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Spend needed per quarter (optional)',
                  prefixText: '₹ '),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, 'save'),
              child: const Text('Save'),
            ),
            if (rule != null)
              TextButton(
                onPressed: () => Navigator.pop(ctx, 'delete'),
                child: const Text('Stop tracking lounges'),
              ),
          ],
        ),
      ),
    );
    final db = ref.read(databaseProvider);
    if (result == 'delete') return db.saveLoungeRule(null, card.id);
    if (result != 'save') return;
    final n = int.tryParse(visits.text);
    if (n == null) return;
    await db.saveLoungeRule(
      LoungeRule(
        cardId: card.id,
        visitsPerQuarter: n,
        spendGatePaise:
            gate.text.trim().isEmpty ? null : parseRupeesToPaise(gate.text),
      ),
      card.id,
    );
  }
}

/// EMIs running on a card: months left and roughly how much limit they
/// still hold.
class EmiSection extends ConsumerWidget {
  const EmiSection({super.key, required this.card});
  final UserCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final emis = (ref.watch(emisProvider).value ?? const <Emi>[])
        .where((e) => e.cardId == card.id && e.isActive(now))
        .toList();
    final blocked = emis.fold<int>(0, (a, e) => a + e.remainingPaise(now));
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitle('EMIs',
              trailing: TextButton(
                onPressed: () => editEmi(context, ref, card, null),
                child: const Text('Add'),
              )),
          if (emis.isEmpty)
            const Caption('No EMIs on this card.')
          else ...[
            Tile(
              padding: EdgeInsets.zero,
              child: Column(children: [
                for (final e in emis)
                  ListTile(
                    title: Text(e.title,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        '${formatInr(e.monthlyPaise)}/month · ${e.monthsLeft(now)} of ${e.totalMonths} left'),
                    trailing: Text(formatInr(e.remainingPaise(now)),
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    onTap: () => editEmi(context, ref, card, e),
                  ),
              ]),
            ),
            const SizedBox(height: 6),
            Caption(
                'About ${formatInr(blocked)} of your ${formatInr(card.creditLimitPaise)} limit is held by EMIs (banks hold the remaining principal, a bit less than this).'),
          ],
        ],
      ),
    );
  }
}

Future<void> editEmi(
    BuildContext context, WidgetRef ref, UserCard card, Emi? existing) async {
  final title = TextEditingController(text: existing?.title ?? '');
  final monthly = TextEditingController(
      text: existing == null ? '' : '${existing.monthlyPaise ~/ 100}');
  final months =
      TextEditingController(text: '${existing?.totalMonths ?? 12}');
  var first = existing?.firstMonth ??
      DateTime(DateTime.now().year, DateTime.now().month, 1);
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
            const Text('EMI',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            TextField(
              controller: title,
              decoration: const InputDecoration(
                  labelText: 'What for', hintText: 'Phone, laptop…'),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: monthly,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Monthly', prefixText: '₹ '),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 110,
                child: TextField(
                  controller: months,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Months'),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.event_outlined),
              label: Text('First instalment: ${DateFormat('MMM yyyy').format(first)}'),
              onPressed: () async {
                final d = await showDatePicker(
                  context: ctx,
                  initialDate: first,
                  firstDate: DateTime(2018),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (d != null) set(() => first = DateTime(d.year, d.month, 1));
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, 'save'),
              child: const Text('Save'),
            ),
            if (existing != null)
              TextButton(
                onPressed: () => Navigator.pop(ctx, 'delete'),
                child: const Text('Delete EMI'),
              ),
          ],
        ),
      ),
    ),
  );
  final db = ref.read(databaseProvider);
  if (result == 'delete' && existing != null) return db.deleteEmi(existing.id);
  if (result != 'save') return;
  final m = parseRupeesToPaise(monthly.text);
  final n = int.tryParse(months.text);
  if (title.text.trim().isEmpty || m == null || n == null || n < 1) return;
  await db.saveEmi(Emi(
    id: existing?.id ?? const Uuid().v4(),
    cardId: card.id,
    title: title.text.trim(),
    monthlyPaise: m,
    totalMonths: n,
    firstMonth: first,
  ));
}
