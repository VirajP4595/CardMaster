import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../domain/models.dart';
import '../../domain/trackers.dart';
import '../../ui/widgets.dart';

/// A saved bank offer, shown above the ranking for its category.
class OfferTile extends ConsumerWidget {
  const OfferTile({super.key, required this.offer});
  final SavedOffer offer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card =
        offer.cardId == null ? null : ref.watch(cardProvider(offer.cardId!));
    return Tile(
      color: AppColors.attentionContainer,
      onTap: () => editOffer(context, ref, offer),
      child: Row(children: [
        const Icon(Icons.local_offer_outlined, color: AppColors.attention),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(offer.title,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(
                  '${card == null ? '' : '${card.displayName} · '}until ${DateFormat('d MMM').format(offer.validUntil)}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textTertiary)),
            ],
          ),
        ),
      ]),
    );
  }
}

/// Saved offers ("10% off with HDFC during the sale"), kept until they
/// expire. Typed in by the user; nothing is fetched.
class OffersSection extends ConsumerWidget {
  const OffersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final offers = (ref.watch(offersProvider).value ?? const <SavedOffer>[])
        .where((o) => o.isActive(now))
        .toList()
      ..sort((a, b) => a.validUntil.compareTo(b.validUntil));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle('Saved offers',
            trailing: TextButton(
              onPressed: () => editOffer(context, ref, null),
              child: const Text('Add'),
            )),
        if (offers.isEmpty)
          const Caption(
              'Seen a bank offer for a sale? Save it here and it shows up when you pick that category.')
        else
          for (final o in offers)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OfferTile(offer: o),
            ),
      ],
    );
  }
}

Future<void> editOffer(
    BuildContext context, WidgetRef ref, SavedOffer? existing) async {
  final title = TextEditingController(text: existing?.title ?? '');
  var category = existing?.category ?? SpendCategory.shopping;
  var until =
      existing?.validUntil ?? DateTime.now().add(const Duration(days: 7));
  String? cardId = existing?.cardId;
  final cards = ref.read(cardsProvider).value ?? const <UserCard>[];
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
            const Text('Offer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            TextField(
              controller: title,
              decoration: const InputDecoration(
                  labelText: 'Offer', hintText: '10% off on Amazon sale'),
            ),
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
            DropdownButtonFormField<String?>(
              initialValue: cardId,
              decoration: const InputDecoration(labelText: 'Card (optional)'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Any card')),
                for (final c in cards)
                  DropdownMenuItem(value: c.id, child: Text(c.displayName)),
              ],
              onChanged: (v) => set(() => cardId = v),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.event_outlined),
              label: Text('Valid until ${DateFormat('d MMM yyyy').format(until)}'),
              onPressed: () async {
                final d = await showDatePicker(
                  context: ctx,
                  initialDate: until,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (d != null) set(() => until = d);
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
                child: const Text('Delete offer'),
              ),
          ],
        ),
      ),
    ),
  );
  final db = ref.read(databaseProvider);
  if (result == 'delete' && existing != null) {
    return db.deleteOffer(existing.id);
  }
  if (result != 'save' || title.text.trim().isEmpty) return;
  await db.saveOffer(SavedOffer(
    id: existing?.id ?? const Uuid().v4(),
    title: title.text.trim(),
    category: category,
    validUntil: DateTime(until.year, until.month, until.day),
    cardId: cardId,
  ));
}
