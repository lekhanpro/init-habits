enum HabitType { boolean, count, timer, negative }

enum HabitSection { morning, deepWork, windDown, custom }

enum HabitDifficulty { easy, normal, hard, extreme }

enum FrequencyType { daily, xPerWeek, alternateDay, weekly, monthly }

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
  final int? reminderMinutes;
  // --- v2 fields ---
  final HabitDifficulty difficulty;
  final FrequencyType frequencyType;
  final int? frequencyTarget; // for xPerWeek: how many per week
  final String? chainId;
  final int chainOrder;
  final int? timeWindowStart; // minutes from midnight
  final int? timeWindowEnd;
  final int shieldsRemaining;
  final int shieldTier; // 0=none 1=bronze 2=silver 3=gold

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
    this.difficulty = HabitDifficulty.normal,
    this.frequencyType = FrequencyType.daily,
    this.frequencyTarget,
    this.chainId,
    this.chainOrder = 0,
    this.timeWindowStart,
    this.timeWindowEnd,
    this.shieldsRemaining = 0,
    this.shieldTier = 0,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  double get difficultyMultiplier {
    switch (difficulty) {
      case HabitDifficulty.easy:
        return 0.5;
      case HabitDifficulty.normal:
        return 1.0;
      case HabitDifficulty.hard:
        return 1.5;
      case HabitDifficulty.extreme:
        return 2.0;
    }
  }

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
    HabitDifficulty? difficulty,
    FrequencyType? frequencyType,
    int? frequencyTarget,
    String? chainId,
    bool clearChain = false,
    int? chainOrder,
    int? timeWindowStart,
    int? timeWindowEnd,
    bool clearTimeWindow = false,
    int? shieldsRemaining,
    int? shieldTier,
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
        difficulty: difficulty ?? this.difficulty,
        frequencyType: frequencyType ?? this.frequencyType,
        frequencyTarget: frequencyTarget ?? this.frequencyTarget,
        chainId: clearChain ? null : (chainId ?? this.chainId),
        chainOrder: chainOrder ?? this.chainOrder,
        timeWindowStart: clearTimeWindow ? null : (timeWindowStart ?? this.timeWindowStart),
        timeWindowEnd: clearTimeWindow ? null : (timeWindowEnd ?? this.timeWindowEnd),
        shieldsRemaining: shieldsRemaining ?? this.shieldsRemaining,
        shieldTier: shieldTier ?? this.shieldTier,
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
        'difficulty': difficulty.name,
        'frequencyType': frequencyType.name,
        'frequencyTarget': frequencyTarget,
        'chainId': chainId,
        'chainOrder': chainOrder,
        'timeWindowStart': timeWindowStart,
        'timeWindowEnd': timeWindowEnd,
        'shieldsRemaining': shieldsRemaining,
        'shieldTier': shieldTier,
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
        difficulty: HabitDifficulty.values.firstWhere(
          (e) => e.name == (json['difficulty'] ?? 'normal'),
          orElse: () => HabitDifficulty.normal,
        ),
        frequencyType: FrequencyType.values.firstWhere(
          (e) => e.name == (json['frequencyType'] ?? 'daily'),
          orElse: () => FrequencyType.daily,
        ),
        frequencyTarget: json['frequencyTarget'],
        chainId: json['chainId'],
        chainOrder: json['chainOrder'] ?? 0,
        timeWindowStart: json['timeWindowStart'],
        timeWindowEnd: json['timeWindowEnd'],
        shieldsRemaining: json['shieldsRemaining'] ?? 0,
        shieldTier: json['shieldTier'] ?? 0,
      );
}

// mood: 0=😄 1=😐 2=😔 3=😤 4=🤒  energyLevel: 1-5
const moodEmojis = ['😄', '😐', '😔', '😤', '🤒'];

class Completion {
  final String id;
  final String habitId;
  final String date; // yyyy-MM-dd
  final bool completed;
  final int? value;
  final String? note;
  final DateTime createdAt;
  final int? mood; // 0-4
  final int? energyLevel; // 1-5

  Completion({
    required this.id,
    required this.habitId,
    required this.date,
    this.completed = true,
    this.value,
    this.note,
    DateTime? createdAt,
    this.mood,
    this.energyLevel,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'habitId': habitId,
        'date': date,
        'completed': completed,
        'value': value,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
        'mood': mood,
        'energyLevel': energyLevel,
      };

  factory Completion.fromJson(Map<String, dynamic> json) => Completion(
        id: json['id'],
        habitId: json['habitId'],
        date: json['date'],
        completed: json['completed'] ?? true,
        value: json['value'],
        note: json['note'],
        createdAt: DateTime.parse(json['createdAt']),
        mood: json['mood'],
        energyLevel: json['energyLevel'],
      );
}

class JournalEntry {
  final String id;
  final String habitId;
  final String date; // yyyy-MM-dd
  final String text;
  final DateTime updatedAt;
  final DateTime createdAt;
  final String? mood; // happy|neutral|sad|frustrated|sick
  final int? energy; // 1..5

  JournalEntry({
    String? id,
    this.habitId = '',
    required this.date,
    required this.text,
    DateTime? updatedAt,
    DateTime? createdAt,
    this.mood,
    this.energy,
  })  : id = id ?? '${date}_${DateTime.now().microsecondsSinceEpoch}',
        updatedAt = updatedAt ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  // Convenience: journal screens read `note` for the body text.
  String? get note => text.isEmpty ? null : text;

  Map<String, dynamic> toJson() => {
        'id': id,
        'habitId': habitId,
        'date': date,
        'text': text,
        'updatedAt': updatedAt.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'mood': mood,
        'energy': energy,
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'],
        habitId: json['habitId'] ?? '',
        date: json['date'],
        text: json['text'] ?? '',
        updatedAt: DateTime.parse(json['updatedAt']),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.parse(json['updatedAt']),
        mood: json['mood'],
        energy: json['energy'] is int ? json['energy'] as int : null,
      );
}
