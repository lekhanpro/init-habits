import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../stores/habit_store.dart';
import '../theme/app_theme.dart';
import '../widgets/terminal_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<HabitStore>();
    if (!store.hasBooted) {
      return Center(child: Text('\$ booting...', style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)));
    }

    final date = store.selectedDate;
    final dateObj = DateTime.parse(date);
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final isToday = date == today;
    final activeHabits = store.habits.where((h) => !h.archived).toList();
    final completions = store.getCompletionsForDate(date);
    final totalDone = completions.length;
    final totalActive = activeHabits.length;
    final pct = totalActive > 0 ? totalDone / totalActive : 0.0;

    // Group by section
    final sections = <HabitSection, List<Habit>>{};
    for (final h in activeHabits) {
      sections.putIfAbsent(h.section, () => []).add(h);
    }

    return Column(
      children: [
        const TerminalHeader(),
        // Date nav
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => store.setSelectedDate(
                  DateFormat('yyyy-MM-dd').format(dateObj.subtract(const Duration(days: 1))),
                ),
                child: const Icon(Icons.chevron_left, color: AppColors.textSecondary, size: 20),
              ),
              Row(
                children: [
                  Text(
                    DateFormat('EEE, MMM d').format(dateObj),
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                  ),
                  if (isToday) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: const Text('TODAY', style: TextStyle(color: AppColors.accentGreen, fontSize: 8, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ],
              ),
              GestureDetector(
                onTap: () => store.setSelectedDate(
                  DateFormat('yyyy-MM-dd').format(dateObj.add(const Duration(days: 1))),
                ),
                child: const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
              ),
            ],
          ),
        ),
        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$totalDone/$totalActive habits', style: const TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                  Text('${(pct * 100).round()}%', style: const TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 3,
                  backgroundColor: AppColors.bgTertiary,
                  valueColor: const AlwaysStoppedAnimation(AppColors.accentGreen),
                ),
              ),
            ],
          ),
        ),
        // Habit sections
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              for (final section in HabitSection.values)
                if (sections.containsKey(section)) _buildSection(context, store, section, sections[section]!, date),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, HabitStore store, HabitSection section, List<Habit> habits, String date) {
    final cfg = SectionConfig.configs[section]!;
    final color = Color(cfg.colorValue);
    final done = habits.where((h) => store.getCompletionForHabit(h.id, date) != null).length;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(1))),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cfg.label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w500)),
                          Text(cfg.command, style: TextStyle(color: AppColors.textTertiary, fontSize: 9)),
                        ],
                      ),
                      Text('$done/${habits.length}', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(1),
              child: LinearProgressIndicator(
                value: habits.isEmpty ? 0 : done / habits.length,
                minHeight: 2,
                backgroundColor: AppColors.bgTertiary,
                valueColor: AlwaysStoppedAnimation(color.withValues(alpha: 0.6)),
              ),
            ),
          ),
          const SizedBox(height: 4),
          for (final habit in habits) _buildHabitRow(context, store, habit, date),
        ],
      ),
    );
  }

  void _showNoteDialog(BuildContext context, HabitStore store, Habit habit, String date) {
    final completion = store.getCompletionForHabit(habit.id, date);
    if (completion == null) return;
    final controller = TextEditingController(text: completion.note ?? '');
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSecondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('// note for "${habit.name}"', style: const TextStyle(color: AppColors.textTertiary, fontSize: 10)),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: 3,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
              decoration: const InputDecoration(hintText: 'Add a note...'),
            ),
            const SizedBox(height: 12),
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
                      store.updateCompletionNote(habit.id, date, controller.text.trim().isEmpty ? null : controller.text.trim());
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen.withValues(alpha: 0.15),
                        border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.center,
                      child: const Text('save', style: TextStyle(color: AppColors.accentGreen, fontSize: 12)),
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

  Widget _buildHabitRow(BuildContext context, HabitStore store, Habit habit, String date) {
    final completion = store.getCompletionForHabit(habit.id, date);
    final isCompleted = completion != null;
    final color = Color(habit.colorValue);
    final streak = store.getStreakForHabit(habit.id);
    final isNegative = habit.type == HabitType.negative;
    final hasNote = completion?.note != null && completion!.note!.isNotEmpty;

    return GestureDetector(
      onTap: () => store.toggleCompletion(habit.id, date),
      onLongPress: isCompleted ? () => _showNoteDialog(context, store, habit, date) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: isCompleted ? color.withValues(alpha: 0.15) : Colors.transparent,
                border: Border.all(color: isCompleted ? color : AppColors.borderSecondary, width: 1.5),
                borderRadius: BorderRadius.circular(2),
              ),
              child: isCompleted
                  ? Icon(isNegative ? Icons.close : Icons.check, size: 12, color: color)
                  : null,
            ),
            const SizedBox(width: 10),
            // Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: TextStyle(
                      color: isCompleted ? AppColors.textTertiary : AppColors.textPrimary,
                      fontSize: 12,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                      decorationColor: AppColors.textTertiary,
                    ),
                  ),
                  if (hasNote)
                    Text(completion!.note!, style: const TextStyle(color: AppColors.textTertiary, fontSize: 9), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            // Note indicator
            if (hasNote) ...[
              const SizedBox(width: 4),
              const Icon(Icons.note_outlined, size: 10, color: AppColors.textTertiary),
            ],
            // Type info
            if (habit.type == HabitType.timer && habit.targetMinutes != null)
              Text('${habit.targetMinutes}m', style: const TextStyle(color: AppColors.textTertiary, fontSize: 9)),
            if (habit.type == HabitType.count && habit.targetCount != null)
              Text('/${habit.targetCount}', style: const TextStyle(color: AppColors.textTertiary, fontSize: 9)),
            // Streak
            if (streak >= 2) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text('🔥$streak', style: TextStyle(fontSize: 9, color: color)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
