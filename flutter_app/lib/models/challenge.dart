enum ChallengeStatus { active, completed, failed }

class Challenge {
  final String id;
  final String habitId;
  final int durationDays; // 7, 14, or 30
  final DateTime startDate;
  final DateTime endDate;
  final ChallengeStatus status;
  final String? sharedWithName;

  Challenge({
    required this.id,
    required this.habitId,
    required this.durationDays,
    required this.startDate,
    required this.endDate,
    this.status = ChallengeStatus.active,
    this.sharedWithName,
  });

  Challenge copyWith({
    String? id,
    String? habitId,
    int? durationDays,
    DateTime? startDate,
    DateTime? endDate,
    ChallengeStatus? status,
    String? sharedWithName,
    bool clearSharedWithName = false,
  }) =>
      Challenge(
        id: id ?? this.id,
        habitId: habitId ?? this.habitId,
        durationDays: durationDays ?? this.durationDays,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        status: status ?? this.status,
        sharedWithName:
            clearSharedWithName ? null : (sharedWithName ?? this.sharedWithName),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'habitId': habitId,
        'durationDays': durationDays,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'status': status.name,
        'sharedWithName': sharedWithName,
      };

  factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
        id: json['id'],
        habitId: json['habitId'],
        durationDays: json['durationDays'],
        startDate: DateTime.parse(json['startDate']),
        endDate: DateTime.parse(json['endDate']),
        status: ChallengeStatus.values.firstWhere(
          (e) => e.name == (json['status'] ?? 'active'),
          orElse: () => ChallengeStatus.active,
        ),
        sharedWithName: json['sharedWithName'],
      );
}
