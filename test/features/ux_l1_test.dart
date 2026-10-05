import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/storage/calendario_store.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/loaders/content_asset_loader.dart';
import 'package:descubre_con_lua/data/models/tpr_curriculum_scheduler.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/familias/portal_familias_screen.dart';

import '../helpers/pasarela.dart';

/// Lote L1 de la revisión de interfaz: STEAM a la vista en el Portal Familias.
///
/// Desde L3 el portal va por pestañas y STEAM está en Explorar; lo que se
/// comprueba es lo mismo: que se ve sin bajar.
///
/// Era el último de los siete módulos, en la cuarta pantalla de un teléfono de
/// 360 × 780, y la tarjeta de entrada del portal no lo nombraba: quien no bajaba
/// hasta el final no sabía que existía. Por eso Frank pidió «en el portal familias también debe tener
/// el módulo steam» cuando ya estaba.
void main() {
  late ContentRepository repo;
  late CalendarioStore store;
  late Directory dir;

  setUpAll(() async {
    // La tipografía real: con la de relleno, más ancha, las tarjetas miden
    // otra cosa (regla 1c).
    await Pasarela.cargarFontes();
    Future<String> ler(String p) => File(p).readAsString();
    repo = ContentRepository(loader: ContentAssetLoader(stringLoader: ler));
    await repo.initialize(unidadPaths: const [], capsulaPaths: const []);
    repo.addProgramaTpr(await ProgramaTpr.cargar(stringLoader: ler));
  });

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('ux_l1_');
    store = CalendarioStore(overrideDirectory: dir.path);
    await store.cargar();
  });

  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  Future<void> pintar(WidgetTester tester, Widget w, Size tamano) async {
    tester.view.physicalSize = tamano;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: w));
    await tester.pumpAndSettle();
  }

  for (final lang in AppLanguage.deInterfaz) {
    final gl = lang == AppLanguage.gl;
    final ciencia = gl ? 'Ciencia coas mans' : 'Ciencia con las manos';

    // Con L3 el portal ya no es una lista de siete módulos: STEAM vive en
    // Explorar, con su nombre de casa, y se ve sin bajar.
    testWidgets('STEAM se ve en Explorar sin bajar (${lang.code})',
        (tester) async {
      // Un teléfono de verdad: lo que cuenta es cuánto hay que bajar.
      await pintar(
        tester,
        PortalFamiliasScreen(
          repository: repo,
          audioService: MockOfflineAudioService(),
          currentLanguage: lang,
          onToggleLanguage: () {},
          calendario: store,
        ),
        const Size(360, 780),
      );
      await tester.tap(find.byKey(const Key('pestana_explorar')));
      await tester.pumpAndSettle();
      final tesela = find.byKey(const ValueKey('explorar_ciencia'));
      expect(tesela, findsOneWidget);
      expect(find.descendant(of: tesela, matching: find.text(ciencia)),
          findsOneWidget);
      // Entera dentro de la pantalla, por encima de la barra de pestañas.
      final caja = tester.getRect(tesela);
      final barra = tester.getRect(find.byType(NavigationBar));
      expect(caja.bottom, lessThanOrEqualTo(barra.top),
          reason: 'la tarjeta termina en ${caja.bottom}, la barra empieza en '
              '${barra.top}');
    });

    // Con L5 el inicio ya no enumera módulos: son dos respuestas. STEAM se
    // nombra donde vive, en Explorar, y en la línea de su fila.
    testWidgets('Explorar dice que la ciencia es STEAM (${lang.code})',
        (tester) async {
      await pintar(
        tester,
        PortalFamiliasScreen(
          repository: repo,
          audioService: MockOfflineAudioService(),
          currentLanguage: lang,
          onToggleLanguage: () {},
          calendario: store,
        ),
        const Size(360, 780),
      );
      await tester.tap(find.byKey(const Key('pestana_explorar')));
      await tester.pumpAndSettle();
      expect(
          find.descendant(
              of: find.byKey(const ValueKey('explorar_ciencia')),
              matching: find.text(gl
                  ? 'STEAM: un xogo por idade'
                  : 'STEAM: un juego por edad')),
          findsOneWidget);
    });
  }
}
