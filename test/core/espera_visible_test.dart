import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/core/widgets/espera_visible.dart';
import 'package:descubre_con_lua/data/models/cuento_model.dart';
import 'package:descubre_con_lua/features/cuentos/views/cuento_viewer_screen.dart';

/// M4.2: la espera se ve y no se oye. Un solo widget para la asamblea y el
/// cuento: se toca tras decir o preguntar y el anillo se llena durante los
/// segundos del contenido. No lleva ni audio ni vibración: no recibe un
/// servicio de audio, así que no puede sonar.
void main() {
  Widget envolver(Widget w) => MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(body: Center(child: w)),
      );

  for (final (lang, agarda, agardando) in [
    (AppLanguage.gl, 'Agarda 5 s', 'Agardando…'),
    (AppLanguage.es, 'Espera 5 s', 'Esperando…'),
  ]) {
    testWidgets('corre os segundos e volve a empezar (${lang.code})',
        (tester) async {
      await tester.pumpWidget(envolver(EsperaVisible(
        segundos: 5,
        language: lang,
        color: Colors.teal,
        fondo: Colors.white,
      )));
      expect(find.text(agarda), findsOneWidget);
      double anel() => tester
          .widget<CircularProgressIndicator>(
              find.byKey(const ValueKey('espera_visible_anel')))
          .value!;
      expect(anel(), 0);

      await tester.tap(find.byKey(const ValueKey('espera_visible')));
      // El anillo arranca en el fotograma siguiente al toque.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2500));
      expect(find.text(agardando), findsOneWidget);
      expect(anel(), closeTo(0.5, 0.05));

      // Tocar mientras corre la reinicia.
      await tester.tap(find.byKey(const ValueKey('espera_visible')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));
      expect(anel(), closeTo(0.2, 0.05));

      await tester.pump(const Duration(seconds: 5));
      expect(find.text(agarda), findsOneWidget);
      expect(anel(), 0);
    });
  }

  testWidgets('a diana mide polo menos 48 px', (tester) async {
    await tester.pumpWidget(envolver(const EsperaVisible(
      segundos: 3,
      language: AppLanguage.gl,
      color: Colors.teal,
      fondo: Colors.white,
    )));
    expect(tester.getSize(find.byKey(const ValueKey('espera_visible'))).height,
        greaterThanOrEqualTo(48));
    expect(find.text('Agarda 3 s'), findsOneWidget);
  });

  testWidgets('o conto da semana leva a espera co seu tempo, xunto á pregunta',
      (tester) async {
    final contos = (jsonDecode(
            File('assets/content/cuentos/banco100_cuentos.json')
                .readAsStringSync()) as List)
        .map((e) => Cuento.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    final conto = contos.firstWhere((c) =>
        c.paginas.isNotEmpty &&
        (c.paginas.first.preguntaImaxe?.gl ?? '').trim().isNotEmpty);
    tester.view.physicalSize = const Size(412, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: CuentoViewerScreen(cuento: conto),
    ));
    await tester.pumpAndSettle();
    final espera = find.byType(EsperaVisible);
    await tester.scrollUntilVisible(espera, 200,
        scrollable: find.byType(Scrollable).first);
    expect(espera, findsOneWidget);
    expect(tester.widget<EsperaVisible>(espera).segundos,
        conto.tempoEsperaSegundos);
  });
}
