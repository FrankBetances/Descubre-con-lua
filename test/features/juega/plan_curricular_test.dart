import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/models/unidade_curricular_model.dart';
import 'package:descubre_con_lua/features/juega/widgets/tarxeta_curricular.dart';

/// F11: las 12 unidades del plan curricular de Frank y qué unidad toca en
/// cada curso y mes. Cada uno de los 50 meses tiene la suya, y la tarjeta se
/// pinta en gl y es con texto normal y grande. Lo que no prueba: el aparato.
void main() {
  late PlanCurricular plan;

  setUpAll(() {
    plan = PlanCurricular.fromRaw([
      for (final f in PlanCurricular.ficheiros) File(f).readAsStringSync(),
    ], File(PlanCurricular.calendarioAsset).readAsStringSync());
  });

  const cursos = [
    'curso_0_2',
    'curso_2_3',
    'curso_3_4',
    'curso_4_5',
    'curso_5_6'
  ];
  const meses = [9, 10, 11, 12, 1, 2, 3, 4, 5, 6];

  test(
      'os 50 meses teñen a súa unidade do plan, cos seus obxectivos e vocabulario',
      () {
    for (final c in cursos) {
      for (final m in meses) {
        final u = plan.para(c, m);
        expect(u, isNotNull, reason: '$c, mes $m');
        expect(u!.objetivos, isNotEmpty, reason: u.id);
        expect(u.vocabulario.length, greaterThanOrEqualTo(4), reason: u.id);
        for (final v in u.vocabulario) {
          expect(v.significado, isNotNull, reason: '${u.id}: ${v.en}');
        }
      }
    }
    // P8: en 3-6 años, media unidad por curso.
    expect(plan.para('curso_3_4', 9)!.id, 'T3.U3.1');
    expect(plan.para('curso_3_4', 2)!.id, 'T3.U3.2');
    expect(plan.mesDentro('curso_3_4', 2), (1, 5));
    expect(plan.para('curso_2_3', 9)!.id, 'T2.U1');
    expect(plan.para('curso_2_3', 6)!.id, 'T2.U6');
  });

  for (final lang in AppLanguage.deInterfaz) {
    for (final escala in [1.0, 1.8]) {
      testWidgets('a tarxeta de 3-4 en outubro, ${lang.code}, escala $escala',
          (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        PlanCurricular.sembrar(plan);
        await tester.pumpWidget(MediaQuery(
          data: MediaQueryData(
              size: const Size(360, 640),
              textScaler: TextScaler.linear(escala)),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: TarxetaCurricular(
                  cursoId: 'curso_3_4',
                  mesCalendario: 10,
                  language: lang,
                ),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('plan_curricular_T3.U3.1')),
            findsOneWidget);
        expect(find.text('block'), findsWidgets);
        await tester.tap(find.text(
            lang == AppLanguage.gl ? 'Como se traballa' : 'Cómo se trabaja'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
