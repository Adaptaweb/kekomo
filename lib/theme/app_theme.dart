import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static final ThemeData lightTheme = _buildTheme(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.androidLightPrimary,
      primaryContainer: AppColors.androidLightPrimaryContainer,
      secondary: AppColors.androidLightSecondary,
      secondaryContainer: AppColors.androidLightSecondaryContainer,
      tertiary: AppColors.androidLightTertiary,
      tertiaryContainer: AppColors.androidLightTertiaryContainer,
      surface: AppColors.lightSurface,
      surfaceContainerHighest: AppColors.lightSurfaceVariant,
      onSurfaceVariant: AppColors.lightOnSurfaceVariant,
      outline: AppColors.lightOutline,
      outlineVariant: AppColors.lightOutlineVariant,
    ),
    background: AppColors.lightBackground,
  );

  static final ThemeData darkTheme = _buildTheme(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      primaryContainer: AppColors.darkPrimaryContainer,
      secondary: AppColors.darkSecondary,
      secondaryContainer: AppColors.darkSecondaryContainer,
      tertiary: AppColors.darkTertiary,
      tertiaryContainer: AppColors.darkTertiaryContainer,
      surface: AppColors.darkSurface,
      surfaceContainerHighest: AppColors.darkSurfaceVariant,
      onSurface: AppColors.darkOnSurface,
      onSurfaceVariant: AppColors.darkOnSurfaceVariant,
      onPrimary: AppColors.darkOnPrimary,
      outline: AppColors.darkOutline,
      outlineVariant: AppColors.darkOutlineVariant,
    ),
    background: AppColors.darkBackground,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color background,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
    );
    final outfitFamily = GoogleFonts.outfit().fontFamily;
    return base.copyWith(
      textTheme: base.textTheme.apply(fontFamily: outfitFamily),
      primaryTextTheme: base.primaryTextTheme.apply(fontFamily: outfitFamily),
    );
  }

  static final _solidLightColorScheme = const ColorScheme.light(
    primary: AppColors.androidLightPrimary,
    onPrimary: AppColors.androidLightOnPrimary,
    primaryContainer: AppColors.androidLightPrimaryContainer,
    onPrimaryContainer: AppColors.androidLightOnPrimaryContainer,
    secondary: AppColors.androidLightSecondary,
    secondaryContainer: AppColors.androidLightSecondaryContainer,
    onSecondaryContainer: AppColors.androidLightOnSecondaryContainer,
    tertiary: AppColors.androidLightTertiary,
    tertiaryContainer: AppColors.androidLightTertiaryContainer,
    onTertiaryContainer: AppColors.androidLightOnTertiaryContainer,
    surface: AppColors.androidLightSurface,
    surfaceContainerLowest: AppColors.androidLightBackground,
    surfaceContainerLow: AppColors.androidLightSurfaceContainerLow,
    surfaceContainer: AppColors.androidLightSurfaceContainer,
    surfaceContainerHigh: AppColors.androidLightSurfaceContainerHigh,
    onSurface: AppColors.androidLightOnSurface,
    onSurfaceVariant: AppColors.androidLightOnSurfaceVariant,
    outline: AppColors.androidLightOutline,
    outlineVariant: AppColors.androidLightOutlineVariant,
  );

  static ThemeData materialLightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: _solidLightColorScheme,
    scaffoldBackgroundColor: AppColors.androidLightBackground,
    textTheme: ThemeData.light()
        .textTheme
        .apply(fontFamily: GoogleFonts.outfit().fontFamily),
    primaryTextTheme: ThemeData.light()
        .primaryTextTheme
        .apply(fontFamily: GoogleFonts.outfit().fontFamily),
    cardTheme: CardThemeData(
      color: AppColors.androidLightSurface,
      elevation: 2,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
            color: AppColors.androidLightOutline.withValues(alpha: 0.6),
            width: 0.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.androidLightPrimary,
        foregroundColor: AppColors.androidLightOnPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
              color: AppColors.androidLightPrimary.withValues(alpha: 0.3),
              width: 0.5),
        ),
        minimumSize: const Size.fromHeight(44),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.androidLightPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(
              color: AppColors.androidLightOutline, width: 1),
        ),
        minimumSize: const Size.fromHeight(44),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.androidLightOutline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color: AppColors.androidLightOutline.withValues(alpha: 0.6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppColors.androidLightPrimary, width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.androidLightSurfaceContainerHigh,
      labelStyle:
          const TextStyle(color: AppColors.androidLightOnSurfaceVariant),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
            color: AppColors.androidLightOutline.withValues(alpha: 0.5),
            width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.androidLightOutlineVariant,
      space: 1,
    ),
  );

  static final _solidDarkColorScheme = const ColorScheme.dark(
    primary: AppColors.androidDarkPrimary,
    onPrimary: AppColors.androidDarkOnPrimary,
    primaryContainer: AppColors.androidDarkPrimaryContainer,
    onPrimaryContainer: AppColors.androidDarkOnPrimaryContainer,
    secondary: AppColors.androidDarkSecondary,
    secondaryContainer: AppColors.androidDarkSecondaryContainer,
    onSecondaryContainer: AppColors.androidDarkOnSecondaryContainer,
    tertiary: AppColors.androidDarkTertiary,
    tertiaryContainer: AppColors.androidDarkTertiaryContainer,
    onTertiaryContainer: AppColors.androidDarkOnTertiaryContainer,
    surface: AppColors.androidDarkSurface,
    surfaceContainerLowest: AppColors.androidDarkBackground,
    surfaceContainerLow: AppColors.androidDarkSurfaceContainerLow,
    surfaceContainer: AppColors.androidDarkSurfaceContainer,
    surfaceContainerHigh: AppColors.androidDarkSurfaceContainerHigh,
    onSurface: AppColors.androidDarkOnSurface,
    onSurfaceVariant: AppColors.androidDarkOnSurfaceVariant,
    outline: AppColors.androidDarkOutline,
    outlineVariant: AppColors.androidDarkOutlineVariant,
  );

  static ThemeData materialDarkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: _solidDarkColorScheme,
    scaffoldBackgroundColor: AppColors.androidDarkBackground,
    textTheme: ThemeData.dark()
        .textTheme
        .apply(fontFamily: GoogleFonts.outfit().fontFamily),
    primaryTextTheme: ThemeData.dark()
        .primaryTextTheme
        .apply(fontFamily: GoogleFonts.outfit().fontFamily),
    cardTheme: CardThemeData(
      color: AppColors.androidDarkSurface,
      elevation: 2,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
            color: AppColors.androidDarkOutline.withValues(alpha: 0.6),
            width: 0.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.androidDarkPrimary,
        foregroundColor: AppColors.androidDarkOnPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
              color: AppColors.androidDarkPrimary.withValues(alpha: 0.3),
              width: 0.5),
        ),
        minimumSize: const Size.fromHeight(44),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.androidDarkPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(
              color: AppColors.androidDarkOutline, width: 1),
        ),
        minimumSize: const Size.fromHeight(44),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.androidDarkOutline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color: AppColors.androidDarkOutline.withValues(alpha: 0.6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppColors.androidDarkPrimary, width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.androidDarkSurfaceContainerHigh,
      labelStyle:
          const TextStyle(color: AppColors.androidDarkOnSurface),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
            color: AppColors.androidDarkOutline.withValues(alpha: 0.5),
            width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.androidDarkOutlineVariant,
      space: 1,
    ),
  );
}
