# Handoff Report — Loader & Repository Explorer (Milestone M1)

**Agent ID**: `teamwork_preview_explorer_m1_2`  
**Workspace**: `/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_explorer_m1_2`  
**Parent Conversation ID**: `e7633361-cefb-4427-91ff-c3fbb93625fc`  
**Date**: 2026-09-14T13:38:00Z  
**Type**: Hard Handoff (Task Complete)

---

## 1. Observation

### 1.1 Existing Loader Architecture (`lib/data/loaders/content_asset_loader.dart`)
1. **Headless String Loader Pattern**:
   - Lines 6–18:
     ```dart
     typedef AssetBundleStringLoader = Future<String> Function(String path);

     class ContentAssetLoader {
       final AssetBundleStringLoader _stringLoader;

       ContentAssetLoader({AssetBundleStringLoader? stringLoader})
           : _stringLoader = stringLoader ?? ((path) => rootBundle.loadString(path));
     ```
     The loader decouples Flutter engine `rootBundle` from unit test environments by accepting an optional `_stringLoader` closure (reading from `dart:io` `File` in test).
2. **Hardcoded Asset Prefixes**:
   - Lines 20–32:
     ```dart
     static const String unidadesAssetPrefix = 'assets/content/unidades/';
     static const String capsulasAssetPrefix = 'assets/content/capsulas/';

     static const String baseUnidadMar01 =
         'assets/content/unidades/juega.mar.01.json';
     static const String baseCapsulaHablar01 =
         'assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json';
     ```
3. **Dedicated Load and Parse Methods for 0-3**:
   - Lines 34–81:
     - `Future<Unidad> loadUnidadFromAsset(String assetPath)`
     - `Future<Capsula> loadCapsulaFromAsset(String assetPath)`
     - `Unidad parseUnidad(String rawJson)`
     - `Capsula parseCapsula(String rawJson)`
     - `Future<List<Unidad>> loadAllUnidades(List<String> assetPaths)`
     - `Future<List<Capsula>> loadAllCapsulas(List<String> assetPaths)`

### 1.2 Existing Repository Architecture (`lib/data/repositories/content_repository.dart`)
1. **State & Caching Maps**:
   - Lines 23–27:
     ```dart
     final ContentAssetLoader _loader;
     final Map<String, Unidad> _unidadesById = {};
     final Map<String, Capsula> _capsulasById = {};
     final List<ContentLoadFailure> _loadErrors = [];
     bool _isInitialized = false;
     ```
2. **Dynamic Bundle Discovery & Fallback**:
   - Lines 56–72:
     ```dart
     Future<void> initialize({
       List<String>? unidadPaths,
       List<String>? capsulaPaths,
     }) async {
       final discovered = (unidadPaths == null || capsulaPaths == null)
           ? await _discover()
           : null;

       final effectiveUnidadPaths = unidadPaths ??
           (discovered?.unidades.isNotEmpty ?? false
               ? discovered!.unidades
               : [ContentAssetLoader.baseUnidadMar01]);
       final effectiveCapsulaPaths = capsulaPaths ??
           (discovered?.capsulas.isNotEmpty ?? false
               ? discovered!.capsulas
               : [ContentAssetLoader.baseCapsulaHablar01]);
     ```
   - Lines 225–246 (`_discover()`):
     ```dart
     Future<_DiscoveredContent> _discover() async {
       try {
         final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
         final assets = manifest.listAssets();
         bool isJsonUnder(String asset, String prefix) =>
             asset.startsWith(prefix) && asset.endsWith('.json');
         return _DiscoveredContent(
           unidades: (assets
               .where((a) => isJsonUnder(a, ContentAssetLoader.unidadesAssetPrefix))
               .toList()..sort()),
           capsulas: (assets
               .where((a) => isJsonUnder(a, ContentAssetLoader.capsulasAssetPrefix))
               .toList()..sort()),
         );
       } catch (_) {
         return const _DiscoveredContent(unidades: [], capsulas: []);
       }
     }
     ```
3. **Query Methods**:
   - Lines 104–124: `getAllUnidades()`, `getUnidadById(String id)`, `getUnidadesByTramoEtario(String tramoEtario)`.
   - Lines 128–198: `getAllCapsulas()`, `getCapsulaById(String id)`, `getCapsulasByBloqueId(String bloqueId)`, `getAllBloques()`, `getAllBloquesAula()`, `getCapsulasAulaByBloqueId(...)`.
   - Lines 202–219: `addUnidad(Unidad)`, `addCapsula(Capsula)`, `clear()`.

### 1.3 CI Tooling & Asset Structure Constraints (`tools/`)
1. **Pulse Song Markers Gate**:
   - `tools/check_pulse_markers.py` line 20:
     `UNITS = ROOT / "assets" / "content" / "unidades"`
     Lines 32–37 glob `UNITS.glob("*.json")` and require `cancionPulso.letraConPulsos` with steady beat counts.
2. **Pulse BPM Gate**:
   - `tools/check_pulse_bpm.py` lines 26, 34: globs `ROOT / "assets" / "content" / "unidades" / "*.json"` and validates 72 BPM.
3. **Voice Corpus & Coverage Gate**:
   - `tools/voice_corpus.py` line 147:
     `for path in sorted((content_dir / "unidades").glob("*.json")):`
     Parses 0-3 `Unidad` fields (`cancionPulso`, `cuento`, `preguntas`, `vocabulario`, `exploracion`, `matematicas`, `puenteCasa`).
   - `tools/check_voice_coverage.py` lines 25–40: checks that every locution extracted by `voice_corpus.py` has a physical `.m4a` file in `assets/voice/` or fails the CI build with exit code 1.
4. **Asset Declarations**:
   - `pubspec.yaml` lines 21–25:
     ```yaml
       assets:
         - assets/content/unidades/
         - assets/content/capsulas/
         - assets/content/premios/
         - assets/audio/
     ```

### 1.4 Test Suites & Invariant Checks
1. `test/data/content_loader_test.dart`:
   - Tests `ContentAssetLoader` parsing from disk using `File(path).readAsString()`.
   - Tests `ContentRepository.initialize()` with explicit paths, checking `repository.unitCount == 1`, `repository.capsuleCount == 1`.
   - Verifies `repository.clear()` resets `isInitialized` to `false` and counts to 0.
2. `test/data/challenger2_stress_test.dart` lines 71–104:
   - Verifies edge cases: unknown IDs return `null`, uninitialized query behavior, and state reset on `clear()`.

---

## 2. Logic Chain

1. **Strict Directory Isolation**:
   - *Observation*: `tools/voice_corpus.py` and `tools/check_pulse_markers.py` glob `assets/content/unidades/*.json` expecting `cancionPulso` and 0-3 schema fields.
   - *Inference*: If Segundo Ciclo JSON files were placed in `assets/content/unidades/`, existing CI scripts would immediately fail because:
     a) `check_pulse_markers.py` would find no `cancionPulso.letraConPulsos`.
     b) `voice_corpus.py` would fail to find `cuento` and `vocabulario`.
     c) `check_voice_coverage.py` would fail because new English TPR sentences lack pre-synthesized `.m4a` files.
   - *Deduction*: Segundo Ciclo content MUST be isolated in `assets/content/asambleas_segundo_ciclo/`. The loader prefix must be `assets/content/asambleas_segundo_ciclo/`.

2. **Loader Extensibility Without 0-3 Regression**:
   - *Observation*: `ContentAssetLoader` provides clean, decoupled loading methods for `Unidad` and `Capsula` driven by `_stringLoader`.
   - *Inference*: Adding `loadAsambleaSegundoCiclo(String assetPath)` and `parseAsambleaSegundoCiclo(String rawJson)` following the identical pattern allows headless file-based testing and production bundle loading without modifying any existing method signatures.
   - *Deduction*: We add:
     - `Future<AsambleaSegundoCiclo> loadAsambleaSegundoCiclo(String assetPath)`
     - `Future<AsambleaSegundoCiclo> loadAsambleaSegundoCicloFromAsset(String assetPath)` (convenience alias)
     - `AsambleaSegundoCiclo parseAsambleaSegundoCiclo(String rawJson)`
     - `Future<List<AsambleaSegundoCiclo>> loadAllAsambleasSegundoCiclo(List<String> assetPaths)`

3. **Repository Caching and Non-Breaking Initialization**:
   - *Observation*: Existing callers (e.g. `test/data/content_loader_test.dart`) call `repository.initialize(unidadPaths: [...], capsulaPaths: [...])` without passing Segundo Ciclo paths. In test environments, `AssetManifest.loadFromAssetBundle(rootBundle)` throws an exception which `_discover()` catches and returns empty lists.
   - *Inference*: If `asambleaSegundoCicloPaths` defaulted to a non-existent file path when null, headless unit tests would fail by recording a `ContentLoadFailure` in `_loadErrors`.
   - *Deduction*: `initialize()` must declare `List<String>? asambleaSegundoCicloPaths`. When null, `effectiveAsambleaPaths` must evaluate to `discovered?.asambleasSegundoCiclo ?? const []`. In production with bundled assets, `_discover()` dynamically finds all `assets/content/asambleas_segundo_ciclo/*.json`. In unit tests without explicit paths, it safely evaluates to `const []`, generating 0 errors and preserving 100% backward compatibility.

4. **Dual Async / Sync Query Interface**:
   - *Observation*: DISPATCH.md mandates `Future<List<AsambleaSegundoCiclo>> getAllAsambleasSegundoCiclo()`, `Future<AsambleaSegundoCiclo?> getAsambleaSegundoCicloById(String id)`, and `Future<List<AsambleaSegundoCiclo>> getAsambleasByNivel(NivelEducativoSegundoCiclo nivel)`. Simultaneously, existing 0-3 UI screens (`unidades_list_screen.dart`, `calendario_screen.dart`) use synchronous in-memory getters (`getAllUnidades()`).
   - *Inference*: Providing async methods with auto-initialization (`if (!_isInitialized) await initialize();`) fulfills the dispatch requirement and guarantees resilience. Providing synchronous helpers (`getAllAsambleasSegundoCicloSync()`, `getAsambleaSegundoCicloByIdSync()`, etc.) enables direct widget consumption without forced `FutureBuilder` overhead.
   - *Deduction*: Implement both async methods and synchronous property/method helpers.

5. **Sorting & Querying by Month and Level**:
   - *Observation*: Segundo Ciclo assemblies represent curricular months (mes 1..10, where 9 is September) and 3 educational levels (`4_infantil`, `5_infantil`, `6_infantil`).
   - *Inference*: Global list queries should be sorted canonically by month (`mes`) ascending, and within the same month by educational level (`nivel.index`) ascending.
   - *Deduction*: In `getAllAsambleasSegundoCiclo()`, sort by `(a, b) => a.mes != b.mes ? a.mes.compareTo(b.mes) : a.nivel.index.compareTo(b.nivel.index)`. Add `getAsambleaByMesYNivel(int mes, NivelEducativoSegundoCiclo nivel)` for 1-touch calendar integration.

---

## 3. Caveats

1. **Pubspec Asset Directory Registration**:
   - In Flutter, adding `- assets/content/asambleas_segundo_ciclo/` to `pubspec.yaml` requires that the physical directory exists on disk. During M1, when creating the directory structure, place an empty file (e.g. `.gitkeep`) so `flutter pub get` and `flutter test` do not warn about a missing asset directory.
2. **Audio File Independence**:
   - Segundo Ciclo TPR commands in L3 will have optional `audioAsset` properties (`String?`). The repository and loader must not fail if an audio file is absent from the bundle; the backstage UI can render the command card visually regardless.
3. **Data Model Prerequisite**:
   - `ContentAssetLoader` and `ContentRepository` depend on `AsambleaSegundoCiclo` and `NivelEducativoSegundoCiclo` defined by agent `m1_1` in `lib/data/models/asamblea_segundo_ciclo_model.dart`. The proposed code is fully aligned with the interface contract established in `PROJECT.md`.

---

## 4. Conclusion & Concrete Code Specifications

### 4.1 Specification for `lib/data/loaders/content_asset_loader.dart`

Add import:
```dart
import '../models/asamblea_segundo_ciclo_model.dart';
```

Add constants and methods to `ContentAssetLoader`:
```dart
  /// Default asset path prefix for Segundo Ciclo assemblies (3-6 years).
  static const String asambleasSegundoCicloAssetPrefix =
      'assets/content/asambleas_segundo_ciclo/';

  /// Canonical base assembly paths for September pilot month.
  static const String baseAsambleaSetembro4 =
      'assets/content/asambleas_segundo_ciclo/asamblea.setembro.4_infantil.json';
  static const String baseAsambleaSetembro5 =
      'assets/content/asambleas_segundo_ciclo/asamblea.setembro.5_infantil.json';
  static const String baseAsambleaSetembro6 =
      'assets/content/asambleas_segundo_ciclo/asamblea.setembro.6_infantil.json';

  /// Loads and parses an [AsambleaSegundoCiclo] from an asset path.
  Future<AsambleaSegundoCiclo> loadAsambleaSegundoCiclo(String assetPath) async {
    final jsonString = await _stringLoader(assetPath);
    return parseAsambleaSegundoCiclo(jsonString);
  }

  /// Alias for [loadAsambleaSegundoCiclo] matching [loadUnidadFromAsset] nomenclature.
  Future<AsambleaSegundoCiclo> loadAsambleaSegundoCicloFromAsset(
          String assetPath) =>
      loadAsambleaSegundoCiclo(assetPath);

  /// Parses an [AsambleaSegundoCiclo] from a raw JSON string.
  AsambleaSegundoCiclo parseAsambleaSegundoCiclo(String rawJson) {
    final dynamic decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
          'Expected JSON object at root for AsambleaSegundoCiclo');
    }
    return AsambleaSegundoCiclo.fromJson(decoded);
  }

  /// Loads multiple [AsambleaSegundoCiclo] instances from a list of asset paths.
  Future<List<AsambleaSegundoCiclo>> loadAllAsambleasSegundoCiclo(
      List<String> assetPaths) async {
    final List<AsambleaSegundoCiclo> list = [];
    for (final path in assetPaths) {
      final asamblea = await loadAsambleaSegundoCiclo(path);
      list.add(asamblea);
    }
    return List.unmodifiable(list);
  }
```

### 4.2 Specification for `lib/data/repositories/content_repository.dart`

Add import:
```dart
import '../models/asamblea_segundo_ciclo_model.dart';
```

Extend `ContentRepository` state and getters:
```dart
  final Map<String, AsambleaSegundoCiclo> _asambleasSegundoCicloById = {};

  /// Total count of loaded Segundo Ciclo assemblies.
  int get asambleaSegundoCicloCount => _asambleasSegundoCicloById.length;
```

Update `initialize()`:
```dart
  Future<void> initialize({
    List<String>? unidadPaths,
    List<String>? capsulaPaths,
    List<String>? asambleaSegundoCicloPaths,
  }) async {
    final discovered = (unidadPaths == null ||
            capsulaPaths == null ||
            asambleaSegundoCicloPaths == null)
        ? await _discover()
        : null;

    final effectiveUnidadPaths = unidadPaths ??
        (discovered?.unidades.isNotEmpty ?? false
            ? discovered!.unidades
            : [ContentAssetLoader.baseUnidadMar01]);
    final effectiveCapsulaPaths = capsulaPaths ??
        (discovered?.capsulas.isNotEmpty ?? false
            ? discovered!.capsulas
            : [ContentAssetLoader.baseCapsulaHablar01]);
    final effectiveAsambleaPaths = asambleaSegundoCicloPaths ??
        (discovered?.asambleasSegundoCiclo ?? const []);

    _unidadesById.clear();
    _capsulasById.clear();
    _asambleasSegundoCicloById.clear();
    _loadErrors.clear();

    for (final path in effectiveUnidadPaths) {
      try {
        final unidad = await _loader.loadUnidadFromAsset(path);
        _unidadesById[unidad.id] = unidad;
      } catch (e) {
        _loadErrors.add(ContentLoadFailure(path, e.toString()));
      }
    }

    for (final path in effectiveCapsulaPaths) {
      try {
        final capsula = await _loader.loadCapsulaFromAsset(path);
        _capsulasById[capsula.id] = capsula;
      } catch (e) {
        _loadErrors.add(ContentLoadFailure(path, e.toString()));
      }
    }

    for (final path in effectiveAsambleaPaths) {
      try {
        final asamblea = await _loader.loadAsambleaSegundoCiclo(path);
        _asambleasSegundoCicloById[asamblea.id] = asamblea;
      } catch (e) {
        _loadErrors.add(ContentLoadFailure(path, e.toString()));
      }
    }

    _isInitialized = true;
  }
```

Add Segundo Ciclo query methods:
```dart
  // --- ASAMBLEAS SEGUNDO CICLO (3-6 anos · Infantil 4º, 5º, 6º) ---

  /// Returns all available Segundo Ciclo assemblies sorted by month and level.
  Future<List<AsambleaSegundoCiclo>> getAllAsambleasSegundoCiclo() async {
    if (!_isInitialized) {
      await initialize();
    }
    return getAllAsambleasSegundoCicloSync();
  }

  /// Synchronous retrieval of all loaded Segundo Ciclo assemblies.
  List<AsambleaSegundoCiclo> getAllAsambleasSegundoCicloSync() {
    final list = _asambleasSegundoCicloById.values.toList();
    list.sort((a, b) {
      final cmpMes = a.mes.compareTo(b.mes);
      if (cmpMes != 0) return cmpMes;
      return a.nivel.index.compareTo(b.nivel.index);
    });
    return List.unmodifiable(list);
  }

  /// Finds a specific Segundo Ciclo assembly by its unique identifier.
  Future<AsambleaSegundoCiclo?> getAsambleaSegundoCicloById(String id) async {
    if (!_isInitialized) {
      await initialize();
    }
    return getAsambleaSegundoCicloByIdSync(id);
  }

  /// Synchronous lookup of a Segundo Ciclo assembly by its ID.
  AsambleaSegundoCiclo? getAsambleaSegundoCicloByIdSync(String id) {
    return _asambleasSegundoCicloById[id.trim()];
  }

  /// Filters Segundo Ciclo assemblies by educational level (4º, 5º, or 6º).
  Future<List<AsambleaSegundoCiclo>> getAsambleasByNivel(
      NivelEducativoSegundoCiclo nivel) async {
    if (!_isInitialized) {
      await initialize();
    }
    return getAsambleasByNivelSync(nivel);
  }

  /// Synchronous filter of Segundo Ciclo assemblies by educational level.
  List<AsambleaSegundoCiclo> getAsambleasByNivelSync(
      NivelEducativoSegundoCiclo nivel) {
    final list = _asambleasSegundoCicloById.values
        .where((a) => a.nivel == nivel)
        .toList();
    list.sort((a, b) => a.mes.compareTo(b.mes));
    return List.unmodifiable(list);
  }

  /// Finds a Segundo Ciclo assembly for a specific curricular month and level.
  Future<AsambleaSegundoCiclo?> getAsambleaByMesYNivel(
      int mes, NivelEducativoSegundoCiclo nivel) async {
    if (!_isInitialized) {
      await initialize();
    }
    return getAsambleaByMesYNivelSync(mes, nivel);
  }

  /// Synchronous lookup by month and level.
  AsambleaSegundoCiclo? getAsambleaByMesYNivelSync(
      int mes, NivelEducativoSegundoCiclo nivel) {
    for (final a in _asambleasSegundoCicloById.values) {
      if (a.mes == mes && a.nivel == nivel) return a;
    }
    return null;
  }
```

Update in-memory and lifecycle helpers:
```dart
  /// Adds or updates an [AsambleaSegundoCiclo] directly in memory (for tests and mocking).
  void addAsambleaSegundoCiclo(AsambleaSegundoCiclo asamblea) {
    _asambleasSegundoCicloById[asamblea.id] = asamblea;
    _isInitialized = true;
  }

  /// Clears all cached content across Primer and Segundo Ciclo.
  void clear() {
    _unidadesById.clear();
    _capsulasById.clear();
    _asambleasSegundoCicloById.clear();
    _loadErrors.clear();
    _isInitialized = false;
  }
```

Update `_discover()` and `_DiscoveredContent`:
```dart
  Future<_DiscoveredContent> _discover() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final assets = manifest.listAssets();
      bool isJsonUnder(String asset, String prefix) =>
          asset.startsWith(prefix) && asset.endsWith('.json');
      return _DiscoveredContent(
        unidades: (assets
            .where(
                (a) => isJsonUnder(a, ContentAssetLoader.unidadesAssetPrefix))
            .toList()
          ..sort()),
        capsulas: (assets
            .where(
                (a) => isJsonUnder(a, ContentAssetLoader.capsulasAssetPrefix))
            .toList()
          ..sort()),
        asambleasSegundoCiclo: (assets
            .where((a) => isJsonUnder(
                a, ContentAssetLoader.asambleasSegundoCicloAssetPrefix))
            .toList()
          ..sort()),
      );
    } catch (_) {
      return const _DiscoveredContent(
        unidades: [],
        capsulas: [],
        asambleasSegundoCiclo: [],
      );
    }
  }

class _DiscoveredContent {
  final List<String> unidades;
  final List<String> capsulas;
  final List<String> asambleasSegundoCiclo;

  const _DiscoveredContent({
    required this.unidades,
    required this.capsulas,
    this.asambleasSegundoCiclo = const [],
  });
}
```

### 4.3 Specification for `pubspec.yaml`
```yaml
  assets:
    - assets/content/unidades/
    - assets/content/capsulas/
    - assets/content/asambleas_segundo_ciclo/
    - assets/content/premios/
    - assets/audio/
```

---

## 5. Verification Method

To verify these specifications independently:
1. **Model & Loader Integration Test**:
   - Add test cases in `test/data/content_loader_test.dart`:
     ```dart
     test('loads and parses AsambleaSegundoCiclo from asset stringLoader', () async {
       final mockJson = jsonEncode({
         'id': 'asamblea.setembro.4_infantil',
         'nivel': '4_infantil',
         'mes': 9,
         'titulo': {'gl': 'Benvida 4º', 'es': 'Bienvenida 4º'},
         'centroInteres': {'gl': 'Acollida', 'es': 'Acogida'},
         'metodologiaTpr': 'accion_expandida',
         'duracionTotalMinutos': 10,
         'fases': [
           {
             'orden': 1,
             'tipo': 'apertura_saudo',
             'titulo': {'gl': 'Saúdo', 'es': 'Saludo'},
             'duracionSegundos': 90,
             'consignaDocente': {'gl': 'Ola Lúa', 'es': 'Hola Lúa'},
             'comandosL3': [],
             'repertorioMateriales': [],
           },
           {
             'orden': 2,
             'tipo': 'movement_rhythm_focus',
             'titulo': {'gl': 'Pulso', 'es': 'Pulso'},
             'duracionSegundos': 120,
             'consignaDocente': {'gl': 'Ritmo', 'es': 'Ritmo'},
             'comandosL3': [],
             'repertorioMateriales': [],
           },
           {
             'orden': 3,
             'tipo': 'core_tpr_challenge',
             'titulo': {'gl': 'TPR', 'es': 'TPR'},
             'duracionSegundos': 270,
             'consignaDocente': {'gl': 'Comandos', 'es': 'Comandos'},
             'comandosL3': [
               {
                 'id': 'cmd.01',
                 'textoIngles': 'Stand up and clap hands',
                 'accionFisica': {'gl': 'Erguerse', 'es': 'Levantarse'},
                 'modeladoDocente': {'gl': 'Modelado', 'es': 'Modelado'},
               }
             ],
             'repertorioMateriales': [],
           },
           {
             'orden': 4,
             'tipo': 'calma_transicion',
             'titulo': {'gl': 'Calma', 'es': 'Calma'},
             'duracionSegundos': 120,
             'consignaDocente': {'gl': 'Respiración', 'es': 'Respiración'},
             'comandosL3': [],
             'repertorioMateriales': [],
           },
         ],
         'curriculo': {
           'normativa': 'Decreto 150/2022',
           'etapa': 'educacion_infantil',
           'ciclo': 'segundo_ciclo_3_6',
           'nivel': '4_infantil',
           'areas': ['area_3_comunicacion_representacion'],
           'competenciasClave': ['CCL'],
           'criteriosEvaluacion': ['CA3.1'],
         },
         'materialesEntorno': [],
         'microRutinaHogar': {
           'id': 'rutina.setembro',
           'titulo': {'gl': 'Abrigo', 'es': 'Abrigo'},
           'nichoTiempoMinutos': 3,
           'momentoDelDia': {'gl': 'Chegada', 'es': 'Llegada'},
           'objetivoAutonomia': {'gl': 'Colgar abrigo', 'es': 'Colgar abrigo'},
           'pautasRecast': [],
           'escenaCotidiana': {'gl': 'Na entrada', 'es': 'En la entrada'},
         },
         'revision': {
           'autor': 'M1 Team',
           'revisorPedagogico': 'Revisor',
           'fechaRevision': '2026-09-14',
           'version': '1.0.0',
           'aprobadoParaAula': true,
         },
       });

       final asamblea = fileLoader.parseAsambleaSegundoCiclo(mockJson);
       expect(asamblea.id, equals('asamblea.setembro.4_infantil'));
       expect(asamblea.nivel, equals(NivelEducativoSegundoCiclo.infantil4));
       expect(asamblea.fases.length, equals(4));
       expect(asamblea.fases[2].comandosL3.first.textoIngles, equals('Stand up and clap hands'));

       repository.addAsambleaSegundoCiclo(asamblea);
       expect(repository.asambleaSegundoCicloCount, equals(1));
       expect((await repository.getAllAsambleasSegundoCiclo()).length, equals(1));
       expect((await repository.getAsambleasByNivel(NivelEducativoSegundoCiclo.infantil4)).length, equals(1));
       expect((await repository.getAsambleasByNivel(NivelEducativoSegundoCiclo.infantil5)), isEmpty);
       expect(await repository.getAsambleaByMesYNivel(9, NivelEducativoSegundoCiclo.infantil4), equals(asamblea));
     });
     ```
2. **Backward Compatibility Verification**:
   - Run existing tests without modifying them:
     ```bash
     flutter test test/data/content_loader_test.dart
     flutter test test/data/challenger2_stress_test.dart
     ```
   - Both tests must pass with 0 failures, verifying that uninitialized behavior, unitCount, capsuleCount, and clear() are completely unchanged.
3. **CI Gate Invariant Verification**:
   - Run content and voice gates:
     ```bash
     python3 tools/check_pulse_markers.py
     python3 tools/check_pulse_bpm.py
     python3 tools/export_voice_corpus.py --check
     python3 tools/check_voice_coverage.py
     ```
   - All tools exit with code 0 because `assets/content/asambleas_segundo_ciclo/` is ignored by the 0-3 unit scanning patterns.
