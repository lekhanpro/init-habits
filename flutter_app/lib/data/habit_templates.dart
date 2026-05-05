import '../models/habit.dart';

/// A draft of a habit, holding only the args required to construct a [Habit]
/// at install-time. The store is responsible for assigning ids, timestamps,
/// order and any other runtime fields.
class HabitDraft {
  final String name;
  final HabitSection section;
  final int colorValue;
  final HabitType type;
  final HabitDifficulty difficulty;
  final String? icon;
  final int? targetMinutes;
  final int? targetCount;

  const HabitDraft({
    required this.name,
    required this.section,
    required this.colorValue,
    required this.type,
    required this.difficulty,
    this.icon,
    this.targetMinutes,
    this.targetCount,
  });
}

class HabitTemplate {
  final String id;
  final String name;
  final String description;
  final List<HabitDraft> habits;

  const HabitTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.habits,
  });
}

const List<HabitTemplate> habitTemplates = [
  HabitTemplate(
    id: 'morning-warrior',
    name: 'Morning Warrior',
    description: 'A hard-mode dawn protocol for builders who win the day before sunrise.',
    habits: [
      HabitDraft(
        name: 'Wake up at 6am',
        section: HabitSection.morning,
        colorValue: 0xFFFFB800,
        type: HabitType.boolean,
        difficulty: HabitDifficulty.hard,
      ),
      HabitDraft(
        name: 'Cold shower',
        section: HabitSection.morning,
        colorValue: 0xFFFFB800,
        type: HabitType.boolean,
        difficulty: HabitDifficulty.hard,
      ),
      HabitDraft(
        name: 'Exercise',
        section: HabitSection.morning,
        colorValue: 0xFFFFB800,
        type: HabitType.timer,
        difficulty: HabitDifficulty.hard,
        targetMinutes: 30,
      ),
      HabitDraft(
        name: 'Meditate',
        section: HabitSection.morning,
        colorValue: 0xFFFFB800,
        type: HabitType.timer,
        difficulty: HabitDifficulty.hard,
        targetMinutes: 10,
      ),
      HabitDraft(
        name: 'Journal',
        section: HabitSection.morning,
        colorValue: 0xFFFFB800,
        type: HabitType.boolean,
        difficulty: HabitDifficulty.hard,
      ),
    ],
  ),
  HabitTemplate(
    id: 'deep-work',
    name: 'Deep Work',
    description: 'Protect a focus block, ship four pomodoros, then review.',
    habits: [
      HabitDraft(
        name: 'No phone 9-12',
        section: HabitSection.deepWork,
        colorValue: 0xFF00B4FF,
        type: HabitType.negative,
        difficulty: HabitDifficulty.normal,
      ),
      HabitDraft(
        name: 'Pomodoro sessions',
        section: HabitSection.deepWork,
        colorValue: 0xFF00B4FF,
        type: HabitType.count,
        difficulty: HabitDifficulty.normal,
        targetCount: 4,
      ),
      HabitDraft(
        name: 'Review notes',
        section: HabitSection.deepWork,
        colorValue: 0xFF00B4FF,
        type: HabitType.boolean,
        difficulty: HabitDifficulty.normal,
      ),
    ],
  ),
  HabitTemplate(
    id: 'wind-down',
    name: 'Wind Down',
    description: 'A gentle evening shutdown sequence for deeper sleep.',
    habits: [
      HabitDraft(
        name: 'No screens by 9pm',
        section: HabitSection.windDown,
        colorValue: 0xFFA855F7,
        type: HabitType.negative,
        difficulty: HabitDifficulty.easy,
      ),
      HabitDraft(
        name: 'Read',
        section: HabitSection.windDown,
        colorValue: 0xFFA855F7,
        type: HabitType.timer,
        difficulty: HabitDifficulty.easy,
        targetMinutes: 20,
      ),
      HabitDraft(
        name: 'Gratitude',
        section: HabitSection.windDown,
        colorValue: 0xFFA855F7,
        type: HabitType.boolean,
        difficulty: HabitDifficulty.easy,
      ),
      HabitDraft(
        name: 'Sleep by 11pm',
        section: HabitSection.windDown,
        colorValue: 0xFFA855F7,
        type: HabitType.boolean,
        difficulty: HabitDifficulty.easy,
      ),
    ],
  ),
  HabitTemplate(
    id: 'fitness-basics',
    name: 'Fitness Basics',
    description: 'Move, push, stretch, hydrate. The minimum viable body.',
    habits: [
      HabitDraft(
        name: 'Run',
        section: HabitSection.custom,
        colorValue: 0xFF22D3EE,
        type: HabitType.timer,
        difficulty: HabitDifficulty.normal,
        targetMinutes: 20,
      ),
      HabitDraft(
        name: 'Push-ups',
        section: HabitSection.custom,
        colorValue: 0xFF22D3EE,
        type: HabitType.count,
        difficulty: HabitDifficulty.normal,
        targetCount: 30,
      ),
      HabitDraft(
        name: 'Stretch',
        section: HabitSection.custom,
        colorValue: 0xFF22D3EE,
        type: HabitType.timer,
        difficulty: HabitDifficulty.normal,
        targetMinutes: 5,
      ),
      HabitDraft(
        name: 'Hydrate',
        section: HabitSection.custom,
        colorValue: 0xFF22D3EE,
        type: HabitType.count,
        difficulty: HabitDifficulty.normal,
        targetCount: 8,
      ),
    ],
  ),
];
