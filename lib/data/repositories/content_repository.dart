import 'package:flutter/services.dart' show AssetManifest, rootBundle;

import '../loaders/content_asset_loader.dart';
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
  final List<ContentLoadFailure> _loadErrors = [];
  bool _isInitialized = false;

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

  /// Initializes the repository by loading assets from default or specified paths.
  ///
  /// With no paths given the catalogue is discovered from the bundle, so adding
  /// a unit or a capsule is a matter of dropping a JSON file into
  /// `assets/content/` — it used to require editing Dart, which is the opposite
  /// of content-as-data.
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

    _unidadesById.clear();
    _capsulasById.clear();
    _loadErrors.clear();

    for (final path in effectiveUnidadPaths) {
      try {
        final unidad = await _loader.loadUnidadFromAsset(path);
        _unidadesById[unidad.id] = unidad;
      } catch (e) {
        // A file that fails to load used to vanish without a trace, leaving an
        // empty screen and no way to tell an empty catalogue from a broken
        // one. The failure is kept so the screen can say which file it was.
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

    _isInitialized = true;
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

  /// Returns all available Academy capsules sorted by order.
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

    final list = _capsulasById.values
        .where((c) => c.bloqueId.toLowerCase() == target)
        .toList();
    list.sort((a, b) => a.orden.compareTo(b.orden));
    return List.unmodifiable(list);
  }

  /// Returns the 5 official developmental blocks of Academy.
  List<Bloque> getAllBloques() => Bloque.todos;

  /// Resolves a developmental block by its ID or ordinal number.
  Bloque? getBloqueById(String id) {
    final cleanId = id.trim();
    final numeric = int.tryParse(cleanId);
    if (numeric != null) {
      return Bloque.byOrden(numeric);
    }
    return Bloque.byId(cleanId);
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

  /// Clears all cached content.
  void clear() {
    _unidadesById.clear();
    _capsulasById.clear();
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
      );
    } catch (_) {
      return const _DiscoveredContent(unidades: [], capsulas: []);
    }
  }
}

class _DiscoveredContent {
  final List<String> unidades;
  final List<String> capsulas;

  const _DiscoveredContent({required this.unidades, required this.capsulas});
}
