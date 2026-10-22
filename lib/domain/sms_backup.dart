import 'package:xml/xml_events.dart';

import 'sms_parser.dart';

/// Result of reading an exported SMS backup (docs/08 §2b).
class SmsBackupResult {
  const SmsBackupResult(this.spends, this.messagesRead, this.bankMessages);
  final List<ParsedSpend> spends;
  final int messagesRead;
  final int bankMessages;
}

/// Indian commercial SMS sender IDs look like "AX-AXISBK" or "VM-HDFCBK-S".
/// Personal numbers are skipped without their text ever being parsed.
final _bankSender = RegExp(r'^[A-Z]{2}-[A-Z0-9]{5,6}(-[A-Z])?$');

bool isBankSender(String address) =>
    _bankSender.hasMatch(address.trim().toUpperCase());

/// Reads the XML format of the "SMS Backup & Restore" app:
/// `<smses><sms address=".." date="<epoch ms>" type="1" body=".."/>…`.
/// Streams events so large backups don't need a full DOM. Only received
/// messages from bank-style senders are parsed; message text is not kept.
SmsBackupResult parseSmsBackupXml(String xml) {
  final spends = <ParsedSpend>[];
  final seen = <String>{};
  var read = 0;
  var bank = 0;
  for (final event in parseEvents(xml)) {
    if (event is! XmlStartElementEvent || event.name != 'sms') continue;
    read++;
    String? attr(String n) =>
        event.attributes.where((a) => a.name == n).firstOrNull?.value;
    if (attr('type') != '1') continue; // 1 = received
    final address = attr('address') ?? '';
    if (!isBankSender(address)) continue;
    bank++;
    final parsed = parseBankSms(attr('body') ?? '');
    if (parsed == null) continue;
    final epoch = int.tryParse(attr('date') ?? '');
    final smsDate = epoch == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(epoch);
    final p = ParsedSpend(
      amountPaise: parsed.amountPaise,
      last4: parsed.last4,
      merchant: parsed.merchant,
      date: parsed.date ?? smsDate,
      viaUpi: parsed.viaUpi,
      international: parsed.international,
      availableLimitPaise: parsed.availableLimitPaise,
    );
    final key = '${p.amountPaise}|${p.last4}|${p.merchant}|${p.date}';
    if (seen.add(key)) spends.add(p);
  }
  return SmsBackupResult(spends, read, bank);
}
