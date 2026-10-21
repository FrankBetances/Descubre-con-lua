import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/models/conto_dialogado_model.dart';
import 'package:descubre_con_lua/data/models/unidade_curricular_model.dart';
import 'package:descubre_con_lua/features/cuentos/views/contos_dialogados_screen.dart';

/// F12: los 100 cuentos dialogados HIS-001…HIS-100, con la plantilla del
/// documento de Frank, atados a una unidad existente del plan curricular, y
/// el visor recorre las láminas en gl y es. Lo que no prueba: el aparato.
void main() {
  late BibliotecaDialogada b;
  late PlanCurricular plan;

  setUpAll(() {
    b = BibliotecaDialogada.fromRaw([
      for (final f in BibliotecaDialogada.ficheiros) File(f).readAsStringSync(),
    ]);
    plan = PlanCurricular.fromRaw([
      for (final f in PlanCurricular.ficheiros) File(f).readAsStringSync(),
    ], File(PlanCurricular.calendarioAsset).readAsStringSync());
  });

  test('os 100, cada un na súa unidade, con 3 ou 4 láminas e a tríada', () {
    expect(b.contos.map((c) => c.id).toList(),
        [for (var i = 1; i <= 100; i++) 'HIS-${i.toString().padLeft(3, '0')}']);
    for (final c in b.contos) {
      expect(plan.unidade(c.unidade), isNotNull, reason: c.id);
      expect(c.laminas.length, c.cohorte == '2_3' ? 3 : 4, reason: c.id);
      for (final l in c.laminas) {
        expect(l.lua, isNotNull, reason: c.id);
        expect(l.crowd.length, 3, reason: c.id);
        expect(l.lua!.significado, isNotNull, reason: c.id);
      }
    }
  });

  for (final id in ['HIS-001', 'HIS-008']) {
    for (final lang in AppLanguage.deInterfaz) {
      testWidgets('$id, ${lang.code}, escala 1.8', (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        final c = b.contos.firstWhere((c) => c.id == id);
        await tester.pumpWidget(MediaQuery(
          data: const MediaQueryData(
              size: Size(360, 640), textScaler: TextScaler.linear(1.8)),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: ContoDialogadoScreen(conto: c, language: lang),
          ),
        ));
        await tester.pumpAndSettle();
        for (var i = 0; i < c.laminas.length; i++) {
          expect(find.byKey(Key('conto_dialogado_${id}_$i')), findsOneWidget);
          expect(tester.takeException(), isNull);
          if (i < c.laminas.length - 1) {
            await tester.tap(find.byKey(const Key('conto_seguinte')));
            await tester.pumpAndSettle();
          }
        }
      });
    }
  }
}
