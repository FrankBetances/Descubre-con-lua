import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/features/calendario/widgets/asemblea_do_dia.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/data/models/tpr_curriculum_scheduler.dart';
import 'package:descubre_con_lua/data/models/asamblea_segundo_ciclo_model.dart';
import 'package:descubre_con_lua/data/loaders/content_asset_loader.dart';

import 'package:descubre_con_lua/core/brand/lua_pixel.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/localization/localized_string.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/models/capsula_model.dart';
import 'package:descubre_con_lua/data/models/curricular_model.dart';
import 'package:descubre_con_lua/data/models/revision_model.dart';
import 'package:descubre_con_lua/features/academy/views/capsula_detail_screen.dart';
import 'package:descubre_con_lua/features/juega/views/nota_para_casas_screen.dart';

/// Dónde aparece la gata dentro de una ACTIVIDAD, y dónde no.
///
/// Antes de esto, Lúa se pintaba en la bienvenida, en los premios, en el
/// calendario y en los créditos: los cuatro sitios, fuera de lo que la docente
/// y la familia están haciendo. Aquí se fija que entra en los dos sitios
/// elegidos —el cierre de la cápsula y la nota que cruza a las casas— y que no
/// se cuela donde el contenido no la pide.
void main() {
  const cierre = LocalizedString(
    gl: 'Hoxe quédate cun só xesto.',
    es: 'Hoy quédate con un solo gesto.',
  );
  // P4: Lúa solo habla inglés; la idea para hoy la dice la app.
  const luaEn = 'Look! A ball!';

  Capsula capsula({LocalizedString? luaDice}) => Capsula(
        id: 'test.capsula.01',
        bloqueId: 'desarrollo_comunicativo',
        orden: 1,
        titulo: const LocalizedString(gl: 'Título', es: 'Título'),
        subtitulo: const LocalizedString(gl: 'Subtítulo', es: 'Subtítulo'),
        tiempoLecturaMinutos: 3,
        icono: 'ear_sparkles',
        ideaClave: const LocalizedString(gl: 'Idea.', es: 'Idea.'),
        porQueImporta: const LocalizedString(gl: 'Porque.', es: 'Porque.'),
        queHacerEnCasa: const LocalizedString(gl: 'Nomea.', es: 'Nombra.'),
        ejemploCotidiano: const LocalizedString(gl: 'Mira.', es: 'Mira.'),
        luaDice: luaDice,
        luaEn: luaDice == null ? null : luaEn,
        afirmaciones: const [
          Afirmacion(
            id: 'a1',
            enunciado:
                LocalizedString(gl: 'Agardar axuda.', es: 'Esperar ayuda.'),
            esVerdadera: true,
            explicacion: LocalizedString(gl: 'Exacto.', es: 'Exacto.'),
          ),
        ],
        curriculo: const CurricularReference(
          normativa: 'Decreto 150/2022',
          etapa: 'educacion_infantil',
          ciclo: 'primeiro_ciclo_0_3',
          areas: ['area_1_crecemento_harmonia'],
          criteriosEvaluacion: ['CA1.1'],
        ),
        revision: const Revision(
          autor: 'Equipo Pedagóxico',
          revisorPedagogico: 'Revisor',
          fechaRevision: '2026-09-14',
          version: '1.0.0',
          aprobadoParaAula: true,
        ),
      );

  Future<void> montarLector(WidgetTester tester, Capsula c, AppLanguage lang) =>
      tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: CapsulaDetailScreen(capsula: c, initialLanguage: lang),
      ));

  group('el cierre de Lúa en el lector de cápsulas', () {
    testWidgets('va el ÚLTIMO, detrás de la reflexión', (tester) async {
      await montarLector(tester, capsula(luaDice: cierre), AppLanguage.gl);
      await tester.pumpAndSettle();

      // Las cuatro secciones: la gata no está en ninguna.
      for (var i = 0; i < 4; i++) {
        expect(find.byType(LuaPixel), findsNothing,
            reason: 'Lúa no pinta en la sección $i.');
        await tester.tap(find.text('Seguinte'));
        await tester.pumpAndSettle();
      }

      // La reflexión. La cápsula se cuenta como leída al responderla, así que
      // el cierre tiene que ir DESPUÉS: al revés, la gata despediría una
      // cápsula todavía sin terminar.
      expect(find.text('PARA PENSAR'), findsOneWidget);
      expect(find.byType(LuaPixel), findsNothing);
      await tester.tap(find.text('Verdadeiro'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Seguinte'));
      await tester.pumpAndSettle();

      expect(find.text('LÚA DI'), findsOneWidget);
      expect(find.byType(LuaPixel), findsOneWidget);
      expect(find.text(cierre.gl), findsOneWidget);
      expect(find.text(luaEn), findsOneWidget);
      expect(find.text('PARA HOXE'), findsOneWidget);
      // Es la última: el botón ya no invita a seguir.
      expect(find.text('Rematar'), findsOneWidget);
    });

    testWidgets('el cierre habla en la lengua elegida', (tester) async {
      await montarLector(tester, capsula(luaDice: cierre), AppLanguage.es);
      await tester.pumpAndSettle();

      for (var i = 0; i < 4; i++) {
        await tester.tap(find.text('Siguiente'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Verdadero'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();

      expect(find.text('LÚA DICE'), findsOneWidget);
      expect(find.text(cierre.es), findsOneWidget);
      // La frase de Lúa no se traduce: es la misma en las dos lenguas.
      expect(find.text(luaEn), findsOneWidget);
    });

    testWidgets('sin luaDice no se inventa una página', (tester) async {
      // Las cápsulas del aula todavía no traen cierre. Una página vacía con la
      // gata y sin nada que decir sería peor que no tener página.
      await montarLector(tester, capsula(), AppLanguage.gl);
      await tester.pumpAndSettle();

      for (var i = 0; i < 4; i++) {
        expect(find.text('Rematar'), findsNothing);
        await tester.tap(find.text('Seguinte'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Verdadeiro'));
      await tester.pumpAndSettle();

      // La reflexión es ya la última: no hay nada detrás.
      expect(find.text('Rematar'), findsOneWidget);
      expect(find.byType(LuaPixel), findsNothing);
      expect(find.text('LÚA DI'), findsNothing);
    });
  });

  group('la nota que cruza a las casas', () {
    // Desde M4.3 cierra la asamblea de cuatro fases y sale de la unidad del
    // mes: centro, núcleo y, en 2.º ciclo, la micro-rutina de casa. Se lee del
    // árbol de trabajo; quien comprueba que el contenido VIAJA en el APK es
    // `test/data/bundle_real_test.dart`.
    late ContentRepository repo;
    late AsembleaDaUnidade da02;
    late AsembleaDaUnidade da56;
    late AsambleaSegundoCiclo asemblea6;

    setUpAll(() async {
      Future<String> ler(String p) => File(p).readAsString();
      repo = ContentRepository(loader: ContentAssetLoader(stringLoader: ler));
      repo.addProgramaTpr(await ProgramaTpr.cargar(stringLoader: ler));
      da02 =
          (await lerAsembleaDaUnidade(repo, 'curso_0_2', 10, AppLanguage.gl))!;
      da56 =
          (await lerAsembleaDaUnidade(repo, 'curso_5_6', 10, AppLanguage.gl))!;
      asemblea6 = AsambleaSegundoCiclo.fromJson(jsonDecode(File(
              'assets/content/asambleas_segundo_ciclo/asamblea.segundo_ciclo.outubro.6_infantil.json')
          .readAsStringSync()) as Map<String, dynamic>);
    });

    Future<void> pintar(WidgetTester tester, Widget nota,
        {double escala = 1.0}) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(escala)),
          child: child!,
        ),
        home: nota,
      ));
      await tester.pumpAndSettle();
    }

    for (final lang in AppLanguage.deInterfaz) {
      testWidgets('Lúa encabeza la nota en ${lang.code}', (tester) async {
        await pintar(
            tester,
            NotaParaCasasScreen(
              centroInteres: da02.centroInteres,
              nucleo: da02.nucleo,
              language: lang,
            ));
        expect(find.byType(LuaPixel), findsOneWidget,
            reason: 'La nota nombra a la gata y tiene que enseñarla.');
        expect(find.text(NotaParaCasasScreen.titulo.resolve(lang)),
            findsOneWidget);
        // Lo que se hizo hoy es el centro del mes, el de la asamblea.
        expect(find.text(da02.centroInteres.resolve(lang)), findsOneWidget);
        // El núcleo del mes, cada pieza con su voz.
        for (final p in da02.nucleo) {
          expect(find.text(p.en), findsOneWidget, reason: p.en);
        }
        // En 1.º ciclo no hay micro-rutina de casa.
        expect(
            find.text(lang == AppLanguage.gl
                ? 'PARA FACER NA CASA, 3 MINUTOS'
                : 'PARA HACER EN CASA, 3 MINUTOS'),
            findsNothing);
      });

      for (final escala in [1.0, 1.8]) {
        testWidgets(
            'en 2.º ciclo leva a micro-rutina da súa asemblea e cabe, '
            '${lang.code} a escala $escala', (tester) async {
          await pintar(
              tester,
              NotaParaCasasScreen(
                centroInteres: da56.centroInteres,
                nucleo: da56.nucleo,
                microRutina: asemblea6.microRutinaHogar,
                language: lang,
              ),
              escala: escala);
          expect(tester.takeException(), isNull);
          final scroll = find.byType(Scrollable);
          final rutina = find
              .text(asemblea6.microRutinaHogar.escenaCotidiana.resolve(lang));
          if (scroll.evaluate().isNotEmpty) {
            await tester.scrollUntilVisible(rutina, 200,
                scrollable: scroll.first);
          }
          expect(rutina, findsOneWidget);
          expect(find.text(asemblea6.microRutinaHogar.titulo.resolve(lang)),
              findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}
