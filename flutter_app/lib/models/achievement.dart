class Achievement {
  final String id;
  final String label;
  final String description;
  final String emoji;
  final int threshold;
  final AchievementMetric metric;

  const Achievement({
    required this.id,
    required this.label,
    required this.description,
    required this.emoji,
    required this.threshold,
    required this.metric,
  });
}

enum AchievementMetric {
  totalCompletions,
  bestStreak,
  perfectDays,
  habitsCreated,
}

const allAchievements = <Achievement>[
  Achievement(id: 'first_step', label: 'First Step', description: 'Complete 1 habit', emoji: '🌱', threshold: 1, metric: AchievementMetric.totalCompletions),
  Achievement(id: 'half_century', label: 'Half Century', description: '50 completions', emoji: '⚡', threshold: 50, metric: AchievementMetric.totalCompletions),
  Achievement(id: 'centurion', label: 'Centurion', description: '100 completions', emoji: '💯', threshold: 100, metric: AchievementMetric.totalCompletions),
  Achievement(id: 'machine', label: 'Machine', description: '500 completions', emoji: '🤖', threshold: 500, metric: AchievementMetric.totalCompletions),
  Achievement(id: 'streak_7', label: 'Week Warrior', description: '7-day streak', emoji: '🔥', threshold: 7, metric: AchievementMetric.bestStreak),
  Achievement(id: 'streak_30', label: 'Month Monk', description: '30-day streak', emoji: '🌙', threshold: 30, metric: AchievementMetric.bestStreak),
  Achievement(id: 'streak_100', label: 'Centennial', description: '100-day streak', emoji: '🏆', threshold: 100, metric: AchievementMetric.bestStreak),
  Achievement(id: 'perfect_1', label: 'Flawless Day', description: '1 perfect day', emoji: '✨', threshold: 1, metric: AchievementMetric.perfectDays),
  Achievement(id: 'perfect_10', label: 'Perfectionist', description: '10 perfect days', emoji: '💎', threshold: 10, metric: AchievementMetric.perfectDays),
  Achievement(id: 'creator', label: 'Architect', description: 'Create 5 habits', emoji: '🛠', threshold: 5, metric: AchievementMetric.habitsCreated),
];
