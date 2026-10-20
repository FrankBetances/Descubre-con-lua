import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/storage/calendario_store.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/loaders/content_asset_loader.dart';
import 'package:descubre_con_lua/data/models/tpr_curriculum_scheduler.dart';
import 'package:descubre_con_lua/data/repositories/calendario_repository.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/docentes/views/hoxe_docentes_screen.dart';
import 'package:descubre_con_lua/features/familias/views/hoxe_familias_screen.dart';

/// M3.10 (D1): en Hoy, el núcleo del mes va delante y las cinco del día
/// quedan plegadas debajo. Y el criterio de M3.9: el mismo día, el MISMO
/// núcleo en el calendario y en los dos Hoy.
///
/// Lo que esto no demuestra: las fuentes reales, la escala de texto de un
/// aparato y que el audio suene.
void main() {
  late ContentRepository repo;
  late CalendarioContenido calendario;
  late Directory dir;
  late CalendarioStore store;

  // Un lunes de la semana 3 de octubre: el día que se ve en las capturas.
  final lunes = DateTime(2026, 10, 19);
  const cursos = ['curso_0_2', 'curso_5_6'];

  setUpAll(() async {
    Future<String> ler(String p) => File(p).readAsString();
    final loader = ContentAssetLoader(stringLoader: ler);
    repo = ContentRepository(loader: loader);
    List<String> jsons(String d) => Directory(d)
        .listSync()
        .whereType<File>()
        .map((f) => f.path)
        .where((p) => p.endsWith('.json'))
        .toList()
      ..sort();
    await repo.initialize(
      capsulaPaths: const [],
      asambleaSegundoCicloPaths:
          jsons('assets/content/asambleas_segundo_ciclo'),
    );
    for (final p in jsons('assets/content/asambleas_primeiro_ciclo')) {
      repo.addAsambleaPrimeiroCiclo(await loader.loadAsambleaPrimeiroCiclo(p));
    }
    for (final p in jsons('assets/content/progresion')) {
      repo.addProgresion(await loader.loadProgresion(p));
    }
    repo.addProgramaTpr(await ProgramaTpr.cargar(stringLoader: ler));
    await repo.loadRexistroFrases();
    // Dentro de `testWidgets` el reloj es falso y una lectura de disco no
    // termina: todo lo que las pantallas piden se lee aquí.
    await repo.loadCalendarioDias(cursoId: '');
    for (final c in cursos) {
      await repo.loadUnidadeDoMes(c, 10);
      await repo.loadCuentos(cursoId: c, mesNumero: 2);
    }
    await repo.loadDinamicas();
    await repo.loadSteamUnits();
    calendario = await CalendarioContenido.cargar(stringLoader: ler);
  });

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('hoxe_nucleo_');
    store = CalendarioStore(overrideDirectory: dir.path);
    await store.cargar();
  });

  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  List<String> erroresDe(WidgetTester tester) => [
        for (var e = tester.takeException();
            e != null;
            e = tester.takeException())
          e.toString().split('\n').first,
      ];

  Future<void> pintar(WidgetTester tester, Widget pantalla,
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
      home: pantalla,
    ));
    await tester.pumpAndSettle();
  }

  test('o mesmo núcleo no calendario e en Hoxe, o mesmo día', () {
    for (final c in cursos) {
      final doCalendario =
          calendario.trayecto[calendario.indiceNoTrayecto(c, lunes)].unidade!;
      final deHoxe = repo.unidadeDoMesSync(c, lunes.month)!;
      expect(deHoxe.id, doCalendario.id, reason: c);
      expect(repo.nucleoSync(deHoxe).map((p) => p.ref),
          doCalendario.nucleo.map((n) => n.ref),
          reason: c);
    }
    expect(repo.unidadeDoMesSync('curso_0_2', 7), isNull,
        reason: 'Xullo non é un mes do curso.');
  });

  // Lo que comprobaba la tarjeta suelta del inglés en casa, que no usaba
  // ninguna pantalla y se retiró: ahora sobre Hoxe de casa de verdad.
  for (final lang in AppLanguage.deInterfaz) {
    Widget casa(DateTime agora) => HoxeFamiliasScreen(
          repository: repo,
          store: store,
          language: lang,
          onLanguageChanged: (_) {},
          cursoId: 'curso_0_2',
          onCambiarCurso: (_) {},
          audioService: MockOfflineAudioService(),
          agora: agora,
        );

    Future<void> abrirPalabras(WidgetTester tester) async {
      final tarxeta = find.byKey(const Key('tarxeta_ingles_de_hoxe_fogar'));
      await tester.dragUntilVisible(tarxeta,
          find.byKey(const Key('hoxe_familias')), const Offset(0, -150));
      await tester.pumpAndSettle();
      final abrir = find.descendant(
          of: tarxeta,
          matching: find.byKey(const Key('abrir_palabras_do_dia')));
      await tester.ensureVisible(abrir);
      await tester.pumpAndSettle();
      await tester.tap(abrir);
      await tester.pumpAndSettle();
    }

    testWidgets('Hoxe da casa: as do día, coa dinámica da CASA (${lang.code})',
        (tester) async {
      await pintar(tester, casa(lunes));
      await abrirPalabras(tester);
      final tarxeta = find.byKey(const Key('tarxeta_ingles_de_hoxe_fogar'));
      final curso = repo.cursoTprSync('curso_0_2')!;
      for (final p in curso.planDoDia(10, 3, 1)!.newWords) {
        expect(find.descendant(of: tarxeta, matching: find.text(p.en)),
            findsOneWidget,
            reason: p.en);
      }
      expect(
          find.descendant(
              of: tarxeta,
              matching:
                  find.text(curso.modelo.dia(1)!.dinamicaFogar.resolve(lang))),
          findsOneWidget);
      expect(erroresDe(tester), isEmpty);
    });

    testWidgets('Hoxe da casa en agosto: as do primeiro día (${lang.code})',
        (tester) async {
      await tester.runAsync(() => repo.loadUnidadeDoMes('curso_0_2', 9));
      await pintar(tester, casa(DateTime(2026, 8, 3)));
      await abrirPalabras(tester);
      final tarxeta = find.byKey(const Key('tarxeta_ingles_de_hoxe_fogar'));
      for (final p
          in repo.cursoTprSync('curso_0_2')!.planDoDia(9, 1, 1)!.newWords) {
        expect(find.descendant(of: tarxeta, matching: find.text(p.en)),
            findsOneWidget,
            reason: p.en);
      }
      expect(erroresDe(tester), isEmpty);
    });
  }

  for (final lang in AppLanguage.deInterfaz) {
    final gl = lang == AppLanguage.gl;
    for (final escala in [1.0, 1.8]) {
      for (final c in cursos) {
        final etiqueta = '$c, ${lang.code} a escala $escala';

        testWidgets(
            'Hoxe do aula: o núcleo diante e as do día pregadas, '
            '$etiqueta', (tester) async {
          await pintar(
            tester,
            HoxeDocentesScreen(
              repository: repo,
              language: lang,
              onLanguageChanged: (_) {},
              cursoId: c,
              onCambiarCurso: (_) {},
              audioService: MockOfflineAudioService(),
              agora: lunes,
            ),
            escala: escala,
          );
          await comprobar(tester, repo, c, gl,
              lista: find.byKey(const Key('hoxe_docentes')),
              tarxeta: find.byKey(const Key('hoxe_aula_palabras')));
          expect(erroresDe(tester), isEmpty, reason: etiqueta);
        });

        testWidgets(
            'Hoxe da casa: o núcleo diante e as do día pregadas, '
            '$etiqueta', (tester) async {
          await pintar(
            tester,
            HoxeFamiliasScreen(
              repository: repo,
              store: store,
              language: lang,
              onLanguageChanged: (_) {},
              cursoId: c,
              onCambiarCurso: (_) {},
              audioService: MockOfflineAudioService(),
              agora: lunes,
            ),
            escala: escala,
          );
          await comprobar(tester, repo, c, gl,
              lista: find.byKey(const Key('hoxe_familias')),
              tarxeta: find.byKey(const Key('tarxeta_ingles_de_hoxe_fogar')));
          expect(erroresDe(tester), isEmpty, reason: etiqueta);
        });
      }
    }
  }
}

/// Que la tarjeta lleve el núcleo de la unidad, que las cinco del día no se
/// vean hasta abrir el pliegue y que, abierto, estén las cinco.
Future<void> comprobar(
    WidgetTester tester, ContentRepository repo, String curso, bool gl,
    {required Finder lista, required Finder tarxeta}) async {
  final nucleo = repo.nucleoSync(repo.unidadeDoMesSync(curso, 10)!);
  expect(nucleo, isNotEmpty);

  await tester.dragUntilVisible(tarxeta, lista, const Offset(0, -150));
  await tester.pumpAndSettle();
  final enTarxeta = find.descendant(
      of: tarxeta, matching: find.byKey(const Key('nucleo_de_hoxe')));
  expect(enTarxeta, findsOneWidget);
  for (final p in nucleo) {
    expect(find.descendant(of: enTarxeta, matching: find.text(p.en)),
        findsOneWidget,
        reason: p.en);
  }

  final plan = repo.cursoTprSync(curso)!.planDoDia(10, 3, 1)!;
  final nova = plan.newWords.first.en;
  expect(find.descendant(of: tarxeta, matching: find.text(nova)), findsNothing,
      reason: 'As do día van pregadas.');
  expect(
      find.descendant(
          of: tarxeta,
          matching: find.text(gl ? 'PALABRAS DE HOXE' : 'PALABRAS DE HOY')),
      findsOneWidget);

  final abrir = find.descendant(
      of: tarxeta, matching: find.byKey(const Key('abrir_palabras_do_dia')));
  await tester.ensureVisible(abrir);
  await tester.pumpAndSettle();
  await tester.tap(abrir);
  await tester.pumpAndSettle();
  for (final p in plan.newWords) {
    expect(
        find.descendant(of: tarxeta, matching: find.text(p.en)), findsOneWidget,
        reason: p.en);
  }
}
