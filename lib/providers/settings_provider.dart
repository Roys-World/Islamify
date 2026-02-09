import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _keyNotificationsEnabled = 'notifications_enabled';
  static const _keyPrayerReminders = 'prayer_reminders';
  static const _keyDarkMode = 'dark_mode';
  static const _keySelectedLanguage = 'selected_language';
  static const _keySelectedSchool = 'selected_school';
  static const _keyIslamicCalendar = 'islamic_calendar';

  bool notificationsEnabled = true;
  bool prayerReminders = true;
  bool darkMode = false;
  String selectedLanguage = 'English';
  String selectedSchool = 'Hanafi';
  bool islamicCalendar = true;

  SettingsProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      notificationsEnabled =
          prefs.getBool(_keyNotificationsEnabled) ?? notificationsEnabled;
      prayerReminders = prefs.getBool(_keyPrayerReminders) ?? prayerReminders;
      darkMode = prefs.getBool(_keyDarkMode) ?? darkMode;
      selectedLanguage =
          prefs.getString(_keySelectedLanguage) ?? selectedLanguage;
      selectedSchool = prefs.getString(_keySelectedSchool) ?? selectedSchool;
      islamicCalendar = prefs.getBool(_keyIslamicCalendar) ?? islamicCalendar;
      notifyListeners();
      print('✓ Settings loaded from preferences');
    } catch (e) {
      print('✗ Error loading settings: $e');
    }
  }

  Future<void> setNotificationsEnabled(bool value) async {
    notificationsEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationsEnabled, value);
  }

  Future<void> setPrayerReminders(bool value) async {
    prayerReminders = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPrayerReminders, value);
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
  }

  Future<void> setSelectedLanguage(String value) async {
    selectedLanguage = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedLanguage, value);
  }

  Future<void> setSelectedSchool(String value) async {
    selectedSchool = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedSchool, value);
  }

  Future<void> setIslamicCalendar(bool value) async {
    islamicCalendar = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIslamicCalendar, value);
  }
}
