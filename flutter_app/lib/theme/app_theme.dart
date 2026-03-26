import 'package:flutter/material.dart';

/// SecureNet design theme (dark) with warm modern accents.
class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFFFFB86C);
  static const Color onPrimary = Color(0xFF2A1705);
  static const Color primaryContainer = Color(0xFF5A3410);
  static const Color secondary = Color(0xFFB8D38F);
  static const Color tertiary = Color(0xFFF4D6A0);
  static const Color error = Color(0xFFFF7A6E);
  static const Color background = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF1F1A16);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1F1A16);
  static const Color surfaceVariant = Color(0xFFF4EFE9);
  static const Color onSurfaceVariant = Color(0xFF6F6458);
  static const Color outline = Color(0xFFC5B9AC);
  static const Color divider = Color(0xFFE6DED5);

  static const Color success = Color(0xFF7FD38B);
  static const Color warning = Color(0xFFFFB56B);
  static const Color secure = Color(0xFF7FD38B);
  static const Color lowRisk = Color(0xFFB8D38F);
  static const Color mediumRisk = Color(0xFFFFB56B);
  static const Color highRisk = Color(0xFFFF9258);
  static const Color critical = Color(0xFFFF7A6E);

  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacingXxl = 48;
  static const double spacingXxxl = 64;

  static const double radiusXs = 2;
  static const double radiusSm = 4;
  static const double radiusMd = 8;
  static const double radiusLg = 16;
  static const double radiusXl = 24;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        onSecondary: Color(0xFF500050),
        error: error,
        onError: Color(0xFF690005),
        surface: surface,
        onSurface: onSurface,
        surfaceContainerHighest: surfaceVariant,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: onSurface,
        elevation: 0,
      ),
      textTheme: _textTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: spacingLg, vertical: spacingMd),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusSm)),
        contentPadding: const EdgeInsets.symmetric(horizontal: spacingSm, vertical: spacingSm),
        hintStyle: const TextStyle(color: onSurfaceVariant),
      ),
    );
  }

  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400, color: onSurface),
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w400, color: onSurface),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w400, color: onSurface),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: onSurface),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w400, color: onSurface),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: onSurface),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: onSurface),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: onSurface),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: onSurfaceVariant),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: onSurfaceVariant),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: onSurface),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: onSurfaceVariant),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: onSurfaceVariant),
  );
}
