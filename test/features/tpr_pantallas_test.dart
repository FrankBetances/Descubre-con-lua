import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/storage/calendario_store.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/loaders/content_asset_loader.dart';
import 'package:descubre_con_lua/data/models/asamblea_primeiro_ciclo_model.dart';
import 'package:descubre_con_lua/data/models/asamblea_segundo_ciclo_model.dart';
import 'package:descubre_con_lua/data/models/progresion_model.dart';
import 'package:descubre_con_lua/data/models/tpr_curriculum_scheduler.dart';
import 'package:descubre_con_lua/data/repositories/calendario_repository.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/calendario/views/calendario_fogar_screen.dart';
import 'package:descubre_con_lua/features/calendario/views/calendario_screen.dart';
import 'package:descubre_con_lua/features/calendario/widgets/palabras_do_dia.dart';
import 'package:descubre_con_lua/features/docentes/portal_docentes_screen.dart';
import 'package:descubre_con_lua/features/docentes/widgets/hoxe_na_aula.dart';
import 'package:descubre_con_lua/features/familias/portal_familias_screen.dart';
import 'package:descubre_con_lua/features/familias/widgets/tarxeta_ingles_de_hoxe_fogar.dart';
import 'package:descubre_con_lua/features/juega/views/asamblea_player_screen.dart';
import 'package:descubre_con_lua/features/premios/premios_repository.dart';

/// Las cinco palabras diarias, en las pantallas donde la docente y la familia
/// las ven. No basta con que «no desborde»: aquí se comprueba QUÉ sale, porque
/// una tarjeta bien dispuesta con las palabras de otro día pasaría todos los
/// tests de escala.
///
/// Las tarjetas nuevas se miden SOLAS, a 360×640 y con texto grande. Los
/// portales enteros se abren aparte, a un tamaño en que lo que ya había en
/// ellos cabe: si no, un desborde anterior a estas tarjetas taparía uno suyo.
///
/// Lo que un widget test NO demuestra: las fuentes reales, la muesca y la barra
/// de gestos, las densidades reales y que el audio suene. Eso, en un aparato.
void main() {
  late ProgramaTpr programa;
  // El curso con el que abren los portales y el calendario: el primero.
  CursoTpr curso0() => programa.curso('curso_0_2')!;
  late CursoTpr curso;
  late CalendarioContenido contenido;
  late ContentRepository repo;
  late CalendarioStore store;
  late Directory dir;

  setUpAll(() async {
    Future<String> ler(String p) => File(p).readAsString();
    programa = await ProgramaTpr.cargar(stringLoader: ler);
    curso = curso0();
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
    // Lo que en la app llega por descubrimiento del paquete.
    for (final p in jsons('assets/content/asambleas_primeiro_ciclo')) {
      repo.addAsambleaPrimeiroCiclo(await loader.loadAsambleaPrimeiroCiclo(p));
    }
    for (final p in jsons('assets/content/progresion')) {
      repo.addProgresion(await loader.loadProgresion(p));
    }
    repo.addProgramaTpr(programa);
    // El banco de días se lee aquí, con E/S de verdad: dentro de un
    // `testWidgets` el reloj es falso y una lectura de disco no termina.
    await repo.loadCalendarioDias(cursoId: '');
  });

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('tpr_pantallas_');
    store = CalendarioStore(overrideDirectory: dir.path);
    await store.cargar();
  });

  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  // Lo que devuelve `takeException()` SE GUARDA y se devuelve. Recoger los
  // errores con un `FlutterError.onError` puesto en `setUp` no sirve:
  // `testWidgets` cambia ese manejador mientras corre el test, la lista salía
  // siempre vacía y un desborde de 150 px pasaba en verde. Se comprobó con un
  // desborde a propósito. El fichero y la línea del desborde los imprime el
  // propio binding en la consola.
  List<String> erroresDe(WidgetTester tester) {
    final fuera = <String>[];
    for (var e = tester.takeException();
        e != null;
        e = tester.takeException()) {
      fuera.add(e.toString().split('\n').first);
    }
    return fuera;
  }

  Future<void> pintar(WidgetTester tester, Widget pantalla,
      {double escala = 1.0, Size tamano = const Size(360, 640)}) async {
    tester.view.physicalSize = tamano;
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

  /// Como la tarjeta vive en el portal: en una lista con 16 de margen.
  Widget enLista(Widget tarxeta) => Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [tarxeta],
        ),
      );

  void compruebaPalabras(Finder dentro, DailyTprPlan plan, AppLanguage lang) {
    expect(
      find.descendant(
          of: dentro, matching: find.text(PalabrasDoDia.resumo(plan, lang))),
      findsOneWidget,
    );
    for (final p in plan.newWords) {
      expect(find.descendant(of: dentro, matching: find.text(p.en)),
          findsOneWidget,
          reason: p.en);
    }
  }

  // Los 200 días de cada curso, al ancho que cada pieza tiene en un teléfono de
  // 360: 260 el recuadro del calendario de casa (el más estrecho de los tres;
  // el del aula y el del día en casa tienen 280) y 293 las palabras dentro de
  // las tarjetas de los portales. Anchos medidos en las pantallas reales.
  // Un día con la frase más larga del curso es el que desborda, no el lunes
  // que sale en la captura.
  group('Os 1.000 días dos cinco cursos caben', () {
    for (final cursoId in cursoTprDoGrupo.values) {
      for (final lang in AppLanguage.deInterfaz) {
        for (final escala in [1.0, 1.8]) {
          for (final mesCalendario in [9, 10, 11, 12, 1, 2, 3, 4, 5, 6]) {
            testWidgets(
                '$cursoId, mes $mesCalendario, ${lang.code} a escala $escala',
                (tester) async {
              final curso = programa.curso(cursoId)!;
              final mes = curso.mes(mesCalendario)!;
              await pintar(
                tester,
                Scaffold(
                  body: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final s in mes.semanas)
                          for (var dia = 1; dia <= 5; dia++) ...[
                            for (final fogar in [false, true])
                              SizedBox(
                                width: 260,
                                child: BloqueInglesDoDia(
                                  rotulo: fogar
                                      ? 'O INGLÉS DESTE DÍA NA CASA'
                                      : 'INGLÉS DO DÍA · 5 PALABRAS NOVAS DE LUNS A XOVES',
                                  plan: s.planDoDia(dia),
                                  modeloDoDia: curso.modelo.dia(dia),
                                  semana: s,
                                  language: lang,
                                  paraFogar: fogar,
                                ),
                              ),
                            for (final fogar in [false, true])
                              SizedBox(
                                width: 293,
                                child: PalabrasDoDia(
                                  plan: s.planDoDia(dia),
                                  modeloDoDia: curso.modelo.dia(dia),
                                  language: lang,
                                  paraFogar: fogar,
                                  detalle: false,
                                ),
                              ),
                          ],
                      ],
                    ),
                  ),
                ),
                escala: escala,
              );
              expect(find.byType(PalabrasDoDia), findsNWidgets(20 * 4));
              expect(erroresDe(tester), isEmpty,
                  reason: 'Algún día de $cursoId, mes $mesCalendario, desborda '
                      'en ${lang.code} a escala $escala.');
            });
          }
        }
      }
    }
  });

  // Un miércoles de la cuarta semana: bloque C, cinco nuevas y diez de repaso.
  final miercoles = DateTime(2026, 9, 23);

  for (final lang in AppLanguage.deInterfaz) {
    for (final escala in [1.0, 1.8]) {
      final etiqueta = '${lang.code} a escala $escala';

      group('A tarxeta «Hoxe na aula», en $etiqueta', () {
        testWidgets('as palabras son as do día da data, e cabe',
            (tester) async {
          DiaDoCursoTpr? pedido;
          String? cursoPedido;
          var verPalabras = 0;
          await pintar(
            tester,
            enLista(TarxetaHoxeNaAula(
              programa: programa,
              cursoId: 'curso_0_2',
              onCambiarCurso: (_) {},
              language: lang,
              audioService: MockOfflineAudioService(),
              agora: miercoles,
              onIniciarAsemblea: (d, c) {
                pedido = d;
                cursoPedido = c;
              },
              onVerPalabras: () => verPalabras++,
            )),
            escala: escala,
          );
          final tarxeta = find.byKey(const Key('tarxeta_hoxe_na_aula'));
          expect(tarxeta, findsOneWidget);
          final plan = curso.planDoDia(9, 4, 3)!;
          expect(plan.newWords, hasLength(5));
          expect(plan.reviewWords, hasLength(10));
          compruebaPalabras(tarxeta, plan, lang);
          expect(
              find.text(lang == AppLanguage.gl
                  ? 'HOXE NA AULA · RITMO TPR'
                  : 'HOY EN EL AULA · RITMO TPR'),
              findsOneWidget);
          expect(erroresDe(tester), isEmpty,
              reason: 'A tarxeta de hoxe desborda en $etiqueta.');

          // Os dous botóns chegan co día da tarxeta, non con outro.
          final iniciar = find.byKey(const Key('boton_asemblea_de_hoxe'));
          await tester.ensureVisible(iniciar);
          await tester.pumpAndSettle();
          await tester.tap(iniciar);
          expect(pedido, (mesCalendario: 9, semana: 4, dia: 3));
          expect(cursoPedido, 'curso_0_2');
          final ver = find.byKey(const Key('boton_ver_palabras_do_curso'));
          await tester.ensureVisible(ver);
          await tester.pumpAndSettle();
          expect(
              find.descendant(
                  of: ver,
                  matching: find.text(lang == AppLanguage.gl
                      ? 'Ver as 4.000 palabras'
                      : 'Ver las 4.000 palabras')),
              findsOneWidget);
          await tester.tap(ver);
          expect(verPalabras, 1);
          expect(erroresDe(tester), isEmpty);
        });

        testWidgets('en xullo di que é o primeiro día, e ensina ese',
            (tester) async {
          await pintar(
            tester,
            enLista(TarxetaHoxeNaAula(
              programa: programa,
              cursoId: 'curso_0_2',
              onCambiarCurso: (_) {},
              language: lang,
              agora: DateTime(2026, 7, 15),
              onIniciarAsemblea: (_, __) {},
              onVerPalabras: () {},
            )),
            escala: escala,
          );
          expect(
              find.text(lang == AppLanguage.gl
                  ? 'O PRIMEIRO DÍA DO CURSO · RITMO TPR'
                  : 'EL PRIMER DÍA DEL CURSO · RITMO TPR'),
              findsOneWidget);
          compruebaPalabras(find.byKey(const Key('tarxeta_hoxe_na_aula')),
              curso.planDoDia(9, 1, 1)!, lang);
          expect(erroresDe(tester), isEmpty);
        });

        testWidgets('o venres: ningunha nova e as vinte en reto',
            (tester) async {
          await pintar(
            tester,
            enLista(TarxetaHoxeNaAula(
              programa: programa,
              cursoId: 'curso_0_2',
              onCambiarCurso: (_) {},
              language: lang,
              agora: DateTime(2026, 9, 25),
              onIniciarAsemblea: (_, __) {},
              onVerPalabras: () {},
            )),
            escala: escala,
          );
          final plan = curso.planDoDia(9, 4, 5)!;
          expect(plan.newWords, isEmpty);
          expect(plan.reviewWords, hasLength(20));
          final tarxeta = find.byKey(const Key('tarxeta_hoxe_na_aula'));
          compruebaPalabras(tarxeta, plan, lang);
          // As vinte, por bloques: o reto xógase así.
          for (final p in plan.reviewWords) {
            expect(
                find.descendant(
                    of: tarxeta, matching: find.textContaining(p.en)),
                findsWidgets,
                reason: p.en);
          }
          expect(erroresDe(tester), isEmpty);
        });

        testWidgets('elixir outro curso trae as palabras DESE curso',
            (tester) async {
          var seleccionado = 'curso_0_2';
          String? cursoPedido;
          await pintar(
            tester,
            StatefulBuilder(
              builder: (context, setState) => enLista(TarxetaHoxeNaAula(
                programa: programa,
                cursoId: seleccionado,
                onCambiarCurso: (c) => setState(() => seleccionado = c),
                language: lang,
                agora: miercoles,
                onIniciarAsemblea: (_, c) => cursoPedido = c,
                onVerPalabras: () {},
              )),
            ),
            escala: escala,
          );
          final tarxeta = find.byKey(const Key('tarxeta_hoxe_na_aula'));
          for (final id in ['curso_4_5', 'curso_2_3', 'curso_5_6']) {
            final chip = find.byKey(ValueKey('hoxe_curso_$id'));
            await tester.ensureVisible(chip);
            await tester.pumpAndSettle();
            await tester.tap(chip);
            await tester.pumpAndSettle();
            expect(seleccionado, id);
            compruebaPalabras(
                tarxeta, programa.curso(id)!.planDoDia(9, 4, 3)!, lang);
            final iniciar = find.byKey(const Key('boton_asemblea_de_hoxe'));
            await tester.ensureVisible(iniciar);
            await tester.pumpAndSettle();
            await tester.tap(iniciar);
            expect(cursoPedido, id);
            expect(erroresDe(tester), isEmpty, reason: id);
          }
        });
      });

      testWidgets('A folla das 4.000: os números contados, en $etiqueta',
          (tester) async {
        var pechada = false;
        await pintar(
          tester,
          Scaffold(
            body: ProxeccionDoCurso(
              programa: programa,
              language: lang,
              onPechar: () => pechada = true,
            ),
          ),
          escala: escala,
        );
        final gl = lang == AppLanguage.gl;
        expect(
            find.text(gl
                ? 'PROXECCIÓN LÉXICA · 4.000 PALABRAS DE 0 A 6 ANOS'
                : 'PROYECCIÓN LÉXICA · 4.000 PALABRAS DE 0 A 6 AÑOS'),
            findsOneWidget);
        expect(
            find.textContaining(gl
                ? '5 palabras novas ao día × 4 días = 20 por semana'
                : '5 palabras nuevas al día × 4 días = 20 por semana'),
            findsOneWidget);
        expect(find.textContaining('20 × 4 semanas = 80'), findsOneWidget);
        expect(find.textContaining('80 × 10 meses = 800 palabras'),
            findsOneWidget);
        expect(find.textContaining('800 × 5 cursos = 4.000 palabras'),
            findsOneWidget);
        expect(erroresDe(tester), isEmpty,
            reason: 'A folla das 4.000 desborda en $etiqueta.');

        // Baixando: os cinco cursos, as cinco categorías co seu número, as
        // fontes e pechar.
        final lista = find.byType(Scrollable).first;
        for (final c in programa.cursos) {
          final fila = find.textContaining(
              '${c.etiqueta.resolve(lang)} '
              '800 palabras · trimestres 320 · 240 · 240',
              skipOffstage: false);
          // Sin `skipOffstage`, una fila que asoma justo por debajo del borde
          // no cuenta como encontrada y el arrastre la salta.
          await tester.scrollUntilVisible(fila, 150, scrollable: lista);
          await tester.pumpAndSettle();
          expect(fila, findsOneWidget, reason: c.id);
        }
        for (final n in ['1.400', '1.000', '800', '480', '320']) {
          final fila = find.textContaining(RegExp('^$n palabras · [^t]'));
          await tester.scrollUntilVisible(fila, 150, scrollable: lista);
          expect(fila, findsOneWidget, reason: n);
        }
        final fontes = find.byKey(const Key('proxeccion_fontes'));
        await tester.scrollUntilVisible(fontes, 150, scrollable: lista);
        expect(
            tester.widget<Text>(fontes).data,
            gl
                ? contains('non normas deses inventarios')
                : contains('no normas de esos inventarios'));
        final pechar = find.text(gl ? 'Pechar' : 'Cerrar');
        await tester.scrollUntilVisible(pechar, 150, scrollable: lista);
        await tester.tap(pechar);
        expect(pechada, isTrue);
        expect(erroresDe(tester), isEmpty);
      });

      group('A tarxeta do inglés na casa, en $etiqueta', () {
        testWidgets('as MESMAS palabras que a escola ese día, e cabe',
            (tester) async {
          var xogos = 0;
          await pintar(
            tester,
            enLista(TarxetaInglesDeHoxeFogar(
              programa: programa,
              cursoId: 'curso_0_2',
              onCambiarCurso: (_) {},
              language: lang,
              audioService: MockOfflineAudioService(),
              agora: miercoles,
              onVerXogos: () => xogos++,
            )),
            escala: escala,
          );
          final tarxeta = find.byKey(const Key('tarxeta_ingles_de_hoxe_fogar'));
          expect(tarxeta, findsOneWidget);
          final plan = curso.planDoDia(9, 4, 3)!;
          compruebaPalabras(tarxeta, plan, lang);
          // A dinámica de CASA dese día, non a da aula.
          expect(
              find.descendant(
                  of: tarxeta,
                  matching: find
                      .text(curso.modelo.dia(3)!.dinamicaFogar.resolve(lang))),
              findsOneWidget);
          expect(find.byKey(const Key('ingles_fogar_prevista')), findsNothing);
          expect(erroresDe(tester), isEmpty,
              reason: 'A tarxeta da casa desborda en $etiqueta.');

          final boton = find.byKey(const Key('boton_xogos_fogar_desde_ingles'));
          await tester.ensureVisible(boton);
          await tester.pumpAndSettle();
          await tester.tap(boton);
          expect(xogos, 1);
          expect(erroresDe(tester), isEmpty);
        });

        testWidgets('en agosto avisa de que son as do primeiro día',
            (tester) async {
          await pintar(
            tester,
            enLista(TarxetaInglesDeHoxeFogar(
              programa: programa,
              cursoId: 'curso_0_2',
              onCambiarCurso: (_) {},
              language: lang,
              agora: DateTime(2026, 8, 3),
              onVerXogos: () {},
            )),
            escala: escala,
          );
          expect(
              find.byKey(const Key('ingles_fogar_prevista')), findsOneWidget);
          compruebaPalabras(
              find.byKey(const Key('tarxeta_ingles_de_hoxe_fogar')),
              curso.planDoDia(9, 1, 1)!,
              lang);
          expect(erroresDe(tester), isEmpty);
        });

        testWidgets('a crianza doutro curso ve as palabras DESE curso',
            (tester) async {
          var seleccionado = 'curso_0_2';
          await pintar(
            tester,
            StatefulBuilder(
              builder: (context, setState) => enLista(TarxetaInglesDeHoxeFogar(
                programa: programa,
                cursoId: seleccionado,
                onCambiarCurso: (c) => setState(() => seleccionado = c),
                language: lang,
                agora: miercoles,
                onVerXogos: () {},
              )),
            ),
            escala: escala,
          );
          final tarxeta = find.byKey(const Key('tarxeta_ingles_de_hoxe_fogar'));
          for (final id in ['curso_5_6', 'curso_3_4']) {
            final chip = find.byKey(ValueKey('fogar_curso_$id'));
            await tester.ensureVisible(chip);
            await tester.pumpAndSettle();
            await tester.tap(chip);
            await tester.pumpAndSettle();
            expect(seleccionado, id);
            compruebaPalabras(
                tarxeta, programa.curso(id)!.planDoDia(9, 4, 3)!, lang);
            expect(erroresDe(tester), isEmpty, reason: id);
          }
        });
      });

      testWidgets(
          'O calendario do aula: as palabras do día que marca a tira, en $etiqueta',
          (tester) async {
        // Outubro, por índice: o calendario abre polo mes de hoxe e o test non
        // pode depender da data en que se corra.
        await pintar(
          tester,
          CalendarioScreen(
            store: store,
            contenido: contenido,
            repository: repo,
            audioService: MockOfflineAudioService(),
            initialLanguage: lang,
            esDocenteInicial: true,
            mesInicialIndex: 1,
          ),
          escala: escala,
        );
        final lista = find
            .descendant(
                of: find.byKey(const Key('paginas_meses')),
                matching: find.byType(Scrollable))
            .first;
        final bloque = find.byKey(const ValueKey('palabras_do_dia_aula_10'));
        await tester.scrollUntilVisible(bloque, 200, scrollable: lista);
        await tester.pumpAndSettle();
        expect(bloque, findsOneWidget);

        // A tira abre polo día de hoxe; as palabras son as dese día.
        final hoxe = ProgresionDoMes.hoxe();
        compruebaPalabras(
            bloque, curso.planDoDia(10, hoxe.semana, hoxe.dia)!, lang);
        expect(erroresDe(tester), isEmpty,
            reason: 'O bloque de palabras desborda en $etiqueta.');

        // E se a docente toca outro día, as palabras cambian con el.
        final outroDia = hoxe.dia == 2 ? 4 : 2;
        final pastilla = find.byKey(ValueKey('cal_dia_$outroDia'));
        await tester.ensureVisible(pastilla);
        await tester.pumpAndSettle();
        await tester.tap(pastilla);
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(bloque, 200, scrollable: lista);
        await tester.pumpAndSettle();
        compruebaPalabras(
            bloque, curso.planDoDia(10, hoxe.semana, outroDia)!, lang);
        expect(erroresDe(tester), isEmpty);
      });
    }

    testWidgets(
        'O calendario en modo familia: as palabras do día na casa, en ${lang.code}',
        (tester) async {
      // A 520 de ancho e non a 360: a tarxeta do día na casa, que vai xusto
      // enriba deste bloque, xa desbordaba a 360 en `main` antes deste cambio
      // (comprobado cun test sobre `main`). Aquí mírase QUE palabras saen; que
      // o bloque cabe a 360, co ancho que ten nesta pantalla, mídese no grupo
      // «Os 200 días do curso».
      await pintar(
        tester,
        CalendarioScreen(
          store: store,
          contenido: contenido,
          repository: repo,
          audioService: MockOfflineAudioService(),
          initialLanguage: lang,
          esDocenteInicial: false,
          mesInicialIndex: 1,
        ),
        tamano: const Size(520, 2600),
      );
      final lista = find
          .descendant(
              of: find.byKey(const Key('paginas_meses')),
              matching: find.byType(Scrollable))
          .first;
      final bloque = find.byKey(const Key('palabras_do_dia_fogar'));
      await tester.scrollUntilVisible(bloque, 200, scrollable: lista);
      await tester.pumpAndSettle();
      expect(bloque, findsOneWidget);
      final hoxe = ProgresionDoMes.hoxe();
      compruebaPalabras(
          bloque, curso.planDoDia(10, hoxe.semana, hoxe.dia)!, lang);
      // A dinámica de CASA dese día.
      expect(
          find.descendant(
              of: bloque,
              matching: find.text(
                  curso.modelo.dia(hoxe.dia)!.dinamicaFogar.resolve(lang))),
          findsOneWidget);
      expect(erroresDe(tester), isEmpty);
    });

    testWidgets(
        'O calendario da casa (Portal Familias): as palabras do día elixido, en ${lang.code}',
        (tester) async {
      // A 400×2600, como os demais tests desta pantalla: o que se mide aquí é
      // QUE palabras saen, non se caben. O que se engadiu —PalabrasDoDia— xa
      // se mide a 360×640 e con texto grande nas tarxetas de arriba.
      await pintar(
        tester,
        CalendarioFogarScreen(
          repository: repo,
          store: store,
          initialLanguage: lang,
          audioService: MockOfflineAudioService(),
        ),
        tamano: const Size(400, 2600),
      );
      final bloque = find.byKey(const Key('palabras_do_dia_calendario_fogar'));
      final lista = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(bloque, 200, scrollable: lista);
      await tester.pumpAndSettle();
      expect(bloque, findsOneWidget);
      // O calendario da casa abre por setembro e polo día de hoxe.
      final hoxe = ProgresionDoMes.hoxe();
      compruebaPalabras(
          bloque, curso.planDoDia(9, hoxe.semana, hoxe.dia)!, lang);
      expect(erroresDe(tester), isEmpty);
    });

    testWidgets(
        'O portal docente: «Iniciar asemblea de hoxe» abre a asemblea DE HOXE, en ${lang.code}',
        (tester) async {
      await pintar(
        tester,
        PortalDocentesScreen(
          repository: repo,
          premios: PremiosRepository(),
          calendario: store,
          audioService: MockOfflineAudioService(),
          currentLanguage: lang,
          onToggleLanguage: () {},
        ),
        tamano: const Size(400, 900),
      );
      final hoxe = diaDoCursoParaHoxe().dia;
      final tarxeta = find.byKey(const Key('tarxeta_hoxe_na_aula'));
      expect(tarxeta, findsOneWidget);
      compruebaPalabras(tarxeta,
          curso.planDoDia(hoxe.mesCalendario, hoxe.semana, hoxe.dia)!, lang);

      // «Ver as 4.000 palabras» abre a folla cos números contados.
      final ver = find.byKey(const Key('boton_ver_palabras_do_curso'));
      await tester.ensureVisible(ver);
      await tester.pumpAndSettle();
      await tester.tap(ver);
      await tester.pumpAndSettle();
      expect(find.byType(ProxeccionDoCurso), findsOneWidget);
      expect(erroresDe(tester), isEmpty);
      final lista = find
          .descendant(
              of: find.byType(ProxeccionDoCurso),
              matching: find.byType(Scrollable))
          .first;
      final pechar = find.descendant(
          of: find.byType(ProxeccionDoCurso),
          matching: find.text(lang == AppLanguage.gl ? 'Pechar' : 'Cerrar'));
      await tester.scrollUntilVisible(pechar, 200, scrollable: lista);
      await tester.pumpAndSettle();
      await tester.tap(pechar);
      await tester.pumpAndSettle();
      expect(find.byType(ProxeccionDoCurso), findsNothing);

      // «Iniciar asemblea de hoxe»: o curso elíxese na tarxeta e abre a
      // asemblea DESE grupo, ese día. Un curso de cada ciclo: o de 1.º leva
      // material e canción, o de 2.º non.
      for (final (clave, cursoId) in [
        ('1c_${TramoPrimeiroCiclo.lactantes0a2.clave}', 'curso_0_2'),
        ('2c_${NivelEducativoSegundoCiclo.infantil4.clave}', 'curso_3_4'),
      ]) {
        final chip = find.byKey(ValueKey('hoxe_curso_$cursoId'));
        await tester.ensureVisible(chip);
        await tester.pumpAndSettle();
        await tester.tap(chip);
        await tester.pumpAndSettle();
        compruebaPalabras(
            tarxeta,
            programa
                .curso(cursoId)!
                .planDoDia(hoxe.mesCalendario, hoxe.semana, hoxe.dia)!,
            lang);
        final iniciar = find.byKey(const Key('boton_asemblea_de_hoxe'));
        await tester.ensureVisible(iniciar);
        await tester.pumpAndSettle();
        await tester.tap(iniciar);
        await tester.pumpAndSettle();
        expect(erroresDe(tester), isEmpty, reason: clave);
        expect(find.byType(AsambleaPlayerScreen), findsOneWidget);
        final player = tester
            .widget<AsambleaPlayerScreen>(find.byType(AsambleaPlayerScreen));
        expect(player.dia?.semana, hoxe.semana, reason: clave);
        expect(player.dia?.dia, hoxe.dia, reason: clave);
        expect(player.semana?.numero, hoxe.semana, reason: clave);
        expect(
            player.subtitulo,
            contains('S${hoxe.semana} '
                '${PalabrasDoDia.nomesDosDias[hoxe.dia - 1].resolve(lang)}'),
            reason: clave);
        // O reprodutor leva o seu propio botón atrás: vólvese polo Navigator.
        tester.state<NavigatorState>(find.byType(Navigator).first).pop();
        await tester.pumpAndSettle();
        expect(find.byType(AsambleaPlayerScreen), findsNothing);
      }
    });

    testWidgets(
        'O portal das familias leva o inglés de hoxe, co día de hoxe, en ${lang.code}',
        (tester) async {
      await pintar(
        tester,
        PortalFamiliasScreen(
          repository: repo,
          premios: PremiosRepository(),
          calendario: store,
          audioService: MockOfflineAudioService(),
          currentLanguage: lang,
          onToggleLanguage: () {},
        ),
        tamano: const Size(400, 2600),
      );
      final tarxeta = find.byKey(const Key('tarxeta_ingles_de_hoxe_fogar'));
      await tester.scrollUntilVisible(tarxeta, 200,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      expect(tarxeta, findsOneWidget);
      final hoxe = diaDoCursoParaHoxe().dia;
      compruebaPalabras(tarxeta,
          curso.planDoDia(hoxe.mesCalendario, hoxe.semana, hoxe.dia)!, lang);
    });
  }
}
