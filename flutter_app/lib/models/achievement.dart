enum AchievementCategory { consistency, volume, diversity, time, hidden }

enum AchievementMetric {
  totalCompletions,
  bestStreak,
  perfectDays,
  habitsCreated,
  xpTotal,
  currentStreak,
  totalDaysTracked,
  lateNightCompletions,  // hidden: Night Owl
  earlyMorningDays,      // hidden: Early Bird
  weekendCompletions,
  consecutivePerfectWeeks,
  hardHabitsCompleted,
  extremeHabitsCompleted,
}

class Achievement {
  final String id;
  final String label;
  final String description;
  final String emoji;
  final int threshold;
  final AchievementMetric metric;
  final AchievementCategory category;
  final bool hidden;
  final String asciiArt;

  const Achievement({
    required this.id,
    required this.label,
    required this.description,
    required this.emoji,
    required this.threshold,
    required this.metric,
    this.category = AchievementCategory.consistency,
    this.hidden = false,
    this.asciiArt = '',
  });
}

const allAchievements = <Achievement>[
  // --- CONSISTENCY ---
  Achievement(id: 'streak_3', label: 'Getting Started', description: '3-day streak', emoji: '🌱', threshold: 3, metric: AchievementMetric.bestStreak, category: AchievementCategory.consistency),
  Achievement(id: 'streak_7', label: 'Week Warrior', description: '7-day streak', emoji: '🔥', threshold: 7, metric: AchievementMetric.bestStreak, category: AchievementCategory.consistency),
  Achievement(id: 'streak_14', label: 'Fortnight Fighter', description: '14-day streak', emoji: '⚡', threshold: 14, metric: AchievementMetric.bestStreak, category: AchievementCategory.consistency),
  Achievement(id: 'streak_30', label: 'Month Monk', description: '30-day streak', emoji: '🌙', threshold: 30, metric: AchievementMetric.bestStreak, category: AchievementCategory.consistency),
  Achievement(id: 'streak_60', label: 'Iron Will', description: '60-day streak', emoji: '⚙️', threshold: 60, metric: AchievementMetric.bestStreak, category: AchievementCategory.consistency),
  Achievement(id: 'streak_100', label: 'Centennial', description: '100-day streak', emoji: '🏆', threshold: 100, metric: AchievementMetric.bestStreak, category: AchievementCategory.consistency),
  Achievement(id: 'streak_365', label: 'Legendary', description: '365-day streak', emoji: '👑', threshold: 365, metric: AchievementMetric.bestStreak, category: AchievementCategory.consistency),
  Achievement(id: 'perfect_1', label: 'Flawless Day', description: '1 perfect day', emoji: '✨', threshold: 1, metric: AchievementMetric.perfectDays, category: AchievementCategory.consistency),
  Achievement(id: 'perfect_7', label: 'Perfect Week', description: '7 perfect days', emoji: '💫', threshold: 7, metric: AchievementMetric.perfectDays, category: AchievementCategory.consistency),
  Achievement(id: 'perfect_30', label: 'Perfect Month', description: '30 perfect days', emoji: '💎', threshold: 30, metric: AchievementMetric.perfectDays, category: AchievementCategory.consistency),

  // --- VOLUME ---
  Achievement(id: 'completions_1', label: 'First Step', description: 'Complete 1 habit', emoji: '🌱', threshold: 1, metric: AchievementMetric.totalCompletions, category: AchievementCategory.volume),
  Achievement(id: 'completions_10', label: 'Warming Up', description: '10 completions', emoji: '🎯', threshold: 10, metric: AchievementMetric.totalCompletions, category: AchievementCategory.volume),
  Achievement(id: 'completions_50', label: 'Half Century', description: '50 completions', emoji: '⚡', threshold: 50, metric: AchievementMetric.totalCompletions, category: AchievementCategory.volume),
  Achievement(id: 'completions_100', label: 'Centurion', description: '100 completions', emoji: '💯', threshold: 100, metric: AchievementMetric.totalCompletions, category: AchievementCategory.volume),
  Achievement(id: 'completions_500', label: 'Machine', description: '500 completions', emoji: '🤖', threshold: 500, metric: AchievementMetric.totalCompletions, category: AchievementCategory.volume),
  Achievement(id: 'completions_1000', label: 'Thousand Cuts', description: '1000 completions', emoji: '🗡️', threshold: 1000, metric: AchievementMetric.totalCompletions, category: AchievementCategory.volume),
  Achievement(id: 'xp_500', label: 'Rising', description: 'Earn 500 XP', emoji: '�', threshold: 500, metric: AchievementMetric.xpTotal, category: AchievementCategory.volume),
  Achievement(id: 'xp_2000', label: 'Power User', description: 'Earn 2000 XP', emoji: '⚡', threshold: 2000, metric: AchievementMetric.xpTotal, category: AchievementCategory.volume),
  Achievement(id: 'xp_10000', label: 'Elite', description: 'Earn 10000 XP', emoji: '🌟', threshold: 10000, metric: AchievementMetric.xpTotal, category: AchievementCategory.volume),

  // --- DIVERSITY ---
  Achievement(id: 'habits_3', label: 'Expanding', description: 'Create 3 habits', emoji: '�', threshold: 3, metric: AchievementMetric.habitsCreated, category: AchievementCategory.diversity),
  Achievement(id: 'habits_5', label: 'Architect', description: 'Create 5 habits', emoji: '🛠️', threshold: 5, metric: AchievementMetric.habitsCreated, category: AchievementCategory.diversity),
  Achievement(id: 'habits_10', label: 'System Builder', description: 'Create 10 habits', emoji: '🔧', threshold: 10, metric: AchievementMetric.habitsCreated, category: AchievementCategory.diversity),
  Achievement(id: 'weekend_warrior', label: 'Weekend Warrior', description: '20 weekend completions', emoji: '🏖️', threshold: 20, metric: AchievementMetric.weekendCompletions, category: AchievementCategory.diversity),
  Achievement(id: 'hard_habits', label: 'Hard Mode', description: 'Complete 10 hard habits', emoji: '💪', threshold: 10, metric: AchievementMetric.hardHabitsCompleted, category: AchievementCategory.diversity),
  Achievement(id: 'extreme_habits', label: 'Extreme Mode', description: 'Complete 5 extreme habits', emoji: '🔥', threshold: 5, metric: AchievementMetric.extremeHabitsCompleted, category: AchievementCategory.diversity),

  // --- TIME ---
  Achievement(id: 'tracked_7', label: 'One Week In', description: 'Track for 7 days', emoji: '📅', threshold: 7, metric: AchievementMetric.totalDaysTracked, category: AchievementCategory.time),
  Achievement(id: 'tracked_30', label: 'Month Veteran', description: 'Track for 30 days', emoji: '📆', threshold: 30, metric: AchievementMetric.totalDaysTracked, category: AchievementCategory.time),
  Achievement(id: 'tracked_90', label: 'Quarter Year', description: 'Track for 90 days', emoji: '🗓️', threshold: 90, metric: AchievementMetric.totalDaysTracked, category: AchievementCategory.time),
  Achievement(id: 'tracked_180', label: 'Half Year Hero', description: 'Track for 180 days', emoji: '�', threshold: 180, metric: AchievementMetric.totalDaysTracked, category: AchievementCategory.time),
  Achievement(id: 'tracked_365', label: 'Year One', description: 'Track for 365 days', emoji: '🎖️', threshold: 365, metric: AchievementMetric.totalDaysTracked, category: AchievementCategory.time),

  // --- HIDDEN ---
  Achievement(
    id: 'night_owl',
    label: 'Night Owl',
    description: '???',
    emoji: '🦉',
    threshold: 5,
    metric: AchievementMetric.lateNightCompletions,
    category: AchievementCategory.hidden,
    hidden: true,
    asciiArt: '  /\\_/\\\n ( o.o )\n  > ^ <\n Night Owl',
  ),
  Achievement(
    id: 'early_bird',
    label: 'Early Bird',
    description: '???',
    emoji: '🌅',
    threshold: 7,
    metric: AchievementMetric.earlyMorningDays,
    category: AchievementCategory.hidden,
    hidden: true,
    asciiArt: ' \\  |  /\n  \\ | /\n---☀️---\n Early Bird',
  ),
  Achievement(
    id: 'centurion_streak',
    label: 'The Hundred',
    description: '???',
    emoji: '�',
    threshold: 100,
    metric: AchievementMetric.currentStreak,
    category: AchievementCategory.hidden,
    hidden: true,
  ),
];
