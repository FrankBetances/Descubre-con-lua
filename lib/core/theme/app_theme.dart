import 'package:flutter/material.dart';

/// Design tokens and Material 3 theme configuration for «Descubre con Lúa · Edición Vigo».
///
/// Tailored strictly for adult educators and families (zero child game mechanics,
/// zero neon/distracting animations, high contrast, body text >= 16sp).
class AppTheme {
  AppTheme._();

  // Maritime Vigo Palette tokens
  static const Color primaryVigoBlue = Color(0xFF1B4965);
  static const Color secondarySeaGlass = Color(0xFF62B6CB);
  static const Color backgroundSand = Color(0xFFF4F1DE);
  static const Color textSlate = Color(0xFF1C2541);
  static const Color accentTerracotta = Color(0xFFE07A5F);
  static const Color calmSage = Color(0xFF81B29A);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEBE7D5);

  /// Light theme definition for adult educators and families.
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primaryVigoBlue,
      onPrimary: Colors.white,
      secondary: secondarySeaGlass,
      onSecondary: textSlate,
      tertiary: accentTerracotta,
      onTertiary: Colors.white,
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      surface: backgroundSand,
      onSurface: textSlate,
      surfaceContainerHighest: surfaceVariant,
      onSurfaceVariant: textSlate,
      outline: Color(0xFFB0B7BD),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundSand,
      fontFamily: 'Roboto',
      
      // High-legibility typography for adults (body >= 16sp)
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 30.0,
          fontWeight: FontWeight.bold,
          color: textSlate,
          height: 1.25,
        ),
        headlineMedium: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.w700,
          color: primaryVigoBlue,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: primaryVigoBlue,
          height: 1.35,
        ),
        titleLarge: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.w700,
          color: textSlate,
          height: 1.3,
        ),
        titleMedium: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          color: textSlate,
          height: 1.35,
        ),
        titleSmall: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          color: textSlate,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.normal,
          color: textSlate,
          height: 1.55,
          letterSpacing: 0.15,
        ),
        bodyMedium: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.normal,
          color: textSlate,
          height: 1.5,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.normal,
          color: Color(0xFF4A5568),
          height: 1.45,
        ),
        labelLarge: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          color: textSlate,
          letterSpacing: 0.1,
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: primaryVigoBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
      ),

      cardTheme: CardTheme(
        color: cardSurface,
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: const BorderSide(color: Color(0xFFE2E0D4), width: 1.0),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryVigoBlue,
          foregroundColor: Colors.white,
          elevation: 1.0,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
          textStyle: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryVigoBlue,
          side: const BorderSide(color: primaryVigoBlue, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          textStyle: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }
}
