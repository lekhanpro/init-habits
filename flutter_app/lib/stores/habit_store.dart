import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../models/chain.dart';
import '../models/mode.dart';
import '../models/achievement.dart';
import '../models/settings.dart';
import '../services/notification_service.dart';

const _uuid = Uuid();
final _dateFmt = DateFormat('yyyy-MM-dd');

const int _xpPerCompletion = 10;
const int _xpPerStreakBonus = 5;
const int _xpPerLevel = 200; // raised from 100

// Loop Habit Tracker EMA alpha: converges to 1 after ~13 days
const double _scoreAlpha = 1 - 0.0513; // 1 - 0.5^(1/13)

const _levelNames = [
  'Initiate',
  'Apprentice',
  'Journeyman',
  'Specialist',
  'Expert',
  'Master',
  'Grandmaster',
  'Legend',
  'Transcendent',
  '[REDACTED]',
];

class HabitStore extends ChangeNotifier {
  List<Habit> habits = [];
  List<Completion> completions = [];
  List<JournalEntry> journal = [];
  List<HabitChain> chains = [];
  Set<String> unlockedAchievements = {};
  Set<String> shownMilestones = {};
  String selectedDate = _dateFmt.format(DateTime.now());
  String activeMode = 'standard';
  bool isDemo = true;
  bool hasBooted = false;
  bool notificationsEnabled = true;
  int gracePeriodHours = 0; // 0-3h: completions before this hour count for prev day

  HabitStore() {
    _boot();
  }

  Future<void> _boot() async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = prefs.getString('habits');
    final completionsJson = prefs.getString('completions');
    final journalJson = prefs.getString('journal');
    final achJson = prefs.getString('achievements');
    final chainsJson = prefs.getString('chains');
    final milestonesJson = prefs.getString('shownMilestones');
    if (habitsJson != null) {
      habits = (jsonDecode(habitsJson) as List).map((e) => Habit.fromJson(e)).toList();
      completions = completionsJson != null
          ? (jsonDecode(completionsJson) as List).map((e) => Completion.fromJson(e)).toList()
          : [];
      journal = journalJson != null
          ? (jsonDecode(journalJson) as List).map((e) => JournalEntry.fromJson(e)).toList()
          : [];
      chains = chainsJson != null
          ? (jsonDecode(chainsJson) as List).map((e) => HabitChain.fromJson(e)).toList()
          : [];
      unlockedAchievements = achJson != null ? Set<String>.from(jsonDecode(achJson)) : {};
      shownMilestones = milestonesJson != null ? Set<String>.from(jsonDecode(milestonesJson)) : {};
      activeMode = prefs.getString('activeMode') ?? 'standard';
      isDemo = prefs.getBool('isDemo') ?? false;
      notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      gracePeriodHours = prefs.getInt('gracePeriodHours') ?? 0;
    } else {
      _loadDemoData();
    }
    hasBooted = true;
    notifyListeners();
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
    await prefs.setString('chains', jsonEncode(chains.map((e) => e.toJson()).toList()));
    await prefs.setString('achievements', jsonEncode(unlockedAchievements.toList()));
    await prefs.setString('shownMilestones', jsonEncode(shownMilestones.toList()));
    await prefs.setString('activeMode', activeMode);
    await prefs.setBool('isDemo', isDemo);
    await prefs.setBool('notificationsEnabled', notificationsEnabled);
    await prefs.setInt('gracePeriodHours', gracePeriodHours);
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
    final wasCompleted = existing != null;
    if (wasCompleted) {
      completions.removeWhere((c) => c.id == existing.id);
    } else {
      completions.add(Completion(id: _uuid.v4(), habitId: habitId, date: date));
    }
    if (isDemo) isDemo = false;
    if (!wasCompleted) _maybeAwardShield(habitId);
    _evaluateAchievements();
    _save();
    notifyListeners();
  }

  // Award shield when streak crosses 7/14/30 thresholds.
  void _maybeAwardShield(String habitId) {
    final idx = habits.indexWhere((h) => h.id == habitId);
    if (idx < 0) return;
    final h = habits[idx];
    final streak = getStreakForHabit(habitId);
    int tier = 0;
    if (streak >= 30) tier = 3;
    else if (streak >= 14) tier = 2;
    else if (streak >= 7) tier = 1;
    if (tier > h.shieldTier) {
      habits[idx] = h.copyWith(shieldTier: tier, shieldsRemaining: tier);
    }
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

  // --- XP / Level 2.0 ---
  int get totalXp {
    int xp = 0;
    for (final c in completions.where((c) => c.completed)) {
      final habit = habits.firstWhere(
        (h) => h.id == c.habitId,
        orElse: () => Habit(id: '', name: '', type: HabitType.boolean, section: HabitSection.custom, colorValue: 0),
      );
      final diffMult = habit.difficultyMultiplier;
      final streak = getStreakForHabit(c.habitId);
      final streakMult = (1.0 + (streak ~/ 7) * 0.05).clamp(1.0, 2.0);
      xp += (_xpPerCompletion * diffMult * streakMult).round();
    }
    return xp;
  }

  int get level => (_levelNames.length - 1).clamp(0, (totalXp ~/ _xpPerLevel).clamp(0, _levelNames.length - 1));
  String get levelName => _levelNames[level.clamp(0, _levelNames.length - 1)];
  int get xpIntoLevel => totalXp % _xpPerLevel;
  int get xpForNextLevel => _xpPerLevel;
  double get xpProgress => xpIntoLevel / _xpPerLevel;

  // --- Achievements ---
  void _evaluateAchievements() {
    final now = DateTime.now();
    int lateNight = 0, earlyMorning = 0, weekendDone = 0;
    int hardDone = 0, extremeDone = 0;
    final earlyDates = <String>{};

    for (final c in completions.where((c) => c.completed)) {
      final hour = c.createdAt.hour;
      if (hour >= 23 || hour < 3) lateNight++;
      if (hour < 6) earlyDates.add(c.date);
      final wd = DateTime.parse(c.date).weekday;
      if (wd == 6 || wd == 7) weekendDone++;
      final h = habits.firstWhere((h) => h.id == c.habitId,
          orElse: () => Habit(id: '', name: '', type: HabitType.boolean, section: HabitSection.custom, colorValue: 0));
      if (h.difficulty == HabitDifficulty.hard) hardDone++;
      if (h.difficulty == HabitDifficulty.extreme) extremeDone++;
    }

    for (int d = 6; d >= 0; d--) {
      final ds = _dateFmt.format(now.subtract(Duration(days: d)));
      final c = completions.where((c) => c.date == ds && c.completed && c.createdAt.hour < 6).length;
      if (c > 0) earlyMorning++;
    }

    final metrics = {
      AchievementMetric.totalCompletions: totalCompletions,
      AchievementMetric.bestStreak: bestStreak,
      AchievementMetric.perfectDays: perfectDays,
      AchievementMetric.habitsCreated: habits.length,
      AchievementMetric.xpTotal: totalXp,
      AchievementMetric.currentStreak: currentStreak,
      AchievementMetric.totalDaysTracked: daysTracked(),
      AchievementMetric.lateNightCompletions: lateNight,
      AchievementMetric.earlyMorningDays: earlyMorning,
      AchievementMetric.weekendCompletions: weekendDone,
      AchievementMetric.consecutivePerfectWeeks: 0,
      AchievementMetric.hardHabitsCompleted: hardDone,
      AchievementMetric.extremeHabitsCompleted: extremeDone,
    };

    for (final ach in allAchievements) {
      if (unlockedAchievements.contains(ach.id)) continue;
      final value = metrics[ach.metric] ?? 0;
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

  Future<void> setGracePeriodHours(int hours) async {
    gracePeriodHours = hours.clamp(0, 3);
    _save();
    notifyListeners();
  }

  // --- Habit Score (Loop Habit Tracker EMA algorithm) ---
  // Returns 0.0 - 1.0; converges to 1 after ~13 perfect days
  double habitScore(String habitId, {int days = 90}) {
    double score = 0.0;
    final now = DateTime.now();
    for (int d = days - 1; d >= 0; d--) {
      final dateStr = _dateFmt.format(now.subtract(Duration(days: d)));
      final due = dueHabitsForDate(dateStr).any((h) => h.id == habitId);
      if (!due) continue;
      final done = getCompletionForHabit(habitId, dateStr) != null ? 1.0 : 0.0;
      score = score * (1 - _scoreAlpha) + done * _scoreAlpha;
    }
    return score;
  }

  // Last [days] daily scores for sparkline
  List<double> habitScoreHistory(String habitId, {int days = 14}) {
    final now = DateTime.now();
    double score = habitScore(habitId, days: 90 + days);
    final result = <double>[];
    for (int d = days - 1; d >= 0; d--) {
      final dateStr = _dateFmt.format(now.subtract(Duration(days: d)));
      final due = dueHabitsForDate(dateStr).any((h) => h.id == habitId);
      if (due) {
        final done = getCompletionForHabit(habitId, dateStr) != null ? 1.0 : 0.0;
        score = score * (1 - _scoreAlpha) + done * _scoreAlpha;
      }
      result.add(score);
    }
    return result;
  }

  String habitScoreBar(String habitId) {
    final score = habitScore(habitId);
    final filled = (score * 10).round();
    return '[${('█' * filled).padRight(10, '░')}] ${(score * 100).round()}%';
  }

  // --- Predictive Insights ---
  String get predictedStreakDays {
    if (currentStreak == 0) return '—';
    final score = habits.isEmpty ? 0.0 : habits
        .where((h) => !h.archived)
        .map((h) => habitScore(h.id))
        .fold(0.0, (a, b) => a + b) /
        habits.where((h) => !h.archived).length;
    if (score < 0.3) return '—';
    final daysTo30 = ((30 - currentStreak) / score).round();
    return daysTo30 > 0 ? '~$daysTo30 days to 30-day streak' : 'You\'re on track!';
  }

  String get weakestHabitThisWeek {
    final active = habits.where((h) => !h.archived).toList();
    if (active.isEmpty) return '—';
    final now = DateTime.now();
    Habit? weakest;
    double minRate = double.infinity;
    for (final h in active) {
      int total = 0, done = 0;
      for (int d = 0; d < 7; d++) {
        final ds = _dateFmt.format(now.subtract(Duration(days: d)));
        if (dueHabitsForDate(ds).any((x) => x.id == h.id)) {
          total++;
          if (getCompletionForHabit(h.id, ds) != null) done++;
        }
      }
      if (total > 0) {
        final rate = done / total;
        if (rate < minRate) {
          minRate = rate;
          weakest = h;
        }
      }
    }
    return weakest?.name ?? '—';
  }

  String get bestPerformanceWindow {
    final counts = {'morning': 0, 'afternoon': 0, 'evening': 0};
    for (final c in completions.where((c) => c.completed)) {
      final h = c.createdAt.hour;
      if (h >= 5 && h < 12) counts['morning'] = counts['morning']! + 1;
      else if (h >= 12 && h < 17) counts['afternoon'] = counts['afternoon']! + 1;
      else counts['evening'] = counts['evening']! + 1;
    }
    if (counts.values.every((v) => v == 0)) return '—';
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  String get weekdayVsWeekendRatio {
    final wd = weekdayAvg();
    final we = weekendAvg();
    if (we == 0) return '—';
    final ratio = (wd / we);
    if (ratio > 1) return '${ratio.toStringAsFixed(1)}× more consistent on weekdays';
    if (ratio < 1) return '${(1 / ratio).toStringAsFixed(1)}× more consistent on weekends';
    return 'Equally consistent on weekdays and weekends';
  }

  double weeklyCompletionRateForHabit(String habitId) {
    final now = DateTime.now();
    int total = 0, done = 0;
    for (int d = 0; d < 28; d++) {
      final ds = _dateFmt.format(now.subtract(Duration(days: d)));
      if (dueHabitsForDate(ds).any((h) => h.id == habitId)) {
        total++;
        if (getCompletionForHabit(habitId, ds) != null) done++;
      }
    }
    return total > 0 ? done / total : 0.0;
  }

  double consistencyScoreForHabit(String habitId) {
    final h = habits.firstWhere((h) => h.id == habitId, orElse: () =>
        Habit(id: '', name: '', type: HabitType.boolean, section: HabitSection.custom, colorValue: 0));
    final ageDays = DateTime.now().difference(h.createdAt).inDays + 1;
    int done = 0;
    final now = DateTime.now();
    for (int d = 0; d < ageDays; d++) {
      final ds = _dateFmt.format(now.subtract(Duration(days: d)));
      if (getCompletionForHabit(habitId, ds) != null) done++;
    }
    return ageDays > 0 ? done / ageDays : 0.0;
  }

  // habits often done on the same day as habitId
  List<String> correlatedHabits(String habitId, {int topN = 2}) {
    final counts = <String, int>{};
    for (final c in completions.where((c) => c.completed && c.habitId == habitId)) {
      for (final other in completions.where((x) => x.completed && x.date == c.date && x.habitId != habitId)) {
        counts[other.habitId] = (counts[other.habitId] ?? 0) + 1;
      }
    }
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(topN).map((e) {
      final h = habits.firstWhere((h) => h.id == e.key, orElse: () =>
          Habit(id: '', name: e.key, type: HabitType.boolean, section: HabitSection.custom, colorValue: 0));
      return h.name;
    }).where((n) => n.isNotEmpty).toList();
  }

  // --- Grace Period: resolve effective date for a completion ---
  String effectiveDateForNow() {
    final now = DateTime.now();
    if (gracePeriodHours > 0 && now.hour < gracePeriodHours) {
      return _dateFmt.format(now.subtract(const Duration(days: 1)));
    }
    return _dateFmt.format(now);
  }

  // --- Streak Shields ---
  void awardShield(String habitId) {
    final idx = habits.indexWhere((h) => h.id == habitId);
    if (idx < 0) return;
    final h = habits[idx];
    final streak = getStreakForHabit(habitId);
    int tier = 0;
    if (streak >= 30) tier = 3;
    else if (streak >= 14) tier = 2;
    else if (streak >= 7) tier = 1;
    if (tier > h.shieldTier) {
      habits[idx] = h.copyWith(shieldTier: tier, shieldsRemaining: tier);
      _save();
      notifyListeners();
    }
  }

  // --- Chain CRUD ---
  HabitChain? chainForHabit(String habitId) {
    try {
      return chains.firstWhere((c) => c.habitIds.contains(habitId));
    } catch (_) {
      return null;
    }
  }

  void addChain(HabitChain chain) {
    chains.add(chain);
    for (int i = 0; i < chain.habitIds.length; i++) {
      final idx = habits.indexWhere((h) => h.id == chain.habitIds[i]);
      if (idx >= 0) habits[idx] = habits[idx].copyWith(chainId: chain.id, chainOrder: i + 1);
    }
    _save();
    notifyListeners();
  }

  void removeChain(String chainId) {
    chains.removeWhere((c) => c.id == chainId);
    for (int i = 0; i < habits.length; i++) {
      if (habits[i].chainId == chainId) habits[i] = habits[i].copyWith(clearChain: true);
    }
    _save();
    notifyListeners();
  }

  // Returns how far through the chain (completedSteps, totalSteps) for a date
  (int, int) chainProgressForDate(String chainId, String date) {
    final chain = chains.firstWhere((c) => c.id == chainId,
        orElse: () => HabitChain(id: '', name: '', habitIds: []));
    int done = 0;
    for (final hId in chain.habitIds) {
      if (getCompletionForHabit(hId, date) != null) done++;
    }
    return (done, chain.habitIds.length);
  }

  // Leaderboard sorted by streak / score / xp
  List<Map<String, dynamic>> leaderboard({String sort = 'streak'}) {
    final active = habits.where((h) => !h.archived).toList();
    return active.map((h) {
      return {
        'habit': h,
        'streak': getStreakForHabit(h.id),
        'score': habitScore(h.id),
        'xp': (_xpPerCompletion * h.difficultyMultiplier * completions.where((c) => c.habitId == h.id && c.completed).length).round(),
      };
    }).toList()
      ..sort((a, b) {
        if (sort == 'score') return (b['score'] as double).compareTo(a['score'] as double);
        if (sort == 'xp') return (b['xp'] as int).compareTo(a['xp'] as int);
        return (b['streak'] as int).compareTo(a['streak'] as int);
      });
  }

  // Weekly frequency rate for frequency-target habits (xPerWeek)
  (int, int) weeklyFrequencyProgress(String habitId) {
    final h = habits.firstWhere((h) => h.id == habitId, orElse: () =>
        Habit(id: '', name: '', type: HabitType.boolean, section: HabitSection.custom, colorValue: 0));
    final target = h.frequencyTarget ?? 7;
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    int done = 0;
    for (int d = 0; d < 7; d++) {
      final ds = _dateFmt.format(weekStart.add(Duration(days: d)));
      if (getCompletionForHabit(habitId, ds) != null) done++;
    }
    return (done, target);
  }

  // --- Export 2.0 ---
  String exportData() => jsonEncode({
        'version': 2,
        'exportedAt': DateTime.now().toIso8601String(),
        'habits': habits.map((e) => e.toJson()).toList(),
        'completions': completions.map((e) => e.toJson()).toList(),
        'journal': journal.map((e) => e.toJson()).toList(),
        'chains': chains.map((e) => e.toJson()).toList(),
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
