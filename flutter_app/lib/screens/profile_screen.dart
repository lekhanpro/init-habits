import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mode.dart';
import '../services/auth_service.dart';
import '../stores/habit_store.dart';
import '../theme/app_theme.dart';
import '../widgets/terminal_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<HabitStore>();
    final auth = context.watch<AuthService>();

    return Column(
      children: [
        const TerminalHeader(command: 'user.profile()', showDate: false),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // User info
              const Text('// user session', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
              const SizedBox(height: 4),
              Text(
                auth.isAuthenticated ? (auth.user!.email ?? 'user@init.habits') : 'user@init.habits',
                style: const TextStyle(color: AppColors.accentGreen, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _infoBadge('${store.activeHabits} habits'),
                  const SizedBox(width: 6),
                  _infoBadge('${store.totalCompletions} done'),
                  const SizedBox(width: 6),
                  _infoBadge(store.activeMode),
                  if (store.isDemo) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accentOrange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: const Text('DEMO', style: TextStyle(color: AppColors.accentOrange, fontSize: 8, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              // Modes
              const Text('// select_mode', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
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
              // Actions
              const Text('// config', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
              const SizedBox(height: 8),
              _actionRow(Icons.download, 'Export Data', '\$ data.export()', () {
                // TODO: share export
              }),
              _actionRow(Icons.refresh, store.isDemo ? 'Fresh Start' : 'Reset All Data', '\$ data.reset()', () {
                _confirmDialog(context, 'Reset all data?', 'This will clear all habits and completions.', () {
                  store.resetToDemo();
                });
              }, color: AppColors.accentRed),
              // Sign out
              if (auth.isAuthenticated)
                _actionRow(Icons.logout, 'Sign Out', '\$ auth.logout()', () async {
                  await auth.signOut();
                }, color: AppColors.accentRed),
              const SizedBox(height: 20),
              const Center(
                child: Text('init.habits v1.1.0 — built with discipline', style: TextStyle(color: AppColors.textTertiary, fontSize: 9)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.bgTertiary,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 9)),
    );
  }

  Widget _modeCard(BuildContext context, HabitStore store, AppMode mode) {
    final isActive = store.activeMode == mode.id;
    final color = Color(mode.colorValue);

    return GestureDetector(
      onTap: () {
        _confirmDialog(context, 'Switch to ${mode.label}?', '${mode.description}\n${mode.presetHabits.length} habits', () {
          store.setMode(mode.id);
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.1) : AppColors.bgSecondary,
          border: Border.all(color: isActive ? color.withValues(alpha: 0.3) : AppColors.borderPrimary),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(mode.icon, size: 12, color: color),
                const SizedBox(width: 4),
                Text(mode.label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 2),
            Text(mode.description, style: const TextStyle(color: AppColors.textTertiary, fontSize: 8), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _actionRow(IconData icon, String label, String command, VoidCallback onTap, {Color color = AppColors.textSecondary}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.borderPrimary))),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: color, fontSize: 12)),
                  Text(command, style: const TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDialog(BuildContext context, String title, String body, VoidCallback onConfirm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSecondary,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Text(body, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            const SizedBox(height: 16),
            Row(
              children: [
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
                      child: const Text('cancel', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
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
                      child: const Text('confirm', style: TextStyle(color: AppColors.accentGreen, fontSize: 12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
