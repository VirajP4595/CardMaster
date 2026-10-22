import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../domain/models.dart';
import '../domain/sms_parser.dart';
import 'providers.dart';

/// Values handed to the quick-add screen from a shared or copied SMS.
class QuickAddPrefill {
  const QuickAddPrefill({
    this.amountPaise,
    this.category,
    this.cardId,
    this.merchant,
    this.date,
    this.viaUpi = false,
    this.international = false,
    this.availableLimitPaise,
    this.source = 'MANUAL',
  });

  final int? amountPaise;
  final SpendCategory? category;
  final String? cardId;
  final String? merchant;
  final DateTime? date;
  final bool viaUpi;
  final bool international;
  final int? availableLimitPaise;
  final String source;
}

/// Turns a parsed SMS into quick-add values, matching the card by last 4
/// and the category by merchant memory (docs/08 §3).
Future<QuickAddPrefill> prefillFrom(
  WidgetRef ref,
  ParsedSpend p, {
  required String source,
}) async {
  final cards = ref.read(cardsProvider).value ?? const <UserCard>[];
  final card = cards.where((c) => c.last4 != null && c.last4 == p.last4);
  final db = ref.read(databaseProvider);
  final category =
      p.merchant == null ? null : await db.categoryFor(p.merchant!);
  return QuickAddPrefill(
    amountPaise: p.amountPaise,
    category: category,
    cardId: card.firstOrNull?.id,
    merchant: p.merchant,
    date: p.date,
    viaUpi: p.viaUpi,
    international: p.international,
    availableLimitPaise: p.availableLimitPaise,
    source: source,
  );
}

/// Starts listening for "Share to Card Master" and checks the clipboard.
/// Neither needs any permission.
void startIntake(BuildContext context, WidgetRef ref) {
  final sharing = ReceiveSharingIntent.instance;

  Future<void> handleShared(List<SharedMediaFile> files) async {
    final text = files
        .where((f) => f.type == SharedMediaType.text || f.type == SharedMediaType.url)
        .map((f) => f.path)
        .join('\n\n');
    if (text.trim().isEmpty || !context.mounted) return;
    await _openFor(context, ref, text, source: 'SHARE');
    await sharing.reset();
  }

  sharing.getInitialMedia().then(handleShared).catchError((_) {});
  sharing.getMediaStream().listen(handleShared, onError: (_) {});

  checkClipboard(context, ref);
  AppLifecycleListener(onResume: () {
    if (context.mounted) checkClipboard(context, ref);
  });
}

Future<void> _openFor(
  BuildContext context,
  WidgetRef ref,
  String text, {
  required String source,
}) async {
  final spends = parseMany(text);
  if (!context.mounted) return;
  if (spends.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("No card spend found in that message.")));
  } else if (spends.length == 1) {
    final prefill = await prefillFrom(ref, spends.single, source: source);
    if (context.mounted) context.push('/quick-add', extra: prefill);
  } else {
    context.push('/import', extra: text);
  }
}

/// Offers to add bank messages found in the clipboard, once per clipboard
/// content. Android 12+ shows its own "pasted" notice, which is expected.
Future<void> checkClipboard(BuildContext context, WidgetRef ref) async {
  final data = await Clipboard.getData(Clipboard.kTextPlain);
  final text = data?.text ?? '';
  if (text.isEmpty) return;
  final spends = parseMany(text);
  if (spends.isEmpty) return;
  final db = ref.read(databaseProvider);
  final hash = text.hashCode.toString();
  if (await db.getValue(SettingKeys.lastClipboardHash) == hash) return;
  await db.setValue(SettingKeys.lastClipboardHash, hash);
  if (!context.mounted) return;
  final n = spends.length;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: const Duration(seconds: 8),
    content: Text(n == 1
        ? 'Found a bank message in your clipboard.'
        : 'Found $n bank messages in your clipboard.'),
    action: SnackBarAction(
      label: 'Add',
      onPressed: () => _openFor(context, ref, text, source: 'CLIPBOARD'),
    ),
  ));
}
