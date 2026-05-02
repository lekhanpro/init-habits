import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../models/mode.dart';
import '../models/achievement.dart';
import '../services/notification_service.dart';

const _uuid = Uuid();
final _dateFmt = DateFormat('yyyy-MM-dd');

const int _xpPerCompletion = 10;
const int _xpPerStreakBonus = 5; // bonus for streak >= 7
const int _xpPerLevel = 100;

class HabitStore extends ChangeNotifier {
  List<Habit> habits = [];
  List<Completion> completions = [];
  List<JournalEntry> journal = [];
  Set<String> unlockedAchievements = {};
  String selectedDate = _dateFmt.format(DateTime.now());
  String activeMode = 'standard';
  bool isDemo = true;
  bool hasBooted = false;
  bool notificationsEnabled = true;

  HabitStore() {
    _boot();
  }

  Future<void> _boot() async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = prefs.getString('habits');
    final completionsJson = prefs.getString('completions');
    final journalJson = prefs.getString('journal');
    final achJson = prefs.getString('achievements');
    if (habitsJson != null) {
      habits = (jsonDecode(habitsJson) as List).map((e) => Habit.fromJson(e)).toList();
      completions = completionsJson != null
          ? (jsonDecode(completionsJson) as List).map((e) => Completion.fromJson(e)).toList()
          : [];
      journal = journalJson != null
          ? (jsonDecode(journalJson) as List).map((e) => JournalEntry.fromJson(e)).toList()
          : [];
      unlockedAchievements = achJson != null ? Set<String>.from(jsonDecode(achJson)) : {};
      activeMode = prefs.getString('activeMode') ?? 'standard';
      isDemo = prefs.getBool('isDemo') ?? false;
      notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    } else {
      _loadDemoData();
    }
    hasBooted = true;
    notifyListeners();
    // Re-arm notifications on boot.
    await NotificationService.instance.rescheduleAll(habits, enabled: notificationsEnabled);
  }

  void _loadDemoData() {
    final mode = allModes.firstWhere((m) => m.id == 'standard');
    habits = List.from(mode.presetHabits);
    activeMode = 'standard';
    isDemo = true;
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
    await prefs.setString('journal', jsonEncode(journal.map((e) => e.toJson()).toList()));
    await prefs.setString('achievements', jsonEncode(unlockedAchievements.toList()));
    await prefs.setString('activeMode', activeMode);
    await prefs.setBool('isDemo', isDemo);
    await prefs.setBool('notificationsEnabled', notificationsEnabled);
  }

  void setSelectedDate(String date) {
    selectedDate = date;
    notifyListeners();
  }

  List<Completion> getCompletionsForDate(String date) =>
      completions.where((c) => c.date == date && c.completed).toList();

  List<Habit> dueHabitsForDate(String date) {
    final weekday = DateTime.parse(date).weekday;
    return habits
        .where((h) => !h.archived && (h.schedule.isEmpty || h.schedule.contains(weekday)))
        .toList();
  }

  int dueCountForDate(String date) => dueHabitsForDate(date).length;

  List<Completion> dueCompletionsForDate(String date) {
    final dueIds = dueHabitsForDate(date).map((h) => h.id).toSet();
    return completions.where((c) => c.date == date && c.completed && dueIds.contains(c.habitId)).toList();
  }

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
    _evaluateAchievements();
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

  int getBestStreakForHabit(String habitId) {
    int best = 0, current = 0;
    final now = DateTime.now();
    for (int d = 365; d >= 0; d--) {
      final dateStr = _dateFmt.format(now.subtract(Duration(days: d)));
      if (getCompletionForHabit(habitId, dateStr) != null) {
        current++;
        if (current > best) best = current;
      } else {
        current = 0;
      }
    }
    return best;
  }

  /// Returns last [days] daily 0/1 completions for a habit, oldest first.
  List<int> getDailyHistoryForHabit(String habitId, {int days = 30}) {
    final now = DateTime.now();
    return List.generate(days, (i) {
      final d = now.subtract(Duration(days: days - 1 - i));
      return getCompletionForHabit(habitId, _dateFmt.format(d)) != null ? 1 : 0;
    });
  }

  // --- CRUD ---
  void addHabit(Habit habit) {
    habits.add(habit);
    if (isDemo) isDemo = false;
    _save();
    NotificationService.instance.scheduleForHabit(habit);
    _evaluateAchievements();
    notifyListeners();
  }

  void updateHabit(Habit updated) {
    final idx = habits.indexWhere((h) => h.id == updated.id);
    if (idx < 0) return;
    final old = habits[idx];
    habits[idx] = updated;
    NotificationService.instance.cancelForHabit(old);
    if (notificationsEnabled) NotificationService.instance.scheduleForHabit(updated);
    _save();
    notifyListeners();
  }

  void archiveHabit(String id, {bool archived = true}) {
    final idx = habits.indexWhere((h) => h.id == id);
    if (idx < 0) return;
    final h = habits[idx].copyWith(archived: archived);
    habits[idx] = h;
    if (archived) NotificationService.instance.cancelForHabit(h);
    _save();
    notifyListeners();
  }

  void deleteHabit(String id) {
    final h = habits.firstWhere((e) => e.id == id, orElse: () => Habit(
        id: id, name: '', type: HabitType.boolean, section: HabitSection.custom, colorValue: 0));
    habits.removeWhere((h) => h.id == id);
    completions.removeWhere((c) => c.habitId == id);
    NotificationService.instance.cancelForHabit(h);
    _save();
    notifyListeners();
  }

  void setMode(String modeId) {
    final mode = allModes.firstWhere((m) => m.id == modeId);
    habits = List.from(mode.presetHabits);
    completions = [];
    activeMode = modeId;
    isDemo = false;
    NotificationService.instance.rescheduleAll(habits, enabled: notificationsEnabled);
    _save();
    notifyListeners();
  }

  void freshStart(String modeId) => setMode(modeId);

  void resetToDemo() {
    _loadDemoData();
    NotificationService.instance.rescheduleAll(habits, enabled: notificationsEnabled);
    _save();
    notifyListeners();
  }

  // --- Journal ---
  JournalEntry? getJournalForDate(String date) {
    try {
      return journal.firstWhere((j) => j.date == date);
    } catch (_) {
      return null;
    }
  }

  void setJournalEntry(String date, String text) {
    journal.removeWhere((j) => j.date == date);
    if (text.trim().isNotEmpty) {
      journal.add(JournalEntry(date: date, text: text));
    }
    _save();
    notifyListeners();
  }

  // --- Stats helpers ---
  int get currentStreak {
    int streak = 0;
    var date = DateTime.now();
    while (true) {
      final dateStr = _dateFmt.format(date);
      final due = dueHabitsForDate(dateStr);
      if (due.isEmpty) break;
      final done = dueCompletionsForDate(dateStr).length;
      if (done > 0 && done >= (due.length * 0.5).ceil()) {
        streak++;
        date = date.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  int get bestStreak {
    int best = 0, current = 0;
    final now = DateTime.now();
    for (int d = 365; d >= 0; d--) {
      final dateStr = _dateFmt.format(now.subtract(Duration(days: d)));
      final due = dueHabitsForDate(dateStr);
      if (due.isEmpty) continue;
      final done = dueCompletionsForDate(dateStr).length;
      if (done > 0 && done >= (due.length * 0.5).ceil()) {
        current++;
        if (current > best) best = current;
      } else {
        current = 0;
      }
    }
    return best;
  }

  String get topHabitStreakLabel {
    if (habits.where((h) => !h.archived).isEmpty) return '—';
    final active = habits.where((h) => !h.archived).toList();
    final ranked = active.map((h) => (h, getStreakForHabit(h.id))).toList()
      ..sort((a, b) => b.$2.compareTo(a.$2));
    if (ranked.first.$2 == 0) return '—';
    return '${ranked.first.$1.name} · ${ranked.first.$2}d';
  }

  double rateForLast(int days) {
    final now = DateTime.now();
    int total = 0, done = 0;
    for (int d = 0; d < days; d++) {
      final dateStr = _dateFmt.format(now.subtract(Duration(days: d)));
      final due = dueCountForDate(dateStr);
      total += due;
      done += dueCompletionsForDate(dateStr).length;
    }
    return total > 0 ? (done / total * 100) : 0;
  }

  double get rate7d => rateForLast(7);

  int get perfectDays {
    int count = 0;
    final now = DateTime.now();
    for (int d = 0; d < 365; d++) {
      final dateStr = _dateFmt.format(now.subtract(Duration(days: d)));
      final due = dueCountForDate(dateStr);
      if (due > 0 && dueCompletionsForDate(dateStr).length >= due) count++;
    }
    return count;
  }

  /// Days in last N where any habit was done.
  int greenDays({int days = 365}) {
    int count = 0;
    final now = DateTime.now();
    for (int d = 0; d < days; d++) {
      final dateStr = _dateFmt.format(now.subtract(Duration(days: d)));
      if (dueCompletionsForDate(dateStr).isNotEmpty) count++;
    }
    return count;
  }

  int daysTracked() {
    if (habits.isEmpty) return 0;
    final earliest = habits.map((h) => h.createdAt).reduce((a, b) => a.isBefore(b) ? a : b);
    return DateTime.now().difference(earliest).inDays + 1;
  }

  /// Average completion percent for [weekday] (1=Mon..7=Sun) over [days].
  double weekdayRate(int weekday, {int days = 365}) {
    final now = DateTime.now();
    int total = 0, done = 0;
    for (int d = 0; d < days; d++) {
      final date = now.subtract(Duration(days: d));
      if (date.weekday != weekday) continue;
      final dateStr = _dateFmt.format(date);
      final due = dueCountForDate(dateStr);
      total += due;
      done += dueCompletionsForDate(dateStr).length;
    }
    return total > 0 ? (done / total * 100) : 0;
  }

  double weekdayAvg() {
    double sum = 0;
    int n = 0;
    for (int w = 1; w <= 5; w++) {
      sum += weekdayRate(w);
      n++;
    }
    return n > 0 ? sum / n : 0;
  }

  double weekendAvg() {
    return (weekdayRate(6) + weekdayRate(7)) / 2;
  }

  int get totalCompletions => completions.where((c) => c.completed).length;
  int get activeHabits => habits.where((h) => !h.archived).length;

  int get dueToday => dueCountForDate(_dateFmt.format(DateTime.now()));
  int get doneToday => dueCompletionsForDate(_dateFmt.format(DateTime.now())).length;

  double get todayRate => dueToday > 0 ? doneToday / dueToday * 100 : 0;

  List<Habit> focusHabits({int limit = 3}) {
    final today = _dateFmt.format(DateTime.now());
    final due = dueHabitsForDate(today)
        .where((h) => getCompletionForHabit(h.id, today) == null)
        .toList();
    due.sort((a, b) => getStreakForHabit(b.id).compareTo(getStreakForHabit(a.id)));
    return due.take(limit).toList();
  }

  // --- XP / Level ---
  int get totalXp {
    int xp = 0;
    xp += totalCompletions * _xpPerCompletion;
    // bonus per habit's best streak if >=7
    for (final h in habits) {
      final s = getBestStreakForHabit(h.id);
      if (s >= 7) xp += s * _xpPerStreakBonus;
    }
    return xp;
  }

  int get level => 1 + (totalXp ~/ _xpPerLevel);
  int get xpIntoLevel => totalXp % _xpPerLevel;
  int get xpForNextLevel => _xpPerLevel;

  // --- Achievements ---
  void _evaluateAchievements() {
    int habitsCreated = habits.length;
    for (final ach in allAchievements) {
      if (unlockedAchievements.contains(ach.id)) continue;
      int value;
      switch (ach.metric) {
        case AchievementMetric.totalCompletions:
          value = totalCompletions;
          break;
        case AchievementMetric.bestStreak:
          value = bestStreak;
          break;
        case AchievementMetric.perfectDays:
          value = perfectDays;
          break;
        case AchievementMetric.habitsCreated:
          value = habitsCreated;
          break;
      }
      if (value >= ach.threshold) {
        unlockedAchievements.add(ach.id);
      }
    }
  }

  // --- Settings ---
  Future<void> setNotificationsEnabled(bool v) async {
    notificationsEnabled = v;
    await NotificationService.instance.rescheduleAll(habits, enabled: v);
    _save();
    notifyListeners();
  }

  // --- Export ---
  String exportData() => jsonEncode({
        'habits': habits.map((e) => e.toJson()).toList(),
        'completions': completions.map((e) => e.toJson()).toList(),
        'journal': journal.map((e) => e.toJson()).toList(),
        'activeMode': activeMode,
      });

  /// CSV: weekly summary (Mon..Sun of current week).
  String weeklySummaryCsv() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    final dates = List.generate(7, (i) => _dateFmt.format(start.add(Duration(days: i))));
    final buf = StringBuffer();
    buf.write('habit,section');
    for (final d in dates) buf.write(',$d');
    buf.write(',total\n');
    for (final h in habits.where((h) => !h.archived)) {
      buf.write('"${h.name.replaceAll('"', '""')}",${h.section.name}');
      int total = 0;
      for (final d in dates) {
        final done = getCompletionForHabit(h.id, d) != null ? 1 : 0;
        total += done;
        buf.write(',$done');
      }
      buf.write(',$total\n');
    }
    return buf.toString();
  }

  void importData(String json) {
    final data = jsonDecode(json);
    habits = (data['habits'] as List).map((e) => Habit.fromJson(e)).toList();
    completions = (data['completions'] as List).map((e) => Completion.fromJson(e)).toList();
    journal = (data['journal'] as List? ?? []).map((e) => JournalEntry.fromJson(e)).toList();
    activeMode = data['activeMode'] ?? 'standard';
    isDemo = false;
    _save();
    notifyListeners();
  }
}
