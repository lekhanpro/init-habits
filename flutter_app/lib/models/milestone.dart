class Milestone {
  final String id;
  final String habitId;
  final String habitName;
  final int count;
  final DateTime achievedAt;

  Milestone({
    required this.id,
    required this.habitId,
    required this.habitName,
    required this.count,
    required this.achievedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'habitId': habitId,
        'habitName': habitName,
        'count': count,
        'achievedAt': achievedAt.toIso8601String(),
      };

  factory Milestone.fromJson(Map<String, dynamic> json) => Milestone(
        id: json['id'] as String,
        habitId: json['habitId'] as String,
        habitName: json['habitName'] as String,
        count: json['count'] as int,
        achievedAt: DateTime.parse(json['achievedAt'] as String),
      );
}
