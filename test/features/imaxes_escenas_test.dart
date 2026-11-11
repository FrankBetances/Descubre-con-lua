import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/brand/imaxe_escena.dart';
import 'package:descubre_con_lua/core/brand/lamina_vector.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/localization/localized_string.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/models/leccion_model.dart';
import 'package:descubre_con_lua/data/models/unidade_do_mes_model.dart';
import 'package:descubre_con_lua/features/criancas/criancas_store.dart';
import 'package:descubre_con_lua/features/familias/widgets/learn_duolingo.dart';
import 'package:descubre_con_lua/features/familias/widgets/reto_da_semana.dart';

/// O-20261111-1: cada escena de un reto se ve con su imagen encima del texto.
void main() {
  final mapa = jsonDecode(File(EscenasImaxes.asset).readAsStringSync())
      as Map<String, dynamic>;
  final escenas = (mapa['escenas'] as List).cast<Map<String, dynamic>>();
  final leccions =
      Leccions.fromRaw(File(Leccions.assetPath).readAsStringSync());

  test('cada escena das leccións ten a súa lámina, e a lámina existe', () {
    final conImaxe = {for (final e in escenas) (e['escena'] as Map)['gl']};
    var vistas = 0;
    for (final us in leccions.unidades.values) {
      for (final u in us) {
        for (final l in u.leccions) {
          if (l.escena.gl.isEmpty) continue;
          vistas++;
          expect(conImaxe, contains(l.escena.gl), reason: l.id);
        }
      }
    }
    expect(vistas, greaterThan(0));
    expect(escenas, hasLength(12));
    for (final e in escenas) {
      expect(File(LaminaVectorial.assetDe(e['clave'] as String)).existsSync(),
          isTrue,
          reason: e['clave'] as String);
      final et = e['etiqueta'] as Map;
      expect(et['gl'], isNotEmpty);
      expect(et['es'], isNotEmpty);
    }
  });

  Future<void> cargar(WidgetTester t) async {
    for (var i = 0; i < 4; i++) {
      await t.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)));
      await t.pump();
    }
  }

  for (final lang in [AppLanguage.gl, AppLanguage.es]) {
    final e = escenas.first;
    final etiqueta = (e['etiqueta'] as Map)[lang.code] as String;

    testWidgets('o reto da semana pinta a imaxe encima do texto (${lang.code})',
        (tester) async {
      final h = UnidadeDoMes.fromJson(jsonDecode(
              File('assets/content/unidades_mes/curso_4_5/unidade.01.json')
                  .readAsStringSync()) as Map<String, dynamic>)
          .hogar!;
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: ListView(children: [
            RetoDaSemana(hogar: h, semana: 1, language: lang),
          ]),
        ),
      ));
      await cargar(tester);
      final imaxe = find.byType(ImaxeEscena);
      expect(imaxe, findsOneWidget);
      expect(find.descendant(of: imaxe, matching: find.byType(CustomPaint)),
          findsWidgets);
      final texto = find.textContaining(h.escena.resolve(lang));
      expect(texto, findsOneWidget);
      expect(
          tester.getTopLeft(imaxe).dy, lessThan(tester.getTopLeft(texto).dy));
      expect(
          find.bySemanticsLabel((escenas.firstWhere(
                  (x) => (x['escena'] as Map)['gl'] == h.escena.gl)['etiqueta']
              as Map)[lang.code] as String),
          findsOneWidget);
    });

    testWidgets('a lección de Duolingo pinta a imaxe da escena (${lang.code})',
        (tester) async {
      final lec = leccions.da('curso_4_5', 10, 1)!.$2;
      final pasos = pasosDoDia(lec, 2, lang);
      expect(pasos.first.escena?.gl, lec.escena.gl);
      const c = Crianza(id: 'c1', nome: 'Uxía', idade: 4, curso: 'curso_4_5');
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.temaFamilias,
        home: LeccionDuolingoScreen(
          pasos: pasos,
          language: lang,
          semana: CriancasStore.semana('curso_4_5', 10, 1),
          palabrasDaSemana: [for (final p in lec.novas) p.en],
          store: CriancasStore.enMemoria(const [c]),
          crianza: c,
          agora: DateTime(2026, 10, 6, 18),
        ),
      ));
      await cargar(tester);
      final imaxe = find.byType(ImaxeEscena);
      expect(imaxe, findsOneWidget);
      expect(find.descendant(of: imaxe, matching: find.byType(CustomPaint)),
          findsWidgets);
      final texto = find.byKey(const Key('leccion_paso_escena'));
      expect(
          tester.getTopLeft(imaxe).dy, lessThan(tester.getTopLeft(texto).dy));
      final et = escenas.firstWhere(
              (x) => (x['escena'] as Map)['gl'] == lec.escena.gl)['etiqueta']
          as Map;
      expect(find.bySemanticsLabel(et[lang.code] as String), findsOneWidget);
    });

    testWidgets(
        'a etiqueta para o lector de pantalla vai na lingua (${lang.code})',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ImaxeEscena(
              escena: LocalizedString.fromJson(
                  (e['escena'] as Map).cast<String, dynamic>()),
              lang: lang),
        ),
      ));
      await cargar(tester);
      expect(find.bySemanticsLabel(etiqueta), findsOneWidget);
    });
  }
}
