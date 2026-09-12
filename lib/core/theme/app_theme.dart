import 'package:flutter/material.dart';

/// Tokens de diseño y tema Material 3 de «Descubre con Lúa · Edición Vigo».
///
/// Fuente única de verdad para color, radios, espaciado y tipografía. Son los
/// tokens de Valeria+ (`src/valeriaTheme.ts` de aquel repositorio), portados
/// para que las dos apps se vean como la misma familia. Lo que NO se hereda es
/// la mecánica infantil: aquí el niño no usa la pantalla, así que no hay nada
/// pensado para captar su atención.
///
/// La escala de espaciado va en múltiplos de 4 y la tipográfica tiene cinco
/// tamaños. Mezclar 11/13/15/18 sueltos es lo que en Valeria+ produjo la
/// sensación de «amontonado» que reportaron los testers.
class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------- color
  static const Color primary = Color(0xFF00C4BE); // Turquesa de marca
  static const Color primaryDark = Color(0xFF00A39E); // Pulsado / activo
  static const Color primaryLight = Color(0xFFE6F9F8); // Fondo destacado
  static const Color primaryTint = Color(0xFFF0FDF9); // Fondo muy suave
  static const Color pageBg = Color(0xFFF6FAFA);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE9EEEE);
  static const Color borderActive = Color(0xFFCDEEEC);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textMuted = Color(0xFF9AA6A5);
  static const Color error = Color(0xFFEF4444);
  static const Color errorBg = Color(0xFFFFF1F2);
  static const Color success = Color(0xFF10B981);
  static const Color successBg = Color(0xFFEAFAF2);
  static const Color star = Color(0xFFFACC15);
  static const Color dark = Color(0xFF0B1220);

  /// Turquesa para barras y cabeceras CON texto blanco.
  ///
  /// Existe por una medición: el blanco sobre el turquesa de marca da 2,18:1,
  /// que no llega ni al umbral de texto grande (3,0). Valeria+ lo lleva así;
  /// aquí no, porque esto se mira en un aula con ventanales y en un móvil al
  /// sol.
  ///
  /// Empezó en #0B4F4C (9,39:1) y Frank dijo que salía demasiado oscuro. Este
  /// es el tono MÁS CLARO que todavía pasa AA con texto pequeño: 5,16:1. Subir
  /// más ya no pasa —#158C85 se queda en 4,10— así que aquí no hay margen sin
  /// perder legibilidad.
  static const Color primaryInk = Color(0xFF127A75);

  // Nombres de la paleta anterior («Maritime Vigo»). Se conservan porque los
  // usan 147 sitios del código y romperlos no aportaba nada; apuntan ya a los
  // tokens nuevos, así que una pantalla sin tocar se ve con el estilo nuevo.
  // Código nuevo: usa los de arriba.
  static const Color primaryVigoBlue = primary;
  static const Color secondarySeaGlass = primaryDark;
  static const Color backgroundSand = pageBg;
  static const Color textSlate = textPrimary;
  static const Color accentTerracotta = star;
  static const Color calmSage = success;
  static const Color cardSurface = card;
  static const Color surfaceVariant = primaryLight;

  // --------------------------------------------------------------- radios
  static const double radiusCard = 16.0;
  static const double radiusField = 12.0;
  static const double radiusButton = 14.0;

  // ------------------------------------------------------------ espaciado
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 12.0;
  static const double spaceLg = 16.0;
  static const double spaceXl = 24.0;
  static const double spaceXxl = 32.0;

  /// Área táctil mínima accesible en Android.
  static const double touchMin = 48.0;

  static const String fontFamily = 'Nunito';

  // -------------------------------------------------------------- sombras
  /// Sombra de tarjeta. Suave y neutra: la tarjeta se separa del fondo sin
  /// pesar.
  static const List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Color(0x140F172A),
      offset: Offset(0, 2),
      blurRadius: 10,
    ),
  ];

  /// Sombra de botón primario: teñida del propio turquesa, no gris.
  static const List<BoxShadow> shadowButton = [
    BoxShadow(
      color: Color(0x5200C4BE),
      offset: Offset(0, 8),
      blurRadius: 18,
    ),
  ];

  /// Tema claro. Los adultos son los únicos que miran esta pantalla, así que el
  /// cuerpo de texto no baja de 16sp.
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      // Tinta oscura, no blanco: 8,59:1 frente a 2,18:1. Ver `primaryInk`.
      onPrimary: dark,
      secondary: primaryInk,
      onSecondary: Colors.white,
      tertiary: star,
      onTertiary: dark,
      error: error,
      onError: Colors.white,
      surface: pageBg,
      onSurface: textPrimary,
      surfaceContainerHighest: primaryLight,
      onSurfaceVariant: textSecondary,
      outline: border,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: pageBg,
      fontFamily: fontFamily,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 30.0,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          height: 1.25,
        ),
        headlineMedium: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: 1.35,
        ),
        titleLarge: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          height: 1.3,
        ),
        titleMedium: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: 1.35,
        ),
        titleSmall: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          height: 1.55,
        ),
        bodyMedium: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.45,
        ),
        labelLarge: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: 0.1,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryInk,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20.0,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: const BorderSide(color: border, width: 1.0),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: spaceLg,
          vertical: spaceSm,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: dark,
          elevation: 0,
          minimumSize: const Size(0, touchMin),
          padding: const EdgeInsets.symmetric(
            horizontal: spaceXl,
            vertical: spaceLg,
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 18.0,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryDark,
          backgroundColor: card,
          side: const BorderSide(color: borderActive, width: 1.5),
          minimumSize: const Size(0, touchMin),
          padding: const EdgeInsets.symmetric(
            horizontal: spaceXl,
            vertical: spaceMd,
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16.0,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryDark,
          minimumSize: const Size(0, touchMin),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: spaceXl,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primaryLight,
        side: const BorderSide(color: borderActive),
        labelStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 14.0,
          fontWeight: FontWeight.w700,
          color: primaryDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusField),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: border,
        linearMinHeight: 10,
      ),
    );
  }
}
