import 'dart:convert';
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

const _synthwavePalette = AppPalette(
  bgPrimary: Color(0xFF0D0221),
  bgSecondary: Color(0xFF150432),
  bgTertiary: Color(0xFF1E0845),
  bgInput: Color(0xFF0A0118),
  borderPrimary: Color(0xFF2D0860),
  borderSecondary: Color(0xFF3F0F80),
  textPrimary: Color(0xFFFFE4F5),
  textSecondary: Color(0xFFCC88BB),
  textTertiary: Color(0xFF884477),
  accentGreen: Color(0xFF05FFA1),
  accentYellow: Color(0xFFFFE600),
  accentBlue: Color(0xFF00C6FF),
  accentPurple: Color(0xFFCC44FF),
  accentRed: Color(0xFFFF2D6E),
  accentCyan: Color(0xFF00F5FF),
  accentOrange: Color(0xFFFF6B35),
  heatmap0: Color(0xFF1E0845),
  heatmap1: Color(0xFF4A0A6B),
  heatmap2: Color(0xFF8B0FAA),
  heatmap3: Color(0xFFCC44FF),
  heatmap4: Color(0xFFFF00FF),
);

const _matrixPalette = AppPalette(
  bgPrimary: Color(0xFF000000),
  bgSecondary: Color(0xFF001400),
  bgTertiary: Color(0xFF001A00),
  bgInput: Color(0xFF000A00),
  borderPrimary: Color(0xFF003300),
  borderSecondary: Color(0xFF004400),
  textPrimary: Color(0xFF00FF41),
  textSecondary: Color(0xFF00AA2B),
  textTertiary: Color(0xFF005517),
  accentGreen: Color(0xFF00FF41),
  accentYellow: Color(0xFF66FF00),
  accentBlue: Color(0xFF00FFAA),
  accentPurple: Color(0xFF00FF88),
  accentRed: Color(0xFFFF2200),
  accentCyan: Color(0xFF00FFDD),
  accentOrange: Color(0xFF88FF00),
  heatmap0: Color(0xFF001400),
  heatmap1: Color(0xFF003A00),
  heatmap2: Color(0xFF006600),
  heatmap3: Color(0xFF00AA00),
  heatmap4: Color(0xFF00FF41),
);

const _solarizedPalette = AppPalette(
  bgPrimary: Color(0xFF002B36),
  bgSecondary: Color(0xFF073642),
  bgTertiary: Color(0xFF094555),
  bgInput: Color(0xFF001F28),
  borderPrimary: Color(0xFF0D5265),
  borderSecondary: Color(0xFF126277),
  textPrimary: Color(0xFFEEE8D5),
  textSecondary: Color(0xFF93A1A1),
  textTertiary: Color(0xFF657B83),
  accentGreen: Color(0xFF859900),
  accentYellow: Color(0xFFB58900),
  accentBlue: Color(0xFF268BD2),
  accentPurple: Color(0xFF6C71C4),
  accentRed: Color(0xFFDC322F),
  accentCyan: Color(0xFF2AA198),
  accentOrange: Color(0xFFCB4B16),
  heatmap0: Color(0xFF073642),
  heatmap1: Color(0xFF0B4A39),
  heatmap2: Color(0xFF1A6B3C),
  heatmap3: Color(0xFF4F8C3F),
  heatmap4: Color(0xFF859900),
);

const _gruvboxPalette = AppPalette(
  bgPrimary: Color(0xFF282828),
  bgSecondary: Color(0xFF32302F),
  bgTertiary: Color(0xFF3C3836),
  bgInput: Color(0xFF1D2021),
  borderPrimary: Color(0xFF504945),
  borderSecondary: Color(0xFF665C54),
  textPrimary: Color(0xFFEBDBB2),
  textSecondary: Color(0xFFBDAE93),
  textTertiary: Color(0xFF928374),
  accentGreen: Color(0xFFB8BB26),
  accentYellow: Color(0xFFFABD2F),
  accentBlue: Color(0xFF83A598),
  accentPurple: Color(0xFFD3869B),
  accentRed: Color(0xFFFB4934),
  accentCyan: Color(0xFF8EC07C),
  accentOrange: Color(0xFFFE8019),
  heatmap0: Color(0xFF3C3836),
  heatmap1: Color(0xFF4A5C22),
  heatmap2: Color(0xFF6A7F28),
  heatmap3: Color(0xFF98A12A),
  heatmap4: Color(0xFFB8BB26),
);

const _catppuccinMochaPalette = AppPalette(
  bgPrimary: Color(0xFF1E1E2E),
  bgSecondary: Color(0xFF181825),
  bgTertiary: Color(0xFF313244),
  bgInput: Color(0xFF11111B),
  borderPrimary: Color(0xFF45475A),
  borderSecondary: Color(0xFF585B70),
  textPrimary: Color(0xFFCDD6F4),
  textSecondary: Color(0xFFBAC2DE),
  textTertiary: Color(0xFF9399B2),
  accentGreen: Color(0xFFA6E3A1),
  accentYellow: Color(0xFFF9E2AF),
  accentBlue: Color(0xFF89B4FA),
  accentPurple: Color(0xFFCBA6F7),
  accentRed: Color(0xFFF38BA8),
  accentCyan: Color(0xFF89DCEB),
  accentOrange: Color(0xFFFAB387),
  heatmap0: Color(0xFF313244),
  heatmap1: Color(0xFF264738),
  heatmap2: Color(0xFF3A6B50),
  heatmap3: Color(0xFF6DA882),
  heatmap4: Color(0xFFA6E3A1),
);

const _nordPalette = AppPalette(
  bgPrimary: Color(0xFF2E3440),
  bgSecondary: Color(0xFF3B4252),
  bgTertiary: Color(0xFF434C5E),
  bgInput: Color(0xFF242933),
  borderPrimary: Color(0xFF4C566A),
  borderSecondary: Color(0xFF5E6779),
  textPrimary: Color(0xFFECEFF4),
  textSecondary: Color(0xFFD8DEE9),
  textTertiary: Color(0xFF8892A0),
  accentGreen: Color(0xFFA3BE8C),
  accentYellow: Color(0xFFEBCB8B),
  accentBlue: Color(0xFF81A1C1),
  accentPurple: Color(0xFFB48EAD),
  accentRed: Color(0xFFBF616A),
  accentCyan: Color(0xFF88C0D0),
  accentOrange: Color(0xFFD08770),
  heatmap0: Color(0xFF434C5E),
  heatmap1: Color(0xFF3A5C42),
  heatmap2: Color(0xFF4D7A58),
  heatmap3: Color(0xFF6EA07D),
  heatmap4: Color(0xFFA3BE8C),
);

const _draculaPalette = AppPalette(
  bgPrimary: Color(0xFF282A36),
  bgSecondary: Color(0xFF1E1F29),
  bgTertiary: Color(0xFF343746),
  bgInput: Color(0xFF191A23),
  borderPrimary: Color(0xFF44475A),
  borderSecondary: Color(0xFF565970),
  textPrimary: Color(0xFFF8F8F2),
  textSecondary: Color(0xFFBDBDBF),
  textTertiary: Color(0xFF6272A4),
  accentGreen: Color(0xFF50FA7B),
  accentYellow: Color(0xFFF1FA8C),
  accentBlue: Color(0xFF6272A4),
  accentPurple: Color(0xFFBD93F9),
  accentRed: Color(0xFFFF5555),
  accentCyan: Color(0xFF8BE9FD),
  accentOrange: Color(0xFFFFB86C),
  heatmap0: Color(0xFF343746),
  heatmap1: Color(0xFF264038),
  heatmap2: Color(0xFF2D6040),
  heatmap3: Color(0xFF3A9957),
  heatmap4: Color(0xFF50FA7B),
);

const _oneDarkPalette = AppPalette(
  bgPrimary: Color(0xFF282C34),
  bgSecondary: Color(0xFF21252B),
  bgTertiary: Color(0xFF2C313C),
  bgInput: Color(0xFF1B1F27),
  borderPrimary: Color(0xFF3E4452),
  borderSecondary: Color(0xFF4B5263),
  textPrimary: Color(0xFFABB2BF),
  textSecondary: Color(0xFF818896),
  textTertiary: Color(0xFF5C6370),
  accentGreen: Color(0xFF98C379),
  accentYellow: Color(0xFFE5C07B),
  accentBlue: Color(0xFF61AFEF),
  accentPurple: Color(0xFFC678DD),
  accentRed: Color(0xFFE06C75),
  accentCyan: Color(0xFF56B6C2),
  accentOrange: Color(0xFFD19A66),
  heatmap0: Color(0xFF2C313C),
  heatmap1: Color(0xFF2A4228),
  heatmap2: Color(0xFF3B6235),
  heatmap3: Color(0xFF618C5A),
  heatmap4: Color(0xFF98C379),
);

const _tokyonightPalette = AppPalette(
  bgPrimary: Color(0xFF1A1B26),
  bgSecondary: Color(0xFF16161E),
  bgTertiary: Color(0xFF1F2335),
  bgInput: Color(0xFF13131B),
  borderPrimary: Color(0xFF292E42),
  borderSecondary: Color(0xFF3B4261),
  textPrimary: Color(0xFFC0CAF5),
  textSecondary: Color(0xFF9AACDB),
  textTertiary: Color(0xFF565F89),
  accentGreen: Color(0xFF9ECE6A),
  accentYellow: Color(0xFFE0AF68),
  accentBlue: Color(0xFF7AA2F7),
  accentPurple: Color(0xFFBB9AF7),
  accentRed: Color(0xFFF7768E),
  accentCyan: Color(0xFF7DCFFF),
  accentOrange: Color(0xFFFF9E64),
  heatmap0: Color(0xFF1F2335),
  heatmap1: Color(0xFF1E3B2A),
  heatmap2: Color(0xFF2A5C3A),
  heatmap3: Color(0xFF4A8C5A),
  heatmap4: Color(0xFF9ECE6A),
);

const _catppuccinLattePalette = AppPalette(
  bgPrimary: Color(0xFFEFF1F5),
  bgSecondary: Color(0xFFE6E9EF),
  bgTertiary: Color(0xFFDCE0E8),
  bgInput: Color(0xFFE6E9EF),
  borderPrimary: Color(0xFFCCD0DA),
  borderSecondary: Color(0xFFBCC0CC),
  textPrimary: Color(0xFF4C4F69),
  textSecondary: Color(0xFF6C6F85),
  textTertiary: Color(0xFF8C8FA1),
  accentGreen: Color(0xFF40A02B),
  accentYellow: Color(0xFFDF8E1D),
  accentBlue: Color(0xFF1E66F5),
  accentPurple: Color(0xFF8839EF),
  accentRed: Color(0xFFD20F39),
  accentCyan: Color(0xFF04A5E5),
  accentOrange: Color(0xFFFE640B),
  heatmap0: Color(0xFFE6E9EF),
  heatmap1: Color(0xFFB7E4B7),
  heatmap2: Color(0xFF7FCB7F),
  heatmap3: Color(0xFF40A02B),
  heatmap4: Color(0xFF2E7D1F),
  brightness: Brightness.light,
);

const _catppuccinFrappePalette = AppPalette(
  bgPrimary: Color(0xFF303446),
  bgSecondary: Color(0xFF292C3C),
  bgTertiary: Color(0xFF232634),
  bgInput: Color(0xFF292C3C),
  borderPrimary: Color(0xFF414559),
  borderSecondary: Color(0xFF51576D),
  textPrimary: Color(0xFFC6D0F5),
  textSecondary: Color(0xFFA5ADCE),
  textTertiary: Color(0xFF838BA7),
  accentGreen: Color(0xFFA6D189),
  accentYellow: Color(0xFFE5C890),
  accentBlue: Color(0xFF8CAAEE),
  accentPurple: Color(0xFFCA9EE6),
  accentRed: Color(0xFFE78284),
  accentCyan: Color(0xFF99D1DB),
  accentOrange: Color(0xFFEF9F76),
  heatmap0: Color(0xFF292C3C),
  heatmap1: Color(0xFF3D4A3A),
  heatmap2: Color(0xFF5F8C56),
  heatmap3: Color(0xFFA6D189),
  heatmap4: Color(0xFFCBE0B0),
);

const _catppuccinMacchiatoPalette = AppPalette(
  bgPrimary: Color(0xFF24273A),
  bgSecondary: Color(0xFF1E2030),
  bgTertiary: Color(0xFF181926),
  bgInput: Color(0xFF1E2030),
  borderPrimary: Color(0xFF363A4F),
  borderSecondary: Color(0xFF494D64),
  textPrimary: Color(0xFFCAD3F5),
  textSecondary: Color(0xFFA5ADCB),
  textTertiary: Color(0xFF8087A2),
  accentGreen: Color(0xFFA6DA95),
  accentYellow: Color(0xFFEED49F),
  accentBlue: Color(0xFF8AADF4),
  accentPurple: Color(0xFFC6A0F6),
  accentRed: Color(0xFFED8796),
  accentCyan: Color(0xFF91D7E3),
  accentOrange: Color(0xFFF5A97F),
  heatmap0: Color(0xFF1E2030),
  heatmap1: Color(0xFF3A4A38),
  heatmap2: Color(0xFF5F8C56),
  heatmap3: Color(0xFFA6DA95),
  heatmap4: Color(0xFFCAE5BB),
);

const _solarizedLightPalette = AppPalette(
  bgPrimary: Color(0xFFFDF6E3),
  bgSecondary: Color(0xFFEEE8D5),
  bgTertiary: Color(0xFFE0DABF),
  bgInput: Color(0xFFEEE8D5),
  borderPrimary: Color(0xFFCCC5B0),
  borderSecondary: Color(0xFFAEA98D),
  textPrimary: Color(0xFF073642),
  textSecondary: Color(0xFF657B83),
  textTertiary: Color(0xFF93A1A1),
  accentGreen: Color(0xFF859900),
  accentYellow: Color(0xFFB58900),
  accentBlue: Color(0xFF268BD2),
  accentPurple: Color(0xFF6C71C4),
  accentRed: Color(0xFFDC322F),
  accentCyan: Color(0xFF2AA198),
  accentOrange: Color(0xFFCB4B16),
  heatmap0: Color(0xFFEEE8D5),
  heatmap1: Color(0xFFCCD8AE),
  heatmap2: Color(0xFFA1B864),
  heatmap3: Color(0xFF859900),
  heatmap4: Color(0xFF6B7A00),
  brightness: Brightness.light,
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
      case AppThemeMode.synthwave:
        return _synthwavePalette;
      case AppThemeMode.matrix:
        return _matrixPalette;
      case AppThemeMode.solarized:
        return _solarizedPalette;
      case AppThemeMode.gruvbox:
        return _gruvboxPalette;
      case AppThemeMode.catppuccinMocha:
        return _catppuccinMochaPalette;
      case AppThemeMode.nord:
        return _nordPalette;
      case AppThemeMode.dracula:
        return _draculaPalette;
      case AppThemeMode.oneDark:
        return _oneDarkPalette;
      case AppThemeMode.tokyonight:
        return _tokyonightPalette;
      case AppThemeMode.catppuccinLatte:
        return _catppuccinLattePalette;
      case AppThemeMode.catppuccinFrappe:
        return _catppuccinFrappePalette;
      case AppThemeMode.catppuccinMacchiato:
        return _catppuccinMacchiatoPalette;
      case AppThemeMode.solarizedLight:
        return _solarizedLightPalette;
      case AppThemeMode.dark:
        return _darkPalette;
    }
  }

  static const themeLabels = {
    AppThemeMode.dark: '🌑 dark',
    AppThemeMode.light: '☀️ light',
    AppThemeMode.coder: '💻 coder',
    AppThemeMode.synthwave: '🌊 synthwave',
    AppThemeMode.matrix: '🐇 matrix',
    AppThemeMode.solarized: '🌤 solarized',
    AppThemeMode.gruvbox: '🪵 gruvbox',
    AppThemeMode.catppuccinMocha: '☕ catppuccin',
    AppThemeMode.nord: '❄️ nord',
    AppThemeMode.dracula: '🧛 dracula',
    AppThemeMode.oneDark: '🔵 one dark',
    AppThemeMode.tokyonight: '🌆 tokyo night',
    AppThemeMode.catppuccinLatte: '☕ catppuccin latte',
    AppThemeMode.catppuccinFrappe: '☕ catppuccin frappe',
    AppThemeMode.catppuccinMacchiato: '☕ catppuccin macchiato',
    AppThemeMode.solarizedLight: '🌞 solarized light',
  };

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
    await prefs.setString('appSettings', jsonEncode(s.toJson()));
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

  Map<String, dynamic> _decode(String s) {
    try {
      return Map<String, dynamic>.from(jsonDecode(s));
    } catch (_) {
      // legacy key=value format
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
  final List<NavigatorObserver> navigatorObservers;
  final String title;
  const ThemedApp({
    super.key,
    required this.homeBuilder,
    required this.title,
    this.navigatorObservers = const <NavigatorObserver>[],
  });

  @override
  Widget build(BuildContext context) {
    final tc = context.watch<ThemeController>();
    AppColors.apply(tc.palette);
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.fromPalette(tc.palette),
      navigatorObservers: navigatorObservers,
      home: Builder(builder: homeBuilder),
    );
  }
}
