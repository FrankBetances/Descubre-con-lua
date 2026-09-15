import 'package:flutter/services.dart' show AssetManifest, rootBundle;

import '../loaders/content_asset_loader.dart';
import '../models/asamblea_segundo_ciclo_model.dart';
import '../models/capsula_model.dart';
import '../models/unidad_model.dart';

/// A content file that could not be loaded, kept instead of being discarded.
class ContentLoadFailure {
  final String assetPath;
  final String reason;

  const ContentLoadFailure(this.assetPath, this.reason);

  @override
  String toString() => 'ContentLoadFailure($assetPath): $reason';
}

/// Central repository providing structured query and filtering capabilities for
/// thematic units («Juega con Lúa · Aula») and Academy capsules («Academy · Familias»).
///
/// Operates completely offline with zero network clients.
class ContentRepository {
  final ContentAssetLoader _loader;
  final Map<String, Unidad> _unidadesById = {};
  final Map<String, Capsula> _capsulasById = {};
  final Map<String, AsambleaSegundoCiclo> _asambleasSegundoCicloById = {};
  final List<ContentLoadFailure> _loadErrors = [];
  bool _isInitialized = false;

  /// Synchronization latch preventing concurrent redundant initializations.
  Future<void>? _initFuture;

  /// Generation counter to safely invalidate in-flight initialization if [clear] is called.
  int _initGeneration = 0;

  ContentRepository({ContentAssetLoader? loader})
      : _loader = loader ?? ContentAssetLoader();

  /// Whether the repository has been initialized with default or loaded content.
  bool get isInitialized => _isInitialized;

  /// Content files that failed to load during [initialize].
  ///
  /// An empty catalogue and a broken catalogue look identical on screen unless
  /// somebody asks this.
  List<ContentLoadFailure> get loadErrors => List.unmodifiable(_loadErrors);

  /// Whether any content file failed to load.
  bool get hasLoadErrors => _loadErrors.isNotEmpty;

  /// Total count of loaded units.
  int get unitCount => _unidadesById.length;

  /// Total count of loaded capsules.
  int get capsuleCount => _capsulasById.length;

  /// Total count of loaded Segundo Ciclo assemblies.
  int get asambleaSegundoCicloCount => _asambleasSegundoCicloById.length;

  /// Initializes the repository by loading assets from default or specified paths.
  ///
  /// With no paths given the catalogue is discovered from the bundle, so adding
  /// a unit or a capsule is a matter of dropping a JSON file into
  /// `assets/content/` — it used to require editing Dart, which is the opposite
  /// of content-as-data.
  ///
  /// A synchronization latch [_initFuture] ensures that multiple concurrent
  /// async queries share the exact same initialization process without duplicate
  /// file I/O or race conditions.
  Future<void> initialize({
    List<String>? unidadPaths,
    List<String>? capsulaPaths,
    List<String>? asambleaSegundoCicloPaths,
    bool forceReload = false,
  }) {
    if (!forceReload) {
      if (_isInitialized &&
          unidadPaths == null &&
          capsulaPaths == null &&
          asambleaSegundoCicloPaths == null) {
        return Future.value();
      }
      if (_initFuture != null) {
        return _initFuture!;
      }
    }

    final generation = ++_initGeneration;
    final future = _loadContent(
      generation: generation,
      unidadPaths: unidadPaths,
      capsulaPaths: capsulaPaths,
      asambleaSegundoCicloPaths: asambleaSegundoCicloPaths,
    );

    final latchedFuture = future.whenComplete(() {
      if (!_isInitialized || generation != _initGeneration) {
        _initFuture = null;
      }
    });

    _initFuture = latchedFuture;
    return latchedFuture;
  }

  Future<void> _loadContent({
    required int generation,
    List<String>? unidadPaths,
    List<String>? capsulaPaths,
    List<String>? asambleaSegundoCicloPaths,
  }) async {
    final discovered = (unidadPaths == null ||
            capsulaPaths == null ||
            asambleaSegundoCicloPaths == null)
        ? await _discover()
        : null;

    if (generation != _initGeneration) return;

    final effectiveUnidadPaths = unidadPaths ??
        (discovered?.unidades.isNotEmpty ?? false
            ? discovered!.unidades
            : [ContentAssetLoader.baseUnidadMar01]);
    final effectiveCapsulaPaths = capsulaPaths ??
        (discovered?.capsulas.isNotEmpty ?? false
            ? discovered!.capsulas
            : [ContentAssetLoader.baseCapsulaHablar01]);
    final effectiveAsambleaPaths = asambleaSegundoCicloPaths ??
        (discovered?.asambleasSegundoCiclo.isNotEmpty ?? false
            ? discovered!.asambleasSegundoCiclo
            : [
                ContentAssetLoader.baseAsambleaSetembro4,
                ContentAssetLoader.baseAsambleaSetembro5,
                ContentAssetLoader.baseAsambleaSetembro6,
              ]);

    _unidadesById.clear();
    _capsulasById.clear();
    _asambleasSegundoCicloById.clear();
    _loadErrors.clear();

    for (final path in effectiveUnidadPaths) {
      if (generation != _initGeneration) return;
      try {
        final unidad = await _loader.loadUnidadFromAsset(path);
        if (generation != _initGeneration) return;
        _unidadesById[unidad.id] = unidad;
      } catch (e) {
        // A file that fails to load used to vanish without a trace, leaving an
        // empty screen and no way to tell an empty catalogue from a broken
        // one. The failure is kept so the screen can say which file it was.
        _loadErrors.add(ContentLoadFailure(path, e.toString()));
      }
    }

    for (final path in effectiveCapsulaPaths) {
      if (generation != _initGeneration) return;
      try {
        final capsula = await _loader.loadCapsulaFromAsset(path);
        if (generation != _initGeneration) return;
        _capsulasById[capsula.id] = capsula;
      } catch (e) {
        _loadErrors.add(ContentLoadFailure(path, e.toString()));
      }
    }

    for (final path in effectiveAsambleaPaths) {
      if (generation != _initGeneration) return;
      try {
        final asamblea = await _loader.loadAsambleaSegundoCiclo(path);
        if (generation != _initGeneration) return;
        _asambleasSegundoCicloById[asamblea.id] = asamblea;
      } catch (e) {
        _loadErrors.add(ContentLoadFailure(path, e.toString()));
      }
    }

    if (generation == _initGeneration) {
      _isInitialized = true;
    }
  }

  // --- UNIDADES (Juega con Lúa · Aula) ---

  /// Returns all available pedagogical units sorted by their canonical order.
  List<Unidad> getAllUnidades() {
    final list = _unidadesById.values.toList();
    list.sort((a, b) => a.orden.compareTo(b.orden));
    return List.unmodifiable(list);
  }

  /// Finds a specific unit by its unique identifier (e.g., "juega.mar.01").
  Unidad? getUnidadById(String id) {
    return _unidadesById[id.trim()];
  }

  /// Filters units by age band ("0-2", "2-3", or "0-3" encompassing both).
  List<Unidad> getUnidadesByTramoEtario(String tramoEtario) {
    final cleanFilter = tramoEtario.trim();
    final list = _unidadesById.values
        .where((u) => u.matchesAgeBand(cleanFilter))
        .toList();
    list.sort((a, b) => a.orden.compareTo(b.orden));
    return List.unmodifiable(list);
  }

  // --- CAPSULAS & BLOQUES (Academy · Familias) ---

  /// Todas las cápsulas cargadas, de Academy y del aula.
  List<Capsula> getAllCapsulas() {
    final list = _capsulasById.values.toList();
    list.sort((a, b) => a.orden.compareTo(b.orden));
    return List.unmodifiable(list);
  }

  /// Finds a specific capsule by its unique identifier.
  Capsula? getCapsulaById(String id) {
    return _capsulasById[id.trim()];
  }

  /// Filters capsules belonging to a specific developmental block ID (or block order 1..5).
  List<Capsula> getCapsulasByBloqueId(String bloqueId) {
    final cleanId = bloqueId.trim().toLowerCase();

    // Check if numeric string '1'..'5' was passed
    final numeric = int.tryParse(cleanId);
    String? mappedId;
    if (numeric != null) {
      final b = Bloque.byOrden(numeric);
      if (b != null) mappedId = b.id;
    }

    final target = mappedId ?? cleanId;

    // Solo las de familia: si una cápsula del aula acabase aquí, Academy la
    // pintaría igual de bien y una familia leería formación docente.
    final list = _capsulasById.values
        .where((c) =>
            c.destinatario == DestinatarioCapsula.familia &&
            c.bloqueId.toLowerCase() == target)
        .toList();
    list.sort((a, b) => a.orden.compareTo(b.orden));
    return List.unmodifiable(list);
  }

  /// Returns the 5 official developmental blocks of Academy.
  List<Bloque> getAllBloques() => Bloque.todos;

  // --- CAPSULAS DEL AULA (Juega con Lúa · docentes) ---

  /// Los 6 bloques de las cápsulas del aula, uno por paso de la asamblea.
  List<Bloque> getAllBloquesAula() => Bloque.aula;

  /// Las cápsulas del aula de un bloque, ya filtradas por destinatario.
  ///
  /// El filtro por destinatario no sobra aunque los identificadores de bloque
  /// no se solapen: una cápsula mal etiquetada saldría igual de bien pintada
  /// en la lista equivocada, y nadie lo vería. El validador lo caza al cargar
  /// el contenido; esto lo caza en la consulta.
  List<Capsula> getCapsulasAulaByBloqueId(String bloqueId) {
    final target = bloqueId.trim().toLowerCase();
    final list = _capsulasById.values
        .where((c) =>
            c.destinatario == DestinatarioCapsula.docente &&
            c.bloqueId.toLowerCase() == target)
        .toList();
    list.sort((a, b) => a.orden.compareTo(b.orden));
    return List.unmodifiable(list);
  }

  /// Resolves a developmental block by its ID or ordinal number.
  Bloque? getBloqueById(String id) {
    final cleanId = id.trim();
    final numeric = int.tryParse(cleanId);
    if (numeric != null) {
      return Bloque.byOrden(numeric);
    }
    return Bloque.byId(cleanId);
  }

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

  // --- IN-MEMORY & TEST HELPER METHODS ---

  /// Adds or updates an [Unidad] directly in memory (for tests and mocking).
  void addUnidad(Unidad unidad) {
    _unidadesById[unidad.id] = unidad;
    _isInitialized = true;
  }

  /// Adds or updates a [Capsula] directly in memory (for tests and mocking).
  void addCapsula(Capsula capsula) {
    _capsulasById[capsula.id] = capsula;
    _isInitialized = true;
  }

  /// Adds or updates an [AsambleaSegundoCiclo] directly in memory (for tests and mocking).
  void addAsambleaSegundoCiclo(AsambleaSegundoCiclo asamblea) {
    _asambleasSegundoCicloById[asamblea.id] = asamblea;
    _isInitialized = true;
  }

  /// Clears all cached content across Primer and Segundo Ciclo.
  void clear() {
    _initGeneration++;
    _initFuture = null;
    _unidadesById.clear();
    _capsulasById.clear();
    _asambleasSegundoCicloById.clear();
    _loadErrors.clear();
    _isInitialized = false;
  }

  /// Lists the content files actually present in the bundle.
  ///
  /// Falls back to an empty result outside a Flutter engine (plain unit tests),
  /// where the caller's explicit paths are used instead.
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
