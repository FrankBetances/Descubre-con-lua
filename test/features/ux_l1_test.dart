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
import 'package:descubre_con_lua/features/seleccion/seleccion_portal_screen.dart';

/// Lote L1 de la revisión de interfaz: STEAM a la vista en el Portal Familias.
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
    final steam = gl
        ? 'STEAM na casa · Ciencia coas mans'
        : 'STEAM en casa · Ciencia con las manos';

    testWidgets('STEAM está en la primera mitad del portal (${lang.code})',
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
      final lista = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(find.text(steam), 200, scrollable: lista);
      await tester.pumpAndSettle();
      final posicion = tester.state<ScrollableState>(lista).position;
      expect(posicion.pixels, lessThanOrEqualTo(posicion.maxScrollExtent / 2),
          reason: 'baixar ${posicion.pixels} de ${posicion.maxScrollExtent}');
    });

    testWidgets('STEAM va justo después del calendario (${lang.code})',
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
        const Size(360, 8000),
      );
      double y(String texto) => tester.getTopLeft(find.text(texto)).dy;
      final calendario =
          gl ? 'Calendario Escolar no Fogar' : 'Calendario Escolar en el Hogar';
      final contos = gl
          ? 'Biblioteca de Contos Dialóxicos'
          : 'Biblioteca de Cuentos Dialógicos';
      expect(y(calendario), lessThan(y(steam)));
      expect(y(steam), lessThan(y(contos)));
      // Y su chip, el segundo de la fila de áreas.
      final fila = find
          .ancestor(
              of: find.text(gl ? 'Todas as Áreas' : 'Todas las Áreas'),
              matching: find.byType(Row))
          .first;
      final chips = find
          .descendant(of: fila, matching: find.byType(ChoiceChip))
          .evaluate();
      final etiquetas = [
        for (final c in chips)
          (((c.widget as ChoiceChip).label as Text).data ?? ''),
      ];
      expect(etiquetas.indexOf('STEAM'), 1, reason: etiquetas.join(' · '));
    });

    testWidgets('la tarjeta de inicio nombra STEAM (${lang.code})',
        (tester) async {
      await pintar(
        tester,
        SeleccionPortalScreen(
          repository: repo,
          audioService: MockOfflineAudioService(),
          currentLanguage: lang,
          onToggleLanguage: () {},
        ),
        const Size(400, 4000),
      );
      expect(
          find.text(gl
              ? 'Ciencia coas mans (STEAM): un xogo de ciencia por idade, con cousas da casa'
              : 'Ciencia con las manos (STEAM): un juego de ciencia por edad, con cosas de casa'),
          findsOneWidget);
    });
  }
}
