import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/loaders/content_asset_loader.dart';
import 'package:descubre_con_lua/data/models/cancion_pulso_model.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/docentes/views/recursos_docentes_screen.dart';
import 'package:descubre_con_lua/features/juega/views/cancions_con_pulso_screen.dart';
import 'package:descubre_con_lua/features/juega/widgets/paso_cancion_widget.dart';

/// M4.3 (D5, «conservarlas sueltas»): las diez canciones con pulso que vivían
/// en la asamblea de seis pasos se abren ahora desde Recursos → Cancións con
/// pulso. Se recorren las diez en gl y es, con el texto grande. Lo que no
/// prueba: fuentes reales, un aparato, que el audio suene.
void main() {
  late ContentRepository repo;
  late List<CancionConPulso> cancions;

  setUpAll(() async {
    repo = ContentRepository(
      loader: ContentAssetLoader(stringLoader: (p) => File(p).readAsString()),
    );
    // Se leen aquí: bajo el reloj falso del test la lectura no termina.
    cancions = await repo.loadCancionsConPulso();
  });

  Future<void> montar(WidgetTester tester, Widget w, double escala) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MediaQuery(
      data: MediaQueryData(
          size: const Size(360, 780), textScaler: TextScaler.linear(escala)),
      // Clave nueva en cada montaje: si no, el Navigator se conserva y la
      // canción abierta antes sigue encima de la lista.
      child: MaterialApp(key: UniqueKey(), theme: AppTheme.lightTheme, home: w),
    ));
    // La lista llega por un futuro ya resuelto fuera del reloj falso: una
    // vuelta de tiempo real deja que su `then` corra antes de mirar.
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }

  for (final lang in AppLanguage.deInterfaz) {
    testWidgets('Recursos abre as cancións (${lang.code})', (tester) async {
      await montar(
          tester,
          Scaffold(
            body: RecursosDocentesScreen(
              repository: repo,
              language: lang,
              onLanguageChanged: (_) {},
              cursoId: 'curso_0_2',
              audioService: MockOfflineAudioService(),
            ),
          ),
          1.0);
      final fila = find.byKey(const ValueKey('recurso_cancions'));
      await tester.scrollUntilVisible(fila, 200,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(fila);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('cancions_con_pulso')), findsOneWidget);
    });

    for (final escala in [1.0, 1.8]) {
      testWidgets(
          'as dez ábrense coa letra e o pulso, ${lang.code} a escala $escala',
          (tester) async {
        expect(cancions, hasLength(10));
        for (final c in cancions) {
          await montar(
              tester,
              CancionsConPulsoScreen(
                key: ValueKey('lista.${c.id}'),
                repository: repo,
                audioService: MockOfflineAudioService(),
                initialLanguage: lang,
              ),
              escala);
          final fila = find.byKey(ValueKey(c.id));
          await tester.scrollUntilVisible(fila, 200,
              scrollable: find.byType(Scrollable).first);
          expect(tester.takeException(), isNull, reason: '${c.id} na lista');
          // Entera a la vista: el borde inferior queda tapado por el margen.
          await tester.ensureVisible(fila);
          await tester.pumpAndSettle();
          await tester.tap(fila);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: c.id);
          expect(find.byKey(ValueKey('cancion_${c.id}')), findsOneWidget,
              reason: c.id);
          expect(find.byType(PasoCancionWidget), findsOneWidget, reason: c.id);
          expect(find.text(c.cancion.titulo.resolve(lang)), findsWidgets,
              reason: c.id);
        }
      });
    }
  }
}
