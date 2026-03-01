import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  bool _initialized = false;
  Future<void>? _initializeFuture;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  Future<void> initialize() {
    if (_initialized) return Future.value();
    _initializeFuture ??= _initializeInternal();
    return _initializeFuture!;
  }

  Future<void> _initializeInternal() async {
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

    _initialized = true;
  }

  Future<void> _ensureInitialized() async {
    await initialize();
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
    await _ensureInitialized();
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
    required String currentPrayerName,
    required DateTime prayerDateTime,
    required String prayerTime,
  }) async {
    await _ensureInitialized();
    // Check if notifications are enabled
    if (!await _areNotificationsEnabled()) {
      print('⚠ Notifications disabled - skipping scheduling for $prayerName');
      return;
    }
    try {
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

      // Schedule notification 30 minutes before prayer time
      final reminderTime = prayerDateTime.subtract(const Duration(minutes: 30));
      if (reminderTime.isAfter(DateTime.now())) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          '${prayerName}_reminder'.hashCode,
          'Prayer Ending Soon',
          '30 minutes remaining to end $currentPrayerName prayer. Hurry up and pray.',
          tz.TZDateTime.from(reminderTime, tz.local),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exact,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: '${prayerName}_reminder',
        );
        print(
          '✓ Scheduled 30-min reminder for $prayerName at ${reminderTime.toString()}',
        );
      }

      // Schedule notification at prayer time
      if (prayerDateTime.isAfter(DateTime.now())) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          prayerName.hashCode,
          'Prayer Time: $prayerName',
          'It\'s time for $prayerName prayer now!',
          tz.TZDateTime.from(prayerDateTime, tz.local),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exact,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: prayerName,
        );
        print(
          '✓ Scheduled prayer time notification for $prayerName at ${prayerDateTime.toString()}',
        );
      }
    } catch (e) {
      print('✗ Error scheduling notification: $e');
    }
  }

  Future<void> cancelPrayerNotifications() async {
    try {
      await _ensureInitialized();
      await flutterLocalNotificationsPlugin.cancelAll();
      print('✓ All prayer notifications cancelled');
    } catch (e) {
      print('✗ Error cancelling notifications: $e');
    }
  }

  Future<void> cancelNotification(String prayerName) async {
    try {
      await _ensureInitialized();
      await flutterLocalNotificationsPlugin.cancel(prayerName.hashCode);
      print('✓ Notification cancelled for $prayerName');
    } catch (e) {
      print('✗ Error cancelling notification: $e');
    }
  }
}
