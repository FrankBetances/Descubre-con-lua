import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/data/models/asamblea_primeiro_ciclo_model.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/juega/views/unidades_list_screen.dart';

/// El aula de 1.º ciclo con datos extremos. Las suites de la asamblea guiada
/// de seis pasos se fueron con ella (M4.3); la de cuatro fases la cubren
/// `asamblea_unidade_test.dart` y `asamblea_player_voz_test.dart`.
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

  group('Adversarial Suite 3: o selector de grupo do 1.º ciclo', () {
    testWidgets('cada tramo dá a súa propia microcápsula, non a mesma',
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

      String textoDaTarxeta() => tester
          .widgetList<Text>(find.descendant(
            of: find.byKey(const ValueKey('tarxeta_fluxo_1c')),
            matching: find.byType(Text),
          ))
          .map((t) => t.data)
          .join('|');

      final tramo02 = textoDaTarxeta();

      // Los filtros van plegados detrás del selector compacto: se abren.
      await tester.tap(find.byKey(const ValueKey('selector_compacto_1c')));
      await tester.pumpAndSettle();
      await tester.tap(find
          .byKey(ValueKey('tramo_1c_${TramoPrimeiroCiclo.deambulantes2a3}')));
      await tester.pumpAndSettle();
      final tramo23 = textoDaTarxeta();

      expect(tramo23, isNot(equals(tramo02)),
          reason: 'Os dous tramos ensinan exactamente o mesmo');

      // E volver atrás recupera o primeiro, sen quedar pegado.
      await tester.tap(
          find.byKey(ValueKey('tramo_1c_${TramoPrimeiroCiclo.lactantes0a2}')));
      await tester.pumpAndSettle();
      expect(textoDaTarxeta(), equals(tramo02));
    });

    testWidgets('un repositorio baleiro non rompe o aula', (tester) async {
      final baleiro = ContentRepository();
      await tester.pumpWidget(
        MaterialApp(
          home: UnidadesListScreen(
            repository: baleiro,
            audioService: mockAudioService,
            initialLanguage: AppLanguage.gl,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // El selector compacto está, y abre los filtros con el grupo.
      await tester.tap(find.byKey(const ValueKey('selector_compacto_1c')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('O MEU GRUPO'), findsOneWidget);
    });
  });
}
