import 'package:flutter/material.dart';

/// Colour tokens from docs/02-DESIGN.md §2 and the design canvas.
abstract final class AppColors {
  static const background = Color(0xFF0E0F13);
  static const surface = Color(0xFF171922);
  static const surfaceHigh = Color(0xFF14161D);
  static const track = Color(0xFF262938);
  static const divider = Color(0xFF23263A);
  static const primary = Color(0xFF6A5AE0);
  static const primaryContainer = Color(0xFF2A2550);
  static const primaryContainerLow = Color(0xFF1F1B3A);
  static const onPrimaryContainer = Color(0xFFB7ACFF);
  static const textPrimary = Color(0xFFF2F3F7);
  static const textSecondary = Color(0xFF9AA0B4);
  static const textTertiary = Color(0xFFC9CDD9);
  static const earned = Color(0xFF3DD68C);
  static const earnedContainer = Color(0xFF15261E);
  static const earnedBorder = Color(0xFF2F7A55);
  static const attention = Color(0xFFF5B54A);
  static const attentionContainer = Color(0xFF3A3320);
  static const danger = Color(0xFFFF6B6B);
  static const dangerText = Color(0xFFFF8A8A);
  static const dangerContainer = Color(0xFF3A1F24);
  static const chipGold = Color(0xFFD9C38A);
  static const chipSilver = Color(0xFFC9CDD4);
  static const spark = Color(0xFFF5B54A);
}

ThemeData buildTheme() {
  const scheme = ColorScheme.dark(
    surface: AppColors.background,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    secondary: AppColors.onPrimaryContainer,
    error: AppColors.danger,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    surfaceContainer: AppColors.surface,
    surfaceContainerHigh: AppColors.surfaceHigh,
    outline: Color(0xFF3A3E52),
  );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Manrope',
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        foregroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surfaceHigh,
      indicatorColor: AppColors.primaryContainer,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primaryContainer,
      side: BorderSide.none,
      labelStyle: TextStyle(fontWeight: FontWeight.w700),
    ),
    dividerColor: AppColors.divider,
  );
}
