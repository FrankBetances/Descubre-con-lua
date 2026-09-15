# Handoff Report — Data Architecture & Backend Explorer (Segundo Ciclo 3-6)

**Agent**: `teamwork_preview_explorer_s3_2`  
**Working Directory**: `/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_explorer_s3_2`  
**Parent Conversation ID**: `e7633361-cefb-4427-91ff-c3fbb93625fc`  
**Recipient**: parent  
**Handoff Type**: Hard (Investigation complete)  

---

## 1. Observation

### 1.1 Existing Codebase & Architecture
1. **Data Models for 0-3 Years (`Unidad`, `Capsula`, `CurricularReference`)**:
   - `lib/data/models/unidad_model.dart`:
     - Lines 635–670 define `Unidad` with 6 hardcoded steps for 0-3 years: `cancionPulso` (lines 74–177), `cuento` (lines 234–277), `vocabulario` (lines 281–350), `preguntas` (lines 357–412), `exploracion` (lines 416–499), `matematicas` (lines 503–566), and `puenteCasa` (lines 570–631).
     - Field `tramoEtario` is strictly checked against `'0-2'`, `'2-3'`, or `'0-3'` in line 729.
   - `lib/data/models/curricular_model.dart`:
     - Line 38 defines `ciclo03 = 'primeiro_ciclo_0_3'`.
     - Lines 48–52 define `validAreas`: `area_1_crecemento_harmonia`, `area_2_descubrimento_contorna`, `area_3_comunicacion_representacion`.
     - Lines 62–68 define `validCriterios`: `CA1.1`, `CA2.1`, `CA2.2`, `CA3.1`, `CA3.2`.
     - Lines 113–126 (`isValidDecreto150`) require `ciclo == ciclo03` and criteria in `validCriterios`.
   - `lib/data/models/capsula_model.dart`:
     - Lines 156–251 define the 5 canonical Academy blocks (`desarrollo_comunicativo`, `rutinas_y_bano_de_lenguaje`, `turnos_y_atencion_conjunta`, `juego_movimiento_sin_pantallas`, `bilinguismo_y_cultura`) and lines 268–363 define 6 classroom capsule blocks (`aulaPulsoId`, `aulaContoId`, `aulaPreguntasId`, `aulaExploracionId`, `aulaMatematicasId`, `aulaPonteCasaId`).
     - Lines 401–439 define `Capsula` with the 4 canonical sections (`ideaClave`, `porQueImporta`, `queHacerEnCasa`, `ejemploCotidiano`) and reflective `afirmaciones`.

2. **Loaders and Repositories**:
   - `lib/data/loaders/content_asset_loader.dart`:
     - Lines 20–21 define prefixes: `unidadesAssetPrefix = 'assets/content/unidades/'` and `capsulasAssetPrefix = 'assets/content/capsulas/'`.
     - Only knows about `Unidad` and `Capsula`.
   - `lib/data/repositories/content_repository.dart`:
     - Lines 24–25 manage `_unidadesById` and `_capsulasById`.
     - Lines 225–246 (`_discover()`): Discovers `.json` files specifically under `unidadesAssetPrefix` and `capsulasAssetPrefix`.

3. **Content Validation (`ContentValidator`)**:
   - `lib/data/validators/content_validator.dart`:
     - Lines 47–57 define `forbiddenClinicalPattern` (clinical term blacklist).
     - Lines 96–100 in `validateUnidadJson`: Rejects any `tramoEtario` other than `'0-2'`, `'2-3'`, or `'0-3'`.
     - Lines 290–296 in `checkCurricularAlignment`:
       ```dart
       final ciclo = curriculo['ciclo']?.toString().trim();
       if (ciclo != CurricularReference.ciclo03) {
         errors.add('${prefix}curriculo.ciclo must be "${CurricularReference.ciclo03}" (got: "$ciclo")');
       }
       ```
     - Lines 335–440: Enforces the 6 steps of 0-3 years (`cancionPulso`, `cuento`, `vocabulario`, `preguntas` levels 1–3, `exploracion`, `matematicas`, `puenteCasa`).

4. **CI Gates & Automation Tooling (`tools/`)**:
   - `tools/export_voice_corpus.py` (lines 36–77) and `tools/voice_corpus.py` (lines 147–224):
     - `voice_corpus.py` explicitly iterates over `(content_dir / "unidades").glob("*.json")` and expects 0-3 `Unidad` structure (`cancionPulso`, `vocabulario`, `cuento`, etc.).
   - `tools/check_pulse_markers.py` (lines 20, 32):
     - Iterates over `ROOT / "assets" / "content" / "unidades" / "*.json"`.
   - `tools/check_pulse_bpm.py` (lines 26, 34):
     - Iterates over `ROOT / "assets" / "content" / "unidades" / "*.json"`.
   - `tools/check_voice_coverage.py`:
     - Fails with exit code 1 if any locution extracted by `voice_corpus.py` does not have a physical `.m4a` file in `assets/voice/`.

---

## 2. Logic Chain

1. **Isolation of Segundo Ciclo Content**:
   - *Premise*: `tools/voice_corpus.py`, `tools/check_pulse_markers.py`, and `tools/check_pulse_bpm.py` glob `assets/content/unidades/*.json`.
   - *Inference*: If Segundo Ciclo assembly JSON files are placed inside `assets/content/unidades/`, existing CI scripts will attempt to parse them as 0-3 `Unidad` models, check for 72 BPM pulse songs, and fail the CI gate `tools/check_voice_coverage.py` because new locutions will not have pre-synthesized `.m4a` files.
   - *Deduction*: Segundo Ciclo JSON assets MUST reside in an isolated directory: `assets/content/asambleas_segundo_ciclo/` (e.g. `asamblea.setembro.4_infantil.json`, `asamblea.setembro.5_infantil.json`, `asamblea.setembro.6_infantil.json`).

2. **Decoupled Model Architecture (`AsambleaSegundoCiclo` vs `Unidad`)**:
   - *Premise*: Primer Ciclo (0-3) is based on a 6-step assembly with sensory exploration, early math, and story reading (`Unidad`), whereas Segundo Ciclo (3-6) is based on an 8–10 minute morning circle structured strictly into 4 canonical TPR phases in L3 (Opening, Rhythmic Focus, Core TPR Challenge, Calm).
   - *Inference*: Forcing the 4 TPR phases into the 6-step `Unidad` model would either corrupt `Unidad` invariants (breaking existing widget tests and data loaders) or force nullability into previously non-nullable fields (`cancionPulso`, `cuento`, `matematicas`).
   - *Deduction*: Segundo Ciclo requires its own strongly typed immutable root model: `AsambleaSegundoCiclo` (with nested `FaseAsamblea`, `ComandoTPR`, `MaterialNatural`, `CurricularReferenceSegundoCiclo`, and `MicroRutinaHogarSegundoCiclo`).

3. **Curricular Reference Evolution (Decreto 150/2022)**:
   - *Premise*: Segundo Ciclo falls under the same regulation (**Decreto 150/2022, do 8 de setembro**) and the same 3 areas (`area_1_crecemento_harmonia`, `area_2_descubrimento_contorna`, `area_3_comunicacion_representacion`), but its stage cycle is `segundo_ciclo_3_6` (with levels `4_infantil`, `5_infantil`, `6_infantil`), and its evaluation criteria address L3 motor response (`CA3.1`), non-verbal dramatic expression (`CA3.2`), and peer-to-peer interaction (`CA3.4`).
   - *Inference*: Existing `CurricularReference` hardcodes `ciclo == 'primeiro_ciclo_0_3'` in line 116.
   - *Deduction*: We must provide `CurricularReferenceSegundoCiclo` (or evolve `CurricularReference` to support both cycles while maintaining complete backwards compatibility for existing tests). In `ContentValidator`, we introduce `checkCurricularAlignmentSegundoCiclo(...)` and `validateAsambleaSegundoCicloJson(...)`.

4. **Integration with Academy and Home Routines**:
   - *Premise*: R1 & R3 require integrating the September home micro-routine (getting dressed / hanging up coats) with the **Principio Time and Place** (3-5 minute niching) and **indirect corrective modeling (recast)**.
   - *Inference*: Families in Segundo Ciclo need actionable dialogic scripts with clear guidance on what to avoid (no direct front-facing evaluation or negative reinforcement).
   - *Deduction*: `MicroRutinaHogarSegundoCiclo` embeds `PautaRecast` (with `expresionMenor`, `modeladoIndirecto`, and `consejoEvitar`) directly in the unit data contract and links to an Academy capsule ID.

---

## 3. Caveats

- **Audio Synthesis for L3 Commands**: The LJSpeech model offline audio generation for L3 commands (`LJSpeech · piper`) will be handled in CI or asset generation pipelines. The model contracts specify `audioAsset` as optional (`String?`), allowing the app to render glanceable teacher cards and text prompts without blocking if an audio file is not bundled.
- **Visual Illustrations in Second Cycle**: The teacher backstage UI is strictly a back-of-the-house tool (glanceable UI, dark mode, high contrast >= 24sp). Unlike 0-3 `Unidad` (which has story illustration pages), Segundo Ciclo assembly phases are prompt-based and physical action-based; no child-facing screens or game animations are declared.

---

## 4. Conclusion & Technical Specifications

### 4.1 Data Models Contract (`lib/data/models/asamblea_segundo_ciclo_model.dart`)

```dart
import 'package:flutter/foundation.dart';
import '../../core/localization/localized_string.dart';
import 'curricular_model.dart';
import 'unidad_model.dart' show Revision;

/// Differentiated educational levels in Segundo Ciclo (3-6 years).
enum NivelEducativoSegundoCiclo {
  infantil4, // 3-4 years
  infantil5, // 4-5 years
  infantil6; // 5-6 years

  String get clave => switch (this) {
    NivelEducativoSegundoCiclo.infantil4 => '4_infantil',
    NivelEducativoSegundoCiclo.infantil5 => '5_infantil',
    NivelEducativoSegundoCiclo.infantil6 => '6_infantil',
  };

  String get tramoEtario => switch (this) {
    NivelEducativoSegundoCiclo.infantil4 => '3-4',
    NivelEducativoSegundoCiclo.infantil5 => '4-5',
    NivelEducativoSegundoCiclo.infantil6 => '5-6',
  };

  LocalizedString get etiqueta => switch (this) {
    NivelEducativoSegundoCiclo.infantil4 => const LocalizedString(
      gl: '4.º de Infantil (3-4 anos)',
      es: '4.º de Infantil (3-4 años)',
    ),
    NivelEducativoSegundoCiclo.infantil5 => const LocalizedString(
      gl: '5.º de Infantil (4-5 anos)',
      es: '5.º de Infantil (4-5 años)',
    ),
    NivelEducativoSegundoCiclo.infantil6 => const LocalizedString(
      gl: '6.º de Infantil (5-6 anos)',
      es: '6.º de Infantil (5-6 años)',
    ),
  };

  static NivelEducativoSegundoCiclo desdeClave(String? valor) =>
      NivelEducativoSegundoCiclo.values.firstWhere(
        (n) => n.clave == valor?.trim(),
        orElse: () => NivelEducativoSegundoCiclo.infantil4,
      );
}

typedef TPRLevel = NivelEducativoSegundoCiclo;

/// Differentiated TPR methodological approaches per level.
enum MetodologiaTPR {
  /// 4.º Infantil (3-4 years): Two-phase commands with "and", scaffolding with fading,
  /// strict respect for the silent period.
  accionExpandida,

  /// 5.º Infantil (4-5 years): Physical cause-effect micro-narratives,
  /// selective inhibition stop-signal / freeze, and orofacial praxias with fingerplays.
  dramatizadoNarrativo,

  /// 6.º Infantil (5-6 years): Peer-to-peer transactional dynamics,
  /// textless iconic cue cards, spatial categorisation, and kinesthetic problem solving.
  transaccionalPragmatico;

  String get clave => switch (this) {
    MetodologiaTPR.accionExpandida => 'accion_expandida',
    MetodologiaTPR.dramatizadoNarrativo => 'dramatizado_narrativo',
    MetodologiaTPR.transaccionalPragmatico => 'transaccional_pragmatico',
  };

  static MetodologiaTPR desdeClave(String? valor) =>
      MetodologiaTPR.values.firstWhere(
        (m) => m.clave == valor?.trim(),
        orElse: () => MetodologiaTPR.accionExpandida,
      );
}

/// The 4 canonical phases of a Segundo Ciclo assembly session.
enum TipoFaseAsamblea {
  aperturaSaudo,
  movementRhythmFocus,
  coreTprChallenge,
  calmaTransicion;

  String get clave => switch (this) {
    TipoFaseAsamblea.aperturaSaudo => 'apertura_saudo',
    TipoFaseAsamblea.movementRhythmFocus => 'movement_rhythm_focus',
    TipoFaseAsamblea.coreTprChallenge => 'core_tpr_challenge',
    TipoFaseAsamblea.calmaTransicion => 'calma_transicion',
  };

  int get duracionCanonicoSegundos => switch (this) {
    TipoFaseAsamblea.aperturaSaudo => 90, // 1:30 min
    TipoFaseAsamblea.movementRhythmFocus => 120, // 2:00 min
    TipoFaseAsamblea.coreTprChallenge => 270, // 4:30 min
    TipoFaseAsamblea.calmaTransicion => 120, // 2:00 min
  };

  static TipoFaseAsamblea desdeClave(String? valor) =>
      TipoFaseAsamblea.values.firstWhere(
        (t) => t.clave == valor?.trim(),
        orElse: () => TipoFaseAsamblea.aperturaSaudo,
      );
}

/// L3 TPR Command with suggested physical action and educator scaffolding notes.
@immutable
class ComandoTPR {
  final String id;
  final String textoIngles;
  final LocalizedString accionFisica;
  final LocalizedString modeladoDocente;
  final String? audioAsset;

  const ComandoTPR({
    required this.id,
    required this.textoIngles,
    required this.accionFisica,
    required this.modeladoDocente,
    this.audioAsset,
  });

  factory ComandoTPR.fromJson(Map<String, dynamic> json) {
    return ComandoTPR(
      id: json['id']?.toString().trim() ?? '',
      textoIngles: json['textoIngles']?.toString().trim() ??
          json['texto_ingles']?.toString().trim() ??
          '',
      accionFisica: LocalizedString.fromJson(
        (json['accionFisica'] ?? json['accion_fisica'])
                as Map<String, dynamic>? ??
            {},
      ),
      modeladoDocente: LocalizedString.fromJson(
        (json['modeladoDocente'] ?? json['modelado_docente'])
                as Map<String, dynamic>? ??
            {},
      ),
      audioAsset: json['audioAsset']?.toString().trim() ??
          json['audio_asset']?.toString().trim(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'textoIngles': textoIngles,
    'accionFisica': accionFisica.toJson(),
    'modeladoDocente': modeladoDocente.toJson(),
    if (audioAsset != null) 'audioAsset': audioAsset,
  };
}

/// Unstructured natural material from the Galician Atlantic environment.
@immutable
class MaterialNatural {
  final String id;
  final LocalizedString nombre;
  final LocalizedString procedencia;
  final LocalizedString pautaManipulacion;
  final LocalizedString? avisoSeguridad;

  const MaterialNatural({
    required this.id,
    required this.nombre,
    required this.procedencia,
    required this.pautaManipulacion,
    this.avisoSeguridad,
  });

  factory MaterialNatural.fromJson(Map<String, dynamic> json) {
    return MaterialNatural(
      id: json['id']?.toString().trim() ?? '',
      nombre: LocalizedString.fromJson(
          json['nombre'] as Map<String, dynamic>? ?? {}),
      procedencia: LocalizedString.fromJson(
          json['procedencia'] as Map<String, dynamic>? ?? {}),
      pautaManipulacion: LocalizedString.fromJson(
        (json['pautaManipulacion'] ?? json['pauta_manipulacion'])
                as Map<String, dynamic>? ??
            {},
      ),
      avisoSeguridad: json['avisoSeguridad'] != null || json['aviso_seguridad'] != null
          ? LocalizedString.fromJson(
              (json['avisoSeguridad'] ?? json['aviso_seguridad'])
                      as Map<String, dynamic>? ??
                  {},
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre.toJson(),
    'procedencia': procedencia.toJson(),
    'pautaManipulacion': pautaManipulacion.toJson(),
    if (avisoSeguridad != null) 'avisoSeguridad': avisoSeguridad!.toJson(),
  };
}

/// Phase representation in the 4-phase assembly.
@immutable
class FaseAsamblea {
  final int orden; // 1..4
  final TipoFaseAsamblea tipo;
  final LocalizedString titulo;
  final int duracionSegundos; // e.g. 90, 120, 270, 120
  final LocalizedString consignaDocente;
  final List<ComandoTPR> comandosL3;
  final String? cueAcustica;
  final List<MaterialNatural> repertorioMateriales;

  const FaseAsamblea({
    required this.orden,
    required this.tipo,
    required this.titulo,
    required this.duracionSegundos,
    required this.consignaDocente,
    this.comandosL3 = const [],
    this.cueAcustica,
    this.repertorioMateriales = const [],
  });

  factory FaseAsamblea.fromJson(Map<String, dynamic> json) {
    final rawComandos = json['comandosL3'] ?? json['comandos_l3'];
    final List<ComandoTPR> cmds = [];
    if (rawComandos is List) {
      for (final c in rawComandos) {
        if (c is Map<String, dynamic>) cmds.add(ComandoTPR.fromJson(c));
      }
    }

    final rawMats = json['repertorioMateriales'] ?? json['repertorio_materiales'];
    final List<MaterialNatural> mats = [];
    if (rawMats is List) {
      for (final m in rawMats) {
        if (m is Map<String, dynamic>) mats.add(MaterialNatural.fromJson(m));
      }
    }

    return FaseAsamblea(
      orden: (json['orden'] as num?)?.toInt() ?? 1,
      tipo: TipoFaseAsamblea.desdeClave(json['tipo']?.toString()),
      titulo: LocalizedString.fromJson(
          json['titulo'] as Map<String, dynamic>? ?? {}),
      duracionSegundos: (json['duracionSegundos'] ??
                  json['duracion_segundos'] as num?)
              ?.toInt() ??
          90,
      consignaDocente: LocalizedString.fromJson(
        (json['consignaDocente'] ?? json['consigna_docente'])
                as Map<String, dynamic>? ??
            {},
      ),
      comandosL3: List.unmodifiable(cmds),
      cueAcustica: json['cueAcustica']?.toString() ?? json['cue_acustica']?.toString(),
      repertorioMateriales: List.unmodifiable(mats),
    );
  }

  Map<String, dynamic> toJson() => {
    'orden': orden,
    'tipo': tipo.clave,
    'titulo': titulo.toJson(),
    'duracionSegundos': duracionSegundos,
    'consignaDocente': consignaDocente.toJson(),
    'comandosL3': comandosL3.map((c) => c.toJson()).toList(),
    if (cueAcustica != null) 'cueAcustica': cueAcustica,
    'repertorioMateriales':
        repertorioMateriales.map((m) => m.toJson()).toList(),
  };
}

/// Indirect corrective modeling guideline (recast) without front-facing evaluation.
@immutable
class PautaRecast {
  final LocalizedString expresionMenor;
  final LocalizedString modeladoIndirecto;
  final LocalizedString consejoEvitar;

  const PautaRecast({
    required this.expresionMenor,
    required this.modeladoIndirecto,
    required this.consejoEvitar,
  });

  factory PautaRecast.fromJson(Map<String, dynamic> json) {
    return PautaRecast(
      expresionMenor: LocalizedString.fromJson(
        (json['expresionMenor'] ?? json['expresion_menor'])
                as Map<String, dynamic>? ??
            {},
      ),
      modeladoIndirecto: LocalizedString.fromJson(
        (json['modeladoIndirecto'] ?? json['modelado_indirecto'])
                as Map<String, dynamic>? ??
            {},
      ),
      consejoEvitar: LocalizedString.fromJson(
        (json['consejoEvitar'] ?? json['consejo_evitar'])
                as Map<String, dynamic>? ??
            {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'expresionMenor': expresionMenor.toJson(),
    'modeladoIndirecto': modeladoIndirecto.toJson(),
    'consejoEvitar': consejoEvitar.toJson(),
  };
}

/// Home micro-routine (Time and Place 3-5 min) with Academy recast guidance.
@immutable
class MicroRutinaHogarSegundoCiclo {
  final String id;
  final LocalizedString titulo;
  final int nichoTiempoMinutos; // 3..5 min
  final LocalizedString momentoDelDia;
  final LocalizedString objetivoAutonomia;
  final List<PautaRecast> pautasRecast;
  final LocalizedString escenaCotidiana;
  final String? enlaceCapsulaAcademyId;

  const MicroRutinaHogarSegundoCiclo({
    required this.id,
    required this.titulo,
    required this.nichoTiempoMinutos,
    required this.momentoDelDia,
    required this.objetivoAutonomia,
    required this.pautasRecast,
    required this.escenaCotidiana,
    this.enlaceCapsulaAcademyId,
  });

  factory MicroRutinaHogarSegundoCiclo.fromJson(Map<String, dynamic> json) {
    final rawPautas = json['pautasRecast'] ?? json['pautas_recast'];
    final List<PautaRecast> pautas = [];
    if (rawPautas is List) {
      for (final p in rawPautas) {
        if (p is Map<String, dynamic>) pautas.add(PautaRecast.fromJson(p));
      }
    }

    return MicroRutinaHogarSegundoCiclo(
      id: json['id']?.toString().trim() ?? '',
      titulo: LocalizedString.fromJson(
          json['titulo'] as Map<String, dynamic>? ?? {}),
      nichoTiempoMinutos: (json['nichoTiempoMinutos'] ??
                  json['nicho_tiempo_minutos'] as num?)
              ?.toInt() ??
          3,
      momentoDelDia: LocalizedString.fromJson(
        (json['momentoDelDia'] ?? json['momento_del_dia'])
                as Map<String, dynamic>? ??
            {},
      ),
      objetivoAutonomia: LocalizedString.fromJson(
        (json['objetivoAutonomia'] ?? json['objetivo_autonomia'])
                as Map<String, dynamic>? ??
            {},
      ),
      pautasRecast: List.unmodifiable(pautas),
      escenaCotidiana: LocalizedString.fromJson(
        (json['escenaCotidiana'] ?? json['escena_cotidiana'])
                as Map<String, dynamic>? ??
            {},
      ),
      enlaceCapsulaAcademyId: json['enlaceCapsulaAcademyId']?.toString() ??
          json['enlace_capsula_academy_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo.toJson(),
    'nichoTiempoMinutos': nichoTiempoMinutos,
    'momentoDelDia': momentoDelDia.toJson(),
    'objetivoAutonomia': objetivoAutonomia.toJson(),
    'pautasRecast': pautasRecast.map((p) => p.toJson()).toList(),
    'escenaCotidiana': escenaCotidiana.toJson(),
    if (enlaceCapsulaAcademyId != null)
      'enlaceCapsulaAcademyId': enlaceCapsulaAcademyId,
  };
}

/// Curricular reference under Decreto 150/2022 for Segundo Ciclo de Educación Infantil.
@immutable
class CurricularReferenceSegundoCiclo {
  final String normativa; // "Decreto 150/2022"
  final String etapa; // "educacion_infantil"
  final String ciclo; // "segundo_ciclo_3_6"
  final String nivel; // "4_infantil" | "5_infantil" | "6_infantil"
  final List<String> areas;
  final List<String> competenciasClave;
  final List<String> criteriosEvaluacion;

  const CurricularReferenceSegundoCiclo({
    this.normativa = 'Decreto 150/2022',
    this.etapa = 'educacion_infantil',
    this.ciclo = 'segundo_ciclo_3_6',
    required this.nivel,
    required this.areas,
    this.competenciasClave = const ['CCL', 'CPSAA', 'CCEC'],
    required this.criteriosEvaluacion,
  });

  static const String cicloSegundo = 'segundo_ciclo_3_6';

  static const Set<String> validAreas = {
    CurricularReference.area1CrecementoHarmonia,
    CurricularReference.area2DescubrimentoContorna,
    CurricularReference.area3ComunicacionRepresentacion,
  };

  // Official evaluation criteria for Segundo Ciclo
  static const String criterioControlCorpoCoord = 'CA1.1';
  static const String criterioRegulacionEmocional = 'CA1.2';
  static const String criterioAutonomiaRutinas = 'CA1.3';
  static const String criterioCuriosidadeMateriaisNaturais = 'CA2.1';
  static const String criterioOrientacionEspacial = 'CA2.2';
  static const String criterioCooperacionRegras = 'CA2.3';
  static const String criterioComprensionL3Motora = 'CA3.1';
  static const String criterioExpresionCorporalDramatica = 'CA3.2';
  static const String criterioRitmoPraxiasRimas = 'CA3.3';
  static const String criterioInteraccionPeerToPeer = 'CA3.4';

  static const Set<String> validCriteriosSegundoCiclo = {
    criterioControlCorpoCoord,
    criterioRegulacionEmocional,
    criterioAutonomiaRutinas,
    criterioCuriosidadeMateriaisNaturais,
    criterioOrientacionEspacial,
    criterioCooperacionRegras,
    criterioComprensionL3Motora,
    criterioExpresionCorporalDramatica,
    criterioRitmoPraxiasRimas,
    criterioInteraccionPeerToPeer,
  };

  factory CurricularReferenceSegundoCiclo.fromJson(Map<String, dynamic> json) {
    final rawAreas = json['areas'];
    final List<String> parsedAreas = rawAreas is List
        ? rawAreas.map((e) => e.toString().trim()).toList()
        : const [];

    final rawComps = json['competenciasClave'] ?? json['competencias_clave'];
    final List<String> parsedComps = rawComps is List
        ? rawComps.map((e) => e.toString().trim()).toList()
        : const ['CCL', 'CPSAA', 'CCEC'];

    final rawCriterios =
        json['criteriosEvaluacion'] ?? json['criterios_evaluacion'];
    final List<String> parsedCriterios = rawCriterios is List
        ? rawCriterios.map((e) => e.toString().trim()).toList()
        : const [];

    return CurricularReferenceSegundoCiclo(
      normativa: json['normativa']?.toString().trim() ?? 'Decreto 150/2022',
      etapa: json['etapa']?.toString().trim() ?? 'educacion_infantil',
      ciclo: json['ciclo']?.toString().trim() ?? cicloSegundo,
      nivel: json['nivel']?.toString().trim() ?? '4_infantil',
      areas: List.unmodifiable(parsedAreas),
      competenciasClave: List.unmodifiable(parsedComps),
      criteriosEvaluacion: List.unmodifiable(parsedCriterios),
    );
  }

  Map<String, dynamic> toJson() => {
    'normativa': normativa,
    'etapa': etapa,
    'ciclo': ciclo,
    'nivel': nivel,
    'areas': areas,
    'competenciasClave': competenciasClave,
    'criteriosEvaluacion': criteriosEvaluacion,
  };
}

/// Root pedagogical assembly unit for Segundo Ciclo (3-6 years).
@immutable
class AsambleaSegundoCiclo {
  final String id;
  final NivelEducativoSegundoCiclo nivel;
  final int mes; // 1..10 (9 for September)
  final LocalizedString titulo;
  final LocalizedString centroInteres;
  final MetodologiaTPR metodologiaTpr;
  final int duracionTotalMinutos;
  final List<FaseAsamblea> fases;
  final CurricularReferenceSegundoCiclo curriculo;
  final List<MaterialNatural> materialesEntorno;
  final MicroRutinaHogarSegundoCiclo microRutinaHogar;
  final Revision revision;

  const AsambleaSegundoCiclo({
    required this.id,
    required this.nivel,
    required this.mes,
    required this.titulo,
    required this.centroInteres,
    required this.metodologiaTpr,
    required this.duracionTotalMinutos,
    required this.fases,
    required this.curriculo,
    required this.materialesEntorno,
    required this.microRutinaHogar,
    required this.revision,
  });

  factory AsambleaSegundoCiclo.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('id')) {
      throw const FormatException('AsambleaSegundoCiclo missing required key: id');
    }

    final rawFases = json['fases'];
    final List<FaseAsamblea> parsedFases = [];
    if (rawFases is List) {
      for (final f in rawFases) {
        if (f is Map<String, dynamic>) parsedFases.add(FaseAsamblea.fromJson(f));
      }
    }

    final rawMats = json['materialesEntorno'] ?? json['materiales_entorno'];
    final List<MaterialNatural> parsedMats = [];
    if (rawMats is List) {
      for (final m in rawMats) {
        if (m is Map<String, dynamic>) parsedMats.add(MaterialNatural.fromJson(m));
      }
    }

    final curriculoData = (json['curriculo'] ?? json['curricular'])
            as Map<String, dynamic>? ??
        {};
    final microData = (json['microRutinaHogar'] ?? json['micro_rutina_hogar'])
            as Map<String, dynamic>? ??
        {};
    final revisionData = json['revision'] as Map<String, dynamic>? ?? {};

    return AsambleaSegundoCiclo(
      id: json['id']?.toString().trim() ?? '',
      nivel: NivelEducativoSegundoCiclo.desdeClave(json['nivel']?.toString()),
      mes: (json['mes'] as num?)?.toInt() ?? 9,
      titulo: LocalizedString.fromJson(
          json['titulo'] as Map<String, dynamic>? ?? {}),
      centroInteres: LocalizedString.fromJson(
        (json['centroInteres'] ?? json['centro_interes'])
                as Map<String, dynamic>? ??
            {},
      ),
      metodologiaTpr: MetodologiaTPR.desdeClave(
        (json['metodologiaTpr'] ?? json['metodologia_tpr'])?.toString(),
      ),
      duracionTotalMinutos: (json['duracionTotalMinutos'] ??
                  json['duracion_total_minutos'] as num?)
              ?.toInt() ??
          10,
      fases: List.unmodifiable(parsedFases),
      curriculo: CurricularReferenceSegundoCiclo.fromJson(curriculoData),
      materialesEntorno: List.unmodifiable(parsedMats),
      microRutinaHogar: MicroRutinaHogarSegundoCiclo.fromJson(microData),
      revision: Revision.fromJson(revisionData),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nivel': nivel.clave,
    'mes': mes,
    'titulo': titulo.toJson(),
    'centroInteres': centroInteres.toJson(),
    'metodologiaTpr': metodologiaTpr.clave,
    'duracionTotalMinutos': duracionTotalMinutos,
    'fases': fases.map((f) => f.toJson()).toList(),
    'curriculo': curriculo.toJson(),
    'materialesEntorno': materialesEntorno.map((m) => m.toJson()).toList(),
    'microRutinaHogar': microRutinaHogar.toJson(),
    'revision': revision.toJson(),
  };
}

/// Typealias for nomenclature parity.
typedef SegundoCicloUnidad = AsambleaSegundoCiclo;
```

---

### 4.2 ContentAssetLoader & ContentRepository Extensions

In `lib/data/loaders/content_asset_loader.dart`:
```dart
  static const String asambleasSegundoCicloAssetPrefix =
      'assets/content/asambleas_segundo_ciclo/';

  Future<AsambleaSegundoCiclo> loadAsambleaSegundoCicloFromAsset(
      String assetPath) async {
    final jsonString = await _stringLoader(assetPath);
    return parseAsambleaSegundoCiclo(jsonString);
  }

  AsambleaSegundoCiclo parseAsambleaSegundoCiclo(String rawJson) {
    final dynamic decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
          'Expected JSON object at root for AsambleaSegundoCiclo');
    }
    return AsambleaSegundoCiclo.fromJson(decoded);
  }

  Future<List<AsambleaSegundoCiclo>> loadAllAsambleasSegundoCiclo(
      List<String> assetPaths) async {
    final List<AsambleaSegundoCiclo> list = [];
    for (final path in assetPaths) {
      final asamblea = await loadAsambleaSegundoCicloFromAsset(path);
      list.add(asamblea);
    }
    return List.unmodifiable(list);
  }
```

In `lib/data/repositories/content_repository.dart`:
```dart
  final Map<String, AsambleaSegundoCiclo> _asambleasSegundoCicloById = {};

  int get asambleaSegundoCicloCount => _asambleasSegundoCicloById.length;

  List<AsambleaSegundoCiclo> getAllAsambleasSegundoCiclo() {
    final list = _asambleasSegundoCicloById.values.toList();
    list.sort((a, b) => a.mes.compareTo(b.mes));
    return List.unmodifiable(list);
  }

  List<AsambleaSegundoCiclo> getAsambleasByNivel(NivelEducativoSegundoCiclo nivel) {
    final list = _asambleasSegundoCicloById.values
        .where((a) => a.nivel == nivel)
        .toList();
    list.sort((a, b) => a.mes.compareTo(b.mes));
    return List.unmodifiable(list);
  }

  AsambleaSegundoCiclo? getAsambleaSegundoCicloById(String id) {
    return _asambleasSegundoCicloById[id.trim()];
  }

  AsambleaSegundoCiclo? getAsambleaByMesYNivel(
      int mes, NivelEducativoSegundoCiclo nivel) {
    for (final a in _asambleasSegundoCicloById.values) {
      if (a.mes == mes && a.nivel == nivel) return a;
    }
    return null;
  }
```

---

### 4.3 ContentValidator Extensions (`lib/data/validators/content_validator.dart`)

Add `validateAsambleaSegundoCicloJson`:
```dart
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
      errors.add('${prefix}Missing or empty root "id"');
    }

    final nivel = json['nivel']?.toString().trim();
    if (nivel != '4_infantil' && nivel != '5_infantil' && nivel != '6_infantil') {
      errors.add('${prefix}Invalid "nivel": must be "4_infantil", "5_infantil", or "6_infantil" (got: "$nivel")');
    }

    final met = json['metodologiaTpr'] ?? json['metodologia_tpr'];
    if (nivel == '4_infantil' && met != 'accion_expandida') {
      errors.add('${prefix}Level 4_infantil must use metodologia "accion_expandida" (got: "$met")');
    } else if (nivel == '5_infantil' && met != 'dramatizado_narrativo') {
      errors.add('${prefix}Level 5_infantil must use metodologia "dramatizado_narrativo" (got: "$met")');
    } else if (nivel == '6_infantil' && met != 'transaccional_pragmatico') {
      errors.add('${prefix}Level 6_infantil must use metodologia "transaccional_pragmatico" (got: "$met")');
    }

    // 2. Bilingual parity check across entire tree (gl/es)
    checkBilingualParity(json, path: 'root', errors: errors, prefix: prefix);

    // 3. Clinical term blacklist check across entire tree
    checkClinicalTerms(json, path: 'root', errors: errors, prefix: prefix);

    // 4. Curricular alignment (Decreto 150/2022 Segundo Ciclo)
    final curriculo = _asMap(json['curriculo'] ?? json['curricular']);
    if (curriculo == null) {
      errors.add('${prefix}Missing required "curriculo" section');
    } else {
      checkCurricularAlignmentSegundoCiclo(curriculo, errors: errors, prefix: prefix);
    }

    // 5. 4 Canonical assembly phases
    final fases = json['fases'];
    if (fases is! List || fases.length != 4) {
      errors.add('${prefix}AsambleaSegundoCiclo must contain exactly 4 canonical phases (got: ${fases is List ? fases.length : 0})');
    } else {
      final expectedTypes = [
        'apertura_saudo',
        'movement_rhythm_focus',
        'core_tpr_challenge',
        'calma_transicion'
      ];
      int duracionTotal = 0;
      for (int i = 0; i < 4; i++) {
        final fase = _asMap(fases[i]);
        if (fase == null) {
          errors.add('${prefix}fases[$i] is not an object');
          continue;
        }
        final orden = (fase['orden'] as num?)?.toInt();
        if (orden != i + 1) {
          errors.add('${prefix}fases[$i].orden must be ${i + 1} (got: $orden)');
        }
        final tipo = fase['tipo']?.toString().trim();
        if (tipo != expectedTypes[i]) {
          errors.add('${prefix}fases[$i].tipo must be "${expectedTypes[i]}" (got: "$tipo")');
        }
        final dur = (fase['duracionSegundos'] ?? fase['duracion_segundos'] as num?)?.toInt() ?? 0;
        if (dur <= 0) {
          errors.add('${prefix}fases[$i].duracionSegundos must be positive');
        }
        duracionTotal += dur;

        // Core TPR challenge checks
        if (tipo == 'core_tpr_challenge') {
          final cmds = fase['comandosL3'] ?? fase['comandos_l3'];
          if (cmds is! List || cmds.isEmpty) {
            errors.add('${prefix}Core TPR challenge must declare at least one L3 command');
          }
        }
      }
      if (duracionTotal < 480 || duracionTotal > 660) {
        errors.add('${prefix}Total assembly duration ($duracionTotal s) must be between 8 and 11 minutes (480-660 s)');
      }
    }

    // 6. Natural Galician materials
    final mats = json['materialesEntorno'] ?? json['materiales_entorno'];
    if (mats is! List || mats.isEmpty) {
      errors.add('${prefix}Must declare at least one natural Galician material (repertorio analógico)');
    }

    // 7. Micro-routine and recast
    final micro = _asMap(json['microRutinaHogar'] ?? json['micro_rutina_hogar']);
    if (micro == null) {
      errors.add('${prefix}Missing required "microRutinaHogar"');
    } else {
      final nicho = (micro['nichoTiempoMinutos'] ?? micro['nicho_tiempo_minutos'] as num?)?.toInt() ?? 0;
      if (nicho < 3 || nicho > 5) {
        errors.add('${prefix}microRutinaHogar.nichoTiempoMinutos must be between 3 and 5 minutes (Principio Time & Place)');
      }
      final pautas = micro['pautasRecast'] ?? micro['pautas_recast'];
      if (pautas is! List || pautas.isEmpty) {
        errors.add('${prefix}microRutinaHogar must declare at least one pautasRecast item');
      }
    }

    return errors.isEmpty
        ? ValidationResult.success(warnings: warnings)
        : ValidationResult.failure(errors, warnings: warnings);
  }

  void checkCurricularAlignmentSegundoCiclo(
    Map<String, dynamic> curriculo, {
    required List<String> errors,
    String prefix = '',
  }) {
    final normativa = curriculo['normativa']?.toString().trim();
    if (normativa != 'Decreto 150/2022') {
      errors.add('${prefix}curriculo.normativa must be "Decreto 150/2022" (got: "$normativa")');
    }

    final etapa = curriculo['etapa']?.toString().trim();
    if (etapa != 'educacion_infantil') {
      errors.add('${prefix}curriculo.etapa must be "educacion_infantil" (got: "$etapa")');
    }

    final ciclo = curriculo['ciclo']?.toString().trim();
    if (ciclo != CurricularReferenceSegundoCiclo.cicloSegundo) {
      errors.add('${prefix}curriculo.ciclo must be "${CurricularReferenceSegundoCiclo.cicloSegundo}" (got: "$ciclo")');
    }

    final areas = curriculo['areas'];
    if (areas is! List || areas.isEmpty) {
      errors.add('${prefix}curriculo.areas must be a non-empty list');
    } else {
      for (final a in areas) {
        final aStr = a.toString().trim();
        if (!CurricularReferenceSegundoCiclo.validAreas.contains(aStr)) {
          errors.add('${prefix}curriculo.areas contains unrecognized area "$aStr"');
        }
      }
    }

    final criterios = curriculo['criteriosEvaluacion'] ?? curriculo['criterios_evaluacion'];
    if (criterios is! List || criterios.isEmpty) {
      errors.add('${prefix}curriculo.criteriosEvaluacion must be a non-empty list');
    } else {
      for (final crit in criterios) {
        final cStr = crit.toString().trim();
        if (!CurricularReferenceSegundoCiclo.validCriteriosSegundoCiclo.contains(cStr)) {
          errors.add('${prefix}curriculo.criteriosEvaluacion contains unrecognized criterion "$cStr"');
        }
      }
    }
  }
```

---

### 4.4 September Vertical Slice File Specifications

The 3 JSON files will be located in:  
`assets/content/asambleas_segundo_ciclo/`

#### 1. `assets/content/asambleas_segundo_ciclo/asamblea.setembro.4_infantil.json`
- **ID**: `"asamblea.segundo_ciclo.setembro.4_infantil"`
- **Nivel**: `"4_infantil"` (3-4 years)
- **Mes**: `9` (Septiembre)
- **Metodología**: `"accion_expandida"` (Two-phase commands with "and", active scaffolding with fading, strict silent period).
- **Duración total**: 600 segundos (10:00 minutos).
- **Fase 1 (Apertura 90s)**: "Good morning circle / Roda de bos días". Saludo afectivo y toma de contacto visual en la alfombra con palmas rítmicas suaves.
- **Fase 2 (Ritmo 120s)**: "Fingerplay: Two little hands / Dúas mansiñas". Rima dactilar y praxias motoras de coordinación bimanual.
- **Fase 3 (Núcleo TPR 270s)**: "Action-Expanded Challenge":
  - Command 1: `"Stand up and clap hands"` (Modelado simultáneo con desvanecimiento).
  - Command 2: `"Walk softly and touch the wicker basket"` (Exploración de cestos de mimbre).
  - Command 3: `"Pick up one pinecone and sit down"` (Manipulación de piñas del monte de O Castro).
- **Fase 4 (Calma 120s)**: "Gentle breathing / Soplo suave como as ondas de Samil". Desaceleración psicomotriz y paso a rincones.
- **Material Natural**: Vimbio / mimbre gallego (cesto) y piñas naturales grandes (> 5 cm).
- **Micro-rutina Hogar**: "Poñer os zapatos e o abrigo" (3 minutos) con pautas de recast indirecto en el hogar ("Coat on!").

#### 2. `assets/content/asambleas_segundo_ciclo/asamblea.setembro.5_infantil.json`
- **ID**: `"asamblea.segundo_ciclo.setembro.5_infantil"`
- **Nivel**: `"5_infantil"` (4-5 years)
- **Mes**: `9` (Septiembre)
- **Metodología**: `"dramatizado_narrativo"` (Cause-effect narrative, stop-signal / freeze inhibition, praxias with fingerplays).
- **Duración total**: 600 segundos (10:00 minutos).
- **Fase 1 (Apertura 90s)**: "Welcome backpack / Benvida á mochila escolar". Saludo de codos y acogida motora.
- **Fase 2 (Ritmo 120s)**: "The school clock / O reloxo do cole". Praxias orofaciales (inflar mejillas, chasquido de lengua) y rima dactilar.
- **Fase 3 (Núcleo TPR 270s)**: "Backpack physical narrative & Freeze!":
  - Command 1: `"Unzip your backpack and take out the apple"` (Mímica cinestésica).
  - Command 2: `"Walk with your bag... FREEZE! Stop and don't move!"` (Inhibición selectiva ante señal acústica).
  - Command 3: `"Hold one chestnut in your hand and walk like a giant"` (Manipulación de castañas).
- **Fase 4 (Calma 120s)**: "Candle blow / Apagar a candea amodo". Control de soplo y relajación muscular.
- **Material Natural**: Castañas autóctonas de Soutomaior / Galicia y gasas de algodón natural.
- **Micro-rutina Hogar**: "Colgar a mochila no seu lugar" (4 minutos) con pautas de recast ("Yes, your backpack is on the hook!").

#### 3. `assets/content/asambleas_segundo_ciclo/asamblea.setembro.6_infantil.json`
- **ID**: `"asamblea.segundo_ciclo.setembro.6_infantil"`
- **Nivel**: `"6_infantil"` (5-6 years)
- **Mes**: `9` (Septiembre)
- **Metodología**: `"transaccional_pragmatico"` (Peer-to-peer interaction, textless cue cards, spatial categorisation).
- **Duración total**: 600 segundos (10:00 minutos).
- **Fase 1 (Apertura 90s)**: "Partner greeting / Saúdo por parellas". Intercambio afectivo y verbal en L3 ("Hello partner!").
- **Fase 2 (Ritmo 120s)**: "Body percussion / Percusión corporal a 4 pulsos" (muslo-pecho-palma-silencio).
- **Fase 3 (Núcleo TPR 270s)**: "Peer-to-peer coat hook quest":
  - Command 1: `"Show the coat card and guide your partner to the hook"` (Intercambio con tarjetas icónicas).
  - Command 2: `"Put the big shell inside the box and give the small shell to your friend"` (Categorización espacial y kinestésica).
- **Fase 4 (Calma 120s)**: "Heavy hands, quiet feet / Mans que pesan e pés tranquilos". Relajación propioceptiva y transición cooperativa a mesas.
- **Material Natural**: Cunchas de ameixa / mexillón de la Ría de Vigo y caixas de madeira de piñeiro gallego.
- **Micro-rutina Hogar**: "Organización autónoma da roupa de mañá" (5 minutos) con elección guiada de 2 prendas y recast indirecto.

---

## 5. Verification Method

### 5.1 Static Verification Commands
Once implemented, the following test and quality commands will independently verify the architecture:
```bash
# 1. Format and static analysis
dart format --output=none --set-exit-if-changed .
flutter analyze

# 2. Existing data test suite (Must continue to pass 100% without regression)
flutter test test/data/models_test.dart
flutter test test/data/curricular_alignment_test.dart
flutter test test/data/bilingual_parity_test.dart
flutter test test/data/referential_integrity_test.dart
flutter test test/data/clinical_terms_blacklist_test.dart

# 3. New Segundo Ciclo unit and validation test suites
flutter test test/data/segundo_ciclo_models_test.dart
flutter test test/data/segundo_ciclo_loader_test.dart
flutter test test/data/segundo_ciclo_validator_test.dart

# 4. CI Gates Verification (Content gates will pass because asambleas_segundo_ciclo is isolated from unidades)
python3 tools/check_contact_email.py
python3 tools/export_voice_corpus.py --check
python3 tools/check_pulse_bpm.py
python3 tools/check_pulse_markers.py
python3 tools/check_voice_coverage.py
```

### 5.2 Invalidation Conditions
- If any model file places Segundo Ciclo JSON assets under `assets/content/unidades/`, `tools/voice_corpus.py` and `tools/check_voice_coverage.py` will fail immediately.
- If `CurricularReference.isValidDecreto150` in `curricular_model.dart` is altered to relax 0-3 constraints rather than creating `CurricularReferenceSegundoCiclo`, existing unit tests in `test/data/curricular_alignment_test.dart` asserting that `ciclo != 'primeiro_ciclo_0_3'` fails will break.
- If `duracionSegundos` across the 4 phases does not sum to the 8–11 minute window (specifically 600s / 10 min), `validateAsambleaSegundoCicloJson` must fail.
