import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../domain/models.dart';
import '../../domain/money.dart';
import '../../domain/sms_parser.dart';
import '../../ui/widgets.dart';

/// Review screen for several bank messages at once (design board 12).
class ImportReviewScreen extends ConsumerStatefulWidget {
  const ImportReviewScreen({super.key, required this.text});
  final String text;

  @override
  ConsumerState<ImportReviewScreen> createState() =>
      _ImportReviewScreenState();
}

class _Row {
  _Row(this.parsed, this.cardId, this.category, this.duplicate)
      : selected = cardId != null && !duplicate;
  final ParsedSpend parsed;
  String? cardId;
  SpendCategory category;
  final bool duplicate;
  bool selected;
}

class _ImportReviewScreenState extends ConsumerState<ImportReviewScreen> {
  List<_Row>? _rows;
  int _found = 0;
  int _ignored = 0;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final messages = splitMessages(widget.text);
    final parsed = parseMany(widget.text);
    final cards = ref.read(cardsProvider).value ?? const <UserCard>[];
    final existing = ref.read(spendsProvider).value ?? const <Spend>[];
    final db = ref.read(databaseProvider);
    final rows = <_Row>[];
    for (final p in parsed) {
      final card = cards.where((c) => c.last4 != null && c.last4 == p.last4);
      final cardId = card.firstOrNull?.id;
      final dup = existing.any((s) =>
          s.userCardId == cardId &&
          isLikelyDuplicate(p,
              amountPaise: s.amountPaise,
              last4: card.firstOrNull?.last4,
              date: s.spentOn));
      final cat = (p.merchant == null ? null : await db.categoryFor(p.merchant!)) ??
          (p.international ? SpendCategory.foreign : SpendCategory.other);
      rows.add(_Row(p, cardId, cat, dup));
    }
    if (!mounted) return;
    setState(() {
      _rows = rows;
      _found = messages.length;
      _ignored = messages.length - parsed.length;
    });
  }

  Future<void> _import() async {
    final db = ref.read(databaseProvider);
    final now = DateTime.now();
    for (final r in _rows!.where((r) => r.selected && r.cardId != null)) {
      await db.addSpend(
        Spend(
          id: const Uuid().v4(),
          amountPaise: r.parsed.amountPaise,
          category: r.category,
          paymentKind: PaymentKind.card,
          userCardId: r.cardId,
          viaUpi: r.parsed.viaUpi,
          international: r.parsed.international,
          note: r.parsed.merchant,
          spentOn: r.parsed.date ?? now,
        ),
        merchant: r.parsed.merchant,
        source: 'CLIPBOARD',
      );
      if (r.parsed.merchant != null &&
          r.category != SpendCategory.other) {
        await db.remember(r.parsed.merchant!, r.category);
      }
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows;
    final cards = ref.watch(cardsProvider).value ?? const <UserCard>[];
    final count = rows?.where((r) => r.selected && r.cardId != null).length ?? 0;
    final dups = rows?.where((r) => r.duplicate).length ?? 0;
    return Scaffold(
      appBar: AppBar(
        title: Text('Import $count expense${count == 1 ? '' : 's'}'),
      ),
      body: rows == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    children: [
                      Row(children: [
                        _count('${rows.length}', 'card spends',
                            AppColors.earnedContainer, AppColors.earned),
                        const SizedBox(width: 8),
                        _count('$dups', 'already added', AppColors.surface,
                            AppColors.textPrimary),
                        const SizedBox(width: 8),
                        _count('$_ignored', 'OTPs, credits, other',
                            AppColors.surface, AppColors.textPrimary),
                      ]),
                      const SizedBox(height: 6),
                      Caption('$_found messages read'),
                      const SizedBox(height: 12),
                      if (rows.isEmpty)
                        const Caption('No card spends found in that text.')
                      else
                        Tile(
                          padding: EdgeInsets.zero,
                          child: Column(children: [
                            for (final r in rows) _rowTile(r, cards),
                          ]),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                  child: Column(children: [
                    const Caption(
                        'Read on this phone. Message text isn\'t saved, only amount, merchant, card and date.'),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: count == 0 ? null : _import,
                      child: Text('Import $count expense${count == 1 ? '' : 's'}'),
                    ),
                  ]),
                ),
              ]),
            ),
    );
  }

  Widget _count(String n, String label, Color bg, Color fg) => Expanded(
        child: Tile(
          color: bg,
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(n,
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800, color: fg)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textTertiary)),
            ],
          ),
        ),
      );

  Widget _rowTile(_Row r, List<UserCard> cards) {
    final p = r.parsed;
    final card = cards.where((c) => c.id == r.cardId).firstOrNull;
    final sub = card == null
        ? 'Card ••${p.last4 ?? '????'} not in wallet · tap to pick a card'
        : '${card.displayName} · ${r.category.label}'
            '${p.date == null ? '' : ' · ${DateFormat('d MMM').format(p.date!)}'}'
            '${r.duplicate ? ' · already added?' : ''}';
    return CheckboxListTile(
      value: r.selected && r.cardId != null,
      onChanged: (v) async {
        if (r.cardId == null) {
          final picked = await _pickCard(cards);
          if (picked == null) return;
          setState(() {
            r.cardId = picked;
            r.selected = true;
          });
        } else {
          setState(() => r.selected = v ?? false);
        }
      },
      title: Text(p.merchant ?? 'Card spend',
          style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(sub,
          style: TextStyle(
              fontSize: 12,
              color: card == null || r.duplicate
                  ? AppColors.attention
                  : AppColors.textSecondary)),
      secondary: Text(formatInr(p.amountPaise),
          style: const TextStyle(fontWeight: FontWeight.w700)),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Future<String?> _pickCard(List<UserCard> cards) =>
      showModalBottomSheet<String>(
        context: context,
        backgroundColor: AppColors.surfaceHigh,
        builder: (ctx) => SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const ListTile(title: Text('Which card was this?')),
            for (final c in cards)
              ListTile(
                leading: Container(
                  width: 36,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Color(c.faceColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                title: Text(c.displayName),
                onTap: () => Navigator.pop(ctx, c.id),
              ),
          ]),
        ),
      );
}
