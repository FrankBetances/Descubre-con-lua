import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';

void main() {
  group('AppTheme tests', () {
    test('Material 3 is enabled and the palette is the inherited one', () {
      final theme = AppTheme.lightTheme;

      expect(theme.useMaterial3, isTrue);

      // Los tokens del tema del proyecto anterior. Si alguien vuelve al azul Vigo por
      // error, esto lo dice. El turquesa de marca sigue siendo el de la casa;
      // lo que cambió en el lote L2 es que ya no es el color de los botones.
      expect(AppTheme.primary, equals(const Color(0xFF00C4BE)));
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
      // grande. Ningún portal usa el turquesa de marca como color primario:
      // cada uno tiene su acento, y el blanco encima pasa AA.
      for (final tema in [AppTheme.temaFamilias, AppTheme.temaDocentes]) {
        expect(tema.colorScheme.primary, isNot(AppTheme.primary));
      }
    });

    double contraste(Color a, Color b) {
      final la = a.computeLuminance(), lb = b.computeLuminance();
      final alto = la > lb ? la : lb, bajo = la > lb ? lb : la;
      return (alto + 0.05) / (bajo + 0.05);
    }

    test('cada portal tiene su acento, y pasa AA (lote L2)', () {
      final portales = {
        AppTheme.familias: AppTheme.temaFamilias,
        AppTheme.docentes: AppTheme.temaDocentes,
      };
      for (final MapEntry(key: acento, value: tema) in portales.entries) {
        // La cabecera y el botón principal, del acento.
        expect(tema.appBarTheme.backgroundColor, acento);
        expect(tema.colorScheme.primary, acento);
        // Blanco sobre el acento: la cabecera, el botón, el chip elegido.
        expect(contraste(Colors.white, acento), greaterThanOrEqualTo(4.5));
        // El acento como letra: sobre blanco, sobre el fondo de la página y
        // sobre su fondo claro.
        for (final fondo in [
          AppTheme.card,
          AppTheme.pageBg,
          tema.colorScheme.primaryContainer,
        ]) {
          expect(contraste(acento, fondo), greaterThanOrEqualTo(4.5),
              reason: '$acento sobre $fondo');
        }
      }
      // El naranja de familias y el turquesa oscuro de docentes.
      expect(AppTheme.familias, const Color(0xFFB4530F));
      expect(AppTheme.docentes, AppTheme.primaryInk);
    });

    test('el texto atenuado se lee (lote L2)', () {
      // Era #9AA6A5: 2,51:1 sobre blanco.
      expect(contraste(AppTheme.textMuted, AppTheme.card),
          greaterThanOrEqualTo(4.5));
      expect(contraste(AppTheme.textMuted, AppTheme.pageBg),
          greaterThanOrEqualTo(4.5));
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
