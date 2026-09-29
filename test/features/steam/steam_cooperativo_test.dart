import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/data/loaders/content_asset_loader.dart';
import 'package:descubre_con_lua/data/models/steam_cooperativo_model.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/data/validators/content_validator.dart';
import 'package:descubre_con_lua/features/docentes/portal_docentes_screen.dart';
import 'package:descubre_con_lua/features/familias/portal_familias_screen.dart';
import 'package:descubre_con_lua/features/steam/views/steam_hub_screen.dart';
import 'package:descubre_con_lua/features/steam/views/steam_sesion_guiada_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final validator = ContentValidator();
  final jsonFile = File('assets/content/steam/banco_steam_cooperativo.json');

  group('STEAM Cooperativo - Data Layer & Safeguards', () {
    test('JSON asset exists on disk and is well-formed', () {
      expect(jsonFile.existsSync(), isTrue,
          reason: 'banco_steam_cooperativo.json must exist');
      final content = jsonFile.readAsStringSync();
      final dynamic decoded = jsonDecode(content);
      expect(decoded, isA<List>());
      expect((decoded as List).length, equals(5),
          reason: 'Must contain exactly the 5 canonical I1..I5 units');
    });

    test('All 5 canonical units parse into SteamUnit models', () {
      final loader = ContentAssetLoader(
        stringLoader: (path) async => jsonFile.readAsStringSync(),
      );
      final units = loader.parseSteamUnits(jsonFile.readAsStringSync());
      expect(units.length, equals(5));

      final ids = units.map((u) => u.id).toList();
      expect(ids, containsAll([
        'I1-MATERIA-001',
        'I2-CINEMATICA-001',
        'I3-ACUSTICA-001',
        'I4-OPTICA-001',
        'I5-LOGICA-001',
      ]));

      for (final u in units) {
        expect(u.titulo.gl, isNotEmpty);
        expect(u.titulo.es, isNotEmpty);
        expect(u.fenomeno.gl, isNotEmpty);
        expect(u.fenomeno.es, isNotEmpty);
        expect(u.dinamicaCooperativa.roles.length, greaterThanOrEqualTo(2));
        expect(u.materiales, isNotEmpty);
        expect(u.tprIngles.comando, isNotEmpty);
        expect(u.tprIngles.ipa, isNotEmpty);
        expect(u.tprIngles.audioAsset, isNotEmpty);
      }
    });

    test('Strict validation via ContentValidator.validateSteamBankJson', () {
      final jsonArray =
          jsonDecode(jsonFile.readAsStringSync()) as List<dynamic>;
      final result = validator.validateSteamBankJson(jsonArray,
          sourcePath: 'banco_steam_cooperativo.json');

      expect(
        result.isValid,
        isTrue,
        reason:
            'STEAM bank failed validation:\n${result.errors.join("\n")}',
      );
    });

    test('Choking hazard prevention: materials > 4 cm for under 3 years (I1 and I2)', () {
      final loader = ContentAssetLoader(
        stringLoader: (path) async => jsonFile.readAsStringSync(),
      );
      final units = loader.parseSteamUnits(jsonFile.readAsStringSync());

      final uI1 = units.firstWhere((u) => u.nivelMadurativo == 'I1');
      final uI2 = units.firstWhere((u) => u.nivelMadurativo == 'I2');

      for (final m in uI1.materiales) {
        expect(m.seguridadMayor4cm, isTrue,
            reason: 'Material ${m.item.es} in I1 must be > 4 cm');
      }
      for (final m in uI2.materiales) {
        expect(m.seguridadMayor4cm, isTrue,
            reason: 'Material ${m.item.es} in I2 must be > 4 cm');
      }
    });

    test('TPR Audio assets physically exist in assets/voice/', () {
      final loader = ContentAssetLoader(
        stringLoader: (path) async => jsonFile.readAsStringSync(),
      );
      final units = loader.parseSteamUnits(jsonFile.readAsStringSync());

      for (final u in units) {
        final audioPath = u.tprIngles.audioAsset;
        final file = File(audioPath);
        expect(file.existsSync(), isTrue,
            reason: 'Audio file for unit ${u.id} must exist at $audioPath');
      }
    });

    test('SteamUnit model supports roundtrip toJson/fromJson and operator ==', () {
      final loader = ContentAssetLoader(
        stringLoader: (path) async => jsonFile.readAsStringSync(),
      );
      final units = loader.parseSteamUnits(jsonFile.readAsStringSync());
      for (final u in units) {
        final jsonMap = u.toJson();
        final reconstructed = SteamUnit.fromJson(jsonMap);
        expect(reconstructed.id, equals(u.id));
        expect(reconstructed, equals(u));
        expect(reconstructed.hashCode, equals(u.hashCode));
      }
    });
  });

  group('STEAM Cooperativo - Repository Integration', () {
    late ContentRepository repo;

    setUp(() {
      final loader = ContentAssetLoader(
        stringLoader: (path) async => jsonFile.readAsStringSync(),
      );
      repo = ContentRepository(loader: loader);
    });

    test('Loads steam units and caches in memory', () async {
      expect(repo.steamUnits, isEmpty);
      final units = await repo.loadSteamUnits();
      expect(units.length, equals(5));
      expect(repo.steamUnitCount, equals(5));

      final i3 = repo.getSteamUnitById('I3-ACUSTICA-001');
      expect(i3, isNotNull);
      expect(i3?.tprIngles.comando, equals('Listen'));

      final byStage = repo.getSteamUnitsByEstadio('curso_3_4');
      expect(byStage.length, equals(1));
      expect(byStage.first.id, equals('I3-ACUSTICA-001'));

      final byNivel = repo.getSteamUnitByNivel('I5');
      expect(byNivel?.id, equals('I5-LOGICA-001'));

      repo.clear();
      expect(repo.steamUnits, isEmpty);
      expect(repo.steamUnitCount, equals(0));
    });

    test('initialize() automatically loads STEAM units into repository', () async {
      final loader = ContentAssetLoader(
        stringLoader: (path) async => jsonFile.readAsStringSync(),
      );
      final newRepo = ContentRepository(loader: loader);
      expect(newRepo.steamUnits, isEmpty);

      await newRepo.initialize(
        unidadPaths: const [],
        capsulaPaths: const [],
        asambleaSegundoCicloPaths: const [],
      );

      expect(newRepo.steamUnits.length, equals(5));
      expect(newRepo.getSteamUnitById('I1-MATERIA-001'), isNotNull);
    });

    test('loadSteamUnits records ContentLoadFailure on error', () async {
      final brokenLoader = ContentAssetLoader(
        stringLoader: (path) async => throw const FileSystemException('Corrupted file'),
      );
      final brokenRepo = ContentRepository(loader: brokenLoader);
      final result = await brokenRepo.loadSteamUnits();
      expect(result, isEmpty);
      expect(brokenRepo.loadErrors, isNotEmpty);
      expect(brokenRepo.loadErrors.first.path, equals(ContentAssetLoader.steamAssetPath));
    });
  });

  group('STEAM Cooperativo - Flutter UI Screens', () {
    late MockOfflineAudioService mockAudio;
    late ContentRepository repo;

    setUp(() {
      mockAudio = MockOfflineAudioService();
      final loader = ContentAssetLoader(
        stringLoader: (path) async => jsonFile.readAsStringSync(),
      );
      repo = ContentRepository(loader: loader);
    });

    tearDown(() {
      mockAudio.dispose();
    });

    testWidgets('SteamHubScreen displays units, filters by level and toggles language',
        (tester) async {
      await repo.loadSteamUnits();

      await tester.pumpWidget(
        MaterialApp(
          home: SteamHubScreen(
            repository: repo,
            audioService: mockAudio,
            initialLanguage: AppLanguage.gl,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Title & header elements in Galician
      expect(find.text('STEAM Cooperativo · Indagación e TPR'), findsOneWidget);
      expect(find.text('ZERO-SCREEN CHILD INTERACTION'), findsOneWidget);

      // Verify that canonical units are displayed
      expect(find.text('O segredo da la suave e o cubo de madeira'),
          findsOneWidget);
      expect(find.text('A rampla de cartón e a carreira do cilindro'),
          findsOneWidget);

      // Filter by I3
      final i3Chip = find.text('I3 · 3-4 anos');
      expect(i3Chip, findsOneWidget);
      await tester.ensureVisible(i3Chip);
      await tester.tap(i3Chip);
      await tester.pumpAndSettle();

      // In I3 filter, only the acoustic unit is shown
      expect(find.text('O arroz saltarín e a membrana sonora'), findsOneWidget);
      expect(find.text('O segredo da la suave e o cubo de madeira'),
          findsNothing);
    });

    testWidgets('SteamSesionGuiadaScreen guided flow: Galician Constrúe, Socratic timer, TPR, 1-Tap log',
        (tester) async {
      tester.view.physicalSize = const Size(400, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await repo.loadSteamUnits();
      final unit = repo.getSteamUnitById('I1-MATERIA-001')!;

      await tester.pumpWidget(
        MaterialApp(
          home: SteamSesionGuiadaScreen(
            unit: unit,
            audioService: mockAudio,
            initialLanguage: AppLanguage.gl,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Steps: Observa, Experimenta, Constrúe (Make) in Galician!
      expect(find.text('Paso 1 · Observa'), findsOneWidget);
      expect(find.text('Paso 2 · Experimenta'), findsOneWidget);
      expect(find.text('Paso 3 · Constrúe (Make)'), findsOneWidget);

      // Verify Roles
      expect(find.text('Exploradora da la'), findsOneWidget);
      expect(find.text('Explorador da madeira'), findsOneWidget);

      // Test Socratic Timer with dynamic duration
      final timerBtn = find.text('Pausa socrática de silencio (5 s)');
      expect(timerBtn, findsOneWidget);
      await tester.ensureVisible(timerBtn);
      await tester.tap(timerBtn);
      await tester.pump();

      // Advances 1 second
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Silencio de observación: 4 s...'), findsOneWidget);

      // Advances until completion
      await tester.pump(const Duration(seconds: 4));
      expect(find.text('Pausa completada (5 s)'), findsOneWidget);

      // Test TPR Audio button
      final audioBtn = find.byKey(const ValueKey('boton_tpr_audio'));
      expect(audioBtn, findsOneWidget);
      await tester.ensureVisible(audioBtn);
      await tester.tap(audioBtn);
      await tester.pump();

      expect(mockAudio.callLog, contains('playAsset:${unit.tprIngles.audioAsset}'));

      // Test 1-Tap Logging Matrix
      final logLogrado = find.byKey(const ValueKey('log_btn_logrado'));
      expect(logLogrado, findsOneWidget);
      await tester.ensureVisible(logLogrado);
      await tester.tap(logLogrado);
      await tester.pump();

      expect(find.text('Solta e discrimina a textura de forma autónoma'),
          findsOneWidget);
    });

    testWidgets('SteamSesionGuiadaScreen shows Spanish Step 3 Construye in Spanish mode',
        (tester) async {
      tester.view.physicalSize = const Size(400, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await repo.loadSteamUnits();
      final unit = repo.getSteamUnitById('I1-MATERIA-001')!;

      await tester.pumpWidget(
        MaterialApp(
          home: SteamSesionGuiadaScreen(
            unit: unit,
            audioService: mockAudio,
            initialLanguage: AppLanguage.es,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // In Spanish: Paso 3 · Construye (Make)
      expect(find.text('Paso 1 · Observa'), findsOneWidget);
      expect(find.text('Paso 2 · Experimenta'), findsOneWidget);
      expect(find.text('Paso 3 · Construye (Make)'), findsOneWidget);
      expect(find.text('Exploradora de la lana'), findsOneWidget);
    });

    testWidgets('PortalDocentesScreen exposes STEAM Cooperativo card in Section 1',
        (tester) async {
      tester.view.physicalSize = const Size(400, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: PortalDocentesScreen(
            repository: repo,
            audioService: mockAudio,
            currentLanguage: AppLanguage.gl,
            onToggleLanguage: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final steamCardTitle = find.text('STEAM Cooperativo · Indagación e TPR');
      expect(steamCardTitle, findsOneWidget);
    });

    testWidgets('PortalFamiliasScreen exposes STEAM category and card',
        (tester) async {
      tester.view.physicalSize = const Size(400, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: PortalFamiliasScreen(
            repository: repo,
            audioService: mockAudio,
            currentLanguage: AppLanguage.gl,
            onToggleLanguage: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final steamChip = find.text('STEAM Cooperativo');
      expect(steamChip, findsOneWidget);

      final steamFamilyCard = find.text('STEAM no Fogar · Xogo Cooperativo');
      expect(steamFamilyCard, findsOneWidget);
    });
  });
}
