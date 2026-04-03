import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class TerminalHeader extends StatelessWidget {
  final String command;
  final bool showDate;

  const TerminalHeader({super.key, this.command = 'habits.today()', this.showDate = true});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final displayName = auth.isAuthenticated ? (auth.user!.email?.split('@')[0] ?? 'user') : 'user';
    final now = DateTime.now();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(bottom: BorderSide(color: AppColors.borderPrimary)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(displayName, style: const TextStyle(color: AppColors.accentGreen, fontSize: 11)),
              const Text('@', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
              const Text('init.habits', style: TextStyle(color: AppColors.accentCyan, fontSize: 11)),
              const Text(':~\$', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
              const SizedBox(width: 4),
              Text(command, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
          if (showDate) ...[
            const SizedBox(height: 4),
            Text(
              '${DateFormat('EEEE, MMMM d, yyyy').format(now)} — ${DateFormat('HH:mm').format(now)}',
              style: const TextStyle(color: AppColors.textTertiary, fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }
}
