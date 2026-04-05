import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../models/mode.dart';

const _uuid = Uuid();
final _dateFmt = DateFormat('yyyy-MM-dd');

class HabitStore extends ChangeNotifier {
  List<Habit> habits = [];
  List<Completion> completions = [];
  String selectedDate = _dateFmt.format(DateTime.now());
  String activeMode = 'standard';
  bool isDemo = true;
  bool hasBooted = false;

  HabitStore() {
    _boot();
  }

  Future<void> _boot() async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = prefs.getString('habits');
    final completionsJson = prefs.getString('completions');
    if (habitsJson != null) {
      habits = (jsonDecode(habitsJson) as List).map((e) => Habit.fromJson(e)).toList();
      completions = completionsJson != null
          ? (jsonDecode(completionsJson) as List).map((e) => Completion.fromJson(e)).toList()
          : [];
      activeMode = prefs.getString('activeMode') ?? 'standard';
      isDemo = prefs.getBool('isDemo') ?? false;
    } else {
      _loadDemoData();
    }
    hasBooted = true;
    notifyListeners();
  }

  void _loadDemoData() {
    final mode = allModes.firstWhere((m) => m.id == 'standard');
    habits = List.from(mode.presetHabits);
    activeMode = 'standard';
    isDemo = true;
    // Generate mock completions for last 90 days
    final rng = Random(42);
    completions = [];
    final now = DateTime.now();
    for (int d = 0; d < 90; d++) {
      final date = now.subtract(Duration(days: d));
      final dateStr = _dateFmt.format(date);
      final rate = d < 7 ? 0.75 : (d < 30 ? 0.65 : 0.5);
      for (final h in habits) {
        if (rng.nextDouble() < rate) {
          completions.add(Completion(id: _uuid.v4(), habitId: h.id, date: dateStr));
        }
      }
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('habits', jsonEncode(habits.map((e) => e.toJson()).toList()));
    await prefs.setString('completions', jsonEncode(completions.map((e) => e.toJson()).toList()));
    await prefs.setString('activeMode', activeMode);
    await prefs.setBool('isDemo', isDemo);
  }

  void setSelectedDate(String date) {
    selectedDate = date;
    notifyListeners();
  }

  List<Completion> getCompletionsForDate(String date) =>
      completions.where((c) => c.date == date && c.completed).toList();

  Completion? getCompletionForHabit(String habitId, String date) {
    try {
      return completions.firstWhere((c) => c.habitId == habitId && c.date == date && c.completed);
    } catch (_) {
      return null;
    }
  }

  void toggleCompletion(String habitId, String date) {
    final existing = getCompletionForHabit(habitId, date);
    if (existing != null) {
      completions.removeWhere((c) => c.id == existing.id);
    } else {
      completions.add(Completion(id: _uuid.v4(), habitId: habitId, date: date));
    }
    if (isDemo) isDemo = false;
    _save();
    notifyListeners();
  }

  int getStreakForHabit(String habitId) {
    int streak = 0;
    var date = DateTime.now();
    while (true) {
      final dateStr = _dateFmt.format(date);
      if (getCompletionForHabit(habitId, dateStr) != null) {
        streak++;
        date = date.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  void addHabit(Habit habit) {
    habits.add(habit);
    if (isDemo) isDemo = false;
    _save();
    notifyListeners();
  }

  void updateCompletionNote(String habitId, String date, String? note) {
    final c = getCompletionForHabit(habitId, date);
    if (c != null) {
      final idx = completions.indexOf(c);
      completions[idx] = Completion(
        id: c.id,
        habitId: c.habitId,
        date: c.date,
        completed: c.completed,
        value: c.value,
        note: note,
        createdAt: c.createdAt,
      );
      _save();
      notifyListeners();
    }
  }

  void reorderHabit(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex--;
    final item = habits.removeAt(oldIndex);
    habits.insert(newIndex, item);
    _save();
    notifyListeners();
  }

  void deleteHabit(String id) {
    habits.removeWhere((h) => h.id == id);
    completions.removeWhere((c) => c.habitId == id);
    _save();
    notifyListeners();
  }

  void setMode(String modeId) {
    final mode = allModes.firstWhere((m) => m.id == modeId);
    habits = List.from(mode.presetHabits);
    completions = [];
    activeMode = modeId;
    isDemo = false;
    _save();
    notifyListeners();
  }

  void freshStart(String modeId) => setMode(modeId);

  void resetToDemo() {
    _loadDemoData();
    _save();
    notifyListeners();
  }

  // Stats helpers
  int get currentStreak {
    int streak = 0;
    var date = DateTime.now();
    while (true) {
      final dateStr = _dateFmt.format(date);
      final active = habits.where((h) => !h.archived).toList();
      if (active.isEmpty) break;
      final done = getCompletionsForDate(dateStr).length;
      if (done > 0 && done >= (active.length * 0.5).ceil()) {
        streak++;
        date = date.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  int get bestStreak {
    int best = 0;
    int current = 0;
    final now = DateTime.now();
    for (int d = 89; d >= 0; d--) {
      final dateStr = _dateFmt.format(now.subtract(Duration(days: d)));
      final active = habits.where((h) => !h.archived).toList();
      if (active.isEmpty) continue;
      final done = getCompletionsForDate(dateStr).length;
      if (done > 0 && done >= (active.length * 0.5).ceil()) {
        current++;
        if (current > best) best = current;
      } else {
        current = 0;
      }
    }
    return best;
  }

  double get rate7d {
    final now = DateTime.now();
    int total = 0, done = 0;
    for (int d = 0; d < 7; d++) {
      final dateStr = _dateFmt.format(now.subtract(Duration(days: d)));
      final active = habits.where((h) => !h.archived).length;
      total += active;
      done += getCompletionsForDate(dateStr).length;
    }
    return total > 0 ? (done / total * 100) : 0;
  }

  int get perfectDays {
    int count = 0;
    final now = DateTime.now();
    for (int d = 0; d < 90; d++) {
      final dateStr = _dateFmt.format(now.subtract(Duration(days: d)));
      final active = habits.where((h) => !h.archived).length;
      if (active > 0 && getCompletionsForDate(dateStr).length >= active) count++;
    }
    return count;
  }

  int get totalCompletions => completions.where((c) => c.completed).length;
  int get activeHabits => habits.where((h) => !h.archived).length;

  // Weekly review data
  Map<String, dynamic> getWeeklyReview() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1 + 7));
    int total = 0, done = 0;
    int perfectDays = 0;
    String bestDay = '';
    int bestDayCount = 0;
    final habitScores = <String, int>{};

    for (int d = 0; d < 7; d++) {
      final date = weekStart.add(Duration(days: d));
      final dateStr = _dateFmt.format(date);
      final active = habits.where((h) => !h.archived).toList();
      if (active.isEmpty) continue;
      total += active.length;
      final dayDone = getCompletionsForDate(dateStr).length;
      done += dayDone;
      if (dayDone >= active.length) perfectDays++;
      if (dayDone > bestDayCount) {
        bestDayCount = dayDone;
        bestDay = DateFormat('EEEE').format(date);
      }
      for (final h in active) {
        if (getCompletionForHabit(h.id, dateStr) != null) {
          habitScores[h.id] = (habitScores[h.id] ?? 0) + 1;
        }
      }
    }

    // Best and worst habits
    String? bestHabitId, worstHabitId;
    int bestScore = -1, worstScore = 8;
    for (final e in habitScores.entries) {
      if (e.value > bestScore) { bestScore = e.value; bestHabitId = e.key; }
      if (e.value < worstScore) { worstScore = e.value; worstHabitId = e.key; }
    }
    // Habits with 0 completions
    for (final h in habits.where((h) => !h.archived)) {
      if (!habitScores.containsKey(h.id)) {
        worstHabitId = h.id;
        worstScore = 0;
      }
    }

    return {
      'total': total,
      'done': done,
      'rate': total > 0 ? (done / total * 100).round() : 0,
      'perfectDays': perfectDays,
      'bestDay': bestDay,
      'bestHabitId': bestHabitId,
      'worstHabitId': worstHabitId,
      'weekStart': _dateFmt.format(weekStart),
      'weekEnd': _dateFmt.format(weekStart.add(const Duration(days: 6))),
    };
  }

  String? getHabitName(String? id) {
    if (id == null) return null;
    try {
      return habits.firstWhere((h) => h.id == id).name;
    } catch (_) {
      return null;
    }
  }

  String exportData() => jsonEncode({'habits': habits.map((e) => e.toJson()).toList(), 'completions': completions.map((e) => e.toJson()).toList(), 'activeMode': activeMode});

  void importData(String json) {
    final data = jsonDecode(json);
    habits = (data['habits'] as List).map((e) => Habit.fromJson(e)).toList();
    completions = (data['completions'] as List).map((e) => Completion.fromJson(e)).toList();
    activeMode = data['activeMode'] ?? 'standard';
    isDemo = false;
    _save();
    notifyListeners();
  }
}
