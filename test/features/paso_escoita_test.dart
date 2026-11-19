import 'dart:convert';
import 'dart:io';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/data/models/leccion_model.dart';
import 'package:descubre_con_lua/data/models/plan_escoita_model.dart';
import 'package:descubre_con_lua/features/familias/widgets/learn_duolingo.dart';
import 'package:descubre_con_lua/features/familias/widgets/paso_escoita.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// O-20261119-8: la pieza de escucha del mes entra en la lección, con una
/// actividad distinta cada semana. Aquí con una pieza de prueba: las 40 de
/// verdad las comprueba tools/check_plan_escoita.py cuando llegan.
void main() {
  final leccions =
      Leccions.fromRaw(File(Leccions.assetPath).readAsStringSync());
  Map<String, String> t(String gl, String es) => {'gl': gl, 'es': es};
  final plan = PlanEscoita.fromRaw(jsonEncode([
    {
      'curso': 'curso_4_5',
      'mes': 3,
      'fuente': 'valeria:snail-nail',
      'par': {
        'a': {
          'en': 'snail',
          'gl': 'caracol',
          'es': 'caracol',
          'lamina': 'pal_snail'
        },
        'b': {'en': 'nail', 'gl': 'uña', 'es': 'uña', 'lamina': null},
        'fonema': '/sn-/ → /n-/',
        'nota': t('Nota gl', 'Nota es'),
        'mision_acerto': t('Acerto gl', 'Acierto es'),
        'mision_fallo': t('Fallo gl', 'Fallo es'),
        'pista': t('Pista gl', 'Pista es'),
      },
      'progresion': {
        'tema': t('O can', 'El perro'),
        'fases': [
          for (final (tipo, en) in [
            ('concepto', 'dog'),
            ('parte', 'tail'),
            ('accion', 'run'),
            ('cualidad', 'soft'),
          ])
            {
              'tipo': tipo,
              'en': en,
              'gl': en,
              'es': en,
              'lamina': 'pal_$en',
              'frase': '',
              'accion': t('Acción $en', 'Acción $en'),
            },
        ],
      },
      'modelo': {
        'neno': 'dog',
        'adulto': ['Dog.', 'A soft dog.', 'The soft dog runs.'],
        'nota': t('Modelo gl', 'Modelo es'),
      },
    },
  ]));
  setUp(() => PlanEscoita.sembrar(plan));
  tearDown(() => PlanEscoita.sembrar(null));

  test('cada semana do mes, unha actividade distinta coa peza do mes', () {
    for (var s = 1; s <= 4; s++) {
      final l = leccions.porId('curso_4_5', 'curso_4_5.03.$s')!.$2;
      final e = pasosDoDia(l, 1, AppLanguage.gl).last.escoita;
      expect(e, isNotNull, reason: 'semana $s sen paso de escoita');
      expect(e!.semana, s);
    }
  });

  test('sen plan, a lección queda como estaba', () {
    PlanEscoita.sembrar(null);
    final l = leccions.porId('curso_4_5', 'curso_4_5.03.1')!.$2;
    expect(pasosDoDia(l, 1, AppLanguage.gl).any((p) => p.escoita != null),
        isFalse);
  });

  for (final lang in [AppLanguage.gl, AppLanguage.es]) {
    testWidgets('as catro actividades pintan en ${lang.code}', (t) async {
      for (var s = 1; s <= 4; s++) {
        final paso = PasoEscoita(semana: s, peza: plan.de('curso_4_5', 3)!);
        await t.pumpWidget(MaterialApp(
            home: Scaffold(
                body: SingleChildScrollView(
                    child: VistaPasoEscoita(
                        paso: paso, lang: lang, audioService: null)))));
        await t.pumpAndSettle();
        expect(find.byKey(Key('leccion_escoita_s$s')), findsOneWidget);
        expect(t.takeException(), isNull);
      }
    });
  }

  // Con el plan de verdad (las 40 piezas orientadas al STEAM): en 2-3, 3-4,
  // 4-5 y 5-6, cada semana de cada mes lleva su actividad de escucha; la del
  // par (semanas 1 y 4) solo falta donde el par está pendiente de P7.9.
  test('o plan real: as catro idades, os dez meses, coas súas actividades', () {
    final real =
        PlanEscoita.fromRaw(File(PlanEscoita.assetPath).readAsStringSync());
    PlanEscoita.sembrar(real);
    var semPar = 0;
    for (final curso in ['curso_2_3', 'curso_3_4', 'curso_4_5', 'curso_5_6']) {
      for (var mes = 1; mes <= 10; mes++) {
        final peza = real.de(curso, mes);
        expect(peza, isNotNull, reason: '$curso mes $mes sen peza');
        for (var s = 1; s <= 4; s++) {
          final id = '$curso.${mes.toString().padLeft(2, '0')}.$s';
          final e = PasoEscoita.para(id, real);
          if (peza!.parPendiente && (s == 1 || s == 4)) {
            expect(e, isNull);
            semPar++;
          } else {
            expect(e?.semana, s, reason: '$id sen actividade de escoita');
          }
        }
      }
    }
    expect(semPar, lessThanOrEqualTo(32));
  });
}
