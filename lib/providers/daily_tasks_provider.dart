import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/daily_task.dart';

class DailyTasksProvider extends ChangeNotifier {
  List<DailyTask> _tasks = [];
  DateTime? _lastResetDate;
  bool _isLoading = false;

  List<DailyTask> get tasks => _tasks;
  bool get isLoading => _isLoading;

  int get completedTasksCount =>
      _tasks.where((task) => task.isCompleted).length;
  int get totalTasksCount => _tasks.length;
  double get progress =>
      _tasks.isEmpty ? 0.0 : completedTasksCount / totalTasksCount;

  DailyTasksProvider() {
    _initializeDefaultTasks();
  }

  // init defaults
  void _initializeDefaultTasks() {
    final now = DateTime.now();
    _tasks = [
      DailyTask(
        id: '1',
        title: 'Read a Selected Verse for Today',
        description: 'Read and reflect on a verse from the Quran',
        createdAt: now,
      ),
      DailyTask(
        id: '2',
        title: 'Start the Day Morning Supplication',
        description: 'Recite morning duas and supplications',
        createdAt: now,
      ),
      DailyTask(
        id: '3',
        title: 'Pause for an Evening Supplication',
        description: 'Recite evening duas before sunset',
        createdAt: now,
      ),
      DailyTask(
        id: '4',
        title: 'Reflect on Today\'s Actions',
        description: 'Take time to reflect on your deeds and intentions',
        createdAt: now,
      ),
      DailyTask(
        id: '5',
        title: 'Perform All Five Daily Prayers',
        description: 'Complete Fajr, Dhuhr, Asr, Maghrib, and Isha prayers',
        createdAt: now,
      ),
    ];
    loadTasks();
  }

  // load prefs
  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString('daily_tasks');
      final lastResetDateString = prefs.getString('last_reset_date');

      // daily reset check
      if (lastResetDateString != null) {
        _lastResetDate = DateTime.parse(lastResetDateString);
        if (!_isSameDay(_lastResetDate!, DateTime.now())) {
          await _resetDailyTasks();
        }
      }

      // load if exists
      if (tasksJson != null) {
        final List<dynamic> jsonList = json.decode(tasksJson);
        _tasks = jsonList.map((json) => DailyTask.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // save prefs
  Future<void> saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = json.encode(
        _tasks.map((task) => task.toJson()).toList(),
      );
      await prefs.setString('daily_tasks', tasksJson);
      await prefs.setString(
        'last_reset_date',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      print('Error saving tasks: $e');
    }
  }

  // toggle
  Future<void> toggleTask(String taskId) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      _tasks[taskIndex].isCompleted = !_tasks[taskIndex].isCompleted;
      notifyListeners();
      await saveTasks();
    }
  }

  // add
  Future<void> addTask(String title, {String? description}) async {
    final newTask = DailyTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
    );
    _tasks.add(newTask);
    notifyListeners();
    await saveTasks();
  }

  // remove
  Future<void> removeTask(String taskId) async {
    _tasks.removeWhere((task) => task.id == taskId);
    notifyListeners();
    await saveTasks();
  }

  // edit
  Future<void> editTask(
    String taskId,
    String title, {
    String? description,
  }) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      _tasks[taskIndex] = _tasks[taskIndex].copyWith(
        title: title,
        description: description,
      );
      notifyListeners();
      await saveTasks();
    }
  }

  // daily reset
  Future<void> _resetDailyTasks() async {
    for (var task in _tasks) {
      task.isCompleted = false;
    }
    notifyListeners();
    await saveTasks();
  }

  // same-day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // manual reset
  Future<void> resetAllTasks() async {
    await _resetDailyTasks();
  }
}
