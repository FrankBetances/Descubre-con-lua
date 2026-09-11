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

  factory ValidationResult.failure(List<String> errors, {List<String>? warnings}) {
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

  /// Prohibited placeholder patterns that indicate incomplete text.
  static final RegExp placeholderPattern = RegExp(
    r'\b(TODO|TBD|PLACEHOLDER|PENDIENTE|PENDENTE|LOREM\s+IPSUM)\b',
    caseSensitive: false,
  );

  /// Valid audio asset extensions for offline playback.
  static const Set<String> validAudioExtensions = {'.mp3', '.wav', '.ogg', '.m4a'};

  /// Defensive type-safe Map extraction helper to prevent runtime TypeError crashes.
  static Map<String, dynamic>? _asMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return Map<String, dynamic>.from(v);
    return null;
  }

  /// Validates a complete [Unidad] JSON document.
  ValidationResult validateUnidadJson(Map<String, dynamic> json, {String sourcePath = ''}) {
    final List<String> errors = [];
    final List<String> warnings = [];

    final prefix = sourcePath.isNotEmpty ? '[$sourcePath] ' : '';

    // 1. Root structure
    if (!json.containsKey('id') || json['id'] is! String || (json['id'] as String).trim().isEmpty) {
      errors.add('${prefix}Missing or empty root "id": must be a non-empty string');
    }

    final tramo = json['tramoEtario'] ?? json['tramo_etario'];
    if (tramo != '0-2' && tramo != '2-3' && tramo != '0-3') {
      errors.add('${prefix}Invalid "tramoEtario": must be "0-2", "2-3", or "0-3" (got: "$tramo")');
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
    checkReferentialIntegrityUnidad(json, errors: errors, warnings: warnings, prefix: prefix);

    return errors.isEmpty
        ? ValidationResult.success(warnings: warnings)
        : ValidationResult.failure(errors, warnings: warnings);
  }

  /// Validates a complete [Capsula] JSON document.
  ValidationResult validateCapsulaJson(Map<String, dynamic> json, {String sourcePath = ''}) {
    final List<String> errors = [];
    final List<String> warnings = [];

    final prefix = sourcePath.isNotEmpty ? '[$sourcePath] ' : '';

    // 1. Root structure
    if (!json.containsKey('id') || json['id'] is! String || (json['id'] as String).trim().isEmpty) {
      errors.add('${prefix}Missing or empty root "id": must be a non-empty string');
    }

    final bloqueId = json['bloqueId']?.toString().trim() ?? json['bloque_id']?.toString().trim();
    if (bloqueId == null || bloqueId.isEmpty) {
      errors.add('${prefix}Missing required "bloqueId"');
    } else {
      final validBlock = Bloque.byId(bloqueId);
      if (validBlock == null) {
        errors.add('${prefix}Invalid "bloqueId": "$bloqueId" is not among the 5 canonical blocks');
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
    checkReferentialIntegrityCapsula(json, errors: errors, warnings: warnings, prefix: prefix);

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
        } else if (placeholderPattern.hasMatch(glVal)) {
          errors.add('$prefix$path: "gl" contains forbidden placeholder: "${glVal.trim()}"');
        }

        if (esVal is! String || esVal.trim().isEmpty) {
          errors.add('$prefix$path: "es" is missing, not a string, or blank');
        } else if (placeholderPattern.hasMatch(esVal)) {
          errors.add('$prefix$path: "es" contains forbidden placeholder: "${esVal.trim()}"');
        }
      } else if (hasGl && !hasEs) {
        errors.add('$prefix$path: Asymmetric bilingual node: contains "gl" but missing "es"');
      } else if (!hasGl && hasEs) {
        errors.add('$prefix$path: Asymmetric bilingual node: contains "es" but missing "gl"');
      }

      // Recurse children
      node.forEach((key, value) {
        checkBilingualParity(value, path: '$path.$key', errors: errors, prefix: prefix);
      });
    } else if (node is List) {
      for (var i = 0; i < node.length; i++) {
        checkBilingualParity(node[i], path: '$path[$i]', errors: errors, prefix: prefix);
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
        checkClinicalTerms(value, path: '$path.$key', errors: errors, prefix: prefix);
      });
    } else if (node is List) {
      for (var i = 0; i < node.length; i++) {
        checkClinicalTerms(node[i], path: '$path[$i]', errors: errors, prefix: prefix);
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
    if (ciclo != CurricularReference.ciclo03) {
      errors.add(
        '${prefix}curriculo.ciclo must be "${CurricularReference.ciclo03}" (got: "$ciclo")',
      );
    }

    final areas = curriculo['areas'];
    if (areas is! List || areas.isEmpty) {
      errors.add('${prefix}curriculo.areas must be a non-empty list');
    } else {
      for (final area in areas) {
        final areaStr = area.toString().trim();
        if (!CurricularReference.validAreas.contains(areaStr)) {
          errors.add(
            '${prefix}curriculo.areas contains unrecognized area "$areaStr". Valid areas: ${CurricularReference.validAreas.toList()}',
          );
        }
      }
    }

    final criterios = curriculo['criteriosEvaluacion'] ?? curriculo['criterios_evaluacion'];
    if (criterios is! List || criterios.isEmpty) {
      errors.add('${prefix}curriculo.criteriosEvaluacion must be a non-empty list');
    } else {
      for (final crit in criterios) {
        final critStr = crit.toString().trim();
        if (!CurricularReference.validCriterios.contains(critStr)) {
          errors.add(
            '${prefix}curriculo.criteriosEvaluacion contains unrecognized criterion "$critStr". Valid criteria: ${CurricularReference.validCriterios.toList()}',
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
          errors.add('${prefix}cancionPulso.bpm must be an integer between 40 and 160 BPM (got: $bpmVal)');
        } else {
          final bpm = bpmVal.toInt();
          if (bpm < 40 || bpm > 160) {
            errors.add('${prefix}cancionPulso.bpm must be an integer between 40 and 160 BPM (got: $bpm)');
          }
        }
      }
      final audioAsset = cancion['audioAsset'] ?? cancion['audio_asset'];
      _validateAudioAsset(audioAsset, path: 'cancionPulso.audioAsset', errors: errors, prefix: prefix);
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
          _validateAudioAsset(a, path: 'vocabulario[$i].audioAsset', errors: errors, prefix: prefix);
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
          errors.add('${prefix}preguntas is missing graduated scaffolding level $reqLevel');
        }
      }
    }

    // 5. Exploracion & mandatory safety notice
    final exploracion = _asMap(json['exploracion'] ?? json['exploracionSensorial']);
    if (exploracion == null) {
      errors.add('${prefix}Missing required section: "exploracion"');
    } else {
      final aviso = _asMap(exploracion['avisoSeguridad'] ?? exploracion['aviso_seguridad']);
      if (aviso == null) {
        errors.add('${prefix}exploracion missing MANDATORY "avisoSeguridad" object');
      } else {
        final gl = aviso['gl']?.toString() ?? '';
        final es = aviso['es']?.toString() ?? '';
        if (gl.trim().isEmpty || es.trim().isEmpty) {
          errors.add('${prefix}exploracion.avisoSeguridad must be populated in both gl and es');
        }
      }
    }

    // 6. Matematicas tempranas
    final matematicas = _asMap(json['matematicas'] ?? json['matematicasTempras']);
    if (matematicas == null) {
      errors.add('${prefix}Missing required section: "matematicas"');
    }

    // 7. Puente a casa
    final puenteCasa = _asMap(json['puenteCasa'] ?? json['ponteCasa'] ?? json['puente_casa']);
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
    final sections = ['ideaClave', 'porQueImporta', 'queHacerEnCasa', 'ejemploCotidiano'];
    for (final sec in sections) {
      final secData = _asMap(json[sec] ?? contido[sec]);
      if (secData == null || !secData.containsKey('gl') || !secData.containsKey('es')) {
        errors.add('${prefix}Capsule missing canonical section: "$sec"');
      }
    }

    // Afirmaciones
    final afirmaciones = json['afirmaciones'];
    if (afirmaciones is! List || afirmaciones.isEmpty) {
      errors.add('${prefix}Capsule must contain at least one reflective "afirmaciones" item');
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
      if (gl.isEmpty) errors.add('$prefix$path.gl: Missing audio path');
      else _checkAudioPath(gl, path: '$path.gl', errors: errors, prefix: prefix);

      if (es.isEmpty) errors.add('$prefix$path.es: Missing audio path');
      else _checkAudioPath(es, path: '$path.es', errors: errors, prefix: prefix);
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
    if (!pathStr.startsWith('assets/audio/')) {
      errors.add(
        '$prefix$path: Audio asset path must begin with "assets/audio/" (got: "$pathStr")',
      );
    }
  }
}
