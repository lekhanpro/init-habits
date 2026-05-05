import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/mode.dart';
import '../models/settings.dart';
import '../services/auth_service.dart';
import '../stores/habit_store.dart';
import '../theme/app_theme.dart';
import '../widgets/terminal_header.dart';
import '../models/challenge.dart';
import 'achievements_screen.dart';
import 'chains_screen.dart';
import 'challenges_screen.dart';
import 'journal_screen.dart';
import 'milestones_log_screen.dart';
import 'pomodoro_screen.dart';
import 'settings_screen.dart';
import 'templates_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<HabitStore>();
    final auth = context.watch<AuthService>();
    final theme = context.watch<ThemeController>();

    return Column(
      children: [
        const TerminalHeader(command: 'user.profile()', showDate: false),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // User info
              Text('// user session', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
              const SizedBox(height: 4),
              Text(
                auth.isAuthenticated ? (auth.user!.email ?? 'user@init.habits') : 'user@init.habits',
                style: TextStyle(color: AppColors.accentGreen, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 4, children: [
                _infoBadge('lv.${store.level} ${store.levelName}'),
                _infoBadge('${store.totalXp} xp'),
                _infoBadge('${store.activeHabits} habits'),
                _infoBadge('${store.totalCompletions} done'),
                _infoBadge(store.activeMode),
                if (store.isDemo)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text('DEMO',
                        style: TextStyle(
                            color: AppColors.accentOrange,
                            fontSize: 8,
                            fontWeight: FontWeight.w600)),
                  ),
              ]),
              const SizedBox(height: 20),

              // Theme switcher
              Text('// theme', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: AppThemeMode.values.map((m) {
                  final label = ThemeController.themeLabels[m] ?? m.name;
                  return _themeChip(context, theme, m, label);
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Notifications
              Text('// reminders', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: AppColors.bgSecondary,
                    border: Border.all(color: AppColors.borderPrimary),
                    borderRadius: BorderRadius.circular(4)),
                child: Row(children: [
                  Icon(Icons.notifications_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Smart reminders',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 12)),
                  ),
                  Switch(
                    value: store.notificationsEnabled,
                    activeColor: AppColors.accentGreen,
                    onChanged: (v) => store.setNotificationsEnabled(v),
                  ),
                ]),
              ),
              const SizedBox(height: 20),

              // Modes / Templates
              Text('// templates', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 2.5,
                children: allModes.map((mode) => _modeCard(context, store, mode)).toList(),
              ),
              const SizedBox(height: 20),

              // Quick links
              Text('// shortcuts', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
              const SizedBox(height: 8),
              _actionRow(Icons.book_outlined, 'Journal', r'$ journal.open()', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const JournalScreen()));
              }),
              _actionRow(Icons.emoji_events_outlined, 'Achievements',
                  '${store.unlockedAchievements.length} / 38 unlocked', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementsScreen()));
              }),
              _actionRow(Icons.link_rounded, 'Habit Chains',
                  '${store.chains.length} chains', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ChainsScreen()));
              }),
              _actionRow(Icons.dashboard_customize, 'Templates',
                  r'$ templates.list()', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TemplatesScreen()));
              }),
              _actionRow(Icons.flag_outlined, 'Milestones',
                  '${store.milestonesLog.length} reached', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MilestonesLogScreen()));
              }),
              _actionRow(Icons.flash_on, 'Challenges',
                  '${store.challenges.where((c) => c.status == ChallengeStatus.active).length} active', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ChallengesScreen()));
              }),
              _actionRow(Icons.timer_outlined, 'Pomodoro',
                  r'$ pomodoro.run()', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PomodoroScreen()));
              }),
              _actionRow(Icons.settings_outlined, 'Settings', r'$ settings.open()', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              }),

              const SizedBox(height: 12),
              Text('// data', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
              const SizedBox(height: 8),
              _actionRow(Icons.share, 'Export weekly summary (CSV)', r'$ data.export.weekly()', () async {
                final csv = store.weeklySummaryCsv();
                await Share.share(csv, subject: 'init.habits — weekly summary');
              }),
              _actionRow(Icons.download, 'Export full backup (JSON)', r'$ data.export.full()', () async {
                final json = store.exportData();
                await Share.share(json, subject: 'init.habits — backup');
              }),
              _actionRow(Icons.refresh, store.isDemo ? 'Fresh Start' : 'Reset All Data',
                  r'$ data.reset()', () {
                _confirmDialog(context, 'Reset all data?',
                    'This will clear all habits, completions, and journal entries.', () {
                  store.resetToDemo();
                });
              }, color: AppColors.accentRed),

              if (auth.isAuthenticated)
                _actionRow(Icons.logout, 'Sign Out', r'$ auth.logout()', () async {
                  await auth.signOut();
                }, color: AppColors.accentRed),

              const SizedBox(height: 20),
              Center(
                child: Text('init.habits v2.0.0 — built with discipline',
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 9)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _themeChip(BuildContext context, ThemeController theme, AppThemeMode mode, String label) {
    final selected = theme.mode == mode;
    final color = AppColors.accentGreen;
    return GestureDetector(
      onTap: () => theme.setMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : AppColors.bgTertiary,
          border: Border.all(
              color: selected ? color.withValues(alpha: 0.4) : AppColors.borderPrimary),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? color : AppColors.textSecondary, fontSize: 10)),
      ),
    );
  }

  Widget _infoBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.bgTertiary,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(text, style: TextStyle(color: AppColors.textSecondary, fontSize: 9)),
    );
  }

  Widget _modeCard(BuildContext context, HabitStore store, AppMode mode) {
    final isActive = store.activeMode == mode.id;
    final color = Color(mode.colorValue);

    return GestureDetector(
      onTap: () {
        _confirmDialog(context, 'Switch to ${mode.label}?',
            '${mode.description}\n${mode.presetHabits.length} habits', () {
          store.setMode(mode.id);
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.1) : AppColors.bgSecondary,
          border:
              Border.all(color: isActive ? color.withValues(alpha: 0.3) : AppColors.borderPrimary),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(children: [
              Icon(mode.icon, size: 12, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(mode.label,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
              ),
            ]),
            const SizedBox(height: 2),
            Text(mode.description,
                style: TextStyle(color: AppColors.textTertiary, fontSize: 8),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _actionRow(IconData icon, String label, String command, VoidCallback onTap,
      {Color? color}) {
    final c = color ?? AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.borderPrimary))),
        child: Row(children: [
          Icon(icon, size: 14, color: c),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(color: c, fontSize: 12)),
              Text(command, style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
            ]),
          ),
        ]),
      ),
    );
  }

  void _confirmDialog(BuildContext context, String title, String body, VoidCallback onConfirm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSecondary,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Text(body, style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderPrimary),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: Text('cancel',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    onConfirm();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen.withValues(alpha: 0.15),
                      border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: Text('confirm',
                        style: TextStyle(color: AppColors.accentGreen, fontSize: 12)),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
