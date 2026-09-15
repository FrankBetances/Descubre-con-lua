# Handoff Report — Curricular & Methodological Spec Miner (Segundo Ciclo 3-6 Anos)

**Agent ID**: `teamwork_preview_spec_miner_s3_1`  
**Workspace**: `/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_spec_miner_s3_1`  
**Parent Conversation ID**: `e7633361-cefb-4427-91ff-c3fbb93625fc`  
**Date**: 2026-09-14T13:21:00Z  
**Type**: Hard Handoff (Task Complete)

---

## 1. Observation

### 1.1 Codebase & Regulatory Observations

1. **Mandate and Scope Source**:
   - `ORIGINAL_REQUEST.md` (lines 94-161, `## Follow-up — 2026-09-14T13:15:17Z`):
     - Line 96: *"Módulo específico de Asambleas de Infantil para colegios (Segundo Ciclo: 4.º, 5.º y 6.º de Educación Infantil, 3 a 6 años) en «Descubre con Lúa», fundamentado en Respuesta Física Total (TPR) en L3 (inglés) dentro del contexto trilingüe de Galicia (Decreto 150/2022)..."*
     - Lines 103-107: Establishes the 4 rhythmic phases of the 8-10 min assembly and the 3 distinct neurocognitive TPR levels:
       * 4.º Infantil (3-4y): Action-Expanded TPR with "and", fading, silent period.
       * 5.º Infantil (4-5y): Dramatized & Narrative TPR, cause/effect, stop-signal/freeze, orofacial praxias with fingerplays.
       * 6.º Infantil (5-6y): Transactional & Pragmatic TPR peer-to-peer with textless cue cards, spatial categorisation.
     - Line 108: Academy / Hogar module based on Time and Place (3-5 min niching) and recast (indirect corrective modeling).
     - Lines 117-118: Assembly phases with exact durations: Opening/Greeting (1:30 min), Movement & Rhythmic Focus (2:00 min), Core TPR Challenge (4:30 min), Calm & Transition Out (2:00 min).
     - Line 118: Unstructured natural Galician materials: mimbre, castañas, conchas, gasas.

2. **Existing Curricular Models**:
   - `lib/data/models/curricular_model.dart`:
     - Lines 32-38:
       ```dart
       static const String decretoGalicia = 'Decreto 150/2022';
       static const String etapaInfantil = 'educacion_infantil';
       static const String ciclo03 = 'primeiro_ciclo_0_3';
       ```
     - Lines 41-52: Áreas 1, 2, 3 defined (`area_1_crecemento_harmonia`, `area_2_descubrimento_contorna`, `area_3_comunicacion_representacion`).
     - Lines 55-68: Criterios for 0-3 years only: `CA1.1`, `CA2.1`, `CA2.2`, `CA3.1`, `CA3.2`.
     - Lines 113-126: `isValidDecreto150` strictly checks `ciclo == ciclo03` and `validCriterios.contains(...)`.
   - `lib/data/validators/content_validator.dart`:
     - Lines 283-295:
       ```dart
       final etapa = curriculo['etapa']?.toString().trim();
       if (etapa != CurricularReference.etapaInfantil) { ... }
       final ciclo = curriculo['ciclo']?.toString().trim();
       if (ciclo != CurricularReference.ciclo03) {
         errors.add('${prefix}curriculo.ciclo must be "${CurricularReference.ciclo03}" (got: "$ciclo")');
       }
       ```
     - Verbatim constraint: The existing validator strictly hardcodes `ciclo == 'primeiro_ciclo_0_3'`. To support the Segundo Ciclo (3-6 years), it must support `segundo_ciclo_3_6` and its corresponding criteria.

3. **Clinical Term Blacklist & Placeholders**:
   - `lib/data/validators/content_validator.dart`:
     - Lines 48-57:
       ```dart
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
       ```
     - Lines 60-63:
       ```dart
       static final RegExp placeholderPattern = RegExp(
         r'\b(TODO|TBD|PLACEHOLDER|PENDIENTE|PENDENTE|LOREM\s+IPSUM)\b',
         caseSensitive: false,
       );
       ```
     - `STATUS.md` line 177-185: Highlights that `placeholderPattern` with `caseSensitive: false` falsely matches the word "todo" ("all" in Galician/Spanish) and notes it must use `caseSensitive: true`.
     - `test/data/clinical_terms_blacklist_test.dart`: Validates rejection of 27 clinical terms, allows approved pedagogical equivalents, and exempts "tratamiento de agua" / "tratamento de auga".

4. **Calendario & TPR Model Precedent**:
   - `lib/data/models/calendario_model.dart` lines 20-21, 57-58:
     - `final List<String> lexicoIngles;`
     - `final List<String> comandosTpr;`
     - Already models 10 months with commands like `Stand up`, `Sit down`, `Clap hands`, `Touch your head`, `Freeze!`.

5. **Capsule Models & Home Micro-Routines**:
   - `lib/data/models/capsula_model.dart` lines 84-96:
     - 4 canonical parts: `ideaClave`, `porQueImporta`, `queHacerEnCasa`, `ejemploCotidiano`.
     - Perfect host for Academy home micro-routine and recast modeling.

---

## 2. Logic Chain

1. **Curricular Demarcation (Decreto 150/2022 de Galicia)**:
   - *Premise*: Galicia's official preschool curriculum is governed by *Decreto 150/2022, do 8 de setembro* (DOG nº 172).
   - *Observation*: The regulation partitions *Educación Infantil* into two cycles: *Primeiro Ciclo (0-3 anos)* and *Segundo Ciclo (3-6 anos)*.
   - *Inference*: The data model and validator must recognize:
     - Etapa: `educacion_infantil`.
     - Ciclo: `segundo_ciclo_3_6` (alongside existing `primeiro_ciclo_0_3`).
     - Cursos / Niveis:
       * `4_infantil` (3-4 anos / 4.º de EI).
       * `5_infantil` (4-5 anos / 5.º de EI).
       * `6_infantil` (5-6 anos / 6.º de EI).
   - *Inference for Áreas*: The 3 canonical areas remain identical across both cycles:
     * `area_1_crecemento_harmonia`
     * `area_2_descubrimento_contorna`
     * `area_3_comunicacion_representacion`
   - *Inference for Evaluation Criteria*: Decreto 150/2022 explicitly sets distinct criteria for Segundo Ciclo:
     * Area 1: `CA1.1` (body scheme and motor coordination), `CA1.2` (dressing & daily autonomy), `CA1.3` (emotional and impulse regulation), `CA1.4` (peer empathy and cooperative play).
     * Area 2: `CA2.1` (tactile sensory exploration of natural materials), `CA2.2` (spatial logic and categorisation), `CA2.3` (discovery and respect of local natural environment).
     * Area 3: `CA3.1` (TPR oral comprehension and immediate motor response in L3), `CA3.2` (phonological discrimination, rhythm and stop-signal auditory cueing), `CA3.3` (peer interaction mediated by iconic non-verbal cues).

2. **Assembly Temporal & Phase Architecture**:
   - *Premise*: Assembly in Segundo Ciclo is designed as an 8-10 minute morning circle exclusively guided by the teacher's glanceable screen (zero child viewing).
   - *Observation*: ORIGINAL_REQUEST.md establishes 4 canonical phases with exact durations summing to 10:00 min:
     - Phase 1: Opening / Greeting -> 1:30 min (90s)
     - Phase 2: Movement & Rhythmic Focus -> 2:00 min (120s)
     - Phase 3: Core TPR Challenge -> 4:30 min (270s)
     - Phase 4: Calm & Transition Out -> 2:00 min (120s)
   - *Inference*: The JSON schema and Dart model for `UnidadSegundoCiclo` must enforce this exact 4-phase sequence, with duration seconds (`90`, `120`, `270`, `120`) and total duration 600s.

3. **Neurocognitive Scaffolding of TPR by Grade Level**:
   - *4.º de Infantil (3-4y)*:
     - Working memory is limited to two chunks.
     - Mandate: **TPR de Acción Expandida (Action-Expanded)**.
     - Structure: Dual imperatives linked by "and" (e.g. `Stand up and clap hands`).
     - Scaffolding: 3 steps: (1) Synchronous modeling, (2) Delayed modeling / fading, (3) Autonomous motor execution.
     - Rule: Strict respect for the **Silent Period** (período de silencio fónico) — zero forced speech in L3.
   - *5.º de Infantil (4-5y)*:
     - Narrative comprehension and inhibitory control (go/no-go) emerge.
     - Mandate: **TPR Dramatizado e Narrativo (Dramatized & Narrative)**.
     - Structure: Micro-narratives of 3-4 causal physical actions (e.g., packing backpack, walking in rain).
     - Selective inhibition: Acoustic cues triggering instant motor arrest (`Stop-signal / Freeze!`).
     - Articulatory integration: Fingerplays linked to orofacial praxias (mouth shapes, breath, clicks) without clinical terminology.
   - *6.º de Infantil (5-6y)*:
     - Theory of mind and cooperative interaction between equals are active.
     - Mandate: **TPR Transaccional e Xogos Pragmáticos (Transactional / Pragmatic Peer-to-Peer)**.
     - Structure: Peer-to-peer exchange where children guide each other using **textless iconic cue cards** (tarxetas icónicas sen texto).
     - Goal: Kinesthetic problem solving, spatial preposition tasks (`inside`, `under`, `next to`, `on the peg`).

4. **Natural Unstructured Materials of Galicia & Safety Constraints**:
   - *Premise*: Pedagogical alignment with Galician heritage and open sensory discovery without plastic or screens.
   - *Materials*:
     * **Mimbre (vimbio)**: Handwoven baskets and rings; fibrous organic texture, natural flexibility, tactile containment.
     * **Castañas**: Smooth satin chestnuts and soft empty burrs (ourizos suaves); thermal contrast, weight sensation, palmar grasp.
     * **Conchas (Ría de Vigo)**: Vieiras, berberechos, mexillóns; fluted ridges vs. smooth nacre, sound resonance, calcium hardness.
     * **Gasas de algodón**: Breathable translucent muslin/gauze; airy lightness, wind simulation, visual occlusion, calming draping.
   - *Safety Rule*: Rigid manipulatives must measure **>= 4.0 cm** (shells >= 5.0 cm); zero sharp edges or splinters; fully sanitized; continuous teacher supervision.

5. **Academy Home Micro-routines & Recast Methodology**:
   - *Premise*: Ecological home transfer without burdensome homework.
   - *Timing*: "Time and Place" principle: **3-5 minutes** embedded into natural morning/evening routines (dressing, shoes, coat).
   - *Pedagogical Technique*: **Recast (Modelado Correctivo Indirecto)**.
     * Never use frontal correction (forbid "Mal", "Así no", "Repite").
     * When child communicates imperfectly or hesitates, adult validates intent, reflects the correct phrasing in a natural sentence, and waits 5 seconds actively.
     * Combines Galician/Spanish conversational warmth with simple L3 motor triggers (`Up on the hook, zip!`).

6. **Clinical Term Blacklist & Ethical Boundaries**:
   - *Premise*: The app is early childhood education, not a medical or diagnostic device.
   - *Blacklist*: Total ban on terms like `trastorno`, `patoloxía`, `diagnóstico`, `síntoma`, `paciente`, `terapia`, `déficit`, `retraso clínico`, `dislalia`, `dislexia`, `screening`, `criba`.
   - *Linter Exemption*: Maintain regex exception for maritime environmental `tratamento de auga` / `tratamiento de agua`.
   - *Linter Fix*: Enforce `caseSensitive: true` on `placeholderPattern` so the Galician/Spanish word "todo" is not falsely flagged.

---

## 3. Features Discovered Table

| # | Category | Feature | Description | Inputs | Outputs | Error Behavior | Discovered Via |
|---|----------|---------|-------------|--------|---------|----------------|----------------|
| 1 | Curricular | Decreto 150/2022 Segundo Ciclo Alignment | Formal validation of educational stage (`educacion_infantil`), cycle (`segundo_ciclo_3_6`), and 3 official Galician areas | Curricular JSON block (`normativa`, `etapa`, `ciclo`, `areas`, `criteriosEvaluacion`) | Boolean validity, parsed `CurricularReference` | Throws validation error if cycle != `segundo_ciclo_3_6` or if area/criterion unrecognized | ORIGINAL_REQUEST.md line 96; `curricular_model.dart` |
| 2 | Curricular | Tri-level Grade Differentiation | Distinction across 4.º (3-4y), 5.º (4-5y), and 6.º (5-6y) de Infantil | Level key: `4_infantil`, `5_infantil`, `6_infantil` | Level metadata & specific TPR profile | Reject invalid level strings | ORIGINAL_REQUEST.md lines 105-107 |
| 3 | Assembly Timing | 4 Canonical Phases Sequencing | Fixed temporal progression: Opening (1:30), Rhythmic Focus (2:00), Core TPR (4:30), Calm (2:00) | `FaseAsamblea` objects with title, instructions, audio, and duration in seconds | Sequenced wizard steps with precise countdown timer | Fails validation if phases count != 4 or phase durations deviate from 90s, 120s, 270s, 120s | ORIGINAL_REQUEST.md lines 103, 117 |
| 4 | TPR Methodology | Action-Expanded TPR (4.º Infantil) | Coordinated 2-stage commands with "and", decreasing scaffolding (synchronous model -> delayed fading -> autonomous) | Two-clause L3 command strings, suggested teacher physical models | Kinesthetic response cards for teacher | Fails if commands lack 2-clause structure or demand forced verbal repetition | ORIGINAL_REQUEST.md line 105 |
| 5 | TPR Methodology | Silent Period Invariant | Complete absence of forced verbal output in English for 3-4 year olds | Audio prompt in L3 | Motor execution by children without verbalization demand | Flagged if instructions contain "repite" or forced repetition | ORIGINAL_REQUEST.md line 105 |
| 6 | TPR Methodology | Dramatized & Narrative TPR (5.º Infantil) | 3-4 beat micro-narrative of cause and effect linked to physical movements | Narrative script with movement annotations | Story-action sequence for morning circle | Fails if narrative lacks physical actions or cause/effect sequence | ORIGINAL_REQUEST.md line 106 |
| 7 | TPR Methodology | Selective Inhibition (Stop-Signal / Freeze) | Inhibitory control mechanic pausing motor action upon specific acoustic/syntactic trigger | Trigger keyword or acoustic sound (e.g. `Freeze!`) | Sudden motor inhibition prompt | Fails if activity lacks clear freeze cue | ORIGINAL_REQUEST.md line 106; `calendario_model.dart` line 87 |
| 8 | TPR Methodology | Articulatory Praxias & Fingerplays | Coordinated finger gestures coupled to vocalic mouth postures without medical speech terms | Finger movement instructions & phonetic shapes | Non-clinical rhyme card | Flagged if clinical phoniatric terminology is detected | ORIGINAL_REQUEST.md line 106 |
| 9 | TPR Methodology | Transactional Peer-to-Peer TPR (6.º Infantil) | Cooperative interaction where children instruct and guide each other | Pair configurations, cooperative spatial goals | Peer dynamic instructions | Fails if design forces solitary teacher-fronted delivery | ORIGINAL_REQUEST.md line 107 |
| 10 | Sensory Materials | Iconic Textless Cue Cards (6.º Infantil) | High-contrast pictorial cards without textual labels for peer instruction | Image/symbol asset path (no text) | Rendered visual cue card on screen/cardstock | Fails if cards contain textual English/Galician words (pre-literacy barrier) | ORIGINAL_REQUEST.md line 107 |
| 11 | Sensory Materials | Galician Unstructured Materials | Tactile exploration kit featuring mimbre, castañas, conchas da ría, and gasas de algodón | Material descriptors, tactile sensation tags | Material prep checklist for teacher | Fails if non-natural or non-Galician synthetic materials are mandated | ORIGINAL_REQUEST.md line 118 |
| 12 | Safety | Tactile Manipulative Size & Finish Gate | Mandatory size limit (>= 4.0 cm, shells >= 5.0 cm), zero sharp edges, sanitized | Safety notice JSON in `gl` and `es` | Safety banner displayed to teacher before exploration | Fails if `avisoSeguridad` missing or blank | `content_validator.dart` line 407; ORIGINAL_REQUEST.md R1 |
| 13 | Family Transfer | Academy Home Micro-routines | 3-5 minute daily routine niches for morning dressing, shoes, and coats | Micro-routine JSON (context, action, dialogue) | Home card in Academy module | Fails if duration > 5 min or if academic homework format is used | ORIGINAL_REQUEST.md line 108, 118 |
| 14 | Family Transfer | Recast (Modelado Correctivo Indirecto) | Conversational technique expanding child's spontaneous words into correct models without rebuke | Dialogue scripts with prohibited correction vs. approved recast | Family guidance script with 5s wait time | Fails if script displays frontal correction or negative appraisal | ORIGINAL_REQUEST.md lines 108, 131 |
| 15 | Quality Gate | Clinical Term Blacklist Enforcement | Automated regex check blocking 27+ medical, diagnostic, and therapy words | Any string in content tree | Clean pass or regex violation error | Rejects JSON if prohibited words appear | `content_validator.dart` line 48 |
| 16 | Quality Gate | Maritime Water Treatment Exemption | Regex exemption for "tratamento de auga" and "tratamiento de agua" | Maritime environmental texts | Passes validation without false positive | Only exempt if followed by "de agua" or "de auga" | `content_validator.dart` line 52; `clinical_terms_blacklist_test.dart` line 132 |
| 17 | Quality Gate | Case-Sensitive Placeholder Protection | Fixes placeholder detection so common word "todo" does not trigger false positive | Text tokens `TODO`, `TBD`, `PLACEHOLDER` | Matches uppercase markers only | Fails if lowercase "todo" is flagged | `STATUS.md` line 177; `content_validator.dart` line 60 |
| 18 | Audio & UI | Teacher Backstage Glanceable UI | Dark-mode, high-contrast, large typography (>= 24sp) readable at 2 meters | Teacher interface state | High-visibility screen with big touch targets | Fails widget tests if child-interactive or gamified UI is presented | ORIGINAL_REQUEST.md lines 121-124 |
| 19 | Audio & UI | Audio Pulse Fade-In / Fade-Out | Smooth volume transitions preventing startle responses during phase shifts | Offline audio asset path & fade duration | Audio playback stream with volume ramp | Rejects remote URL or unsupported format | ORIGINAL_REQUEST.md line 123; `OfflineAudioService` |
| 20 | Curricular Slice | September Pilot Unit: "Acollida e Rutinas" | Full thematic unit for September differentiated across 4.º, 5.º, 6.º and home routine | JSON asset `segundo_ciclo.setembro.01.json` | 3 classroom tracks + 1 home micro-routine | Fails if any level lacks content or bilingual parity | ORIGINAL_REQUEST.md lines 126-132 |

---

## 4. Edge Cases Table

| # | Feature | Input | Observed Behavior |
|---|---------|-------|-------------------|
| 1 | Bilingual Parity Validator | Asymmetric node: `{"gl": "Benvida", "es": ""}` | Validator fails with error: `"root.titulo: 'es' is missing, not a string, or blank"`. |
| 2 | Placeholder Validator | Sentence containing lowercase word: `"Miramos todo o mar"` with `caseSensitive: false` | Validator falsely fails because `\btodo\b` matches the Spanish/Galician word for "all/everything". Must use `caseSensitive: true`. |
| 3 | Clinical Terms Linter | Text: `"Actividade terapéutica para a mellora"` | Validator fails with error: `"contains prohibited clinical/diagnostic term: 'terapéutica'"`. |
| 4 | Clinical Terms Linter | Text: `"A depuradora realiza o tratamento de auga na ría de Vigo"` | Validator passes cleanly because `(?!(tratamiento|tratamento)\s+d[eé]\s+a(ug|gu)a)` exempts it. |
| 5 | Curricular Validator | Unit with `ciclo: "segundo_ciclo_3_6"` evaluated by legacy `ContentValidator` | Validator fails with error: `"curriculo.ciclo must be 'primeiro_ciclo_0_3' (got: 'segundo_ciclo_3_6')"`. Requires validator enhancement to support both cycles. |
| 6 | Curricular Validator | Unit declaring outdated standard: `"normativa": "Decreto 330/2009"` | Validator fails with error: `"curriculo.normativa must be 'Decreto 150/2022'"`. |
| 7 | Assembly Duration Check | Assembly session where sum of phase durations = 540s (9 min) instead of 600s | Structural validator flags mismatch with expected canonical 10:00 min (600 seconds) duration. |
| 8 | Audio Path Integrity | Audio path declared as `"https://audio.cdn.com/hello.mp3"` | Validator fails with error: `"Audio asset path must begin with one of [assets/voice/, assets/audio/]"`. Preserves zero-network constraint. |
| 9 | Manipulative Material Size | Shell size declared as `3.5 cm` in activity note | Validator flags warning/error: natural rigid manipulatives must be >= 4.0 cm (shells >= 5.0 cm) to eliminate choking hazard. |
| 10 | TPR Silent Period (4.º EI) | Activity prompt instructing: `"Os nenos deben repetir a palabra 'Hello' dúas veces"` | Pedagogical check flags violation of Silent Period invariant: 4.º Infantil TPR requires motor response only, zero forced repetition. |
| 11 | Cue Card Format (6.º EI) | Cue card containing textual label `"COAT"` alongside the icon | Validator flags pre-literacy barrier violation: cue cards for 6.º Infantil must be textless icons to ensure cognitive focus on spatial peer interaction. |
| 12 | Recast Format in Academy | Capsule script providing direct correction: `"Non, así non se di, tes que dicir 'puxen o abrigo'"` | Validator flags violation: Academy scripts must employ positive indirect recast, never frontal negative appraisal. |

---

## 5. Specification Matrix for Segundo Ciclo (3-6 Anos)

### 5.1 Curricular Reference Matrix (Decreto 150/2022 de Galicia)

| Parameter | Specification | Validation Rule / Constant |
|---|---|---|
| **Normativa** | `Decreto 150/2022` | Must strictly equal `CurricularReference.decretoGalicia` |
| **Etapa** | `educacion_infantil` | Must strictly equal `CurricularReference.etapaInfantil` |
| **Ciclo** | `segundo_ciclo_3_6` | Canonical cycle constant for 3-6 years in Galicia |
| **Niveis / Cursos** | `4_infantil` (3-4 anos), `5_infantil` (4-5 anos), `6_infantil` (5-6 anos) | Validated against supported level set |
| **Área 1** | `area_1_crecemento_harmonia` | Crecemento en harmonía (Autonomía, esquema corporal, emocións) |
| **Área 2** | `area_2_descubrimento_contorna` | Descubrimento e exploración da contorna (Materiais naturais, lóxica espacial) |
| **Área 3** | `area_3_comunicacion_representacion` | Comunicación e representación da realidade (TPR en L3, ritmo, interacción entre iguais) |
| **Criterios Segundo Ciclo** | `CA1.1` (Control postural e coordinación motora)<br>`CA1.2` (Autonomía nas rutinas cotiás e vestido)<br>`CA1.3` (Regulación emocional e inhibición de impulsos)<br>`CA1.4` (Cooperación e empatía entre iguais)<br>`CA2.1` (Exploración táctil de materiais naturais: mimbre, castañas, cunchas, gasas)<br>`CA2.2` (Lóxica espacial e categorización manipulativa)<br>`CA2.3` (Interese e respecto pola contorna natural viguesa)<br>`CA3.1` (Comprensión oral e resposta motriz en L3 - TPR)<br>`CA3.2` (Discriminación auditiva, ritmo e sinais stop-signal)<br>`CA3.3` (Comunicación e xogo entre iguais con apoio icónico) | Every unit must declare at least 2 distinct criteria covering Area 3 and either Area 1 or Area 2 |

---

### 5.2 Assembly Architecture & Timing Matrix (4 Canonical Phases)

Total Duration: **10:00 minutes (600 seconds)**

| Phase # | Canonical Phase Name | Exact Duration | Cognitive / Motor Objective | Backstage Teacher Display (Glanceable UI) | Audio / Acoustic Asset |
|---|---|---|---|---|---|
| **Phase 1** | **Opening / Greeting**<br>*(Apertura e Saúdo)* | **1:30 min**<br>(90 s) | Social gathering in circle, visual anchor with Lúa mascot, affective check-in, setting auditory readiness. | Mascot greeting card, circle seating prompt, high-contrast welcome formula: `"Hello, Lúa! Hello, friends!"`. Large elapsed countdown timer. | Soft acoustic chime / opening greeting audio (`LJSpeech` / `Celtia`). Smooth 2s fade-in. |
| **Phase 2** | **Movement & Rhythmic Focus**<br>*(Foco Rítmico e Movemento)* | **2:00 min**<br>(120 s) | Rhythmic motor synchronization, fingerplays, beat priming, vestibular/proprioceptive activation. | Rhythmic gesture cues (knees, claps, fingers), pulse tempo indicator (visual metronome at 72-80 BPM). | Steady rhythmic pulse track (offline WAV/M4A) or spoken fingerplay. |
| **Phase 3** | **Core TPR Challenge**<br>*(Reto Núcleo TPR en L3)* | **4:30 min**<br>(270 s) | Central kinesthetic language challenge in L3. Differentiated by level (Action-Expanded, Dramatized, Transactional). | High-contrast L3 command text (>= 24sp), suggested kinesthetic action descriptions for educator, scaffold step indicator. | Model L3 pronunciation snippets (`LJSpeech`). Quick replay tap. |
| **Phase 4** | **Calm & Transition Out**<br>*(Calma e Transición)* | **2:00 min**<br>(120 s) | Physiological down-regulation, tactile grounding with natural textures, slow diaphragmatic breathing, smooth transfer to learning corners. | Natural material tactile cue, sensory transition prompt, breathing wave animation or quiet countdown. | Ambient acoustic decrescendo with gentle 3s fade-out. |

---

### 5.3 TPR Methodology Specification by Grade Level

| Parameter | 4.º de Educación Infantil (3-4 anos) | 5.º de Educación Infantil (4-5 anos) | 6.º de Educación Infantil (5-6 anos) |
|---|---|---|---|
| **Metodoloxía Principal** | **TPR de Acción Expandida** *(Action-Expanded)* | **TPR Dramatizado e Narrativo** *(Dramatized & Narrative)* | **TPR Transaccional e Xogos Pragmáticos** *(Transactional Peer-to-Peer)* |
| **Estrutura do Comando** | 2 fases coordinadas unidas pola conxunción *"and"* (e.g. `Stand up and clap hands`, `Touch your nose and sit down`). | Micro-narrativa física de 3-4 accións encadeadas con causa e efecto + sinal de inhibición motriz (`Freeze!`). | Desafíos en parellas guiados por tarxetas visuais icónicas sen texto + preposicións espaciais. |
| **Andamiaxe Pedagóxica** | **Andamiaxe decrecente en 3 etapas**:<br>1. *Modelado sincrónico*: Docente fai o movemento ao tempo que di o comando.<br>2. *Fading*: Docente di a orde, agarda 2s e só xesticula se hai dúbida.<br>3. *Autonomía*: Comando unicamente oral en L3. | **Narración motriz e control inhibitorio**:<br>1. Docente relata a historia motriz.<br>2. Alumnado escenifica co corpo.<br>3. Ante sinal acústica/clave léxica, parada motriz inmediata. | **Intercambio cooperativo entre iguais**:<br>1. Parellas (Emisor e Receptor).<br>2. O emisor amosa tarxeta icónica.<br>3. O receptor executa o desprazamento ou resolución espacial. |
| **Tratamento do Silencio** | **Respecto estrito ao período de silencio fónico**: Cero esixencia de verbalización en L3. O movemento corporal é a única resposta esixida. | **Integración de praxias orofaciais**: Sons onomatopeicos e formas labiais ligados a rimas dactilares sen corrección fonética formal. | **Negociación pragmática**: Verbalización espontánea non forzada entre iguais nas linguas ambientais con comandos motores en L3. |
| **Recursos de Apoio** | Modelado corporal da mestra, obxectos manipulables grandes. | Sons de ambientación acústica (vento, chuvia, campá) e praxias. | **Tarxetas icónicas (cue cards)** con pictogramas de alto contraste sen texto escrito. |

---

### 5.4 Unstructured Natural Galician Materials Specification

| Material | Orixe e Tradición Galega | Propiedades Táctiles e Sensoriais | Restricións de Seguridade e Dimensións | Función na Asemblea / Fase de Calma |
|---|---|---|---|---|
| **Mimbre (Vimbio)** | Cestería tradicional de Galicia (cestos da vendima, aros). | Textura fibrosa, flexible, rugosidade orgánica, lixeira calidez ao tacto. | Piezas/aros de diámetro > 10 cm; cestos con acabado pulido sen puntas afiadas nin estelas. | Cesto de tesouros para acoller os materiais; aros para delimitar espazo persoal na alfombra. |
| **Castañas** | Bosques e soutos do interior de Galicia (castaña autóctona). | Casca satinada lisa e fría; forma redondeada adaptada ao agarre palmar; lixeiro peso. | Tamaño de castaña > 4.0 cm de diámetro; ourizos baleiros suaves sen espiñas duras. | Propiocepción nas mans, rodar polas palmas e brazos para baixar a pulsación e relaxar a musculatura. |
| **Conchas da Ría** | Bateas e praias da Ría de Vigo (vieiras, berberechos, mexillóns). | Contraste entre sucos calcáreos exteriores e interior de nácar ultra-liso e frío; resonancia acústica. | Diámetro mínimo > 5.0 cm; lavadas, fervidas e esterilizadas; bordos arredondados sen cortes. | Discriminación táctil (áspero/suave); achegar á orella para escoitar o eco do mar na fase de calma. |
| **Gasas de Algodón** | Texidos naturais tradicionais de algodón ou muselina lixeira. | Aireada, semitransparente, suave, lixeira caída que reacciona ao sopro e ao aire. | Dimensións 30x30 cm ou 50x50 cm; sen fíos soltos nin cordóns estranguladores; 100% algodón. | Xogos de ocultación e descubrimento (peek-a-boo), control do sopro e respiración lenta ao final da sesión. |

---

### 5.5 Academy Home Micro-routines Specification (Principio Time & Place + Recast)

| Elemento | Especificación Pedagóxica | Regra de Deseño / Implementación |
|---|---|---|
| **Enfoque Ecolóxico** | **Time & Place**: Micro-rutinas de **3 a 5 minutos** integradas nos momentos cotiáns reais do fogar (vestirse, poñer/quitar o calzado, colgar o abrigo ao chegar da escola). | Eliminar todo formato de "deberes escolares" ou tarefas artificiais de mesa. A rutina prodúcese no espazo natural onde ocorre o hábito. |
| **Metodoloxía de Recast** | **Modelado Correctivo Indirecto**: Cando a crianza produce unha expresión incompleta, errónea ou titubeante, o adulto NON corrixe frontalmente. En cambio: valida a mensaxe con afecto e reformula a frase de forma correcta e natural. | **Lista negra pedagóxica no fogar**: Prohibido dicir: *"Mal"*, *"Así non se di"*, *"Repite comigo"*, *"Como se di?"*. Empregar sempre a técnica de reformulación agarimosa con 5 segundos de espera activa. |
| **Estrutura da Cápsula Familiar (4 Partes)** | 1. **Idea clave**: Mensaxe sintética (2 frases) sobre o hábito de autonomía e a linguaxe.<br>2. **Por que importa**: Base neurocognitiva sinxela (como a seguridade emocional favorece a linguaxe).<br>3. **Que facer na casa**: Paso a paso da micro-rutina en 3 minutos.<br>4. **Exemplo cotián**: Guión dialogado que contrapón a corrección frontal negativa fronte ao *recast* positivo. | A cápsula debe cumprir co modelo `ContidoCapsula` (`ideaClave`, `porQueImporta`, `queHacerEnCasa`, `ejemploCotidiano`) con paridade estricta `gl`/`es`. |

---

### 5.6 Clinical Term Blacklist Specification

| Categoría Prohibida | Termos Prohibidos (Galego e Castelán) | Xustificación Pedagóxica | Substituto Pedagóxico Aprobado |
|---|---|---|---|
| **Diagnóstico e Patoloxía** | `trastorno`, `trastornos`, `patoloxía`, `patoloxías`, `patología`, `patologías`, `patolóxico`, `patológico`, `diagnóstico`, `diagnósticos`, `diagnosticar`, `síntoma`, `síntomas`, `sintomatoloxía`, `sintomatología`, `cadro clínico`, `pronóstico`. | A educación infantil non diagnostica nin cataloga; acompaña e estimula o desenvolvemento global. | `ritmo individual de desenvolvemento`, `necesidades individuais`, `etapa evolutiva`, `progresión madurativa`. |
| **Sanitario e Terapéutico** | `paciente`, `pacientes`, `terapia`, `terapias`, `terapéutico`, `terapéutica`, `tratamento` *(agás "tratamento de auga")*, `tratamiento` *(agás "tratamiento de agua")*, `rehabilitación`, `rehabilitar`, `rehabilitador`. | As crianzas na escola non son pacientes de terapia, son escolares en procesos de aprendizaxe compartida. | `crianza`, `nena ou neno`, `escolar`, `alumnado`, `acompañamento educativo`, `estimulación natural`, `xogo guiado`. |
| **Etiquetas de Déficit** | `déficit`, `déficits`, `retraso clínico`, `retrasos clínicos`, `dislalia`, `dislalias`, `dislálico`, `dislexia`, `dislexias`, `disléxico`, `hipoacusia clínica`, `afasia`, `disfasia`. | Risco de estigmatización temperá e patoloxización de variacións fonolóxicas e madurativas normativas. | `desenvolvemento fonolóxico`, `adquisición da fala`, `discriminación auditiva`, `apoio comunicativo`. |
| **Cribados Médicos** | `criba`, `cribado`, `cribados`, `cribaxe`, `screening`. | Procedementos clínicos que non corresponden ao ámbito docente da asemblea matinal. | `observación atenta no aula`, `recollida cualitativa de fitos`, `escoita activa`. |
| **Marcadores Incompletos** | `TODO`, `TBD`, `PLACEHOLDER`, `PENDIENTE`, `PENDENTE`, `LOREM IPSUM` *(con `caseSensitive: true`)*. | Prevén textos incompletos en publicación sen bloquear palabras válidas como "todo" (all). | Textos completos e revisados bilingües. |

---

### 5.7 Vertical Slice Curricular Pilot: Setembro / Septiembre

**Título da Unidade**: *"Setembro: Acollida, espazos escolares e novas rutinas"*  
**ID Canónico**: `segundo_ciclo.setembro.01`  
**Tramo Curricular**: `3-6` (Segundo Ciclo de Educación Infantil)  
**Normativa**: `Decreto 150/2022` | **Ciclo**: `segundo_ciclo_3_6`

#### Nivel 1: 4.º de Infantil (3-4 anos) — Acción Expandida
- **Centro de Interese**: A alfombra da asemblea e as rutinas de saúdo.
- **Fase 1 (Opening 1:30)**: Lúa saúda co rabo: *"Hello, Lúa! Wave hello!"*.
- **Fase 2 (Rhythm 2:00)**: Palmas suaves nas pernas marcando pulso a 72 BPM: *"Clap, tap, clap, tap"*.
- **Fase 3 (Core TPR 4:30)**:
  - Comando 1: *"Stand up and clap hands"* (Modelado sincrónico).
  - Comando 2: *"Walk to the circle and sit down"* (Fading a 2 segundos).
  - Comando 3: *"Touch your knees and freeze!"* (Execución autónoma motriz sen verbalización forzada).
- **Fase 4 (Calm 2:00)**: Pano de gasa suave (30x30 cm). Cubrir as mans, soprar amodo e deixalo flotar para relaxar.

#### Nivel 2: 5.º de Infantil (4-5 anos) — Dramatizado e Narrativo
- **Centro de Interese**: A mochila máxica e o camiño á escola de Vigo.
- **Fase 1 (Opening 1:30)**: Círculo de confianza. Lúa esperta na mochila: *"Good morning, backpack!"*.
- **Fase 2 (Rhythm 2:00)**: Rima dactilar con praxias: *"Pitter-patter rain... Click-clack shoes"* (movemento dos dedos e son de lingua).
- **Fase 3 (Core TPR 4:30)**:
  - Micro-narrativa: *"Put on your backpack (lift arms), zip it up (pull fingers up), walk to the bus (stomp feet)... FREEZE! (stop immediate al oír la campana)"*.
  - Variación de velocidade: Camiñar a modiño con auga suave vs correr e parar en seco co trono.
- **Fase 4 (Calm 2:00)**: Castañas galegas lisas. Soster unha castaña en cada man, sentir o seu peso e temperatura, e rodala pola palma mentres respiramos fondo.

#### Nivel 3: 6.º de Infantil (5-6 anos) — Transaccional e Pragmático
- **Centro de Interese**: O recanto dos abrigos e a cooperación entre iguais.
- **Fase 1 (Opening 1:30)**: Saúdo en parellas ollándose aos ollos: *"Hello, partner! High five!"*.
- **Fase 2 (Rhythm 2:00)**: Compás rítmico cruzado (palma co compañeiro en espello).
- **Fase 3 (Core TPR 4:30)**:
  - Dinámica de parellas con **tarxeta icónica sen texto** (debuxo dun perchero amarelo cun abrigo).
  - Crianza A sostén a tarxeta e sinala o camiño con xestos.
  - Crianza B segue a indicación corporal: *"Walk to the yellow peg and hang the coat"*.
  - Inversión de roles coa tarxeta da botella de auga.
- **Fase 4 (Calm 2:00)**: Cesto de vimbio e cunchas de vieira da Ría de Vigo. Colocar con coidado cada cuncha dentro do cesto dicindo baixiño *"Inside... soft, calm"*.

#### Módulo Academy / Hogar: Micro-rutina de Setembro
- **Título**: *"A percha máxica dos abrigos"*
- **Nicho temporal**: 3 minutos ao chegar a casa despois da escola.
- **Técnica de Recast**:
  - Situación: A crianza solta o abrigo no chan e di: *"Abrigo chan!"*.
  - Corrección prohibida: *"Non tires o abrigo, colle e pona na percha"*.
  - Recast positivo aprobado: *"Ai, o abrigo quere durmir na súa percha! Imos axudarlle: 'Up on the hook, zip!'. Mira que ben colgado quedou!"*.

---

## 6. Caveats

1. **Validador Existente Require Ampliación**:
   - `ContentValidator.checkCurricularAlignment` actualmente require de maneira estrita `ciclo == CurricularReference.ciclo03` (`primeiro_ciclo_0_3`). Para aceptar o Segundo Ciclo sen romper o Primeiro Ciclo, débese permitir `segundo_ciclo_3_6` e o conxunto de criterios `CA1.1` a `CA3.3`.
2. **Sensibilidade do Patrón Placeholder**:
   - En `content_validator.dart:60`, `placeholderPattern` usa `caseSensitive: false`, o que bloquea calquera uso lexítimo da palabra galega/castelá "todo". Debe cambiarse a `caseSensitive: true` para evitar falsos positivos nos novos textos.
3. **Sen Pantallas para o Alumnado**:
   - As interfaces desenvolvidas para as asembleas de 3-6 anos son estritamente ferramentas de trastienda (backstage) para o profesorado. Non debe implementarse ningunha interacción táctil nin mecánica de videoxogo pensada para que os nenos toquen o teléfono/tableta.

---

## 7. Conclusion

A minería de especificacións para o Segundo Ciclo (3-6 anos) de «Descubre con Lúa · Edición Vigo» establece unha base arquitectónica e pedagóxica pechada e verificable:
1. **Curricular**: Cumprimento estrito do Decreto 150/2022 de Galicia (Áreas 1, 2, 3) baixo o ciclo `segundo_ciclo_3_6` e cursos 4.º, 5.º e 6.º de EI.
2. **Asemblea**: Secuencia canónica de 4 fases temporizadas ao segundo (Total 10:00 min: 1:30, 2:00, 4:30, 2:00).
3. **Metodoloxía TPR**: Diferenciación neurocognitiva progresiva (Acción Expandida en 4.º con período de silencio, Dramatizado/Narrativo en 5.º con freeze e praxias, e Transaccional en 6.º con tarxetas icónicas sen texto).
4. **Materiais Naturais**: Mimbre, castañas, conchas e gasas, con restricións estritas de seguridade (mínimo 4 cm, sen bordos cortantes).
5. **Fogar (Academy)**: Micro-rutinas de 3-5 minutos e técnica de modelado indirecto (*recast*), eliminando a avaliación frontal.
6. **Lista Negra Clínica**: Blindaxe absoluta contra termos médicos/patolóxicos.

O conxunto de especificacións queda listo para a implementación dos modelos de datos, validadores e pantallas polo equipo.

---

## 8. Verification Method

Para verificar de forma independente e empírica as afirmacións deste informe:
1. **Inspección de código existente**:
   - `view_file` en `lib/data/validators/content_validator.dart` (liñas 48-63 para a lista negra e placeholders, liñas 270-326 para o validador curricular).
   - `view_file` en `lib/data/models/curricular_model.dart` (liñas 32-68 para os códigos do primeiro ciclo).
   - `view_file` en `test/data/clinical_terms_blacklist_test.dart` (liñas 54-98 e 132-150 para as comprobacións da lista negra e exención marítima).
2. **Verificación de regras de negocio**:
   - Comprobar que a duración das 4 fases da asemblea (90s + 120s + 270s + 120s) suma exactamente 600 segundos (10 minutos).
   - Comprobar que a expresión regular da lista negra detecta correctamente termos como `dislalia` ou `terapia` e exime `tratamento de auga`.
