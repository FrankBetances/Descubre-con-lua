import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/models/plan_escoita_model.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/docentes/views/recursos_docentes_screen.dart';
import 'package:descubre_con_lua/features/estimulacion/ar/ar_bridge.dart';
import 'package:descubre_con_lua/features/estimulacion/data/ar_estimulacion_model.dart';
import 'package:descubre_con_lua/features/estimulacion/data/estimulacion_ui.dart';
import 'package:descubre_con_lua/features/estimulacion/views/ar_actividad_screen.dart';
import 'package:descubre_con_lua/features/estimulacion/views/estimulacion_screen.dart';
import 'package:descubre_con_lua/features/familias/views/explorar_familias_screen.dart';
import 'package:descubre_con_lua/features/leccions/widgets/proxecto_0_2.dart';

class _DiskJsonBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final file = File(key);
    if (!file.existsSync()) {
      throw FlutterError('Asset not found: $key');
    }
    final bytes = await file.readAsBytes();
    return ByteData.sublistView(bytes);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.earlify.descubreconlua/ar');

  setUpAll(() async {
    await EstimulacionUi.cargar();
    await Proxectos02.cargar();
    await ArEstimulacionPlan.cargar();
    PlanEscoita.sembrar(
      PlanEscoita.fromRaw(
        File('assets/content/escoita/plan_mensual.json').readAsStringSync(),
      ),
    );
  });

  tearDownAll(() => PlanEscoita.sembrar(null));

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('ArEstimulacionPlan', () {
    test(
        'carga 40 escenas (2-3 a 5-6 x 10 meses) y 6 espellos faciais sen texto clínico',
        () async {
      final plan = await ArEstimulacionPlan.cargar(bundle: _DiskJsonBundle());
      expect(plan.escenas.length, 40);
      expect(plan.actividadesFaciais.length, 6);

      const mapaFenomenos = <String, Set<String>>{
        'materia': {'S0', 'S5'},
        'acustica': {'S2', 'S4'},
        'cinematica': {'S1', 'S3'},
        'optica': {'S6'},
        'logica': {'S8', 'S9', 'S10', 'S11', 'L02', 'L03', 'L04', 'L05'},
      };

      for (final curso in [
        'curso_2_3',
        'curso_3_4',
        'curso_4_5',
        'curso_5_6'
      ]) {
        for (var mes = 1; mes <= 10; mes++) {
          final e = plan.escenaDe(curso, mes);
          expect(e, isNotNull, reason: '$curso mes $mes');
          expect(e!.curso, curso);
          expect(e.mes, mes);
          final esperadas = mapaFenomenos[e.fenomeno];
          expect(esperadas, isNotNull, reason: 'Fenómeno ${e.fenomeno}');
          expect(esperadas!.contains(e.valeriaSceneId), isTrue,
              reason: '${e.id}: ${e.fenomeno} -> ${e.valeriaSceneId}');
          expect(e.palabrasEn, isNotEmpty);
          expect(e.frasesEn, isNotEmpty);
          expect(e.laminasSuporte, isNotEmpty);
        }
      }
    });
  });

  group('MethodChannelArBridge mock', () {
    test('abre escena e espello facial e non crea ficheiros en getFilesDir',
        () async {
      final fakeFilesDir =
          Directory.systemTemp.createTempSync('lua_ar_privacidad_');
      addTearDown(() => fakeFilesDir.deleteSync(recursive: true));

      final chamadas = <String>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        chamadas.add(call.method);
        if (call.method == 'checkAvailability') {
          return <String, Object?>{
            'available': true,
            'hasCamera': true,
            'hasFrontCamera': true,
            'arCoreSupported': true,
            'modelShaOk': true,
            'reason': 'OK',
          };
        }
        if (call.method == 'openScene') {
          final spec = jsonDecode((call.arguments as Map)['specJson'] as String)
              as Map<String, dynamic>;
          expect(spec['events'], isA<List>());
          return jsonEncode({
            'outcome': 'completed',
            'confirmed': ['ev1'],
            'gestureDone': false,
          });
        }
        if (call.method == 'openFaceActivity') {
          return jsonEncode({
            'outcome': 'completed',
            'confirmed': const <String>[],
            'gestureDone': true,
          });
        }
        return null;
      });

      const bridge = MethodChannelArBridge();
      final av = await bridge.checkAvailability();
      expect(av.available, isTrue);
      expect(av.hasCamera, isTrue);
      expect(av.hasFrontCamera, isTrue);
      expect(av.arCoreSupported, isTrue);
      expect(av.modelShaOk, isTrue);

      final plan = await ArEstimulacionPlan.cargar(bundle: _DiskJsonBundle());
      final escena = plan.escenaDe('curso_3_4', 1)!;
      final resScene =
          await bridge.openScene(escena.toNativeSpecJson(AppLanguage.gl));
      expect(resScene.outcome, 'completed');
      expect(resScene.confirmed, ['ev1']);

      final facial = plan.facialDe(escena.faceId)!;
      final resFace = await bridge
          .openFaceActivity(facial.toNativeSpecJson(AppLanguage.es));
      expect(resFace.outcome, 'completed');
      expect(resFace.gestureDone, isTrue);

      expect(chamadas, ['checkAvailability', 'openScene', 'openFaceActivity']);
      expect(fakeFilesDir.listSync(recursive: true), isEmpty);
    });

    test('sen cámara nin ARCore ou sen plugin devolve fallback sen pechar',
        () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'checkAvailability') {
          return <String, Object?>{
            'available': false,
            'hasCamera': false,
            'hasFrontCamera': false,
            'arCoreSupported': false,
            'modelShaOk': true,
            'reason': 'NO_CAMERA',
          };
        }
        return jsonEncode({
          'outcome': 'unsupported',
          'reason': 'NO_ARCORE',
        });
      });

      const bridge = MethodChannelArBridge();
      final av = await bridge.checkAvailability();
      expect(av.available, isFalse);
      expect(av.hasCamera, isFalse);
      expect(av.arCoreSupported, isFalse);

      final res = await bridge.openScene('{}');
      expect(res.needsFallback, isTrue);

      // Sen canle nativo (MissingPluginException) tampoco lanza excepción.
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      final avMissing = await bridge.checkAvailability();
      expect(avMissing.available, isFalse);
      final resMissing = await bridge.openFaceActivity('{}');
      expect(resMissing.needsFallback, isTrue);
    });
  });

  group('ArActividadScreen e entradas en gl e es a escala 1.8', () {
    Future<void> montarEComprobar(
      WidgetTester tester, {
      required AppLanguage lang,
      required ArBridge bridge,
      required bool esperaAvisoFallback,
    }) async {
      final overflows = <FlutterErrorDetails>[];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('overflowed') ||
            details.exceptionAsString().contains('OVERFLOWING')) {
          overflows.add(details);
        } else {
          oldHandler?.call(details);
        }
      };
      addTearDown(() => FlutterError.onError = oldHandler);

      await tester.binding.setSurfaceSize(const Size(412, 915));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final fakeFilesDir =
          Directory.systemTemp.createTempSync('lua_ar_screen_files_');
      addTearDown(() => fakeFilesDir.deleteSync(recursive: true));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.temaFamilias
              .copyWith(splashFactory: InkRipple.splashFactory),
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(412, 915),
              textScaler: TextScaler.linear(1.8),
            ),
            child: ArActividadScreen(
              language: lang,
              onLanguageChanged: (_) {},
              arBridge: bridge,
              initialCursoId: 'curso_3_4',
              initialMes: 1,
            ),
          ),
        ),
      );
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 120)));
      await tester.pump();
      await tester.pumpAndSettle();

      final scrollable = find.byType(Scrollable).first;
      expect(find.byKey(const Key('ar_actividad_screen')), findsOneWidget);
      if (esperaAvisoFallback) {
        await tester.scrollUntilVisible(
            find.byKey(const Key('ar_aviso_sen_camara')), 200,
            scrollable: scrollable);
        expect(find.byKey(const Key('ar_aviso_sen_camara')), findsOneWidget);
      }

      await tester.scrollUntilVisible(
          find.byKey(const Key('ar_btn_abrir_mesa')), 200,
          scrollable: scrollable);
      expect(find.byKey(const Key('ar_btn_abrir_mesa')), findsOneWidget);
      if (!esperaAvisoFallback) {
        await tester.ensureVisible(find.byKey(const Key('ar_btn_abrir_mesa')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('ar_btn_abrir_mesa')));
        await tester.pumpAndSettle();
      }

      await tester.scrollUntilVisible(
          find.byKey(const Key('ar_btn_abrir_espello')), 200,
          scrollable: scrollable);
      expect(find.byKey(const Key('ar_btn_abrir_espello')), findsOneWidget);
      if (!esperaAvisoFallback) {
        await tester
            .ensureVisible(find.byKey(const Key('ar_btn_abrir_espello')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('ar_btn_abrir_espello')));
        await tester.pumpAndSettle();
      } else {
        await tester.scrollUntilVisible(
            find.byKey(const Key('ar_version_sen_camara')), 200,
            scrollable: scrollable);
        expect(find.byKey(const Key('ar_version_sen_camara')), findsOneWidget);
      }

      await tester.scrollUntilVisible(
          find.byKey(const Key('ar_privacidade_nota')), 200,
          scrollable: scrollable);
      expect(find.byKey(const Key('ar_privacidade_nota')), findsOneWidget);

      expect(overflows, isEmpty);
      expect(fakeFilesDir.listSync(recursive: true), isEmpty);
    }

    testWidgets('gl con AR dispoñible a escala 1.8', (tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'checkAvailability') {
          return <String, Object?>{
            'available': true,
            'hasCamera': true,
            'hasFrontCamera': true,
            'arCoreSupported': true,
            'modelShaOk': true,
            'reason': 'OK',
          };
        }
        return jsonEncode({
          'outcome': 'completed',
          'confirmed': ['ev1'],
          'gestureDone': true,
        });
      });

      await montarEComprobar(
        tester,
        lang: AppLanguage.gl,
        bridge: const MethodChannelArBridge(),
        esperaAvisoFallback: false,
      );
    });

    testWidgets('es sen ARCore nin cámara mostra alternativa a escala 1.8',
        (tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'checkAvailability') {
          return <String, Object?>{
            'available': false,
            'hasCamera': false,
            'hasFrontCamera': false,
            'arCoreSupported': false,
            'modelShaOk': true,
            'reason': 'NO_ARCORE',
          };
        }
        return jsonEncode({'outcome': 'unsupported', 'reason': 'NO_ARCORE'});
      });

      await montarEComprobar(
        tester,
        lang: AppLanguage.es,
        bridge: const MethodChannelArBridge(),
        esperaAvisoFallback: true,
      );
    });

    testWidgets('entradas en Estimulación, Explorar e Recursos en gl e es',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(412, 915));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final repo = ContentRepository();
      final audio = MockOfflineAudioService();

      for (final lang in [AppLanguage.gl, AppLanguage.es]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.temaFamilias,
            home: EstimulacionScreen(
              language: lang,
              onLanguageChanged: (_) {},
              enAula: false,
            ),
          ),
        );
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 120)));
        await tester.pump();
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.byKey(const Key('bloque_estimulacion_ra')),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.byKey(const Key('bloque_estimulacion_ra')), findsOneWidget);
        expect(find.byKey(const Key('estimulacion_abrir_ra')), findsOneWidget);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.temaFamilias,
            home: ExplorarFamiliasScreen(
              repository: repo,
              language: lang,
              onLanguageChanged: (_) {},
              cursoId: 'curso_3_4',
              onCambiarCurso: (_) {},
              audioService: audio,
            ),
          ),
        );
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 120)));
        await tester.pump();
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('explorar_ra')),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.byKey(const ValueKey('explorar_ra')), findsOneWidget);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.temaDocentes,
            home: RecursosDocentesScreen(
              repository: repo,
              language: lang,
              onLanguageChanged: (_) {},
              cursoId: 'curso_3_4',
              audioService: audio,
            ),
          ),
        );
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 120)));
        await tester.pump();
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('recurso_ra')),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.byKey(const ValueKey('recurso_ra')), findsOneWidget);
      }
    });
  });
}
