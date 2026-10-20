import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/juega/views/unidades_list_screen.dart';

void main() {
  late ContentRepository repository;
  late MockOfflineAudioService mockAudioService;

  setUp(() async {
    repository = ContentRepository();
    // El aula pinta la microcápsula del grupo y el mes, que vive en los
    // assets: el repositorio se inicializa de verdad.
    await repository.initialize();
    mockAudioService = MockOfflineAudioService();
  });

  group('Juega con Lúa Feature Tests', () {
    testWidgets('UnidadesListScreen ensina a microcápsula do grupo escollido',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: UnidadesListScreen(
            repository: repository,
            audioService: mockAudioService,
            initialLanguage: AppLanguage.gl,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // O aula ensina UNHA microcápsula, a do grupo e o mes escollidos.
      expect(find.text('Xoga con Lúa'), findsOneWidget);
      expect(find.byKey(const ValueKey('tarxeta_fluxo_1c')), findsOneWidget);
      expect(find.byKey(const ValueKey('comezar_asemblea_1c')), findsOneWidget);
      // Grupo, mes e día, nunha liña; os filtros ábrense se fai falta.
      expect(
          find.byKey(const ValueKey('selector_compacto_1c')), findsOneWidget);
      expect(find.text('O MEU GRUPO'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('selector_compacto_1c')));
      await tester.pumpAndSettle();
      expect(find.text('O MEU GRUPO'), findsOneWidget);
      expect(find.text('MES DO CURSO'), findsOneWidget);
    });
  });
}
