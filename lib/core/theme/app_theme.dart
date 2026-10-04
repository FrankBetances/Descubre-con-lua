import 'package:flutter/material.dart';

/// Tokens de diseño y tema Material 3 de «Descubre con Lúa · Edición Vigo».
///
/// Fuente única de verdad para color, radios, espaciado y tipografía. Son los
/// tokens del proyecto anterior de la casa, portados
/// para que las dos apps se vean como la misma familia. Lo que NO se hereda es
/// la mecánica infantil: aquí el niño no usa la pantalla, así que no hay nada
/// pensado para captar su atención.
///
/// La escala de espaciado va en múltiplos de 4 y la tipográfica tiene cinco
/// tamaños. Mezclar 11/13/15/18 sueltos es lo que en el proyecto anterior de la casa produjo la
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

  /// Texto atenuado. Era #9AA6A5, que sobre blanco da 2,51:1 y no se leía;
  /// este da 5,53:1 sobre blanco y 5,26:1 sobre el fondo de página.
  static const Color textMuted = Color(0xFF5F6B6A);
  static const Color error = Color(0xFFEF4444);
  static const Color errorBg = Color(0xFFFFF1F2);
  static const Color success = Color(0xFF10B981);
  static const Color successBg = Color(0xFFEAFAF2);

  /// [error] y [success] son para iconos y fondos: como letra sobre blanco se
  /// quedan en 3,76:1 y 2,54:1. Para texto, estos tres, que pasan AA sobre
  /// blanco y sobre los dos fondos claros de los portales: 6,06:1, 5,14:1 y
  /// 4,84:1 en el peor caso. El azul es el de la paleta de los meses.
  static const Color errorInk = Color(0xFFB91C1C);
  static const Color successInk = Color(0xFF047857);
  static const Color info = Color(0xFF2563EB);
  static const Color star = Color(0xFFFACC15);

  /// Aviso: ni error ni éxito. Es el ámbar de la casa, y existe porque las
  /// pantallas nuevas traían cajas de «ojo con esto» pintadas con
  /// `Colors.amber.shade50/900` de Material, que no es de este set (regla 5).
  /// #B45309 sobre #FEF6E7 pasa de sobra el umbral AA de texto normal.
  static const Color warning = Color(0xFFB45309);
  static const Color warningBg = Color(0xFFFEF6E7);
  static const Color dark = Color(0xFF0B1220);

  // ------------------------------------------- asamblea de segundo ciclo
  /// La asamblea de 2.º ciclo NACIÓ con fondo casi negro, y Frank la rechazó:
  /// «el color negro no ayuda». Tenía razón por dos motivos. Uno, el aula de
  /// infantil se da con luz de ventana y una pantalla oscura se lee peor, no
  /// mejor. Dos, y más importante: la app tiene UN lenguaje visual, el del
  /// primer ciclo, y una segunda piel convierte dos partes del mismo producto
  /// en dos productos.
  ///
  /// Los nombres se conservan porque los citan los widgets de `backstage/`;
  /// lo que cambia es que ya NO son oscuros: son la misma paleta clara que
  /// usa la asamblea de primer ciclo.
  static const Color backstageBg = pageBg;
  static const Color backstageSurface = card;
  static const Color backstageSurfaceElevated = primaryLight;
  static const Color backstageBorder = border;
  static const Color backstageTextPrimary = textPrimary;
  static const Color backstageTextSecondary = textSecondary;
  static const Color backstageTextMuted = textMuted;

  /// Turquesa OSCURO, no el de marca: este color se usa como texto sobre
  /// blanco, y el turquesa de marca sobre blanco no llega al contraste
  /// mínimo. Lo vigila `theme_test.dart`.
  static const Color backstageAccent = primaryInk;
  static const Color backstageWarning = Color(0xFFB45309);
  static const double backstageTouchMin = 64.0;

  /// Turquesa para barras y cabeceras CON texto blanco.
  ///
  /// Existe por una medición: el blanco sobre el turquesa de marca da 2,18:1,
  /// que no llega ni al umbral de texto grande (3,0). El proyecto anterior de la casa lo lleva así;
  /// aquí no, porque esto se mira en un aula con ventanales y en un móvil al
  /// sol.
  ///
  /// Empezó en #0B4F4C (9,39:1) y Frank dijo que salía demasiado oscuro. Este
  /// es el tono MÁS CLARO que todavía pasa AA con texto pequeño: 5,16:1. Subir
  /// más ya no pasa —#158C85 se queda en 4,10— así que aquí no hay margen sin
  /// perder legibilidad.
  static const Color primaryInk = Color(0xFF127A75);

  // ------------------------------------------------ acentos de los portales
  /// Cada portal tiene un acento: el de su cabecera, su botón principal, sus
  /// chips elegidos y sus enlaces. Dice en qué parte de la app está una sin
  /// tener que leer nada, y los dos pasan AA con texto blanco encima.
  ///
  /// El turquesa de marca ([primary]) se queda para fondos, ilustración y
  /// detalles: nunca con texto blanco encima, que da 2,18:1.

  /// Familias: el naranja de la casa, oscurecido hasta pasar AA (5,02:1 con
  /// blanco). El de antes, #DD6B20, se quedaba en 3,39:1.
  static const Color familias = Color(0xFFB4530F);

  /// Fondo claro de familias, para chips y avisos. El acento encima da 4,70:1.
  static const Color familiasTint = Color(0xFFFFF6EF);

  /// Docentes: el turquesa oscuro de la barra (5,16:1 con blanco).
  static const Color docentes = primaryInk;

  /// Fondo claro de docentes. El acento encima da 4,74:1.
  static const Color docentesTint = primaryLight;

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

  /// Tema claro de la app: el de las docentes y el de las pantallas comunes.
  /// Los adultos son los únicos que miran esta pantalla, así que el cuerpo de
  /// texto no baja de 16sp.
  static ThemeData get lightTheme => temaDe(docentes, docentesTint);

  /// Tema del Portal Familias y de todo lo que se abre desde él.
  static ThemeData get temaFamilias => temaDe(familias, familiasTint);

  /// Tema del Portal Docentes. Es el de la app: se nombra para que quien abre
  /// el portal diga qué tema quiere y no dependa de cuál sea el de serie.
  static ThemeData get temaDocentes => lightTheme;

  /// El tema de un portal a partir de su [acento] y su fondo claro [tinte].
  ///
  /// Todo lo que lleva el color del portal sale de aquí: la cabecera, el botón
  /// principal, los enlaces, el chip elegido, la pestaña activa. Por eso una
  /// pantalla no escribe colores de botón ni de chip: si lo hace, se sale del
  /// sistema y, casi siempre, del contraste AA. Lo vigila `ux_l2_test.dart`.
  static ThemeData temaDe(Color acento, Color tinte) {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: acento,
      onPrimary: Colors.white,
      primaryContainer: tinte,
      onPrimaryContainer: acento,
      secondary: acento,
      onSecondary: Colors.white,
      secondaryContainer: acento,
      onSecondaryContainer: Colors.white,
      tertiary: star,
      onTertiary: dark,
      error: error,
      onError: Colors.white,
      surface: pageBg,
      onSurface: textPrimary,
      surfaceContainerHighest: tinte,
      onSurfaceVariant: textSecondary,
      outline: border,
    );

    // El chip elegido va relleno del acento y con la letra en blanco; el
    // resto, en blanco con letra oscura. Antes cada pantalla ponía el suyo:
    // turquesa con blanco encima (2,18:1) o turquesa sobre turquesa oscuro.
    final letraDoChip = WidgetStateColor.resolveWith((estados) =>
        estados.contains(WidgetState.selected) ? Colors.white : textPrimary);
    final bordeDoChip = WidgetStateBorderSide.resolveWith((estados) =>
        estados.contains(WidgetState.selected)
            ? BorderSide(color: acento)
            : const BorderSide(color: border));

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
      appBarTheme: AppBarTheme(
        backgroundColor: acento,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        // A la izquierda, como en Android: deja más sitio al título entre la
        // flecha de volver y el selector de lengua.
        centerTitle: false,
        titleSpacing: 4,
        titleTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 20.0,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.1,
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
      // Botón principal: uno por pantalla, relleno del acento.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: acento,
          foregroundColor: Colors.white,
          disabledBackgroundColor: border,
          disabledForegroundColor: textMuted,
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
      // Secundario: con borde, mismo radio, nunca otro relleno.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: acento,
          backgroundColor: card,
          disabledForegroundColor: textMuted,
          side: BorderSide(color: acento.withValues(alpha: 0.45), width: 1.5),
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
          foregroundColor: acento,
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
        backgroundColor: card,
        selectedColor: acento,
        disabledColor: border,
        checkmarkColor: Colors.white,
        side: bordeDoChip,
        labelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14.0,
          fontWeight: FontWeight.w700,
          color: letraDoChip,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusField),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: acento,
        unselectedLabelColor: textSecondary,
        indicatorColor: acento,
        labelStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 15.0,
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 15.0,
          fontWeight: FontWeight.w600,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: acento,
        linearTrackColor: border,
        linearMinHeight: 10,
      ),
      // Las pestañas de abajo de cada portal: Hoxe, Calendario, Explorar,
      // Guías. La elegida, con el acento en el icono, la letra y la píldora;
      // las demás, en gris de texto, que pasa AA sobre blanco.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        indicatorColor: tinte,
        height: 68,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (estados) => IconThemeData(
            size: 24,
            color:
                estados.contains(WidgetState.selected) ? acento : textSecondary,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (estados) => TextStyle(
            fontFamily: fontFamily,
            fontSize: 12.5,
            fontWeight: estados.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w700,
            color:
                estados.contains(WidgetState.selected) ? acento : textSecondary,
          ),
        ),
      ),
    );
  }

  /// Tema escuro de trasteira (Backstage) para a xestión da asemblea polo docente.
  ///
  /// Cero distraccións nin emisión lumínica cara aos nenos. Tipografías amplas (>= 26sp en títulos
  /// e comandos), contraste AAA sobre fondo #0B1220 e botóns táctiles amplos (>= 64dp).
  static ThemeData get backstageDarkTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: backstageAccent,
      onPrimary: backstageBg,
      secondary: primaryLight,
      onSecondary: backstageBg,
      tertiary: backstageWarning,
      onTertiary: backstageBg,
      error: error,
      onError: Colors.white,
      surface: backstageBg,
      onSurface: backstageTextPrimary,
      surfaceContainerHighest: backstageSurface,
      onSurfaceVariant: backstageTextSecondary,
      outline: backstageBorder,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backstageBg,
      canvasColor: backstageBg,
      cardTheme: CardThemeData(
        color: backstageSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: const BorderSide(color: backstageBorder, width: 1.5),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backstageBg,
        foregroundColor: backstageTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 22.0,
          fontWeight: FontWeight.w800,
          color: backstageTextPrimary,
        ),
      ),
    );
  }
}

/// El acento del portal en el que está una pantalla, sacado del tema.
///
/// Una pantalla que se abre desde los dos portales —la formación, una cápsula,
/// el calendario— no puede escribir su color: con `context.acento` sale
/// naranja si se abrió desde Familias y turquesa oscuro desde Docentes.
extension AcentoDoPortal on BuildContext {
  /// Para texto, iconos y bordes: pasa AA sobre blanco y sobre [acentoTint].
  Color get acento => Theme.of(this).colorScheme.primary;

  /// El fondo claro del acento.
  Color get acentoTint => Theme.of(this).colorScheme.primaryContainer;
}
