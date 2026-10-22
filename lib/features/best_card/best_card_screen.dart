import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../domain/billing_cycle.dart';
import '../../domain/models.dart';
import '../../domain/money.dart';
import '../../domain/recommender.dart';
import '../../domain/trackers.dart';
import 'offers.dart';
import '../../ui/amount_input.dart';
import '../../ui/widgets.dart';

/// Which card should I use? (design board 5) plus "Pay today with…".
class BestCardScreen extends ConsumerStatefulWidget {
  const BestCardScreen({super.key});

  @override
  ConsumerState<BestCardScreen> createState() => _BestCardScreenState();
}

class _BestCardScreenState extends ConsumerState<BestCardScreen> {
  SpendCategory? _picked;
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
    final travel = settingOn(ref, SettingKeys.travelMode, fallback: false);
    final category = _picked ??
        (travel ? SpendCategory.foreign : SpendCategory.utilities);
    final cards = ref.watch(cardsWithBenefitsProvider);
    final suggestions = ref.watch(suggestionsProvider);
    final results = recommend(
      Purchase(category: category, amountPaise: _amountPaise, viaUpi: _upi),
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
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.flight_takeoff_outlined),
              title: const Text('Travel mode',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text(
                  'Abroad? Rank cards by their true cost: rewards minus forex markup.'),
              value: travel,
              onChanged: (v) async {
                await ref
                    .read(databaseProvider)
                    .setValue(SettingKeys.travelMode, '$v');
                setState(() => _picked = null);
              },
            ),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final c in _categories)
                ChoiceChip(
                  label: Text(c.label),
                  selected: c == category,
                  onSelected: (_) => setState(() => _picked = c),
                ),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: TextFormField(
                  initialValue: amountFieldText(_amountPaise),
                  keyboardType: TextInputType.number,
                  inputFormatters: const [
                    IndianAmountFormatter(decimals: false)
                  ],
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
              for (final o in activeOffersFor(
                  ref.watch(offersProvider).value ?? const <SavedOffer>[],
                  category,
                  DateTime.now()))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OfferTile(offer: o),
                ),
              Text('RANKED FOR YOU',
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
              if (suggestions.isNotEmpty) ...[
                const SizedBox(height: 24),
                const SectionTitle('A card that fits your spending'),
                for (final sg in suggestions.take(2))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Tile(
                      border: const Color(0xFF3A3E52),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                              child: Text(sg.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                            ),
                            Pill.accent('Suggestion'),
                          ]),
                          const SizedBox(height: 6),
                          Text.rich(TextSpan(children: [
                            const TextSpan(
                                text:
                                    'Based on your last 90 days (worked out on this phone), it would earn about '),
                            TextSpan(
                                text:
                                    '${formatInr(sg.extraPerYearPaise)} more a year',
                                style: TextStyle(
                                    color: AppColors.earned,
                                    fontWeight: FontWeight.w800)),
                            TextSpan(
                                text: sg.annualFeePaise == 0
                                    ? '.'
                                    : ' after its ${formatInr(sg.annualFeePaise)} fee.'),
                          ])),
                          const SizedBox(height: 4),
                          const Caption(
                              'Ranked only by what you\'d earn, using sample rates. No ads, no paid placements, no links.'),
                        ],
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 24),
              const OffersSection(),
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
                style: TextStyle(
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
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textTertiary)),
                if (r.warning != null)
                  Text(r.warning!,
                      style: TextStyle(
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
                style: TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
          ]),
        ]),
      ),
    );
  }
}
