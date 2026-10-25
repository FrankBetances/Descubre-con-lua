import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/models/steam_do_mes_model.dart';
import 'package:descubre_con_lua/data/models/unidade_curricular_model.dart';
import 'package:descubre_con_lua/features/juega/widgets/tarxeta_curricular.dart';
import 'package:descubre_con_lua/features/steam/views/steam_do_mes_screen.dart';

/// F8: STEAM vertebra el curso. Un experimento por mes y curso, atado a la
/// unidad del plan curricular de ese mes, con los cinco fenómenos del banco
/// de Frank rotando. Lo que no prueba: el aparato.
void main() {
  final steam =
      SteamDoMes.fromRaw(File(SteamDoMes.assetPath).readAsStringSync());
  final plan = PlanCurricular.fromRaw([
    for (final f in PlanCurricular.ficheiros) File(f).readAsStringSync(),
  ], File(PlanCurricular.calendarioAsset).readAsStringSync());
  const cursos = [
    'curso_0_2',
    'curso_2_3',
    'curso_3_4',
    'curso_4_5',
    'curso_5_6'
  ];
  const meses = [9, 10, 11, 12, 1, 2, 3, 4, 5, 6];

  test('un experimento por cada mes de cada curso, da unidade dese mes', () {
    expect(steam.experimentos, hasLength(50));
    for (final c in cursos) {
      final fen = <String, int>{};
      for (final m in meses) {
        final e = steam.para(c, m);
        expect(e, isNotNull, reason: '$c $m');
        expect(e!.unidade, plan.para(c, m)!.id, reason: e.id);
        expect(e.ordes, isNotEmpty, reason: e.id);
        expect(e.aula, isNotEmpty, reason: e.id);
        expect(e.casa, isNotEmpty, reason: e.id);
        expect(e.seguridade.gl.trim(), isNotEmpty, reason: e.id);
        fen[e.fenomeno] = (fen[e.fenomeno] ?? 0) + 1;
      }
      // Os cinco fenómenos, dúas veces ao ano cada un.
      expect(
          fen,
          {
            for (final f in ExperimentoSteam.nomesFenomeno.keys) f: 2,
          },
          reason: c);
    }
  });

  for (final lang in AppLanguage.deInterfaz) {
    for (final casa in [false, true]) {
      testWidgets(
          'o experimento de 4-5 en abril, ${lang.code}, ${casa ? 'casa' : 'aula'}, escala 1.8',
          (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(MediaQuery(
          data: const MediaQueryData(
              size: Size(360, 640), textScaler: TextScaler.linear(1.8)),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: SteamDoMesScreen(
              experimento: steam.para('curso_4_5', 4)!,
              language: lang,
              enCasa: casa,
            ),
          ),
        ));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('steam_seguridade')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('a tarxeta do plan leva o STEAM do mes, ${lang.code}',
        (tester) async {
      PlanCurricular.sembrar(plan);
      SteamDoMes.sembrar(steam);
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: SingleChildScrollView(
            child: TarxetaCurricular(
                cursoId: 'curso_3_4', mesCalendario: 10, language: lang),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('steam_do_mes_boton_STEAM-3_4-10')),
          findsOneWidget);
    });
  }
}
