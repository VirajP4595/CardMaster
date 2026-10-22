import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

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
import 'card_extras.dart';

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
            onSelected: (v) async {
              switch (v) {
                case 'photo':
                  context.push('/card/${card.id}/photo');
                case 'styled':
                  await ref.read(photoStoreProvider)?.delete(card.id);
                  ref.invalidate(facePhotoProvider(card.id));
                case 'delete':
                  _confirmDelete(context, ref, card);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: 'photo', child: Text('Use a photo of my card')),
              if (ref.read(facePhotoProvider(card.id)).value != null)
                const PopupMenuItem(
                    value: 'styled', child: Text('Back to styled face')),
              const PopupMenuItem(value: 'delete', child: Text('Remove card')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          Hero(
            tag: 'card-${card.id}',
            child: CardFace(
              card: card,
              style: style,
              photo: ref.watch(facePhotoProvider(card.id)).value,
            ),
          ),
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
          const SizedBox(height: 12),
          Tile(
            onTap: () => context.push('/card/${card.id}/worth'),
            child: const Row(children: [
              Icon(Icons.insights_outlined, color: AppColors.onPrimaryContainer),
              SizedBox(width: 12),
              Expanded(
                child: Text('Is this card worth keeping?',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              Icon(Icons.chevron_right),
            ]),
          ),
          _Caps(card: card, benefits: benefits),
          _Points(card: card),
          LoungeTile(card: card),
          EmiSection(card: card),
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
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _customBenefitSheet(context, ref, card, null),
            icon: const Icon(Icons.add),
            label: const Text('Add a benefit'),
          ),
          const SizedBox(height: 10),
          const Caption(
              'Rates come from the benefits list and may be out of date. Tap a benefit to correct it or mark it verified. Benefits you add take priority.'),
          const SizedBox(height: 22),
          _LostCard(card: card),
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

  Future<void> _customBenefitSheet(BuildContext context, WidgetRef ref,
      UserCard card, Benefit? existing) async {
    final title = TextEditingController(text: existing?.title ?? '');
    final rate = TextEditingController(
        text: existing?.rateBps == null ? '' : '${existing!.rateBps! / 100}');
    final cap = TextEditingController(
        text: existing?.monthlyCapPaise == null
            ? ''
            : '${existing!.monthlyCapPaise! ~/ 100}');
    final channel = TextEditingController(text: existing?.channel ?? '');
    var category = existing?.category ?? SpendCategory.other;
    var forex = existing?.kind == BenefitKind.forexMarkup;
    final action = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceHigh,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(existing == null ? 'Add a benefit' : 'Edit benefit',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                TextField(
                  controller: title,
                  decoration: const InputDecoration(
                      labelText: 'Name', hintText: 'e.g. 5% on Swiggy'),
                  onChanged: (_) => set(() {}),
                ),
                const SizedBox(height: 12),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Reward')),
                    ButtonSegment(value: true, label: Text('Forex markup')),
                  ],
                  selected: {forex},
                  onSelectionChanged: (v) => set(() => forex = v.first),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<SpendCategory>(
                  initialValue: forex ? SpendCategory.foreign : category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    for (final c in SpendCategory.values)
                      DropdownMenuItem(value: c, child: Text(c.label)),
                  ],
                  onChanged: forex ? null : (c) => set(() => category = c!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: rate,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      labelText: forex ? 'Markup' : 'Reward rate',
                      helperText: forex
                          ? null
                          : 'For points, use their rupee value, e.g. 2 points per ₹100 worth ₹0.25 each = 0.5%',
                      suffixText: '%'),
                  onChanged: (_) => set(() {}),
                ),
                if (!forex) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: cap,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Monthly cap (optional)', prefixText: '₹ '),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: channel,
                    decoration: const InputDecoration(
                        labelText: 'Only via (optional)',
                        hintText: 'e.g. Airtel Thanks app'),
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: title.text.trim().isEmpty ||
                          double.tryParse(rate.text.trim()) == null
                      ? null
                      : () => Navigator.pop(ctx, 'save'),
                  child: const Text('Save'),
                ),
                if (existing != null)
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, 'delete'),
                    child: const Text('Delete this benefit'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    final db = ref.read(databaseProvider);
    final existingId =
        existing?.id.substring(customBenefitPrefix.length);
    if (action == 'delete' && existingId != null) {
      await db.deleteCustomBenefit(existingId);
      return;
    }
    if (action != 'save') return;
    final pct = double.parse(rate.text.trim());
    await db.saveCustomBenefit(CustomBenefitsCompanion(
      id: Value(existingId ?? const Uuid().v4()),
      userCardId: Value(card.id),
      category: Value(forex ? SpendCategory.foreign.code : category.code),
      kind: Value(forex ? BenefitKind.forexMarkup.code : BenefitKind.reward.code),
      title: Value(title.text.trim()),
      rateBps: Value((pct * 100).round()),
      monthlyCapPaise:
          Value(forex ? null : parseRupeesToPaise(cap.text)),
      channel: Value(
          forex || channel.text.trim().isEmpty ? null : channel.text.trim()),
      createdAt: Value(DateTime.now()),
    ));
  }

  Future<void> _editBenefit(
      BuildContext context, WidgetRef ref, UserCard card, Benefit b) async {
    if (b.id.startsWith(customBenefitPrefix)) {
      return _customBenefitSheet(context, ref, card, b);
    }
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
    await ref.read(photoStoreProvider)?.delete(card.id);
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

/// "Lost this card?": opens the dialer with the bank's helpline. Uses the
/// dialer app, so no call permission is needed.
class _LostCard extends ConsumerWidget {
  const _LostCard({required this.card});
  final UserCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final number = ref.watch(helplineProvider(card.id)).value;
    return Tile(
      color: AppColors.dangerContainer,
      onTap: () => number == null
          ? _edit(context, ref, null)
          : launchUrl(Uri(scheme: 'tel', path: number)),
      child: Row(children: [
        const Icon(Icons.phone_in_talk_outlined, color: AppColors.dangerText),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Lost this card?',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              Text(
                number == null
                    ? "Add your bank's helpline now (it's on the back of the card), so it's one tap away if you lose it."
                    : 'Call ${card.bankName} to block it: $number',
                style: const TextStyle(fontSize: 12, color: Color(0xFFFFC2C2)),
              ),
            ],
          ),
        ),
        if (number != null)
          IconButton(
            tooltip: 'Change number',
            onPressed: () => _edit(context, ref, number),
            icon: const Icon(Icons.edit_outlined, size: 18),
          ),
      ]),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, String? current) async {
    final c = TextEditingController(text: current ?? '');
    final value = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${card.bankName} helpline'),
        content: TextField(
          controller: c,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
              hintText: 'Number on the back of your card'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, c.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
    if (value == null) return;
    await ref
        .read(databaseProvider)
        .setHelpline(card.id, value.isEmpty ? null : value);
  }
}

/// This month's cap usage per capped benefit (design board 3).
class _Caps extends ConsumerWidget {
  const _Caps({required this.card, required this.benefits});
  final UserCard card;
  final List<Benefit> benefits;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capped = benefits
        .where((b) => b.kind == BenefitKind.reward && b.monthlyCapPaise != null)
        .toList();
    if (capped.isEmpty) return const SizedBox.shrink();
    final spends = ref.watch(spendsProvider).value ?? const <Spend>[];
    final used = capUsageThisMonth(card, benefits, spends, DateTime.now());
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionTitle("This month's caps"),
          Tile(
            child: Column(children: [
              for (final b in capped)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(children: [
                    Row(children: [
                      Expanded(child: Text(b.title)),
                      Text(
                        '${formatInr(used[b.id] ?? 0)} / ${formatInr(b.monthlyCapPaise!)}'
                        '${(used[b.id] ?? 0) >= b.monthlyCapPaise! ? ' · full' : ''}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ]),
                    const SizedBox(height: 5),
                    Bar(
                      value: (used[b.id] ?? 0) / b.monthlyCapPaise!,
                      color: (used[b.id] ?? 0) >= b.monthlyCapPaise!
                          ? AppColors.danger
                          : AppColors.earned,
                    ),
                  ]),
                ),
            ]),
          ),
        ],
      ),
    );
  }
}

/// Reward points wallet for this card (balance, rupee value, expiry).
class _Points extends ConsumerWidget {
  const _Points({required this.card});
  final UserCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(pointsProvider).value ?? const <PointsBalance>[];
    final p = all.where((x) => x.cardId == card.id).firstOrNull;
    final expiring = p?.expiresOn != null &&
        p!.expiresOn!.difference(DateTime.now()).inDays <= 60;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Tile(
        onTap: () => _edit(context, ref, p),
        child: Row(children: [
          const Icon(Icons.stars_outlined, color: AppColors.attention),
          const SizedBox(width: 12),
          Expanded(
            child: p == null
                ? const Text('Track reward points',
                    style: TextStyle(fontWeight: FontWeight.w700))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${groupIndian(p.points)} points ≈ ${formatInr(p.valuePaise)}',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      if (p.expiresOn != null)
                        Text(
                            'Expire ${DateFormat('d MMM yyyy').format(p.expiresOn!)}',
                            style: TextStyle(
                                fontSize: 12,
                                color: expiring
                                    ? AppColors.attention
                                    : AppColors.textSecondary)),
                    ],
                  ),
          ),
          const Icon(Icons.chevron_right),
        ]),
      ),
    );
  }

  Future<void> _edit(
      BuildContext context, WidgetRef ref, PointsBalance? p) async {
    final points = TextEditingController(text: p == null ? '' : '${p.points}');
    final value = TextEditingController(
        text: p == null ? '0.25' : '${p.paisePerPoint / 100}');
    DateTime? expires = p?.expiresOn;
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
              const Text('Reward points',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Caption(
                  'Copy the balance from your statement or bank app. Value per point is what you can redeem one point for.'),
              const SizedBox(height: 16),
              TextField(
                controller: points,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Points balance'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: value,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Value per point', prefixText: '₹ '),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.event_outlined),
                label: Text(expires == null
                    ? 'Expiry date (optional)'
                    : 'Expire ${DateFormat('d MMM yyyy').format(expires!)}'),
                onPressed: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: expires ??
                        DateTime.now().add(const Duration(days: 365)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );
                  if (d != null) set(() => expires = d);
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, 'save'),
                child: const Text('Save'),
              ),
              if (p != null)
                TextButton(
                  onPressed: () => Navigator.pop(ctx, 'delete'),
                  child: const Text('Stop tracking points'),
                ),
            ],
          ),
        ),
      ),
    );
    final db = ref.read(databaseProvider);
    if (result == 'delete') {
      await db.deletePoints(card.id);
      return;
    }
    if (result != 'save') return;
    final n = int.tryParse(points.text.replaceAll(',', '').trim());
    final perPoint = parseRupeesToPaise(value.text);
    if (n == null || perPoint == null) return;
    await db.savePoints(PointsBalance(
      cardId: card.id,
      points: n,
      paisePerPoint: perPoint,
      expiresOn: expires,
    ));
  }
}
