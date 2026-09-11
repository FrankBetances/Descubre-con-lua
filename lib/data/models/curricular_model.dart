import 'package:flutter/foundation.dart';

/// Represents official curricular alignment under Galician educational regulations
/// for early childhood education (0-3 years):
/// **Decreto 150/2022, do 8 de setembro** (DOG nº 172).
@immutable
class CurricularReference {
  /// Reference standard, strictly "Decreto 150/2022".
  final String normativa;

  /// Educational stage, strictly "educacion_infantil".
  final String etapa;

  /// Educational cycle, strictly "primeiro_ciclo_0_3".
  final String ciclo;

  /// Curricular areas covered (Áreas 1, 2, 3).
  final List<String> areas;

  /// Official evaluation criteria IDs (e.g., "CA1.1", "CA2.1", "CA3.1").
  final List<String> criteriosEvaluacion;

  const CurricularReference({
    required this.normativa,
    required this.etapa,
    required this.ciclo,
    required this.areas,
    required this.criteriosEvaluacion,
  });

  /// Canonical regulatory standard name for Galicia.
  static const String decretoGalicia = 'Decreto 150/2022';

  /// Canonical stage identifier.
  static const String etapaInfantil = 'educacion_infantil';

  /// Canonical cycle identifier (0-3 years).
  static const String ciclo03 = 'primeiro_ciclo_0_3';

  // Official Area Identifiers under Decreto 150/2022
  static const String area1CrecementoHarmonia = 'area_1_crecemento_harmonia';
  static const String area2DescubrimentoContorna = 'area_2_descubrimento_contorna';
  static const String area3ComunicacionRepresentacion = 'area_3_comunicacion_representacion';

  /// All valid curricular area codes for 0-3 years in Galicia.
  static const Set<String> validAreas = {
    area1CrecementoHarmonia,
    area2DescubrimentoContorna,
    area3ComunicacionRepresentacion,
  };

  // Official Criteria Identifiers for 0-3 years
  static const String criterioCuriosidadeSeguridade = 'CA1.1';
  static const String criterioExploracionMateriais = 'CA2.1';
  static const String criterioRazoamentoElementar = 'CA2.2';
  static const String criterioComunicacionAfectiva = 'CA3.1';
  static const String criterioLecturaCompartida = 'CA3.2';

  /// Recognized evaluation criteria for early childhood 0-3 years.
  static const Set<String> validCriterios = {
    criterioCuriosidadeSeguridade,
    criterioExploracionMateriais,
    criterioRazoamentoElementar,
    criterioComunicacionAfectiva,
    criterioLecturaCompartida,
  };

  /// Factory constructor to parse JSON data.
  factory CurricularReference.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('normativa')) {
      throw const FormatException('CurricularReference missing required key: normativa');
    }

    final rawAreas = json['areas'];
    final List<String> parsedAreas;
    if (rawAreas is List) {
      parsedAreas = rawAreas.map((e) => e.toString().trim()).toList();
    } else {
      parsedAreas = const [];
    }

    final rawCriterios = json['criteriosEvaluacion'] ?? json['criterios_evaluacion'];
    final List<String> parsedCriterios;
    if (rawCriterios is List) {
      parsedCriterios = rawCriterios.map((e) => e.toString().trim()).toList();
    } else {
      parsedCriterios = const [];
    }

    return CurricularReference(
      normativa: json['normativa']?.toString().trim() ?? '',
      etapa: json['etapa']?.toString().trim() ?? etapaInfantil,
      ciclo: json['ciclo']?.toString().trim() ?? ciclo03,
      areas: List.unmodifiable(parsedAreas),
      criteriosEvaluacion: List.unmodifiable(parsedCriterios),
    );
  }

  /// Serializes to JSON map.
  Map<String, dynamic> toJson() => {
    'normativa': normativa,
    'etapa': etapa,
    'ciclo': ciclo,
    'areas': areas,
    'criteriosEvaluacion': criteriosEvaluacion,
  };

  /// Validates that this reference conforms strictly to Decreto 150/2022.
  bool get isValidDecreto150 {
    if (normativa != decretoGalicia) return false;
    if (etapa != etapaInfantil) return false;
    if (ciclo != ciclo03) return false;
    if (areas.isEmpty) return false;
    for (final area in areas) {
      if (!validAreas.contains(area)) return false;
    }
    if (criteriosEvaluacion.isEmpty) return false;
    for (final criterio in criteriosEvaluacion) {
      if (!validCriterios.contains(criterio)) return false;
    }
    return true;
  }

  /// Checks if a specific area is referenced.
  bool hasArea(String areaCode) => areas.contains(areaCode);

  /// Checks if a specific evaluation criterion is referenced.
  bool hasCriterio(String criterioCode) => criteriosEvaluacion.contains(criterioCode);

  /// Creates a copy with optionally updated fields.
  CurricularReference copyWith({
    String? normativa,
    String? etapa,
    String? ciclo,
    List<String>? areas,
    List<String>? criteriosEvaluacion,
  }) {
    return CurricularReference(
      normativa: normativa ?? this.normativa,
      etapa: etapa ?? this.etapa,
      ciclo: ciclo ?? this.ciclo,
      areas: areas != null ? List.unmodifiable(areas) : this.areas,
      criteriosEvaluacion: criteriosEvaluacion != null ? List.unmodifiable(criteriosEvaluacion) : this.criteriosEvaluacion,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurricularReference &&
          runtimeType == other.runtimeType &&
          normativa == other.normativa &&
          etapa == other.etapa &&
          ciclo == other.ciclo &&
          listEquals(areas, other.areas) &&
          listEquals(criteriosEvaluacion, other.criteriosEvaluacion);

  @override
  int get hashCode => Object.hash(
        normativa,
        etapa,
        ciclo,
        Object.hashAll(areas),
        Object.hashAll(criteriosEvaluacion),
      );

  @override
  String toString() =>
      'CurricularReference(normativa: "$normativa", areas: $areas, criterios: $criteriosEvaluacion)';
}

/// Type alias for Galician nomenclature parity.
typedef CurriculoReferencia = CurricularReference;
