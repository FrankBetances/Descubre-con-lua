import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/loaders/content_asset_loader.dart';
import 'package:descubre_con_lua/data/models/leccion_model.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/familias/views/codigo_da_escola_screen.dart';

/// P10: o código da nota abre o mes e a semana que di, en casa; desde P11,
/// a lección desa semana.
void main() {
  late ContentRepository repo;

  setUpAll(() async {
    repo = ContentRepository(
      loader: ContentAssetLoader(
          stringLoader: (path) => File(path).readAsStringSync().let()),
    );
    await repo.loadProgramaTpr();
    await repo.loadRexistroFrases();
    TestWidgetsFlutterBinding.ensureInitialized();
    await repo.loadUnidadeDoMes('curso_4_5', 11);
    Leccions.sembrar(
        Leccions.fromRaw(File(Leccions.assetPath).readAsStringSync()));
  });

  for (final lang in [AppLanguage.gl, AppLanguage.es]) {
    testWidgets('un código bo abre a lección da súa semana (${lang.code})',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.temaFamilias,
        home: CodigoDaEscolaScreen(repository: repo, language: lang),
      ));
      await tester.enterText(find.byKey(const Key('codigo_campo')), '45 11 3');
      await tester.tap(find.byKey(const Key('codigo_abrir')));
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('codigo_resultado_45-11-3')),
          findsOneWidget);
      // P11: la lección de 4-5 años de la semana 3 de noviembre.
      final id = Leccions.lidas!.da('curso_4_5', 11, 3)!.$2.id;
      expect(find.byKey(ValueKey('leccion_$id')), findsOneWidget);
      expect(find.byKey(const Key('leccion_cabeceira')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('un código malo di como é (${lang.code})', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.temaFamilias,
        home: CodigoDaEscolaScreen(repository: repo, language: lang),
      ));
      await tester.enterText(find.byKey(const Key('codigo_campo')), '45-07-1');
      await tester.tap(find.byKey(const Key('codigo_abrir')));
      await tester.pump();
      expect(find.byKey(const Key('codigo_erro')), findsOneWidget);
    });
  }
}

extension on String {
  Future<String> let() => Future.value(this);
}
