import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../stores/habit_store.dart';
import '../theme/app_theme.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});
  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  String _leaderSort = 'streak';

  @override
  Widget build(BuildContext context) {
    final store = context.watch<HabitStore>();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            Text('> insights.run()',
                style: TextStyle(color: AppColors.accentGreen, fontSize: 11, letterSpacing: 1.2)),
            const SizedBox(height: 16),

            // --- Predictive ---
            _section('PREDICTIVE ANALYSIS', [
              _kv('streak prediction', store.predictedStreakDays),
              _kv('best performance window', store.bestPerformanceWindow),
              _kv('weakest habit (7d)', store.weakestHabitThisWeek),
              _kv('weekday vs weekend', store.weekdayVsWeekendRatio),
            ]),
            const SizedBox(height: 16),

            // --- Habit Scores ---
            _section('HABIT SCORES (EMA)', [
              for (final h in store.habits.where((h) => !h.archived).take(10))
                _scoreRow(h.name, store.habitScore(h.id)),
            ]),
            const SizedBox(height: 16),

            // --- Leaderboard ---
            _sectionHeader('LEADERBOARD'),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                border: Border.all(color: AppColors.borderPrimary),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  Row(children: [
                    Text('sort:', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                    const SizedBox(width: 8),
                    for (final s in ['streak', 'score', 'xp'])
                      GestureDetector(
                        onTap: () => setState(() => _leaderSort = s),
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _leaderSort == s
                                ? AppColors.accentGreen.withValues(alpha: 0.15)
                                : Colors.transparent,
                            border: Border.all(
                              color: _leaderSort == s
                                  ? AppColors.accentGreen.withValues(alpha: 0.4)
                                  : AppColors.borderPrimary,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(s,
                              style: TextStyle(
                                  color: _leaderSort == s
                                      ? AppColors.accentGreen
                                      : AppColors.textTertiary,
                                  fontSize: 9)),
                        ),
                      ),
                  ]),
                  const SizedBox(height: 8),
                  ..._buildLeaderboard(store),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- Correlations ---
            _section('HABIT CORRELATIONS', [
              for (final h in store.habits.where((h) => !h.archived).take(5))
                Builder(builder: (_) {
                  final corr = store.correlatedHabits(h.id);
                  if (corr.isEmpty) return const SizedBox.shrink();
                  return _kv(h.name, 'often with: ${corr.join(", ")}');
                }),
              if (store.habits.where((h) => !h.archived).isEmpty)
                _kv('no data', 'add habits and track them to see correlations'),
            ]),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLeaderboard(HabitStore store) {
    final board = store.leaderboard(sort: _leaderSort);
    if (board.isEmpty) {
      return [Text('no habits yet', style: TextStyle(color: AppColors.textTertiary, fontSize: 11))];
    }
    return board.take(8).toList().asMap().entries.map((e) {
      final i = e.key;
      final item = e.value;
      final h = item['habit'];
      final streak = item['streak'] as int;
      final score = item['score'] as double;
      final xp = item['xp'] as int;
      final medals = ['🥇', '🥈', '🥉'];
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          SizedBox(
            width: 20,
            child: Text(i < 3 ? medals[i] : '${i + 1}.',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
          ),
          Container(width: 3, height: 16, color: Color(h.colorValue), margin: const EdgeInsets.symmetric(horizontal: 6)),
          Expanded(
            child: Text(h.name,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 11),
                overflow: TextOverflow.ellipsis),
          ),
          Text(
            _leaderSort == 'score'
                ? '${(score * 100).round()}%'
                : _leaderSort == 'xp'
                    ? '${xp}xp'
                    : '🔥$streak',
            style: TextStyle(color: AppColors.accentGreen, fontSize: 10),
          ),
        ]),
      );
    }).toList();
  }

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(title),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            border: Border.all(color: AppColors.borderPrimary),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children.isEmpty
                ? [Text('no data', style: TextStyle(color: AppColors.textTertiary, fontSize: 11))]
                : children,
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text('// $title',
          style: TextStyle(color: AppColors.textTertiary, fontSize: 9, letterSpacing: 0.8)),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$k: ', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
        Expanded(
          child: Text(v, style: TextStyle(color: AppColors.textPrimary, fontSize: 10)),
        ),
      ]),
    );
  }

  Widget _scoreRow(String name, double score) {
    final filled = (score * 10).round().clamp(0, 10);
    final bar = '[${'█' * filled}${'░' * (10 - filled)}]';
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Expanded(
          flex: 3,
          child: Text(name,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
              overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 8),
        Text(bar, style: TextStyle(color: AppColors.accentGreen, fontSize: 10, letterSpacing: -1)),
        const SizedBox(width: 4),
        Text('${(score * 100).round()}%',
            style: TextStyle(color: AppColors.accentCyan, fontSize: 10)),
      ]),
    );
  }
}
