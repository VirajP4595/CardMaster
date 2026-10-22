import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/catalog/catalog.dart';
import '../../data/db/database.dart';
import '../../domain/billing_cycle.dart';
import '../../domain/models.dart';
import '../../domain/money.dart';
import '../../ui/card_face.dart';
import '../../ui/widgets.dart';
import '../add_card/card_form.dart';

class CardDetailScreen extends ConsumerWidget {
  const CardDetailScreen({super.key, required this.cardId});
  final String cardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = ref.watch(cardProvider(cardId));
    if (card == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('This card was removed.')),
      );
    }
    final style = ref.watch(catalogProvider).product(card.productId)?.face ??
        const CardFaceStyle();
    final benefits = ref.watch(benefitsForCardProvider(cardId));
    final waiver = ref.watch(feeWaiverProvider(cardId));
    final cycle = cycleFor(card, DateTime.now());
    final days = cycle.interestFreeDaysFrom(DateTime.now());
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Card details'),
        actions: [
          IconButton(
            tooltip: 'Edit card',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _editCard(context, ref, card),
          ),
          PopupMenuButton<String>(
            tooltip: 'More',
            onSelected: (v) {
              if (v == 'delete') _confirmDelete(context, ref, card);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'delete', child: Text('Remove card')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          Hero(tag: 'card-${card.id}', child: CardFace(card: card, style: style)),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.25,
            children: [
              _stat('Limit', formatInr(card.creditLimitPaise)),
              _stat('Annual fee',
                  card.annualFeePaise == 0 ? 'Free' : formatInr(card.annualFeePaise)),
              _stat('Waived at',
                  card.waiverSpendPaise == null
                      ? '—'
                      : '${formatInr(card.waiverSpendPaise!)}/yr'),
              _stat('Statement', _ordinal(card.statementDay)),
              _stat('Due', _ordinal(card.dueDay)),
              _stat('UPI', card.network.worksOnUpi ? 'Yes' : 'No',
                  color: card.network.worksOnUpi
                      ? AppColors.earned
                      : AppColors.dangerText),
            ],
          ),
          const SizedBox(height: 12),
          Tile(
            child: Row(children: [
              const Icon(Icons.event_available_outlined,
                  color: AppColors.onPrimaryContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text.rich(TextSpan(children: [
                  const TextSpan(text: 'Buy today, pay by '),
                  TextSpan(
                      text: '${cycle.due.day}/${cycle.due.month}',
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  TextSpan(text: ': $days interest-free days'),
                ])),
              ),
            ]),
          ),
          if (waiver != null) ...[
            const SizedBox(height: 12),
            Tile(
              child: Row(children: [
                ProgressRing(
                  value: waiver.progress,
                  size: 76,
                  stroke: 8,
                  color: waiver.achieved ? AppColors.earned : AppColors.attention,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Fee waiver progress',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(
                          '${formatInr(waiver.spentPaise)} of ${formatInr(waiver.targetPaise)}',
                          style: const TextStyle(color: AppColors.textTertiary)),
                      const SizedBox(height: 2),
                      Text(
                        waiver.achieved
                            ? 'Done: this year\'s fee should be waived'
                            : '${formatInr(waiver.remainingPaise)} left · ${waiver.daysLeft} days to anniversary',
                        style: TextStyle(
                            fontSize: 12,
                            color: waiver.achieved
                                ? AppColors.earned
                                : AppColors.attention),
                      ),
                      const SizedBox(height: 2),
                      const Caption('Counts card spends you log in Money.'),
                    ],
                  ),
                ),
              ]),
            ),
          ],
          const SizedBox(height: 18),
          const SectionTitle('Benefits'),
          if (benefits.isEmpty)
            const Caption('No benefits for this card yet.')
          else
            Tile(
              padding: EdgeInsets.zero,
              child: Column(children: [
                for (final (i, b) in benefits.indexed) ...[
                  if (i > 0) const Divider(height: 1, indent: 14, endIndent: 14),
                  _BenefitRow(
                    benefit: b,
                    stale: b.isStale(now),
                    onEdit: () => _editBenefit(context, ref, card, b),
                  ),
                ],
              ]),
            ),
          const SizedBox(height: 10),
          const Caption(
              'Rates come from the benefits list and may be out of date. Tap a benefit to correct it or mark it verified.'),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, {Color? color}) => Tile(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            FittedBox(
              child: Text(value,
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: color)),
            ),
          ],
        ),
      );

  static String _ordinal(int d) {
    if (d >= 11 && d <= 13) return '${d}th';
    return switch (d % 10) {
      1 => '${d}st',
      2 => '${d}nd',
      3 => '${d}rd',
      _ => '${d}th',
    };
  }

  Future<void> _editBenefit(
      BuildContext context, WidgetRef ref, UserCard card, Benefit b) async {
    final rate = TextEditingController(
        text: b.rateBps == null ? '' : (b.rateBps! / 100).toString());
    final cap = TextEditingController(
        text: b.monthlyCapPaise == null ? '' : '${b.monthlyCapPaise! ~/ 100}');
    final save = await showModalBottomSheet<bool>(
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
            Text(b.title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Caption(
                'Check your bank\'s current terms (MITC), then correct the numbers. Your edits are kept when benefits update.'),
            const SizedBox(height: 16),
            if (b.kind != BenefitKind.info) ...[
              TextField(
                controller: rate,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: b.kind == BenefitKind.forexMarkup
                      ? 'Forex markup'
                      : 'Reward rate',
                  suffixText: '%',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cap,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Monthly cap (optional)', prefixText: '₹ '),
              ),
              const SizedBox(height: 16),
            ],
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save and mark verified'),
            ),
          ],
        ),
      ),
    );
    if (save != true) return;
    final pct = double.tryParse(rate.text.trim());
    await ref.read(databaseProvider).saveOverride(BenefitOverridesCompanion(
          userCardId: Value(card.id),
          benefitId: Value(b.id),
          rateBps: Value(pct == null ? null : (pct * 100).round()),
          monthlyCapPaise: Value(parseRupeesToPaise(cap.text)),
          verifiedOn: Value(DateTime.now()),
        ));
  }

  Future<void> _editCard(
      BuildContext context, WidgetRef ref, UserCard card) async {
    final v = CardFormValues(
      nickname: card.nickname ?? '',
      last4: card.last4 ?? '',
      limitRupees: '${card.creditLimitPaise ~/ 100}',
      statementDay: '${card.statementDay}',
      dueDay: '${card.dueDay}',
      annualFeeRupees: '${card.annualFeePaise ~/ 100}',
      waiverRupees: card.waiverSpendPaise == null
          ? ''
          : '${card.waiverSpendPaise! ~/ 100}',
      anniversaryMonth: card.anniversaryMonth,
    );
    final db = ref.read(databaseProvider);
    final finish = await db.faceFinish(card.id) ?? 'matte';
    if (!context.mounted) return;
    final save = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceHigh,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Edit card',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                CardForm(values: v, onChanged: () => setSheet(() {})),
                FilledButton(
                  onPressed: v.valid ? () => Navigator.pop(ctx, true) : null,
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (save != true) return;
    await db.upsertCard(
      UserCard(
        id: card.id,
        productId: card.productId,
        bankName: card.bankName,
        name: card.name,
        nickname: v.nickname.trim().isEmpty ? null : v.nickname.trim(),
        network: card.network,
        last4: v.last4.isEmpty ? null : v.last4,
        creditLimitPaise: v.limitPaise!,
        statementDay: v.statement!,
        dueDay: v.due!,
        annualFeePaise: v.feePaise,
        waiverSpendPaise: v.waiverPaise,
        anniversaryMonth: v.anniversaryMonth,
        faceColor: card.faceColor,
      ),
      finish: finish,
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, UserCard card) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove ${card.displayName}?'),
        content: const Text(
            'The card and your benefit edits are deleted. Logged expenses stay in Money.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Remove')),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(databaseProvider).deleteCard(card.id);
    if (context.mounted) context.pop();
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.benefit,
    required this.stale,
    required this.onEdit,
  });

  final Benefit benefit;
  final bool stale;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final b = benefit;
    final rate = b.rateBps;
    final isForex = b.kind == BenefitKind.forexMarkup;
    final details = [
      if (b.channel != null) 'via ${b.channel}',
      if (b.monthlyCapPaise != null) 'cap ${formatInr(b.monthlyCapPaise!)}/mo',
      if (b.conditions != null) b.conditions!,
    ].join(' · ');
    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Caption(details),
                ],
                if (stale) ...[
                  const SizedBox(height: 6),
                  Pill.attention('Verify'),
                ],
              ],
            ),
          ),
          if (rate != null)
            Text(
              isForex ? '${formatBps(rate)} fx' : formatBps(rate),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isForex
                    ? (rate == 0 ? AppColors.earned : AppColors.textTertiary)
                    : (rate > 100
                        ? AppColors.earned
                        : rate == 0
                            ? AppColors.textSecondary
                            : AppColors.textTertiary),
              ),
            ),
        ]),
      ),
    );
  }
}
