import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../domain/models.dart';
import '../../domain/csv_export.dart';
import '../../domain/money.dart';
import '../../domain/sms_backup.dart';
import '../../domain/statement_parser.dart';
import '../../data/pdf_text.dart';
import '../../ui/widgets.dart';
import 'import_review_screen.dart';
import 'recurring_section.dart';
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
            const RecurringSection(),
            const SizedBox(height: 18),
            SectionTitle('Expenses',
                trailing: PopupMenuButton<String>(
                  tooltip: 'Import',
                  icon: const Icon(Icons.download_outlined),
                  onSelected: (v) => switch (v) {
                    'paste' => _pasteMessages(context),
                    'file' => _importBackupFile(context),
                    'pdf' => _importStatement(context),
                    _ => _exportCsv(context, all),
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                        value: 'paste', child: Text('Paste bank messages')),
                    PopupMenuItem(
                        value: 'file', child: Text('Import SMS backup file')),
                    PopupMenuItem(
                        value: 'pdf',
                        child: Text('Import statement PDF (beta)')),
                    PopupMenuItem(
                        value: 'csv', child: Text('Export all as CSV')),
                  ],
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

  /// Saves every expense as a CSV file where the user chooses. Not
  /// encrypted, so the dialog says so.
  Future<void> _exportCsv(BuildContext context, List<Spend> all) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export as CSV'),
        content: const Text(
            'A spreadsheet of all your expenses. Unlike backups, a CSV file isn\'t encrypted: anyone who gets the file can read it.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Export')),
        ],
      ),
    );
    if (ok != true) return;
    final cards = ref.read(cardsProvider).value ?? const <UserCard>[];
    final csv = spendsToCsv(all, {for (final c in cards) c.id: c.displayName});
    final now = DateTime.now();
    final saved = await FilePicker.saveFile(
      dialogTitle: 'Save CSV',
      fileName:
          'cardmaster-expenses-${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}.csv',
      bytes: utf8.encode(csv),
    );
    if (saved != null) {
      messenger.showSnackBar(
          SnackBar(content: Text('Exported ${all.length} expenses.')));
    }
  }

  /// Statement PDF import (beta): text is extracted on this phone and
  /// parsed generically; every row goes through the review screen.
  Future<void> _importStatement(BuildContext context) async {
    final picked = await FilePicker.pickFiles();
    if (picked.isEmpty || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final bytes = await picked.single.readAsBytes();
      final text = await extractPdfText(bytes, askPassword: () async {
        if (!context.mounted) return null;
        return _askPdfPassword(context);
      });
      final r = parseStatementText(text);
      if (!context.mounted) return;
      if (r.spends.isEmpty) {
        messenger.showSnackBar(const SnackBar(
            content: Text(
                "Couldn't find transactions in that PDF. Statement layouts vary; share or paste the SMS instead.")));
        return;
      }
      context.push('/import',
          extra: ImportPayload(
            spends: r.spends,
            messagesRead: r.spends.length + r.creditsSkipped,
            source: 'PDF',
          ));
    } on PdfPasswordNeeded {
      messenger.showSnackBar(const SnackBar(
          content: Text('That PDF needs its password to open.')));
    } catch (e) {
      messenger.showSnackBar(
          SnackBar(content: Text('Could not read that PDF: $e')));
    }
  }

  Future<String?> _askPdfPassword(BuildContext context) {
    final c = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Statement password'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text(
              'Banks protect statements with a password (often part of your name and date of birth). It\'s used once to open the file and isn\'t saved.'),
          TextField(controller: c, obscureText: true, autofocus: true),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, c.text),
              child: const Text('Open')),
        ],
      ),
    );
  }

  /// Imports an XML export from an SMS backup app (docs/08 §2b). The file
  /// is read here and not copied into the app.
  Future<void> _importBackupFile(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import an SMS backup'),
        content: const Text(
            'Export your messages as an XML file with an SMS backup app (for example "SMS Backup & Restore"), then pick that file. Only messages from bank senders are read, on this phone. The file isn\'t copied into Card Master.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Pick file')),
        ],
      ),
    );
    if (ok != true) return;
    final picked = await FilePicker.pickFiles();
    if (picked.isEmpty || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final text = utf8.decode(await picked.single.readAsBytes(),
          allowMalformed: true);
      final result = parseSmsBackupXml(text);
      if (!context.mounted) return;
      if (result.messagesRead == 0) {
        messenger.showSnackBar(const SnackBar(
            content: Text("That doesn't look like an SMS backup XML file.")));
        return;
      }
      context.push('/import',
          extra: ImportPayload(
            spends: result.spends,
            messagesRead: result.messagesRead,
            source: 'SMS_FILE',
          ));
    } catch (e) {
      messenger.showSnackBar(
          SnackBar(content: Text('Could not read that file: $e')));
    }
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
