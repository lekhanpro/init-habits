import 'package:flutter/material.dart';
import 'habit.dart';

class AppMode {
  final String id;
  final String label;
  final String description;
  final IconData icon;
  final int colorValue;
  final List<HabitSection> sections;
  final List<Habit> presetHabits;

  const AppMode({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.colorValue,
    required this.sections,
    this.presetHabits = const [],
  });
}

final List<AppMode> allModes = [
  AppMode(
    id: 'standard',
    label: 'Standard',
    description: 'Balanced daily routine',
    icon: Icons.grid_view_rounded,
    colorValue: 0xFF00FF9F,
    sections: [HabitSection.morning, HabitSection.deepWork, HabitSection.windDown],
    presetHabits: _standardHabits,
  ),
  AppMode(
    id: 'minimal',
    label: 'Minimal',
    description: '5 core essentials',
    icon: Icons.remove_rounded,
    colorValue: 0xFFE8E8ED,
    sections: [HabitSection.morning, HabitSection.deepWork],
    presetHabits: _minimalHabits,
  ),
  AppMode(
    id: 'focus',
    label: 'Focus',
    description: 'Single-task deep focus',
    icon: Icons.center_focus_strong,
    colorValue: 0xFF00B4FF,
    sections: [HabitSection.morning, HabitSection.deepWork],
    presetHabits: _focusHabits,
  ),
  AppMode(
    id: 'deepwork',
    label: 'Deep Work',
    description: 'Cal Newport schedule',
    icon: Icons.terminal,
    colorValue: 0xFF00B4FF,
    sections: [HabitSection.morning, HabitSection.deepWork, HabitSection.windDown],
    presetHabits: _deepWorkHabits,
  ),
  AppMode(
    id: 'study',
    label: 'Study',
    description: 'Learning & retention',
    icon: Icons.menu_book,
    colorValue: 0xFFA855F7,
    sections: [HabitSection.morning, HabitSection.deepWork, HabitSection.windDown],
    presetHabits: _studyHabits,
  ),
  AppMode(
    id: 'fitness',
    label: 'Fitness',
    description: 'Training & recovery',
    icon: Icons.fitness_center,
    colorValue: 0xFFFF6B2C,
    sections: [HabitSection.morning, HabitSection.deepWork, HabitSection.windDown],
    presetHabits: _fitnessHabits,
  ),
  AppMode(
    id: 'monk',
    label: 'Monk',
    description: 'Maximum discipline',
    icon: Icons.self_improvement,
    colorValue: 0xFFFFB800,
    sections: [HabitSection.morning, HabitSection.deepWork, HabitSection.windDown],
    presetHabits: _monkHabits,
  ),
  AppMode(
    id: 'detox',
    label: 'Detox',
    description: 'Digital/dopamine reset',
    icon: Icons.shield_outlined,
    colorValue: 0xFFFF4444,
    sections: [HabitSection.morning, HabitSection.deepWork, HabitSection.windDown],
    presetHabits: _detoxHabits,
  ),
  AppMode(
    id: 'recovery',
    label: 'Recovery',
    description: 'Gentle restart',
    icon: Icons.favorite_border,
    colorValue: 0xFF22D3EE,
    sections: [HabitSection.morning, HabitSection.windDown],
    presetHabits: _recoveryHabits,
  ),
  AppMode(
    id: 'morning_athlete',
    label: 'Morning Athlete',
    description: 'Train at sunrise',
    icon: Icons.directions_run,
    colorValue: 0xFFFF6B2C,
    sections: [HabitSection.morning, HabitSection.deepWork, HabitSection.windDown],
    presetHabits: _morningAthleteHabits,
  ),
  AppMode(
    id: 'deepwork_pro',
    label: 'Deep Work Pro',
    description: 'Pro-level focus stack',
    icon: Icons.bolt,
    colorValue: 0xFF00B4FF,
    sections: [HabitSection.morning, HabitSection.deepWork, HabitSection.windDown],
    presetHabits: _deepWorkProHabits,
  ),
  AppMode(
    id: 'custom',
    label: 'Custom',
    description: 'Start from scratch',
    icon: Icons.tune,
    colorValue: 0xFF22D3EE,
    sections: [HabitSection.morning, HabitSection.deepWork, HabitSection.windDown, HabitSection.custom],
    presetHabits: [],
  ),
];

final _morningAthleteHabits = [
  _h('ma1', 'Wake at 5:30 AM', HabitSection.morning, HabitType.boolean),
  _h('ma2', 'Hydrate 500ml', HabitSection.morning, HabitType.boolean),
  _h('ma3', 'Run', HabitSection.morning, HabitType.timer, targetMinutes: 30),
  _h('ma4', 'Strength training', HabitSection.morning, HabitType.timer, targetMinutes: 30),
  _h('ma5', 'Protein breakfast', HabitSection.morning, HabitType.boolean),
  _h('ma6', 'Cold shower', HabitSection.morning, HabitType.boolean),
  _h('ma7', 'Focused work', HabitSection.deepWork, HabitType.timer, targetMinutes: 120),
  _h('ma8', 'Steps', HabitSection.deepWork, HabitType.count, targetCount: 10000),
  _h('ma9', 'Stretch / mobility', HabitSection.windDown, HabitType.timer, targetMinutes: 15),
  _h('ma10', 'Sleep by 10 PM', HabitSection.windDown, HabitType.boolean),
];

final _deepWorkProHabits = [
  _h('dp1', 'Wake at 6 AM', HabitSection.morning, HabitType.boolean),
  _h('dp2', 'No phone first hour', HabitSection.morning, HabitType.negative),
  _h('dp3', 'Plan top 3 priorities', HabitSection.morning, HabitType.boolean),
  _h('dp4', 'Block 1 — 90 min', HabitSection.deepWork, HabitType.timer, targetMinutes: 90),
  _h('dp5', 'Block 2 — 90 min', HabitSection.deepWork, HabitType.timer, targetMinutes: 90),
  _h('dp6', 'Block 3 — 60 min', HabitSection.deepWork, HabitType.timer, targetMinutes: 60),
  _h('dp7', 'Inbox zero (once)', HabitSection.deepWork, HabitType.boolean),
  _h('dp8', 'Ship a deliverable', HabitSection.deepWork, HabitType.boolean),
  _h('dp9', 'No social media', HabitSection.deepWork, HabitType.negative),
  _h('dp10', 'Shutdown ritual', HabitSection.windDown, HabitType.boolean),
  _h('dp11', 'Read 30 min', HabitSection.windDown, HabitType.timer, targetMinutes: 30),
  _h('dp12', 'Sleep by 10:30', HabitSection.windDown, HabitType.boolean),
];

Habit _h(String id, String name, HabitSection section, HabitType type, {int? targetCount, int? targetMinutes}) {
  final cfg = SectionConfig.configs[section]!;
  return Habit(id: id, name: name, type: type, section: section, colorValue: cfg.colorValue, targetCount: targetCount, targetMinutes: targetMinutes);
}

final _standardHabits = [
  _h('s1', 'Wake at 6 AM', HabitSection.morning, HabitType.boolean),
  _h('s2', 'Cold shower', HabitSection.morning, HabitType.boolean),
  _h('s3', 'Meditate', HabitSection.morning, HabitType.timer, targetMinutes: 15),
  _h('s4', 'Journal', HabitSection.morning, HabitType.boolean),
  _h('s5', 'Read 20 pages', HabitSection.morning, HabitType.count, targetCount: 20),
  _h('s6', 'Code 2 hours', HabitSection.deepWork, HabitType.timer, targetMinutes: 120),
  _h('s7', 'Ship 1 feature', HabitSection.deepWork, HabitType.boolean),
  _h('s8', 'Review PRs', HabitSection.deepWork, HabitType.boolean),
  _h('s9', 'Learn something new', HabitSection.deepWork, HabitType.boolean),
  _h('s10', 'No screens after 10 PM', HabitSection.windDown, HabitType.negative),
  _h('s11', 'Stretch/Yoga', HabitSection.windDown, HabitType.boolean),
  _h('s12', 'Plan tomorrow', HabitSection.windDown, HabitType.boolean),
  _h('s13', 'Gratitude log', HabitSection.windDown, HabitType.boolean),
];

final _minimalHabits = [
  _h('m1', 'Exercise', HabitSection.morning, HabitType.boolean),
  _h('m2', 'Read', HabitSection.morning, HabitType.timer, targetMinutes: 20),
  _h('m3', 'Deep work', HabitSection.deepWork, HabitType.timer, targetMinutes: 120),
  _h('m4', 'Journal', HabitSection.morning, HabitType.boolean),
  _h('m5', 'No social media', HabitSection.deepWork, HabitType.negative),
];

final _focusHabits = [
  _h('f1', 'Morning routine', HabitSection.morning, HabitType.boolean),
  _h('f2', 'Set daily target', HabitSection.morning, HabitType.boolean),
  _h('f3', 'Deep work block 1', HabitSection.deepWork, HabitType.timer, targetMinutes: 90),
  _h('f4', 'Deep work block 2', HabitSection.deepWork, HabitType.timer, targetMinutes: 90),
  _h('f5', 'No multitasking', HabitSection.deepWork, HabitType.negative),
  _h('f6', 'Review & reflect', HabitSection.deepWork, HabitType.boolean),
];

final _deepWorkHabits = [
  _h('d1', 'Wake early', HabitSection.morning, HabitType.boolean),
  _h('d2', 'No email before noon', HabitSection.morning, HabitType.negative),
  _h('d3', 'Deep work AM', HabitSection.deepWork, HabitType.timer, targetMinutes: 180),
  _h('d4', 'Deep work PM', HabitSection.deepWork, HabitType.timer, targetMinutes: 120),
  _h('d5', 'Ship deliverable', HabitSection.deepWork, HabitType.boolean),
  _h('d6', 'Learn new skill', HabitSection.deepWork, HabitType.timer, targetMinutes: 30),
  _h('d7', 'Plan tomorrow', HabitSection.windDown, HabitType.boolean),
  _h('d8', 'Digital sunset', HabitSection.windDown, HabitType.negative),
];

final _studyHabits = [
  _h('st1', 'Wake early', HabitSection.morning, HabitType.boolean),
  _h('st2', 'Review flashcards', HabitSection.morning, HabitType.boolean),
  _h('st3', 'Study session 1', HabitSection.deepWork, HabitType.timer, targetMinutes: 90),
  _h('st4', 'Practice problems', HabitSection.deepWork, HabitType.count, targetCount: 10),
  _h('st5', 'Study session 2', HabitSection.deepWork, HabitType.timer, targetMinutes: 90),
  _h('st6', 'Teach/explain concept', HabitSection.deepWork, HabitType.boolean),
  _h('st7', 'Review notes', HabitSection.windDown, HabitType.boolean),
  _h('st8', 'Plan tomorrow', HabitSection.windDown, HabitType.boolean),
];

final _fitnessHabits = [
  _h('ft1', 'Wake early', HabitSection.morning, HabitType.boolean),
  _h('ft2', 'Protein breakfast', HabitSection.morning, HabitType.boolean),
  _h('ft3', 'Workout', HabitSection.deepWork, HabitType.timer, targetMinutes: 60),
  _h('ft4', 'Steps', HabitSection.deepWork, HabitType.count, targetCount: 10000),
  _h('ft5', 'Water intake', HabitSection.deepWork, HabitType.count, targetCount: 8),
  _h('ft6', 'Meal prep', HabitSection.deepWork, HabitType.boolean),
  _h('ft7', 'No junk food', HabitSection.deepWork, HabitType.negative),
  _h('ft8', 'Stretch', HabitSection.windDown, HabitType.timer, targetMinutes: 15),
  _h('ft9', 'Sleep by 10 PM', HabitSection.windDown, HabitType.boolean),
];

final _monkHabits = [
  _h('mk1', 'Wake at 5 AM', HabitSection.morning, HabitType.boolean),
  _h('mk2', 'Cold shower', HabitSection.morning, HabitType.boolean),
  _h('mk3', 'Meditate', HabitSection.morning, HabitType.timer, targetMinutes: 30),
  _h('mk4', 'Journal', HabitSection.morning, HabitType.boolean),
  _h('mk5', 'Exercise', HabitSection.morning, HabitType.timer, targetMinutes: 60),
  _h('mk6', 'Read', HabitSection.morning, HabitType.count, targetCount: 30),
  _h('mk7', 'Deep work', HabitSection.deepWork, HabitType.timer, targetMinutes: 240),
  _h('mk8', 'No social media', HabitSection.deepWork, HabitType.negative),
  _h('mk9', 'No sugar', HabitSection.deepWork, HabitType.negative),
  _h('mk10', 'No alcohol', HabitSection.deepWork, HabitType.negative),
  _h('mk11', 'Learn new skill', HabitSection.deepWork, HabitType.timer, targetMinutes: 30),
  _h('mk12', 'Stretch/Yoga', HabitSection.windDown, HabitType.timer, targetMinutes: 20),
  _h('mk13', 'Gratitude log', HabitSection.windDown, HabitType.boolean),
  _h('mk14', 'Plan tomorrow', HabitSection.windDown, HabitType.boolean),
  _h('mk15', 'Lights out by 9:30', HabitSection.windDown, HabitType.boolean),
];

final _detoxHabits = [
  _h('dx1', 'No phone first hour', HabitSection.morning, HabitType.negative),
  _h('dx2', 'Meditate', HabitSection.morning, HabitType.timer, targetMinutes: 15),
  _h('dx3', 'Walk outside', HabitSection.morning, HabitType.boolean),
  _h('dx4', 'No social media', HabitSection.deepWork, HabitType.negative),
  _h('dx5', 'No news/feeds', HabitSection.deepWork, HabitType.negative),
  _h('dx6', 'No sugar', HabitSection.deepWork, HabitType.negative),
  _h('dx7', 'No caffeine after 2 PM', HabitSection.deepWork, HabitType.negative),
  _h('dx8', 'Read physical book', HabitSection.windDown, HabitType.timer, targetMinutes: 30),
  _h('dx9', 'Journal', HabitSection.windDown, HabitType.boolean),
  _h('dx10', 'Digital sunset at 8 PM', HabitSection.windDown, HabitType.negative),
];

final _recoveryHabits = [
  _h('r1', 'Wake gently', HabitSection.morning, HabitType.boolean),
  _h('r2', 'Hydrate', HabitSection.morning, HabitType.boolean),
  _h('r3', 'Short walk', HabitSection.morning, HabitType.boolean),
  _h('r4', 'Stretch', HabitSection.windDown, HabitType.timer, targetMinutes: 10),
  _h('r5', 'Gratitude', HabitSection.windDown, HabitType.boolean),
  _h('r6', 'Early bedtime', HabitSection.windDown, HabitType.boolean),
];
