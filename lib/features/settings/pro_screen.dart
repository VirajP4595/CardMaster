import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../app/billing.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../domain/entitlement.dart';
import '../../domain/models.dart';
import '../../domain/money.dart';
import '../../ui/widgets.dart';
import '../money/money_logic.dart';

final _productsProvider = FutureProvider<Map<String, ProductDetails>>(
  (ref) => Billing.instance.products(),
);

/// Pro upgrade + buy me a coffee (design board 8, docs/07 §3.2).
/// Value first (your own number), honest story second, never guilt.
class ProScreen extends ConsumerStatefulWidget {
  const ProScreen({super.key});

  @override
  ConsumerState<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends ConsumerState<ProScreen> {
  String _tip = ProductIds.coffees[1];
  int _tierIndex = 5;
  bool _custom = false;

  static const _perks = [
    ('Is this card worth keeping?', 'Yearly Keep / Borderline / Reconsider verdict'),
    ('Milestones & caps', 'Know exactly what to spend, and where'),
    ('Reward points wallet', 'Balances, rupee value and expiry reminders'),
    ('Statement PDF import', 'A whole month of spends in one go'),
    ('Recurring, history & CSV', 'Rent and subscriptions logged for you'),
    ('Photo faces, widgets, lounge tracker', 'Your real card look, best card in one tap'),
  ];

  int _foundPaise() {
    final e = ref.watch(entitlementProvider);
    final spends = (ref.watch(spendsProvider).value ?? const <Spend>[])
        .where((s) => !s.spentOn.isBefore(e.trialStart))
        .toList();
    final cards = ref.watch(cardsWithBenefitsProvider);
    // Per month, so monthly caps apply correctly.
    final byMonth = <int, List<Spend>>{};
    for (final s in spends) {
      byMonth.putIfAbsent(s.spentOn.year * 12 + s.spentOn.month, () => []).add(s);
    }
    return byMonth.values
        .map((m) => earnedBySpend(m, cards).values.fold<int>(0, (a, v) => a + v))
        .fold<int>(0, (a, v) => a + v);
  }

  @override
  Widget build(BuildContext context) {
    final e = ref.watch(entitlementProvider);
    final now = DateTime.now();
    final products = ref.watch(_productsProvider).value ?? const {};
    final pro = products[ProductIds.pro];
    final found = _foundPaise();
    final supporter = settingOn(ref, SettingKeys.supporter, fallback: false);
    final tipId = _custom ? ProductIds.tipTiers[_tierIndex] : _tip;
    final tipProduct = products[tipId];

    final value = Tile(
      color: AppColors.earnedContainer,
      border: AppColors.earnedBorder,
      child: Column(children: [
        const Text('Since you started, Card Master found you',
            style: TextStyle(color: AppColors.textTertiary)),
        Text(formatInr(found),
            style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: AppColors.earned)),
        const Caption('in rewards from better card picks you logged.',
            color: AppColors.textSecondary),
      ]),
    );
    final perks = Tile(
      child: Column(children: [
        for (final p in _perks)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.check, color: AppColors.earned, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
                    Caption(p.$2),
                  ],
                ),
              ),
            ]),
          ),
      ]),
    );

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (!e.purchased && e.gatingEnabled && e.inTrial(now))
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Pill.attention('Trial · ${e.trialDaysLeft(now)} days left'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        children: [
          const Center(child: BrandMark(size: 72)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Wordmark(fontSize: 22, color: AppColors.textPrimary),
            const SizedBox(width: 8),
            Pill('PRO', fg: AppColors.background, bg: AppColors.attention),
          ]),
          const SizedBox(height: 16),
          // A small number argues against buying: features first then.
          if (found >= 30000) ...[value, const SizedBox(height: 12), perks]
          else ...[perks, if (found > 0) ...[const SizedBox(height: 12), value]],
          const SizedBox(height: 16),
          if (e.purchased)
            Pill.earned('Pro is yours. Thank you!')
          else if (!e.gatingEnabled)
            const Tile(
              child: Text(
                  "Every feature is unlocked while Card Master is in testing. Pro goes on sale when the app is on Google Play.",
                  style: TextStyle(color: AppColors.textTertiary)),
            )
          else ...[
            FilledButton(
              onPressed: pro == null ? null : () => Billing.instance.buyPro(pro),
              child: Text(pro == null
                  ? 'Not available on this device'
                  : 'Unlock Pro · ${pro.price}'),
            ),
          ],
          TextButton(
            onPressed: Billing.instance.restore,
            child: const Text('Restore purchase'),
          ),
          const Divider(height: 32),
          const Text('Made by one person',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text(
              "Card Master has no investors, no ads and never sees your data, so there's nothing to sell. Keeping card benefits up to date every month is real work, and your support is the only thing that pays for it.",
              style: TextStyle(color: AppColors.textTertiary, height: 1.5)),
          const SizedBox(height: 16),
          Row(children: [
            const Expanded(
              child: Text('Buy me a coffee',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            if (supporter) Pill.attention('☆ Supporter'),
          ]),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final (id, label) in [
              (ProductIds.coffees[0], 'A chai · ₹49'),
              (ProductIds.coffees[1], 'A coffee · ₹99'),
              (ProductIds.coffees[2], 'Coffee + snack · ₹199'),
            ])
              ChoiceChip(
                label: Text(label),
                selected: !_custom && _tip == id,
                onSelected: (_) => setState(() {
                  _tip = id;
                  _custom = false;
                }),
              ),
            ChoiceChip(
              label: const Text('Custom'),
              selected: _custom,
              onSelected: (_) => setState(() => _custom = true),
            ),
          ]),
          if (_custom)
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton(
                tooltip: 'Smaller tip',
                onPressed: () => setState(
                    () => _tierIndex = (_tierIndex - 1).clamp(0, 7)),
                icon: const Icon(Icons.remove),
              ),
              Text('₹${ProductIds.tipTiers[_tierIndex].substring(4)}',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w800)),
              IconButton(
                tooltip: 'Bigger tip',
                onPressed: () => setState(
                    () => _tierIndex = (_tierIndex + 1).clamp(0, 7)),
                icon: const Icon(Icons.add),
              ),
            ]),
          if (_custom)
            const Caption(
                'Google Play only allows set prices, so amounts go in steps from ₹29 to ₹999.'),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: tipProduct == null
                ? null
                : () => Billing.instance.tip(tipProduct),
            child: Text(tipProduct == null
                ? 'Tips open when the app is on Google Play'
                : 'Send ${tipProduct.price}'),
          ),
          const SizedBox(height: 6),
          const Caption(
              'A tip, not a purchase: it unlocks nothing. Supporters get a small ☆ on Settings as a thank-you.'),
          const SizedBox(height: 10),
          const Caption(
              "Google Play keeps a share of every payment for its fees, and taxes are taken out too. What's left goes into keeping Card Master going."),
        ],
      ),
    );
  }
}
