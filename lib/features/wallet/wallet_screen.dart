import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/catalog/catalog.dart';
import '../../domain/billing_cycle.dart';
import '../../domain/models.dart';
import '../../domain/money.dart';
import '../../ui/card_face.dart';
import '../../ui/widgets.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(cardsProvider).value ?? const <UserCard>[];
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add',
        onPressed: () => _addMenu(context),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 100),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wordmark(),
                      SizedBox(height: 2),
                      Text('Your wallet',
                          style: TextStyle(
                              fontSize: 26, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'Trust Center',
                  onPressed: () => context.push('/trust'),
                  icon: const Icon(Icons.shield_outlined),
                ),
              ]),
            ),
            const SizedBox(height: 18),
            if (cards.isEmpty)
              const _EmptyWallet()
            else ...[
              _Summary(cards: cards),
              const SizedBox(height: 18),
              _Carousel(cards: cards),
              const SizedBox(height: 18),
              const _NeedsAttention(),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Tile(
                  color: AppColors.primaryContainerLow,
                  onTap: () => context.go('/best'),
                  child: const Row(children: [
                    Icon(Icons.star_outline,
                        color: AppColors.onPrimaryContainer),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Which card should I use?',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          Text('Pick a category, get the best return',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.onPrimaryContainer)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right),
                  ]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _addMenu(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        backgroundColor: AppColors.surfaceHigh,
        builder: (ctx) => SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Add expense'),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/quick-add');
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Add card'),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/add-card');
              },
            ),
          ]),
        ),
      );
}

class _EmptyWallet extends StatelessWidget {
  const _EmptyWallet();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Tile(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const BrandMark(size: 96, cutout: AppColors.surface),
            const SizedBox(height: 12),
            const Text('Add your first card',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text(
              'See what it\'s good for, and which card to use for every spend.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () => context.push('/add-card'),
              child: const Text('Add card'),
            ),
          ]),
        ),
      );
}

class _Summary extends StatelessWidget {
  const _Summary({required this.cards});
  final List<UserCard> cards;

  @override
  Widget build(BuildContext context) {
    final limit = cards.fold<int>(0, (s, c) => s + c.creditLimitPaise);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Tile(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('TOTAL CREDIT LIMIT',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    letterSpacing: 1)),
            const SizedBox(height: 4),
            Row(children: [
              Expanded(
                child: Text(formatInr(limit),
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.w800)),
              ),
              Text('${cards.length} card${cards.length == 1 ? '' : 's'}',
                  style: const TextStyle(color: AppColors.textSecondary)),
            ]),
          ],
        ),
      ),
    );
  }
}

class _Carousel extends ConsumerWidget {
  const _Carousel({required this.cards});
  final List<UserCard> cards;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    return SizedBox(
      height: 210,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.86),
        itemCount: cards.length,
        itemBuilder: (context, i) {
          final c = cards[i];
          final style =
              catalog.product(c.productId)?.face ?? const CardFaceStyle();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: GestureDetector(
              onTap: () => context.push('/card/${c.id}'),
              child: Semantics(
                button: true,
                label: 'Open ${c.displayName}',
                child: Hero(
                  tag: 'card-${c.id}',
                  child: CardFace(card: c, style: style),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NeedsAttention extends ConsumerWidget {
  const _NeedsAttention();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(cardsProvider).value ?? const <UserCard>[];
    final today = DateTime.now();
    final items = <Widget>[];

    for (final c in cards) {
      final due = nextDueDate(c, today);
      final days = DateTime(due.year, due.month, due.day)
          .difference(DateTime(today.year, today.month, today.day))
          .inDays;
      if (days <= 5) {
        items.add(_item(
          context,
          lead: _DaysBadge(days),
          title: '${c.displayName} bill due',
          subtitle: days == 0 ? 'Due today' : 'Due on ${due.day}/${due.month}',
          onTap: () => context.push('/card/${c.id}'),
        ));
      }
      final waiver = ref.watch(feeWaiverProvider(c.id));
      if (waiver != null && !waiver.achieved && waiver.daysLeft <= 120) {
        items.add(_item(
          context,
          lead: ProgressRing(value: waiver.progress, size: 52),
          title: '${c.displayName} fee waiver',
          subtitle:
              'Spend ${formatInr(waiver.remainingPaise)} more in ${waiver.daysLeft} days to skip the ${formatInr(c.annualFeePaise)} fee',
          onTap: () => context.push('/card/${c.id}'),
        ));
      }
    }

    final lastBackup =
        ref.watch(settingProvider(SettingKeys.lastBackupAt)).value;
    final backupAge = lastBackup == null
        ? null
        : today.difference(DateTime.parse(lastBackup)).inDays;
    if (backupAge == null || backupAge >= 30) {
      items.add(_item(
        context,
        lead: const Icon(Icons.download_outlined, color: AppColors.attention),
        title: 'Back up now',
        subtitle: backupAge == null
            ? 'You haven\'t made a backup yet'
            : 'Last backup $backupAge days ago',
        onTap: () => context.go('/settings'),
      ));
    }

    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionTitle('Needs attention'),
          for (final w in items.take(3))
            Padding(padding: const EdgeInsets.only(bottom: 8), child: w),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context, {
    required Widget lead,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) =>
      Tile(
        padding: const EdgeInsets.all(14),
        onTap: onTap,
        child: Row(children: [
          SizedBox(width: 52, child: Center(child: lead)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Caption(subtitle),
              ],
            ),
          ),
        ]),
      );
}

class _DaysBadge extends StatelessWidget {
  const _DaysBadge(this.days);
  final int days;

  @override
  Widget build(BuildContext context) => Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.dangerContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$days',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dangerText)),
            Text(days == 1 ? 'DAY' : 'DAYS',
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dangerText)),
          ],
        ),
      );
}
