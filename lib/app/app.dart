import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/reminders.dart';
import 'lock_gate.dart';
import 'providers.dart';
import 'reminders_service.dart';
import 'router.dart';
import 'theme.dart';

/// Keeps scheduled reminders in step with cards, spends and backups.
final reminderSyncProvider = Provider<void>((ref) {
  final enabled =
      ref.watch(settingProvider(SettingKeys.remindersEnabled)).value == 'true';
  final cards = ref.watch(cardsProvider).value;
  final spends = ref.watch(spendsProvider).value;
  final lastBackup = ref.watch(settingProvider(SettingKeys.lastBackupAt)).value;
  final points = ref.watch(pointsProvider).value ?? const [];
  if (cards == null || spends == null) return;
  if (!enabled) {
    RemindersService.instance.cancelAll();
    return;
  }
  RemindersService.instance.reschedule(
    planReminders(
      cards: cards,
      spends: spends,
      now: DateTime.now(),
      lastBackup: lastBackup == null ? null : DateTime.parse(lastBackup),
      points: points,
    ),
  );
});

class CardMasterApp extends ConsumerWidget {
  const CardMasterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(reminderSyncProvider);
    final mode = switch (ref
        .watch(settingProvider(SettingKeys.themeMode))
        .value) {
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };
    return MaterialApp.router(
      title: 'Card Master',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: mode,
      // Screens read AppColors directly, so the switch has to be instant.
      themeAnimationDuration: Duration.zero,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) {
        syncPalette(context);
        return LockGate(child: child ?? const SizedBox());
      },
    );
  }
}

/// Turns reminders on after asking Android for permission. Returns whether
/// they ended up on.
Future<bool> enableReminders(WidgetRef ref) async {
  final granted = await RemindersService.instance.requestPermission();
  await ref
      .read(databaseProvider)
      .setValue(SettingKeys.remindersEnabled, '$granted');
  return granted;
}
