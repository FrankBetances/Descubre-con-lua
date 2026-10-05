import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/storage/calendario_store.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/loaders/content_asset_loader.dart';
import 'package:descubre_con_lua/data/models/asamblea_segundo_ciclo_model.dart';
import 'package:descubre_con_lua/data/models/lectura_model.dart';
import 'package:descubre_con_lua/data/models/tpr_curriculum_scheduler.dart';
import 'package:descubre_con_lua/data/models/xogos_fogar_model.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/calendario/views/calendario_fogar_screen.dart';
import 'package:descubre_con_lua/features/familias/nomes_familias.dart';
import 'package:descubre_con_lua/features/familias/views/xogos_fogar_screen.dart';
import 'package:descubre_con_lua/features/juega/views/asamblea_player_screen.dart';
import 'package:descubre_con_lua/features/laminas/views/laminas_gallery_screen.dart';
import 'package:descubre_con_lua/features/lectura/views/aprender_a_ler_screen.dart';

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

  group('O castelán e o plural', () {
    late ContentRepository repo;
    late CalendarioStore store;
    late Directory dir;

    setUpAll(() async {
      Future<String> ler(String p) => File(p).readAsString();
      repo = ContentRepository(loader: ContentAssetLoader(stringLoader: ler));
      await repo.initialize(unidadPaths: const [], capsulaPaths: const []);
      repo.addProgramaTpr(await ProgramaTpr.cargar(stringLoader: ler));
      // Fuera del testWidgets: dentro, el reloj es falso y una lectura de
      // disco no termina.
      await repo.loadCalendarioDias(cursoId: '');
      await repo.loadLaminas();
    });

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('ux_l7_');
      store = CalendarioStore(overrideDirectory: dir.path);
      await store.cargar();
    });

    tearDown(() async {
      if (await dir.exists()) await dir.delete(recursive: true);
    });

    Future<void> pintar(WidgetTester tester, Widget w) async {
      tester.view.physicalSize = const Size(400, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester
          .pumpWidget(MaterialApp(theme: AppTheme.temaFamilias, home: w));
      await tester.pumpAndSettle();
    }

    for (final lang in AppLanguage.deInterfaz) {
      final esperado = lang == AppLanguage.gl ? 'do curso' : 'del curso';

      testWidgets('o calendario da casa di «Día N $esperado» (${lang.code})',
          (tester) async {
        await pintar(
          tester,
          CalendarioFogarScreen(
            repository: repo,
            store: store,
            initialLanguage: lang,
            initialCursoId: 'curso_0_2',
            audioService: MockOfflineAudioService(),
            agora: DateTime(2026, 10, 2),
          ),
        );
        expect(find.textContaining(RegExp('^Día [0-9]+ $esperado\$')),
            findsOneWidget);
        if (lang == AppLanguage.es) {
          expect(find.textContaining(RegExp(r'^Día [0-9]+ do curso$')),
              findsNothing);
        }
      });

      testWidgets('unha soa lámina vai en singular (${lang.code})',
          (tester) async {
        await pintar(
          tester,
          LaminasGalleryScreen(
            repository: repo,
            initialLanguage: lang,
            audioService: MockOfflineAudioService(),
          ),
        );
        final gl = lang == AppLanguage.gl;
        expect(
            find.textContaining(RegExp(gl
                ? r'^[0-9]+ láminas dispoñibles$'
                : r'^[0-9]+ láminas disponibles$')),
            findsOneWidget);
        await tester.enterText(
            find.byType(TextField), gl ? 'mazá vermella' : 'manzana roja');
        await tester.pumpAndSettle();
        expect(find.text(gl ? '1 lámina dispoñible' : '1 lámina disponible'),
            findsOneWidget);
      });
    }
  });

  group('Os arranxos menores', () {
    final xogos =
        XogosFogar.fromRaw(File(XogosFogar.assetPath).readAsStringSync());
    final lectura = ContidoLectura.fromRaw(
        File(ContidoLectura.assetPath).readAsStringSync());

    test('os dez xogos de movemento veñen do JSON e non do widget', () {
      expect(xogos.xogos, hasLength(10));
      final pantalla =
          File('lib/features/familias/views/xogos_fogar_screen.dart')
              .readAsStringSync();
      for (final x in xogos.xogos) {
        expect(pantalla.contains(x.fraseEn), isFalse,
            reason: '${x.id}: a frase segue escrita no widget');
      }
    });

    test('os títulos dos xogos levan maiúscula só ao principio', () {
      // Nomes propios e a orde inglesa que dá nome ao xogo.
      const propios = {'Samil', 'Lúa', 'Freeze'};
      final fallos = <String>[];
      for (final x in xogos.xogos) {
        for (final titulo in [x.titulo.gl, x.titulo.es]) {
          final palabras = titulo.split(' ');
          for (final p in palabras.skip(1)) {
            if (p.isNotEmpty &&
                p[0] != p[0].toLowerCase() &&
                !propios.contains(p)) {
              fallos.add('${x.id}: «$titulo»');
            }
          }
        }
      }
      expect(fallos, isEmpty, reason: fallos.join('\n'));
    });

    test('ningunha ruta con nome á que nada navega', () {
      final main = File('lib/main.dart').readAsStringSync();
      final declaradas = RegExp(r"^\s+'(/[^']*)':", multiLine: true)
          .allMatches(main)
          .map((m) => m.group(1)!)
          .toList();
      expect(declaradas, isNotEmpty);
      final lib = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .map((f) => f.readAsStringSync())
          .join('\n');
      final mortas = [
        for (final r in declaradas)
          if (r != '/' && !lib.contains("pushNamed('$r')")) r,
      ];
      expect(mortas, isEmpty, reason: 'rutas sen ningún pushNamed: $mortas');
      expect(main.contains('onGenerateRoute'), isFalse);
    });

    for (final lang in AppLanguage.deInterfaz) {
      testWidgets(
          'as pestanas de «Ler xogando» din o que se fai (${lang.code})',
          (tester) async {
        tester.view.physicalSize = const Size(400, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.temaFamilias,
          home: AprenderALerScreen(
            repository: contenido,
            initialLanguage: lang,
            audioService: MockOfflineAudioService(),
            contido: lectura,
          ),
        ));
        await tester.pumpAndSettle();
        for (final nome in [
          NomesFamilias.lerPestanaSons,
          NomesFamilias.lerPestanaLetras,
          NomesFamilias.lerPestanaCubos,
          NomesFamilias.lerPestanaPares,
        ]) {
          expect(find.widgetWithText(Tab, nome.resolve(lang)), findsOneWidget);
        }
        expect(find.textContaining('Alphabot'), findsNothing);
        expect(find.textContaining('CVC'), findsNothing);
      });

      testWidgets('os xogos de movemento pintan o seu título (${lang.code})',
          (tester) async {
        tester.view.physicalSize = const Size(400, 12000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.temaFamilias,
          home: XogosFogarScreen(initialLanguage: lang, xogos: xogos),
        ));
        await tester.pumpAndSettle();
        for (final x in xogos.xogos) {
          expect(find.text(x.titulo.resolve(lang)), findsOneWidget,
              reason: x.id);
        }
      });
    }
  });

  group('O contido que Frank mandou quitar', () {
    String ler(String p) => File(p).readAsStringSync();

    test('a dinámica do luns xa non leva «72 bpm» no título', () {
      final dinamicas =
          jsonDecode(ler('assets/content/dinamicas_aula.json')) as List;
      for (final d in dinamicas) {
        final titulo = (d as Map)['titulo'] as Map;
        for (final t in titulo.values) {
          expect((t as String).toLowerCase().contains('bpm'), isFalse,
              reason: t);
        }
      }
    });

    test('ningunha dinámica propón un difusor de esencias', () {
      expect(ler('assets/content/dinamicas_aula.json').toLowerCase(),
          isNot(contains('difusor')));
    });

    test('os pares mínimos non piden tapar a boca', () {
      // Lo que se quitó: tapar la boca para que la criatura no lea los
      // labios. Poner la mano delante de la boca para notar el aire de /t/
      // es otra cosa, una pista táctil, y se queda.
      final lectura = jsonDecode(ler(ContidoLectura.assetPath)) as Map;
      for (final par in lectura['paresMinimos'] as List) {
        for (final t in ((par as Map)['instrucion'] as Map).values) {
          final texto = (t as String).toLowerCase();
          final tapa = texto.contains('tapa') && texto.contains('boca');
          expect(
              tapa ||
                  texto.contains('beizos') ||
                  texto.contains('labios') ||
                  texto.contains('papel'),
              isFalse,
              reason: t);
        }
      }
    });

    test('ningunha cápsula nin formación fala de circuítos neurais', () {
      final fallos = <String>[];
      for (final dir in [
        'assets/content/capsulas',
        'assets/content/formacion'
      ]) {
        for (final f in Directory(dir).listSync().whereType<File>()) {
          final texto = f.readAsStringSync().toLowerCase();
          if (texto.contains('circuítos neurais') ||
              texto.contains('circuitos neuronales') ||
              texto.contains('circuitos neurales')) {
            fallos.add(f.path);
          }
        }
      }
      expect(fallos, isEmpty, reason: fallos.join('\n'));
    });
  });
}
