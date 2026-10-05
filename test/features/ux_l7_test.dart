import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/data/models/asamblea_segundo_ciclo_model.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/juega/views/asamblea_player_screen.dart';

/// Lote L7: lo que Frank decidió tras probar la build de L6.
void main() {
  late ContentRepository contenido;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    contenido = ContentRepository();
    await contenido.initialize();
  });

  group('O reprodutor da asemblea', () {
    // Se abre desde una pantalla de inicio, como en la app: así se ve si al
    // acabar vuelve a ella.
    Future<void> abrir(WidgetTester tester, AppLanguage lang) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final asamblea = contenido.getAsambleaByMesYNivelSync(
          10, NivelEducativoSegundoCiclo.infantil4)!;
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                key: const ValueKey('abrir'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AsambleaPlayerScreen(
                      fases: asamblea.fases,
                      subtitulo: 'proba',
                      language: lang,
                      audioService: MockOfflineAudioService(),
                    ),
                  ),
                ),
                child: const Text('Inicio'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.byKey(const ValueKey('abrir')));
      await tester.pumpAndSettle();
      expect(find.byType(AsambleaPlayerScreen), findsOneWidget);
    }

    for (final lang in AppLanguage.deInterfaz) {
      final rematar = lang == AppLanguage.gl ? 'Rematar' : 'Terminar';

      testWidgets('«$rematar» pecha sen preguntar (${lang.code})',
          (tester) async {
        await abrir(tester, lang);
        final seguinte = find.byKey(const ValueKey('player_fase_seguinte'));
        // Hasta la última fase.
        for (var i = 0; i < 10; i++) {
          if (find
              .descendant(of: seguinte, matching: find.text(rematar))
              .evaluate()
              .isNotEmpty) {
            break;
          }
          await tester.tap(seguinte);
          await tester.pumpAndSettle();
        }
        expect(find.descendant(of: seguinte, matching: find.text(rematar)),
            findsOneWidget);

        await tester.tap(seguinte);
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);
        expect(find.byType(AsambleaPlayerScreen), findsNothing);
        expect(find.text('Inicio'), findsOneWidget);
      });

      testWidgets('saír a medias segue preguntando (${lang.code})',
          (tester) async {
        await abrir(tester, lang);
        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.byType(AsambleaPlayerScreen), findsOneWidget);
      });
    }
  });
}
