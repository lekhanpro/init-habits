import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../stores/habit_store.dart';
import '../theme/app_theme.dart';
import '../widgets/terminal_header.dart';
import 'habit_detail_screen.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  int _periodIdx = 1; // default 30d

  static const _periods = [
    ('14d', 14),
    ('30d', 30),
    ('60d', 60),
    ('90d', 90),
    ('180d', 180),
    ('365d', 365),
    ('all', 9999),
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<HabitStore>();

    return Column(
      children: [
        const TerminalHeader(command: 'stats.overview()'),
        TabBar(
          controller: _tab,
          isScrollable: true,
          indicatorColor: AppColors.accentGreen,
          indicatorWeight: 1,
          labelColor: AppColors.accentGreen,
          unselectedLabelColor: AppColors.textTertiary,
          labelStyle: const TextStyle(fontSize: 11),
          tabs: const [
            Tab(text: 'overview'),
            Tab(text: 'month'),
            Tab(text: 'week'),
            Tab(text: 'habits'),
          ],
        ),
        Expanded(
          child: TabBarView(controller: _tab, children: [
            _overviewTab(store),
            _monthTab(store),
            _weekTab(store),
            _habitsTab(store),
          ]),
        ),
      ],
    );
  }

  Widget _overviewTab(HabitStore store) {
    final period = _periods[_periodIdx];
    return ListView(padding: const EdgeInsets.all(16), children: [
      _quickGlance(store),
      const SizedBox(height: 20),
      _streaks(store),
      const SizedBox(height: 20),
      Text('// completion_rates', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
      const SizedBox(height: 8),
      _periodChips(),
      const SizedBox(height: 8),
      _completionRates(store, period.$2),
      const SizedBox(height: 20),
      Text('// contribution_year', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
      const SizedBox(height: 8),
      _yearHeatmap(store),
      const SizedBox(height: 20),
      _weekdayBars(store),
    ]);
  }

  Widget _monthTab(HabitStore store) {
    final now = DateTime.now();
    final firstOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final fmt = DateFormat('yyyy-MM-dd');
    int monthDone = 0, monthTotal = 0;
    for (int d = 0; d < daysInMonth; d++) {
      final date = firstOfMonth.add(Duration(days: d));
      if (date.isAfter(now)) break;
      final dateStr = fmt.format(date);
      monthTotal += store.dueCountForDate(dateStr);
      monthDone += store.dueCompletionsForDate(dateStr).length;
    }
    final pct = monthTotal > 0 ? monthDone / monthTotal * 100 : 0;

    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('// ${DateFormat('MMMM yyyy').format(now)}',
          style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
      const SizedBox(height: 8),
      Row(children: [
        _statCard('Completion', '${pct.round()}', '%'),
        const SizedBox(width: 8),
        _statCard('Done', '$monthDone', ''),
        const SizedBox(width: 8),
        _statCard('Days', '${now.day}', '/$daysInMonth'),
      ]),
      const SizedBox(height: 20),
      Text('// month_grid', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
      const SizedBox(height: 8),
      _monthGrid(store, firstOfMonth, daysInMonth),
    ]);
  }

  Widget _weekTab(HabitStore store) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final fmt = DateFormat('yyyy-MM-dd');
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    int weekDone = 0, weekTotal = 0;
    final perDay = <int>[];
    for (int i = 0; i < 7; i++) {
      final d = monday.add(Duration(days: i));
      final dateStr = fmt.format(d);
      final done = store.dueCompletionsForDate(dateStr).length;
      weekTotal += store.dueCountForDate(dateStr);
      weekDone += done;
      perDay.add(done);
    }
    final pct = weekTotal > 0 ? weekDone / weekTotal * 100 : 0;
    final maxDone = perDay.fold<int>(0, (a, b) => a > b ? a : b);

    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('// week_of ${DateFormat('MMM d').format(monday)}',
          style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
      const SizedBox(height: 8),
      Row(children: [
        _statCard('Rate', '${pct.round()}', '%'),
        const SizedBox(width: 8),
        _statCard('Done', '$weekDone', ''),
        const SizedBox(width: 8),
        _statCard('Streak', '${store.currentStreak}', 'd'),
      ]),
      const SizedBox(height: 20),
      Text('// per_day', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
      const SizedBox(height: 8),
      SizedBox(
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(7, (i) {
            final h = maxDone > 0 ? (perDay[i] / maxDone * 80) : 0.0;
            return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text('${perDay[i]}', style: TextStyle(color: AppColors.textTertiary, fontSize: 8)),
              const SizedBox(height: 2),
              Container(
                width: 22,
                height: h,
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 4),
              Text(dayNames[i],
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 9)),
            ]);
          }),
        ),
      ),
    ]);
  }

  Widget _habitsTab(HabitStore store) {
    final habits = store.habits.where((h) => !h.archived).toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('// per_habit_rankings', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
      const SizedBox(height: 8),
      for (final h in habits)
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => HabitDetailScreen(habitId: h.id))),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              border: Border.all(color: AppColors.borderPrimary),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                    color: Color(h.colorValue), borderRadius: BorderRadius.circular(1)),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(h.name, style: TextStyle(color: AppColors.textPrimary, fontSize: 12))),
              Text('best ${store.getBestStreakForHabit(h.id)}d',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
              const SizedBox(width: 8),
              Text('🔥${store.getStreakForHabit(h.id)}',
                  style: TextStyle(color: AppColors.accentOrange, fontSize: 11)),
            ]),
          ),
        ),
      if (habits.isEmpty)
        Padding(
          padding: const EdgeInsets.all(24),
          child: Center(child: Text(r'$ no habits yet.', style: TextStyle(color: AppColors.textTertiary, fontSize: 11))),
        ),
    ]);
  }

  // ---- shared widgets ----

  Widget _quickGlance(HabitStore store) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('// quick_glance', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
      const SizedBox(height: 8),
      Row(children: [
        _statCard('Days tracked', '${store.daysTracked()}', ''),
        const SizedBox(width: 8),
        _statCard('Avg %', '${store.rateForLast(30).round()}', '%'),
        const SizedBox(width: 8),
        _statCard('Perfect days', '${store.perfectDays}', ''),
      ]),
    ]);
  }

  Widget _streaks(HabitStore store) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('// streaks', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
      const SizedBox(height: 8),
      Row(children: [
        _statCard('Current', '${store.currentStreak}', 'd'),
        const SizedBox(width: 8),
        _statCard('Best', '${store.bestStreak}', 'd'),
      ]),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          border: Border.all(color: AppColors.borderPrimary),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(children: [
          Icon(Icons.local_fire_department, size: 14, color: AppColors.accentOrange),
          const SizedBox(width: 8),
          Expanded(
              child: Text('Top habit: ${store.topHabitStreakLabel}',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 11))),
        ]),
      ),
    ]);
  }

  Widget _completionRates(HabitStore store, int days) {
    final pct = days >= 9999 ? store.rateForLast(store.daysTracked().clamp(1, 3650)) : store.rateForLast(days);
    final green = store.greenDays(days: days >= 9999 ? store.daysTracked().clamp(1, 3650) : days);
    return Row(children: [
      _statCard('Rate', '${pct.round()}', '%'),
      const SizedBox(width: 8),
      _statCard('Green days', '$green', ''),
      const SizedBox(width: 8),
      _statCard('Wknd avg', '${store.weekendAvg().round()}', '%'),
    ]);
  }

  Widget _periodChips() {
    return SizedBox(
      height: 28,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _periods.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final selected = i == _periodIdx;
          return GestureDetector(
            onTap: () => setState(() => _periodIdx = i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: selected ? AppColors.accentGreen.withValues(alpha: 0.15) : AppColors.bgTertiary,
                border: Border.all(
                    color: selected ? AppColors.accentGreen.withValues(alpha: 0.4) : AppColors.borderPrimary),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(_periods[i].$1,
                  style: TextStyle(
                      color: selected ? AppColors.accentGreen : AppColors.textSecondary, fontSize: 10)),
            ),
          );
        },
      ),
    );
  }

  Widget _statCard(String label, String value, String suffix) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          border: Border.all(color: AppColors.borderPrimary),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: AppColors.textTertiary, fontSize: 9)),
          const SizedBox(height: 2),
          Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
            Text(value, style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
            if (suffix.isNotEmpty) ...[
              const SizedBox(width: 2),
              Text(suffix, style: TextStyle(color: AppColors.textTertiary, fontSize: 9)),
            ],
          ]),
        ]),
      ),
    );
  }

  Widget _yearHeatmap(HabitStore store) {
    final now = DateTime.now();
    const weeks = 52;
    const days = 7;
    final fmt = DateFormat('yyyy-MM-dd');
    final heatColors = [
      AppColors.heatmap0,
      AppColors.heatmap1,
      AppColors.heatmap2,
      AppColors.heatmap3,
      AppColors.heatmap4
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        height: days * 12.0 + 16,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(weeks, (w) {
            return Column(
              children: List.generate(days, (d) {
                final daysAgo = (weeks - 1 - w) * 7 + (6 - d);
                final date = now.subtract(Duration(days: daysAgo));
                final dateStr = fmt.format(date);
                final active = store.dueCountForDate(dateStr);
                final done = store.dueCompletionsForDate(dateStr).length;
                final ratio = active > 0 ? done / active : 0.0;
                final level = ratio == 0
                    ? 0
                    : ratio <= 0.25
                        ? 1
                        : ratio <= 0.5
                            ? 2
                            : ratio <= 0.75
                                ? 3
                                : 4;
                return Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(color: heatColors[level], borderRadius: BorderRadius.circular(2)),
                );
              }),
            );
          }),
        ),
      ),
    );
  }

  Widget _weekdayBars(HabitStore store) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final rates = List.generate(7, (i) => store.weekdayRate(i + 1));
    final maxRate = rates.reduce((a, b) => a > b ? a : b);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('// weekday_completion', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
      const SizedBox(height: 8),
      SizedBox(
        height: 90,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(7, (i) {
            final h = maxRate > 0 ? (rates[i] / maxRate * 60) : 0.0;
            return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text('${rates[i].round()}%',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 8)),
              const SizedBox(height: 2),
              Container(
                width: 22,
                height: h,
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 4),
              Text(dayNames[i],
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 9)),
            ]);
          }),
        ),
      ),
    ]);
  }

  Widget _monthGrid(HabitStore store, DateTime firstOfMonth, int daysInMonth) {
    final fmt = DateFormat('yyyy-MM-dd');
    final startWeekday = firstOfMonth.weekday; // 1=Mon
    final cells = <Widget>[];
    for (int i = 1; i < startWeekday; i++) {
      cells.add(const SizedBox.shrink());
    }
    final now = DateTime.now();
    for (int d = 0; d < daysInMonth; d++) {
      final date = firstOfMonth.add(Duration(days: d));
      final dateStr = fmt.format(date);
      final active = store.dueCountForDate(dateStr);
      final done = store.dueCompletionsForDate(dateStr).length;
      final ratio = active > 0 ? done / active : 0.0;
      final level = ratio == 0 ? 0 : ratio <= 0.5 ? 1 : ratio < 1 ? 2 : 3;
      final colors = [AppColors.bgTertiary, AppColors.accentGreen.withValues(alpha: 0.25), AppColors.accentGreen.withValues(alpha: 0.55), AppColors.accentGreen];
      final isFuture = date.isAfter(now);
      cells.add(Container(
        margin: const EdgeInsets.all(2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isFuture ? AppColors.bgTertiary.withValues(alpha: 0.3) : colors[level],
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: AppColors.borderPrimary, width: 0.5),
        ),
        child: Text('${date.day}',
            style: TextStyle(
                color: level >= 2 ? AppColors.bgPrimary : AppColors.textTertiary, fontSize: 9)),
      ));
    }
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      children: cells,
    );
  }
}
