import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../ui/widgets.dart';

/// First launch: three honest screens (design board 0, docs/10 §2).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _Step {
  const _Step(this.title, this.icon, this.fg, this.bg, this.points);
  final String title;
  final IconData icon;
  final Color fg;
  final Color bg;
  final List<String> points;
}

const _steps = [
  _Step(
    'Your data stays on this phone.',
    Icons.verified_user_outlined,
    AppColors.earned,
    AppColors.earnedContainer,
    [
      'No account to create. No ads. No tracking.',
      'We have no server that stores anything about you, so there\'s nothing of yours for us to sell or lose.',
      'We only ask for the last 4 digits of a card, never the full number or CVV.',
    ],
  ),
  _Step(
    'Honest trade-offs.',
    Icons.balance_outlined,
    AppColors.attention,
    AppColors.attentionContainer,
    [
      'We don\'t read your SMS. You share or copy bank messages in a few taps.',
      'We don\'t sync to the cloud. This phone holds the only copy.',
      'The app goes online only to download card-benefit updates. Nothing is ever uploaded.',
    ],
  ),
  _Step(
    'Keep a backup. Seriously.',
    Icons.download_outlined,
    AppColors.onPrimaryContainer,
    AppColors.primaryContainerLow,
    [
      'If you lose your phone without a backup, your data is gone. We can\'t recover it, because we never had it.',
      'Settings → Backup saves a passphrase-protected file wherever you choose.',
      'Moving to a new phone? Your backup file is the way.',
    ],
  ),
];

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _i = 0;

  Future<void> _next() async {
    if (_i < _steps.length - 1) {
      setState(() => _i++);
      return;
    }
    await ref
        .read(databaseProvider)
        .setValue(SettingKeys.onboardingDone, 'true');
    if (mounted) context.go('/wallet');
  }

  @override
  Widget build(BuildContext context) {
    final s = _steps[_i];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const StackedWordmark(scale: 0.5),
                const Spacer(),
                Text('${_i + 1} of 3',
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700)),
              ]),
              const Spacer(),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                    color: s.bg, borderRadius: BorderRadius.circular(22)),
                child: Icon(s.icon, color: s.fg, size: 36),
              ),
              const SizedBox(height: 18),
              Text(s.title,
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.2)),
              const SizedBox(height: 18),
              for (final p in s.points)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8, right: 12),
                        child: CircleAvatar(radius: 3, backgroundColor: s.fg),
                      ),
                      Expanded(
                        child: Text(p,
                            style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.textTertiary,
                                height: 1.5)),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var n = 0; n < _steps.length; n++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: n == _i ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: n == _i
                            ? AppColors.textPrimary
                            : const Color(0xFF4A4E60),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _next,
                child: Text(_i == _steps.length - 1 ? 'Get started' : 'Next'),
              ),
              Center(
                child: TextButton(
                  onPressed: () => context.push('/trust'),
                  child: const Text('Read the full details in the Trust Center'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
