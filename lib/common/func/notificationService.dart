import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import './task_database.dart';

class NotificationService {
  static const String defaultTitle = '每日提醒';
  static const String defaultBodyTemplate = '今天有 {count} 项待完成事项，记得打开看看哦！';
  static const int _notificationIdBase = 100000;
  static const int _maximumScheduledDays = 60;
  static const String _channelId = 'daily_reminder';
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// 初始化本地通知，并让定时任务使用设备所在时区。
  static Future<void> initialize() async {
    tz.initializeTimeZones();
    final localTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimezone.identifier));

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _notifications.initialize(initializationSettings);
  }

  static Future<void> requestPermissions() async {
    await Permission.notification.request();

    if (Platform.isAndroid) {
      final android = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final canScheduleExactly =
          await android?.canScheduleExactNotifications() ?? false;
      if (!canScheduleExactly) {
        await android?.requestExactAlarmsPermission();
      }
    }
  }

  static Future<AndroidScheduleMode> _androidScheduleMode() async {
    if (!Platform.isAndroid) {
      return AndroidScheduleMode.inexactAllowWhileIdle;
    }

    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final canScheduleExactly =
        await android?.canScheduleExactNotifications() ?? false;
    return canScheduleExactly
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  /// 只为存在未完成事项的日期安排通知。
  static Future<void> scheduleDailyNotification() async {
    await _cancelTaskNotifications();

    final time = await DatabaseHelper().getNotificationTime();
    if (time == null) {
      return;
    }

    final copy = await DatabaseHelper().getNotificationCopy();
    final title = copy?['title'] ?? defaultTitle;
    final bodyTemplate = copy?['bodyTemplate'] ?? defaultBodyTemplate;

    final rows = await DatabaseHelper().getAllTasks();
    final incompleteTaskCounts = <DateTime, int>{};

    for (final row in rows) {
      if (row['done'] == 1) {
        continue;
      }

      final date = DateTime.tryParse(row['date'] as String? ?? '');
      if (date == null) {
        continue;
      }

      final day = DateTime(date.year, date.month, date.day);
      incompleteTaskCounts.update(day, (count) => count + 1, ifAbsent: () => 1);
    }

    final now = tz.TZDateTime.now(tz.local);
    final androidScheduleMode = await _androidScheduleMode();
    final days = incompleteTaskCounts.keys.toList()..sort();
    var scheduledCount = 0;

    for (final day in days) {
      final scheduled = tz.TZDateTime(
        tz.local,
        day.year,
        day.month,
        day.day,
        time.hour,
        time.minute,
      );
      if (!scheduled.isAfter(now)) {
        continue;
      }

      final taskCount = incompleteTaskCounts[day]!;
      await _notifications.zonedSchedule(
        _notificationIdFor(day),
        title,
        bodyTemplate.replaceAll('{count}', '$taskCount'),
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            '每日提醒',
            channelDescription: '用于未完成事项提醒的通知通道',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: androidScheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      scheduledCount++;
      if (scheduledCount >= _maximumScheduledDays) {
        break;
      }
    }
  }

  static int _notificationIdFor(DateTime day) {
    final daysSinceEpoch =
        DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch ~/
            Duration.millisecondsPerDay;
    return _notificationIdBase + daysSinceEpoch;
  }

  static Future<void> _cancelTaskNotifications() async {
    final pending = await _notifications.pendingNotificationRequests();
    for (final notification in pending) {
      if (notification.id >= _notificationIdBase) {
        await _notifications.cancel(notification.id);
      }
    }
  }

  /// 取消通知
  static Future<void> cancelNotification() async {
    await _cancelTaskNotifications();
  }

  /// 初始化后立即调度通知
  static Future<void> initializeAndSchedule() async {
    await initialize();
    await scheduleDailyNotification();
  }
}
