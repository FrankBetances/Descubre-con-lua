import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/features/bienvenida/welcome_screen.dart';
import 'package:descubre_con_lua/features/creditos/credits_screen.dart';

/// Envuelve una pantalla con el tema real. Probarlas con el tema por defecto de
/// Material no diría nada: la mitad de lo que se comprueba aquí son decisiones
/// del tema.
Widget _wrap(Widget child) =>
    MaterialApp(theme: AppTheme.lightTheme, home: child);

void main() {
  group('Pantalla de bienvenida', () {
    testWidgets('dice qué es cada módulo, en las dos lenguas', (tester) async {
      for (final lang in AppLanguage.values) {
        await tester.pumpWidget(_wrap(WelcomeScreen(
          currentLanguage: lang,
          onToggleLanguage: () {},
          onStart: () {},
          onShowCredits: () {},
        )));
        await tester.pumpAndSettle();

        expect(find.text('Descubre con Lúa'), findsOneWidget);
        expect(find.text('Edición Vigo'), findsOneWidget);

        // El cuerpo nombra los dos módulos: quien abre esto por primera vez
        // tiene que saber cuál es el suyo sin entrar a probar.
        final body = tester
            .widgetList<Text>(find.byType(Text))
            .map((t) => t.data ?? '')
            .join(' ');
        expect(body, contains('Lúa'));
        expect(body, contains('Academy'));
      }
    });

    testWidgets('el botón de empezar llama a su acción', (tester) async {
      var started = 0;
      await tester.pumpWidget(_wrap(WelcomeScreen(
        currentLanguage: AppLanguage.gl,
        onToggleLanguage: () {},
        onStart: () => started++,
        onShowCredits: () {},
      )));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Comezar'));
      await tester.pump();
      expect(started, 1);
    });

    testWidgets('el conmutador de lengua está y responde', (tester) async {
      var toggles = 0;
      await tester.pumpWidget(_wrap(WelcomeScreen(
        currentLanguage: AppLanguage.gl,
        onToggleLanguage: () => toggles++,
        onStart: () {},
        onShowCredits: () {},
      )));
      await tester.pumpAndSettle();

      await tester.tap(find.text('GL'));
      await tester.pump();
      expect(toggles, 1);
    });

    testWidgets('cabe con la escala de texto grande del sistema',
        (tester) async {
      // El defecto típico de esta app: una cadena galega más larga con el texto
      // grande del sistema. En release un desborde no se ve, el texto se corta.
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.8)),
          child: WelcomeScreen(
            currentLanguage: AppLanguage.gl,
            onToggleLanguage: () {},
            onStart: () {},
            onShowCredits: () {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('Créditos', () {
    Future<String> textOf(WidgetTester tester, AppLanguage lang) async {
      await tester.pumpWidget(_wrap(CreditsScreen(currentLanguage: lang)));
      await tester.pumpAndSettle();
      return tester
          .widgetList<Widget>(find.byType(Text))
          .whereType<Text>()
          .map((t) => t.data ?? '')
          .join(' ');
    }

    testWidgets('acredita la autoría y la empresa', (tester) async {
      final body = await textOf(tester, AppLanguage.gl);
      expect(body, contains('Frank Alberto Betances Reinoso'));
      expect(body, contains('Earlify Health S.L.'));
    });

    testWidgets('acredita las voces y la tipografía, que llevan licencia',
        (tester) async {
      final body = await textOf(tester, AppLanguage.es);
      // Citar estas tres no es cortesía: las dos voces y la fuente tienen
      // licencia, y la app las redistribuye dentro del paquete.
      expect(body, contains('Celtia'));
      expect(body, contains('Sharvard'));
      expect(body, contains('Nunito'));
      expect(body, contains('SIL Open Font License'));
    });

    testWidgets('lleva el correo de contacto del proyecto', (tester) async {
      await tester.pumpWidget(
        _wrap(const CreditsScreen(currentLanguage: AppLanguage.gl)),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('frank.alberto.betances.reinoso@gmail.com'),
        findsOneWidget,
      );
    });

    testWidgets('no acredita ninguna colaboración inventada', (tester) async {
      // De esta edición no consta ninguna entidad colaboradora en el
      // repositorio. Poner un nombre institucional aquí es atribuirse un
      // respaldo que nadie ha dado, así que si alguien añade uno, que sea
      // rompiendo este test a conciencia y no de pasada.
      final body = await textOf(tester, AppLanguage.gl);
      for (final claimed in [
        'Concello',
        'Xunta',
        'Acopros',
        'Quisqueya',
        'Universidade',
        'Hospital',
      ]) {
        expect(body.contains(claimed), isFalse,
            reason: '«$claimed» aparece en los créditos sin constar en el '
                'repositorio que colabore.');
      }
    });
  });
}
