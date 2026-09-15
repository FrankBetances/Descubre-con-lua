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
}
