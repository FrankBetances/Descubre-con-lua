import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/storage/calendario_store.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/loaders/content_asset_loader.dart';
import 'package:descubre_con_lua/data/models/unidad_model.dart';
import 'package:descubre_con_lua/features/juega/views/asamblea_guiada_screen.dart';

/// Que las seis fases de la asamblea quepan, en las DIEZ unidades, en las dos
/// lenguas y con el texto grande del sistema.
///
/// Existe por dos motivos concretos, no por completar la cuadrícula:
///
///  1. Las unidades pasaron de una a diez de golpe. Una cadena gallega más
///     larga en cualquiera de las nueve nuevas rompe una fila que llevaba
///     años cabiendo, y nadie lo miraría unidad por unidad.
///  2. La fase del cuento estrena la tarjeta del vocabulario, que pone la
///     palabra galega y la inglesa en la misma línea: «Mexillón» y «Mussel»
///     juntas en 360 dp con escala 1,8 es exactamente el caso que revienta.
///
/// En depuración un desborde pinta las franjas amarillas y negras. **En
/// release no se ve nada: el texto se corta y ya.** Por eso esto es un test y
/// no una mirada.
///
/// Lo que un widget test NO demuestra: fuentes reales, muesca, barra de
/// gestos, densidades reales y que el audio suene. Para eso hace falta un
/// aparato.
void main() {
  late List<Unidad> unidades;

  setUpAll(() async {
    // Del disco, en setUpAll: dentro de `testWidgets` el reloj es falso y una
    // lectura de verdad no termina nunca.
    final loader = ContentAssetLoader(
      stringLoader: (path) => File(path).readAsString(),
    );
    final paths = Directory('assets/content/unidades')
        .listSync()
        .whereType<File>()
        .map((f) => f.path)
        .where((p) => p.endsWith('.json'))
        .toList()
      ..sort();
    unidades = [
      for (final path in paths) await loader.loadUnidadFromAsset(path),
    ];
    expect(unidades, hasLength(10),
        reason: 'el curso son diez meses: faltan unidades');
  });

  List<Object> erroresDe(WidgetTester tester) {
    final errores = <Object>[];
    while (true) {
      final e = tester.takeException();
      if (e == null) break;
      errores.add(e);
    }
    return errores;
  }

  for (final lang in AppLanguage.deInterfaz) {
    for (final escala in [1.0, 1.8]) {
      testWidgets('as seis fases caben en ${lang.code} a escala $escala',
          (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        for (final unidad in unidades) {
          await tester.pumpWidget(MaterialApp(
            theme: AppTheme.lightTheme,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(escala)),
              child: child!,
            ),
            home: AsambleaGuiadaScreen(
              unidad: unidad,
              calendario: CalendarioStore(overrideDirectory: null),
              initialLanguage: lang,
            ),
          ));
          await tester.pumpAndSettle();

          expect(erroresDe(tester), isEmpty,
              reason: '${unidad.id} desborda na fase 1 '
                  '(${lang.code}, escala $escala)');

          // La ficha completa trae el doble de texto: consejos, materiales,
          // objetivos. Si solo se comprueba el modo asamblea, la mitad de la
          // pantalla se queda sin mirar.
          final abrirFicha = find.byKey(const Key('boton_ficha_completa'));
          if (abrirFicha.evaluate().isNotEmpty) {
            await tester.ensureVisible(abrirFicha);
            await tester.pumpAndSettle();
            await tester.tap(abrirFicha, warnIfMissed: false);
            await tester.pumpAndSettle();
            expect(erroresDe(tester), isEmpty,
                reason: '${unidad.id} desborda na ficha completa da fase 1 '
                    '(${lang.code}, escala $escala)');
          }

          // El interruptor queda ABIERTO desde la fase 1, así que las cinco
          // siguientes se comprueban con la ficha completa, que es el caso con
          // más texto. El modo asamblea enseña un subconjunto: si cabe el
          // superconjunto, cabe él.
          //
          // Las seis fases, una a una: la que desborda puede ser cualquiera.
          for (var fase = 1; fase < 6; fase++) {
            final seguinte = find.byKey(const Key('boton_seguinte_fase'));
            if (seguinte.evaluate().isEmpty) break;
            await tester.ensureVisible(seguinte);
            await tester.pumpAndSettle();
            await tester.tap(seguinte, warnIfMissed: false);
            await tester.pumpAndSettle();

            expect(erroresDe(tester), isEmpty,
                reason: '${unidad.id} desborda na fase ${fase + 1} '
                    '(${lang.code}, escala $escala)');
          }
        }
      });
    }
  }
}
