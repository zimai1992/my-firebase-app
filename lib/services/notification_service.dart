
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/medicine.dart';

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();
  }

  Future<void> scheduleNotification(
      int id, String title, String body, DateTime scheduledTime) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'your_channel_id',
            'your_channel_name',
            channelDescription: 'your_channel_description',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // uiLocalNotificationDateInterpretation is removed in newer versions
    );
  }

  Future<void> scheduleRefillNotification(Medicine medicine) async {
    await flutterLocalNotificationsPlugin.show(
      medicine.hashCode,
      'Low Stock Warning',
      'Your stock of ${medicine.name} is running low. Please refill soon.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'refill_channel_id',
          'Refill Channel',
          channelDescription: 'Notifications for low stock warnings.',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> showNotification(int id, String title, String body) async {
    const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
    ));
    await flutterLocalNotificationsPlugin.show(
        id, title, body, notificationDetails);
  }
}
