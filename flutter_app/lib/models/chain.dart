class HabitChain {
  final String id;
  final String name;
  final List<String> habitIds; // ordered by chainOrder
  final DateTime createdAt;
  final int chainStreak; // consecutive days full chain was completed

  HabitChain({
    required this.id,
    required this.name,
    required this.habitIds,
    DateTime? createdAt,
    this.chainStreak = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  HabitChain copyWith({
    String? name,
    List<String>? habitIds,
    int? chainStreak,
  }) =>
      HabitChain(
        id: id,
        name: name ?? this.name,
        habitIds: habitIds ?? this.habitIds,
        createdAt: createdAt,
        chainStreak: chainStreak ?? this.chainStreak,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'habitIds': habitIds,
        'createdAt': createdAt.toIso8601String(),
        'chainStreak': chainStreak,
      };

  factory HabitChain.fromJson(Map<String, dynamic> json) => HabitChain(
        id: json['id'],
        name: json['name'],
        habitIds: List<String>.from(json['habitIds'] ?? []),
        createdAt: DateTime.parse(json['createdAt']),
        chainStreak: json['chainStreak'] ?? 0,
      );
}
