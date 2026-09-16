import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/audio/widgets/boton_escuchar.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/data/models/asamblea_primeiro_ciclo_model.dart';
import 'package:descubre_con_lua/data/models/asamblea_segundo_ciclo_model.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/juega/views/asamblea_player_screen.dart';

/// El reproductor de la asamblea HABLA.
///
/// Gate nacido de un fallo real: al unificar el reproductor de los dos ciclos
/// las 133 órdenes en inglés y las 400 consignas quedaron pintadas como texto,
/// sin ningún botón que tocara las grabaciones que ya iban en el paquete. La
/// cobertura de voz seguía en verde —las grabaciones existían— y la app estaba
/// muda. Esto comprueba lo que la docente ve: un altavoz junto a la consigna y
/// uno junto a cada orden, y que ese altavoz apunta a una grabación que existe
/// (el botón sólo se pinta cuando `rootBundle` la encuentra).
void main() {
  late ContentRepository repository;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    repository = ContentRepository();
    await repository.initialize();
  });

  Future<void> pump(WidgetTester tester, List<FaseAsamblea> fases) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: AsambleaPlayerScreen(
        fases: fases,
        subtitulo: 'proba',
        language: AppLanguage.gl,
        audioService: MockOfflineAudioService(),
      ),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> irAFase(WidgetTester tester, int veces) async {
    for (var i = 0; i < veces; i++) {
      await tester.tap(find.byKey(const ValueKey('player_fase_seguinte')));
      await tester.pumpAndSettle();
    }
  }

  int altavoces() => find.byIcon(Icons.volume_up_rounded).evaluate().length;

  testWidgets('2.º ciclo: a consigna e cada orde en inglés teñen voz',
      (tester) async {
    final a = repository.getAsambleaByMesYNivelSync(
        9, NivelEducativoSegundoCiclo.infantil4)!;
    await pump(tester, a.fases);

    // Fase 1: a consigna ten o seu altavoz e a grabación existe.
    expect(find.byKey(const ValueKey('voz_consigna')), findsOneWidget);
    expect(altavoces(), greaterThanOrEqualTo(1));

    // Fase 3 (TPR): un altavoz por orde en inglés, ademais do da consigna.
    final core = a.fases.indexWhere((f) => f.comandosL3.isNotEmpty);
    expect(core, greaterThanOrEqualTo(0));
    await irAFase(tester, core);
    final ordes = a.fases[core].comandosL3.take(3).length;
    expect(ordes, greaterThanOrEqualTo(1));
    expect(find.byType(BotonEscuchar).evaluate().length,
        greaterThanOrEqualTo(1 + ordes));
    expect(altavoces(), 1 + ordes);
  });

  testWidgets('1.º ciclo: a consigna e cada orde en inglés teñen voz',
      (tester) async {
    final a = repository.getAsambleaPrimeiroCicloSync(
        9, TramoPrimeiroCiclo.deambulantes2a3)!;
    await pump(tester, a.fases);
    expect(find.byKey(const ValueKey('voz_consigna')), findsOneWidget);
    expect(altavoces(), greaterThanOrEqualTo(1));

    final core = a.fases.indexWhere((f) => f.comandosL3.isNotEmpty);
    expect(core, greaterThanOrEqualTo(0));
    await irAFase(tester, core);
    final ordes = a.fases[core].comandosL3.take(3).length;
    expect(altavoces(), 1 + ordes);
  });
}
