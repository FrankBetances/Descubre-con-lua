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

/// Vacía TODAS las excepciones pendientes, no solo la primera.
///
/// `takeException()` saca una sola. Un desborde de disposición lanza una por
/// fotograma, así que con una sola llamada el test falla y las demás se filtran
/// al test SIGUIENTE, que revienta sin tener ninguna culpa. Pasó exactamente
/// eso: un desborde en la bienvenida tumbó también el primer test de créditos,
/// y el informe de CI señalaba dos fallos donde había un solo defecto.
List<Object> _drainExceptions(WidgetTester tester) {
  final errores = <Object>[];
  while (true) {
    final e = tester.takeException();
    if (e == null) break;
    errores.add(e);
  }
  return errores;
}

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

      expect(_drainExceptions(tester), isEmpty,
          reason: 'La bienvenida desborda con la escala de texto grande.');
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

    testWidgets('acredita a los dos colaboradores que constan', (tester) async {
      for (final lang in AppLanguage.values) {
        final body = await textOf(tester, lang);
        expect(body, contains('startTIC'));
        expect(body, contains('Zona Franca de Vigo'));
        // El nombre oficial, no una abreviatura.
        expect(body, contains('Incubadora de Alta Tecnolo'));
        expect(
          body,
          contains(lang == AppLanguage.gl
              ? 'Concello de Vigo'
              : 'Ayuntamiento de Vigo'),
        );
      }
    });

    testWidgets('cabe con la escala de texto grande del sistema',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(1.8)),
          child: CreditsScreen(currentLanguage: AppLanguage.gl),
        ),
      ));
      await tester.pumpAndSettle();

      expect(_drainExceptions(tester), isEmpty,
          reason: 'Los créditos desbordan con la escala de texto grande.');
    });

    testWidgets('y no acredita a nadie más', (tester) async {
      // Lista BLANCA, no negra. Una lista negra solo caza los nombres que a
      // alguien se le ocurrió prohibir; esto caza cualquier institución nueva
      // que aparezca, que es el riesgo real: atribuirse un respaldo que esa
      // institución no ha dado. Si hay que sumar a alguien, se suma AQUÍ
      // primero, a conciencia.
      const permitidas = {
        'startTIC',
        // Nombres oficiales confirmados por Frank el 12/9/2026. La incubadora
        // es un programa del Consorcio, no una entidad aparte.
        'Incubadora de Alta Tecnoloxía startTIC',
        'Incubadora de Alta Tecnología startTIC',
        'Consorcio da Zona Franca de Vigo',
        'Consorcio de la Zona Franca de Vigo',
        'Zona Franca de Vigo',
        'Concello de Vigo',
        'Ayuntamiento de Vigo',
        'Earlify Health S.L.',
        'Proxecto Nós',
      };
      // Patrón de nombre institucional: dos mayúsculas iniciales seguidas, o
      // una palabra clave de organismo.
      final sospechoso = RegExp(
        r'\b(Concello|Ayuntamiento|Consorcio|Xunta|Universidade|Universidad|'
        r'Hospital|Fundación|Fundacion|Deputación|Diputación|Instituto|'
        r'Ministerio|Conselleria|Consellería)\b[^.·\n]{0,40}',
      );
      for (final lang in AppLanguage.values) {
        final body = await textOf(tester, lang);
        for (final m in sospechoso.allMatches(body)) {
          final hallado = m.group(0)!.trim();
          final permitido = permitidas
              .any((p) => hallado.startsWith(p) || p.contains(hallado));
          expect(permitido, isTrue,
              reason: '«$hallado» aparece en los créditos y no está en la '
                  'lista de entidades que constan como colaboradoras.');
        }
      }
    });
  });
}
