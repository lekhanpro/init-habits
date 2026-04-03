import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bgPrimary = Color(0xFF0A0A0F);
  static const bgSecondary = Color(0xFF12121A);
  static const bgTertiary = Color(0xFF1A1A25);
  static const bgInput = Color(0xFF0F0F18);
  static const borderPrimary = Color(0xFF1E1E2E);
  static const borderSecondary = Color(0xFF2A2A3A);
  static const textPrimary = Color(0xFFE8E8ED);
  static const textSecondary = Color(0xFF6B6B80);
  static const textTertiary = Color(0xFF4A4A5A);
  static const accentGreen = Color(0xFF00FF9F);
  static const accentYellow = Color(0xFFFFB800);
  static const accentBlue = Color(0xFF00B4FF);
  static const accentPurple = Color(0xFFA855F7);
  static const accentRed = Color(0xFFFF4444);
  static const accentCyan = Color(0xFF22D3EE);
  static const accentOrange = Color(0xFFFF6B2C);
  static const heatmap0 = Color(0xFF1A1A25);
  static const heatmap1 = Color(0xFF0D3320);
  static const heatmap2 = Color(0xFF166534);
  static const heatmap3 = Color(0xFF22C55E);
  static const heatmap4 = Color(0xFF00FF9F);
}

class AppTheme {
  static ThemeData get dark {
    final mono = GoogleFonts.jetBrainsMonoTextTheme(
      ThemeData.dark().textTheme,
    );
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgPrimary,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.bgPrimary,
        primary: AppColors.accentGreen,
        error: AppColors.accentRed,
      ),
      textTheme: mono.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgSecondary,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.borderPrimary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.borderPrimary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: AppColors.accentGreen.withValues(alpha: 0.4)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        labelStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 10),
        hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
      ),
    );
  }
}
