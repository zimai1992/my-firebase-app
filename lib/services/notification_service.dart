
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

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Handle action here if needed in main.dart or via a stream
      },
    );
    tz.initializeTimeZones();
  }

  Future<void> scheduleMedicineReminder(Medicine medicine) async {
    // Schedule for each time in the medicine.times list
    for (int i = 0; i < medicine.times.length; i++) {
      final time = medicine.times[i];
      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, time.hour, time.minute);
      
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        medicine.hashCode + i,
        'Time for ${medicine.name}',
        'Dosage: ${medicine.dosage}. Tap to log as taken.',
        tz.TZDateTime.from(scheduledDate, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'medicine_reminders',
            'Medicine Reminders',
            channelDescription: 'Daily reminders for medications',
            importance: Importance.max,
            priority: Priority.high,
            // Action buttons appear on Smart Watches (Wear OS / watchOS)
            actions: <AndroidNotificationAction>[
              const AndroidNotificationAction(
                'mark_taken',
                'Mark as Taken',
                showsUserInterface: true,
                cancelNotification: true,
              ),
              const AndroidNotificationAction(
                'snooze',
                'Snooze (10m)',
                showsUserInterface: false,
              ),
            ],
          ),
          iOS: const DarwinNotificationDetails(
            categoryIdentifier: 'medicine_category',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
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
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(
              'find_pharmacy',
              'Find Pharmacy',
              showsUserInterface: true,
            ),
          ],
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
