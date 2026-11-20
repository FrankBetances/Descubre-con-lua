import 'dart:io';

import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/audio/voice_id.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/storage/calendario_store.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/models/plan_escoita_model.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/docentes/views/hoxe_docentes_screen.dart';
import 'package:descubre_con_lua/features/docentes/views/recursos_docentes_screen.dart';
import 'package:descubre_con_lua/features/estimulacion/data/estimulacion_ui.dart';
import 'package:descubre_con_lua/features/estimulacion/views/estimulacion_screen.dart';
import 'package:descubre_con_lua/features/familias/views/explorar_familias_screen.dart';
import 'package:descubre_con_lua/features/familias/views/hoxe_familias_screen.dart';
import 'package:descubre_con_lua/features/familias/widgets/paso_escoita.dart';
import 'package:descubre_con_lua/features/leccions/widgets/proxecto_0_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestAssetBundle extends AssetBundle {
  final Set<String> audioPaths;
  _TestAssetBundle(this.audioPaths);

  @override
  Future<ByteData> load(String key) async {
    if (audioPaths.contains(key)) return ByteData(4);
    final f = File(key);
    if (f.existsSync()) {
      return ByteData.view(f.readAsBytesSync().buffer);
    }
    throw Exception('Asset not found: $key');
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final f = File(key);
    if (f.existsSync()) return f.readAsStringSync();
    return rootBundle.loadString(key, cache: cache);
  }

  @override
  void evict(String key) {}
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await EstimulacionUi.cargar();
    await Proxectos02.cargar();
    PlanEscoita.sembrar(
      PlanEscoita.fromRaw(
        File('assets/content/escoita/plan_mensual.json').readAsStringSync(),
      ),
    );
  });
  tearDownAll(() => PlanEscoita.sembrar(null));

  test('las 40 piezas tienen pensamiento STEAM en las cuatro edades', () async {
    final plan = PlanEscoita.fromRaw(
      File('assets/content/escoita/plan_mensual.json').readAsStringSync(),
    );
    expect(plan.pezas.length, 40);
    const cursos = ['curso_2_3', 'curso_3_4', 'curso_4_5', 'curso_5_6'];
    for (final c in cursos) {
      for (var mes = 1; mes <= 10; mes++) {
        final peza = plan.de(c, mes);
        expect(peza, isNotNull, reason: 'Falta pieza $c M$mes');
        expect(peza!.steamId, isNotEmpty, reason: 'Falta steamId $c M$mes');
        final pen = peza.pensamiento;
        expect(pen, isNotNull, reason: 'Falta pensamiento $c M$mes');
        expect(pen!.momentos.length, 4);
        for (final m in pen.momentos) {
          expect(m.preguntaEn, isNotEmpty);
          expect(m.significado.gl, isNotEmpty);
          expect(m.significado.es, isNotEmpty);
          expect(m.guia.gl, isNotEmpty);
          expect(m.guia.es, isNotEmpty);
          expect(m.observar.gl, isNotEmpty);
          expect(m.observar.es, isNotEmpty);
        }
        if (c == 'curso_2_3' || c == 'curso_3_4') {
          expect(pen.edadModo, 'elige_dos');
        } else if (c == 'curso_4_5') {
          expect(pen.edadModo, 'palabra_corta');
        } else {
          expect(pen.edadModo, 'explica_because');
          expect(
            pen.explica.modeloEn?.toLowerCase().contains('because'),
            isTrue,
            reason: '5-6 M$mes explica debe usar because',
          );
        }
      }
    }
  });

  group('EstimulacionScreen en gl y es a escala de texto 1.8', () {
    for (final lang in AppLanguage.deInterfaz) {
      for (final enAula in [false, true]) {
        testWidgets(
          '${lang.code} · ${enAula ? "Modo Aula" : "Na casa"} sin desbordes',
          (tester) async {
            tester.view.physicalSize = const Size(360, 780);
            tester.view.devicePixelRatio = 1.0;
            addTearDown(tester.view.reset);

            final audio = MockOfflineAudioService();
            addTearDown(audio.dispose);

            await tester.pumpWidget(
              MaterialApp(
                theme: AppTheme.lightTheme,
                builder: (ctx, child) => MediaQuery(
                  data: MediaQuery.of(ctx).copyWith(
                    textScaler: const TextScaler.linear(1.8),
                  ),
                  child: child!,
                ),
                home: EstimulacionScreen(
                  language: lang,
                  onLanguageChanged: (_) {},
                  audioService: audio,
                  initialCursoId: 'curso_3_4',
                  initialMes: 1,
                  enAula: enAula,
                ),
              ),
            );
            await tester.pumpAndSettle();

            expect(
                find.byKey(const Key('estimulacion_screen')), findsOneWidget);
            expect(
                find.byKey(const Key('estimulacion_titulo')), findsOneWidget);
            expect(find.byKey(const Key('estimulacion_steam_banner')),
                findsOneWidget);
            if (enAula) {
              expect(
                find.byKey(const Key('estimulacion_guia_asemblea')),
                findsOneWidget,
              );
            }
            for (var m = 1; m <= 10; m++) {
              expect(
                find.byKey(ValueKey('estimulacion_mes_$m')),
                findsOneWidget,
              );
            }

            // Cambiar al mes 6 antes de desplazarse abajo y comprobar que actualiza.
            final mes6 = find.byKey(const Key('estimulacion_mes_6'));
            await tester.scrollUntilVisible(
              mes6,
              150,
              scrollable: find.byType(Scrollable).first,
            );
            await tester.ensureVisible(mes6);
            await tester.pumpAndSettle();
            await tester.tap(mes6);
            await tester.pumpAndSettle();
            tester
                .state<ScrollableState>(find.byType(Scrollable).first)
                .position
                .jumpTo(0);
            await tester.pumpAndSettle();
            expect(find.textContaining('Mes 6 ·'), findsOneWidget);

            // Desplazar para comprobar los 4 bloques y los 4 momentos de Pensamos.
            await tester.scrollUntilVisible(
              find.byKey(const Key('bloque_estimulacion_escoita')),
              350,
              scrollable: find.byType(Scrollable).first,
            );
            await tester.pumpAndSettle();
            expect(
              find.byKey(const Key('bloque_estimulacion_escoita')),
              findsOneWidget,
            );

            await tester.scrollUntilVisible(
              find.byKey(const Key('bloque_estimulacion_pensamos')),
              400,
              scrollable: find.byType(Scrollable).first,
            );
            await tester.pumpAndSettle();
            expect(
              find.byKey(const Key('bloque_estimulacion_pensamos')),
              findsOneWidget,
            );
            for (final k in ['predice', 'proba', 'compara', 'explica']) {
              await tester.scrollUntilVisible(
                find.byKey(ValueKey('estimulacion_momento_$k')),
                250,
                scrollable: find.byType(Scrollable).first,
              );
              expect(
                find.byKey(ValueKey('estimulacion_momento_$k')),
                findsOneWidget,
              );
            }
          },
        );
      }
    }

    testWidgets('0-2 mostra o proxecto e o momento Mira e nota sen preguntas',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: EstimulacionScreen(
            language: AppLanguage.gl,
            onLanguageChanged: (_) {},
            initialCursoId: 'curso_0_2',
            initialMes: 1,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bloque_estimulacion_0_2')), findsOneWidget);
    });
  });

  group('Botón Oír amodo / Oír despacio na sección pide slow', () {
    for (final lang in AppLanguage.deInterfaz) {
      testWidgets('en ${lang.code}, preme slow nun momento de Pensamos',
          (tester) async {
        final plan = PlanEscoita.fromRaw(
          File('assets/content/escoita/plan_mensual.json').readAsStringSync(),
        );
        PlanEscoita.sembrar(plan);
        addTearDown(() => PlanEscoita.sembrar(null));

        final peza = plan.de('curso_2_3', 1)!;
        final pregunta = peza.pensamiento!.predice.preguntaEn;
        final rutaChild =
            voiceAssetPath(VoiceStyle.child, pregunta, AppLanguage.en);
        final rutaSlow =
            voiceAssetPath(VoiceStyle.slow, pregunta, AppLanguage.en);
        final bundle = _TestAssetBundle({rutaChild, rutaSlow});
        final audio = MockOfflineAudioService();
        addTearDown(audio.dispose);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: DefaultAssetBundle(
              bundle: bundle,
              child: EstimulacionScreen(
                language: lang,
                onLanguageChanged: (_) {},
                audioService: audio,
                initialCursoId: 'curso_2_3',
                initialMes: 1,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final cardPredice =
            find.byKey(const ValueKey('estimulacion_momento_predice'));
        await tester.scrollUntilVisible(
          cardPredice,
          350,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();

        final etiquetaLenta =
            lang == AppLanguage.gl ? 'Oír amodo' : 'Oír despacio';
        final botonLenta = find.descendant(
          of: cardPredice,
          matching: find.text(etiquetaLenta),
        );
        await tester.ensureVisible(botonLenta.first);
        await tester.tap(botonLenta.first);
        await tester.pumpAndSettle();

        expect(audio.currentAssetPath, rutaSlow);
      });
    }
  });

  group('Entradas principais en Na casa, Modo Aula e dentro da lección', () {
    testWidgets('Na casa (Hoxe e Explorar) e Modo Aula (Hoxe e Recursos)',
        (tester) async {
      final repo = ContentRepository();
      final store = CalendarioStore();
      await tester.runAsync(() async {
        await repo.loadCuentos();
        await repo.loadProgramaTpr();
        await repo.loadSteamUnits();
        await Proxectos02.cargar();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: HoxeFamiliasScreen(
            repository: repo,
            store: store,
            language: AppLanguage.gl,
            onLanguageChanged: (_) {},
            cursoId: 'curso_3_4',
            onCambiarCurso: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('entrada_estimulacion_casa')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
          find.byKey(const Key('entrada_estimulacion_casa')), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ExplorarFamiliasScreen(
            repository: repo,
            language: AppLanguage.es,
            onLanguageChanged: (_) {},
            cursoId: 'curso_3_4',
            onCambiarCurso: (_) {},
            audioService: MockOfflineAudioService(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('explorar_estimulacion')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
          find.byKey(const ValueKey('explorar_estimulacion')), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: HoxeDocentesScreen(
            repository: repo,
            language: AppLanguage.gl,
            onLanguageChanged: (_) {},
            cursoId: 'curso_3_4',
            onCambiarCurso: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('entrada_estimulacion_aula')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
          find.byKey(const Key('entrada_estimulacion_aula')), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: RecursosDocentesScreen(
            repository: repo,
            language: AppLanguage.es,
            onLanguageChanged: (_) {},
            cursoId: 'curso_3_4',
            audioService: MockOfflineAudioService(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('recurso_estimulacion')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
          find.byKey(const ValueKey('recurso_estimulacion')), findsOneWidget);
    });

    testWidgets('VistaPasoEscoita enlaza coa sección sen quitar pasos',
        (tester) async {
      final plan = PlanEscoita.fromRaw(
        File('assets/content/escoita/plan_mensual.json').readAsStringSync(),
      );
      final paso = PasoEscoita(semana: 1, peza: plan.de('curso_2_3', 1)!);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: VistaPasoEscoita(
                paso: paso,
                lang: AppLanguage.gl,
                audioService: null,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('paso_escoita_ver_seccion')), findsOneWidget);
      await tester.tap(find.byKey(const Key('paso_escoita_ver_seccion')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('estimulacion_screen')), findsOneWidget);
    });
  });
}
