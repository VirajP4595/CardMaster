import 'package:card_master/domain/sms_backup.dart';
import 'package:flutter_test/flutter_test.dart';

// Shape of an "SMS Backup & Restore" export. Illustrative content only.
const _xml = '''<?xml version='1.0' encoding='UTF-8' standalone='yes' ?>
<smses count="6">
  <sms protocol="0" address="AX-AXISBK" date="1792540800000" type="1"
    body="INR 2,400.00 spent on Credit Card XX7302 at BESCOM on 21-10-26. Avl Lmt: INR 1,08,600" />
  <sms protocol="0" address="AX-AXISBK" date="1792540800000" type="1"
    body="INR 2,400.00 spent on Credit Card XX7302 at BESCOM on 21-10-26. Avl Lmt: INR 1,08,600" />
  <sms protocol="0" address="VM-HDFCBK" date="1792454400000" type="1"
    body="Rs.486 spent on card XX1190 at SWIGGY" />
  <sms protocol="0" address="JD-ICICIT" date="1792454400000" type="1"
    body="123456 is your OTP for INR 500 at AMAZON" />
  <sms protocol="0" address="+919800000000" date="1792454400000" type="1"
    body="Paid Rs 500 to you at dinner, spent on card XX1111" />
  <sms protocol="0" address="AX-AXISBK" date="1792454400000" type="2"
    body="INR 999 spent on card XX7302 at SENT" />
</smses>''';

void main() {
  test('reads bank spends from an SMS backup and skips the rest', () {
    final r = parseSmsBackupXml(_xml);
    expect(r.messagesRead, 6);
    expect(r.bankMessages, 4); // personal number and sent message skipped
    expect(r.spends.map((s) => s.merchant), ['BESCOM', 'SWIGGY']);
    // No date in the SWIGGY text: falls back to the message's own date.
    expect(r.spends[1].date,
        DateTime.fromMillisecondsSinceEpoch(1792454400000));
  });

  test('recognises bank sender IDs', () {
    expect(isBankSender('AX-AXISBK'), isTrue);
    expect(isBankSender('VM-HDFCBK-S'), isTrue);
    expect(isBankSender('+919800000000'), isFalse);
    expect(isBankSender('Mom'), isFalse);
  });
}
