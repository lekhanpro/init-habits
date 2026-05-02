enum HabitType { boolean, count, timer, negative }

enum HabitSection { morning, deepWork, windDown, custom }

class SectionConfig {
  final String label;
  final String command;
  final int colorValue;

  const SectionConfig(this.label, this.command, this.colorValue);

  static const configs = {
    HabitSection.morning: SectionConfig('Morning Routine', 'morning.init()', 0xFFFFB800),
    HabitSection.deepWork: SectionConfig('Deep Work', 'deepwork.start()', 0xFF00B4FF),
    HabitSection.windDown: SectionConfig('Wind Down', 'winddown.exec()', 0xFFA855F7),
    HabitSection.custom: SectionConfig('Custom', 'custom.run()', 0xFF22D3EE),
  };
}

class Habit {
  final String id;
  final String name;
  final HabitType type;
  final HabitSection section;
  final int colorValue;
  final String? icon;
  final int? targetCount;
  final int? targetMinutes;
  final List<int> schedule;
  final int order;
  final bool archived;
  final DateTime createdAt;
  final DateTime updatedAt;
  // reminder time-of-day in minutes-from-midnight, null = no reminder
  final int? reminderMinutes;

  Habit({
    required this.id,
    required this.name,
    required this.type,
    required this.section,
    required this.colorValue,
    this.icon,
    this.targetCount,
    this.targetMinutes,
    this.schedule = const [],
    this.order = 0,
    this.archived = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.reminderMinutes,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Habit copyWith({
    String? name,
    HabitType? type,
    HabitSection? section,
    int? colorValue,
    String? icon,
    int? targetCount,
    int? targetMinutes,
    List<int>? schedule,
    int? order,
    bool? archived,
    int? reminderMinutes,
    bool clearReminder = false,
  }) =>
      Habit(
        id: id,
        name: name ?? this.name,
        type: type ?? this.type,
        section: section ?? this.section,
        colorValue: colorValue ?? this.colorValue,
        icon: icon ?? this.icon,
        targetCount: targetCount ?? this.targetCount,
        targetMinutes: targetMinutes ?? this.targetMinutes,
        schedule: schedule ?? this.schedule,
        order: order ?? this.order,
        archived: archived ?? this.archived,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
        reminderMinutes: clearReminder ? null : (reminderMinutes ?? this.reminderMinutes),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'section': section.name,
        'colorValue': colorValue,
        'icon': icon,
        'targetCount': targetCount,
        'targetMinutes': targetMinutes,
        'schedule': schedule,
        'order': order,
        'archived': archived,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'reminderMinutes': reminderMinutes,
      };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'],
        name: json['name'],
        type: HabitType.values.firstWhere((e) => e.name == json['type']),
        section: HabitSection.values.firstWhere((e) => e.name == json['section']),
        colorValue: json['colorValue'],
        icon: json['icon'],
        targetCount: json['targetCount'],
        targetMinutes: json['targetMinutes'],
        schedule: List<int>.from(json['schedule'] ?? []),
        order: json['order'] ?? 0,
        archived: json['archived'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        reminderMinutes: json['reminderMinutes'],
      );
}

class Completion {
  final String id;
  final String habitId;
  final String date; // yyyy-MM-dd
  final bool completed;
  final int? value;
  final String? note;
  final DateTime createdAt;

  Completion({
    required this.id,
    required this.habitId,
    required this.date,
    this.completed = true,
    this.value,
    this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'habitId': habitId,
        'date': date,
        'completed': completed,
        'value': value,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Completion.fromJson(Map<String, dynamic> json) => Completion(
        id: json['id'],
        habitId: json['habitId'],
        date: json['date'],
        completed: json['completed'] ?? true,
        value: json['value'],
        note: json['note'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}

class JournalEntry {
  final String date; // yyyy-MM-dd
  final String text;
  final DateTime updatedAt;

  JournalEntry({required this.date, required this.text, DateTime? updatedAt})
      : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'date': date,
        'text': text,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        date: json['date'],
        text: json['text'] ?? '',
        updatedAt: DateTime.parse(json['updatedAt']),
      );
}
