import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/achievement.dart';
import '../stores/habit_store.dart';
import '../theme/app_theme.dart';
import '../widgets/terminal_header.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  int _progress(HabitStore store, Achievement a) {
    switch (a.metric) {
      case AchievementMetric.totalCompletions:
        return store.totalCompletions;
      case AchievementMetric.bestStreak:
        return store.bestStreak;
      case AchievementMetric.perfectDays:
        return store.perfectDays;
      case AchievementMetric.habitsCreated:
        return store.habits.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<HabitStore>();
    final unlocked = store.unlockedAchievements;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(children: [
          const TerminalHeader(command: 'achievements.list()', showDate: false),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(children: [
                  Icon(Icons.arrow_back, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('back', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ]),
              ),
              const Spacer(),
              Text('${unlocked.length}/${allAchievements.length} unlocked',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
            ]),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: allAchievements.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final a = allAchievements[i];
                final got = unlocked.contains(a.id);
                final v = _progress(store, a);
                final pct = (v / a.threshold).clamp(0.0, 1.0);
                final color = got ? AppColors.accentGreen : AppColors.textTertiary;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bgSecondary,
                    border: Border.all(
                        color: got
                            ? AppColors.accentGreen.withValues(alpha: 0.4)
                            : AppColors.borderPrimary),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(children: [
                    Text(a.emoji,
                        style: TextStyle(
                            fontSize: 22, color: got ? null : AppColors.textTertiary)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(
                            child: Text(a.label,
                                style: TextStyle(
                                    color: color, fontSize: 12, fontWeight: FontWeight.w500)),
                          ),
                          Text('${v.clamp(0, a.threshold)}/${a.threshold}',
                              style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                        ]),
                        const SizedBox(height: 2),
                        Text(a.description,
                            style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 3,
                            backgroundColor: AppColors.bgTertiary,
                            valueColor: AlwaysStoppedAnimation(
                                got ? AppColors.accentGreen : AppColors.accentCyan),
                          ),
                        ),
                      ]),
                    ),
                  ]),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
