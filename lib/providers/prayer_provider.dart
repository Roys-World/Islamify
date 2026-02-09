import 'package:flutter/material.dart';
import 'dart:async';
import '../services/prayer_times_service.dart';
import '../services/notification_service.dart';

class PrayerProvider extends ChangeNotifier {
  List<PrayerTime> _prayerTimes = [];
  PrayerTime? _currentPrayer;
  PrayerTime? _nextPrayer;
  String _countdown = 'Loading...';
  Timer? _countdownTimer;
  bool _isInitialized = false;

  double _latitude = 33.7298; // Default: Islamabad
  double _longitude = 73.1786;
  DateTime _lastCalculatedDate = DateTime.now();

  List<PrayerTime> get prayerTimes => _prayerTimes;
  PrayerTime? get currentPrayer => _currentPrayer;
  PrayerTime? get nextPrayer => _nextPrayer;
  String get countdown => _countdown;
  double get latitude => _latitude;
  double get longitude => _longitude;
  bool get isInitialized => _isInitialized;

  PrayerProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _initializePrayerTimes();
    _startCountdownTimer();
    _scheduleNotifications();
    _isInitialized = true;
    notifyListeners();
  }

  void _initializePrayerTimes() {
    _prayerTimes = PrayerTimesService.getPrayerTimes(
      DateTime.now(),
      latitude: _latitude,
      longitude: _longitude,
    );
    _updateCurrentAndNextPrayer();
  }

  void _updateCurrentAndNextPrayer() {
    final now = DateTime.now();
    final data = PrayerTimesService.getCurrentAndNextPrayer(
      prayers: _prayerTimes,
      now: now,
    );

    _currentPrayer = data['current'];
    _nextPrayer = data['next'];

    if (_nextPrayer != null) {
      _countdown = PrayerTimesService.getCountdown(_nextPrayer!.time);
    }

    // midnight recalc
    if (now.day != _lastCalculatedDate.day) {
      _initializePrayerTimes();
      _lastCalculatedDate = now;
      _scheduleNotifications();
    }
  }

  void _scheduleNotifications() async {
    try {
      // Cancel previous notifications
      await NotificationService().cancelPrayerNotifications();

      // Schedule notifications for today's prayers
      for (final prayer in _prayerTimes) {
        if (prayer.name == 'None') continue;

        // Parse prayer time (HH:mm format)
        final timeParts = prayer.displayTime.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);

        // Create DateTime for today
        final now = DateTime.now();
        var prayerDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        );

        // If prayer time has passed today, skip it
        if (prayerDateTime.isBefore(now)) {
          continue;
        }

        // Schedule notification 5 minutes before prayer time
        await NotificationService().schedulePrayerNotification(
          prayerName: prayer.name,
          prayerDateTime: prayerDateTime,
          prayerTime: prayer.displayTime,
        );
      }

      print('✓ All prayer notifications scheduled for today');
    } catch (e) {
      print('✗ Error scheduling notifications: $e');
    }
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCurrentAndNextPrayer();
      notifyListeners();
    });
  }

  // set location + recalc
  Future<void> setLocation(double latitude, double longitude) async {
    _latitude = latitude;
    _longitude = longitude;
    _initializePrayerTimes();
    _scheduleNotifications();
    notifyListeners();
  }

  // Reschedule notifications when settings change
  Future<void> rescheduleNotifications() async {
    _scheduleNotifications();
  }

  // range (start)
  String getPrayerTimeRange(PrayerTime prayer, {int durationMinutes = 40}) {
    return prayer.displayTime;
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
