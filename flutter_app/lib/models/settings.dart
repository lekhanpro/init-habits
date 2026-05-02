enum AppThemeMode { dark, light, coder }

class AppSettings {
  final AppThemeMode theme;
  final bool notificationsEnabled;

  const AppSettings({
    this.theme = AppThemeMode.dark,
    this.notificationsEnabled = true,
  });

  AppSettings copyWith({AppThemeMode? theme, bool? notificationsEnabled}) =>
      AppSettings(
        theme: theme ?? this.theme,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      );

  Map<String, dynamic> toJson() => {
        'theme': theme.name,
        'notificationsEnabled': notificationsEnabled,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        theme: AppThemeMode.values.firstWhere(
          (e) => e.name == (json['theme'] ?? 'dark'),
          orElse: () => AppThemeMode.dark,
        ),
        notificationsEnabled: json['notificationsEnabled'] ?? true,
      );
}
