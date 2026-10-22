import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Colour tokens from docs/02-DESIGN.md §2 and the design canvas. The light
/// set keeps the same roles with contrast checked against white (≥4.5:1 for
/// text tokens).
class Palette {
  const Palette({
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.track,
    required this.divider,
    required this.primary,
    required this.primaryContainer,
    required this.primaryContainerLow,
    required this.onPrimaryContainer,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.earned,
    required this.earnedContainer,
    required this.earnedBorder,
    required this.attention,
    required this.attentionContainer,
    required this.danger,
    required this.dangerText,
    required this.dangerContainer,
    required this.chipGold,
    required this.chipSilver,
    required this.spark,
    required this.outline,
  });

  final Color background;
  final Color surface;
  final Color surfaceHigh;
  final Color track;
  final Color divider;
  final Color primary;
  final Color primaryContainer;
  final Color primaryContainerLow;
  final Color onPrimaryContainer;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color earned;
  final Color earnedContainer;
  final Color earnedBorder;
  final Color attention;
  final Color attentionContainer;
  final Color danger;
  final Color dangerText;
  final Color dangerContainer;
  final Color chipGold;
  final Color chipSilver;
  final Color spark;
  final Color outline;
}

const darkPalette = Palette(
  background: Color(0xFF0E0F13),
  surface: Color(0xFF171922),
  surfaceHigh: Color(0xFF14161D),
  track: Color(0xFF262938),
  divider: Color(0xFF23263A),
  primary: Color(0xFF6A5AE0),
  primaryContainer: Color(0xFF2A2550),
  primaryContainerLow: Color(0xFF1F1B3A),
  onPrimaryContainer: Color(0xFFB7ACFF),
  textPrimary: Color(0xFFF2F3F7),
  textSecondary: Color(0xFF9AA0B4),
  textTertiary: Color(0xFFC9CDD9),
  earned: Color(0xFF3DD68C),
  earnedContainer: Color(0xFF15261E),
  earnedBorder: Color(0xFF2F7A55),
  attention: Color(0xFFF5B54A),
  attentionContainer: Color(0xFF3A3320),
  danger: Color(0xFFFF6B6B),
  dangerText: Color(0xFFFF8A8A),
  dangerContainer: Color(0xFF3A1F24),
  chipGold: Color(0xFFD9C38A),
  chipSilver: Color(0xFFC9CDD4),
  spark: Color(0xFFF5B54A),
  outline: Color(0xFF3A3E52),
);

const lightPalette = Palette(
  background: Color(0xFFF5F6FA),
  surface: Color(0xFFFFFFFF),
  surfaceHigh: Color(0xFFECEEF4),
  track: Color(0xFFE1E4EE),
  divider: Color(0xFFE1E4EE),
  primary: Color(0xFF5B4BD6),
  primaryContainer: Color(0xFFE6E2FF),
  primaryContainerLow: Color(0xFFF1EEFF),
  onPrimaryContainer: Color(0xFF3B2DA3),
  textPrimary: Color(0xFF14161D),
  textSecondary: Color(0xFF5A6075),
  textTertiary: Color(0xFF3D4254),
  earned: Color(0xFF0F7A4A),
  earnedContainer: Color(0xFFE2F5EB),
  earnedBorder: Color(0xFF8ACDAA),
  attention: Color(0xFF8F5A00),
  attentionContainer: Color(0xFFFFF0D2),
  danger: Color(0xFFD93838),
  dangerText: Color(0xFFB42323),
  dangerContainer: Color(0xFFFDE3E3),
  chipGold: Color(0xFFD9C38A),
  chipSilver: Color(0xFFC9CDD4),
  spark: Color(0xFFE09B1F),
  outline: Color(0xFFC4C8D6),
);

/// The palette in use. Screens read colours from here; [CardMasterApp]
/// switches it when the theme changes and rebuilds every widget.
abstract final class AppColors {
  static Palette _p = darkPalette;
  static Brightness get brightness =>
      identical(_p, darkPalette) ? Brightness.dark : Brightness.light;
  static void use(Brightness b) =>
      _p = b == Brightness.dark ? darkPalette : lightPalette;

  static Color get background => _p.background;
  static Color get surface => _p.surface;
  static Color get surfaceHigh => _p.surfaceHigh;
  static Color get track => _p.track;
  static Color get divider => _p.divider;
  static Color get primary => _p.primary;
  static Color get primaryContainer => _p.primaryContainer;
  static Color get primaryContainerLow => _p.primaryContainerLow;
  static Color get onPrimaryContainer => _p.onPrimaryContainer;
  static Color get textPrimary => _p.textPrimary;
  static Color get textSecondary => _p.textSecondary;
  static Color get textTertiary => _p.textTertiary;
  static Color get earned => _p.earned;
  static Color get earnedContainer => _p.earnedContainer;
  static Color get earnedBorder => _p.earnedBorder;
  static Color get attention => _p.attention;
  static Color get attentionContainer => _p.attentionContainer;
  static Color get danger => _p.danger;
  static Color get dangerText => _p.dangerText;
  static Color get dangerContainer => _p.dangerContainer;
  static Color get chipGold => _p.chipGold;
  static Color get chipSilver => _p.chipSilver;
  static Color get spark => _p.spark;
}

ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final p = dark ? darkPalette : lightPalette;
  // The named constructors, not copyWith: copyWith keeps the defaults'
  // derived colours (teal secondaryContainer) instead of re-deriving them.
  final scheme = dark
      ? ColorScheme.dark(
          surface: p.background,
          primary: p.primary,
          onPrimary: Colors.white,
          primaryContainer: p.primaryContainer,
          onPrimaryContainer: p.onPrimaryContainer,
          secondary: p.onPrimaryContainer,
          error: p.danger,
          onSurface: p.textPrimary,
          onSurfaceVariant: p.textSecondary,
          surfaceContainer: p.surface,
          surfaceContainerHigh: p.surfaceHigh,
          outline: p.outline,
        )
      : ColorScheme.light(
          surface: p.background,
          primary: p.primary,
          onPrimary: Colors.white,
          primaryContainer: p.primaryContainer,
          onPrimaryContainer: p.onPrimaryContainer,
          secondary: p.onPrimaryContainer,
          error: p.danger,
          onSurface: p.textPrimary,
          onSurfaceVariant: p.textSecondary,
          surfaceContainer: p.surface,
          surfaceContainerHigh: p.surfaceHigh,
          outline: p.outline,
        );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.background,
    fontFamily: 'Manrope',
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: p.textPrimary,
      displayColor: p.textPrimary,
    ),
    appBarTheme: AppBarTheme(
      systemOverlayStyle: dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      backgroundColor: p.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: p.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
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
        foregroundColor: p.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.surfaceHigh,
      indicatorColor: p.primaryContainer,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: p.surface,
      selectedColor: p.primaryContainer,
      side: BorderSide.none,
      labelStyle: TextStyle(
        fontFamily: 'Manrope',
        fontWeight: FontWeight.w700,
        color: p.textPrimary,
      ),
    ),
    dividerColor: p.divider,
  );
}

/// Points [AppColors] at the palette for the theme in use. Widgets built
/// with `const` don't rebuild on their own, so after a switch every element
/// is marked dirty once.
void syncPalette(BuildContext context) {
  final b = Theme.of(context).brightness;
  if (AppColors.brightness == b) return;
  AppColors.use(b);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    void mark(Element e) {
      e.markNeedsBuild();
      e.visitChildren(mark);
    }

    if (context.mounted) (context as Element).visitChildren(mark);
  });
}
