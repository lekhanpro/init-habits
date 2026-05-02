import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings.dart';

class AppPalette {
  final Color bgPrimary;
  final Color bgSecondary;
  final Color bgTertiary;
  final Color bgInput;
  final Color borderPrimary;
  final Color borderSecondary;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color accentGreen;
  final Color accentYellow;
  final Color accentBlue;
  final Color accentPurple;
  final Color accentRed;
  final Color accentCyan;
  final Color accentOrange;
  final Color heatmap0;
  final Color heatmap1;
  final Color heatmap2;
  final Color heatmap3;
  final Color heatmap4;
  final Brightness brightness;

  const AppPalette({
    required this.bgPrimary,
    required this.bgSecondary,
    required this.bgTertiary,
    required this.bgInput,
    required this.borderPrimary,
    required this.borderSecondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accentGreen,
    required this.accentYellow,
    required this.accentBlue,
    required this.accentPurple,
    required this.accentRed,
    required this.accentCyan,
    required this.accentOrange,
    required this.heatmap0,
    required this.heatmap1,
    required this.heatmap2,
    required this.heatmap3,
    required this.heatmap4,
    this.brightness = Brightness.dark,
  });
}

const _darkPalette = AppPalette(
  bgPrimary: Color(0xFF0A0A0F),
  bgSecondary: Color(0xFF12121A),
  bgTertiary: Color(0xFF1A1A25),
  bgInput: Color(0xFF0F0F18),
  borderPrimary: Color(0xFF1E1E2E),
  borderSecondary: Color(0xFF2A2A3A),
  textPrimary: Color(0xFFE8E8ED),
  textSecondary: Color(0xFF6B6B80),
  textTertiary: Color(0xFF4A4A5A),
  accentGreen: Color(0xFF00FF9F),
  accentYellow: Color(0xFFFFB800),
  accentBlue: Color(0xFF00B4FF),
  accentPurple: Color(0xFFA855F7),
  accentRed: Color(0xFFFF4444),
  accentCyan: Color(0xFF22D3EE),
  accentOrange: Color(0xFFFF6B2C),
  heatmap0: Color(0xFF1A1A25),
  heatmap1: Color(0xFF0D3320),
  heatmap2: Color(0xFF166534),
  heatmap3: Color(0xFF22C55E),
  heatmap4: Color(0xFF00FF9F),
);

const _lightPalette = AppPalette(
  bgPrimary: Color(0xFFF7F5EE),
  bgSecondary: Color(0xFFEFEDE3),
  bgTertiary: Color(0xFFE5E2D6),
  bgInput: Color(0xFFFFFFFF),
  borderPrimary: Color(0xFFD7D3C2),
  borderSecondary: Color(0xFFC4BFAA),
  textPrimary: Color(0xFF1F2024),
  textSecondary: Color(0xFF55585F),
  textTertiary: Color(0xFF8A8C92),
  accentGreen: Color(0xFF00A36C),
  accentYellow: Color(0xFFB8860B),
  accentBlue: Color(0xFF0E7FBF),
  accentPurple: Color(0xFF7C3AED),
  accentRed: Color(0xFFC0392B),
  accentCyan: Color(0xFF0CA9B5),
  accentOrange: Color(0xFFCC5A12),
  heatmap0: Color(0xFFE5E2D6),
  heatmap1: Color(0xFFC8E6D6),
  heatmap2: Color(0xFF7DCBA0),
  heatmap3: Color(0xFF22C55E),
  heatmap4: Color(0xFF00A36C),
  brightness: Brightness.light,
);

const _coderPalette = AppPalette(
  bgPrimary: Color(0xFF000000),
  bgSecondary: Color(0xFF050805),
  bgTertiary: Color(0xFF0A100A),
  bgInput: Color(0xFF000000),
  borderPrimary: Color(0xFF0F2A0F),
  borderSecondary: Color(0xFF1A3A1A),
  textPrimary: Color(0xFF00FF41),
  textSecondary: Color(0xFF14B82E),
  textTertiary: Color(0xFF0A6E1B),
  accentGreen: Color(0xFF00FF41),
  accentYellow: Color(0xFFCFFF41),
  accentBlue: Color(0xFF41FFC9),
  accentPurple: Color(0xFF8AFF41),
  accentRed: Color(0xFFFF4141),
  accentCyan: Color(0xFF41FFFF),
  accentOrange: Color(0xFFFFB341),
  heatmap0: Color(0xFF0A100A),
  heatmap1: Color(0xFF073D14),
  heatmap2: Color(0xFF0E7F23),
  heatmap3: Color(0xFF1FCC36),
  heatmap4: Color(0xFF00FF41),
);

class ThemeController extends ChangeNotifier {
  AppThemeMode _mode = AppThemeMode.dark;
  bool _notificationsEnabled = true;
  bool _booted = false;

  AppThemeMode get mode => _mode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get booted => _booted;

  AppPalette get palette {
    switch (_mode) {
      case AppThemeMode.light:
        return _lightPalette;
      case AppThemeMode.coder:
        return _coderPalette;
      case AppThemeMode.dark:
        return _darkPalette;
    }
  }

  ThemeController() {
    _boot();
  }

  Future<void> _boot() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('appSettings');
    if (raw != null) {
      try {
        final s = AppSettings.fromJson(_decode(raw));
        _mode = s.theme;
        _notificationsEnabled = s.notificationsEnabled;
      } catch (_) {}
    }
    _booted = true;
    _applySystemUi();
    notifyListeners();
  }

  Future<void> setMode(AppThemeMode m) async {
    _mode = m;
    _applySystemUi();
    notifyListeners();
    await _persist();
  }

  Future<void> setNotificationsEnabled(bool v) async {
    _notificationsEnabled = v;
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final s = AppSettings(theme: _mode, notificationsEnabled: _notificationsEnabled);
    await prefs.setString('appSettings', _encode(s.toJson()));
  }

  void _applySystemUi() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          palette.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: palette.bgSecondary,
      systemNavigationBarIconBrightness:
          palette.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
    ));
  }

  String _encode(Map<String, dynamic> m) =>
      m.entries.map((e) => '${e.key}=${e.value}').join('&');

  Map<String, dynamic> _decode(String s) {
    final map = <String, dynamic>{};
    for (final part in s.split('&')) {
      final i = part.indexOf('=');
      if (i < 0) continue;
      final k = part.substring(0, i);
      final v = part.substring(i + 1);
      if (v == 'true' || v == 'false') {
        map[k] = v == 'true';
      } else {
        map[k] = v;
      }
    }
    return map;
  }
}

/// Static accessor that proxies the active palette. Updated by ThemedApp on
/// theme change; existing widgets keep using `AppColors.x` unchanged.
class AppColors {
  static AppPalette _active = _darkPalette;
  static void apply(AppPalette p) {
    _active = p;
  }

  static Color get bgPrimary => _active.bgPrimary;
  static Color get bgSecondary => _active.bgSecondary;
  static Color get bgTertiary => _active.bgTertiary;
  static Color get bgInput => _active.bgInput;
  static Color get borderPrimary => _active.borderPrimary;
  static Color get borderSecondary => _active.borderSecondary;
  static Color get textPrimary => _active.textPrimary;
  static Color get textSecondary => _active.textSecondary;
  static Color get textTertiary => _active.textTertiary;
  static Color get accentGreen => _active.accentGreen;
  static Color get accentYellow => _active.accentYellow;
  static Color get accentBlue => _active.accentBlue;
  static Color get accentPurple => _active.accentPurple;
  static Color get accentRed => _active.accentRed;
  static Color get accentCyan => _active.accentCyan;
  static Color get accentOrange => _active.accentOrange;
  static Color get heatmap0 => _active.heatmap0;
  static Color get heatmap1 => _active.heatmap1;
  static Color get heatmap2 => _active.heatmap2;
  static Color get heatmap3 => _active.heatmap3;
  static Color get heatmap4 => _active.heatmap4;
}

class AppTheme {
  static ThemeData fromPalette(AppPalette p) {
    final base = p.brightness == Brightness.light ? ThemeData.light() : ThemeData.dark();
    final mono = GoogleFonts.jetBrainsMonoTextTheme(base.textTheme);
    return ThemeData(
      brightness: p.brightness,
      scaffoldBackgroundColor: p.bgPrimary,
      colorScheme: ColorScheme(
        brightness: p.brightness,
        surface: p.bgPrimary,
        onSurface: p.textPrimary,
        primary: p.accentGreen,
        onPrimary: p.bgPrimary,
        secondary: p.accentCyan,
        onSecondary: p.bgPrimary,
        error: p.accentRed,
        onError: p.bgPrimary,
      ),
      textTheme: mono.apply(bodyColor: p.textPrimary, displayColor: p.textPrimary),
      fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
      appBarTheme: AppBarTheme(backgroundColor: p.bgSecondary, elevation: 0),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.bgInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: p.borderPrimary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: p.borderPrimary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: p.accentGreen.withValues(alpha: 0.4)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        labelStyle: TextStyle(color: p.textTertiary, fontSize: 10),
        hintStyle: TextStyle(color: p.textTertiary, fontSize: 12),
      ),
    );
  }

  // legacy accessor retained for compatibility
  static ThemeData get dark => fromPalette(_darkPalette);
}

/// Wraps MaterialApp and rebuilds it on theme change.
class ThemedApp extends StatelessWidget {
  final Widget Function(BuildContext) homeBuilder;
  final String title;
  const ThemedApp({super.key, required this.homeBuilder, required this.title});

  @override
  Widget build(BuildContext context) {
    final tc = context.watch<ThemeController>();
    AppColors.apply(tc.palette);
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.fromPalette(tc.palette),
      home: Builder(builder: homeBuilder),
    );
  }
}
