import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/storage/calendario_store.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/loaders/content_asset_loader.dart';
import 'package:descubre_con_lua/data/models/steam_model.dart';
import 'package:descubre_con_lua/data/models/tpr_curriculum_scheduler.dart';
import 'package:descubre_con_lua/data/repositories/calendario_repository.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/data/validators/content_validator.dart';
import 'package:descubre_con_lua/features/calendario/views/calendario_fogar_screen.dart';
import 'package:descubre_con_lua/features/calendario/views/calendario_screen.dart';
import 'package:descubre_con_lua/features/docentes/widgets/hoxe_na_aula.dart';
import 'package:descubre_con_lua/features/juega/widgets/circulo_do_dia.dart';
import 'package:descubre_con_lua/features/steam/views/steam_sesion_guiada_screen.dart';
import 'package:descubre_con_lua/features/steam/widgets/steam_no_calendario.dart';

/// La sesión STEAM en «Hoxe na aula» y en el calendario, el día que toca.
///
/// Nace de una sesión que solo vivía en el portal: la docente tenía que
/// acordarse de ir a buscarla. Ahora cada unidad trae su día del curso y sale
/// sola ese día, en la tarjeta de hoy, en el día del Modo Aula y en el día del
/// calendario, del lado del aula y del de casa.
void main() {
  late ContentRepository repo;
  late ProgramaTpr programa;
  late CalendarioContenido contenido;
  late CalendarioStore store;
  late Directory dir;
  final crudo = File(ContentAssetLoader.steamAssetPath).readAsStringSync();
  List<dynamic> copia() => jsonDecode(crudo) as List<dynamic>;

  setUpAll(() async {
    Future<String> ler(String p) => File(p).readAsString();
    programa = await ProgramaTpr.cargar(stringLoader: ler);
    contenido = await CalendarioContenido.cargar(stringLoader: ler);
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
      unidadPaths: jsons('assets/content/unidades'),
      capsulaPaths: const [],
      asambleaSegundoCicloPaths:
          jsons('assets/content/asambleas_segundo_ciclo'),
    );
    for (final p in jsons('assets/content/progresion')) {
      repo.addProgresion(await loader.loadProgresion(p));
    }
    repo.addProgramaTpr(programa);
    // Todo lo que se lee de disco, aquí: dentro de un `testWidgets` el reloj
    // es falso y una lectura de disco no termina.
    await repo.loadCalendarioDias(cursoId: '');
    await repo.loadCuentos();
    await repo.loadDinamicas();
  });

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('steam_calendario_');
    store = CalendarioStore(overrideDirectory: dir.path);
    await store.cargar();
  });

  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  SteamUnit unidad(String nivel) => repo.getSteamUnitByNivel(nivel)!;

  group('El día de cada sesión', () {
    // Es la tabla de `docs/BASE_PEDAGOGICA_STEAM.md`: el miércoles de la
    // semana 2, en el mes cuyo centro de interés casa con la unidad. Si cambia
    // el JSON, cambia el documento.
    test('miércoles de la semana 2, en el mes que casa con la unidad', () {
      const meses = {
        'curso_0_2': 3, // noviembre: texturas
        'curso_2_3': 7, // marzo: formas
        'curso_3_4': 8, // abril: el ciclo del agua
        'curso_4_5': 4, // diciembre: ciencia del invierno y comparaciones
        'curso_5_6': 7, // marzo: patrones
      };
      expect(repo.steamUnits, hasLength(5));
      for (final u in repo.steamUnits) {
        final d = u.diaNoCalendario;
        expect(d, isNotNull, reason: u.id);
        expect(d!.mes, meses[u.estadio], reason: u.id);
        expect(d.semana, 2, reason: u.id);
        expect(d.dia, 3, reason: u.id);
      }
    });

    test('del mes del calendario al mes del curso', () {
      expect(SteamDiaNoCalendario.mesDoCursoDe(9), 1);
      expect(SteamDiaNoCalendario.mesDoCursoDe(12), 4);
      expect(SteamDiaNoCalendario.mesDoCursoDe(1), 5);
      expect(SteamDiaNoCalendario.mesDoCursoDe(6), 10);
      expect(SteamDiaNoCalendario.mesDoCursoDe(7), 0);
      expect(SteamDiaNoCalendario.mesDoCursoDe(8), 0);
    });

    // La cadena entera: la fecha, el día del curso de «Hoxe na aula» y la
    // sesión. Son fechas reales del curso 2026-2027.
    test('la fecha de hoy lleva a la sesión de su curso', () {
      SteamUnit? de(String curso, DateTime fecha) =>
          steamDoDiaDoCurso(repo, curso, CursoTpr.hoxe(agora: fecha)!);

      expect(de('curso_0_2', DateTime(2026, 11, 11))?.id, 'I1-MATERIA-001');
      expect(de('curso_4_5', DateTime(2026, 12, 9))?.id, 'I4-OPTICA-001');
      expect(de('curso_2_3', DateTime(2027, 3, 10))?.id, 'I2-CINEMATICA-001');
      expect(de('curso_5_6', DateTime(2027, 3, 10))?.id, 'I5-LOGICA-001');
      expect(de('curso_3_4', DateTime(2027, 4, 14))?.id, 'I3-ACUSTICA-001');
      // El jueves no, y el miércoles de otro curso tampoco.
      expect(de('curso_4_5', DateTime(2026, 12, 10)), isNull);
      expect(de('curso_3_4', DateTime(2026, 12, 9)), isNull);
    });

    test('el repositorio busca por día y por mes', () {
      expect(
        repo
            .getSteamUnitsDoDia(cursoId: 'curso_4_5', mes: 4, semana: 2, dia: 3)
            .map((u) => u.id),
        ['I4-OPTICA-001'],
      );
      expect(
          repo.getSteamUnitsDoDia(
              cursoId: 'curso_4_5', mes: 4, semana: 2, dia: 2),
          isEmpty);
      // El catálogo de diez meses, sin curso: marzo trae dos.
      expect(
        repo
            .getSteamUnitsDoDia(mes: 7, semana: 2, dia: 3)
            .map((u) => u.id)
            .toSet(),
        {'I2-CINEMATICA-001', 'I5-LOGICA-001'},
      );
      expect(
          repo
              .getSteamUnitsDoMes(cursoId: 'curso_0_2', mes: 3)
              .map((u) => u.id),
          ['I1-MATERIA-001']);
      expect(repo.getSteamUnitsDoMes(cursoId: 'curso_0_2', mes: 4), isEmpty);
    });

    test('el validador rechaza un día que no existe', () {
      final validator = ContentValidator();
      final b = copia();
      (b[3] as Map)['calendario'] = {'mes': 4, 'semana': 5, 'dia': 3};
      expect(validator.validateSteamBankJson(b).errors.join('\n'),
          contains('calendario.semana must be an integer between 1 and 4'));

      final sinDia = copia();
      (sinDia[0] as Map).remove('calendario');
      expect(validator.validateSteamBankJson(sinDia).errors.join('\n'),
          contains('Missing required STEAM field: "calendario"'));
    });
  });

  group('Pantallas', () {
    Future<void> pintar(WidgetTester tester, Widget w,
        {Size tamano = const Size(400, 900)}) async {
      tester.view.physicalSize = tamano;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: w));
      await tester.pumpAndSettle();
    }

    // Con `ensureVisible` y no con un `Scrollable` concreto: el calendario
    // tiene los meses en un `PageView` horizontal y el primer `Scrollable` que
    // aparece no es la lista que se desplaza hacia abajo.
    Future<void> verYTocar(WidgetTester tester, Finder f) async {
      expect(f, findsOneWidget);
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      await tester.tap(f);
      await tester.pumpAndSettle();
    }

    Widget hoxe(DateTime agora, List<SteamUnit> abertas) => Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TarxetaHoxeNaAula(
                programa: programa,
                cursoId: 'curso_4_5',
                onCambiarCurso: (_) {},
                language: AppLanguage.gl,
                audioService: MockOfflineAudioService(),
                agora: agora,
                onIniciarAsemblea: (_, __) {},
                onVerPalabras: () {},
                steamDoDia: (c, d) => steamDoDiaDoCurso(repo, c, d),
                onAbrirSteam: abertas.add,
              ),
            ],
          ),
        );

    testWidgets('«Hoxe na aula» trae la sesión el día que le toca al curso',
        (tester) async {
      final abertas = <SteamUnit>[];
      await pintar(tester, hoxe(DateTime(2026, 12, 9), abertas));
      final fila = find.byKey(const ValueKey('fila_steam_I4-OPTICA-001'));
      expect(fila, findsOneWidget);
      expect(find.text('A sesión STEAM de hoxe'), findsOneWidget);
      expect(find.text('Sombras grandes e pequenas'), findsOneWidget);
      await tester.tap(fila);
      expect(abertas.map((u) => u.id), ['I4-OPTICA-001']);
    });

    testWidgets('«Hoxe na aula» no la trae el día siguiente', (tester) async {
      await pintar(tester, hoxe(DateTime(2026, 12, 10), []));
      expect(find.byKey(const Key('tarxeta_hoxe_na_aula')), findsOneWidget);
      expect(find.textContaining('STEAM'), findsNothing);
    });

    testWidgets('El día del Modo Aula abre la versión del aula',
        (tester) async {
      await pintar(
        tester,
        Scaffold(
          body: ListView(children: [
            CirculoDoDia(
              repository: repo,
              cursoId: 'curso_4_5',
              mes: 4,
              semana: 2,
              dia: 3,
              language: AppLanguage.es,
              audioService: MockOfflineAudioService(),
            ),
          ]),
        ),
      );
      final fila = find.byKey(const ValueKey('fila_steam_I4-OPTICA-001'));
      expect(fila, findsOneWidget);
      expect(find.text('La sesión STEAM de hoy'), findsOneWidget);
      await tester.tap(fila);
      await tester.pumpAndSettle();
      final sesion = tester.widget<SteamSesionGuiadaScreen>(
          find.byType(SteamSesionGuiadaScreen));
      expect(sesion.unit.id, 'I4-OPTICA-001');
      expect(sesion.audiencia, SteamAudiencia.aula);
    });

    testWidgets('El día del Modo Aula no la trae otro día', (tester) async {
      await pintar(
        tester,
        Scaffold(
          body: ListView(children: [
            CirculoDoDia(
              repository: repo,
              cursoId: 'curso_4_5',
              mes: 4,
              semana: 3,
              dia: 3,
              language: AppLanguage.gl,
            ),
          ]),
        ),
      );
      expect(find.textContaining('STEAM'), findsNothing);
    });

    // El calendario del Modo Aula: el mes de diciembre de 4-5 años. Estos
    // tests miden QUÉ sale, a 520 de ancho como los demás de estas pantallas:
    // el encaje a 360 y con letra grande se mide más abajo, en «Cabe a 360 dp».
    Widget calendario({
      required bool docente,
      ValueChanged<AppLanguage>? onLanguageChanged,
    }) =>
        CalendarioScreen(
          store: store,
          contenido: contenido,
          cursoInicial: 'curso_4_5',
          mesInicialIndex: 3,
          esDocenteInicial: docente,
          initialLanguage: AppLanguage.gl,
          onLanguageChanged: onLanguageChanged,
          repository: repo,
          audioService: MockOfflineAudioService(),
        );

    testWidgets('El calendario, lado del aula: el aviso del mes y el día',
        (tester) async {
      await pintar(tester, calendario(docente: true),
          tamano: const Size(520, 2600));
      final aviso = find.byKey(const ValueKey('aviso_steam_do_mes'));
      expect(aviso, findsOneWidget);
      expect(
          find.descendant(
              of: aviso,
              matching: find
                  .text('mércores da semana 2 · Sombras grandes e pequenas')),
          findsOneWidget);

      await verYTocar(tester, find.byKey(const ValueKey('cal_semana_2')));
      await verYTocar(tester, find.byKey(const ValueKey('cal_dia_3')));
      final fila = find.byKey(const ValueKey('fila_steam_I4-OPTICA-001'));
      await verYTocar(tester, fila);
      final sesion = tester.widget<SteamSesionGuiadaScreen>(
          find.byType(SteamSesionGuiadaScreen));
      expect(sesion.audiencia, SteamAudiencia.aula);
    });

    testWidgets('El calendario, lado de casa: la versión de casa ese día',
        (tester) async {
      await pintar(tester, calendario(docente: false),
          tamano: const Size(520, 2600));
      expect(find.byKey(const ValueKey('aviso_steam_do_mes')), findsOneWidget);

      await verYTocar(tester, find.byKey(const ValueKey('fogar_semana_2')));
      await verYTocar(tester, find.byKey(const ValueKey('fogar_dia_3')));
      final fila = find.byKey(const ValueKey('fila_steam_I4-OPTICA-001'));
      expect(find.text('O xogo STEAM de hoxe'), findsOneWidget);
      await verYTocar(tester, fila);
      final sesion = tester.widget<SteamSesionGuiadaScreen>(
          find.byType(SteamSesionGuiadaScreen));
      expect(sesion.audiencia, SteamAudiencia.hogar);
    });

    testWidgets('El calendario de las familias: la casilla, el aviso y el día',
        (tester) async {
      await pintar(
        tester,
        CalendarioFogarScreen(
          repository: repo,
          store: store,
          initialLanguage: AppLanguage.es,
          initialCursoId: 'curso_4_5',
          agora: DateTime(2026, 9, 7),
          audioService: MockOfflineAudioService(),
        ),
        tamano: const Size(520, 2600),
      );
      // Setembro no tiene sesión: ni aviso ni casilla marcada.
      expect(find.byKey(const ValueKey('aviso_steam_do_mes')), findsNothing);
      // La tira de meses es perezosa: diciembre no existe hasta que se llega.
      final meses = find
          .ancestor(
              of: find.text('Noviembre'), matching: find.byType(Scrollable))
          .first;
      await tester.scrollUntilVisible(find.text('Diciembre'), 100,
          scrollable: meses);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Diciembre'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('aviso_steam_do_mes')), findsOneWidget);
      final casilla = find.byKey(const ValueKey('reixa_steam_2_3'));
      expect(casilla, findsOneWidget);
      await verYTocar(tester, casilla);
      final fila = find.byKey(const ValueKey('fila_steam_I4-OPTICA-001'));
      expect(find.text('El juego STEAM de hoy'), findsOneWidget);
      await verYTocar(tester, fila);
      final sesion = tester.widget<SteamSesionGuiadaScreen>(
          find.byType(SteamSesionGuiadaScreen));
      expect(sesion.audiencia, SteamAudiencia.hogar);
      expect(find.text('Sombras grandes y pequeñas'), findsWidgets);
    });

    // Quien cambia de lengua dentro de la sesión vuelve al calendario en esa
    // lengua, desde los dos lados y desde el calendario de las familias; y el
    // cambio sigue hacia arriba, hasta la pantalla que abrió el calendario.
    Future<void> alCastellanoYVolver(WidgetTester tester) async {
      await tester.tap(find.descendant(
          of: find.byType(SteamSesionGuiadaScreen), matching: find.text('ES')));
      await tester.pumpAndSettle();
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
      expect(find.byType(SteamSesionGuiadaScreen), findsNothing);
    }

    for (final docente in [true, false]) {
      final lado = docente ? 'del aula' : 'de casa';
      testWidgets('El calendario, lado $lado: se vuelve en la otra lengua',
          (tester) async {
        final cambios = <AppLanguage>[];
        await pintar(tester,
            calendario(docente: docente, onLanguageChanged: cambios.add),
            tamano: const Size(520, 2600));
        final p = docente ? 'cal' : 'fogar';
        await verYTocar(tester, find.byKey(ValueKey('${p}_semana_2')));
        await verYTocar(tester, find.byKey(ValueKey('${p}_dia_3')));
        expect(
            find.text(
                docente ? 'A sesión STEAM de hoxe' : 'O xogo STEAM de hoxe'),
            findsOneWidget);
        await verYTocar(
            tester, find.byKey(const ValueKey('fila_steam_I4-OPTICA-001')));
        await alCastellanoYVolver(tester);
        expect(
            find.text(
                docente ? 'La sesión STEAM de hoy' : 'El juego STEAM de hoy'),
            findsOneWidget);
        expect(cambios, [AppLanguage.es]);
      });
    }

    testWidgets('El calendario de las familias: se vuelve en la otra lengua',
        (tester) async {
      final cambios = <AppLanguage>[];
      await pintar(
        tester,
        CalendarioFogarScreen(
          repository: repo,
          store: store,
          initialLanguage: AppLanguage.gl,
          onLanguageChanged: cambios.add,
          initialCursoId: 'curso_4_5',
          agora: DateTime(2026, 9, 7),
          audioService: MockOfflineAudioService(),
        ),
        tamano: const Size(520, 2600),
      );
      final meses = find
          .ancestor(
              of: find.text('Novembro'), matching: find.byType(Scrollable))
          .first;
      await tester.scrollUntilVisible(find.text('Decembro'), 100,
          scrollable: meses);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Decembro'));
      await tester.pumpAndSettle();
      await verYTocar(tester, find.byKey(const ValueKey('reixa_steam_2_3')));
      expect(find.text('O xogo STEAM de hoxe'), findsOneWidget);
      await verYTocar(
          tester, find.byKey(const ValueKey('fila_steam_I4-OPTICA-001')));
      await alCastellanoYVolver(tester);
      expect(find.text('El juego STEAM de hoy'), findsOneWidget);
      expect(cambios, [AppLanguage.es]);
    });
  });

  // Que QUEPA: 360 dp, gallego y castellano, letra normal y grande. En las
  // pantallas de verdad, a 360 dp, la fila tiene 264 px de ancho en «Hoxe na
  // aula», 267 en el día del Modo Aula, 280 en el calendario y 260 en el
  // calendario de las familias (cómo se midió, en STATUS.md). El día del Modo
  // Aula se pinta aquí suelto, con 302: por eso la fila se mide además sola a
  // 260, la más estrecha de las cuatro. El lado de casa del calendario NO se
  // mide entero aquí: desborda también en un día sin STEAM, y eso no es de
  // este cambio (ver STATUS.md).
  group('Cabe a 360 dp', () {
    // `takeException()` y no un `FlutterError.onError` puesto en `setUp`:
    // `testWidgets` cambia ese manejador y la lista salía siempre vacía.
    List<String> errores(WidgetTester tester) {
      final fuera = <String>[];
      for (var e = tester.takeException();
          e != null;
          e = tester.takeException()) {
        fuera.add(e.toString().split('\n').first);
      }
      return fuera;
    }

    Future<void> pintar(WidgetTester tester, Widget w, double escala,
        {double ancho = 360}) async {
      tester.view.physicalSize = Size(ancho, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(escala)),
          child: child!,
        ),
        home: w,
      ));
      await tester.pumpAndSettle();
    }

    Future<void> tocar(WidgetTester tester, Finder f) async {
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      await tester.tap(f);
      await tester.pumpAndSettle();
    }

    testWidgets('el medidor ve un desborde hecho a propósito', (tester) async {
      await pintar(
        tester,
        const Scaffold(body: Row(children: [SizedBox(width: 500, height: 10)])),
        1.0,
      );
      expect(errores(tester), isNotEmpty);
    });

    for (final lang in AppLanguage.deInterfaz) {
      for (final escala in [1.0, 1.8]) {
        final etiqueta = '${lang.code}, escala $escala';

        testWidgets('la fila y el aviso, sueltos a 260 px ($etiqueta)',
            (tester) async {
          await pintar(
            tester,
            Scaffold(
              body: ListView(
                children: [
                  for (final audiencia in SteamAudiencia.values)
                    FilaSteamDoDia(
                      unidade: unidad('I4'),
                      audiencia: audiencia,
                      language: lang,
                      conIdade: true,
                      onTap: () {},
                    ),
                  AvisoSteamDoMes(
                    unidades: [unidad('I2'), unidad('I5')],
                    language: lang,
                    conIdade: true,
                  ),
                ],
              ),
            ),
            escala,
            ancho: 260,
          );
          expect(find.byType(FilaSteamDoDia), findsNWidgets(2));
          expect(errores(tester), isEmpty);
        });

        testWidgets('«Hoxe na aula» el día STEAM ($etiqueta)', (tester) async {
          await pintar(
            tester,
            Scaffold(
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TarxetaHoxeNaAula(
                    programa: programa,
                    cursoId: 'curso_4_5',
                    onCambiarCurso: (_) {},
                    language: lang,
                    agora: DateTime(2026, 12, 9),
                    onIniciarAsemblea: (_, __) {},
                    onVerPalabras: () {},
                    steamDoDia: (c, d) => steamDoDiaDoCurso(repo, c, d),
                    onAbrirSteam: (_) {},
                  ),
                ],
              ),
            ),
            escala,
          );
          expect(find.byType(FilaSteamDoDia), findsOneWidget);
          expect(errores(tester), isEmpty);
        });

        testWidgets('el día del Modo Aula el día STEAM ($etiqueta)',
            (tester) async {
          await pintar(
            tester,
            Scaffold(
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  CirculoDoDia(
                    repository: repo,
                    cursoId: 'curso_4_5',
                    mes: 4,
                    semana: 2,
                    dia: 3,
                    language: lang,
                  ),
                ],
              ),
            ),
            escala,
          );
          expect(find.byType(FilaSteamDoDia), findsOneWidget);
          expect(errores(tester), isEmpty);
        });

        testWidgets('el calendario, lado del aula, el día STEAM ($etiqueta)',
            (tester) async {
          await pintar(
            tester,
            CalendarioScreen(
              store: store,
              contenido: contenido,
              cursoInicial: 'curso_4_5',
              mesInicialIndex: 3,
              esDocenteInicial: true,
              initialLanguage: lang,
              repository: repo,
              audioService: MockOfflineAudioService(),
            ),
            escala,
          );
          await tocar(tester, find.byKey(const ValueKey('cal_semana_2')));
          await tocar(tester, find.byKey(const ValueKey('cal_dia_3')));
          expect(find.byType(FilaSteamDoDia), findsOneWidget);
          expect(find.byType(AvisoSteamDoMes), findsOneWidget);
          expect(errores(tester), isEmpty);
        });

        testWidgets('el calendario de las familias el día STEAM ($etiqueta)',
            (tester) async {
          await pintar(
            tester,
            CalendarioFogarScreen(
              repository: repo,
              store: store,
              initialLanguage: lang,
              initialCursoId: 'curso_4_5',
              agora: DateTime(2026, 9, 7),
              audioService: MockOfflineAudioService(),
            ),
            escala,
          );
          final outubro = lang == AppLanguage.gl ? 'Outubro' : 'Octubre';
          final decembro = lang == AppLanguage.gl ? 'Decembro' : 'Diciembre';
          final meses = find
              .ancestor(
                  of: find.text(outubro), matching: find.byType(Scrollable))
              .first;
          await tester.scrollUntilVisible(find.text(decembro), 100,
              scrollable: meses);
          await tester.pumpAndSettle();
          await tester.tap(find.text(decembro));
          await tester.pumpAndSettle();
          expect(find.byType(AvisoSteamDoMes), findsOneWidget);
          expect(errores(tester), isEmpty);

          final vertical = find
              .descendant(
                  of: find.byType(ListView).first,
                  matching: find.byType(Scrollable))
              .first;
          final casilla = find.byKey(const ValueKey('reixa_steam_2_3'));
          await tester.scrollUntilVisible(casilla, 100, scrollable: vertical);
          await tester.pumpAndSettle();
          await tester.tap(casilla);
          await tester.pumpAndSettle();
          await tester.scrollUntilVisible(find.byType(FilaSteamDoDia), 100,
              scrollable: vertical);
          await tester.pumpAndSettle();
          expect(errores(tester), isEmpty);
        });
      }
    }
  });
}
