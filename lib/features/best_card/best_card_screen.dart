import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../domain/billing_cycle.dart';
import '../../domain/models.dart';
import '../../domain/money.dart';
import '../../domain/recommender.dart';
import '../../ui/widgets.dart';

/// Which card should I use? (design board 5) plus "Pay today with…".
class BestCardScreen extends ConsumerStatefulWidget {
  const BestCardScreen({super.key});

  @override
  ConsumerState<BestCardScreen> createState() => _BestCardScreenState();
}

class _BestCardScreenState extends ConsumerState<BestCardScreen> {
  SpendCategory _category = SpendCategory.utilities;
  int _amountPaise = 240000;
  bool _upi = false;

  static const _categories = [
    SpendCategory.utilities,
    SpendCategory.telecom,
    SpendCategory.foodDelivery,
    SpendCategory.groceries,
    SpendCategory.shopping,
    SpendCategory.dining,
    SpendCategory.fuel,
    SpendCategory.travel,
    SpendCategory.foreign,
    SpendCategory.rent,
    SpendCategory.insurance,
    SpendCategory.other,
  ];

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(cardsWithBenefitsProvider);
    final results = recommend(
      Purchase(category: _category, amountPaise: _amountPaise, viaUpi: _upi),
      cards,
    );
    final today = DateTime.now();
    final payToday = payTodayRanking([for (final c in cards) c.card], today);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          children: [
            const Caption('Before you pay'),
            const Text('Which card should I use?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final c in _categories)
                ChoiceChip(
                  label: Text(c.label),
                  selected: c == _category,
                  onSelected: (_) => setState(() => _category = c),
                ),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: TextFormField(
                  initialValue: '${_amountPaise ~/ 100}',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                      labelText: 'Amount', prefixText: '₹ '),
                  onChanged: (s) => setState(
                      () => _amountPaise = parseRupeesToPaise(s) ?? 0),
                ),
              ),
              const SizedBox(width: 10),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Card')),
                  ButtonSegment(value: true, label: Text('UPI')),
                ],
                selected: {_upi},
                onSelectionChanged: (s) => setState(() => _upi = s.first),
              ),
            ]),
            const SizedBox(height: 18),
            if (cards.isEmpty)
              Tile(
                onTap: () => context.push('/add-card'),
                child: const Text('Add a card to see recommendations.'),
              )
            else ...[
              const Text('RANKED FOR YOU',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      letterSpacing: 1)),
              const SizedBox(height: 8),
              for (final (i, r) in results.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ResultRow(
                      rank: i + 1, result: r, amount: _amountPaise, best: i == 0),
                ),
              const Caption(
                  'Uses your cards\' benefits (some are sample rates until verified) and what you\'ve logged this month for caps.'),
              const SizedBox(height: 24),
              const SectionTitle('Pay today with…'),
              const Caption('Most interest-free days for a purchase today'),
              const SizedBox(height: 10),
              Tile(
                child: Column(children: [
                  for (final o in payToday)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(children: [
                        Container(
                          width: 40,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Color(o.card.faceColor),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(o.card.displayName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              Caption(
                                  'Statement ${o.dates.statement.day}/${o.dates.statement.month} · due ${o.dates.due.day}/${o.dates.due.month}'),
                            ],
                          ),
                        ),
                        Text('${o.days} days',
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: o == payToday.first
                                    ? AppColors.earned
                                    : AppColors.textPrimary)),
                      ]),
                    ),
                ]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.rank,
    required this.result,
    required this.amount,
    required this.best,
  });

  final int rank;
  final Recommendation result;
  final int amount;
  final bool best;

  @override
  Widget build(BuildContext context) {
    final r = result;
    final highlight = best && r.eligible && r.netPaise > 0;
    final valueColor = !r.eligible
        ? AppColors.textSecondary
        : r.netPaise > 0
            ? AppColors.earned
            : r.netPaise < 0
                ? AppColors.dangerText
                : AppColors.textTertiary;
    return Opacity(
      opacity: r.eligible ? 1 : 0.7,
      child: Tile(
        padding: const EdgeInsets.all(12),
        color: highlight ? AppColors.earnedContainer : AppColors.surface,
        border: highlight ? AppColors.earnedBorder : null,
        child: Row(children: [
          SizedBox(
            width: 24,
            child: Text(r.eligible ? '$rank' : '–',
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary)),
          ),
          Container(
            width: 44,
            height: 28,
            decoration: BoxDecoration(
              color: Color(r.card.faceColor),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.card.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(r.reason,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textTertiary)),
                if (r.warning != null)
                  Text(r.warning!,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.attention)),
              ],
            ),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(r.eligible ? formatInr(r.netPaise) : 'N/A',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: valueColor)),
            Text(
                r.eligible && amount > 0
                    ? '${(r.netPaise / amount * 100).toStringAsFixed(1)}%'
                    : 'ineligible',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
          ]),
        ]),
      ),
    );
  }
}
