import 'package:card_master/data/db/database.dart';
import 'package:card_master/domain/models.dart';
import 'package:card_master/domain/recurring.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('adding an occurrence logs the expense once and marks the month', () async {
    final db = AppDatabase(NativeDatabase.memory());
    const rule = RecurringRule(
      id: 'rent',
      title: 'Rent',
      amountPaise: 2500000,
      category: SpendCategory.rent,
      paymentKind: PaymentKind.bankUpi,
      dayOfMonth: 5,
      autoAdd: true,
    );
    await db.saveRecurring(rule);
    final now = DateTime(2026, 10, 22);
    final due = dueOccurrences(await db.allRecurring(), now);
    expect(due, hasLength(1));
    await db.addOccurrence(due.single.$1, due.single.$2);

    final spends = await db.allSpends();
    expect(spends.single.amountPaise, 2500000);
    expect(spends.single.payee, PayeeType.person); // rent: no card nudge
    expect(dueOccurrences(await db.allRecurring(), now), isEmpty);

    // Skipping next month adds nothing.
    final next = DateTime(2026, 11, 6);
    final nextDue = dueOccurrences(await db.allRecurring(), next).single;
    await db.skipOccurrence(nextDue.$1, nextDue.$2);
    expect(dueOccurrences(await db.allRecurring(), next), isEmpty);
    expect(await db.allSpends(), hasLength(1));
    await db.close();
  });
}
