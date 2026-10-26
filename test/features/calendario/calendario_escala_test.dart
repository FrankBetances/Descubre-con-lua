import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/storage/calendario_store.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/loaders/content_asset_loader.dart';
import 'package:descubre_con_lua/data/repositories/calendario_repository.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/academy/views/guia_atencion_screen.dart';
import 'package:descubre_con_lua/features/calendario/views/calendario_fogar_screen.dart';
import 'package:descubre_con_lua/features/calendario/views/calendario_screen.dart';

/// Que el calendario y la guía quepan, en las dos lenguas y con el texto grande
/// del sistema.
///
/// Esto existe por un defecto real, no por completar la cuadrícula: la tarjeta
/// del carrusel se salía 47 px por abajo y 41 por la derecha, y el conmutador
/// de rol 5 px. En depuración eso pinta las franjas amarillas y negras; **en
/// release no se ve nada: el texto se corta y ya**. El gallego es más largo que
/// el castellano, así que una pantalla correcta en una lengua puede romperse en
/// la otra, y con la escala de texto grande se rompen las dos.
///
/// Lo que un widget test NO demuestra: las fuentes reales, los recortes de la
/// pantalla (muesca, barra de gestos), las densidades reales y que el audio
/// suene. Para eso hace falta un aparato.
void main() {
  late CalendarioContenido contenido;
  late ContentRepository repositorio;
  late Directory dir;
  late CalendarioStore store;

  setUpAll(() async {
    contenido = await CalendarioContenido.cargar(
      stringLoader: (path) => File(path).readAsString(),
    );
    // Con el banco y el registro leídos, el mes pinta su núcleo (M3.9): sin
    // ellos el bloque sale vacío y aquí no se mediría.
    repositorio = ContentRepository(
      loader: ContentAssetLoader(
        stringLoader: (path) => File(path).readAsString(),
      ),
    );
    await repositorio.loadProgramaTpr();
    await repositorio.loadRexistroFrases();
    // El día de casa (DiaNoFogar) lee el banco de días: aquí, con E/S real.
    await repositorio.loadCalendarioDias(cursoId: '');
    // El calendario de casa lee su contenido del paquete por su cuenta. Se
    // lee aquí la primera vez, con reloj de verdad: dentro de `testWidgets`
    // esa lectura no termina y la pantalla se queda en el indicador de carga.
    TestWidgetsFlutterBinding.ensureInitialized();
    await CalendarioContenido.cargar();
  });

  // El contenido y el almacén se leen AQUÍ, no dentro de `testWidgets`: ahí
  // dentro el reloj es falso y una lectura de disco de verdad no termina
  // nunca. Cargarlo dentro colgaba el proceso entero, sin mensaje de error.
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('cal_escala_');
    store = CalendarioStore(overrideDirectory: dir.path);
    await store.cargar();
  });

  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
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
      testWidgets(
          'o calendario cabe en ${lang.code} a escala $escala, nos dous roles',
          (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.lightTheme,
          // `copyWith` sobre el MediaQuery real, no un MediaQueryData nuevo:
          // uno nuevo trae tamaño 0x0 y la pantalla se dispone contra una
          // ventana inexistente.
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(escala)),
            child: child!,
          ),
          home: CalendarioScreen(
            store: store,
            contenido: contenido,
            initialLanguage: lang,
            esDocenteInicial: true,
          ),
        ));
        await tester.pumpAndSettle();

        expect(erroresDe(tester), isEmpty,
            reason: 'El calendario desborda en modo aula, '
                '${lang.code}, escala $escala.');

        // El rol de familia enseña otros bloques: se comprueban los dos.
        await tester.tap(find.byKey(const Key('tab_rol_familia')));
        await tester.pumpAndSettle();

        expect(erroresDe(tester), isEmpty,
            reason: 'El calendario desborda en modo fogar, '
                '${lang.code}, escala $escala.');
      });

      // 0-2 trae canción y objeto; 5-6, fórmulas, descritivas e estrutura,
      // que é o bloque máis longo.
      for (final curso in ['curso_0_2', 'curso_5_6']) {
        testWidgets(
            'o núcleo do mes cabe en ${lang.code} a escala $escala, $curso, '
            'nos dous calendarios', (tester) async {
          tester.view.physicalSize = const Size(360, 640);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          Widget envolver(Widget pantalla) => MaterialApp(
                theme: AppTheme.lightTheme,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(escala)),
                  child: child!,
                ),
                home: pantalla,
              );

          await tester.pumpWidget(envolver(CalendarioScreen(
            store: store,
            contenido: contenido,
            repository: repositorio,
            initialLanguage: lang,
            esDocenteInicial: true,
            cursoInicial: curso,
          )));
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('nucleo_do_mes')), findsOneWidget);
          // F4: desde 2-3 o mes trae o seu contraste de son.
          expect(find.byKey(const Key('contraste_do_mes'), skipOffstage: false),
              curso == 'curso_0_2' ? findsNothing : findsOneWidget);
          expect(erroresDe(tester), isEmpty,
              reason: 'O núcleo desborda no aula, $curso, ${lang.code}, '
                  'escala $escala.');

          await tester.tap(find.byKey(const Key('tab_rol_familia')));
          await tester.pumpAndSettle();
          expect(erroresDe(tester), isEmpty,
              reason: 'O núcleo desborda no lado da familia, $curso, '
                  '${lang.code}, escala $escala.');

          await tester.pumpWidget(envolver(CalendarioFogarScreen(
            repository: repositorio,
            store: store,
            initialLanguage: lang,
            initialCursoId: curso,
            agora: DateTime(2026, 10, 19),
          )));
          // La pantalla pide su contenido al paquete en initState; ese futuro
          // necesita reloj de verdad para resolverse.
          await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 200)));
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('nucleo_do_mes')), findsOneWidget);
          expect(erroresDe(tester), isEmpty,
              reason: 'O núcleo desborda no calendario da casa, $curso, '
                  '${lang.code}, escala $escala.');
        });
      }

      testWidgets(
          'a guía de inglés cabe en ${lang.code} a escala $escala, en todos os tramos',
          (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.lightTheme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(escala)),
            child: child!,
          ),
          home: GuiaAtencionScreen(
            contenido: contenido,
            initialLanguage: lang,
          ),
        ));
        await tester.pumpAndSettle();

        // Cada tramo tiene textos de largo distinto: el que desborda puede ser
        // cualquiera, no solo el primero.
        for (final tramo in contenido.guia.tramos) {
          // Por el widget, no por el texto suelto: el tramo elegido enseña su
          // rango también en la cabecera de la ficha, y tocar ahí no hace nada.
          final chip = find.widgetWithText(
            ChoiceChip,
            tramo.rangoEdad.resolve(lang),
          );
          await tester.ensureVisible(chip);
          await tester.pumpAndSettle();
          await tester.tap(chip, warnIfMissed: false);
          await tester.pumpAndSettle();

          // Que el tramo haya cambiado de verdad: si la pastilla quedara
          // tapada, el toque no haría nada y el test estaría mirando siempre
          // el mismo tramo sin enterarse.
          // findRichText y textContaining: el momento doméstico se pinta
          // dentro de un RichText junto a su rótulo en negrita, así que ni un
          // buscador de Text normal entra ahí ni el texto casa exacto.
          expect(
            find.textContaining(tramo.momentoDomestico.resolve(lang),
                findRichText: true),
            findsWidgets,
            reason: 'El toque no abrió el tramo ${tramo.id}.',
          );

          expect(erroresDe(tester), isEmpty,
              reason: 'El tramo ${tramo.id} desborda en ${lang.code}, '
                  'escala $escala.');
        }
      });
    }
  }
}
