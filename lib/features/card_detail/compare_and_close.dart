import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../domain/models.dart';
import '../../domain/money.dart';
import '../../domain/recommender.dart';
import '../../ui/widgets.dart';

/// Side-by-side: what each card returns per category, fees, forex, UPI.
class CompareScreen extends ConsumerStatefulWidget {
  const CompareScreen({super.key, required this.firstId});
  final String firstId;

  @override
  ConsumerState<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends ConsumerState<CompareScreen> {
  String? _secondId;

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(cardsWithBenefitsProvider);
    final a = cards.where((c) => c.card.id == widget.firstId).firstOrNull;
    final others = cards.where((c) => c.card.id != widget.firstId).toList();
    final b = others.where((c) => c.card.id == _secondId).firstOrNull ??
        others.firstOrNull;
    if (a == null) return Scaffold(appBar: AppBar());

    String rate(CardWithBenefits c, SpendCategory cat) {
      final r = recommend(
        Purchase(category: cat, amountPaise: 1000000),
        [c],
      ).single;
      return r.eligible ? formatBps(r.rateBps) : '—';
    }

    int forex(CardWithBenefits c) =>
        c.benefits
            .where((x) => x.kind == BenefitKind.forexMarkup)
            .firstOrNull
            ?.rateBps ??
        defaultForexMarkupBps;

    TableRow row(String label, String x, String y, {bool head = false}) =>
        TableRow(children: [
          for (final (i, t) in [label, x, y].indexed)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
              child: Text(t,
                  textAlign: i == 0 ? TextAlign.left : TextAlign.right,
                  style: TextStyle(
                      fontWeight: head || i > 0 ? FontWeight.w700 : null,
                      color: i == 0 ? AppColors.textTertiary : null)),
            ),
        ]);

    return Scaffold(
      appBar: AppBar(title: const Text('Compare cards')),
      body: others.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Add another card to compare.'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              children: [
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: b!.card.id,
                  decoration: const InputDecoration(labelText: 'Compare with'),
                  items: [
                    for (final c in others)
                      DropdownMenuItem(
                          value: c.card.id,
                          child: Text(c.card.displayName,
                              overflow: TextOverflow.ellipsis)),
                  ],
                  onChanged: (v) => setState(() => _secondId = v),
                ),
                const SizedBox(height: 16),
                Tile(
                  padding: const EdgeInsets.all(8),
                  child: Table(
                    columnWidths: const {0: FlexColumnWidth(1.3)},
                    children: [
                      row('', a.card.displayName, b.card.displayName, head: true),
                      row('Annual fee', formatInr(a.card.annualFeePaise),
                          formatInr(b.card.annualFeePaise)),
                      row('Forex markup', formatBps(forex(a)), formatBps(forex(b))),
                      row('Works on UPI', a.card.network.worksOnUpi ? 'Yes' : 'No',
                          b.card.network.worksOnUpi ? 'Yes' : 'No'),
                      for (final cat in SpendCategory.values)
                        if (cat != SpendCategory.foreign)
                          row(cat.label, rate(a, cat), rate(b, cat)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Caption(
                    'Reward rates per category from each card\'s benefits (sample rates until verified). Monthly caps not shown.'),
              ],
            ),
    );
  }
}

/// Checklist before closing a card (docs/06 Tier 3). Ticks are saved.
Future<void> showCloseChecklist(
    BuildContext context, WidgetRef ref, UserCard card) async {
  const items = [
    'Pay the full outstanding, including any EMIs',
    'Redeem or transfer your reward points',
    'Move subscriptions and standing instructions to another card',
    'Remove the card from shopping sites and UPI apps',
    'Ask the bank to close it and get a written confirmation',
    'Check your credit report a month later shows it closed',
  ];
  final db = ref.read(databaseProvider);
  final done = <int>{
    for (var i = 0; i < items.length; i++)
      if (await db.getValue('close:${card.id}:$i') == 'true') i,
  };
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceHigh,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, set) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('Closing ${card.displayName}?',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(8, 4, 8, 8),
                child: Caption(
                    'Closing an old card can lower your credit score a little (less total limit, shorter history). Usually worth it only if the fee outweighs what it earns.'),
              ),
              for (var i = 0; i < items.length; i++)
                CheckboxListTile(
                  value: done.contains(i),
                  title: Text(items[i]),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (v) async {
                    set(() => v == true ? done.add(i) : done.remove(i));
                    await db.setValue('close:${card.id}:$i', '${v == true}');
                  },
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
