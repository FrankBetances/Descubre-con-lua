import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/storage/calendario_store.dart';
import 'package:descubre_con_lua/core/storage/local_store.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/loaders/content_asset_loader.dart';
import 'package:descubre_con_lua/data/models/progresion_model.dart';
import 'package:descubre_con_lua/data/models/tpr_curriculum_scheduler.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/calendario/widgets/asemblea_do_dia.dart';
import 'package:descubre_con_lua/features/juega/views/asamblea_player_screen.dart';
import 'package:descubre_con_lua/features/premios/premios_model.dart';
import 'package:descubre_con_lua/features/premios/premios_repository.dart';

/// M4.1: la asamblea lee su unidad. Canción, material, órdenes, fórmulas y
/// reactivación salen de la unidad del mes, y el reto TPR lleva la línea
/// para la adulta.
///
/// Se recorren las 50 en la semana 4 (la que más lleva: fórmulas y núcleo del
/// mes pasado en la apertura), en gl y es, con el texto grande y a 360×640 y
/// 360×780. Antes de M4.1, a 360×640, ya desbordaban 9 asambleas en la semana
/// 1 y 47 en la 4: ahora la fase se desplaza cuando no cabe. Lo que no
/// prueba: fuentes reales, un aparato.
void main() {
  late ContentRepository repo;
  final daUnidade = <String, Map<AppLanguage, AsembleaDaUnidade?>>{};
  final grupos = <String, GrupoDaAsemblea>{};
  const meses = [9, 10, 11, 12, 1, 2, 3, 4, 5, 6];

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
    for (final mes in meses) {
      for (final g in gruposDaAsembleaDoDia(repo, mes)) {
        final clave = '${g.clave}.$mes';
        grupos[clave] = g;
        daUnidade[clave] = {
          for (final lang in AppLanguage.deInterfaz)
            lang: await lerAsembleaDaUnidade(
                repo, cursoTprDoGrupo[g.clave], mes, lang),
        };
      }
    }
  });

  test('as 50 asembleas len a súa unidade', () {
    expect(grupos, hasLength(50));
    for (final MapEntry(key: clave, value: g) in grupos.entries) {
      final u = daUnidade[clave]![AppLanguage.gl];
      expect(u, isNotNull, reason: clave);
      final fases = g.primeiro?.fases ?? g.segundo!.fases;
      final ids = [
        for (final f in fases)
          for (final c in f.comandosL3) c.id,
      ];
      // Cada orden de la asamblea tiene su par en la unidad, con el mismo
      // inglés: la unidad no puede decir una orden y la asamblea otra.
      expect(u!.ordenes.keys, ids, reason: clave);
      for (final f in fases) {
        for (final c in f.comandosL3) {
          expect(u.ordenes[c.id]!.en, c.textoIngles, reason: '$clave ${c.id}');
        }
      }
      expect(u.material, isNotNull, reason: '$clave: sin material');
      final cancion = g.primeiro?.cancionDoMes;
      expect(u.cancion,
          (cancion == null || cancion.trim().isEmpty) ? null : cancion,
          reason: clave);
      final curso = cursoTprDoGrupo[g.clave]!;
      final desde34 = curso != 'curso_0_2' && curso != 'curso_2_3';
      expect(u.formulas.isNotEmpty, desde34, reason: clave);
      expect(u.reactivar.isNotEmpty, !clave.endsWith('.9'), reason: clave);
    }
  });

  test('cada tramo trae a súa liña para a adulta, sen pedir repetir', () {
    for (final clave in [
      'primeiro_ciclo.0_2',
      'primeiro_ciclo.2_3',
      'segundo_ciclo.4',
      'segundo_ciclo.5',
      'segundo_ciclo.6',
    ]) {
      final linea = repo.getProgresionSync(clave)!.lineaAdulta;
      expect(linea?.hasParity, isTrue, reason: clave);
      expect(linea!.gl.toLowerCase(), isNot(contains('xesto')),
          reason: 'A semana 4 dá as ordes sen xesto: $clave');
    }
  });

  Future<void> abrir(WidgetTester tester, String clave, AppLanguage lang,
      int semana, double escala,
      {bool conUnidade = true,
      double alto = 780,
      bool conNota = false,
      PremiosRepository? premios,
      CalendarioStore? calendario}) async {
    final g = grupos[clave]!;
    final u = conUnidade ? daUnidade[clave]![lang] : null;
    final ProgresionDoMes p = repo.getProgresionSync(g.claveProgresion)!;
    final dia = p.dia(semana, 1)!;
    final fases = g.primeiro?.fases ?? g.segundo!.fases;
    tester.view.physicalSize = Size(360, alto);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MediaQuery(
      data: MediaQueryData(
          size: Size(360, alto), textScaler: TextScaler.linear(escala)),
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: AsambleaPlayerScreen(
          // Una clave por apertura: sin ella el reproductor reutiliza el
          // estado (página y fases) del anterior.
          key: ValueKey('$clave.$semana.$conUnidade'),
          fases: dia.aplicarA(fases),
          subtitulo: clave,
          language: lang,
          material: conUnidade
              ? u?.material
              : g.primeiro?.materialDoMes.resolve(lang),
          cancion: conUnidade ? u?.cancion : g.primeiro?.cancionDoMes,
          centroInteres: (g.primeiro?.centroInteres ?? g.segundo!.centroInteres)
              .resolve(lang),
          dia: dia,
          semana: p.semana(semana),
          lineaAdulta: conUnidade ? p.lineaAdulta?.resolve(lang) : null,
          ordenes: u?.ordenes ?? const {},
          formulas: u?.formulas ?? const [],
          reactivar: u?.reactivar ?? const [],
          notaParaCasas:
              conNota ? notaDaAsemblea(u, g.segundo, lang, null) : null,
          premios: premios,
          calendario: calendario,
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> seguinte(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('player_fase_seguinte')));
    await tester.pumpAndSettle();
  }

  /// Las pantallas que desbordan, de la apertura al núcleo (incluido).
  Future<Set<int>> desbordes(WidgetTester tester, String clave,
      AppLanguage lang, double escala, double alto) async {
    await abrir(tester, clave, lang, 4, escala, alto: alto);
    final fora = <int>{};
    for (var i = 0; i < 6; i++) {
      if (tester.takeException() != null) fora.add(i);
      // La fase núcleo enseña el día: ahí se para, con y sin unidad.
      if (find
          .byKey(const ValueKey('dia_no_reproductor'))
          .evaluate()
          .isNotEmpty) {
        break;
      }
      await seguinte(tester);
    }
    return fora;
  }

  for (final lang in AppLanguage.deInterfaz) {
    for (final escala in [1.0, 1.8]) {
      // 640: el móvil barato de la escuela. Antes de M4.1 ahí desbordaban 47
      // asambleas en la semana 4; ahora la fase se desplaza si no cabe.
      for (final alto in [640.0, 780.0]) {
        testWidgets(
            'as 50 na semana 4, ${lang.code} a escala $escala en 360×'
            '${alto.toInt()}: ningunha pantalla desborda', (tester) async {
          for (final clave in grupos.keys) {
            expect(await desbordes(tester, clave, lang, escala, alto), isEmpty,
                reason: clave);
          }
        });
      }

      testWidgets(
          'as 50 na semana 4, ${lang.code} a escala $escala: liña da adulta '
          'no reto e o do mes na apertura', (tester) async {
        for (final clave in grupos.keys) {
          final u = daUnidade[clave]![lang]!;
          await abrir(tester, clave, lang, 4, escala);
          tester.takeException();
          expect(find.byKey(const ValueKey('apertura_formulas')),
              u.formulas.isEmpty ? findsNothing : findsOneWidget,
              reason: clave);
          expect(find.byKey(const ValueKey('apertura_reactivar')),
              u.reactivar.isEmpty ? findsNothing : findsOneWidget,
              reason: clave);
          for (var i = 0; i < 6; i++) {
            if (find
                .byKey(const ValueKey('linea_adulta'))
                .evaluate()
                .isNotEmpty) {
              break;
            }
            await seguinte(tester);
            tester.takeException();
          }
          expect(find.byKey(const ValueKey('linea_adulta')), findsOneWidget,
              reason: clave);
          // M4.2: al lado de la línea, la espera visible.
          expect(find.byKey(const ValueKey('espera_visible')), findsOneWidget,
              reason: clave);
        }
      });
    }

    // M4.3: «Rematar» acaba en la nota para las casas, que sale de la unidad
    // del mes. En 2.º ciclo lleva además la micro-rutina de casa.
    for (final clave in ['1c_0_2.10', '2c_4_infantil.10']) {
      testWidgets('Rematar abre a nota de $clave (${lang.code})',
          (tester) async {
        await abrir(tester, clave, lang, 1, 1.0, conNota: true);
        for (var i = 0; i < 6; i++) {
          if (find
              .byKey(const ValueKey('nota_para_casas'))
              .evaluate()
              .isNotEmpty) {
            break;
          }
          await seguinte(tester);
        }
        expect(find.byKey(const ValueKey('nota_para_casas')), findsOneWidget);
        expect(find.byType(AsambleaPlayerScreen), findsNothing,
            reason: 'a nota substitúe o reprodutor, non se apila');
        final g = grupos[clave]!;
        final u = daUnidade[clave]![lang]!;
        expect(find.text(u.centroInteres.resolve(lang)), findsWidgets);
        for (final peza in u.nucleo) {
          expect(find.text(peza.en), findsWidgets, reason: peza.en);
        }
        final rutina = g.segundo?.microRutinaHogar;
        if (rutina == null) {
          expect(
              find.textContaining(
                  lang == AppLanguage.gl ? 'PARA FACER' : 'PARA HACER'),
              findsNothing);
        } else {
          expect(find.text(rutina.titulo.resolve(lang)), findsOneWidget);
        }
      });
    }

    // M4.3: la de seis pasos era la única que contaba la asamblea. Al
    // retirarla, «Rematar» de esta tiene que sumar a la docente, no a la
    // familia, y marcar el día del aula.
    testWidgets('Rematar conta a asemblea para a docente (${lang.code})',
        (tester) async {
      final dir = Directory.systemTemp.createTempSync('rematar_conta');
      addTearDown(() => dir.deleteSync(recursive: true));
      final premios = PremiosRepository(
        store:
            LocalStore(fileName: 'premios.json', overrideDirectory: dir.path),
        ahora: () => DateTime(2026, 10, 20),
      );
      final calendario = CalendarioStore(overrideDirectory: dir.path);
      await tester.runAsync(() async {
        await premios.cargar();
        await calendario.cargar();
      });
      await abrir(tester, '1c_0_2.10', lang, 1, 1.0,
          conNota: true, premios: premios, calendario: calendario);
      final rematar =
          find.text(lang == AppLanguage.gl ? 'Rematar' : 'Terminar');
      while (rematar.evaluate().isEmpty) {
        await seguinte(tester);
      }
      // Dos toques seguidos: el segundo no puede contar otra vez.
      await tester.tap(rematar);
      await tester.tap(rematar, warnIfMissed: false);
      // Lo que se guarda es E/S de verdad: necesita tiempo real.
      for (var i = 0;
          i < 20 &&
              find.byKey(const ValueKey('nota_para_casas')).evaluate().isEmpty;
          i++) {
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 50)));
        await tester.pump();
      }
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('nota_para_casas')), findsOneWidget);
      expect(premios.progresoDe(Perfil.docente).asambleas, 1);
      expect(premios.progresoDe(Perfil.familia).asambleas, 0);
      expect(calendario.contadores.diasAula, 1);
      expect(
          find.textContaining(lang == AppLanguage.gl
              ? 'Asemblea completada'
              : 'Asamblea completada'),
          findsOneWidget);
    });

    testWidgets('na semana 3 non volve o mes pasado (${lang.code})',
        (tester) async {
      await abrir(tester, '2c_6_infantil.10', lang, 3, 1.0);
      expect(find.byKey(const ValueKey('apertura_reactivar')), findsNothing);
      expect(find.byKey(const ValueKey('apertura_formulas')), findsOneWidget);
    });
  }
}
