import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationHelper {
  static Future<void> init() async {
    AwesomeNotifications().requestPermissionToSendNotifications();
    AwesomeNotifications().initialize('resource://mipmap/ic_launcher', [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic notifications',
        defaultColor: const Color(0xFF9D50DD),
        ledColor: Colors.white,
      ),
    ]);
  }

  static void scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime date,
    String? bigPicture,
  }) async {
    PermissionStatus status = await Permission.notification.request();
    if (status.isGranted) {
      if (date.isAfter(DateTime.now())) {
        // Ensure notification is scheduled for a future date
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: id,
            channelKey: 'basic_channel',
            title: title,
            body: body,
            icon: 'resource://mipmap/ic_launcher',
            bigPicture: bigPicture,
            notificationLayout: NotificationLayout.BigPicture,
          ),
          schedule: NotificationCalendar.fromDate(date: date),
        );
        debugPrint('Notification scheduled for $date');
      } else {
        debugPrint('Notification date is in the past. Skipping scheduling.');
      }
    } else {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  static void cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }
}
