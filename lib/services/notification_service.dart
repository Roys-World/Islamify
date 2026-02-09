import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  Future<void> initialize() async {
    // Initialize timezone
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('app_icon');

    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: androidInitializationSettings,
          iOS: iosInitializationSettings,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          print('Notification payload: ${response.payload}');
        }
      },
    );

    // Request permissions for Android 13+
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<bool> _areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    final prayerReminders = prefs.getBool('prayer_reminders') ?? true;
    return notificationsEnabled && prayerReminders;
  }

  Future<void> showPrayerNotification({
    required String prayerName,
    required String prayerTime,
  }) async {
    // Check if notifications are enabled
    if (!await _areNotificationsEnabled()) {
      print('⚠ Notifications disabled - skipping notification for $prayerName');
      return;
    }

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'prayer_channel',
          'Prayer Reminders',
          channelDescription: 'Notifications for prayer times',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('notification_sound'),
        );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      prayerName.hashCode,
      'Prayer Time: $prayerName',
      'It\'s time for $prayerName at $prayerTime',
      notificationDetails,
      payload: prayerName,
    );

    print('✓ Prayer notification sent for $prayerName at $prayerTime');
  }

  Future<void> schedulePrayerNotification({
    required String prayerName,
    required DateTime prayerDateTime,
    required String prayerTime,
  }) async {
    // Check if notifications are enabled
    if (!await _areNotificationsEnabled()) {
      print('⚠ Notifications disabled - skipping scheduling for $prayerName');
      return;
    }

    try {
      // Schedule for 5 minutes before prayer time
      final scheduledTime = prayerDateTime.subtract(const Duration(minutes: 5));

      // Don't schedule if time has already passed
      if (scheduledTime.isBefore(DateTime.now())) {
        print('⚠ Skipped scheduling for $prayerName - time has already passed');
        return;
      }

      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
            'prayer_channel',
            'Prayer Reminders',
            channelDescription: 'Notifications for prayer times',
            importance: Importance.max,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
          );

      const DarwinNotificationDetails iosNotificationDetails =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iosNotificationDetails,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        prayerName.hashCode,
        'Prayer Time: $prayerName',
        'Upcoming prayer at $prayerTime',
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: prayerName,
      );

      print(
        '✓ Scheduled notification for $prayerName at ${scheduledTime.toString()}',
      );
    } catch (e) {
      print('✗ Error scheduling notification: $e');
    }
  }

  Future<void> cancelPrayerNotifications() async {
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
      print('✓ All prayer notifications cancelled');
    } catch (e) {
      print('✗ Error cancelling notifications: $e');
    }
  }

  Future<void> cancelNotification(String prayerName) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(prayerName.hashCode);
      print('✓ Notification cancelled for $prayerName');
    } catch (e) {
      print('✗ Error cancelling notification: $e');
    }
  }
}
