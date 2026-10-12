import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/models/cuento_model.dart';
import 'package:descubre_con_lua/features/cuentos/views/cuento_viewer_screen.dart';

import '../helpers/pasarela.dart';

/// Lote L11: o conto ten que entenderse. A sinopse cortábase en dúas liñas na
/// cabeceira; agora vai enteira, arriba da primeira páxina.
void main() {
  final p = Pasarela();
  setUpAll(p.cargar);
  tearDownAll(p.limpar);
  setUp(CuentoViewerScreen.pregarExplicacion);
  tearDown(CuentoViewerScreen.despregarExplicacion);

  for (final lang in AppLanguage.deInterfaz) {
    testWidgets('a sinopse máis longa enteira na páxina 1 (${lang.code})',
        (tester) async {
      final contos = [
        for (final nome in ['historias_progresivas', 'banco100_cuentos'])
          for (final e in _lista(jsonDecode(
              File('assets/content/cuentos/$nome.json').readAsStringSync())))
            Cuento.fromJson(Map<String, dynamic>.from(e as Map)),
      ];
      final conto = contos.reduce((a, b) =>
          a.sinopse.resolve(lang).length >= b.sinopse.resolve(lang).length
              ? a
              : b);
      final sinopse = conto.sinopse.resolve(lang);
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.temaFamilias,
        home: CuentoViewerScreen(
          cuento: conto,
          language: lang,
          audioService: p.audio,
          comoFunciona: p.comoFunciona,
        ),
      ));
      await tester.pump();
      await tester.pump();

      final caixa = find.byKey(const ValueKey('conto_de_que_vai'));
      expect(caixa, findsOneWidget);
      final texto = find.descendant(of: caixa, matching: find.text(sinopse));
      expect(texto, findsOneWidget);
      final t = tester.widget<Text>(texto);
      expect(t.maxLines, isNull);
      expect(t.overflow, isNot(TextOverflow.ellipsis));
      expect(
          find.text(lang == AppLanguage.gl
              ? 'DE QUE VAI O CONTO'
              : 'DE QUÉ VA EL CUENTO'),
          findsOneWidget);

      // Na páxina 2 xa non: alí manda o conto.
      await tester.tap(find.byKey(const ValueKey('conto_seguinte')));
      await tester.pumpAndSettle();
      expect(caixa, findsNothing);
    });
  }
}

List<Object?> _lista(Object? datos) => datos is List
    ? datos
    : (datos as Map).values.firstWhere((v) => v is List) as List;
