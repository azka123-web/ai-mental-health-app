import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {

  static final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // ================= INIT =================

  static Future init() async {
    tz.initializeTimeZones();

    tz.setLocalLocation(tz.getLocation('Asia/Karachi'));

    const AndroidInitializationSettings android =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: android);

    await notificationsPlugin.initialize(settings);

    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  // ================= SCHEDULE =================

  static Future scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    try {
      debugPrint("🚀 Scheduling Notification...");

      final now = DateTime.now();

      DateTime scheduled = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      final tzScheduled = tz.TZDateTime.from(scheduled, tz.local);

      debugPrint("📅 Scheduled Time: $tzScheduled");

      await notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'habit_channel',
            'Habit Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint("✅ Notification scheduled successfully!");
    } catch (e) {
      debugPrint("❌ Error scheduling notification: $e");
    }
  }

  // ================= CANCEL ALL =================

  static Future cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }

  // ================= NEXT TIME =================

  static tz.TZDateTime _nextInstance(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }
}