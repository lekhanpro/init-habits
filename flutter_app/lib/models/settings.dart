enum AppThemeMode {
  dark,
  light,
  coder,
  synthwave,
  matrix,
  solarized,
  gruvbox,
  catppuccinMocha,
  nord,
  dracula,
  oneDark,
  tokyonight,
  catppuccinLatte,
  catppuccinFrappe,
  catppuccinMacchiato,
  solarizedLight,
}

enum HapticsLevel { off, light, medium, strong }

enum CelebrationIntensity { minimal, standard, full }

enum InsightFrequency { daily, weekly, off }

class AppSettings {
  final AppThemeMode theme;
  final bool notificationsEnabled;
  final int gracePeriodHours; // 0-3: completions before this hour count for prev day
  final int firstDayOfWeek; // 1=Mon 7=Sun
  final String defaultDifficulty; // easy/normal/hard/extreme
  final HapticsLevel checkinHaptics;
  final CelebrationIntensity celebrationIntensity;
  final InsightFrequency insightFrequency;
  final bool dailyPlanningPrompt;
  final int weeklyReviewDay; // 1=Mon .. 7=Sun

  const AppSettings({
    this.theme = AppThemeMode.dark,
    this.notificationsEnabled = true,
    this.gracePeriodHours = 0,
    this.firstDayOfWeek = 1,
    this.defaultDifficulty = 'normal',
    this.checkinHaptics = HapticsLevel.light,
    this.celebrationIntensity = CelebrationIntensity.standard,
    this.insightFrequency = InsightFrequency.daily,
    this.dailyPlanningPrompt = false,
    this.weeklyReviewDay = 7,
  });

  AppSettings copyWith({
    AppThemeMode? theme,
    bool? notificationsEnabled,
    int? gracePeriodHours,
    int? firstDayOfWeek,
    String? defaultDifficulty,
    HapticsLevel? checkinHaptics,
    CelebrationIntensity? celebrationIntensity,
    InsightFrequency? insightFrequency,
    bool? dailyPlanningPrompt,
    int? weeklyReviewDay,
  }) =>
      AppSettings(
        theme: theme ?? this.theme,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        gracePeriodHours: gracePeriodHours ?? this.gracePeriodHours,
        firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
        defaultDifficulty: defaultDifficulty ?? this.defaultDifficulty,
        checkinHaptics: checkinHaptics ?? this.checkinHaptics,
        celebrationIntensity: celebrationIntensity ?? this.celebrationIntensity,
        insightFrequency: insightFrequency ?? this.insightFrequency,
        dailyPlanningPrompt: dailyPlanningPrompt ?? this.dailyPlanningPrompt,
        weeklyReviewDay: weeklyReviewDay ?? this.weeklyReviewDay,
      );

  Map<String, dynamic> toJson() => {
        'theme': theme.name,
        'notificationsEnabled': notificationsEnabled,
        'gracePeriodHours': gracePeriodHours,
        'firstDayOfWeek': firstDayOfWeek,
        'defaultDifficulty': defaultDifficulty,
        'checkinHaptics': checkinHaptics.name,
        'celebrationIntensity': celebrationIntensity.name,
        'insightFrequency': insightFrequency.name,
        'dailyPlanningPrompt': dailyPlanningPrompt,
        'weeklyReviewDay': weeklyReviewDay,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        theme: AppThemeMode.values.firstWhere(
          (e) => e.name == (json['theme'] ?? 'dark'),
          orElse: () => AppThemeMode.dark,
        ),
        notificationsEnabled: json['notificationsEnabled'] ?? true,
        gracePeriodHours: (json['gracePeriodHours'] as num?)?.toInt() ?? 0,
        firstDayOfWeek: (json['firstDayOfWeek'] as num?)?.toInt() ?? 1,
        defaultDifficulty: json['defaultDifficulty'] ?? 'normal',
        checkinHaptics: HapticsLevel.values.firstWhere(
          (e) => e.name == (json['checkinHaptics'] ?? 'light'),
          orElse: () => HapticsLevel.light,
        ),
        celebrationIntensity: CelebrationIntensity.values.firstWhere(
          (e) => e.name == (json['celebrationIntensity'] ?? 'standard'),
          orElse: () => CelebrationIntensity.standard,
        ),
        insightFrequency: InsightFrequency.values.firstWhere(
          (e) => e.name == (json['insightFrequency'] ?? 'daily'),
          orElse: () => InsightFrequency.daily,
        ),
        dailyPlanningPrompt: json['dailyPlanningPrompt'] ?? false,
        weeklyReviewDay: (json['weeklyReviewDay'] as num?)?.toInt() ?? 7,
      );
}
