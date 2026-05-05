import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../stores/habit_store.dart';
import '../theme/app_theme.dart';
import '../widgets/terminal_header.dart';
import '../widgets/habit_timer_sheet.dart';
import '../widgets/score_sparkline.dart';
import 'add_habit_screen.dart';
import 'habit_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _taglines = [
    'discipline > motivation.',
    'small reps. compound interest.',
    'show up. that\'s the whole game.',
    'consistency unlocks everything.',
    'one rep. one day. one streak.',
    'be unreasonably consistent.',
    'the system is the goal.',
  ];

  String _tagline() {
    final i = DateTime.now().weekday % _taglines.length;
    return _taglines[i];
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<HabitStore>();
    if (!store.hasBooted) {
      return Center(
          child: Text(r'$ booting...',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 11)));
    }

    final date = store.selectedDate;
    final dateObj = DateTime.parse(date);
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final isToday = date == today;
    final activeHabits = store.dueHabitsForDate(date);
    final completions = store.dueCompletionsForDate(date);
    final totalDone = completions.length;
    final totalActive = activeHabits.length;
    final pct = totalActive > 0 ? totalDone / totalActive : 0.0;

    final sections = <HabitSection, List<Habit>>{};
    for (final h in activeHabits) {
      sections.putIfAbsent(h.section, () => []).add(h);
    }

    return Column(
      children: [
        const TerminalHeader(),
        // Tagline + meta
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(children: [
            Expanded(
              child: Text('// ${_tagline()}',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
            ),
            _metaChip('lv.${store.level}', AppColors.accentCyan),
            const SizedBox(width: 4),
            _metaChip('🔥${store.currentStreak}', AppColors.accentOrange),
            const SizedBox(width: 4),
            _metaChip('★${store.totalCompletions}', AppColors.accentYellow),
          ]),
        ),
        // XP bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(children: [
            Text('xp ', style: TextStyle(color: AppColors.textTertiary, fontSize: 9)),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: store.xpIntoLevel / store.xpForNextLevel,
                  minHeight: 3,
                  backgroundColor: AppColors.bgTertiary,
                  valueColor: AlwaysStoppedAnimation(AppColors.accentCyan),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text('${store.xpIntoLevel}/${store.xpForNextLevel}',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 9)),
          ]),
        ),
        // Weekly strip
        _WeekStrip(selectedDate: date, onTap: store.setSelectedDate, store: store),
        // Date nav
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => store.setSelectedDate(
                    DateFormat('yyyy-MM-dd').format(dateObj.subtract(const Duration(days: 1)))),
                child: Icon(Icons.chevron_left, color: AppColors.textSecondary, size: 20),
              ),
              Row(children: [
                Text(DateFormat('EEE, MMM d').format(dateObj),
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 12)),
                if (isToday) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text('TODAY',
                        style: TextStyle(
                            color: AppColors.accentGreen, fontSize: 8, fontWeight: FontWeight.w600)),
                  ),
                ],
              ]),
              GestureDetector(
                onTap: () => store.setSelectedDate(
                    DateFormat('yyyy-MM-dd').format(dateObj.add(const Duration(days: 1)))),
                child: Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('$totalDone/$totalActive habits',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
              Text('${(pct * 100).round()}%',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
            ]),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 3,
                backgroundColor: AppColors.bgTertiary,
                valueColor: AlwaysStoppedAnimation(AppColors.accentGreen),
              ),
            ),
          ]),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              for (final section in HabitSection.values)
                if (sections.containsKey(section))
                  _buildSection(context, store, section, sections[section]!, date),
              if (activeHabits.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(r'$ no habits due. tap + to add one.',
                        style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metaChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildSection(BuildContext context, HabitStore store, HabitSection section,
      List<Habit> habits, String date) {
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
            child: Row(children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(1)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(cfg.label,
                        style: TextStyle(
                            color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w500)),
                    Text(cfg.command,
                        style: TextStyle(color: AppColors.textTertiary, fontSize: 9)),
                  ]),
                  Text('[$done/${habits.length}]',
                      style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                ]),
              ),
            ]),
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

  Widget _buildHabitRow(BuildContext context, HabitStore store, Habit habit, String date) {
    final isCompleted = store.getCompletionForHabit(habit.id, date) != null;
    final color = Color(habit.colorValue);
    final streak = store.getStreakForHabit(habit.id);
    final isNegative = habit.type == HabitType.negative;
    final isTimer = habit.type == HabitType.timer;
    final score = store.habitScore(habit.id);
    final sparkScores = store.habitScoreHistory(habit.id, days: 14);
    final scorePct = (score * 100).round();

    return GestureDetector(
      onTap: () {
        if (isTimer && !isCompleted) {
          HabitTimerSheet.show(context, habit, date);
        } else {
          store.toggleCompletion(habit.id, date);
        }
      },
      onLongPress: () => _rowActions(context, habit),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: [
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
          Expanded(
            child: Text(
              habit.name,
              style: TextStyle(
                color: isCompleted ? AppColors.textTertiary : AppColors.textPrimary,
                fontSize: 12,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                decorationColor: AppColors.textTertiary,
              ),
            ),
          ),
          if (habit.reminderMinutes != null) ...[
            Icon(Icons.alarm, size: 10, color: AppColors.textTertiary),
            const SizedBox(width: 4),
          ],
          if (isTimer && habit.targetMinutes != null)
            Text('${habit.targetMinutes}m', style: TextStyle(color: AppColors.textTertiary, fontSize: 9)),
          if (habit.type == HabitType.count && habit.targetCount != null)
            Text('/${habit.targetCount}', style: TextStyle(color: AppColors.textTertiary, fontSize: 9)),
          if (sparkScores.length >= 2) ...[
            const SizedBox(width: 8),
            ScoreSparkline(scores: sparkScores, color: color),
            const SizedBox(width: 4),
            Text('$scorePct%',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 9)),
          ],
          if (habit.shieldsRemaining > 0) ...[
            const SizedBox(width: 6),
            Text('${'🛡' * habit.shieldsRemaining}',
                style: const TextStyle(fontSize: 9)),
          ],
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
        ]),
      ),
    );
  }

  void _rowActions(BuildContext context, Habit habit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSecondary,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(color: Color(habit.colorValue), borderRadius: BorderRadius.circular(1))),
              const SizedBox(width: 8),
              Expanded(child: Text(habit.name, style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500))),
            ]),
          ),
          _action(ctx, Icons.show_chart, 'Open detail', () {
            Navigator.pop(ctx);
            Navigator.push(context, MaterialPageRoute(builder: (_) => HabitDetailScreen(habitId: habit.id)));
          }),
          _action(ctx, Icons.edit, 'Edit', () {
            Navigator.pop(ctx);
            Navigator.push(context, MaterialPageRoute(builder: (_) => AddHabitScreen(existing: habit)));
          }),
          _action(ctx, habit.archived ? Icons.unarchive : Icons.archive, habit.archived ? 'Unarchive' : 'Archive', () {
            Navigator.pop(ctx);
            context.read<HabitStore>().archiveHabit(habit.id, archived: !habit.archived);
          }),
          _action(ctx, Icons.delete_outline, 'Delete', () {
            Navigator.pop(ctx);
            context.read<HabitStore>().deleteHabit(habit.id);
          }, color: AppColors.accentRed),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Widget _action(BuildContext ctx, IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Icon(icon, size: 14, color: color ?? AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: color ?? AppColors.textPrimary, fontSize: 12)),
        ]),
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  final String selectedDate;
  final void Function(String) onTap;
  final HabitStore store;
  const _WeekStrip({required this.selectedDate, required this.onTap, required this.store});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final fmt = DateFormat('yyyy-MM-dd');
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: List.generate(7, (i) {
          final d = monday.add(Duration(days: i));
          final ds = fmt.format(d);
          final isSelected = ds == selectedDate;
          final isToday = ds == fmt.format(today);
          final active = store.dueCountForDate(ds);
          final done = store.dueCompletionsForDate(ds).length;
          final ratio = active > 0 ? done / active : 0.0;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(ds),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                child: Column(children: [
                  Text(dayLabels[i],
                      style: TextStyle(
                          color: isToday ? AppColors.accentGreen : AppColors.textTertiary,
                          fontSize: 9)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accentGreen.withValues(alpha: 0.12)
                          : AppColors.bgSecondary,
                      border: Border.all(
                          color: isSelected
                              ? AppColors.accentGreen.withValues(alpha: 0.5)
                              : AppColors.borderPrimary),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(children: [
                      Text('${d.day}',
                          style: TextStyle(
                              color: isSelected ? AppColors.accentGreen : AppColors.textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Container(
                        width: 14,
                        height: 3,
                        decoration: BoxDecoration(
                          color: ratio == 0
                              ? AppColors.bgTertiary
                              : ratio < 0.5
                                  ? AppColors.accentGreen.withValues(alpha: 0.3)
                                  : ratio < 1
                                      ? AppColors.accentGreen.withValues(alpha: 0.6)
                                      : AppColors.accentGreen,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ]),
                  ),
                ]),
              ),
            ),
          );
        }),
      ),
    );
  }
}
