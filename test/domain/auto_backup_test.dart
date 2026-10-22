import 'package:card_master/app/auto_backup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('automatic backup is due weekly', () {
    final now = DateTime(2026, 10, 22);
    expect(AutoBackup.isDue(null, now), isTrue);
    expect(AutoBackup.isDue(DateTime(2026, 10, 16), now), isFalse);
    expect(AutoBackup.isDue(DateTime(2026, 10, 15), now), isTrue);
  });
}
