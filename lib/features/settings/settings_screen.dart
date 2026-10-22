import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/services.dart';
import '../../app/theme.dart';
import '../../data/backup/backup.dart';
import '../../ui/widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final catalog = ref.watch(catalogProvider);
    final now = DateTime.now();
    final toVerify = catalog.products
        .expand((p) => p.benefits)
        .where((b) => b.isStale(now))
        .length;
    final lastBackup =
        ref.watch(settingProvider(SettingKeys.lastBackupAt)).value;
    final backupAge = lastBackup == null
        ? null
        : now.difference(DateTime.parse(lastBackup)).inDays;

    Widget toggle(String key, String title, String subtitle,
            {bool fallback = true, Future<void> Function(bool)? also}) =>
        SwitchListTile(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle,
              style: const TextStyle(color: AppColors.textSecondary)),
          value: settingOn(ref, key, fallback: fallback),
          onChanged: (v) async {
            await db.setValue(key, '$v');
            await also?.call(v);
          },
        );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          children: [
            const Text('Settings',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Tile(
              color: AppColors.earnedContainer,
              border: AppColors.earnedBorder,
              onTap: () => context.push('/trust'),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.verified_user_outlined, color: AppColors.earned),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your data never leaves this phone',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        SizedBox(height: 4),
                        Caption(
                            'The app only downloads card-benefit updates and never uploads anything. No account, no tracking, no ads.',
                            color: AppColors.textTertiary),
                        SizedBox(height: 6),
                        Text('Why we built it this way →',
                            style: TextStyle(
                                color: AppColors.earned,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const _Header('Security'),
            Tile(
              padding: EdgeInsets.zero,
              child: Column(children: [
                toggle(SettingKeys.lockEnabled, 'App lock',
                    'Fingerprint, face or device PIN. Locks again after 30 seconds away.'),
                toggle(SettingKeys.screenshotsBlocked, 'Block screenshots',
                    'Also hides the app in recent apps',
                    also: setScreenSecure),
              ]),
            ),
            const _Header('Money'),
            Tile(
              padding: EdgeInsets.zero,
              child: toggle(SettingKeys.rewardHints, 'Show card reward hints',
                  'For UPI and cash expenses, show what a card would have earned'),
            ),
            const _Header('Benefits'),
            Tile(
              child: Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Benefits list v${catalog.version}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Caption(
                          '${catalog.products.length} cards · ${catalog.banks.length} banks · updates download automatically when available'),
                    ],
                  ),
                ),
                if (toVerify > 0) Pill.attention('$toVerify to verify'),
              ]),
            ),
            const _Header('Backup'),
            Tile(
              color: backupAge == null || backupAge >= 30
                  ? AppColors.attentionContainer
                  : AppColors.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    backupAge == null
                        ? 'No backup yet'
                        : backupAge == 0
                            ? 'Last backup: today'
                            : 'Last backup: $backupAge days ago',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  const Caption(
                      'A passphrase-protected file you save wherever you like. It\'s the only way to move to a new phone or recover a lost one. We can\'t recover it for you.',
                      color: AppColors.textTertiary),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () => _export(context, ref),
                        child: const Text('Export'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52)),
                        onPressed: () => _restore(context, ref),
                        child: const Text('Restore'),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
            const _Header('About'),
            Tile(
              padding: EdgeInsets.zero,
              child: Column(children: [
                ListTile(
                  title: const Text('Trust Center'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/trust'),
                ),
                ListTile(
                  title: const Text('Open-source licences'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showLicensePage(
                      context: context, applicationName: 'Card Master'),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _askPassphrase(BuildContext context,
      {required bool confirm}) {
    final a = TextEditingController();
    final b = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) {
          final mismatch = confirm && b.text.isNotEmpty && a.text != b.text;
          final ok = a.text.length >= 8 && (!confirm || a.text == b.text);
          return AlertDialog(
            title: Text(confirm ? 'Protect your backup' : 'Backup passphrase'),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              if (confirm)
                const Text(
                    'You\'ll need this passphrase to restore. If you forget it, the backup can\'t be opened, by anyone.'),
              TextField(
                controller: a,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'Passphrase', helperText: 'At least 8 characters'),
                onChanged: (_) => set(() {}),
              ),
              if (confirm)
                TextField(
                  controller: b,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Repeat passphrase',
                    errorText: mismatch ? 'Doesn\'t match' : null,
                  ),
                  onChanged: (_) => set(() {}),
                ),
            ]),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel')),
              TextButton(
                onPressed: ok ? () => Navigator.pop(ctx, a.text) : null,
                child: const Text('Continue'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final pass = await _askPassphrase(context, confirm: true);
    if (pass == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final db = ref.read(databaseProvider);
    try {
      final bytes = await createBackup(db, pass);
      final saved = await FilePicker.saveFile(
        dialogTitle: 'Save backup',
        fileName: backupFileName(DateTime.now()),
        bytes: bytes,
      );
      if (saved == null) return;
      await db.setValue(
          SettingKeys.lastBackupAt, DateTime.now().toIso8601String());
      messenger.showSnackBar(
          const SnackBar(content: Text('Backup saved. Keep the passphrase safe.')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Backup failed: $e')));
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final picked = await FilePicker.pickFiles();
    if (picked.isEmpty || !context.mounted) return;
    final bytes = await picked.single.readAsBytes();
    if (!context.mounted) return;
    final sure = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Replace everything?'),
        content: const Text(
            'Restoring replaces all cards and expenses on this phone with the backup.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Replace')),
        ],
      ),
    );
    if (sure != true || !context.mounted) return;
    final pass = await _askPassphrase(context, confirm: false);
    if (pass == null) return;
    try {
      await restoreBackup(ref.read(databaseProvider), pass, bytes);
      messenger.showSnackBar(const SnackBar(content: Text('Backup restored.')));
    } on BackupException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 8),
        child: Text(text.toUpperCase(),
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 1)),
      );
}
