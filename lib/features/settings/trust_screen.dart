import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/db/database.dart';
import '../../ui/widgets.dart';

/// Trust Center (design board 13, docs/10). Wording here must match the
/// approved claims; the permission list must match the merged manifest.
class TrustScreen extends ConsumerWidget {
  const TrustScreen({super.key});

  static const _decisions = [
    (
      'No account, no server',
      'Nothing about you exists on the internet, so it can\'t be hacked, leaked or sold.',
      'No sync between devices. Your phone is the only copy.',
    ),
    (
      'No cloud backup',
      'Your data never sits on someone else\'s computer, ours or Google\'s.',
      'If you lose your phone without a backup file stored somewhere else, your data is gone. Weekly backups go to Downloads; copy them off the phone now and then.',
    ),
    (
      'We don\'t read your SMS',
      'Reading every message would give the app access to OTPs and private chats.',
      'You share or copy bank messages yourself. It takes a few taps.',
    ),
    (
      'Only the last 4 digits of your card',
      'Even if someone opened the app, they can\'t use your card.',
      'You can\'t copy your full card number from here.',
    ),
    (
      'Benefit updates are downloaded',
      'Banks change rewards often; stale data would give you wrong advice.',
      'Like any website visit, our server sees your phone\'s internet address (IP), but nothing about you or your cards.',
    ),
  ];

  static const _permissions = [
    ('Internet', 'Download card-benefit updates. Nothing is sent.', 'Always'),
    ('Fingerprint / face', 'Unlock the app', 'If you allow'),
    ('Notifications', 'Bill due dates, fee waivers, backup reminders', 'If you allow'),
    ('Camera', 'Photo of your card face (optional, number blurred)', 'Only when used'),
    ('Run after restart', 'Re-schedule your reminders', 'Always'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final log = ref.watch(_networkLogProvider).value ?? const <NetworkLog>[];
    return Scaffold(
      appBar: AppBar(title: const Text('Trust Center')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          const Tile(
            color: AppColors.earnedContainer,
            border: AppColors.earnedBorder,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OUR PROMISE',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.earned,
                        letterSpacing: 1)),
                SizedBox(height: 8),
                Text('Your card and money data never leaves this phone.',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                SizedBox(height: 8),
                Text(
                    'No account. No ads. No tracking. We have no server that stores anything about you, so there\'s nothing of yours for us to sell, lose or hand over.',
                    style: TextStyle(color: AppColors.textTertiary, height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionTitle('Why we built it this way, and what it costs you'),
          const Caption(
              'Every choice below protects you, and each one has a cost. We\'d rather tell you upfront.'),
          const SizedBox(height: 10),
          Tile(
            padding: EdgeInsets.zero,
            child: Column(children: [
              for (final (i, d) in _decisions.indexed) ...[
                if (i > 0) const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.$1,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      _reason(Pill.earned('WHY'), d.$2),
                      const SizedBox(height: 6),
                      _reason(Pill.attention('COST'), d.$3),
                    ],
                  ),
                ),
              ],
            ]),
          ),
          const SizedBox(height: 22),
          const SectionTitle('Permissions, and exactly why'),
          Tile(
            padding: EdgeInsets.zero,
            child: Column(children: [
              for (final p in _permissions)
                ListTile(
                  title: Text(p.$1,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(p.$2),
                  trailing: Text(p.$3,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                ),
            ]),
          ),
          const SizedBox(height: 8),
          const Tile(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Never asked for',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Caption(
                    'SMS, contacts, location, call logs, notification access, accessibility, photos/gallery. If an update ever asks for one of these, something is wrong. Please tell us.'),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionTitle('Every connection this app made'),
          if (log.isEmpty)
            const Caption(
                'None in the last 90 days. Benefit updates aren\'t switched on yet, so the app hasn\'t connected anywhere.')
          else
            Tile(
              padding: EdgeInsets.zero,
              child: Column(children: [
                for (final e in log)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.download_outlined,
                        color: AppColors.earned, size: 18),
                    title: Text('${e.method} ${Uri.parse(e.url).host}${Uri.parse(e.url).path}',
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 12)),
                    subtitle: Text(
                        '${DateFormat('d MMM, HH:mm').format(e.at)} · ${(e.bytes / 1024).toStringAsFixed(1)} KB · ${e.status}'),
                  ),
              ]),
            ),
          const SizedBox(height: 8),
          const Caption(
              'Only downloads. Nothing is uploaded. Purchases (when available) are handled by the Google Play app, not us.'),
          const SizedBox(height: 22),
          const Tile(
            color: AppColors.primaryContainerLow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Don't just trust us. Check.",
                    style: TextStyle(fontWeight: FontWeight.w800)),
                SizedBox(height: 6),
                Text(
                    'Android Settings → Apps → Card Master → Permissions shows the same list as above. The Play Store\'s Data safety section and our one-page privacy policy say the same thing in plain language.',
                    style: TextStyle(color: Color(0xFFD4CCFF), height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reason(Widget tag, String text) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          tag,
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textTertiary, height: 1.45)),
          ),
        ],
      );
}

final _networkLogProvider = StreamProvider<List<NetworkLog>>(
  (ref) => ref.watch(databaseProvider).watchNetworkLog(),
);
