import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/loaders/content_asset_loader.dart';
import 'package:descubre_con_lua/data/models/tpr_curriculum_scheduler.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/cuentos/views/cuento_viewer_screen.dart';
import 'package:descubre_con_lua/features/juega/widgets/circulo_do_dia.dart';

/// «O conto de hoxe» é o conto DA SEMANA, o que leva as palabras do día.
///
/// A primeira semana de cada mes abría un conto do banco: eses non son de
/// ningunha semana, o modelo dálles a 1 por defecto e, ordenados por id, ían
/// diante. Así, en outubro de 0-2 saía «Onde están as cóxegas de Lúa?», sen
/// ningunha das palabras do día, no canto de «Martiño e o nariz escondido».
void main() {
  late ContentRepository repo;
  late ProgramaTpr programa;

  setUpAll(() async {
    Future<String> ler(String p) => File(p).readAsString();
    programa = await ProgramaTpr.cargar(stringLoader: ler);
    repo = ContentRepository(loader: ContentAssetLoader(stringLoader: ler));
    repo.addProgramaTpr(programa);
    // Do disco AQUÍ: dentro de testWidgets o reloxo é falso.
    await repo.loadCuentos();
    await repo.loadDinamicas();
  });

  const cursos = [
    'curso_0_2',
    'curso_2_3',
    'curso_3_4',
    'curso_4_5',
    'curso_5_6',
  ];

  test('as 200 semanas do curso abren o seu conto, coas palabras do día',
      () async {
    for (final curso in cursos) {
      for (var mes = 1; mes <= 10; mes++) {
        final contos = await repo.loadCuentos(cursoId: curso, mesNumero: mes);
        for (var semana = 1; semana <= 4; semana++) {
          final conto = CirculoDoDia.contoDaSemana(contos, semana)!;
          final tag = '$curso, mes $mes, semana $semana';
          expect(conto.semanaSugerida, semana, reason: tag);
          final palabras = {
            for (final p in conto.paginas)
              for (final w in p.palabras) w.toLowerCase(),
          };
          final semanaTpr = programa.curso(curso)!.semanaPorOrden(mes, semana)!;
          for (var dia = 1; dia <= 4; dia++) {
            for (final w in semanaTpr.planDoDia(dia).newWords) {
              expect(palabras, contains(w.en.toLowerCase()),
                  reason: '$tag, día $dia: «${w.en}» non está no conto '
                      '«${conto.titulo.gl}»');
            }
          }
        }
      }
    }
  });

  testWidgets(
      'outubro de 0-2, semana 1, xoves: o conto da semana e as cinco de hoxe',
      (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: ListView(children: [
          CirculoDoDia(
            repository: repo,
            cursoId: 'curso_0_2',
            mes: 2,
            semana: 1,
            dia: 4,
            language: AppLanguage.gl,
            audioService: MockOfflineAudioService(),
          ),
        ]),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Martiño e o nariz escondido'), findsOneWidget);
    expect(find.text('Onde están as cóxegas de Lúa?'), findsNothing);

    await tester.tap(find.text('Martiño e o nariz escondido'));
    await tester.pumpAndSettle();
    final visor =
        tester.widget<CuentoViewerScreen>(find.byType(CuentoViewerScreen));
    expect(visor.dia, 4);
    expect(visor.semanaTpr?.semana, 1);
    expect(
        find.text('AS 5 PALABRAS DE HOXE ESTÁN NESTE CONTO'), findsOneWidget);
  });
}
