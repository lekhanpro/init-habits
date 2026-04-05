import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../stores/habit_store.dart';
import '../theme/app_theme.dart';
import '../widgets/terminal_header.dart';

class WeeklyReviewScreen extends StatelessWidget {
  const WeeklyReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<HabitStore>();
    final review = store.getWeeklyReview();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            const TerminalHeader(command: 'review.weekly()', showDate: false),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back, size: 14, color: AppColors.textSecondary),
                        SizedBox(width: 4),
                        Text('back', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '// weekly review: ${review['weekStart']} — ${review['weekEnd']}',
                    style: const TextStyle(color: AppColors.textTertiary, fontSize: 10),
                  ),
                  const SizedBox(height: 16),
                  // Overall rate
                  _statCard(
                    'Completion Rate',
                    '${review['rate']}%',
                    '${review['done']}/${review['total']} habits completed',
                    review['rate'] >= 70 ? AppColors.accentGreen : review['rate'] >= 40 ? AppColors.accentYellow : AppColors.accentRed,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _statCard('Perfect Days', '${review['perfectDays']}', '/7 days', AppColors.accentGreen)),
                      const SizedBox(width: 8),
                      Expanded(child: _statCard('Best Day', review['bestDay'].isEmpty ? '--' : review['bestDay'], '', AppColors.accentBlue)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('// highlights', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                  const SizedBox(height: 8),
                  if (store.getHabitName(review['bestHabitId']) != null)
                    _highlightRow(
                      Icons.trending_up,
                      'Most consistent',
                      store.getHabitName(review['bestHabitId'])!,
                      AppColors.accentGreen,
                    ),
                  if (store.getHabitName(review['worstHabitId']) != null)
                    _highlightRow(
                      Icons.trending_down,
                      'Needs attention',
                      store.getHabitName(review['worstHabitId'])!,
                      AppColors.accentOrange,
                    ),
                  const SizedBox(height: 24),
                  // Motivational message
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.bgSecondary,
                      border: Border.all(color: AppColors.borderPrimary),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getMessage(review['rate']),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border.all(color: AppColors.borderPrimary),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textTertiary, fontSize: 9)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w600)),
          if (subtitle.isNotEmpty)
            Text(subtitle, style: const TextStyle(color: AppColors.textTertiary, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _highlightRow(IconData icon, String label, String habit, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: color, fontSize: 9)),
                Text(habit, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getMessage(int rate) {
    if (rate >= 80) return '// stdout: exceptional week. keep the momentum going.';
    if (rate >= 60) return '// stdout: solid progress. consistency compounds over time.';
    if (rate >= 40) return '// stdout: room to grow. focus on showing up, even imperfectly.';
    return '// stdout: tough week. every restart counts. try again.';
  }
}
