import 'dart:convert';
import 'package:flutter/services.dart' show AssetManifest, rootBundle;

import '../loaders/content_asset_loader.dart';
import '../models/asamblea_primeiro_ciclo_model.dart';
import '../models/asamblea_segundo_ciclo_model.dart';
import '../models/capsula_model.dart';
import '../models/corpus_palabra_model.dart';
import '../models/cuento_model.dart';
import '../models/dia_calendario_dual_model.dart';
import '../models/dinamica_model.dart';
import '../models/english_corpus_model.dart';
import '../models/estrategia_model.dart';
import '../models/lamina_model.dart';
import '../models/phonics_model.dart';
import '../models/progresion_model.dart';
// `Cuento` y `CuentoPagina` existen DOS veces en el proyecto y no son la misma
// cosa: en unidad_model.dart son el cuento que vive DENTRO de una unidad de la
// asamblea (sin id, con páginas de la unidad), y en cuento_model.dart son el
// cuento suelto del banco de 200 (con id, curso, mes y preguntas graduadas).
// Este fichero solo usa los del banco, así que se ocultan los de la unidad: sin
// esto, los dos nombres chocan y el proyecto NO compila.
import '../models/unidad_model.dart' hide Cuento, CuentoPagina;

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
  // Canonical asset paths for new pedagogical modules
  //
  // `banco200_cuentos.json` ya no está: sus 200 contos estaban BYTE A BYTE
  // dentro de historias_progresivas.json, que además trae 6 más. Eran 1,5 MB
  // de APK que no añadían un solo conto, y una primera carga más lenta por
  // leer y descartar el mismo fichero dos veces.
  static const String cuentos100AssetPath =
      'assets/content/cuentos/banco100_cuentos.json';
  static const String historiasProgresivasAssetPath =
      'assets/content/cuentos/historias_progresivas.json';
  static const String laminas200AssetPath =
      'assets/content/laminas/banco200_laminas.json';

  /// El vocabulario inglés que la app enseña: las 4.000 de uso habitual.
  ///
  /// Lo escribe `tools/build_corpus_ingles.py` desde la lista BNC/COCA de
  /// 7.998, quedándose con las cuatro primeras bandas de frecuencia y sin las
  /// doce que Frank mandó quitar.
  static const String corpusCefrAssetPath =
      'assets/content/corpus/ingles_4000_uso_habitual.json';
  static const String calendarioDiasAssetPath =
      'assets/content/calendario/calendario_dias.json';
  static const String englishCorpusAssetPath =
      'assets/content/english/english_corpus.json';
  static const String phonicsTaxonomyAssetPath =
      'assets/content/english/phonics_taxonomy.json';
  static const String estrategiasAssetPath =
      'assets/content/estrategias_pedagogicas.json';
  static const String dinamicasAssetPath = 'assets/content/dinamicas_aula.json';
  static const String curriculo50MesesAssetPath =
      'assets/content/calendario/curriculo_50_meses.json';

  final ContentAssetLoader _loader;
  final Map<String, Unidad> _unidadesById = {};
  final Map<String, Capsula> _capsulasById = {};
  final Map<String, AsambleaPrimeiroCiclo> _asambleasPrimeiroCicloById = {};
  final Map<String, AsambleaSegundoCiclo> _asambleasSegundoCicloById = {};

  /// La progresión diaria por tramo: «primeiro_ciclo.0_2», «segundo_ciclo.4»…
  final Map<String, ProgresionDoMes> _progresionsPorClave = {};

  // Milestone 2 Caches
  final Map<String, Cuento> _cuentosById = {};
  final Map<String, Lamina> _laminasById = {};
  final List<CorpusPalabra> _corpusPalabras = [];
  final List<DiaCalendarioDual> _calendarioDias = [];
  EnglishCorpus? _englishCorpus;
  PhonicsTaxonomy? _phonicsTaxonomy;
  final List<EstrategiaPedagogica> _estrategias = [];
  final List<DinamicaPedagogica> _dinamicas = [];
  final List<MesCurricular50> _curriculo50Meses = [];

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
  int get asambleaPrimeiroCicloCount => _asambleasPrimeiroCicloById.length;

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
    _asambleasPrimeiroCicloById.clear();
    _asambleasSegundoCicloById.clear();
    _progresionsPorClave.clear();
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

    for (final path in discovered?.asambleasPrimeiroCiclo ?? const <String>[]) {
      if (generation != _initGeneration) return;
      try {
        final asamblea = await _loader.loadAsambleaPrimeiroCiclo(path);
        if (generation != _initGeneration) return;
        _asambleasPrimeiroCicloById[asamblea.id] = asamblea;
      } catch (e) {
        _loadErrors.add(ContentLoadFailure(path, e.toString()));
      }
    }

    for (final path in discovered?.progresions ?? const <String>[]) {
      if (generation != _initGeneration) return;
      try {
        final progresion = await _loader.loadProgresion(path);
        if (generation != _initGeneration) return;
        _progresionsPorClave[progresion.clave] = progresion;
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

  // --- ASAMBLEAS DO 1.º CICLO (0-3) ---

  /// Todas as microcápsulas do 1.º ciclo: 10 meses x 2 tramos.
  List<AsambleaPrimeiroCiclo> getAllAsambleasPrimeiroCicloSync() {
    final list = _asambleasPrimeiroCicloById.values.toList();
    list.sort((a, b) {
      final ma = a.mes >= 9 ? a.mes : a.mes + 12;
      final mb = b.mes >= 9 ? b.mes : b.mes + 12;
      if (ma != mb) return ma.compareTo(mb);
      return a.tramo.clave.compareTo(b.tramo.clave);
    });
    return List.unmodifiable(list);
  }

  /// A progresión diaria dun tramo («primeiro_ciclo.0_2», «segundo_ciclo.4»),
  /// ou `null` se non está no paquete.
  ProgresionDoMes? getProgresionSync(String clave) =>
      _progresionsPorClave[clave];

  /// Todas as progresións diarias, ordenadas pola súa clave.
  List<ProgresionDoMes> getAllProgresionsSync() {
    final list = _progresionsPorClave.values.toList()
      ..sort((a, b) => a.clave.compareTo(b.clave));
    return List.unmodifiable(list);
  }

  /// A microcápsula dun mes e un tramo concretos, ou `null` se non existe.
  AsambleaPrimeiroCiclo? getAsambleaPrimeiroCicloSync(
      int mes, TramoPrimeiroCiclo tramo) {
    for (final a in _asambleasPrimeiroCicloById.values) {
      if (a.mes == mes && a.tramo == tramo) return a;
    }
    return null;
  }

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

  // --- CUENTOS (Banco de 200 Contos e Historias Progresivas) ---

  /// Loads pedagogical stories, optionally filtered by course ID and month.
  Future<List<Cuento>> loadCuentos({String? cursoId, int? mesNumero}) async {
    if (_cuentosById.isEmpty) {
      // El orden manda: primero el banco progresivo, que es el catálogo
      // completo; después el de 100, que solo aporta lo que no esté ya.
      final paths = [
        historiasProgresivasAssetPath,
        cuentos100AssetPath,
      ];
      // Un mismo título se repite a propósito en los cinco cursos: es la misma
      // asamblea contada para cada edad. Lo que NO puede repetirse es un título
      // dentro del MISMO curso, porque entonces la docente ve dos filas iguales
      // y no hay forma de saber cuál abrir.
      final vistosPorCurso = <String>{};
      for (final path in paths) {
        try {
          final raw = await _loader.loadRawString(path);
          final dynamic decoded = jsonDecode(raw);
          if (decoded is List) {
            for (final item in decoded) {
              final Cuento? cuento = item is Map<String, dynamic>
                  ? Cuento.fromJson(item)
                  : item is Map
                      ? Cuento.fromJson(Map<String, dynamic>.from(item))
                      : null;
              if (cuento == null) continue;
              final firma = '${cuento.cursoId}|${cuento.titulo.gl}';
              if (!vistosPorCurso.add(firma) &&
                  !_cuentosById.containsKey(cuento.id)) {
                continue;
              }
              _cuentosById[cuento.id] = cuento;
            }
          }
        } catch (e) {
          _loadErrors.add(ContentLoadFailure(path, e.toString()));
        }
      }
    }

    var list = _cuentosById.values.toList();
    if (cursoId != null && cursoId.trim().isNotEmpty) {
      final clean = cursoId.trim();
      list = list.where((c) => c.cursoId == clean).toList();
    }
    if (mesNumero != null) {
      list = list.where((c) => c.mesNumero == mesNumero).toList();
    }
    list.sort((a, b) {
      final cmpCurso = a.cursoId.compareTo(b.cursoId);
      if (cmpCurso != 0) return cmpCurso;
      final cmpMes = a.mesNumero.compareTo(b.mesNumero);
      if (cmpMes != 0) return cmpMes;
      final cmpSem = a.semanaSugerida.compareTo(b.semanaSugerida);
      if (cmpSem != 0) return cmpSem;
      return a.id.compareTo(b.id);
    });
    return List.unmodifiable(list);
  }

  /// Finds a story by its unique ID.
  Future<Cuento?> getCuentoById(String id) async {
    final cleanId = id.trim();
    if (_cuentosById.containsKey(cleanId)) {
      return _cuentosById[cleanId];
    }
    await loadCuentos();
    return _cuentosById[cleanId];
  }

  /// Synchronous lookup for an in-memory cached story.
  Cuento? getCuentoByIdSync(String id) => _cuentosById[id.trim()];

  // --- LAMINAS (Banco de 200+ Láminas Ilustradas) ---

  /// Loads didactic cards/flashcards, optionally filtered by category and CEFR level.
  Future<List<Lamina>> loadLaminas({String? categoria, String? nivel}) async {
    if (_laminasById.isEmpty) {
      try {
        final raw = await _loader.loadRawString(laminas200AssetPath);
        final dynamic decoded = jsonDecode(raw);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              final lamina = Lamina.fromJson(item);
              _laminasById[lamina.id] = lamina;
            } else if (item is Map) {
              final lamina = Lamina.fromJson(Map<String, dynamic>.from(item));
              _laminasById[lamina.id] = lamina;
            }
          }
        }
      } catch (e) {
        _loadErrors.add(ContentLoadFailure(laminas200AssetPath, e.toString()));
      }
    }

    var list = _laminasById.values.toList();
    if (categoria != null && categoria.trim().isNotEmpty) {
      final cleanCat = categoria.trim().toLowerCase();
      list = list.where((l) => l.categoria.toLowerCase() == cleanCat).toList();
    }
    if (nivel != null && nivel.trim().isNotEmpty) {
      final cleanNiv = nivel.trim().toLowerCase();
      list = list.where((l) => l.cefr.toLowerCase() == cleanNiv).toList();
    }
    list.sort((a, b) => a.numero.compareTo(b.numero));
    return List.unmodifiable(list);
  }

  /// Finds a didactic card by its unique ID.
  Future<Lamina?> getLaminaById(String id) async {
    final cleanId = id.trim();
    if (_laminasById.containsKey(cleanId)) {
      return _laminasById[cleanId];
    }
    await loadLaminas();
    return _laminasById[cleanId];
  }

  /// Synchronous lookup for a didactic card.
  Lamina? getLaminaByIdSync(String id) => _laminasById[id.trim()];

  // --- CORPUS 8,000 PALABRAS ---

  /// Loads the 8,000-word corpus, optionally filtered by frequency band (1..8) or CEFR level.
  Future<List<CorpusPalabra>> loadCorpusPalabras({
    int? banda,
    String? cefr,
    String? pos,
    bool soloOnomatopeias = false,
  }) async {
    if (_corpusPalabras.isEmpty) {
      // Una sola ruta, a propósito. Antes había un respaldo a la lista cruda
      // de 7.998 palabras: si el fichero bueno fallaba, la app enseñaba las
      // 7.998 sin categoría, sin frase y con las doce que Frank mandó quitar.
      // Un respaldo que enseña lo que se prohibió no es un respaldo.
      for (final path in [corpusCefrAssetPath]) {
        try {
          final raw = await _loader.loadRawString(path);
          final dynamic decoded = jsonDecode(raw);
          if (decoded is List && decoded.isNotEmpty) {
            _corpusPalabras.clear();
            for (final item in decoded) {
              if (item is Map<String, dynamic>) {
                _corpusPalabras.add(CorpusPalabra.fromJson(item));
              } else if (item is Map) {
                _corpusPalabras.add(
                  CorpusPalabra.fromJson(Map<String, dynamic>.from(item)),
                );
              }
            }
            break;
          }
        } catch (e) {
          _loadErrors.add(ContentLoadFailure(path, e.toString()));
        }
      }
    }

    var list = _corpusPalabras;
    if (banda != null) {
      list = list
          .where((p) => p.bandaNumero == banda || p.banda == '${banda}k')
          .toList();
    }
    if (cefr != null && cefr.trim().isNotEmpty) {
      // Igualdad, no `contains`. Con `contains`, pedir «B2» devolvía también
      // las de «B1/B2» y pedir «B1» las de «A2/B1»: dos pastillas distintas de
      // la pantalla daban listas solapadas, y la cuenta de arriba no cuadraba
      // con la banda elegida.
      final cleanCefr = cefr.trim().toLowerCase();
      list = list.where((p) => p.nivelCefr.toLowerCase() == cleanCefr).toList();
    }
    if (pos != null && pos.trim().isNotEmpty) {
      final cleanPos = pos.trim().toUpperCase();
      list = list.where((p) => p.pos == cleanPos).toList();
    }
    if (soloOnomatopeias) {
      list = list.where((p) => p.onomatopeya).toList();
    }
    return List.unmodifiable(list);
  }

  /// Searches words matching [query] by prefix or substring with intelligent ranking.
  Future<List<CorpusPalabra>> searchPalabras(String query) async {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return const [];
    if (_corpusPalabras.isEmpty) {
      await loadCorpusPalabras();
    }
    final results = _corpusPalabras.where((p) {
      final lemma = p.lemma.toLowerCase();
      return lemma.contains(clean);
    }).toList();

    results.sort((a, b) {
      final aLemma = a.lemma.toLowerCase();
      final bLemma = b.lemma.toLowerCase();
      final aExact = aLemma == clean;
      final bExact = bLemma == clean;
      if (aExact && !bExact) return -1;
      if (!aExact && bExact) return 1;

      final aStarts = aLemma.startsWith(clean);
      final bStarts = bLemma.startsWith(clean);
      if (aStarts && !bStarts) return -1;
      if (!aStarts && bStarts) return 1;

      final cmpBanda = a.bandaNumero.compareTo(b.bandaNumero);
      if (cmpBanda != 0) return cmpBanda;
      return a.id.compareTo(b.id);
    });
    return List.unmodifiable(results);
  }

  // --- CALENDARIO 1,000 DÍAS DUAL ---

  /// Loads daily dual calendar entries (aula + fogar) for a specific course and optional month.
  Future<List<DiaCalendarioDual>> loadCalendarioDias({
    required String cursoId,
    int? mes,
  }) async {
    if (_calendarioDias.isEmpty) {
      try {
        final raw = await _loader.loadRawString(calendarioDiasAssetPath);
        final dynamic decoded = jsonDecode(raw);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              _calendarioDias.add(DiaCalendarioDual.fromJson(item));
            } else if (item is Map) {
              _calendarioDias.add(
                DiaCalendarioDual.fromJson(Map<String, dynamic>.from(item)),
              );
            }
          }
        }
      } catch (e) {
        _loadErrors.add(
          ContentLoadFailure(calendarioDiasAssetPath, e.toString()),
        );
      }
    }

    final cleanCurso = cursoId.trim();
    var list = _calendarioDias.where((d) {
      return d.fechaClave.contains(cleanCurso) || cleanCurso.isEmpty;
    }).toList();

    if (mes != null) {
      list = list.where((d) => d.mesNumero == mes).toList();
    }

    list.sort((a, b) => a.diaGlobalNumero.compareTo(b.diaGlobalNumero));
    return List.unmodifiable(list);
  }

  // --- ENGLISH IMMERSION CORPUS ---

  /// Loads the English Immersion lexicon and dialogue scenarios.
  Future<EnglishCorpus> loadEnglishCorpus() async {
    if (_englishCorpus != null) return _englishCorpus!;
    try {
      final raw = await _loader.loadRawString(englishCorpusAssetPath);
      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        _englishCorpus = EnglishCorpus.fromJson(decoded);
      } else if (decoded is Map) {
        _englishCorpus =
            EnglishCorpus.fromJson(Map<String, dynamic>.from(decoded));
      } else if (decoded is List) {
        _englishCorpus = EnglishCorpus.fromJson({
          'words': decoded,
          'scenarios': [],
        });
      }
    } catch (e) {
      _loadErrors.add(ContentLoadFailure(englishCorpusAssetPath, e.toString()));
    }
    return _englishCorpus ?? const EnglishCorpus(words: [], scenarios: []);
  }

  // --- PHONICS TAXONOMY ---

  /// Loads the 44-phoneme taxonomy, decodable words, word families, and missions.
  Future<PhonicsTaxonomy> loadPhonicsTaxonomy() async {
    if (_phonicsTaxonomy != null) return _phonicsTaxonomy!;
    try {
      final raw = await _loader.loadRawString(phonicsTaxonomyAssetPath);
      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        _phonicsTaxonomy = PhonicsTaxonomy.fromJson(decoded);
      } else if (decoded is Map) {
        _phonicsTaxonomy =
            PhonicsTaxonomy.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (e) {
      _loadErrors
          .add(ContentLoadFailure(phonicsTaxonomyAssetPath, e.toString()));
    }
    return _phonicsTaxonomy ??
        const PhonicsTaxonomy(
          phonemes: [],
          decodableWords: [],
          wordFamilies: [],
          missions: [],
        );
  }

  // --- ESTRATEGIAS PEDAGÓXICAS ---

  /// Loads the pedagogical strategies catalogue.
  Future<List<EstrategiaPedagogica>> loadEstrategias() async {
    if (_estrategias.isEmpty) {
      try {
        final raw = await _loader.loadRawString(estrategiasAssetPath);
        final dynamic decoded = jsonDecode(raw);
        final List list = decoded is List
            ? decoded
            : (decoded is Map && decoded['estrategias'] is List
                ? decoded['estrategias'] as List
                : const []);
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            _estrategias.add(EstrategiaPedagogica.fromJson(item));
          } else if (item is Map) {
            _estrategias.add(
              EstrategiaPedagogica.fromJson(Map<String, dynamic>.from(item)),
            );
          }
        }
      } catch (e) {
        _loadErrors.add(ContentLoadFailure(estrategiasAssetPath, e.toString()));
      }
    }
    return List.unmodifiable(_estrategias);
  }

  // --- DINÁMICAS DA AULA ---

  /// Loads classroom dynamics.
  Future<List<DinamicaPedagogica>> loadDinamicas() async {
    if (_dinamicas.isEmpty) {
      try {
        final raw = await _loader.loadRawString(dinamicasAssetPath);
        final dynamic decoded = jsonDecode(raw);
        final List list = decoded is List
            ? decoded
            : (decoded is Map && decoded['dinamicas'] is List
                ? decoded['dinamicas'] as List
                : const []);
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            _dinamicas.add(DinamicaPedagogica.fromJson(item));
          } else if (item is Map) {
            _dinamicas.add(
              DinamicaPedagogica.fromJson(Map<String, dynamic>.from(item)),
            );
          }
        }
      } catch (e) {
        _loadErrors.add(ContentLoadFailure(dinamicasAssetPath, e.toString()));
      }
    }
    return List.unmodifiable(_dinamicas);
  }

  // --- CURRICULO 50 MESES ---

  /// Loads the 50-month curricular timeline (5 courses × 10 months).
  Future<List<MesCurricular50>> loadCurriculo50Meses() async {
    if (_curriculo50Meses.isEmpty) {
      try {
        final raw = await _loader.loadRawString(curriculo50MesesAssetPath);
        final dynamic decoded = jsonDecode(raw);
        final List list = decoded is List
            ? decoded
            : (decoded is Map && decoded['meses'] is List
                ? decoded['meses'] as List
                : const []);
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            _curriculo50Meses.add(MesCurricular50.fromJson(item));
          } else if (item is Map) {
            _curriculo50Meses.add(
              MesCurricular50.fromJson(Map<String, dynamic>.from(item)),
            );
          }
        }
      } catch (e) {
        _loadErrors.add(
          ContentLoadFailure(curriculo50MesesAssetPath, e.toString()),
        );
      }
    }
    return List.unmodifiable(_curriculo50Meses);
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

  /// Adds or updates a [Cuento] directly in memory (for tests and mocking).
  void addCuento(Cuento cuento) {
    _cuentosById[cuento.id] = cuento;
  }

  /// Adds or updates a [Lamina] directly in memory (for tests and mocking).
  void addLamina(Lamina lamina) {
    _laminasById[lamina.id] = lamina;
  }

  /// Adds a [CorpusPalabra] directly in memory (for tests and mocking).
  void addCorpusPalabra(CorpusPalabra palabra) {
    _corpusPalabras.add(palabra);
  }

  /// Adds a [DiaCalendarioDual] directly in memory (for tests and mocking).
  void addCalendarioDia(DiaCalendarioDual dia) {
    _calendarioDias.add(dia);
  }

  /// Sets [EnglishCorpus] directly in memory (for tests and mocking).
  void setEnglishCorpus(EnglishCorpus corpus) {
    _englishCorpus = corpus;
  }

  /// Sets [PhonicsTaxonomy] directly in memory (for tests and mocking).
  void setPhonicsTaxonomy(PhonicsTaxonomy taxonomy) {
    _phonicsTaxonomy = taxonomy;
  }

  /// Adds an [EstrategiaPedagogica] directly in memory (for tests and mocking).
  void addEstrategia(EstrategiaPedagogica estrategia) {
    _estrategias.add(estrategia);
  }

  /// Adds a [DinamicaPedagogica] directly in memory (for tests and mocking).
  void addDinamica(DinamicaPedagogica dinamica) {
    _dinamicas.add(dinamica);
  }

  /// Adds a [MesCurricular50] directly in memory (for tests and mocking).
  void addMesCurricular50(MesCurricular50 mes) {
    _curriculo50Meses.add(mes);
  }

  /// Clears all cached content across all modules.
  void clear() {
    _initGeneration++;
    _initFuture = null;
    _unidadesById.clear();
    _capsulasById.clear();
    _asambleasPrimeiroCicloById.clear();
    _asambleasSegundoCicloById.clear();
    _progresionsPorClave.clear();
    _cuentosById.clear();
    _laminasById.clear();
    _corpusPalabras.clear();
    _calendarioDias.clear();
    _englishCorpus = null;
    _phonicsTaxonomy = null;
    _estrategias.clear();
    _dinamicas.clear();
    _curriculo50Meses.clear();
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
        asambleasPrimeiroCiclo: (assets
            .where((a) => isJsonUnder(
                a, ContentAssetLoader.asambleasPrimeiroCicloAssetPrefix))
            .toList()
          ..sort()),
        asambleasSegundoCiclo: (assets
            .where((a) => isJsonUnder(
                a, ContentAssetLoader.asambleasSegundoCicloAssetPrefix))
            .toList()
          ..sort()),
        progresions: (assets
            .where(
                (a) => isJsonUnder(a, ContentAssetLoader.progresionAssetPrefix))
            .toList()
          ..sort()),
      );
    } catch (_) {
      return const _DiscoveredContent(
        unidades: [],
        capsulas: [],
        asambleasPrimeiroCiclo: [],
        asambleasSegundoCiclo: [],
      );
    }
  }
}

class _DiscoveredContent {
  final List<String> unidades;
  final List<String> capsulas;
  final List<String> asambleasPrimeiroCiclo;
  final List<String> asambleasSegundoCiclo;
  final List<String> progresions;

  const _DiscoveredContent({
    required this.unidades,
    required this.capsulas,
    this.asambleasPrimeiroCiclo = const [],
    this.asambleasSegundoCiclo = const [],
    this.progresions = const [],
  });
}
