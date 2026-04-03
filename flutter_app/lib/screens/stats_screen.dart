import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../stores/habit_store.dart';
import '../theme/app_theme.dart';
import '../widgets/terminal_header.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<HabitStore>();

    return Column(
      children: [
        const TerminalHeader(command: 'stats.overview()'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatsGrid(store),
              const SizedBox(height: 20),
              _buildHeatmap(store),
              const SizedBox(height: 20),
              _buildWeekdayBars(store),
              const SizedBox(height: 20),
              _buildCategoryBreakdown(store),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(HabitStore store) {
    final stats = [
      ('Current Streak', '${store.currentStreak}', 'days'),
      ('Best Streak', '${store.bestStreak}', 'days'),
      ('7-Day Rate', '${store.rate7d.round()}', '%'),
      ('Perfect Days', '${store.perfectDays}', '/90d'),
      ('Total Done', '${store.totalCompletions}', ''),
      ('Active Habits', '${store.activeHabits}', ''),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.2,
      children: stats.map((s) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          border: Border.all(color: AppColors.borderPrimary),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(s.$1, style: const TextStyle(color: AppColors.textTertiary, fontSize: 9)),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(s.$2, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
                if (s.$3.isNotEmpty) ...[
                  const SizedBox(width: 2),
                  Text(s.$3, style: const TextStyle(color: AppColors.textTertiary, fontSize: 9)),
                ],
              ],
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildHeatmap(HabitStore store) {
    final now = DateTime.now();
    const weeks = 20;
    const days = 7;
    final heatColors = [AppColors.heatmap0, AppColors.heatmap1, AppColors.heatmap2, AppColors.heatmap3, AppColors.heatmap4];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('// contribution_heatmap', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
        const SizedBox(height: 8),
        SizedBox(
          height: days * 12.0,
          child: Row(
            children: List.generate(weeks, (w) {
              return Column(
                children: List.generate(days, (d) {
                  final daysAgo = (weeks - 1 - w) * 7 + (6 - d);
                  final date = now.subtract(Duration(days: daysAgo));
                  final dateStr = DateFormat('yyyy-MM-dd').format(date);
                  final active = store.habits.where((h) => !h.archived).length;
                  final done = store.getCompletionsForDate(dateStr).length;
                  final ratio = active > 0 ? done / active : 0.0;
                  final level = ratio == 0 ? 0 : ratio <= 0.25 ? 1 : ratio <= 0.5 ? 2 : ratio <= 0.75 ? 3 : 4;

                  return Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: heatColors[level],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              );
            }),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('less ', style: TextStyle(color: AppColors.textTertiary, fontSize: 8)),
            for (final c in heatColors)
              Container(
                width: 8, height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(1)),
              ),
            const Text(' more', style: TextStyle(color: AppColors.textTertiary, fontSize: 8)),
          ],
        ),
      ],
    );
  }

  Widget _buildWeekdayBars(HabitStore store) {
    final now = DateTime.now();
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final counts = List.filled(7, 0);
    final totals = List.filled(7, 0);

    for (int d = 0; d < 90; d++) {
      final date = now.subtract(Duration(days: d));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final dow = date.weekday - 1; // 0=Mon
      final active = store.habits.where((h) => !h.archived).length;
      totals[dow] += active;
      counts[dow] += store.getCompletionsForDate(dateStr).length;
    }

    final rates = List.generate(7, (i) => totals[i] > 0 ? counts[i] / totals[i] : 0.0);
    final maxRate = rates.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('// weekday_completion', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final h = maxRate > 0 ? (rates[i] / maxRate * 60) : 0.0;
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 20,
                    height: h,
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(dayNames[i], style: const TextStyle(color: AppColors.textTertiary, fontSize: 8)),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(HabitStore store) {
    final now = DateTime.now();
    final sectionStats = <HabitSection, (int, int)>{};

    for (final section in HabitSection.values) {
      final sectionHabits = store.habits.where((h) => h.section == section && !h.archived).toList();
      if (sectionHabits.isEmpty) continue;
      int total = 0, done = 0;
      for (int d = 0; d < 30; d++) {
        final dateStr = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: d)));
        total += sectionHabits.length;
        done += sectionHabits.where((h) => store.getCompletionForHabit(h.id, dateStr) != null).length;
      }
      sectionStats[section] = (done, total);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('// category_breakdown (30d)', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
        const SizedBox(height: 8),
        for (final entry in sectionStats.entries)
          _buildCategoryBar(entry.key, entry.value.$1, entry.value.$2),
      ],
    );
  }

  Widget _buildCategoryBar(HabitSection section, int done, int total) {
    final cfg = SectionConfig.configs[section]!;
    final color = Color(cfg.colorValue);
    final pct = total > 0 ? done / total : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(cfg.label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
              Text('${(pct * 100).round()}%', style: const TextStyle(color: AppColors.textTertiary, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 4,
              backgroundColor: AppColors.bgTertiary,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
