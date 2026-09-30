import '../models/asamblea_segundo_ciclo_model.dart';
import '../models/capsula_model.dart';
import '../models/curricular_model.dart';

/// Structured outcome of content validation checks.
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  factory ValidationResult.success({List<String>? warnings}) {
    return ValidationResult(
      isValid: true,
      errors: const [],
      warnings: List.unmodifiable(warnings ?? const []),
    );
  }

  factory ValidationResult.failure(List<String> errors,
      {List<String>? warnings}) {
    return ValidationResult(
      isValid: false,
      errors: List.unmodifiable(errors),
      warnings: List.unmodifiable(warnings ?? const []),
    );
  }

  @override
  String toString() {
    if (isValid) {
      return 'ValidationResult: PASS (warnings: ${warnings.length})';
    }
    return 'ValidationResult: FAIL (${errors.length} errors):\n - ${errors.join('\n - ')}';
  }
}

/// Programmatic validator enforcing bilingual parity, curricular alignment with Decreto 150/2022,
/// zero clinical terms blacklist, and referential integrity across all content.
class ContentValidator {
  /// Strict regex pattern matching prohibited clinical, pathological, or diagnostic terms.
  /// Derived from clinical wall specifications for 0-3 years infant education.
  static final RegExp forbiddenClinicalPattern = RegExp(
    r'\b(trastorno|trastornos|patolog[ií]a|patolog[ií]as|patolox[ií]a|patolox[ií]as|patol[oó][gx]ic[oa]s?|'
    r'diagn[oó]stic[oa]s?|diagnostic[a-záéíóúñ]+|s[ií]ntoma|s[ií]ntomas|sintomatolog[ií]a|'
    r'sintomatolox[ií]a|d[eé]ficit|d[eé]ficits|paciente|pacientes|terapia|'
    r'terapias|terap[eé]utic[oa]s?|'
    r'(?!(tratamiento|tratamento)\s+d[eé]\s+a(ug|gu)a)(tratamiento|tratamientos|tratamento|tratamentos)|'
    r'retrasos?\s+cl[ií]nic[oa]s?|dislalia|dislalias|disl[aá]lic[oa]s?|dislexia|dislexias|disl[eé]xic[oa]s?|'
    r'hipoacusia\s+cl[ií]nica|afasia|disfasia|rehabilit[a-záéíóúñ]+|'
    r'criba[sxd]?[a-záéíóúñ]*|screening|pron[oó]stico)\b',
    caseSensitive: false,
  );

  /// Marcadores de desarrollo que NO son palabras de ninguna de las dos
  /// lenguas del contenido. Se rechazan escritos como se escriban: en gallego
  /// o en castellano nadie escribe «placeholder» queriendo decir algo.
  static final RegExp placeholderPattern = RegExp(
    r'\b(PLACEHOLDER|TBD|LOREM\s+IPSUM)\b',
    caseSensitive: false,
  );

  /// TODO, PENDIENTE y PENDENTE sí son palabras corrientes: «sobre todo»,
  /// «pendente da percha». Rechazarlas en minúscula convertiría el validador
  /// en un estorbo, así que solo se rechazan en MAYÚSCULAS, que es como las
  /// deja una herramienta y nunca quien redacta.
  static final RegExp placeholderUpperPattern = RegExp(
    r'\b(TODO|PENDIENTE|PENDENTE)\b',
  );

  /// Un texto lleva marcador de desarrollo si cae en cualquiera de los dos.
  static bool hasPlaceholder(String value) =>
      placeholderPattern.hasMatch(value) ||
      placeholderUpperPattern.hasMatch(value);

  /// Valid audio asset extensions for offline playback.
  static const Set<String> validAudioExtensions = {
    '.mp3',
    '.wav',
    '.ogg',
    '.m4a'
  };

  /// Defensive type-safe Map extraction helper to prevent runtime TypeError crashes.
  static Map<String, dynamic>? _asMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return Map<String, dynamic>.from(v);
    return null;
  }

  /// Validates a complete [Unidad] JSON document.
  ValidationResult validateUnidadJson(Map<String, dynamic> json,
      {String sourcePath = ''}) {
    final List<String> errors = [];
    final List<String> warnings = [];

    final prefix = sourcePath.isNotEmpty ? '[$sourcePath] ' : '';

    // 1. Root structure
    if (!json.containsKey('id') ||
        json['id'] is! String ||
        (json['id'] as String).trim().isEmpty) {
      errors.add(
          '${prefix}Missing or empty root "id": must be a non-empty string');
    }

    final tramo = json['tramoEtario'] ?? json['tramo_etario'];
    if (tramo != '0-2' && tramo != '2-3' && tramo != '0-3') {
      errors.add(
          '${prefix}Invalid "tramoEtario": must be "0-2", "2-3", or "0-3" (got: "$tramo")');
    }

    // 2. Bilingual parity check across entire tree
    checkBilingualParity(json, path: 'root', errors: errors, prefix: prefix);

    // 3. Clinical term blacklist check across entire tree
    checkClinicalTerms(json, path: 'root', errors: errors, prefix: prefix);

    // 4. Curricular alignment (Decreto 150/2022)
    final curriculo = _asMap(json['curriculo'] ?? json['curricular']);
    if (curriculo == null) {
      errors.add('${prefix}Missing required "curriculo" section');
    } else {
      checkCurricularAlignment(curriculo, errors: errors, prefix: prefix);
    }

    // 5. Referential integrity and required sections
    checkReferentialIntegrityUnidad(json,
        errors: errors, warnings: warnings, prefix: prefix);

    return errors.isEmpty
        ? ValidationResult.success(warnings: warnings)
        : ValidationResult.failure(errors, warnings: warnings);
  }

  /// Validates a complete [Capsula] JSON document.
  ValidationResult validateCapsulaJson(Map<String, dynamic> json,
      {String sourcePath = ''}) {
    final List<String> errors = [];
    final List<String> warnings = [];

    final prefix = sourcePath.isNotEmpty ? '[$sourcePath] ' : '';

    // 1. Root structure
    if (!json.containsKey('id') ||
        json['id'] is! String ||
        (json['id'] as String).trim().isEmpty) {
      errors.add(
          '${prefix}Missing or empty root "id": must be a non-empty string');
    }

    final bloqueId = json['bloqueId']?.toString().trim() ??
        json['bloque_id']?.toString().trim();
    if (bloqueId == null || bloqueId.isEmpty) {
      errors.add('${prefix}Missing required "bloqueId"');
    } else {
      final validBlock = Bloque.byId(bloqueId);
      if (validBlock == null) {
        errors.add('${prefix}Invalid "bloqueId": "$bloqueId" is not among the '
            '5 Academy blocks nor the 6 classroom blocks');
      } else {
        // El destinatario y el bloque tienen que decir lo mismo. Si no, una
        // cápsula del aula acabaría en la lista de Academy —o al revés— y el
        // defecto no se vería hasta abrir la pantalla equivocada: la lista se
        // pinta igual de bien con la cápsula que no toca.
        final destinatario =
            DestinatarioCapsula.desdeClave(json['destinatario']?.toString());
        final esDeAula = Bloque.aula.any((b) => b.id == validBlock.id);
        if (destinatario == DestinatarioCapsula.docente && !esDeAula) {
          errors.add('${prefix}Capsule declares destinatario "docente" but '
              '"$bloqueId" is an Academy block');
        }
        if (destinatario == DestinatarioCapsula.familia && esDeAula) {
          errors.add('${prefix}Capsule is for "familia" but "$bloqueId" is a '
              'classroom block; declare "destinatario": "docente"');
        }
      }
    }

    // 2. Bilingual parity check across entire tree
    checkBilingualParity(json, path: 'root', errors: errors, prefix: prefix);

    // 3. Clinical term blacklist check across entire tree
    checkClinicalTerms(json, path: 'root', errors: errors, prefix: prefix);

    // 4. Curricular alignment (Decreto 150/2022)
    final curriculo = _asMap(json['curriculo'] ?? json['curricular']);
    if (curriculo == null) {
      errors.add('${prefix}Missing required "curriculo" section');
    } else {
      checkCurricularAlignment(curriculo, errors: errors, prefix: prefix);
    }

    // 5. Referential integrity and 4 canonical parts
    checkReferentialIntegrityCapsula(json,
        errors: errors, warnings: warnings, prefix: prefix);

    return errors.isEmpty
        ? ValidationResult.success(warnings: warnings)
        : ValidationResult.failure(errors, warnings: warnings);
  }

  /// Recursively audits the JSON tree to guarantee 1:1 non-empty parity for every [LocalizedString].
  void checkBilingualParity(
    dynamic node, {
    String path = 'root',
    required List<String> errors,
    String prefix = '',
  }) {
    if (node is Map) {
      // Check if this map represents a LocalizedString node
      final hasGl = node.containsKey('gl');
      final hasEs = node.containsKey('es');

      if (hasGl && hasEs) {
        final glVal = node['gl'];
        final esVal = node['es'];

        if (glVal is! String || glVal.trim().isEmpty) {
          errors.add('$prefix$path: "gl" is missing, not a string, or blank');
        } else if (hasPlaceholder(glVal)) {
          errors.add(
              '$prefix$path: "gl" contains forbidden placeholder: "${glVal.trim()}"');
        }

        if (esVal is! String || esVal.trim().isEmpty) {
          errors.add('$prefix$path: "es" is missing, not a string, or blank');
        } else if (hasPlaceholder(esVal)) {
          errors.add(
              '$prefix$path: "es" contains forbidden placeholder: "${esVal.trim()}"');
        }
      } else if (hasGl && !hasEs) {
        errors.add(
            '$prefix$path: Asymmetric bilingual node: contains "gl" but missing "es"');
      } else if (!hasGl && hasEs) {
        errors.add(
            '$prefix$path: Asymmetric bilingual node: contains "es" but missing "gl"');
      }

      // Recurse children
      node.forEach((key, value) {
        checkBilingualParity(value,
            path: '$path.$key', errors: errors, prefix: prefix);
      });
    } else if (node is List) {
      for (var i = 0; i < node.length; i++) {
        checkBilingualParity(node[i],
            path: '$path[$i]', errors: errors, prefix: prefix);
      }
    }
  }

  /// Recursively audits the JSON tree against the clinical blacklist regex.
  void checkClinicalTerms(
    dynamic node, {
    String path = 'root',
    required List<String> errors,
    String prefix = '',
  }) {
    if (node is String) {
      final match = forbiddenClinicalPattern.firstMatch(node);
      if (match != null) {
        errors.add(
          '$prefix$path contains prohibited clinical/diagnostic term: "${match.group(0)}" '
          '(must use educational/pedagogical equivalence for 0-3 years)',
        );
      }
    } else if (node is Map) {
      node.forEach((key, value) {
        checkClinicalTerms(value,
            path: '$path.$key', errors: errors, prefix: prefix);
      });
    } else if (node is List) {
      for (var i = 0; i < node.length; i++) {
        checkClinicalTerms(node[i],
            path: '$path[$i]', errors: errors, prefix: prefix);
      }
    }
  }

  /// Audits the curricular reference block against Decreto 150/2022.
  void checkCurricularAlignment(
    Map<String, dynamic> curriculo, {
    required List<String> errors,
    String prefix = '',
  }) {
    final normativa = curriculo['normativa']?.toString().trim();
    if (normativa != CurricularReference.decretoGalicia) {
      errors.add(
        '${prefix}curriculo.normativa must be "${CurricularReference.decretoGalicia}" (got: "$normativa")',
      );
    }

    final etapa = curriculo['etapa']?.toString().trim();
    if (etapa != CurricularReference.etapaInfantil) {
      errors.add(
        '${prefix}curriculo.etapa must be "${CurricularReference.etapaInfantil}" (got: "$etapa")',
      );
    }

    final ciclo = curriculo['ciclo']?.toString().trim();
    final isSegundoCiclo =
        ciclo == CurricularReferenceSegundoCiclo.cicloSegundo;
    if (ciclo != CurricularReference.ciclo03 && !isSegundoCiclo) {
      errors.add(
        '${prefix}curriculo.ciclo must be "${CurricularReference.ciclo03}" or "${CurricularReferenceSegundoCiclo.cicloSegundo}" (got: "$ciclo")',
      );
    }

    final areas = curriculo['areas'];
    if (areas is! List || areas.isEmpty) {
      errors.add('${prefix}curriculo.areas must be a non-empty list');
    } else {
      for (final area in areas) {
        final areaStr = area.toString().trim();
        final validAreas = isSegundoCiclo
            ? CurricularReferenceSegundoCiclo.validAreas
            : CurricularReference.validAreas;
        if (!validAreas.contains(areaStr)) {
          errors.add(
            '${prefix}curriculo.areas contains unrecognized area "$areaStr". Valid areas: ${validAreas.toList()}',
          );
        }
      }
    }

    final criterios =
        curriculo['criteriosEvaluacion'] ?? curriculo['criterios_evaluacion'];
    if (criterios is! List || criterios.isEmpty) {
      errors.add(
          '${prefix}curriculo.criteriosEvaluacion must be a non-empty list');
    } else {
      final validCriterios = isSegundoCiclo
          ? CurricularReferenceSegundoCiclo.validCriteriosSegundoCiclo
          : CurricularReference.validCriterios;
      for (final crit in criterios) {
        final critStr = crit.toString().trim();
        if (!validCriterios.contains(critStr)) {
          errors.add(
            '${prefix}curriculo.criteriosEvaluacion contains unrecognized criterion "$critStr". Valid criteria: ${validCriterios.toList()}',
          );
        }
      }
    }
  }

  /// Verifies referential integrity and required sections for a unit.
  void checkReferentialIntegrityUnidad(
    Map<String, dynamic> json, {
    required List<String> errors,
    required List<String> warnings,
    String prefix = '',
  }) {
    // 1. Canción a pulso
    final cancion = _asMap(json['cancionPulso'] ?? json['cancion']);
    if (cancion == null) {
      errors.add('${prefix}Missing required section: "cancionPulso"');
    } else {
      if (cancion.containsKey('bpm')) {
        final bpmVal = cancion['bpm'];
        if (bpmVal is! num) {
          errors.add(
              '${prefix}cancionPulso.bpm must be an integer between 40 and 160 BPM (got: $bpmVal)');
        } else {
          final bpm = bpmVal.toInt();
          if (bpm < 40 || bpm > 160) {
            errors.add(
                '${prefix}cancionPulso.bpm must be an integer between 40 and 160 BPM (got: $bpm)');
          }
        }
      }
      final audioAsset = cancion['audioAsset'] ?? cancion['audio_asset'];
      _validateAudioAsset(audioAsset,
          path: 'cancionPulso.audioAsset', errors: errors, prefix: prefix);
    }

    // 2. Cuento
    final cuento = _asMap(json['cuento'] ?? json['conto']);
    if (cuento == null) {
      errors.add('${prefix}Missing required section: "cuento"');
    } else {
      final paginas = cuento['paginas'];
      if (paginas is! List || paginas.isEmpty) {
        errors.add('${prefix}cuento.paginas must have at least one story page');
      }
    }

    // 3. Vocabulario
    final vocab = json['vocabulario'];
    if (vocab is! List || vocab.isEmpty) {
      errors.add('${prefix}vocabulario must contain at least one item');
    } else {
      for (var i = 0; i < vocab.length; i++) {
        final item = vocab[i];
        if (item is Map<String, dynamic>) {
          final a = item['audioAsset'] ?? item['audio_asset'];
          _validateAudioAsset(a,
              path: 'vocabulario[$i].audioAsset',
              errors: errors,
              prefix: prefix);
        }
      }
    }

    // 4. Preguntas (Must contain levels 1, 2, and 3)
    final preguntas = json['preguntas'];
    if (preguntas is! List || preguntas.isEmpty) {
      errors.add('${prefix}preguntas must contain graduated questions');
    } else {
      final Set<int> levelsFound = {};
      for (final p in preguntas) {
        if (p is Map) {
          final n = (p['nivel'] as num?)?.toInt();
          if (n != null) levelsFound.add(n);
        }
      }
      for (final reqLevel in [1, 2, 3]) {
        if (!levelsFound.contains(reqLevel)) {
          errors.add(
              '${prefix}preguntas is missing graduated scaffolding level $reqLevel');
        }
      }
    }

    // 5. Exploracion & mandatory safety notice
    final exploracion =
        _asMap(json['exploracion'] ?? json['exploracionSensorial']);
    if (exploracion == null) {
      errors.add('${prefix}Missing required section: "exploracion"');
    } else {
      final aviso = _asMap(
          exploracion['avisoSeguridad'] ?? exploracion['aviso_seguridad']);
      if (aviso == null) {
        errors.add(
            '${prefix}exploracion missing MANDATORY "avisoSeguridad" object');
      } else {
        final gl = aviso['gl']?.toString() ?? '';
        final es = aviso['es']?.toString() ?? '';
        if (gl.trim().isEmpty || es.trim().isEmpty) {
          errors.add(
              '${prefix}exploracion.avisoSeguridad must be populated in both gl and es');
        }
      }
    }

    // 6. Matematicas tempranas
    final matematicas =
        _asMap(json['matematicas'] ?? json['matematicasTempras']);
    if (matematicas == null) {
      errors.add('${prefix}Missing required section: "matematicas"');
    }

    // 7. Puente a casa
    final puenteCasa =
        _asMap(json['puenteCasa'] ?? json['ponteCasa'] ?? json['puente_casa']);
    if (puenteCasa == null) {
      errors.add('${prefix}Missing required section: "puenteCasa"');
    }
  }

  /// Verifies referential integrity and the 4 canonical sections for a capsule.
  void checkReferentialIntegrityCapsula(
    Map<String, dynamic> json, {
    required List<String> errors,
    required List<String> warnings,
    String prefix = '',
  }) {
    final contido = _asMap(json['contido']) ?? {};

    // 4 canonical sections must be present either at root or inside contido
    final sections = [
      'ideaClave',
      'porQueImporta',
      'queHacerEnCasa',
      'ejemploCotidiano'
    ];
    for (final sec in sections) {
      final secData = _asMap(json[sec] ?? contido[sec]);
      if (secData == null ||
          !secData.containsKey('gl') ||
          !secData.containsKey('es')) {
        errors.add('${prefix}Capsule missing canonical section: "$sec"');
      }
    }

    // Afirmaciones
    final afirmaciones = json['afirmaciones'];
    if (afirmaciones is! List || afirmaciones.isEmpty) {
      errors.add(
          '${prefix}Capsule must contain at least one reflective "afirmaciones" item');
    }
  }

  void _validateAudioAsset(
    dynamic audio, {
    required String path,
    required List<String> errors,
    String prefix = '',
  }) {
    if (audio == null) {
      errors.add('$prefix$path: Missing audio asset path');
      return;
    }
    if (audio is String) {
      _checkAudioPath(audio, path: path, errors: errors, prefix: prefix);
    } else if (audio is Map) {
      final gl = audio['gl']?.toString() ?? '';
      final es = audio['es']?.toString() ?? '';
      if (gl.isEmpty) {
        errors.add('$prefix$path.gl: Missing audio path');
      } else {
        _checkAudioPath(gl, path: '$path.gl', errors: errors, prefix: prefix);
      }

      if (es.isEmpty) {
        errors.add('$prefix$path.es: Missing audio path');
      } else {
        _checkAudioPath(es, path: '$path.es', errors: errors, prefix: prefix);
      }
    }
  }

  void _checkAudioPath(
    String pathStr, {
    required String path,
    required List<String> errors,
    String prefix = '',
  }) {
    final lower = pathStr.toLowerCase().trim();
    final hasValidExt = validAudioExtensions.any((ext) => lower.endsWith(ext));
    if (!hasValidExt) {
      errors.add(
        '$prefix$path: Invalid audio file extension in "$pathStr". Must be one of $validAudioExtensions',
      );
    }
    // Bundled paths only. This is what keeps a remote URL from ever reaching
    // the player: assets/voice/ holds the synthesised neural recordings and
    // assets/audio/ the instrumental tracks.
    const bundledPrefixes = ['assets/voice/', 'assets/audio/'];
    if (!bundledPrefixes.any(pathStr.startsWith)) {
      errors.add(
        '$prefix$path: Audio asset path must begin with one of $bundledPrefixes (got: "$pathStr")',
      );
    }
  }

  /// Validates a complete [AsambleaSegundoCiclo] JSON document.
  ValidationResult validateAsambleaSegundoCicloJson(
    Map<String, dynamic> json, {
    String sourcePath = '',
  }) {
    final List<String> errors = [];
    final List<String> warnings = [];

    final prefix = sourcePath.isNotEmpty ? '[$sourcePath] ' : '';

    // 1. Root structure
    if (!json.containsKey('id') ||
        json['id'] is! String ||
        (json['id'] as String).trim().isEmpty) {
      errors.add(
          '${prefix}Missing or empty root "id": must be a non-empty string');
    }

    final nivelStr = json['nivel']?.toString().trim();
    if (nivelStr == null || nivelStr.isEmpty) {
      errors.add('${prefix}Missing required "nivel"');
    } else if (nivelStr != '4_infantil' &&
        nivelStr != '5_infantil' &&
        nivelStr != '6_infantil') {
      errors.add(
          '${prefix}Invalid "nivel": "$nivelStr" (expected 4_infantil, 5_infantil, or 6_infantil)');
    }

    final mes = json['mes'];
    if (mes is! int || mes < 1 || mes > 12) {
      errors.add(
          '${prefix}Invalid or missing "mes": must be an integer between 1 and 12');
    }

    final metodologiaStr = json['metodologiaTpr']?.toString().trim() ??
        json['metodologia_tpr']?.toString().trim();
    if (metodologiaStr == null || metodologiaStr.isEmpty) {
      errors.add('${prefix}Missing required "metodologiaTpr"');
    } else {
      const validMetodologias = [
        'accion_expandida',
        'dramatizado_narrativo',
        'transaccional_pragmatico',
      ];
      if (!validMetodologias.contains(metodologiaStr.toLowerCase())) {
        errors.add(
            '${prefix}Invalid "metodologiaTpr": "$metodologiaStr". Valid values: $validMetodologias');
      }
    }

    // 2. Bilingual parity check across entire tree
    checkBilingualParity(json, path: 'root', errors: errors, prefix: prefix);

    // 3. Clinical term blacklist check across entire tree
    checkClinicalTerms(json, path: 'root', errors: errors, prefix: prefix);

    // 4. Curricular alignment (Decreto 150/2022)
    final curriculo = _asMap(json['curriculo'] ?? json['curricular']);
    if (curriculo == null) {
      errors.add('${prefix}Missing required "curriculo" section');
    } else {
      checkCurricularAlignment(curriculo, errors: errors, prefix: prefix);
    }

    // 5. Referential integrity and required 4 phases
    checkReferentialIntegrityAsamblea(json,
        errors: errors, warnings: warnings, prefix: prefix);

    return errors.isEmpty
        ? ValidationResult.success(warnings: warnings)
        : ValidationResult.failure(errors, warnings: warnings);
  }

  /// Verifies structural integrity of the 4 canonical phases of an assembly session.
  void checkReferentialIntegrityAsamblea(
    Map<String, dynamic> json, {
    required List<String> errors,
    required List<String> warnings,
    String prefix = '',
  }) {
    final rawFases = json['fases'];
    if (rawFases is! List) {
      errors.add('${prefix}Missing or invalid "fases": must be a list');
      return;
    }

    if (rawFases.length != 4) {
      errors.add(
          '${prefix}Assembly must have exactly 4 canonical phases (got ${rawFases.length})');
      return;
    }

    final expectedTypes = [
      'apertura_saudo',
      'movement_rhythm_focus',
      'core_tpr_challenge',
      'calma_transicion',
    ];
    final expectedDurations = [90, 120, 270, 120];

    int totalDuration = 0;

    for (var i = 0; i < 4; i++) {
      final fase = _asMap(rawFases[i]);
      if (fase == null) {
        errors.add('${prefix}fases[$i] is not a valid JSON object');
        continue;
      }

      final orden = fase['orden'];
      if (orden != i + 1) {
        errors.add('${prefix}fases[$i].orden must be ${i + 1} (got: $orden)');
      }

      final tipo = fase['tipo']?.toString().trim();
      if (tipo != expectedTypes[i]) {
        errors.add(
            '${prefix}fases[$i].tipo must be "${expectedTypes[i]}" (got: "$tipo")');
      }

      final duracion = fase['duracionSegundos'] ?? fase['duracion_segundos'];
      if (duracion is! int || duracion != expectedDurations[i]) {
        errors.add(
            '${prefix}fases[$i].duracionSegundos must be exactly ${expectedDurations[i]}s (got: $duracion)');
      } else {
        totalDuration += duracion;
      }

      // Phase 3 (Core TPR Challenge) must contain L3 commands
      if (i == 2) {
        final comandos = fase['comandosL3'] ?? fase['comandos_l3'];
        if (comandos is! List || comandos.isEmpty) {
          errors.add(
              '${prefix}Phase 3 (Core TPR Challenge) must contain at least 1 L3 command');
        } else {
          for (var cIdx = 0; cIdx < comandos.length; cIdx++) {
            final cmd = _asMap(comandos[cIdx]);
            if (cmd == null) {
              errors.add('${prefix}comandosL3[$cIdx] is not a valid object');
              continue;
            }
            final textoIngles = cmd['textoIngles']?.toString().trim() ??
                cmd['texto_ingles']?.toString().trim();
            if (textoIngles == null || textoIngles.isEmpty) {
              errors.add(
                  '${prefix}comandosL3[$cIdx] missing required "textoIngles"');
            }
            final audioAsset = cmd['audioAsset']?.toString().trim() ??
                cmd['audio_asset']?.toString().trim();
            if (audioAsset != null && audioAsset.isNotEmpty) {
              _checkAudioPath(audioAsset,
                  path: 'comandosL3[$cIdx].audioAsset',
                  errors: errors,
                  prefix: prefix);
            }
          }
        }
      }
    }

    if (totalDuration != 600) {
      errors.add(
          '${prefix}Total assembly duration must sum exactly 600 seconds / 10 minutes (got $totalDuration s)');
    }

    // Check natural materials safety notice
    final materiales = json['materialesEntorno'] ?? json['materiales_entorno'];
    if (materiales is List) {
      for (var mIdx = 0; mIdx < materiales.length; mIdx++) {
        final mat = _asMap(materiales[mIdx]);
        if (mat != null) {
          final aviso = mat['avisoSeguridad'] ?? mat['aviso_seguridad'];
          if (aviso == null) {
            errors.add(
                '${prefix}materialesEntorno[$mIdx] missing required "avisoSeguridad"');
          }
        }
      }
    }

    // Check home micro-routine
    final rutina = json['microRutinaHogar'] ?? json['micro_rutina_hogar'];
    if (rutina != null && rutina is Map) {
      final pautas = rutina['pautasRecast'] ?? rutina['pautas_recast'];
      if (pautas is! List || pautas.isEmpty) {
        errors.add(
            '${prefix}microRutinaHogar must contain at least one recast guideline ("pautasRecast")');
      }
    }
  }

  // ───────────────────────────────────────────────────────────── STEAM ────

  /// Materiales que no pueden aparecer en ninguna unidad STEAM, a ninguna edad.
  ///
  /// Nace de la primera versión del módulo, que ponía un globo de látex tensado
  /// y veinte granos de arroz crudo delante de criaturas de 3 a 4 años. Los
  /// globos son la primera causa de muerte por atragantamiento no alimentario
  /// en la infancia, y las legumbres y semillas están entre los cuerpos extraños
  /// que más se sacan de la nariz y el oído entre el año y los cinco. Solo mira
  /// la lista de materiales: un aviso que diga «nada de globos» es correcto.
  static final RegExp steamMaterialProhibido = RegExp(
    r'\b(globos?|l[áa]tex|arroz|grans|granos|gr[aá]os|legumes|legumbres|'
    r'lentellas?|lentejas?|garavanzos?|garbanzos?|feix[óo]ns?|jud[ií]as?|'
    r'alubias?|canicas?|im[áa]ns?|imanes|pilas? de bot[óo]n|moedas?|monedas?|'
    r'sementes?|semillas?|pomp[óo]ns?|pompones|bot[óo]ns|botones)\b',
    caseSensitive: false,
  );

  /// Vocabulario clínico o de evaluación del desarrollo que el filtro general
  /// no caza. La primera versión describía a una criatura de 3 años que
  /// «fonoarticula» o que «precisa modelado fonador»: eso es lenguaje de
  /// consulta, y esta app no tiene finalidad sanitaria.
  static final RegExp steamVocabularioClinico = RegExp(
    r'(fonoarticul|fonador|cl[ií]nic|neuroevolutiv|neurodesarroll|'
    r'neurodesenvolv|est[ií]mul)',
    caseSensitive: false,
  );

  /// Las ocho competencias clave de la LOMLOE que recoge el Decreto 150/2022.
  static const Set<String> competenciasClaveLomloe = {
    'CCL',
    'CP',
    'STEM',
    'CD',
    'CPSAA',
    'CC',
    'CE',
    'CCEC',
  };

  /// Cada nivel con su curso y, desde los 3 años, con su nivel de segundo ciclo.
  static const Map<String, (String, String)> _steamNiveles = {
    'I1': ('curso_0_2', ''),
    'I2': ('curso_2_3', ''),
    'I3': ('curso_3_4', '4_infantil'),
    'I4': ('curso_4_5', '5_infantil'),
    'I5': ('curso_5_6', '6_infantil'),
  };

  /// Valida el fichero entero de unidades STEAM.
  ValidationResult validateSteamBankJson(
    dynamic json, {
    String sourcePath = '',
  }) {
    final errors = <String>[];
    final warnings = <String>[];

    if (json is! List) {
      return ValidationResult.failure(
          ['Expected JSON array at root for STEAM units']);
    }
    if (json.isEmpty) {
      return ValidationResult.failure(['STEAM units file cannot be empty']);
    }

    final ids = <String>{};
    for (var i = 0; i < json.length; i++) {
      final unit = _asMap(json[i]);
      if (unit == null) {
        errors.add('steam[$i] must be a JSON object');
        continue;
      }
      final id = unit['id']?.toString().trim() ?? '';
      if (id.isNotEmpty && !ids.add(id)) {
        errors.add('steam[$i]: duplicated id "$id"');
      }
      _validateSteamUnitFields(unit, errors, warnings,
          sourcePath: '$sourcePath[$i]');
    }

    return errors.isEmpty
        ? ValidationResult.success(warnings: warnings)
        : ValidationResult.failure(errors, warnings: warnings);
  }

  /// Valida una sola unidad STEAM.
  ValidationResult validateSteamUnitJson(
    Map<String, dynamic> json, {
    String sourcePath = '',
  }) {
    final errors = <String>[];
    final warnings = <String>[];
    _validateSteamUnitFields(json, errors, warnings, sourcePath: sourcePath);
    return errors.isEmpty
        ? ValidationResult.success(warnings: warnings)
        : ValidationResult.failure(errors, warnings: warnings);
  }

  bool _esTextoBilingue(dynamic node) {
    final m = _asMap(node);
    if (m == null) return false;
    final gl = m['gl'];
    final es = m['es'];
    return gl is String &&
        gl.trim().isNotEmpty &&
        es is String &&
        es.trim().isNotEmpty;
  }

  void _steamTodasLasCadenas(dynamic node, void Function(String) f) {
    if (node is String) {
      f(node);
    } else if (node is Map) {
      for (final v in node.values) {
        _steamTodasLasCadenas(v, f);
      }
    } else if (node is List) {
      for (final v in node) {
        _steamTodasLasCadenas(v, f);
      }
    }
  }

  void _validateSteamUnitFields(
    Map<String, dynamic> json,
    List<String> errors,
    List<String> warnings, {
    String sourcePath = '',
  }) {
    final prefix = sourcePath.isNotEmpty ? '[$sourcePath] ' : '';

    for (final field in const [
      'id',
      'estadio',
      'nivelMadurativo',
      'rangoEdad',
      'titulo',
      'fenomeno',
      'tiempoEstimadoMin',
      'calendario',
      'curriculo',
      'seguridad',
      'ordenesIngles',
      'queObservar',
      'aula',
      'hogar',
    ]) {
      if (!json.containsKey(field) || json[field] == null) {
        errors.add('${prefix}Missing required STEAM field: "$field"');
      }
    }

    checkBilingualParity(json, path: 'steam', errors: errors, prefix: prefix);
    checkClinicalTerms(json, path: 'steam', errors: errors, prefix: prefix);
    _steamTodasLasCadenas(json, (texto) {
      final m = steamVocabularioClinico.firstMatch(texto);
      if (m != null) {
        errors.add(
            '${prefix}clinical or assessment vocabulary "${m.group(0)}" in: "$texto"');
      }
      if (texto.contains('assets/')) {
        errors.add(
            '${prefix}STEAM content must not hard-code asset paths (voice is derived from the text): "$texto"');
      }
    });

    // Nivel, curso y ciclo tienen que contar la misma edad.
    final nivel = json['nivelMadurativo']?.toString().trim() ?? '';
    final estadio = json['estadio']?.toString().trim() ?? '';
    final esperado = _steamNiveles[nivel];
    if (esperado == null) {
      errors.add('${prefix}nivelMadurativo must be one of '
          '${_steamNiveles.keys.toList()} (got: "$nivel")');
    } else if (estadio != esperado.$1) {
      errors.add('${prefix}estadio "$estadio" does not match nivel $nivel '
          '(expected "${esperado.$1}")');
    }

    final minutos = json['tiempoEstimadoMin'];
    if (minutos is! int || minutos < 5 || minutos > 30) {
      errors.add('${prefix}tiempoEstimadoMin must be an integer between 5 and '
          '30 (got: $minutos)');
    }

    // El día del curso en que toca: lo que pone la sesión en «Hoxe na aula» y
    // en el calendario. Un día que no existe dejaría la sesión sin aparecer
    // nunca, y ningún otro gate lo diría.
    final calendario = _asMap(json['calendario']);
    if (calendario != null) {
      for (final (campo, min, max) in const [
        ('mes', 1, 10),
        ('semana', 1, 4),
        ('dia', 1, 5),
      ]) {
        final valor = calendario[campo];
        if (valor is! int || valor < min || valor > max) {
          errors.add('${prefix}calendario.$campo must be an integer between '
              '$min and $max (got: $valor)');
        }
      }
    } else if (json['calendario'] != null) {
      errors.add('${prefix}calendario must be a JSON object');
    }

    // Currículo: el mismo anclaje que el resto del contenido.
    final curriculo = _asMap(json['curriculo']);
    if (curriculo == null) {
      errors.add('${prefix}curriculo must be a JSON object');
    } else {
      checkCurricularAlignment(curriculo, errors: errors, prefix: prefix);
      final ciclo = curriculo['ciclo']?.toString().trim() ?? '';
      if (esperado != null) {
        final cicloEsperado = esperado.$2.isEmpty
            ? CurricularReference.ciclo03
            : CurricularReferenceSegundoCiclo.cicloSegundo;
        if (ciclo != cicloEsperado) {
          errors.add('${prefix}curriculo.ciclo "$ciclo" does not match nivel '
              '$nivel (expected "$cicloEsperado")');
        }
        final nivelCurricular = curriculo['nivel']?.toString().trim() ?? '';
        if (nivelCurricular != esperado.$2) {
          errors.add('${prefix}curriculo.nivel "$nivelCurricular" does not '
              'match nivel $nivel (expected "${esperado.$2}")');
        }
      }
      final competencias = curriculo['competenciasClave'];
      if (competencias is List) {
        for (final c in competencias) {
          if (!competenciasClaveLomloe.contains(c.toString().trim())) {
            errors.add('${prefix}curriculo.competenciasClave contains '
                'unrecognized key competence "$c"');
          }
        }
      }
    }

    // Seguridad: toda unidad trae su aviso, y la pantalla lo pinta arriba.
    final seguridad = _asMap(json['seguridad']);
    if (seguridad == null || !_esTextoBilingue(seguridad['aviso'])) {
      errors.add('${prefix}seguridad.aviso must be a non-empty gl/es text');
    }

    // Lo que se observa, no lo que se evalúa.
    final observar = json['queObservar'];
    if (observar is! List || observar.length < 2 || observar.length > 4) {
      errors.add('${prefix}queObservar must list between 2 and 4 observations');
    } else {
      for (var i = 0; i < observar.length; i++) {
        if (!_esTextoBilingue(observar[i])) {
          errors.add('${prefix}queObservar[$i] must be a non-empty gl/es text');
        }
      }
    }

    // Las dos versiones de la sesión.
    final prosaPorVariante = <String, String>{};
    for (final audiencia in const ['aula', 'hogar']) {
      final variante = _asMap(json[audiencia]);
      if (variante == null) {
        errors.add('$prefix$audiencia must be a JSON object');
        continue;
      }
      final p = '$prefix$audiencia.';
      if (!_esTextoBilingue(variante['agrupamiento'])) {
        errors.add('${p}agrupamiento must be a non-empty gl/es text');
      }

      final materiales = variante['materiales'];
      if (materiales is! List || materiales.isEmpty) {
        errors.add('${p}materiales must contain at least one material');
      } else {
        for (var m = 0; m < materiales.length; m++) {
          final mat = _asMap(materiales[m]);
          if (mat == null || !_esTextoBilingue(mat['item'])) {
            errors.add('${p}materiales[$m] must have a gl/es "item"');
            continue;
          }
          if (mat['seguridadMayor4cm'] != true) {
            errors.add('${p}materiales[$m] must be larger than 4 cm '
                '("seguridadMayor4cm": true) at every age');
          }
          final item = _asMap(mat['item'])!;
          for (final lang in const ['gl', 'es']) {
            final hit = steamMaterialProhibido.firstMatch('${item[lang]}');
            if (hit != null) {
              errors.add('${p}materiales[$m].$lang uses a forbidden material '
                  '"${hit.group(0)}": ${item[lang]}');
            }
          }
        }
      }

      // Papeles: nunca antes de los 3 años (el juego es en paralelo); siempre
      // en el aula a partir de los 4, que es cuando el juego cooperativo tiene
      // sentido.
      final roles = variante['roles'];
      final numRoles = roles is List ? roles.length : 0;
      if (roles != null && roles is! List) {
        errors.add('${p}roles must be a list');
      }
      if ((nivel == 'I1' || nivel == 'I2') && numRoles > 0) {
        errors.add('${p}roles must be empty before 3 years: at $nivel play is '
            'parallel, not cooperative');
      }
      if (audiencia == 'aula' &&
          (nivel == 'I4' || nivel == 'I5') &&
          numRoles < 2) {
        errors.add('${p}roles: $nivel classroom sessions need at least two '
            'complementary roles');
      }
      if (roles is List) {
        for (var r = 0; r < roles.length; r++) {
          final rol = _asMap(roles[r]);
          if (rol == null ||
              (rol['clave']?.toString().trim() ?? '').isEmpty ||
              !_esTextoBilingue(rol['nombre']) ||
              !_esTextoBilingue(rol['mision'])) {
            errors.add('${p}roles[$r] must have clave, nombre and mision');
          }
        }
      }

      final ciclo = _asMap(variante['ciclo']);
      if (ciclo == null) {
        errors.add('${p}ciclo must be a JSON object');
        continue;
      }
      const pasos = {
        'observa': ['planteamiento', 'preguntaIndagacion'],
        'experimenta': ['consignaAdulto', 'pistaN1', 'pistaN2'],
        'construye': ['retoTangible', 'sintesisCierre'],
      };
      // Una prosa por lengua: juntas, una orden dicha solo en gallego pasaba
      // por buena y la sesión en castellano no la pedía nunca.
      final prosa = {'gl': StringBuffer(), 'es': StringBuffer()};
      pasos.forEach((paso, campos) {
        final bloque = _asMap(ciclo[paso]);
        if (bloque == null) {
          errors.add('${p}ciclo is missing the "$paso" step');
          return;
        }
        for (final campo in campos) {
          if (!_esTextoBilingue(bloque[campo])) {
            errors.add('${p}ciclo.$paso.$campo must be a non-empty gl/es text');
          } else {
            final t = _asMap(bloque[campo])!;
            prosa.forEach((lang, b) => b.write(' ${t[lang]}'));
          }
        }
      });
      final observa = _asMap(ciclo['observa']);
      final pausa = observa?['pausaSilencioSegundos'];
      if (pausa is! int || pausa < 3 || pausa > 10) {
        errors.add('${p}ciclo.observa.pausaSilencioSegundos must be an integer '
            'between 3 and 10 (got: $pausa)');
      }
      prosa.forEach((lang, b) {
        prosaPorVariante['$audiencia session in $lang'] =
            b.toString().toLowerCase();
      });
    }

    // Las órdenes en inglés: cada una tiene su gesto y cada una la dice la
    // persona adulta en las dos versiones y en las dos lenguas. Si una orden
    // sale en la pastilla y no en el texto, o al revés, la sesión enseña una
    // cosa y pide otra.
    final ordenes = json['ordenesIngles'];
    if (ordenes is! List || ordenes.isEmpty) {
      errors.add('${prefix}ordenesIngles must contain at least one command');
    } else {
      for (var o = 0; o < ordenes.length; o++) {
        final orden = _asMap(ordenes[o]);
        final en = orden?['en']?.toString().trim() ?? '';
        if (orden == null || en.isEmpty) {
          errors.add('${prefix}ordenesIngles[$o] must have an "en" text');
          continue;
        }
        if (!RegExp(r"^[A-Za-z][A-Za-z ']*$").hasMatch(en)) {
          errors.add('${prefix}ordenesIngles[$o].en must be plain English '
              'words (got: "$en")');
        }
        if (!_esTextoBilingue(orden['accion'])) {
          errors.add('${prefix}ordenesIngles[$o].accion must be a non-empty '
              'gl/es text');
        }
        final ipa = orden['ipa']?.toString().trim() ?? '';
        if (ipa.isNotEmpty && !(ipa.startsWith('/') && ipa.endsWith('/'))) {
          errors.add('${prefix}ordenesIngles[$o].ipa must be written between '
              'slashes (got: "$ipa")');
        }
        // Entre comiñas inglesas “…”, non entre «…»: é a marca coa que a voz
        // le ese anaco coa voz inglesa e non coa galega ou a castelá.
        final cita = '“${en.toLowerCase()}”';
        prosaPorVariante.forEach((donde, prosa) {
          if (!prosa.contains(cita)) {
            errors.add('${prefix}ordenesIngles[$o] "$en" is never said in the '
                '$donde (expected $cita in its steps)');
          }
        });
      }
    }
  }
}
