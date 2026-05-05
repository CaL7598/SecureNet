import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// SecureNet design theme based on exported neon-cyber concept.
class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF00F5FF);
  static const Color onPrimary = Color(0xFF003840);
  static const Color primaryContainer = Color(0xFF005058);
  static const Color secondary = Color(0xFFFF66FF);
  static const Color tertiary = Color(0xFFB388FF);
  static const Color error = Color(0xFFFF6699);
  static const Color background = Color(0xFF0A0A0F);
  static const Color onBackground = Color(0xFFE4E4E8);
  static const Color surface = Color(0xFF0A0A0F);
  static const Color onSurface = Color(0xFFE4E4E8);
  static const Color surfaceVariant = Color(0xFF35354A);
  static const Color onSurfaceVariant = Color(0xFFC6C6D8);
  static const Color outline = Color(0xFF8080A0);
  static const Color divider = Color(0xFF35354A);

  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFFB86B);
  static const Color secure = Color(0xFF34D399);
  static const Color lowRisk = Color(0xFF7ED957);
  static const Color mediumRisk = Color(0xFFFFB86B);
  static const Color highRisk = Color(0xFFFF8A5B);
  static const Color critical = Color(0xFFFF6699);

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

  static TextTheme get _textTheme => TextTheme(
        displayLarge: GoogleFonts.alexandria(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          color: onSurface,
          height: 1.12,
        ),
        displayMedium: GoogleFonts.alexandria(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          color: onSurface,
          height: 1.16,
        ),
        displaySmall: GoogleFonts.alexandria(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          color: onSurface,
          height: 1.22,
        ),
        headlineLarge: GoogleFonts.alexandria(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          color: onSurface,
          height: 1.25,
        ),
        headlineMedium: GoogleFonts.alexandria(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          color: onSurface,
          height: 1.29,
        ),
        headlineSmall: GoogleFonts.alexandria(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: onSurface,
          height: 1.33,
        ),
        titleLarge: GoogleFonts.alexandria(
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: onSurface,
          height: 1.27,
        ),
        titleMedium: GoogleFonts.alexandria(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: onSurface,
          height: 1.5,
        ),
        titleSmall: GoogleFonts.alexandria(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: onSurface,
          height: 1.43,
        ),
        bodyLarge: GoogleFonts.alexandria(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: onSurface,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.alexandria(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: onSurfaceVariant,
          height: 1.43,
        ),
        bodySmall: GoogleFonts.alexandria(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: onSurfaceVariant,
          height: 1.33,
        ),
        labelLarge: GoogleFonts.alexandria(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: onSurface,
          height: 1.43,
        ),
        labelMedium: GoogleFonts.alexandria(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: onSurfaceVariant,
          height: 1.33,
        ),
        labelSmall: GoogleFonts.alexandria(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: onSurfaceVariant,
          height: 1.45,
        ),
      );
}
