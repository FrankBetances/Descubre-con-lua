import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';

void main() {
  group('AppTheme tests', () {
    test('Material 3 is enabled and the palette is Valeria+\'s', () {
      final theme = AppTheme.lightTheme;

      expect(theme.useMaterial3, isTrue);

      // Los tokens de src/valeriaTheme.ts. Si alguien vuelve al azul Vigo por
      // error, esto lo dice.
      expect(theme.colorScheme.primary, equals(const Color(0xFF00C4BE)));
      expect(theme.scaffoldBackgroundColor, equals(const Color(0xFFF6FAFA)));
      expect(theme.colorScheme.surface, equals(const Color(0xFFF6FAFA)));
    });

    test('Nunito is the family, and it ships inside the app', () {
      // La fuente va empaquetada: el APK no tiene permiso de INTERNET y no
      // puede descargarla en tiempo de ejecución.
      expect(AppTheme.fontFamily, equals('Nunito'));
      // ThemeData propaga la familia al textTheme: comprobarlo ahí es
      // comprobar lo que de verdad pinta el cuerpo de texto.
      expect(
        AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily,
        equals('Nunito'),
      );
    });

    test('white is never put on the brand turquoise', () {
      // Blanco sobre #00C4BE da 2,18:1, por debajo incluso del umbral de texto
      // grande. La barra usa `primaryInk` y el botón primario, tinta oscura.
      expect(AppTheme.lightTheme.colorScheme.onPrimary, equals(AppTheme.dark));
      expect(AppTheme.lightTheme.appBarTheme.backgroundColor,
          equals(AppTheme.primaryInk));
    });

    test(
        'Typography enforces high legibility for adult educators (body >= 16sp)',
        () {
      final theme = AppTheme.lightTheme;
      final textTheme = theme.textTheme;

      expect(textTheme.bodyLarge?.fontSize, greaterThanOrEqualTo(16.0));
      expect(textTheme.bodyMedium?.fontSize, greaterThanOrEqualTo(16.0));

      expect(textTheme.titleLarge?.fontSize, greaterThanOrEqualTo(20.0));
      expect(textTheme.headlineMedium?.fontSize, greaterThanOrEqualTo(22.0));
    });
  });
}
