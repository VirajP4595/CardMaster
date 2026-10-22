import 'dart:async';
import 'dart:io';

import 'package:card_master/app/providers.dart';
import 'package:card_master/app/theme.dart';
import 'package:card_master/data/catalog/catalog.dart';
import 'package:card_master/data/db/database.dart';
import 'package:card_master/data/photo_face.dart';
import 'package:card_master/domain/models.dart';
import 'package:card_master/domain/recurring.dart';
import 'package:card_master/domain/trackers.dart';
import 'package:card_master/features/best_card/best_card_screen.dart';
import 'package:card_master/features/card_detail/card_detail_screen.dart';
import 'package:card_master/features/card_detail/worth_screen.dart';
import 'package:card_master/features/money/import_review_screen.dart';
import 'package:card_master/features/money/money_screen.dart';
import 'package:card_master/features/money/quick_add_screen.dart';
import 'package:card_master/features/settings/pro_screen.dart';
import 'package:card_master/features/settings/trust_screen.dart';
import 'package:card_master/features/wallet/wallet_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

final _catalog = Catalog.fromJsonString(
    File('assets/catalog/catalog_v1.json').readAsStringSync());

UserCard _card(String id, String product, CardNetwork n, int color,
        {int fee = 0, int? waiver, int? month, String? last4}) =>
    UserCard(
      id: id,
      productId: product,
      bankName: _catalog.bank(_catalog.product(product)!.bankId)!.name,
      name: _catalog.product(product)!.name,
      network: n,
      last4: last4,
      creditLimitPaise: 25000000,
      statementDay: 12,
      dueDay: 2,
      annualFeePaise: fee,
      waiverSpendPaise: waiver,
      anniversaryMonth: month,
      faceColor: color,
    );

Future<AppDatabase> _seed({bool withCards = true}) async {
  final db = AppDatabase(NativeDatabase.memory());
  if (withCards) {
    await db.upsertCard(_card('airtel', 'axis_airtel', CardNetwork.mastercard,
        0xFF9E1233,
        fee: 50000, waiver: 20000000, month: 1, last4: '7302'));
    await db.upsertCard(
        _card('scapia', 'federal_scapia', CardNetwork.visa, 0xFF0F4A4B));
    await db.upsertCard(_card(
        'neu', 'hdfc_tataneu_infinity', CardNetwork.rupay, 0xFF141418));
  }
  return db;
}

Future<void> _pump(WidgetTester t, AppDatabase db, Widget screen,
    {PhotoStore? photos}) async {
  await t.binding.setSurfaceSize(const Size(400, 3200));
  await t.pumpWidget(ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      catalogProvider.overrideWith(() => CatalogNotifier(_catalog)),
      if (photos != null) photoStoreProvider.overrideWithValue(photos),
    ],
    child: MaterialApp(theme: buildTheme(), home: screen),
  ));
  await _settle(t);
}

/// Lets drift queries and streams finish: real time for the database work,
/// fake time so drift's own timers fire.
Future<void> _settle(WidgetTester t) async {
  for (var i = 0; i < 10; i++) {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await t.pump(const Duration(milliseconds: 20));
  }
}

Future<void> _close(WidgetTester t, AppDatabase db) async {
  // Unmount first so drift stream subscriptions are cancelled, then let
  // drift's internal timers run out before the test ends.
  await t.pumpWidget(const SizedBox());
  await t.pump(const Duration(seconds: 1));
  unawaited(db.close());
  await t.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets('wallet shows the empty state without cards', (t) async {
    final db = await t.runAsync(() => _seed(withCards: false));
    await _pump(t, db!, const WalletScreen());
    expect(find.text('Add your first card'), findsOneWidget);
    await _close(t, db);
  });

  testWidgets('wallet shows total limit and fee waiver', (t) async {
    final db = await t.runAsync(_seed);
    await _pump(t, db!, const WalletScreen());
    expect(find.text('₹7,50,000'), findsOneWidget);
    expect(find.textContaining('fee waiver'), findsOneWidget);
    expect(find.text('Back up now'), findsOneWidget);
    await _close(t, db);
  });

  testWidgets('best card ranks Airtel Axis first for utilities', (t) async {
    final db = await t.runAsync(_seed);
    await _pump(t, db!, const BestCardScreen());
    expect(find.text('RANKED FOR YOU'), findsOneWidget);
    // ₹2,400 at 10% = ₹240 on Airtel Axis.
    expect(find.text('₹240'), findsOneWidget);
    expect(find.text('Pay today with…'), findsOneWidget);

    await t.tap(find.text('UPI'));
    await t.pump();
    expect(find.text('Only RuPay credit cards work on UPI'), findsNWidgets(2));
    await _close(t, db);
  });

  testWidgets('card detail shows stats and benefits', (t) async {
    final db = await t.runAsync(_seed);
    await _pump(t, db!, const CardDetailScreen(cardId: 'airtel'));
    expect(find.text('Benefits'), findsOneWidget);
    expect(find.text('Airtel bills'), findsNWidgets(2)); // caps + benefits
    expect(find.text('Fee waiver progress'), findsOneWidget);
    expect(find.text('Verify'), findsWidgets);
    await _close(t, db);
  });

  testWidgets('quick add keypad and reward hint', (t) async {
    final db = await t.runAsync(_seed);
    await _pump(t, db!, const QuickAddScreen());
    await t.tap(find.text('4'));
    await t.tap(find.text('5'));
    await t.tap(find.text('0'));
    await t.pump();
    expect(find.text('₹450'), findsOneWidget);
    // Food delivery: Airtel Axis 10% = ₹45 is the default best pick.
    expect(find.textContaining('Best choice: earns ₹45'), findsOneWidget);

    await t.tap(find.text('Cash'));
    await t.pump();
    expect(find.textContaining('would earn ₹45'), findsOneWidget);

    await t.tap(find.text('Save ₹450'));
    for (var i = 0; i < 5; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await t.pump();
    }
    expect(find.text('Saved ✓  Add another'), findsOneWidget);
    final spends = await t.runAsync(db.allSpends);
    expect(spends!.single.paymentKind, PaymentKind.cash);
    await _close(t, db);
  });

  testWidgets('money tab shows the missed-reward insight', (t) async {
    final db = await t.runAsync(_seed);
    await t.runAsync(() => db!.addSpend(Spend(
          id: 's1',
          amountPaise: 100000,
          category: SpendCategory.foodDelivery,
          paymentKind: PaymentKind.cash,
          spentOn: DateTime.now(),
        )));
    await _pump(t, db!, const MoneyScreen());
    expect(find.textContaining('would have earned ₹100'), findsOneWidget);
    await _close(t, db);
  });

  testWidgets('money tab shows budgets, flagging overspend', (t) async {
    final db = await t.runAsync(_seed);
    await t.runAsync(() async {
      await db!.setBudget(SpendCategory.dining, 100000);
      await db.addSpend(Spend(
        id: 's2',
        amountPaise: 150000,
        category: SpendCategory.dining,
        paymentKind: PaymentKind.card,
        userCardId: 'scapia',
        spentOn: DateTime.now(),
      ));
    });
    await _pump(t, db!, const MoneyScreen());
    expect(find.text('Budgets this month'), findsOneWidget);
    expect(find.text(' / ₹1,000 · over'), findsOneWidget);
    await _close(t, db);
  });

  testWidgets('card detail offers the lost-card helpline', (t) async {
    final db = await t.runAsync(_seed);
    await _pump(t, db!, const CardDetailScreen(cardId: 'airtel'));
    expect(find.text('Lost this card?'), findsOneWidget);
    expect(find.textContaining("Add your bank's helpline"), findsOneWidget);
    await t.runAsync(() => db.setHelpline('airtel', '1860 419 5555'));
    for (var i = 0; i < 5; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await t.pump();
    }
    expect(find.textContaining('Call Axis Bank to block it'), findsOneWidget);
    await _close(t, db);
  });

  testWidgets('worth-it report and caps reflect logged spends', (t) async {
    final db = await t.runAsync(_seed);
    await t.runAsync(() => db!.addSpend(Spend(
          id: 'u1',
          amountPaise: 300000,
          category: SpendCategory.utilities,
          paymentKind: PaymentKind.card,
          userCardId: 'airtel',
          spentOn: DateTime.now(),
        )));
    await _pump(t, db!, const CardDetailScreen(cardId: 'airtel'));
    expect(find.text("This month's caps"), findsOneWidget);
    expect(find.text('₹250 / ₹250 · full'), findsOneWidget);
    await _close(t, db);

    final db2 = await t.runAsync(_seed);
    await t.runAsync(() => db2!.addSpend(Spend(
          id: 'u1',
          amountPaise: 300000,
          category: SpendCategory.utilities,
          paymentKind: PaymentKind.card,
          userCardId: 'airtel',
          spentOn: DateTime.now(),
        )));
    await _pump(t, db2!, const WorthScreen(cardId: 'airtel'));
    // ₹250 reward − ₹500 fee (not waived) = −₹250.
    expect(find.text('−₹250'), findsOneWidget);
    expect(find.text('RECONSIDER'), findsOneWidget);
    await _close(t, db2);
  });

  testWidgets('import review matches cards and imports ticked rows', (t) async {
    final db = await t.runAsync(_seed);
    await _pump(
      t,
      db!,
      ImportReviewScreen(
        payload: ImportPayload.fromText('''
INR 2,400.00 spent on Credit Card XX7302 at BESCOM on 21-10-26.

Rs.900 spent on card XX5566 at UNKNOWN SHOP on 20-10-26.

123456 is your OTP. Do not share.
'''),
      ),
    );
    expect(find.text('Import 1 expense'), findsWidgets);
    expect(find.textContaining('not in wallet'), findsOneWidget);
    await t.tap(find.widgetWithText(FilledButton, 'Import 1 expense'));
    for (var i = 0; i < 5; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await t.pump();
    }
    final spends = await t.runAsync(db.allSpends);
    expect(spends!.single.userCardId, 'airtel');
    expect(spends.single.amountPaise, 240000);
    await _close(t, db);
  });

  testWidgets('recurring expense that asks first shows Add / Skip', (t) async {
    final db = await t.runAsync(_seed);
    final now = DateTime.now();
    await t.runAsync(() => db!.saveRecurring(RecurringRule(
          id: 'netflix',
          title: 'Netflix',
          amountPaise: 64900,
          category: SpendCategory.other,
          paymentKind: PaymentKind.card,
          userCardId: 'scapia',
          dayOfMonth: 1,
          autoAdd: false,
          lastAddedMonth: monthKey(now) - 1,
        )));
    await _pump(t, db!, const MoneyScreen());
    expect(find.textContaining('Netflix ₹649 was due on 1/'), findsOneWidget);
    await t.tap(find.widgetWithText(FilledButton, 'Add'));
    await _settle(t);
    expect(find.textContaining('was due on'), findsNothing);
    final spends = await t.runAsync(db.allSpends);
    expect(spends!.single.note, 'Netflix');
    await _close(t, db);
  });

  testWidgets('points show on the card and in the wallet total', (t) async {
    final db = await t.runAsync(_seed);
    await t.runAsync(() => db!.savePoints(PointsBalance(
          cardId: 'airtel',
          points: 12450,
          paisePerPoint: 25,
          expiresOn: DateTime.now().add(const Duration(days: 20)),
        )));
    await _pump(t, db!, const CardDetailScreen(cardId: 'airtel'));
    expect(find.text('12,450 points ≈ ₹3,112'), findsOneWidget);
    await _close(t, db);

    final db2 = await t.runAsync(_seed);
    await t.runAsync(() => db2!.savePoints(const PointsBalance(
        cardId: 'scapia', points: 1000, paisePerPoint: 50)));
    await _pump(t, db2!, const WalletScreen());
    expect(find.text('Reward points worth about ₹500'), findsOneWidget);
    await _close(t, db2);
  });

  testWidgets('best card suggests a better card and has travel mode', (t) async {
    final db = await t.runAsync(_seed);
    // ₹40,000 on online shopping by cash in the last 90 days: SBI Cashback
    // (5% on shopping, sample rate) would beat the cards owned.
    await t.runAsync(() => db!.addSpend(Spend(
          id: 'shop',
          amountPaise: 4000000,
          category: SpendCategory.shopping,
          paymentKind: PaymentKind.cash,
          spentOn: DateTime.now().subtract(const Duration(days: 5)),
        )));
    await _pump(t, db!, const BestCardScreen());
    expect(find.text('A card that fits your spending'), findsOneWidget);
    expect(find.text('SBI Cashback'), findsOneWidget);

    await t.tap(find.text('Travel mode'));
    await _settle(t);
    expect(find.textContaining('forex markup'), findsWidgets);
    await _close(t, db);
  });

  testWidgets('lounge, EMI and offers show where expected', (t) async {
    final db = await t.runAsync(_seed);
    final now = DateTime.now();
    await t.runAsync(() async {
      await db!.saveLoungeRule(
          const LoungeRule(
              cardId: 'airtel', visitsPerQuarter: 2, spendGatePaise: 5000000),
          'airtel');
      await db.logLoungeVisit('v1', 'airtel', now);
      await db.saveEmi(Emi(
        id: 'e1',
        cardId: 'airtel',
        title: 'Phone',
        monthlyPaise: 500000,
        totalMonths: 12,
        firstMonth: DateTime(now.year, now.month, 1),
      ));
      await db.saveOffer(SavedOffer(
        id: 'o1',
        title: '10% off on the big sale',
        category: SpendCategory.utilities,
        validUntil: now.add(const Duration(days: 3)),
      ));
    });
    await _pump(t, db!, const CardDetailScreen(cardId: 'airtel'));
    expect(find.text('Lounge: 1 of 2 used this quarter'), findsOneWidget);
    expect(find.textContaining('to unlock next quarter'), findsOneWidget);
    expect(find.text('Phone'), findsOneWidget);
    expect(find.textContaining('11 of 12 left'), findsOneWidget);
    await _close(t, db);

    final db2 = await t.runAsync(_seed);
    await t.runAsync(() => db2!.saveOffer(SavedOffer(
          id: 'o1',
          title: '10% off on the big sale',
          category: SpendCategory.utilities,
          validUntil: now.add(const Duration(days: 3)),
        )));
    await _pump(t, db2!, const BestCardScreen());
    // Above the ranking for Utilities, and in the saved list.
    expect(find.text('10% off on the big sale'), findsNWidgets(2));
    await _close(t, db2);
  });

  testWidgets('a saved photo replaces the styled card face', (t) async {
    final db = await t.runAsync(_seed);
    final dir = await t.runAsync(() => Directory.systemTemp.createTemp('cm_p'));
    final key = PhotoStore.newKey();
    final store = PhotoStore(dir: dir!, key: () async => key);
    await t.runAsync(() async {
      final im = img.Image(width: 400, height: 300);
      await store.save('airtel',
          prepareCardPhoto(img.encodePng(im), [BlurBox.numberDefault]));
    });
    await _pump(t, db!, const CardDetailScreen(cardId: 'airtel'),
        photos: store);
    await _settle(t);
    expect(find.bySemanticsLabel('Airtel Axis Bank card photo'), findsOneWidget);
    await _close(t, db);
    await t.runAsync(() => dir.delete(recursive: true));
  });

  testWidgets('pro screen: honest while testing, coffee tiers step', (t) async {
    final db = await t.runAsync(_seed);
    await _pump(t, db!, const ProScreen());
    expect(find.textContaining('unlocked while Card Master is in testing'),
        findsOneWidget);
    expect(find.text('Made by one person'), findsOneWidget);
    expect(find.textContaining('Google Play keeps a share'), findsOneWidget);
    await t.tap(find.text('Custom'));
    await t.pump();
    expect(find.text('₹299'), findsOneWidget);
    await t.tap(find.byTooltip('Bigger tip'));
    await t.pump();
    expect(find.text('₹499'), findsOneWidget);
    await _close(t, db);
  });

  testWidgets('trust center lists costs and an empty network log', (t) async {
    final db = await t.runAsync(_seed);
    await _pump(t, db!, const TrustScreen());
    expect(find.text('COST'), findsNWidgets(5));
    expect(find.textContaining("hasn't connected anywhere"), findsOneWidget);
    await _close(t, db);
  });
}
