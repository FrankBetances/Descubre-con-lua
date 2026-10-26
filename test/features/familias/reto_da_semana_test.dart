import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/models/hogar_model.dart';
import 'package:descubre_con_lua/data/models/unidade_do_mes_model.dart';
import 'package:descubre_con_lua/features/familias/widgets/reto_da_semana.dart';

/// F5: la guía de casa de cada mes y su reto de la semana.
void main() {
  const cursos = [
    'curso_0_2',
    'curso_2_3',
    'curso_3_4',
    'curso_4_5',
    'curso_5_6'
  ];

  UnidadeDoMes ler(String curso, int orden) => UnidadeDoMes.fromJson(
        jsonDecode(File('assets/content/unidades_mes/$curso/'
                'unidade.${orden.toString().padLeft(2, '0')}.json')
            .readAsStringSync()) as Map<String, dynamic>,
      );

  test('as 50 unidades traen catro retos, en gl e es, coa frase en inglés', () {
    for (final curso in cursos) {
      for (var orden = 1; orden <= 10; orden++) {
        final h = ler(curso, orden).hogar;
        expect(h, isNotNull, reason: '$curso.$orden sen hogar');
        expect([for (final r in h!.retos) r.semana], [1, 2, 3, 4]);
        for (final r in h.retos) {
          expect(r.frase.en, isNotEmpty);
          for (final t in [
            r.queFacer,
            r.mans,
            r.nonPedir,
            r.recastSilencio,
            r.recastLinguaCasa,
            r.recastUnhaPalabra
          ]) {
            expect(t.hasParity, isTrue, reason: '${r.id}: falta gl ou es');
          }
        }
        expect(h.momento.hasParity, isTrue);
        expect(h.xogo ?? h.steam, isNotNull, reason: '$curso.$orden sen xogo');
        // A semana 5 dun mes longo é a 4.ª.
        expect(h.daSemana(5)?.semana, 4);
      }
    }
  });

  test('a guía estable ten dez puntos e a da idade oito tramos', () {
    final g = GuiaDeCasa.fromRaw(
      File(GuiaDeCasa.guiaAsset).readAsStringSync(),
      File(GuiaDeCasa.idadeAsset).readAsStringSync(),
    );
    expect(g.puntos, hasLength(10));
    expect(g.tramos, hasLength(8));
    for (final c in cursos) {
      expect(g.doCurso(c), isNotEmpty, reason: '$c sen tramo');
    }
    expect(g.puntos.firstWhere((p) => p.clave == 'ferramentas').exemplos,
        hasLength(4));
  });

  for (final lang in [AppLanguage.gl, AppLanguage.es]) {
    for (final escala in [1.0, 1.8]) {
      for (final curso in cursos) {
        testWidgets(
            'o reto cabe a 360 px en ${lang.code}, escala $escala, $curso',
            (tester) async {
          tester.view.physicalSize = const Size(360, 640);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);
          final h = ler(curso, 3).hogar!;
          await tester.pumpWidget(MaterialApp(
            theme: AppTheme.lightTheme,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(escala)),
              child: child!,
            ),
            home: Scaffold(
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [RetoDaSemana(hogar: h, semana: 4, language: lang)],
              ),
            ),
          ));
          await tester.pump();
          expect(find.byKey(const Key('reto_da_semana')), findsOneWidget);
          expect(find.textContaining(h.retos[3].queFacer.resolve(lang)),
              findsOneWidget);
          await tester.ensureVisible(find.byKey(const Key('reto_recast')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('reto_recast')));
          await tester.pumpAndSettle();
          expect(find.textContaining(h.retos[3].recastLinguaCasa.resolve(lang)),
              findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
