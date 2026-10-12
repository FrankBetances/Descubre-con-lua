import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/models/como_funciona_o_conto_model.dart';
import 'package:descubre_con_lua/data/models/cuento_model.dart';
import 'package:descubre_con_lua/data/models/ponte_ao_dia_model.dart';
import 'package:descubre_con_lua/features/cuentos/views/cuento_viewer_screen.dart';

import '../helpers/pasarela.dart';

/// Lote L10: os puntos 2 e 3 do que Frank decidiu ao probar a build de L8.
///
/// 2. As pautas de lectura dialóxica xa non van nunha barra aparte escrita no
///    widget: están dentro de «Como funciona o conto», en JSON.
/// 3. A opción A, estendida aos retos TPR dos contos: o que cada reto dá por
///    sabido, co seu xesto e a súa voz, no visor e en «Ponte ao día».
void main() {
  final p = Pasarela();
  setUpAll(p.cargar);
  tearDownAll(p.limpar);

  late PonteAoDia ponte;
  late List<Cuento> contos;
  setUpAll(() {
    ponte = PonteAoDia.fromRaw(File(PonteAoDia.assetPath).readAsStringSync());
    contos = [
      for (final nome in ['historias_progresivas', 'banco100_cuentos'])
        for (final e in _lista(jsonDecode(
            File('assets/content/cuentos/$nome.json').readAsStringSync())))
          Cuento.fromJson(Map<String, dynamic>.from(e as Map)),
    ];
  });
  setUp(CuentoViewerScreen.despregarExplicacion);
  tearDown(CuentoViewerScreen.despregarExplicacion);

  group('os retos dos contos: os datos', () {
    const cursos = [
      'curso_0_2',
      'curso_2_3',
      'curso_3_4',
      'curso_4_5',
      'curso_5_6'
    ];
    const meses = [9, 10, 11, 12, 1, 2, 3, 4, 5, 6];

    test('ningún reto dá por sabida unha palabra do seu mes ou de despois', () {
      final fallos = <String>[];
      var conPalabras = 0;
      for (final c in contos) {
        final palabras = ponte.doConto(c.id);
        if (palabras.isEmpty) continue;
        conPalabras++;
        // «mesNumero» é o mes do curso: 1 = setembro.
        final cando = (cursos.indexOf(c.cursoId), c.mesNumero - 1);
        for (final w in palabras) {
          final dela = (cursos.indexOf(w.cursoId), meses.indexOf(w.mes));
          final antes =
              dela.$1 < cando.$1 || (dela.$1 == cando.$1 && dela.$2 < cando.$2);
          if (!antes) fallos.add('${c.id}: ${w.en}');
        }
      }
      expect(fallos, isEmpty, reason: fallos.join('\n'));
      expect(conPalabras, greaterThan(60), reason: 'o cruce quedou baleiro');
    });

    test('a revisión a man está aplicada', () {
      Iterable<String> en(String prefixo) => ponte
          .doConto(contos.firstWhere((c) => c.id.startsWith(prefixo)).id)
          .map((w) => w.en);
      // Coinciden na letra e non no sentido.
      expect(en('conto_056_a_gran'), isNot(contains('Bark')));
      expect(en('conto_081_o_caderno'), isNot(contains('High')));
      expect(en('conto_094_a_camelia'), isNot(contains('Steps')));
      expect(en('conto_100_a_canci'), isNot(contains('Wave')));
      expect(en('conto_088_o_sol'), isNot(contains('Earth')));
      // E o que si: «Lift the heavy branch together, team!».
      expect(en('conto_067_o_neno'),
          ['Lift', 'Heavy', 'Branch', 'Together', 'Team']);
    });

    test('ningún xesto se fai co bebé nin tapa a boca', () {
      for (final w in ponte.palabras.values) {
        for (final t in [w.xesto.gl, w.xesto.es]) {
          final x = t.toLowerCase();
          expect(x, isNot(contains('bebé')), reason: '${w.id}: $t');
          expect(x.contains('tapa') && x.contains('boca'), isFalse,
              reason: '${w.id}: $t');
        }
      }
    });
  });

  group('o visor', () {
    Future<void> abrir(
        WidgetTester tester, Cuento conto, AppLanguage lang) async {
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
          ponteAoDia: ponte,
        ),
      ));
      await tester.pump();
      await tester.pump();
    }

    for (final lang in AppLanguage.deInterfaz) {
      final gl = lang == AppLanguage.gl;

      testWidgets(
          'as pautas van dentro de «Como funciona o conto» '
          '(${lang.code})', (tester) async {
        await abrir(tester, p.contoDaSemana, lang);
        expect(find.textContaining('Pautas de lectura'), findsNothing);
        final pautas = p.comoFunciona.pasos
            .where((x) => x.cando == CandoPaso.sempre)
            .elementAt(1)
            .texto
            .resolve(lang);
        expect(
            pautas,
            contains(gl
                ? 'agarda uns cinco segundos'
                : 'espera unos cinco segundos'));
        expect(find.text(pautas), findsOneWidget);
      });

      testWidgets('o reto di o que dá por sabido e ábreo (${lang.code})',
          (tester) async {
        final conto =
            contos.firstWhere((c) => c.id.startsWith('conto_067_o_neno'));
        final palabras = ponte.doConto(conto.id);
        await abrir(tester, conto, lang);
        final fila = find.byKey(const ValueKey('reto_dadas_por_sabidas'));
        await tester.scrollUntilVisible(fila, 200,
            scrollable: find.byType(Scrollable).first);
        expect(
            find.text(gl
                ? 'O reto dá por sabidas ${palabras.length} palabras'
                : 'El reto da por sabidas ${palabras.length} palabras'),
            findsOneWidget);
        expect(find.byKey(ValueKey('reto_palabra_${palabras.first.id}')),
            findsNothing);

        await tester.tap(fila);
        await tester.pumpAndSettle();
        for (final w in palabras) {
          final f = find.byKey(ValueKey('reto_palabra_${w.id}'));
          await tester.scrollUntilVisible(f, 100,
              scrollable: find.byType(Scrollable).first);
          expect(f, findsOneWidget);
        }
        expect(find.text(ponte.texto('conto', 'porque').resolve(lang)),
            findsOneWidget);
      });

      testWidgets(
          'un reto sen nada que dar por sabido non ten fila '
          '(${lang.code})', (tester) async {
        final conto = contos.firstWhere(
            (c) => c.tprOral != null && ponte.doConto(c.id).isEmpty);
        await abrir(tester, conto, lang);
        await tester.drag(
            find.byType(Scrollable).first, const Offset(0, -3000));
        await tester.pumpAndSettle();
        expect(
            find.byKey(const ValueKey('reto_dadas_por_sabidas')), findsNothing);
      });
    }
  });
}

List<Object?> _lista(Object? datos) => datos is List
    ? datos
    : (datos as Map).values.firstWhere((v) => v is List) as List;
