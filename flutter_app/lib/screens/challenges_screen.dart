import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/challenge.dart';
import '../models/habit.dart';
import '../stores/habit_store.dart';
import '../theme/app_theme.dart';
import '../widgets/terminal_header.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  int _progressDays(Challenge c) {
    final now = DateTime.now();
    final start = DateTime(c.startDate.year, c.startDate.month, c.startDate.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(start).inDays;
    if (diff < 0) return 0;
    if (diff > c.durationDays) return c.durationDays;
    return diff;
  }

  String _bar(int progress, int total) {
    const width = 8;
    final filled = total == 0 ? 0 : ((progress / total) * width).round().clamp(0, width);
    return ('█' * filled) + ('░' * (width - filled));
  }

  Habit? _findHabit(HabitStore store, String habitId) {
    for (final h in store.habits) {
      if (h.id == habitId) return h;
    }
    return null;
  }

  Widget _sectionHeader(String label, Color color) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Text(
          label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w500),
        ),
      );

  Widget _emptyRow() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Text(
          '— none —',
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 10,
            fontStyle: FontStyle.italic,
          ),
        ),
      );

  Widget _challengeRow(BuildContext context, Challenge c, HabitStore store) {
    final habit = _findHabit(store, c.habitId);
    final habitName = habit?.name ?? 'unknown';
    final habitColor = habit != null ? Color(habit.colorValue) : AppColors.textSecondary;
    final progress = _progressDays(c);
    final total = c.durationDays;
    final bracketStyle = TextStyle(
      color: AppColors.textSecondary,
      fontSize: 11,
      fontFamilyFallback: const ['monospace'],
    );
    final tertiaryStyle = TextStyle(
      color: AppColors.textTertiary,
      fontSize: 11,
      fontFamilyFallback: const ['monospace'],
    );
    final habitStyle = TextStyle(
      color: habitColor,
      fontSize: 11,
      fontFamilyFallback: const ['monospace'],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: RichText(
        text: TextSpan(children: [
          TextSpan(text: '[${total}d] ', style: bracketStyle),
          TextSpan(text: habitName.padRight(16), style: habitStyle),
          TextSpan(text: ' progress ', style: bracketStyle),
          TextSpan(text: '$progress/$total ', style: tertiaryStyle),
          TextSpan(text: '[${_bar(progress, total)}]', style: bracketStyle),
        ]),
      ),
    );
  }

  void _openAddSheet(BuildContext context, HabitStore store) {
    final available = store.habits.where((h) => !h.archived).toList();
    String? selectedHabitId = available.isNotEmpty ? available.first.id : null;
    int duration = 7;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bgSecondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16 + MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'challenge.new()',
                  style: TextStyle(color: AppColors.accentGreen, fontSize: 12),
                ),
                const SizedBox(height: 16),
                Text('habit',
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.bgInput,
                    border: Border.all(color: AppColors.borderPrimary),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedHabitId,
                      dropdownColor: AppColors.bgSecondary,
                      style: TextStyle(
                          color: AppColors.textPrimary, fontSize: 12),
                      items: available
                          .map((h) => DropdownMenuItem<String>(
                                value: h.id,
                                child: Text(
                                  h.name,
                                  style: TextStyle(
                                      color: Color(h.colorValue), fontSize: 12),
                                ),
                              ))
                          .toList(),
                      onChanged: (v) => setSheetState(() => selectedHabitId = v),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text('duration',
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                const SizedBox(height: 6),
                Row(
                  children: [7, 14, 30].map((d) {
                    final selected = d == duration;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: GestureDetector(
                          onTap: () => setSheetState(() => duration = d),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.accentGreen.withValues(alpha: 0.1)
                                  : AppColors.bgInput,
                              border: Border.all(
                                color: selected
                                    ? AppColors.accentGreen
                                    : AppColors.borderPrimary,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${d}d',
                              style: TextStyle(
                                color: selected
                                    ? AppColors.accentGreen
                                    : AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: selectedHabitId == null
                        ? null
                        : () {
                            store.startChallenge(
                              habitId: selectedHabitId!,
                              durationDays: duration,
                            );
                            Navigator.pop(sheetCtx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AppColors.bgTertiary,
                                content: Text(
                                  '[ok] challenge started',
                                  style: TextStyle(
                                    color: AppColors.accentGreen,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            );
                          },
                    child: Text(
                      '[start challenge]',
                      style: TextStyle(
                        color: selectedHabitId == null
                            ? AppColors.textTertiary
                            : AppColors.accentGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<HabitStore>();
    final all = store.challenges;
    final active = all.where((c) => c.status == ChallengeStatus.active).toList();
    final completed =
        all.where((c) => c.status == ChallengeStatus.completed).toList();
    final failed = all.where((c) => c.status == ChallengeStatus.failed).toList();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(children: [
          const TerminalHeader(command: 'challenges.list()', showDate: false),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(children: [
                  Icon(Icons.arrow_back, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('back',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 11)),
                ]),
              ),
              const Spacer(),
              Text('${active.length} active',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
            ]),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                _sectionHeader('active', AppColors.accentGreen),
                if (active.isEmpty)
                  _emptyRow()
                else
                  ...active.map((c) => _challengeRow(context, c, store)),
                _sectionHeader('completed', AppColors.accentBlue),
                if (completed.isEmpty)
                  _emptyRow()
                else
                  ...completed.map((c) => _challengeRow(context, c, store)),
                _sectionHeader('failed', AppColors.accentRed),
                if (failed.isEmpty)
                  _emptyRow()
                else
                  ...failed.map((c) => _challengeRow(context, c, store)),
              ],
            ),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.bgTertiary,
        foregroundColor: AppColors.accentGreen,
        onPressed: () => _openAddSheet(context, store),
        child: const Icon(Icons.add),
      ),
    );
  }
}
