import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/models/leccion_model.dart';
import 'package:descubre_con_lua/data/models/xogos_fogar_model.dart';
import 'package:descubre_con_lua/features/leccions/views/camino_do_curso_screen.dart';
import 'package:descubre_con_lua/features/leccions/views/gramatica_screen.dart';
import 'package:descubre_con_lua/features/leccions/widgets/leccion_da_semana.dart';

/// P11 (Frank 27/10/2026): lecciones de una semana por grupo, con una sola
/// fuente, el plan curricular. Ninguna semana vacía, ninguna palabra que no
/// salga del plan y nada del plan que se quede sin enseñar.
void main() {
  final raw = File(Leccions.assetPath).readAsStringSync();
  final leccions = Leccions.fromRaw(raw);
  const cursos = [
    'curso_0_2',
    'curso_2_3',
    'curso_3_4',
    'curso_4_5',
    'curso_5_6',
  ];
  const meses = [9, 10, 11, 12, 1, 2, 3, 4, 5, 6];

  String norm(String s) =>
      s.replaceAll(RegExp(r'[!.?¡¿]'), '').trim().toLowerCase();

  // Todo lo que el plan enseña, por unidad.
  final plan = <String, Set<String>>{};
  for (final f in [
    'assets/content/curriculo/tramo_18_36.json',
    'assets/content/curriculo/tramo_3_6.json',
  ]) {
    void andar(Object? n) {
      if (n is Map) {
        final id = n['id'];
        if (id is String &&
            RegExp(r'^T[23]\.U[0-9.]+$').hasMatch(id) &&
            n['vocabulario'] is List) {
          plan[id] = {
            for (final k in [
              'vocabulario',
              'accionsTPR',
              'formulas',
              'estructuras'
            ])
              for (final x in (n[k] as List? ?? const []))
                if (x is Map && x['en'] is String) norm(x['en'] as String),
          };
        }
        n.values.forEach(andar);
      } else if (n is List) {
        n.forEach(andar);
      }
    }

    andar(jsonDecode(File(f).readAsStringSync()));
  }

  test('cada semana do curso, dos cinco grupos, ten a súa lección', () {
    var total = 0;
    for (final c in cursos) {
      for (final m in meses) {
        for (var s = 1; s <= 4; s++) {
          final l = leccions.da(c, m, s);
          expect(l, isNotNull, reason: '$c $m $s');
          total++;
        }
      }
    }
    expect(total, 200);
  });

  test('ningunha palabra se ensina dúas veces e cada unha di que é', () {
    for (final c in cursos) {
      final vistas = <String>{};
      for (final u in leccions.unidades[c]!) {
        for (final l in u.leccions) {
          expect(l.repaso ? l.repasa : l.novas, isNotEmpty, reason: l.id);
          for (final p in l.novas) {
            expect(vistas.add(norm(p.en)), isTrue, reason: '${l.id}: ${p.en}');
            expect(p.que, isNotNull, reason: '${l.id}: ${p.en}');
          }
          expect(l.dias, hasLength(5), reason: l.id);
        }
      }
    }
  });

  // O-20261028-7: lo que el plan enseña sale en la primera edad que usa la
  // unidad; la siguiente no lo repite, lo da por sabido.
  test('todo o que o plan ensina aparece no curso que o usa ou antes', () {
    final ensinado = <String>{};
    for (final c in cursos) {
      ensinado.addAll({
        for (final u in leccions.unidades[c]!)
          for (final l in u.leccions)
            for (final p in l.novas) norm(p.en),
      });
      final usadas = {
        for (final m in meses)
          if (leccions.da(c, m, 1) != null) m,
      };
      expect(usadas, hasLength(10), reason: c);
      final cal = jsonDecode(
          File('assets/content/curriculo/calendario_curricular.json')
              .readAsStringSync())['cursos'][c] as Map;
      for (final uid in cal.values.toSet()) {
        expect(plan[uid]!.difference(ensinado), isEmpty, reason: '$c $uid');
      }
    }
  });

  test(
      'progresión: 10 unidades distintas, sen reto repetido seguido, '
      '0-2 e 2-3 distintos', () {
    for (final c in cursos) {
      final us = leccions.unidades[c]!;
      expect(us, hasLength(10), reason: c);
      expect(us.map((u) => u.titulo.gl).toSet(), hasLength(10), reason: c);
      String? antes;
      for (final u in us) {
        for (final l in u.leccions) {
          expect(l.reto.frase.en, isNot(antes), reason: l.id);
          antes = l.reto.frase.en;
        }
      }
    }
    List<String> novas(String c) => [
          for (final u in leccions.unidades[c]!)
            for (final l in u.leccions)
              for (final p in l.novas) p.en,
        ];
    expect(novas('curso_0_2'), isNot(novas('curso_2_3')));
  });

  // O-20261028-7 (opción A de Frank): nada se repite entre edades ni se
  // rellena con «repaso».
  // El STEAM es el eje: cada mes tiene el suyo y los cinco días de cada
  // semana son distintos de los de cualquier otra semana del curso.
  // Cada semana dice cómo hablar: una técnica del modelo por fase, las
  // cuatro distintas en el mes.
  test('cada semana di como falar, catro técnicas distintas no mes', () {
    for (final c in cursos) {
      for (final u in leccions.unidades[c]!) {
        final t = {for (final l in u.leccions) l.comoFalarTitulo?.gl};
        expect(t, hasLength(4), reason: u.id);
        expect(t, isNot(contains(null)), reason: u.id);
      }
    }
  });

  test('cada mes co seu STEAM e ningún día repetido no curso', () {
    for (final c in cursos) {
      final vistos = <String>{};
      for (final u in leccions.unidades[c]!) {
        expect(u.steam, isNotNull, reason: u.id);
        for (final l in u.leccions) {
          for (final d in l.dias) {
            expect(vistos.add(d.texto.gl), isTrue,
                reason: '${l.id}: «${d.texto.gl}» repetido');
          }
        }
      }
    }
  });

  test('entre idades, ningún tema, palabra nova nin conto repetido', () {
    final temas = <String, String>{};
    final palabras = <String, String>{};
    final contos = <String, String>{};
    for (final c in cursos) {
      for (final u in leccions.unidades[c]!) {
        expect(temas.putIfAbsent(u.titulo.gl, () => c), c,
            reason: '«${u.titulo.gl}» en dúas idades');
        for (final l in u.leccions) {
          expect(l.repaso, isFalse, reason: '${l.id}: semana sen nada novo');
          expect(l.novas.length, greaterThanOrEqualTo(3), reason: l.id);
          for (final p in l.novas) {
            expect(palabras.putIfAbsent(norm(p.en), () => c), c,
                reason: '«${p.en}» nova en dúas idades');
          }
          if (l.conto case final k?) {
            expect(contos.putIfAbsent(k, () => l.id), l.id,
                reason: 'o conto $k, en dúas semanas');
          }
        }
      }
    }
  });

  // F7: el doble toque dice el significado; un botón sin él no hace nada.
  test('todo o inglés das leccións leva o seu significado en gl e es', () {
    for (final c in cursos) {
      for (final u in leccions.unidades[c]!) {
        for (final l in u.leccions) {
          for (final p in [...l.novas, ...l.repasa, ...l.xaSabe]) {
            expect(p.significado?.hasParity, isTrue,
                reason: '${l.id}: ${p.en}');
          }
          expect(l.reto.frase.significado?.hasParity, isTrue,
              reason: '${l.id}: ${l.reto.frase.en}');
          for (final d in l.dias.where((d) => d.en != null)) {
            expect(d.significado?.hasParity, isTrue,
                reason: '${l.id}: ${d.en}');
          }
        }
      }
    }
  });

  test('cada unidade leva o seu punto de gramática e cada semana a súa frase',
      () {
    final puntos = <int>{};
    for (final c in cursos) {
      for (final u in leccions.unidades[c]!) {
        final g = u.gramatica;
        expect(g, isNotNull, reason: u.id);
        expect(g!.n, inInclusiveRange(1, 48), reason: u.id);
        expect(g.paraFamilias?.hasParity, isTrue, reason: u.id);
        puntos.add(g.n);
        for (final l in u.leccions) {
          expect(l.fraseGramatica?.significado?.hasParity, isTrue,
              reason: l.id);
        }
      }
    }
    // O-20261028-9: las 48 unidades son para las criaturas, todas en la ruta.
    expect(puntos, hasLength(48));
  });

  testWidgets('a gramática do curso, a 360 px e escala 1.8', (tester) async {
    GramaticaDoCurso.sembrar(GramaticaDoCurso.fromRaw(
        File(GramaticaDoCurso.assetPath).readAsStringSync()));
    await tester.binding.setSurfaceSize(const Size(360, 780));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final lang in AppLanguage.deInterfaz) {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: MediaQuery(
          data: const MediaQueryData(
              size: Size(360, 780), textScaler: TextScaler.linear(1.8)),
          child: GramaticaScreen(
            key: ValueKey(lang),
            language: lang,
            audioService: MockOfflineAudioService(),
            destacado: 7,
          ),
        ),
      ));
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('gramatica_punto_1')), findsOneWidget);
      // Hasta el final de la lista, sin que nada desborde por el camino.
      for (var i = 0;
          i < 200 &&
              find
                  .byKey(const ValueKey('gramatica_punto_48'))
                  .evaluate()
                  .isEmpty;
          i++) {
        await tester.drag(
            find.byKey(const Key('gramatica')), const Offset(0, -500));
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
      expect(find.byKey(const ValueKey('gramatica_punto_48')), findsOneWidget);
      // Que se agote el temporizador del doble toque de un botón rozado.
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    }
  });

  // O-20261028-6: dónde estamos en las 48, de dónde venimos y a dónde vamos.
  test('cada unidade di a unidade de antes e a seguinte', () {
    for (final c in cursos) {
      for (final u in leccions.unidades[c]!) {
        final n = u.gramatica!.n;
        if (n > 1) expect(u.gramaticaAntes?.n, n - 1, reason: u.id);
        if (n < 48) expect(u.gramaticaDespois?.n, n + 1, reason: u.id);
      }
    }
  });

  group('Hoxe da familia (O-20261028-4/6)', () {
    setUpAll(() {
      Leccions.sembrar(leccions);
    });

    Future<void> pintar(WidgetTester tester, Size tamano, double escala,
        AppLanguage lang) async {
      await tester.binding.setSurfaceSize(tamano);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.temaFamilias,
        home: MediaQuery(
          data: MediaQueryData(
              size: tamano, textScaler: TextScaler.linear(escala)),
          child: Scaffold(
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                LeccionFamilia(
                  key: ValueKey(lang),
                  leccions: leccions,
                  cursoId: 'curso_4_5',
                  mesCalendario: 10,
                  semana: 4,
                  dia: 3,
                  language: lang,
                  audioService: MockOfflineAudioService(),
                ),
              ],
            ),
          ),
        ),
      ));
      await tester.pump();
    }

    for (final lang in AppLanguage.deInterfaz) {
      testWidgets('dónde estamos e o de hoxe, sen baixar, en ${lang.code}',
          (tester) async {
        await pintar(tester, const Size(412, 915), 1.0, lang);
        expect(tester.takeException(), isNull);
        expect(find.byKey(const Key('leccion_ruta_gramatica')), findsOneWidget);
        // Antes, ahora y después: 29, 30 y 31 en octubre de 4-5 años.
        for (final t in ['29 · B1', '30 · B1', '31 · B1']) {
          expect(find.text(t), findsOneWidget, reason: t);
        }
        // La barra es la del curso, y lo dice: tema 2, lección 4 = semana 8.
        expect(find.text('Curso: semana 8 de 40'), findsOneWidget);
        // El STEAM del mes, a la vista: el eje de la semana.
        expect(find.byKey(const Key('leccion_steam')), findsOneWidget);
        // Cómo hablar esta semana: la 4.ª, la de consolidar, el recast.
        expect(find.byKey(const Key('leccion_como_falar')), findsOneWidget);
        final hoxe = find.byKey(const Key('leccion_dias'));
        expect(tester.getRect(hoxe).bottom, lessThan(915));
        expect(find.byKey(const Key('leccion_xa_sabe')), findsOneWidget);
      });

      testWidgets('a 360 px e escala 1.8, sen desbordar, en ${lang.code}',
          (tester) async {
        await pintar(tester, const Size(360, 780), 1.8, lang);
        expect(tester.takeException(), isNull);
        // Otro día de la semana: se ve lo de ese día.
        final venres = find.byKey(const ValueKey('leccion_dia_5'));
        await tester.ensureVisible(venres);
        await tester.pump();
        await tester.tap(venres);
        await tester.pump();
        expect(tester.takeException(), isNull);
        final dia5 = leccions.unidades['curso_4_5']![1].leccions[3].dias[4];
        expect(find.text(dia5.texto.resolve(lang)), findsOneWidget);
      });
    }
  });

  for (final lang in AppLanguage.deInterfaz) {
    testWidgets('o camiño dos 10 temas, coa lección de agora, en ${lang.code}',
        (tester) async {
      final unidades = leccions.unidades['curso_4_5']!;
      expect(unidades, hasLength(10));
      final u = unidades[1];
      final l = u.leccions[3];
      await tester.binding.setSurfaceSize(const Size(412, 915));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.temaFamilias,
        home: CaminoDoCursoScreen(
          leccions: leccions,
          cursoId: 'curso_4_5',
          actual: l.id,
          language: lang,
          audioService: MockOfflineAudioService(),
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      for (final x in unidades) {
        expect(find.byKey(ValueKey('camino_${x.id}'), skipOffstage: false),
            findsOneWidget,
            reason: x.id);
      }
      // Cada tema dice qué unidad de las 48 trabaja: la 30 en octubre.
      expect(
          tester
              .widget<Text>(find.byKey(ValueKey('camino_gramatica_${u.id}')))
              .data,
          '${lang == AppLanguage.gl ? 'Unidade' : 'Unidad'} 30 de 48 · '
          'B1 · ${u.gramatica!.titulo.resolve(lang)}');
      // Solo una lección marcada como la de esta semana.
      expect(find.byKey(const Key('leccion_globo')), findsOneWidget);
      final punto = find.descendant(
          of: find.byKey(ValueKey('camino_${u.id}')),
          matching: find.byKey(const ValueKey('leccion_punto_4')));
      await tester.ensureVisible(punto);
      await tester.pumpAndSettle();
      await tester.tap(punto);
      await tester.pumpAndSettle();
      expect(find.byKey(ValueKey('camino_leccion_${l.id}')), findsOneWidget);
      for (final p in l.novas) {
        expect(find.text(p.en), findsWidgets, reason: p.en);
      }
      expect(tester.takeException(), isNull);
    });
  }

  test('o que xa coñece é o ensinado antes', () {
    // Lo de antes puede venir de la edad anterior: al empezar el curso.
    final antes = <String>{};
    for (final c in cursos) {
      for (final u in leccions.unidades[c]!) {
        for (final l in u.leccions) {
          for (final p in l.xaSabe) {
            expect(antes, contains(norm(p.en)), reason: '${l.id}: ${p.en}');
          }
          antes.addAll(l.novas.map((p) => norm(p.en)));
        }
      }
    }
  });

  group('a lección, a 360 px e escala 1.8', () {
    setUpAll(() {
      Leccions.sembrar(leccions);
      XogosFogar.sembrar(
          XogosFogar.fromRaw(File(XogosFogar.assetPath).readAsStringSync()));
    });

    for (final lang in AppLanguage.deInterfaz) {
      testWidgets('casa e aula, en ${lang.code}', (tester) async {
        await tester.binding.setSurfaceSize(const Size(360, 780));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        for (final aula in [false, true]) {
          await tester.pumpWidget(MaterialApp(
            theme: AppTheme.lightTheme,
            home: MediaQuery(
              data: const MediaQueryData(
                  size: Size(360, 780), textScaler: TextScaler.linear(1.8)),
              child: Scaffold(
                body: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    LeccionDaSemana(
                      leccions: leccions,
                      cursoId: 'curso_4_5',
                      mesCalendario: 11,
                      semana: 3,
                      language: lang,
                      audioService: MockOfflineAudioService(),
                      enAula: aula,
                    ),
                  ],
                ),
              ),
            ),
          ));
          await tester.pump();
          expect(tester.takeException(), isNull);
          expect(find.byKey(const Key('leccion_cabeceira')), findsOneWidget);
          expect(find.byKey(const Key('leccion_novas')), findsOneWidget);
          // Elegir otra lección de la unidad y volver a la de esta semana.
          final actual = leccions.da('curso_4_5', 11, 3)!.$2.numero;
          final outra =
              find.byKey(ValueKey('leccion_punto_${actual == 1 ? 2 : 1}'));
          await tester.ensureVisible(outra);
          await tester.pumpAndSettle();
          await tester.tap(outra);
          await tester.pump();
          expect(find.byKey(const Key('leccion_volver')), findsOneWidget);
          await tester.ensureVisible(find.byKey(const Key('leccion_volver')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('leccion_volver')));
          await tester.pump();
          expect(find.byKey(const Key('leccion_volver')), findsNothing);
          expect(tester.takeException(), isNull);
        }
      });
    }
  });

  test('o conto de cada lección existe entre os 100 dialogados', () {
    final ids = <String>{};
    for (final f in Directory('assets/content/biblioteca')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.contains('his_'))) {
      for (final c in jsonDecode(f.readAsStringSync()) as List) {
        ids.add((c as Map)['id'] as String);
      }
    }
    for (final c in cursos) {
      for (final u in leccions.unidades[c]!) {
        for (final l in u.leccions) {
          if (l.conto != null) expect(ids, contains(l.conto), reason: l.id);
        }
      }
    }
  });
}
