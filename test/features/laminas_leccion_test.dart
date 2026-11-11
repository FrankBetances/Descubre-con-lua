import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/brand/lamina_vector.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/models/leccion_model.dart';
import 'package:descubre_con_lua/features/criancas/criancas_store.dart';
import 'package:descubre_con_lua/features/familias/widgets/learn_duolingo.dart';
import 'package:descubre_con_lua/features/leccions/widgets/proxecto_0_2.dart';

/// O-20261111-2: cada paso de la lección enseña el dibujo de SU palabra.
void main() {
  final leccions =
      Leccions.fromRaw(File(Leccions.assetPath).readAsStringSync());

  bool existe(String clave) =>
      File(LaminaVectorial.assetDe(clave)).existsSync();

  /// Lo que le falta a un paso para tener su dibujo; vacío si lo tiene.
  String? falta(PasoLeccion p) {
    final claves = [
      if (p.peza?.lamina case final c?) c,
      for (final l in p.laminas) l.clave,
    ];
    if (p.peza != null && p.peza!.lamina == null) {
      return '«${p.peza!.en}» sen lámina';
    }
    if (p.peza == null && claves.isEmpty && p.escena == null) {
      return '«${p.titulo}» sen lámina';
    }
    for (final c in claves) {
      if (c.startsWith('escena_')) return '$c é dunha escena de reto';
      if (!existe(c)) return '$c non existe';
    }
    return null;
  }

  Future<void> cargar(WidgetTester t) async {
    for (var i = 0; i < 4; i++) {
      await t.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)));
      await t.pump();
    }
  }

  for (final lang in [AppLanguage.gl, AppLanguage.es]) {
    testWidgets(
        'curso_4_5.03.2, paso a paso: un debuxo en cada paso (${lang.code})',
        (tester) async {
      final lec = leccions.porId('curso_4_5', 'curso_4_5.03.2')!.$2;
      final pasos = pasosDoDia(lec, 1, lang);
      const c = Crianza(id: 'c1', nome: 'Uxía', idade: 4, curso: 'curso_4_5');
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.temaFamilias,
        home: LeccionDuolingoScreen(
          pasos: pasos,
          language: lang,
          semana: CriancasStore.semana('curso_4_5', 11, 2),
          palabrasDaSemana: [for (final p in lec.novas) p.en],
          store: CriancasStore.enMemoria(const [c]),
          crianza: c,
          agora: DateTime(2026, 11, 9, 18),
        ),
      ));
      var vistos = 0;
      for (final paso in pasos) {
        await cargar(tester);
        final vista = find.byKey(const Key('leccion_paso'));
        expect(vista, findsOneWidget, reason: paso.titulo);
        final laminas = tester
            .widgetList<LaminaEscena>(
                find.descendant(of: vista, matching: find.byType(LaminaEscena)))
            .toList();
        expect(laminas, isNotEmpty,
            reason: 'paso ${vistos + 1} («${paso.peza?.en ?? paso.titulo}») '
                'sen LaminaEscena');
        final en = paso.peza?.en ?? '';
        if (['Curl into a ball', 'Downhill', 'Steep'].contains(en)) {
          expect(laminas.single.clave, isNot('escena_peluche_pano'));
          expect(laminas.single.clave, isNot(startsWith('escena_')));
          expect(laminas.single.clave, paso.peza!.lamina);
          expect(
              find.bySemanticsLabel(
                  '${lang == AppLanguage.gl ? 'Imaxe' : 'Imagen'}: '
                  '${paso.peza!.significado!.resolve(lang)}'),
              findsOneWidget);
        }
        // Un paso que no es o do reto nunca leva a lámina da escena.
        if (paso.escena == null) {
          expect(laminas.where((l) => l.clave.startsWith('escena_')), isEmpty,
              reason: en);
        }
        vistos++;
        await tester.runAsync(() async {
          await tester.tap(find.byKey(const Key('leccion_continuar')));
          await Future<void>.delayed(const Duration(milliseconds: 20));
        });
        await tester.pump();
      }
      expect(vistos, pasos.length);
      expect(vistos, greaterThanOrEqualTo(7));
    });
  }

  test('todas as leccións, os cinco días: cada paso co seu debuxo', () {
    final faltan = <String>[];
    var pasos = 0;
    for (final e in leccions.unidades.entries) {
      for (final u in e.value) {
        for (final l in u.leccions) {
          for (var dia = 1; dia <= 5; dia++) {
            for (final p in pasosDoDia(l, dia, AppLanguage.gl)) {
              pasos++;
              if (falta(p) case final f?) faltan.add('${l.id} día $dia: $f');
            }
          }
        }
      }
    }
    expect(faltan, isEmpty,
        reason: '${faltan.length} de $pasos pasos sen o seu debuxo; '
            'os primeiros: ${faltan.take(5).join(' · ')}');
  });

  test('0-2: todos os pasos de todos os proxectos co seu debuxo', () {
    final proxectos =
        Proxectos02.fromRaw(File(Proxectos02.assetPath).readAsStringSync());
    final faltan = <String>[];
    var pasos = 0;
    for (final mes in [9, 10, 11, 12, 1, 2, 3, 4, 5, 6]) {
      final p = proxectos.doMes(mes)!;
      for (var semana = 1; semana <= 4; semana++) {
        for (final paso in pasosDoProxecto(p, semana, AppLanguage.gl)) {
          pasos++;
          if (falta(paso) case final f?) faltan.add('mes $mes s$semana: $f');
        }
      }
    }
    expect(faltan, isEmpty,
        reason: '${faltan.length} de $pasos pasos de 0-2 sen o seu debuxo; '
            'os primeiros: ${faltan.take(5).join(' · ')}');
  });
}
