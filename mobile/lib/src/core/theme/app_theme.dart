import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF090A0D);
  static const surface = Color(0xFF12141A);
  static const surfaceAlt = Color(0xFF1A1E26);
  static const border = Color(0xFF272C37);
  static const textPrimary = Color(0xFFF5F7FA);
  static const textSecondary = Color(0xFFB3BCCB);
  static const accent = Color(0xFFFF5A36);
}

ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      surface: AppColors.surface,
    ),
    useMaterial3: true,
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
    ),
  );
}
