import 'billing_cycle.dart';
import 'fee_waiver.dart';
import 'models.dart';
import 'money.dart';

/// A local notification to schedule. Planned here (pure, testable) and
/// scheduled by app/reminders_service.dart. Nothing leaves the phone.
class PlannedReminder {
  const PlannedReminder(this.id, this.at, this.title, this.body);
  final int id;
  final DateTime at;
  final String title;
  final String body;
}

const _hour = 9; // 9 am local time

/// Reminders for the next [horizonDays]: each bill 3 days and 1 day before
/// it's due, fee waiver 60 days before the card year ends (if not reached),
/// and a backup nudge 30 days after the last backup.
List<PlannedReminder> planReminders({
  required List<UserCard> cards,
  required List<Spend> spends,
  required DateTime now,
  DateTime? lastBackup,
  List<PointsBalance> points = const [],
  int horizonDays = 60,
}) {
  final out = <PlannedReminder>[];
  final end = now.add(Duration(days: horizonDays));
  var id = 1;

  void add(DateTime day, String title, String body) {
    final at = DateTime(day.year, day.month, day.day, _hour);
    if (at.isAfter(now) && at.isBefore(end)) {
      out.add(PlannedReminder(id, at, title, body));
    }
    id++;
  }

  for (final c in cards) {
    var due = nextDueDate(c, now);
    while (due.isBefore(end)) {
      add(due.subtract(const Duration(days: 3)), '${c.displayName} bill due in 3 days',
          'Due on ${due.day}/${due.month}. Pay the full amount to avoid interest.');
      add(due.subtract(const Duration(days: 1)), '${c.displayName} bill due tomorrow',
          'Due on ${due.day}/${due.month}.');
      due = nextDueDate(c, due.add(const Duration(days: 1)));
    }

    final waiver = feeWaiverStatus(c, spends, now);
    if (waiver != null && !waiver.achieved) {
      add(
        waiver.yearEnd.subtract(const Duration(days: 60)),
        '${c.displayName}: fee waiver in 60 days',
        'Spend ${formatInr(waiver.remainingPaise)} more by '
            '${waiver.yearEnd.day}/${waiver.yearEnd.month} to skip the '
            '${formatInr(c.annualFeePaise)} fee.',
      );
    }
  }

  for (final p in points) {
    final card = cards.where((c) => c.id == p.cardId).firstOrNull;
    if (card == null || p.expiresOn == null || p.points == 0) continue;
    add(
      p.expiresOn!.subtract(const Duration(days: 30)),
      '${card.displayName}: points expire in 30 days',
      '${p.points} points worth about ${formatInr(p.valuePaise)} expire on '
          '${p.expiresOn!.day}/${p.expiresOn!.month}. Redeem them before then.',
    );
  }

  add(
    (lastBackup ?? now).add(const Duration(days: 30)),
    'Time to back up Card Master',
    lastBackup == null
        ? "You haven't made a backup yet. If you lose your phone, your data is gone."
        : 'Your last backup is 30 days old.',
  );

  out.sort((a, b) => a.at.compareTo(b.at));
  return out;
}
