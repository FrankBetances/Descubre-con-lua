import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/core/widgets/espera_visible.dart';
import 'package:descubre_con_lua/data/models/microcuento_model.dart';
import 'package:descubre_con_lua/data/models/rexistro_frases_model.dart';
import 'package:descubre_con_lua/data/models/unidade_do_mes_model.dart';
import 'package:descubre_con_lua/features/cuentos/views/microcuento_screen.dart';

/// M5.1: el visor abre un microcuento en los dos modos. Aula: frase de Lúa,
/// tríada, espera y guion de recast plegado. Casa: frase de Lúa, una pregunta
/// por lámina y espera; sin tríada. Se recorre el de 2-3, junio, en gl y es,
/// con texto normal y grande, a 360×640. Lo que no prueba: fuentes reales, un
/// aparato, que el audio suene.
void main() {
  late Microcuento mc;
  late RexistroDeFrases rexistro;

  setUpAll(() {
    final u = UnidadeDoMes.fromJson(jsonDecode(
        File('assets/content/unidades_mes/curso_2_3/unidade.10.json')
            .readAsStringSync()) as Map<String, dynamic>);
    mc = u.microcuento!;
    rexistro = RexistroDeFrases.fromJson(
        jsonDecode(File(RexistroDeFrases.asset).readAsStringSync())
            as Map<String, dynamic>);
  });

  Future<void> abrir(WidgetTester tester, ModoMicrocuento modo,
      AppLanguage lang, double escala) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MediaQuery(
      data: MediaQueryData(
          size: const Size(360, 640), textScaler: TextScaler.linear(escala)),
      child: MaterialApp(
        key: UniqueKey(),
        theme: AppTheme.lightTheme,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => MicrocuentoScreen(
                    microcuento: mc,
                    modo: modo,
                    rexistro: rexistro,
                    language: lang,
                  ),
                )),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  Future<void> verAbaixo(WidgetTester tester, Finder f) async {
    await tester.scrollUntilVisible(f, 150,
        scrollable: find.descendant(
            of: find.byKey(const ValueKey('microcuento')),
            matching: find.byType(Scrollable)));
  }

  test('o microcuento de proba ten as tres láminas de 2-3', () {
    expect(mc.id, 'microcuento.curso_2_3.10');
    expect(mc.laminas, hasLength(3));
    // Son as tres láminas de mostra de M5.6.
    expect(mc.debuxado, isTrue);
    expect(mc.laminas.map((l) => l.lamina), [
      'microcuento_2_3_10_1',
      'microcuento_2_3_10_2',
      'microcuento_2_3_10_3'
    ]);
    for (final l in mc.laminas) {
      expect(rexistro.frase(l.lua)?.tipo, 'lua');
    }
  });

  for (final lang in AppLanguage.deInterfaz) {
    for (final escala in [1.0, 1.8]) {
      testWidgets('aula, ${lang.code}, escala $escala', (tester) async {
        await abrir(tester, ModoMicrocuento.aula, lang, escala);
        for (var i = 0; i < mc.laminas.length; i++) {
          final l = mc.laminas[i];
          expect(tester.takeException(), isNull, reason: 'lámina ${i + 1}');
          expect(find.text(l.trama.resolve(lang)), findsOneWidget);
          expect(find.byKey(const ValueKey('frase_de_lua')), findsOneWidget);
          expect(find.text(rexistro.frase(l.lua)!.en), findsOneWidget);
          expect(find.byType(EsperaVisible), findsOneWidget);
          for (final k in [
            'triada_sinalar',
            'triada_imitar',
            'triada_achegar'
          ]) {
            await verAbaixo(tester, find.byKey(ValueKey(k)));
          }
          expect(find.text(l.achegar.en), findsOneWidget);
          expect(find.byKey(const ValueKey('pregunta_casa')), findsNothing);
          // El guion de recast va plegado.
          expect(find.byKey(const ValueKey('recast')), findsNothing);
          await verAbaixo(tester, find.byKey(const ValueKey('abrir_recast')));
          await tester.tap(find.byKey(const ValueKey('abrir_recast')));
          await tester.pumpAndSettle();
          await verAbaixo(tester, find.text(l.recast.formaTorcida.en));
          expect(tester.takeException(), isNull, reason: 'recast ${i + 1}');
          await tester.tap(find.byKey(const ValueKey('microcuento_seguinte')));
          await tester.pumpAndSettle();
        }
        // «Rematar» en la última cierra el visor.
        expect(find.byType(MicrocuentoScreen), findsNothing);
      });

      testWidgets('casa, ${lang.code}, escala $escala', (tester) async {
        await abrir(tester, ModoMicrocuento.casa, lang, escala);
        for (var i = 0; i < mc.laminas.length; i++) {
          final l = mc.laminas[i];
          expect(tester.takeException(), isNull, reason: 'lámina ${i + 1}');
          expect(find.byKey(const ValueKey('frase_de_lua')), findsOneWidget);
          await verAbaixo(tester, find.byKey(const ValueKey('pregunta_casa')));
          expect(find.text(l.casa.en), findsOneWidget);
          expect(find.byKey(const ValueKey('triada_sinalar')), findsNothing);
          expect(find.byKey(const ValueKey('abrir_recast')), findsNothing);
          await tester.tap(find.byKey(const ValueKey('microcuento_seguinte')));
          await tester.pumpAndSettle();
        }
        expect(find.byType(MicrocuentoScreen), findsNothing);
      });
    }
  }
}
