import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../stores/habit_store.dart';
import '../theme/app_theme.dart';
import '../widgets/terminal_header.dart';
import 'add_habit_screen.dart';

class HabitDetailScreen extends StatelessWidget {
  final String habitId;
  const HabitDetailScreen({super.key, required this.habitId});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<HabitStore>();
    final habit = store.habits.firstWhere(
      (h) => h.id == habitId,
      orElse: () => Habit(
          id: habitId,
          name: 'unknown',
          type: HabitType.boolean,
          section: HabitSection.custom,
          colorValue: 0xFF6B6B80),
    );
    final color = Color(habit.colorValue);
    final streak = store.getStreakForHabit(habit.id);
    final best = store.getBestStreakForHabit(habit.id);
    final history = store.getDailyHistoryForHabit(habit.id, days: 30);
    final total = history.fold<int>(0, (a, b) => a + b);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            TerminalHeader(command: 'habit.inspect("${habit.name}")', showDate: false),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(children: [
                      Icon(Icons.arrow_back, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('back', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 8),
                    Expanded(child: Text(habit.name, style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600))),
                    GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => AddHabitScreen(existing: habit))),
                      child: Icon(Icons.edit, size: 16, color: AppColors.textSecondary),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  Row(children: [
                    _stat('Streak', '$streak', 'd', color),
                    const SizedBox(width: 8),
                    _stat('Best', '$best', 'd', color),
                    const SizedBox(width: 8),
                    _stat('30d done', '$total', '', color),
                  ]),
                  const SizedBox(height: 16),
                  // Score bar
                  Row(children: [
                    Text('// habit_score: ',
                        style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                    Text(store.habitScoreBar(habit.id),
                        style: TextStyle(
                            color: AppColors.accentGreen,
                            fontSize: 10,
                            letterSpacing: -1,
                            fontFamily: 'monospace')),
                  ]),
                  const SizedBox(height: 8),
                  // Difficulty + shield badges
                  Row(children: [
                    _badge(
                      label: habit.difficulty.name,
                      color: _difficultyColor(habit.difficulty),
                    ),
                    const SizedBox(width: 6),
                    if (habit.shieldsRemaining > 0)
                      _badge(
                        label:
                            '${'🛡' * habit.shieldsRemaining} shield${habit.shieldsRemaining > 1 ? 's' : ''}',
                        color: AppColors.accentCyan,
                      ),
                    if (habit.chainId != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: _badge(label: '🔗 chained', color: AppColors.accentPurple),
                      ),
                  ]),
                  const SizedBox(height: 8),
                  // Sparkline: 14-day score history
                  Text('// score_14d',
                      style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                  const SizedBox(height: 4),
                  _sparkline(store.habitScoreHistory(habit.id, days: 14), color),
                  const SizedBox(height: 16),
                  Text('// trend_30d', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                  const SizedBox(height: 8),
                  SizedBox(height: 140, child: _trend(history, color)),
                  const SizedBox(height: 24),
                  Text('// last_year', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                  const SizedBox(height: 8),
                  _miniHeatmap(store, habit),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _difficultyColor(HabitDifficulty d) {
    switch (d) {
      case HabitDifficulty.easy:
        return AppColors.accentBlue;
      case HabitDifficulty.normal:
        return AppColors.accentGreen;
      case HabitDifficulty.hard:
        return AppColors.accentYellow;
      case HabitDifficulty.extreme:
        return AppColors.accentRed;
    }
  }

  Widget _badge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 9)),
    );
  }

  Widget _sparkline(List<double> scores, Color color) {
    if (scores.isEmpty) return const SizedBox.shrink();
    final max = scores.reduce((a, b) => a > b ? a : b).clamp(0.01, 1.0);
    return SizedBox(
      height: 36,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: scores.map((s) {
          final h = (s / max * 36).clamp(2.0, 36.0);
          return Expanded(
            child: Container(
              height: h,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _stat(String label, String value, String suffix, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          border: Border.all(color: AppColors.borderPrimary),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: AppColors.textTertiary, fontSize: 9)),
          const SizedBox(height: 2),
          Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
            Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w600)),
            if (suffix.isNotEmpty) ...[
              const SizedBox(width: 2),
              Text(suffix, style: TextStyle(color: AppColors.textTertiary, fontSize: 9)),
            ],
          ]),
        ]),
      ),
    );
  }

  Widget _trend(List<int> history, Color color) {
    final spots = <FlSpot>[];
    int cum = 0;
    for (int i = 0; i < history.length; i++) {
      cum += history[i];
      spots.add(FlSpot(i.toDouble(), cum.toDouble()));
    }
    return LineChart(LineChartData(
      gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: AppColors.borderPrimary, strokeWidth: 0.5)),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      minY: 0,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: color,
          barWidth: 2,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.15)),
        ),
      ],
    ));
  }

  Widget _miniHeatmap(HabitStore store, Habit habit) {
    final now = DateTime.now();
    const weeks = 26;
    const days = 7;
    final fmt = DateFormat('yyyy-MM-dd');
    return SizedBox(
      height: days * 12.0,
      child: Row(
        children: List.generate(weeks, (w) {
          return Column(
            children: List.generate(days, (d) {
              final daysAgo = (weeks - 1 - w) * 7 + (6 - d);
              final date = now.subtract(Duration(days: daysAgo));
              final done = store.getCompletionForHabit(habit.id, fmt.format(date)) != null;
              return Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: done ? Color(habit.colorValue) : AppColors.bgTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          );
        }),
      ),
    );
  }
}
