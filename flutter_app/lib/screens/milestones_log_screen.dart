import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../models/milestone.dart';
import '../stores/habit_store.dart';
import '../theme/app_theme.dart';
import '../widgets/terminal_header.dart';

class MilestonesLogScreen extends StatelessWidget {
  const MilestonesLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<HabitStore>();
    final log = List<Milestone>.from(store.milestonesLog)
      ..sort((a, b) => b.achievedAt.compareTo(a.achievedAt));
    final dateFmt = DateFormat('yyyy-MM-dd');

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(children: [
          const TerminalHeader(command: 'cat milestones.log', showDate: false),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(children: [
                  Icon(Icons.arrow_back, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('back',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ]),
              ),
              const Spacer(),
              Text('${log.length} milestone${log.length == 1 ? '' : 's'}',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
            ]),
          ),
          Expanded(
            child: log.isEmpty
                ? Center(
                    child: Text(
                      'no milestones yet — keep going.',
                      style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: log.length,
                    itemBuilder: (_, i) {
                      final m = log[i];
                      Habit? habit;
                      for (final h in store.habits) {
                        if (h.id == m.habitId) {
                          habit = h;
                          break;
                        }
                      }
                      final habitColor = habit != null
                          ? Color(habit.colorValue)
                          : AppColors.textPrimary;
                      final habitLabel = (habit?.name ?? m.habitName);
                      final paddedName = habitLabel.length >= 20
                          ? '${habitLabel.substring(0, 19)} '
                          : habitLabel.padRight(20, ' ');

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text.rich(
                          TextSpan(
                            style: GoogleFonts.jetBrainsMono(
                              color: AppColors.textPrimary,
                              fontSize: 11,
                            ),
                            children: [
                              TextSpan(
                                text: dateFmt.format(m.achievedAt),
                                style: GoogleFonts.jetBrainsMono(
                                  color: AppColors.textTertiary,
                                  fontSize: 11,
                                ),
                              ),
                              const TextSpan(text: '  '),
                              TextSpan(
                                text: paddedName,
                                style: GoogleFonts.jetBrainsMono(
                                  color: habitColor,
                                  fontSize: 11,
                                ),
                              ),
                              const TextSpan(text: '  '),
                              TextSpan(
                                text: '${m.count} days',
                                style: GoogleFonts.jetBrainsMono(
                                  color: AppColors.accentGreen,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ]),
      ),
    );
  }
}
