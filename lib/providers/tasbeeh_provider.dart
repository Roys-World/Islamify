import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

class Dhikr {
  final String id;
  final String arabic;
  final String translation;
  int count;

  Dhikr({
    required this.id,
    required this.arabic,
    required this.translation,
    this.count = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'arabic': arabic,
    'translation': translation,
    'count': count,
  };

  factory Dhikr.fromJson(Map<String, dynamic> json) => Dhikr(
    id: json['id'] as String,
    arabic: json['arabic'] as String,
    translation: json['translation'] as String,
    count: json['count'] as int? ?? 0,
  );
}

class TasbeehProvider extends ChangeNotifier {
  late List<Dhikr> _dhikrList;
  DateTime? _lastResetDate;
  bool _isLoading = false;
  late int _selectedIndex;
  Timer? _dailyCheckTimer;

  List<Dhikr> get dhikrList => _dhikrList;
  bool get isLoading => _isLoading;
  int get selectedIndex => _selectedIndex;
  Dhikr get selectedDhikr => _dhikrList[_selectedIndex];

  TasbeehProvider() {
    _initializeDefaultDhikr();
  }

  void _initializeDefaultDhikr() {
    _dhikrList = [
      Dhikr(
        id: '1',
        arabic: 'الحمد لله',
        translation: 'Alhamdulillah (All praise is due to Allah)',
      ),
      Dhikr(
        id: '2',
        arabic: 'سبحان الله',
        translation: 'SubhanAllah (Glory be to Allah)',
      ),
      Dhikr(
        id: '3',
        arabic: 'الله أكبر',
        translation: 'Allahu Akbar (Allah is the Greatest)',
      ),
      Dhikr(
        id: '4',
        arabic: 'لا حول ولا قوة إلا بالله',
        translation:
            'La hawla wa la quwwata illa billah (There is no might nor power except with Allah)',
      ),
      Dhikr(
        id: '5',
        arabic: 'استغفر الله',
        translation: 'Astaghfirullah (I seek forgiveness from Allah)',
      ),
      Dhikr(
        id: '6',
        arabic: 'لا إله إلا الله',
        translation: 'La ilaha illallah (There is no god but Allah)',
      ),
    ];
    _selectedIndex = 0;
    loadCounts();
    _startDailyCheckTimer();
  }

  // Load counts from shared preferences
  Future<void> loadCounts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final countsJson = prefs.getString('tasbeeh_counters');
      final lastResetDateString = prefs.getString('tasbeeh_last_reset_date');

      // Check for daily reset
      if (lastResetDateString != null) {
        _lastResetDate = DateTime.parse(lastResetDateString);
        if (!_isSameDay(_lastResetDate!, DateTime.now())) {
          print('⏰ New day detected - resetting tasbeeh counters');
          await _resetCounters();
          return;
        }
      } else {
        // First time loading - set reset date to today
        _lastResetDate = DateTime.now();
        await _saveResetDate();
      }

      // Load counts if they exist
      if (countsJson != null) {
        try {
          final Map<String, dynamic> countsMap = json.decode(countsJson);
          for (var dhikr in _dhikrList) {
            dhikr.count = countsMap[dhikr.id] as int? ?? 0;
          }
          print(
            '✓ Tasbeeh counters loaded: ${_dhikrList.map((d) => '${d.arabic}=${d.count}').join(', ')}',
          );
        } catch (e) {
          print('Error parsing tasbeeh counts: $e');
          await _resetCounters();
        }
      }
    } catch (e) {
      print('✗ Error loading tasbeeh counts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Increment counter for selected dhikr
  Future<void> incrementCounter() async {
    _dhikrList[_selectedIndex].count++;
    await _saveCounters();
    notifyListeners();
  }

  // Reset counter for selected dhikr
  Future<void> resetSelectedCounter() async {
    _dhikrList[_selectedIndex].count = 0;
    await _saveCounters();
    notifyListeners();
  }

  // Reset all counters
  Future<void> resetAllCounters() async {
    await _resetCounters();
  }

  // Internal reset function
  Future<void> _resetCounters() async {
    for (var dhikr in _dhikrList) {
      dhikr.count = 0;
    }
    _lastResetDate = DateTime.now();
    await _saveCounters();
    await _saveResetDate();
    print('✓ All tasbeeh counters reset at: ${DateTime.now()}');
    notifyListeners();
  }

  // Save counters to shared preferences
  Future<void> _saveCounters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final countsMap = <String, int>{};

      for (var dhikr in _dhikrList) {
        countsMap[dhikr.id] = dhikr.count;
      }

      await prefs.setString('tasbeeh_counters', json.encode(countsMap));
    } catch (e) {
      print('✗ Error saving tasbeeh counts: $e');
    }
  }

  // Save reset date to shared preferences
  Future<void> _saveResetDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'tasbeeh_last_reset_date',
        _lastResetDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      );
    } catch (e) {
      print('✗ Error saving reset date: $e');
    }
  }

  // Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Select a dhikr
  void selectDhikr(int index) {
    if (index >= 0 && index < _dhikrList.length) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  // Get total count across all dhikrs
  int getTotalCount() {
    return _dhikrList.fold(0, (sum, dhikr) => sum + dhikr.count);
  }

  // Start a periodic timer to check for daily reset
  void _startDailyCheckTimer() {
    _dailyCheckTimer?.cancel();
    // Check every 30 seconds if it's a new day
    _dailyCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (_lastResetDate != null &&
          !_isSameDay(_lastResetDate!, DateTime.now())) {
        print('⏰ Daily reset timer: New day detected!');
        await _resetCounters();
      }
    });
  }

  // Check if it's time to reset based on Maghrib time
  // This method checks if Maghrib prayer time is the current prayer
  // Call this from a widget that has access to both PrayerProvider and TasbeehProvider
  Future<void> checkAndResetAtMaghrib(String? currentPrayerName) async {
    if (currentPrayerName == 'Maghrib') {
      // Check if we're past Maghrib time and haven't reset yet in this day
      final now = DateTime.now();
      if (_lastResetDate != null && _isSameDay(_lastResetDate!, now)) {
        print('⏰ Maghrib prayer detected - resetting tasbeeh counters');
        await _resetCounters();
      }
    }
  }

  @override
  void dispose() {
    _dailyCheckTimer?.cancel();
    super.dispose();
  }
}
