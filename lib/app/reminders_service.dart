import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../domain/reminders.dart';

/// Schedules local reminders (bills, fee waiver, backup). Inexact alarms
/// only: no exact-alarm permission (rule R7). Everything stays on the phone.
class RemindersService {
  RemindersService._();
  static final instance = RemindersService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'reminders',
      'Reminders',
      channelDescription: 'Bill due dates, fee waivers and backup reminders',
      importance: Importance.defaultImportance,
      enableVibration: false,
    ),
  );

  Future<void> _init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    final local = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(local.identifier));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    _ready = true;
  }

  /// Asks Android 13+ for notification permission, in context.
  Future<bool> requestPermission() async {
    await _init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? false;
  }

  /// Replaces all scheduled reminders with [plan].
  Future<void> reschedule(List<PlannedReminder> plan) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _init();
      await _plugin.cancelAll();
      for (final r in plan) {
        await _plugin.zonedSchedule(
          id: r.id,
          title: r.title,
          body: r.body,
          scheduledDate: tz.TZDateTime.from(r.at, tz.local),
          notificationDetails: _details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    } catch (e) {
      debugPrint('Reminder scheduling failed: $e');
    }
  }

  Future<void> cancelAll() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    await _init();
    await _plugin.cancelAll();
  }
}
