import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/add_card/add_card_screen.dart';
import '../features/best_card/best_card_screen.dart';
import '../features/card_detail/card_detail_screen.dart';
import '../features/card_detail/compare_and_close.dart';
import '../features/card_detail/photo_face_screen.dart';
import '../features/card_detail/worth_screen.dart';
import '../features/money/import_review_screen.dart';
import '../features/money/money_screen.dart';
import '../features/money/quick_add_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/settings/pro_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/settings/trust_screen.dart';
import '../features/wallet/wallet_screen.dart';
import 'intake.dart';
import 'providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final db = ref.watch(databaseProvider);
  return GoRouter(
    initialLocation: '/wallet',
    redirect: (context, state) async {
      final done = await db.getValue(SettingKeys.onboardingDone);
      if (done != 'true' && state.matchedLocation != '/welcome') {
        return '/welcome';
      }
      return null;
    },
    routes: [
      GoRoute(
          path: '/welcome', builder: (_, _) => const OnboardingScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _Shell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/wallet', builder: (_, _) => const WalletScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/best', builder: (_, _) => const BestCardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/money', builder: (_, _) => const MoneyScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/settings', builder: (_, _) => const SettingsScreen()),
          ]),
        ],
      ),
      GoRoute(
        path: '/card/:id',
        builder: (_, s) => CardDetailScreen(cardId: s.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'worth',
            builder: (_, s) => WorthScreen(cardId: s.pathParameters['id']!),
          ),
          GoRoute(
            path: 'compare',
            builder: (_, s) => CompareScreen(firstId: s.pathParameters['id']!),
          ),
          GoRoute(
            path: 'photo',
            builder: (_, s) => PhotoFaceScreen(cardId: s.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(path: '/add-card', builder: (_, _) => const AddCardScreen()),
      GoRoute(
        path: '/quick-add',
        builder: (_, s) => QuickAddScreen(prefill: s.extra as QuickAddPrefill?),
      ),
      GoRoute(
        path: '/import',
        builder: (_, s) => ImportReviewScreen(
          payload: s.extra is ImportPayload
              ? s.extra! as ImportPayload
              : ImportPayload.fromText(s.extra as String? ?? ''),
        ),
      ),
      GoRoute(path: '/trust', builder: (_, _) => const TrustScreen()),
      GoRoute(path: '/pro', builder: (_, _) => const ProScreen()),
    ],
  );
});

class _Shell extends ConsumerStatefulWidget {
  const _Shell({required this.shell});
  final StatefulNavigationShell shell;

  @override
  ConsumerState<_Shell> createState() => _ShellState();
}

class _ShellState extends ConsumerState<_Shell> {
  @override
  void initState() {
    super.initState();
    // Bank SMS shared from the messages app, and clipboard pick-up.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startIntake(context, ref);
      _listenForShortcuts();
    });
  }

  /// Quick Settings tile and home-screen widget open the app on a route
  /// (see MainActivity: only /quick-add and /best are accepted).
  Future<void> _listenForShortcuts() async {
    const channel = MethodChannel('cardmaster/launch');
    void open(String? route) {
      if (!mounted || route == null) return;
      if (route == '/best') {
        widget.shell.goBranch(1);
      } else if (route == '/quick-add') {
        GoRouter.of(context).push('/quick-add');
      }
    }

    channel.setMethodCallHandler((call) async {
      if (call.method == 'open') open(call.arguments as String?);
    });
    try {
      open(await channel.invokeMethod<String>('initialRoute'));
    } on MissingPluginException {
      // Tests and non-Android platforms.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.shell.currentIndex,
        onDestinationSelected: (i) => widget.shell
            .goBranch(i, initialLocation: i == widget.shell.currentIndex),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet),
              label: 'Wallet'),
          NavigationDestination(
              icon: Icon(Icons.star_outline),
              selectedIcon: Icon(Icons.star),
              label: 'Best card'),
          NavigationDestination(
              icon: Icon(Icons.show_chart),
              selectedIcon: Icon(Icons.show_chart),
              label: 'Money'),
          NavigationDestination(
              icon: Icon(Icons.tune),
              selectedIcon: Icon(Icons.tune),
              label: 'Settings'),
        ],
      ),
    );
  }
}
