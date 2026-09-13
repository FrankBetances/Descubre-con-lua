import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/juega/views/unidades_list_screen.dart';

/// El filtro de tramo etario recortaba «Todas las edades» en castellano.
///
/// No lo cazó ningún test de los que había, y no por descuido: un chip
/// RECORTA, no desborda. No hay franjas amarillas, no se lanza ninguna
/// excepción y `pumpAndSettle` termina tan contento. El texto simplemente sale
/// cortado, y en release nadie se entera. Se vio en una captura del manual.
///
/// Por eso aquí no se busca una excepción: se compara el ancho que el chip le
/// da al texto con el que ese texto mide de verdad.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ContentRepository repo;

  setUpAll(() async {
    repo = ContentRepository();
    await repo.initialize();
  });

  /// Lo que mide la cadena sin que nadie la apriete.
  double anchoReal(String texto, TextStyle estilo, double escala) {
    final painter = TextPainter(
      text: TextSpan(text: texto, style: estilo),
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.linear(escala),
    )..layout();
    return painter.width;
  }

  for (final lang in AppLanguage.deInterfaz) {
    for (final escala in [1.0, 1.3]) {
      testWidgets(
          'ninguna etiqueta del filtro se recorta en ${lang.code} '
          'a escala $escala', (tester) async {
        // 360 dp: más estrecho que el Pixel 6, que es lo que hay en muchas
        // aulas. El defecto aparecía justo aquí.
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.lightTheme,
          // copyWith, NO un MediaQueryData nuevo: uno nuevo trae `size` a
          // cero y la pantalla se dispone contra una pantalla inexistente.
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(escala)),
              child: UnidadesListScreen(
                repository: repo,
                initialLanguage: lang,
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        final esGl = lang == AppLanguage.gl;
        final etiquetas = [
          esGl ? 'Todas as idades' : 'Todas las edades',
          esGl ? '0-2 anos' : '0-2 años',
          esGl ? '2-3 anos' : '2-3 años',
        ];

        for (final etiqueta in etiquetas) {
          final finder = find.text(etiqueta);
          expect(finder, findsOneWidget, reason: 'Falta «$etiqueta».');

          final widget = tester.widget<Text>(finder);
          final pintado = tester.getSize(finder).width;
          final real = anchoReal(etiqueta, widget.style!, escala);

          // Medio punto de margen por el redondeo del layout.
          expect(pintado, greaterThanOrEqualTo(real - 0.5),
              reason: '«$etiqueta» sale en ${pintado.toStringAsFixed(1)} dp '
                  'cuando necesita ${real.toStringAsFixed(1)}. Está '
                  'recortada, y en release eso no avisa: el texto se corta y '
                  'ya.');
        }
      });
    }
  }

  testWidgets('los tres filtros siguen respondiendo', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: UnidadesListScreen(
        repository: repo,
        initialLanguage: AppLanguage.es,
      ),
    ));
    await tester.pumpAndSettle();

    // Rehacer la fila con Wrap no puede haber roto lo que hacían los chips.
    for (final etiqueta in ['0-2 años', '2-3 años', 'Todas las edades']) {
      await tester.tap(find.text(etiqueta));
      await tester.pumpAndSettle();
      final chip = tester.widget<FilterChip>(
        find.ancestor(
          of: find.text(etiqueta),
          matching: find.byType(FilterChip),
        ),
      );
      expect(chip.selected, isTrue, reason: 'Tocar «$etiqueta» no lo marca.');
    }
  });
}
