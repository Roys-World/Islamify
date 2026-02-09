import 'package:adhan/adhan.dart';

class PrayerTime {
  final String name;
  final DateTime time;
  final String displayTime;

  PrayerTime({
    required this.name,
    required this.time,
    required this.displayTime,
  });
}

class PrayerTimesService {
  // get times (Adhan)
  static List<PrayerTime> getPrayerTimes(
    DateTime date, {
    required double latitude,
    required double longitude,
  }) {
    final coordinates = Coordinates(latitude, longitude);
    final params = CalculationMethod.karachi.getParameters()
      ..madhab = Madhab.hanafi;

    final prayerTimes = PrayerTimes.today(coordinates, params);

    // Extract prayer times
    final prayers = <PrayerTime>[
      PrayerTime(
        name: 'Fajr',
        time: prayerTimes.fajr,
        displayTime: _formatTime(prayerTimes.fajr),
      ),
      PrayerTime(
        name: 'Dhuhr',
        time: prayerTimes.dhuhr,
        displayTime: _formatTime(prayerTimes.dhuhr),
      ),
      PrayerTime(
        name: 'Asr',
        time: prayerTimes.asr,
        displayTime: _formatTime(prayerTimes.asr),
      ),
      PrayerTime(
        name: 'Maghrib',
        time: prayerTimes.maghrib,
        displayTime: _formatTime(prayerTimes.maghrib),
      ),
      PrayerTime(
        name: 'Isha',
        time: prayerTimes.isha,
        displayTime: _formatTime(prayerTimes.isha),
      ),
    ];

    return prayers;
  }

  // HH:mm
  static String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // current + next
  static Map<String, dynamic> getCurrentAndNextPrayer({
    required List<PrayerTime> prayers,
    required DateTime now,
  }) {
    PrayerTime? currentPrayer;
    PrayerTime? nextPrayer;

    // Compare only time of day, ignoring the date
    final nowTimeOnly = Duration(
      hours: now.hour,
      minutes: now.minute,
      seconds: now.second,
    );

    for (int i = 0; i < prayers.length; i++) {
      final prayerTimeOnly = Duration(
        hours: prayers[i].time.hour,
        minutes: prayers[i].time.minute,
        seconds: prayers[i].time.second,
      );

      if (nowTimeOnly.compareTo(prayerTimeOnly) < 0) {
        // Current time is before this prayer time
        nextPrayer = prayers[i];
        if (i > 0) {
          currentPrayer = prayers[i - 1];
        }
        break;
      }
    }

    // after Isha → Fajr (tomorrow)
    if (nextPrayer == null) {
      currentPrayer = prayers.isNotEmpty ? prayers.last : null;
      // For next prayer after Isha, create Fajr time for tomorrow
      if (prayers.isNotEmpty) {
        final tomorrow = now.add(const Duration(days: 1));
        final fajrTomorrow = prayers.first;
        nextPrayer = PrayerTime(
          name: fajrTomorrow.name,
          time: DateTime(
            tomorrow.year,
            tomorrow.month,
            tomorrow.day,
            fajrTomorrow.time.hour,
            fajrTomorrow.time.minute,
          ),
          displayTime: fajrTomorrow.displayTime,
        );
      }
    } else {
      currentPrayer ??= prayers.isNotEmpty ? prayers.last : null;
    }

    return {'current': currentPrayer, 'next': nextPrayer};
  }

  // countdown
  static String getCountdown(DateTime prayerTime) {
    final now = DateTime.now();
    final difference = prayerTime.difference(now);

    if (difference.isNegative) {
      return 'Passed';
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return 'Soon';
    }
  }

  // range: "HH:mm - HH:mm"
  static String getPrayerTimeRange(DateTime startTime, DateTime endTime) {
    return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  }

  // end time (add minutes)
  static DateTime getPrayerEndTime(
    DateTime startTime, {
    int durationMinutes = 40,
  }) {
    return startTime.add(Duration(minutes: durationMinutes));
  }
}
