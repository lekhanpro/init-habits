import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings.dart';
import '../stores/habit_store.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<HabitStore>();
    final theme = context.watch<ThemeController>();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back, size: 16, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 10),
                Text('> settings.config()',
                    style:
                        TextStyle(color: AppColors.accentGreen, fontSize: 11, letterSpacing: 1.2)),
              ]),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [

                  // --- THEME ---
                  _header('theme'),
                  _block([
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: AppThemeMode.values.map((m) {
                        final label = ThemeController.themeLabels[m] ?? m.name;
                        final selected = theme.mode == m;
                        return GestureDetector(
                          onTap: () => theme.setMode(m),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.accentGreen.withValues(alpha: 0.15)
                                  : AppColors.bgTertiary,
                              border: Border.all(
                                color: selected
                                    ? AppColors.accentGreen.withValues(alpha: 0.4)
                                    : AppColors.borderPrimary,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(label,
                                style: TextStyle(
                                  color: selected
                                      ? AppColors.accentGreen
                                      : AppColors.textSecondary,
                                  fontSize: 10,
                                )),
                          ),
                        );
                      }).toList(),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // --- TRACKING ---
                  _header('tracking'),
                  _block([
                    _row(
                      'grace period',
                      'completions before ${store.gracePeriodHours}:00 count for previous day',
                      trailing: DropdownButton<int>(
                        value: store.gracePeriodHours,
                        dropdownColor: AppColors.bgSecondary,
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 11),
                        underline: const SizedBox.shrink(),
                        items: [0, 1, 2, 3]
                            .map((v) => DropdownMenuItem(
                                  value: v,
                                  child: Text(v == 0 ? 'off' : '${v}h',
                                      style: TextStyle(
                                          color: AppColors.textPrimary, fontSize: 11)),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) store.setGracePeriodHours(v);
                        },
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // --- NOTIFICATIONS ---
                  _header('notifications'),
                  _block([
                    _row(
                      'smart reminders',
                      'schedule-aware habit reminders',
                      trailing: Switch(
                        value: store.notificationsEnabled,
                        activeColor: AppColors.accentGreen,
                        onChanged: (v) => store.setNotificationsEnabled(v),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // --- LEVEL INFO ---
                  _header('progress'),
                  _block([
                    _row('level', '${store.level} — ${store.levelName}'),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: store.xpProgress,
                        backgroundColor: AppColors.bgTertiary,
                        valueColor: AlwaysStoppedAnimation(AppColors.accentGreen),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                        '${store.xpIntoLevel} / ${store.xpForNextLevel} xp to next level',
                        style: TextStyle(color: AppColors.textTertiary, fontSize: 9)),
                  ]),
                  const SizedBox(height: 16),

                  // --- ABOUT ---
                  _header('about'),
                  _block([
                    _row('version', 'v2.0.0'),
                    _row('total xp', '${store.totalXp}'),
                    _row('habits tracked', '${store.habits.length}'),
                    _row('completions', '${store.totalCompletions}'),
                    _row('achievements', '${store.unlockedAchievements.length} / ${_totalAch}'),
                  ]),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const int _totalAch = 38;

  Widget _header(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text('// $title',
          style: TextStyle(color: AppColors.textTertiary, fontSize: 9, letterSpacing: 0.8)),
    );
  }

  Widget _block(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border.all(color: AppColors.borderPrimary),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _row(String label, String value, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(children: [
        Text('$label: ', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
        Expanded(child: Text(value, style: TextStyle(color: AppColors.textPrimary, fontSize: 11))),
        if (trailing != null) trailing,
      ]),
    );
  }
}
