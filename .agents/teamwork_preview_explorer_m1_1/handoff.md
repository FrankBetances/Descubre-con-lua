# Handoff Report — M1 Model Contract Explorer (asamblea_segundo_ciclo_model.dart)

**Agent**: `teamwork_preview_explorer_m1_1`  
**Working Directory**: `/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_explorer_m1_1`  
**Parent Conversation ID**: `e7633361-cefb-4427-91ff-c3fbb93625fc`  
**Recipient**: `parent` (Milestone M1 Orchestrator)  
**Date**: 2026-09-14T15:26:00Z  
**Type**: Hard Handoff (Investigation & Architectural Contract Complete)

---

## 1. Observation

### 1.1 Verbatim Regulatory & Product Requirements
1. **Scope and Methodology Mandate**:
   - `ORIGINAL_REQUEST.md` (lines 96–109):
     > *"Módulo específico de Asambleas de Infantil para colegios (Segundo Ciclo: 4.º, 5.º y 6.º de Educación Infantil, 3 a 6 años) en «Descubre con Lúa», fundamentado en Respuesta Física Total (TPR) en L3 (inglés) dentro del contexto trilingüe de Galicia (Decreto 150/2022), manteniendo estricta continuidad arquitectónica (Clean Architecture), diseño sobrio para el docente (cero pantallas para el alumnado), progresión curricular escalonada (vertical slice centrado en Septiembre para los tres niveles) y transferencia ecológica al hogar."*
   - Lines 103–107 define the 4 canonical rhythmic phases and the 3 distinct neurocognitive TPR levels:
     - 4.º Infantil (3-4 anos): *TPR de Acción Expandida* (comandos de dos fases con "and", andamiaje decreciente con modelado y fading, respeto estricto al periodo de silencio fónico).
     - 5.º Infantil (4-5 anos): *TPR Dramatizado y Narrativo* (micro-narrativas de causa/efecto, juegos de inhibición selectiva stop-signal/freeze ante claves sintácticas/semánticas, praxias orofaciais ligadas a rimas dactilares).
     - 6.º Infantil (5-6 anos): *TPR Transaccional y Juegos Pragmáticos* (intercambio entre iguales peer-to-peer con tarjetas icónicas cue cards sin texto, categorización espacial y resolución cinestésica de problemas).
   - Line 108: *Módulo Academy / Hogar*: Principio Time and Place (nichos de 3-5 minutos) y modelado correctivo indirecto (*recast*), erradicando la evaluación frontal inhibitoria.
   - Lines 117–118: Assembly phases with exact durations: Opening/Greeting (1:30 min = 90s), Movement & Rhythmic Focus (2:00 min = 120s), Core TPR Challenge (4:30 min = 270s), Calm & Transition Out (2:00 min = 120s). Total: 600s (10:00 min).
   - Line 118: Unstructured natural Galician materials: mimbre, castañas, conchas, gasas.

2. **Orchestrator Project Roadmap Contract**:
   - `PROJECT.md` (lines 61–73):
     ```dart
     class AsambleaSegundoCiclo {
       final String id;
       final LocalizedString titulo;
       final NivelEducativoSegundoCiclo nivel;
       final MetodologiaTPR metodologia;
       final CurricularReferenceSegundoCiclo curricular;
       final List<FaseAsamblea> fases; // Exactly 4 phases: [aperturaSaudo, movementRhythmFocus, coreTprChallenge, calmaTransicion]
       final List<MaterialNatural> materiaisNaturais;
       final MicroRutinaHogarSegundoCiclo microRutinaHogar;
       final Revision revision;
     }

     class FaseAsamblea {
       final int orden; // 1..4
       final TipoFaseAsamblea tipo;
       final LocalizedString titulo;
       final int duracionSegundos; // 90, 120, 270, 120
       final LocalizedString consignaDocente;
       final List<ComandoTPR> comandos;
       final String? audioAsset;
     }
     ```

3. **Existing Model Patterns & Conventions**:
   - `lib/data/models/unidad_model.dart`:
     - Line 8 defines `@immutable class Revision` with fields `autor`, `revisorPedagogico`, `fechaRevision`, `version`, `aprobadoParaAula`.
     - Lines 635–865 define `Unidad` with full immutability, immutable list wrapping `List.unmodifiable(...)`, `copyWith`, `operator ==` with `identical`, `runtimeType`, `listEquals`, and `int get hashCode => Object.hashAll([...])`.
   - `lib/data/models/curricular_model.dart`:
     - Lines 40–52 define canonical areas: `area_1_crecemento_harmonia`, `area_2_descubrimento_contorna`, `area_3_comunicacion_representacion`.
     - Line 38 defines `ciclo03 = 'primeiro_ciclo_0_3'`, which requires a dedicated class `CurricularReferenceSegundoCiclo` for `segundo_ciclo_3_6` to preserve 0-3 test invariants.
   - `lib/core/localization/localized_string.dart`:
     - Lines 8–74 define `LocalizedString` with `gl`, `es`, optional `en`, `resolve(AppLanguage)`, `hasParity`, and value equality.
   - `pubspec.yaml`:
     - No external packages (`equatable`, `freezed`, `json_serializable`) are present. Models must use pure Flutter/Dart (`package:flutter/foundation.dart`).

4. **Known Trap in ContentValidator**:
   - `STATUS.md` (lines 177–185):
     > *"`placeholderPattern` caza la palabra «todo». En `content_validator.dart:60` el patrón `\b(TODO|TBD|…)\b` va con `caseSensitive: false`, así que rechaza cualquier texto que contenga «todo» —una de las palabras más comunes en castellano y galego—. El arreglo es de una línea: `caseSensitive: true`".*

---

## 2. Logic Chain

1. **Decoupled Root Model Architecture**:
   - *Observation*: `Unidad` (`unidad_model.dart:635`) models a 6-step cycle (cancionPulso, cuento, vocabulario, preguntas, exploracion, matematicas, puenteCasa) and enforces `tramoEtario` in `{'0-2', '2-3', '0-3'}`.
   - *Logic*: Attempting to force Segundo Ciclo (3-6 years) into `Unidad` would compromise non-nullable fields or break existing tests in `test/data/models_test.dart`.
   - *Deduction*: Segundo Ciclo requires an independent, strongly typed root model: `AsambleaSegundoCiclo` (with alias `UnidadSegundoCiclo`).

2. **Neurocognitive Differentiation by Level**:
   - *Observation*: `ORIGINAL_REQUEST.md` lines 105–107 prescribe distinct methodologies for 4º, 5º, and 6º de Infantil.
   - *Logic*: Grouping these into two complementary enums:
     - `NivelEducativoSegundoCiclo`: `infantil4` (3-4 anos), `infantil5` (4-5 anos), `infantil6` (5-6 anos).
     - `MetodologiaTPR`: `accionExpandida` (4º EI), `dramatizadoNarrativo` (5º EI), `transaccionalPragmatico` (6º EI).
   - *Deduction*: Both enums provide mapping properties (`clave`, `etiqueta`, `tramoEtario`, `metodologiaPorDefecto`, `usaTarjetasIconicas`, `usaSenalInhibicion`) and tolerant parsers (`desdeClave`).

3. **Assembly Temporal & Phase Rhythm (4 Canonical Phases = 600s)**:
   - *Observation*: The assembly consists strictly of 4 phases:
     1. Apertura / Saúdo: 90 s (1:30 min)
     2. Movement & Rhythmic Focus: 120 s (2:00 min)
     3. Core TPR Challenge: 270 s (4:30 min)
     4. Calma & Transición: 120 s (2:00 min)
     Sum = 90 + 120 + 270 + 120 = 600 seconds (10:00 minutes).
   - *Logic*: Enum `TipoFaseAsamblea` encapsulates `duracionCanonicoSegundos`, `orden`, `clave`, and `nombre`.
   - *Deduction*: `FaseAsamblea` stores `orden` (1..4), `tipo`, `duracionSegundos`, `consignaDocente`, `comandosL3`, `cueAcustica`, `audioAsset`, and `repertorioMateriales`. Compatibility getters `comandos` and `materiaisNaturais` ensure 100% interoperability with both `PROJECT.md` and survey reports.

4. **Atlantic Natural Materials Model (`MaterialNatural`)**:
   - *Observation*: Activities in Segundo Ciclo use Galician unstructured natural materials: mimbre/vimbio, castañas, conchas da ría, and gasas de algodón.
   - *Logic*: Rigid manipulatives require safety guarantees (size >= 4.0 cm, no sharp edges).
   - *Deduction*: `MaterialNatural` encapsulates `id`, `nombre`, `procedencia`, `pautaManipulacion`, and optional `avisoSeguridad`.

5. **Curricular Alignment (`CurricularReferenceSegundoCiclo`)**:
   - *Observation*: Segundo Ciclo adheres to **Decreto 150/2022 de Galicia**, sharing the 3 areas (`area_1_crecemento_harmonia`, `area_2_descubrimento_contorna`, `area_3_comunicacion_representacion`), but operates under cycle `segundo_ciclo_3_6` with 10 specific evaluation criteria (`CA1.1` to `CA3.3`).
   - *Logic*: Existing `CurricularReference` hardcodes `ciclo == 'primeiro_ciclo_0_3'`.
   - *Deduction*: `CurricularReferenceSegundoCiclo` models `normativa`, `etapa`, `ciclo`, `nivel`, `areas`, `competenciasClave` (default: `['CCL', 'CPSAA', 'CCEC']`), and `criteriosEvaluacion`, with validation getter `isValidDecreto150SegundoCiclo`.

6. **Ecological Home Transfer (`MicroRutinaHogarSegundoCiclo` & `PautaRecast`)**:
   - *Observation*: Transfer to families requires a short daily niche (3-5 minutes, "Time and Place" principle) and indirect corrective modeling (*recast*), banishing frontal negative evaluation.
   - *Logic*: `PautaRecast` models `expresionMenor`, `modeladoIndirecto`, and `consejoEvitar`. `MicroRutinaHogarSegundoCiclo` holds the micro-routine metadata and links to Academy (`enlaceCapsulaAcademyId`).

7. **Contract & Serialization Parity**:
   - *Observation*: JSON payloads can arrive from snake_case or camelCase keys (e.g. `metodologia_tpr` vs `metodologiaTpr`, `curriculo` vs `curricular`).
   - *Logic*: Factory `fromJson` constructors must safely check both key variations, trim string inputs, wrap all lists in `List.unmodifiable(...)`, and implement full value equality (`operator ==` with `listEquals` and `Object.hashAll`).

---

## 3. Caveats

1. **Read-Only Scope**:
   - As an explorer agent, no files have been created directly in `lib/` or `test/`. The complete, production-ready code files have been written to this agent's folder:
     - Model: `.agents/teamwork_preview_explorer_m1_1/proposed_asamblea_segundo_ciclo_model.dart`
     - Tests: `.agents/teamwork_preview_explorer_m1_1/proposed_asamblea_segundo_ciclo_models_test.dart`
2. **Audio Offline Execution**:
   - `audioAsset` in `ComandoTPR` and `FaseAsamblea` is optional (`String?`). The application runs 100% offline, and teacher cards render glanceable text prompts regardless of whether pre-synthesized neural audio assets are bundled.
3. **Backstage UI Distinction**:
   - Unlike 0-3 `Unidad` (which includes story illustrations and child-facing activities), Segundo Ciclo assembly models are strictly back-of-the-house teacher guides with zero child-facing screens or gamification elements.

---

## 4. Conclusion & Technical Specifications

### 4.1 Complete Code Specification: `lib/data/models/asamblea_segundo_ciclo_model.dart`

The implementation is written to `.agents/teamwork_preview_explorer_m1_1/proposed_asamblea_segundo_ciclo_model.dart` and contains:

1. **Enums**:
   - `NivelEducativoSegundoCiclo`: `infantil4`, `infantil5`, `infantil6`.
     - Getters: `clave`, `tramoEtario`, `edadMinima`, `edadMaxima`, `etiqueta`, `metodologiaPorDefecto`.
     - Static: `desdeClave(String? valor)`.
     - Alias: `typedef TPRLevel = NivelEducativoSegundoCiclo;`.
   - `MetodologiaTPR`: `accionExpandida`, `dramatizadoNarrativo`, `transaccionalPragmatico`.
     - Getters: `clave`, `nombre`, `nivelCorrespondiente`, `usaTarjetasIconicas`, `usaSenalInhibicion`.
     - Static: `desdeClave(String? valor)`.
   - `TipoFaseAsamblea`: `aperturaSaudo`, `movementRhythmFocus`, `coreTprChallenge`, `calmaTransicion`.
     - Getters: `orden` (1..4), `clave`, `duracionCanonicoSegundos` (90, 120, 270, 120), `duracionMinutosDecimal`, `nombre`.
     - Static: `desdeClave(String? valor)`, `porOrden(int orden)`.

2. **Classes**:
   - `ComandoTPR`: `@immutable`, const constructor, `id`, `textoIngles`, `accionFisica`, `modeladoDocente`, `audioAsset`, `fromJson`, `toJson`, `copyWith`, `operator ==`, `hashCode`.
   - `MaterialNatural`: `@immutable`, const constructor, `id`, `nombre`, `procedencia`, `pautaManipulacion`, `avisoSeguridad`, `fromJson`, `toJson`, `copyWith`, `operator ==`, `hashCode`.
   - `FaseAsamblea`: `@immutable`, const constructor, `orden`, `tipo`, `titulo`, `duracionSegundos`, `consignaDocente`, `comandosL3`, `cueAcustica`, `audioAsset`, `repertorioMateriales`. Compatibility getters: `comandos`, `materiaisNaturais`, `duracionMinutosEnteros`, `duracionFormateada`. Full equality and serialization.
   - `CurricularReferenceSegundoCiclo`: `@immutable`, const constructor, `normativa`, `etapa`, `ciclo`, `nivel`, `areas`, `competenciasClave`, `criteriosEvaluacion`. Constants: `cicloSegundo = 'segundo_ciclo_3_6'`, `validAreas`, criteria `CA1.1` to `CA3.3`. Getters: `isValidDecreto150SegundoCiclo`, `hasArea`, `hasCriterio`, `hasCompetencia`. Alias: `typedef CurriculoSegundoCiclo = CurricularReferenceSegundoCiclo;`.
   - `PautaRecast`: `@immutable`, const constructor, `expresionMenor`, `modeladoIndirecto`, `consejoEvitar`, `fromJson`, `toJson`, `copyWith`, `operator ==`, `hashCode`.
   - `MicroRutinaHogarSegundoCiclo`: `@immutable`, const constructor, `id`, `titulo`, `nichoTiempoMinutos` (3..5), `momentoDelDia`, `objetivoAutonomia`, `pautasRecast`, `escenaCotidiana`, `enlaceCapsulaAcademyId`. Full equality and serialization.
   - `AsambleaSegundoCiclo` (Root): `@immutable`, const constructor, `id`, `nivel`, `mes`, `titulo`, `centroInteres`, `metodologiaTpr`, `duracionTotalMinutos` (default 10), `fases` (List of 4 `FaseAsamblea`), `curriculo`, `materialesEntorno`, `microRutinaHogar`, `revision`. Compatibility getters: `metodologia`, `curricular`, `materiaisNaturais`, `duracionTotalSegundos`, `hasCanonicalPhases`, `fasePorTipo`, `fasePorOrden`. Full value equality with `listEquals` on `fases` and `materialesEntorno`. Aliases: `typedef SegundoCicloUnidad = AsambleaSegundoCiclo;` and `typedef UnidadSegundoCiclo = AsambleaSegundoCiclo;`.

---

### 4.2 ContentAssetLoader Extension Specification
In `lib/data/loaders/content_asset_loader.dart`:
```dart
import '../models/asamblea_segundo_ciclo_model.dart';

// Add to ContentAssetLoader:
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

---

### 4.3 ContentRepository Extension Specification
In `lib/data/repositories/content_repository.dart`:
```dart
import '../models/asamblea_segundo_ciclo_model.dart';

// In ContentRepository:
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

### 4.4 ContentValidator Placeholder Fix Specification
In `lib/data/validators/content_validator.dart:60-63`:
```dart
// Change caseSensitive: false to caseSensitive: true:
static final RegExp placeholderPattern = RegExp(
  r'\b(TODO|TBD|PLACEHOLDER|PENDIENTE|PENDENTE|LOREM\s+IPSUM)\b',
  caseSensitive: true,
);
```

---

## 5. Verification Method

### 5.1 Verification Commands
The implementing agent can verify the implementation with:
```bash
# 1. Verify Dart formatting and static analysis
dart format --output=none --set-exit-if-changed lib/data/models/asamblea_segundo_ciclo_model.dart
flutter analyze lib/data/models/asamblea_segundo_ciclo_model.dart

# 2. Run new model unit tests
flutter test test/data/asamblea_segundo_ciclo_models_test.dart

# 3. Ensure zero regression on existing tests
flutter test test/data/models_test.dart
flutter test test/data/curricular_alignment_test.dart
flutter test test/data/bilingual_parity_test.dart
flutter test test/data/clinical_terms_blacklist_test.dart
```

### 5.2 Invalidation Conditions
- If `TipoFaseAsamblea` durations do not sum to 600 seconds, the 10-minute assembly temporal contract is invalidated.
- If `CurricularReference` in `curricular_model.dart` is modified directly instead of adding `CurricularReferenceSegundoCiclo`, existing 0-3 unit tests asserting `ciclo == 'primeiro_ciclo_0_3'` will fail.
- If `placeholderPattern` remains `caseSensitive: false`, any legitimate pedagogical text containing the common word "todo" will fail validation.
- If any collection in the models returns mutable lists, immutability guarantees are breached.

---

### Artifacts Produced
- Proposed model file: `.agents/teamwork_preview_explorer_m1_1/proposed_asamblea_segundo_ciclo_model.dart`
- Proposed test suite: `.agents/teamwork_preview_explorer_m1_1/proposed_asamblea_segundo_ciclo_models_test.dart`
- Progress tracking: `.agents/teamwork_preview_explorer_m1_1/progress.md`
- Working memory: `.agents/teamwork_preview_explorer_m1_1/BRIEFING.md`
- Final report: `.agents/teamwork_preview_explorer_m1_1/handoff.md`
