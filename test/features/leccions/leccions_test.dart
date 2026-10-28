import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/models/leccion_model.dart';
import 'package:descubre_con_lua/data/models/xogos_fogar_model.dart';
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

  test('todo o que o plan ensina aparece no curso que o usa', () {
    for (final c in cursos) {
      final ensinado = {
        for (final u in leccions.unidades[c]!)
          for (final l in u.leccions)
            for (final p in l.novas) norm(p.en),
      };
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

  test('o que xa coñece é o ensinado antes', () {
    for (final c in cursos) {
      final antes = <String>{};
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
