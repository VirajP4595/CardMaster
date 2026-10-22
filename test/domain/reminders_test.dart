import 'package:card_master/domain/models.dart';
import 'package:card_master/domain/reminders.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const card = UserCard(
    id: 'c',
    productId: 'p',
    bankName: 'Axis Bank',
    name: 'Airtel Axis',
    network: CardNetwork.mastercard,
    creditLimitPaise: 0,
    statementDay: 12,
    dueDay: 2,
    annualFeePaise: 50000,
    waiverSpendPaise: 20000000,
    anniversaryMonth: 1,
  );
  final now = DateTime(2026, 10, 22, 12);

  test('plans bill reminders 3 days and 1 day before each due date', () {
    final r = planReminders(
        cards: [card], spends: const [], now: now, lastBackup: now);
    final bills = r.where((x) => x.title.contains('bill due')).toList();
    // Due 2 Nov and 2 Dec within 60 days.
    expect(bills.map((b) => b.at), [
      DateTime(2026, 10, 30, 9),
      DateTime(2026, 11, 1, 9),
      DateTime(2026, 11, 29, 9),
      DateTime(2026, 12, 1, 9),
    ]);
  });

  test('plans the fee waiver reminder 60 days before the card year ends', () {
    final r = planReminders(
        cards: [card], spends: const [], now: now, lastBackup: now);
    final w = r.singleWhere((x) => x.title.contains('fee waiver'));
    expect(w.at, DateTime(2026, 11, 2, 9));
    expect(w.body, contains('₹2,00,000'));
  });

  test('never schedules in the past, and ids are stable', () {
    final r1 = planReminders(cards: [card], spends: const [], now: now);
    final r2 = planReminders(cards: [card], spends: const [], now: now);
    expect(r1.every((x) => x.at.isAfter(now)), isTrue);
    expect(r1.map((x) => x.id), r2.map((x) => x.id));
    expect(r1.map((x) => x.id).toSet().length, r1.length);
  });

  test('nudges for a backup 30 days after the last one', () {
    final r = planReminders(
        cards: const [],
        spends: const [],
        now: now,
        lastBackup: DateTime(2026, 10, 10));
    expect(r.single.at, DateTime(2026, 11, 9, 9));
  });

  test('reminds 30 days before reward points expire', () {
    final r = planReminders(
      cards: [card],
      spends: const [],
      now: now,
      lastBackup: now,
      points: [
        PointsBalance(
          cardId: 'c',
          points: 12450,
          paisePerPoint: 25,
          expiresOn: DateTime(2026, 12, 1),
        ),
      ],
    );
    final p = r.singleWhere((x) => x.title.contains('points expire'));
    expect(p.at, DateTime(2026, 11, 1, 9));
    expect(p.body, contains('₹3,112'));
  });
}
