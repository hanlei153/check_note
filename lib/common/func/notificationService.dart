import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import './task_database.dart';

class NotificationService {
  static const int _notificationId = 1001;
  static const String _channelKey = 'daily_reminder';

  /// 初始化 Awesome Notifications
  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: _channelKey,
          channelName: '每日提醒',
          channelDescription: '用于每日打卡提醒的通知通道',
          importance: NotificationImportance.High,
          channelShowBadge: true,
        )
      ],
      debug: true,
    );
  }

  /// 设置每日定时通知
  static Future<void> scheduleDailyNotification() async {
    try {
      final time = await DatabaseHelper().getNotificationTime();
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: _notificationId,
          channelKey: _channelKey,
          title: '每日提醒',
          body: '记得完成今天的打卡项哦！',
          notificationLayout: NotificationLayout.Default,
        ),
        schedule: NotificationCalendar(
          hour: time?.hour,
          minute: time?.minute,
          second: 0,
          repeats: true,
          timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        ),
      );
    } catch (e) {
      return;
    }
  }

  /// 取消通知
  static Future<void> cancelNotification() async {
    await AwesomeNotifications().cancel(_notificationId);
  }

  /// 初始化后立即调度通知
  static Future<void> initializeAndSchedule() async {
    await initialize();
    await scheduleDailyNotification();
  }
}
