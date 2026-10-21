import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/models/formacion_model.dart';
import 'package:descubre_con_lua/data/models/o_modelo_model.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/docentes/views/eu_docente_screen.dart';
import 'package:descubre_con_lua/features/familias/views/guias_familias_screen.dart';
import 'package:descubre_con_lua/features/formacion/views/formacion_screen.dart';

/// F2: «O modelo» se abre por Eu (aula) y por Guías (casa), en gl y es, con
/// texto normal y grande, y trae las nueve secciones de los documentos de
/// base. Lo que no prueba: fuentes reales, un aparato, que el audio suene.
void main() {
  const ruta = 'assets/content/modelo/o_modelo.json';

  test('o contido: as nove seccións, cada unha co seu exemplo de aula e casa',
      () {
    final m = OModelo.fromRaw(File(ruta).readAsStringSync());
    expect(m.seccions.map((s) => s.clave), [
      'parentese',
      'compuerta_social',
      'habla_paralela',
      'espera',
      'expansion',
      'recast',
      'lua_solo_ingles',
      'etapas',
      'rexistro',
    ]);
    for (final s in m.seccions.where((s) => s.clave != 'rexistro')) {
      expect(s.exemploAula, isNotNull, reason: s.clave);
      expect(s.exemploCasa, isNotNull, reason: s.clave);
    }
    final etapas = m.seccions.firstWhere((s) => s.clave == 'etapas');
    expect(etapas.tramos.map((t) => t.clave), ['18_36m', '3_6']);
    // Ninguna sección pide que la criatura repita (ERRATAS, 180 y 334).
    final todo = File(ruta).readAsStringSync();
    expect(todo, isNot(contains('Can you say')));
  });

  for (final lang in AppLanguage.deInterfaz) {
    for (final escala in [1.0, 1.8]) {
      for (final paraAula in [true, false]) {
        final onde = paraAula ? 'Eu' : 'Guías';
        testWidgets('$onde → O modelo, ${lang.code}, escala $escala',
            (tester) async {
          tester.view.physicalSize = const Size(360, 640);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);
          final repo = ContentRepository();
          final audio = MockOfflineAudioService();
          // Leído antes y sembrado: con la carga en curso, el indicador gira
          // siempre y pumpAndSettle no acaba nunca.
          OModelo.sembrar(OModelo.fromRaw(File(ruta).readAsStringSync()));
          await tester.pumpWidget(MediaQuery(
            data: MediaQueryData(
                size: const Size(360, 640),
                textScaler: TextScaler.linear(escala)),
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: paraAula
                  ? EuDocenteScreen(
                      repository: repo,
                      language: lang,
                      onLanguageChanged: (_) {},
                      audioService: audio,
                    )
                  : GuiasFamiliasScreen(
                      repository: repo,
                      language: lang,
                      onLanguageChanged: (_) {},
                      audioService: audio,
                    ),
            ),
          ));
          await tester.pumpAndSettle();
          final fila =
              find.byKey(ValueKey(paraAula ? 'eu_o_modelo' : 'guia_o_modelo'));
          await tester.scrollUntilVisible(fila, 200,
              scrollable: find
                  .descendant(
                      of: find.byKey(
                          Key(paraAula ? 'eu_docente' : 'guias_familias')),
                      matching: find.byType(Scrollable))
                  .first);
          await tester.pumpAndSettle();
          await tester.tap(fila);
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('o_modelo')), findsOneWidget);
          expect(tester.takeException(), isNull);
          // Se abre la primera sección y sale SU ejemplo: el de aula o el de
          // casa, no los dos.
          final parentese =
              find.byKey(const PageStorageKey('modelo_parentese'));
          await tester.scrollUntilVisible(parentese, 200,
              scrollable: find.descendant(
                  of: find.byKey(const Key('o_modelo')),
                  matching: find.byType(Scrollable)));
          // Con texto grande la cabecera de la sección mide más que la
          // pantalla: se toca su título, no su centro.
          final cabeza =
              find.descendant(of: parentese, matching: find.byType(Text)).first;
          await tester.ensureVisible(cabeza);
          await tester.pumpAndSettle();
          await tester.tap(cabeza);
          await tester.pumpAndSettle();
          final aula = find.textContaining('A big boat');
          final casa = find.textContaining('Warm water');
          expect(aula, paraAula ? findsWidgets : findsNothing);
          expect(casa, paraAula ? findsNothing : findsWidgets);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  // F2: la guía de dos minutos, de aula y de casa, acaba enlazando con «El
  // modelo».
  for (final perfil in PerfilFormacion.values) {
    testWidgets('a guía ${perfil.name} remata en O modelo', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      OModelo.sembrar(OModelo.fromRaw(File(ruta).readAsStringSync()));
      final guia = GuiaFormacion.fromJson(jsonDecode(
          File('assets/content/formacion/formacion.${perfil.name}.json')
              .readAsStringSync()) as Map<String, dynamic>);
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: FormacionScreen(
          perfil: perfil,
          language: AppLanguage.gl,
          guiaPrecargada: guia,
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('formacion_o_modelo')), findsNothing);
      for (var i = 1; i < guia.pasos.length; i++) {
        await tester.tap(find.byKey(const ValueKey('formacion_seguinte')));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byKey(const ValueKey('formacion_o_modelo')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('o_modelo')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
