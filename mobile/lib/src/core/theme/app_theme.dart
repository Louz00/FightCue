import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFF7F7F7);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF1F1F1);
  static const border = Color(0xFFE6E6E6);
  static const textPrimary = Color(0xFF101010);
  static const textSecondary = Color(0xFF6C655E);
  static const accent = Color(0xFFD30F2F);
  static const accentDark = Color(0xFF97001C);
  static const ink = Color(0xFF141414);
  static const shadow = Color(0x14000000);
}

class AppShadows {
  static const card = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.accent,
      secondary: AppColors.accentDark,
      surface: AppColors.surface,
      onPrimary: Colors.white,
      onSurface: AppColors.textPrimary,
    ),
    useMaterial3: true,
  );

  return base.copyWith(
    dividerColor: AppColors.border,
    cardColor: AppColors.surface,
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.accent,
      elevation: 0,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? Colors.white : AppColors.textSecondary,
          size: 22,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          color: selected ? AppColors.textPrimary : AppColors.textSecondary,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 12,
          letterSpacing: 0.2,
        );
      }),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 34,
        height: 0.98,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.1,
        color: AppColors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: AppColors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.45,
        color: AppColors.textSecondary,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.3,
        color: AppColors.textSecondary,
      ),
    ),
  );
}
