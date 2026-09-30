import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/loaders/content_asset_loader.dart';
import 'package:descubre_con_lua/data/models/steam_model.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/steam/views/steam_hub_screen.dart';
import 'package:descubre_con_lua/features/steam/views/steam_sesion_guiada_screen.dart';

/// Que STEAM QUEPA en un teléfono: 360 dp, gallego y castellano, y la letra
/// grande del sistema.
///
/// La primera versión desbordaba en doce filas del hub y de la sesión, y el
/// distintivo «sin riesgo de asfixia» se cortaba justo en «asfixia». Sus
/// tests no lo veían porque pintaban a 800 × 600 o a 400 × 2600.
///
/// El manejador de errores se pone DENTRO de cada test: puesto en `setUp`,
/// `testWidgets` lo sustituye mientras corre y la lista sale vacía siempre
/// (comprobado con un desborde de 300 px hecho a propósito, que pasaba en
/// verde).
void main() {
  late List<SteamUnit> unidades;

  setUpAll(() async {
    final crudo = await File(ContentAssetLoader.steamAssetPath).readAsString();
    unidades = ContentAssetLoader(stringLoader: (_) async => crudo)
        .parseSteamUnits(crudo);
  });

  Future<List<String>> medir(
    WidgetTester tester,
    Widget pantalla,
    double escala,
    Future<void> Function() recorrido,
  ) async {
    final errores = <String>[];
    final anterior = FlutterError.onError;
    FlutterError.onError = (d) {
      final donde = RegExp(r'steam_[a-z_]+\.dart:\d+')
              .firstMatch(d.toString())
              ?.group(0) ??
          '?';
      errores.add('${d.exceptionAsString().split('\n').first} @ $donde');
    };
    try {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(escala)),
          child: child!,
        ),
        home: pantalla,
      ));
      await tester.pumpAndSettle();
      await recorrido();
    } finally {
      FlutterError.onError = anterior;
      tester.view.reset();
    }
    return errores.toSet().toList();
  }

  Future<void> bajarHastaElFinal(WidgetTester tester, String lista) async {
    final scroll = find.descendant(
        of: find.byKey(ValueKey(lista)), matching: find.byType(Scrollable));
    for (var i = 0; i < 40; i++) {
      final antes = tester.state<ScrollableState>(scroll).position.pixels;
      await tester.drag(scroll, const Offset(0, -300), warnIfMissed: false);
      await tester.pumpAndSettle();
      if (tester.state<ScrollableState>(scroll).position.pixels == antes) {
        break;
      }
    }
  }

  // El medidor tiene que VER un desborde: si no lo ve, todo lo de abajo sale
  // verde sin haber comprobado nada.
  testWidgets('el medidor ve un desborde hecho a propósito', (tester) async {
    final errores = await medir(
      tester,
      const Scaffold(
        body: Row(children: [SizedBox(width: 500, height: 10)]),
      ),
      1.0,
      () async {},
    );
    expect(errores, isNotEmpty);
    expect(errores.first, contains('overflowed'));
  });

  for (final lang in AppLanguage.deInterfaz) {
    for (final escala in [1.0, 1.8]) {
      for (final audiencia in SteamAudiencia.values) {
        final etiqueta = '${lang.code}, ${audiencia.name}, escala $escala';

        testWidgets('el hub cabe ($etiqueta)', (tester) async {
          final repo = ContentRepository();
          for (final u in unidades) {
            repo.addSteamUnit(u);
          }
          final errores = await medir(
            tester,
            SteamHubScreen(
              repository: repo,
              audioService: MockOfflineAudioService(),
              initialLanguage: lang,
              audiencia: audiencia,
            ),
            escala,
            () => bajarHastaElFinal(tester, 'steam_hub_lista'),
          );
          expect(errores, isEmpty, reason: 'El hub desborda ($etiqueta)');
        });

        testWidgets('las cinco sesiones caben ($etiqueta)', (tester) async {
          final todos = <String>[];
          for (final u in unidades) {
            final errores = await medir(
              tester,
              SteamSesionGuiadaScreen(
                // Una clave por unidad: sin ella, Flutter reutiliza el estado
                // de la sesión anterior y la lista empieza abajo del todo.
                key: ValueKey(u.id),
                unit: u,
                audiencia: audiencia,
                audioService: MockOfflineAudioService(),
                initialLanguage: lang,
              ),
              escala,
              () async {
                // Las pistas abiertas: también tienen que caber.
                final scroll = find.descendant(
                    of: find.byKey(const ValueKey('steam_sesion_lista')),
                    matching: find.byType(Scrollable));
                for (final clave in ['steam_pista_1', 'steam_pista_2']) {
                  final pista = find.byKey(ValueKey(clave));
                  await tester.scrollUntilVisible(pista, 200,
                      scrollable: scroll);
                  await tester.tap(pista, warnIfMissed: false);
                  await tester.pumpAndSettle();
                }
                await bajarHastaElFinal(tester, 'steam_sesion_lista');
              },
            );
            todos.addAll(errores.map((e) => '${u.id}: $e'));
          }
          expect(todos, isEmpty, reason: 'Alguna sesión desborda ($etiqueta)');
        });
      }
    }
  }
}
