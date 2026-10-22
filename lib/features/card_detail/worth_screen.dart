import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../domain/card_value.dart';
import '../../domain/models.dart';
import '../../domain/money.dart';
import '../../ui/widgets.dart';

/// "Is this card worth keeping?" (design board 9).
class WorthScreen extends ConsumerWidget {
  const WorthScreen({super.key, required this.cardId});
  final String cardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = ref.watch(cardProvider(cardId));
    if (card == null) return Scaffold(appBar: AppBar());
    final benefits = ref.watch(benefitsForCardProvider(cardId));
    final spends = ref.watch(spendsProvider).value ?? const <Spend>[];
    final v = cardYearValue(card, benefits, spends, DateTime.now());
    final fmt = DateFormat('MMM yyyy');
    final (label, fg, bg, line) = switch (v.verdict) {
      Verdict.keep => (
          'KEEP',
          AppColors.earned,
          AppColors.earnedContainer,
          'It pays for itself.'
        ),
      Verdict.borderline => (
          'BORDERLINE',
          AppColors.attention,
          AppColors.attentionContainer,
          'Barely covers its fee. Ask the bank for a fee waiver or a lifetime-free version.'
        ),
      Verdict.reconsider => (
          'RECONSIDER',
          AppColors.dangerText,
          AppColors.dangerContainer,
          'It costs more than it earns. Consider downgrading or closing it (pay dues and redeem points first).'
        ),
    };

    Widget row(String l, int paise, {String? note, bool minus = false}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(children: [
            Expanded(
              child: Text.rich(TextSpan(children: [
                TextSpan(text: l),
                if (note != null)
                  TextSpan(
                      text: '  $note',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
              ])),
            ),
            Text('${minus ? '−' : '+'}${formatInr(paise)}',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: minus ? AppColors.dangerText : AppColors.earned)),
          ]),
        );

    return Scaffold(
      appBar: AppBar(title: Text('Is ${card.displayName} worth it?')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          Caption('Card year ${fmt.format(v.from)} – ${fmt.format(v.to)}'),
          const SizedBox(height: 10),
          Tile(
            color: bg,
            child: Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Caption('Net value this year'),
                    Text(
                        '${v.netPaise < 0 ? '' : '+'}${formatInr(v.netPaise)}',
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.w800, color: fg)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                    color: fg, borderRadius: BorderRadius.circular(14)),
                child: Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.background)),
              ),
            ]),
          ),
          const SizedBox(height: 8),
          Text(line, style: const TextStyle(color: AppColors.textTertiary)),
          const SizedBox(height: 14),
          Tile(
            child: Column(children: [
              row('Rewards earned', v.rewardsPaise,
                  note: 'on ${formatInr(v.spentPaise)} spent'),
              row('Annual fee', v.feePaise,
                  minus: true,
                  note: v.feeWaived
                      ? 'waived'
                      : card.annualFeePaise == 0
                          ? 'free card'
                          : null),
              row('Forex markup paid', v.forexPaidPaise, minus: true),
            ]),
          ),
          const SizedBox(height: 12),
          const Caption(
              'Based on the card spends you logged and this card\'s benefits (check sample rates). Lounge visits, insurance and other perks aren\'t counted yet.'),
        ],
      ),
    );
  }
}
