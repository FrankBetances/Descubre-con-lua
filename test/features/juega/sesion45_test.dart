import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/data/models/steam_do_mes_model.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/models/sesion45_model.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/juega/views/sesion45_screen.dart';

/// F3: la sesión de 45 minutos se abre en los cinco cursos, con sus cuatro
/// fases (7-10, 10-12, 15-18 y 5-7 min) y lo del mes de cada unidad, en gl y
/// es, con texto normal y grande. Lo que no prueba: un aparato, el audio.
void main() {
  final steam =
      SteamDoMes.fromRaw(File(SteamDoMes.assetPath).readAsStringSync());
  late Sesion45 sesion;

  setUpAll(() {
    sesion = Sesion45.fromRaw(File(Sesion45.assetPath).readAsStringSync());
  });

  test('catro fases, cos minutos do texto de base, e ningunha pide repetir',
      () {
    expect(sesion.fases.map((f) => f.clave),
        ['acollida', 'conto', 'taller', 'despedida']);
    expect(
        sesion.fases.map((f) => f.minutos), ['7-10', '10-12', '15-18', '5-7']);
    final todo = File(Sesion45.assetPath).readAsStringSync();
    expect(todo, isNot(contains('Can we all say')));
    expect(todo, isNot(contains('Good pointing')));
    expect(todo, contains('Reach inside'));
  });

  const cursos = [
    'curso_0_2',
    'curso_2_3',
    'curso_3_4',
    'curso_4_5',
    'curso_5_6'
  ];
  for (final curso in cursos) {
    for (final lang in AppLanguage.deInterfaz) {
      for (final escala in [1.0, 1.8]) {
        testWidgets('$curso, outubro, ${lang.code}, escala $escala',
            (tester) async {
          tester.view.physicalSize = const Size(360, 640);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);
          Sesion45.sembrar(sesion);
          SteamDoMes.sembrar(steam);
          final repo = ContentRepository();
          await tester.runAsync(() async {
            await repo.loadProgramaTpr();
            await repo.loadRexistroFrases();
            await repo.loadUnidadeDoMes(curso, 10);
          });
          await tester.pumpWidget(MediaQuery(
            data: MediaQueryData(
                size: const Size(360, 640),
                textScaler: TextScaler.linear(escala)),
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: Sesion45Screen(
                repository: repo,
                cursoId: curso,
                mesCalendario: 10,
                segundoCiclo: !curso.endsWith('0_2') && !curso.endsWith('2_3'),
                language: lang,
              ),
            ),
          ));
          await tester.runAsync(() => Future<void>.delayed(Duration.zero));
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('sesion45')), findsOneWidget);
          final lista = find.descendant(
              of: find.byKey(const Key('sesion45')),
              matching: find.byType(Scrollable));
          for (final f in sesion.fases) {
            await tester.scrollUntilVisible(
                find.byKey(ValueKey('sesion45_${f.clave}')), 300,
                scrollable: lista);
            expect(find.text('${f.minutos} min'), findsOneWidget);
            expect(tester.takeException(), isNull, reason: f.clave);
          }
          // El taller trae las órdenes del mes de la unidad.
          expect(
              find.textContaining(lang == AppLanguage.gl ? 'ORDES' : 'ÓRDENES'),
              findsWidgets);
        });
      }
    }
  }
}
