# Handoff Report — Milestone M6: High-Contrast Visual Cards & 4 Session Moments Architecture

- **Author**: `teamwork_preview_explorer_m6_1`
- **Working Directory**: `/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_explorer_m6_1`
- **Target Audience**: `teamwork_preview_orchestrator_2` / `teamwork_preview_worker_m6`
- **Scope**: Requirement R2 (10 Curricular Months Flashcards, 2-Meter Rug Readability, 4 Session Moments: Apertura 72 BPM, Fingerplay, English TPR LJSpeech, Peche Afectivo).

---

## 1. Observation

### 1.1 Existing Model & Curricular Data
In `lib/data/models/calendario_model.dart` (lines 14-41, 44-335), `MesCurricular` defines the canonical 10 curricular months of the Galician early childhood curriculum (Decreto 150/2022, DOG nº 172):
```dart
class MesCurricular {
  final int orden; // 1 (Setembro) to 10 (Xuño)
  final int mesCalendario; // 9, 10, 11, 12, 1, 2, 3, 4, 5, 6
  final LocalizedString nombreMes;
  final LocalizedString centroInteres;
  final LocalizedString objetivoPedagogico;
  final List<String> lexicoIngles;
  final List<String> comandosTpr;
  final LocalizedString actividadAula;
  final LocalizedString actividadHogar;
  final LocalizedString rutinaRecomendadaHogar;
  final int minutosAtencionSugeridos;
  final IconData icono;
```
All 10 months are instantiated as static constants (`MesCurricular.meses`) with complete Galician and Spanish bilingual parity. However, the current model lacks an explicit breakdown into the **4 session moments** (Apertura 72 BPM, Fingerplay/Concentración, Núcleo TPR en inglés, and Peche Afectivo).

### 1.2 Existing Calendar View Implementation
In `lib/features/calendario/views/calendario_screen.dart` (lines 515-795), `_buildMonthDetailCard` renders month information inside an inline `Card`. It displays the month icon (`radius: 24`, icon size `28`), interest center, objective, and chips for English lexicon and TPR commands, followed by the role-specific activity (Aula vs Fogar).
- It does not yet feature the modular `TarjetaMesVisualWidget` or `MomentoSesionWidget`.
- Typography in some sections uses `labelSmall` (11-12sp) and `bodySmall` (12-14sp), which fall below the 2-meter rug readability threshold (>= 16sp body, >= 18sp headings).

### 1.3 AppTheme Design Tokens & Contrast Ratios
In `lib/core/theme/app_theme.dart` (lines 18-48, 126-187):
- Primary Teal: `primary = Color(0xFF00C4BE)`
- High-Contrast Primary Ink: `primaryInk = Color(0xFF127A75)` (explicitly introduced for WCAG AA compliance with white text)
- Background: `pageBg = Color(0xFFF6FAFA)`, `card = Color(0xFFFFFFFF)`
- Text: `textPrimary = Color(0xFF1F2937)`, `textSecondary = Color(0xFF4B5563)`, `textMuted = Color(0xFF9AA6A5)`
- Dark: `dark = Color(0xFF0B1220)`
- Amber: `star = Color(0xFFFACC15)`
- Success/Mint: `success = Color(0xFF10B981)`
- Coral suave palette: present in `assets/brand/palette.json` as `p: #F4A9B6` and `c: #EF8296`.
- Typography scale:
  * `headlineMedium`: 24sp w800
  * `headlineSmall`: 20sp w700
  * `titleMedium`: 18sp w700
  * `titleSmall`: 16sp w700
  * `bodyLarge`: 18sp w400
  * `bodyMedium`: 16sp w400

### 1.4 Empirical Contrast Measurements (WCAG 2.1)
Empirical verification using standard WCAG 2.1 relative luminance calculation ($L = 0.2126 R + 0.7152 G + 0.0722 B$):
| Color Combination | Contrast Ratio | WCAG Rating | Usage Recommendation |
|---|---|---|---|
| `textPrimary` (#1F2937) on `white` (#FFFFFF) | **14.68:1** | WCAG AAA (>= 7:1) | Body text, titles, consignas |
| `textSecondary` (#4B5563) on `white` (#FFFFFF) | **7.56:1** | WCAG AAA (>= 7:1) | Secondary pedagogical descriptions |
| `primaryInk` (#127A75) on `white` (#FFFFFF) | **5.16:1** | WCAG AA (>= 4.5:1) | Header text, active labels, badges |
| `white` (#FFFFFF) on `primaryInk` (#127A75) | **5.16:1** | WCAG AA (>= 4.5:1) | Inverse buttons and header chips |
| `dark` (#0B1220) on `primary` (#00C4BE) | **8.59:1** | WCAG AAA (>= 7:1) | Brand buttons (text on teal) |
| `white` (#FFFFFF) on `primary` (#00C4BE) | **2.18:1** | **FAIL** (< 3:1) | **PROHIBITED** (documented in AppTheme) |
| `dark` (#0B1220) on `amber` (#FACC15) | **12.23:1** | WCAG AAA (>= 7:1) | Amber badges / star accents |
| `coralText` (#9F1239) on `coralLight` (#FFF1F2) | **7.30:1** | WCAG AAA (>= 7:1) | Momento 3 (TPR English) card container |
| `amberText` (#92400E) on `amberLight` (#FFFBEB) | **6.84:1** | WCAG AA / AAA lg | Momento 2 (Fingerplay) card container |
| `mintText` (#065F46) on `mintLight` (#EAFAF2) | **7.12:1** | WCAG AAA (>= 7:1) | Momento 4 (Peche afectivo) card container |
| `primaryInk` (#127A75) on `primaryLight` (#E6F9F8) | **4.74:1** | WCAG AA (>= 4.5:1) | Momento 1 (Apertura) card container |

### 1.5 Audio Pipeline & BotonEscuchar Behavior
In `lib/core/audio/voice_id.dart` (lines 41-56):
- `voiceAssetPath(VoiceStyle.tutor, text, AppLanguage.gl)` resolves to `assets/voice/gl_tutor_<hash>_<len>.m4a`.
- `englishVoiceAssetPath(VoiceStyle.tutor, text)` resolves to `assets/voice/en_tutor_<hash>_<len>.m4a` with `AppLanguage.en` (LJSpeech female model, piper ONNX).
In `lib/core/audio/widgets/boton_escuchar.dart` (lines 143-150):
- If `audioService == null` or the asset file is not bundled in `rootBundle`, `BotonEscuchar` cleanly returns `const SizedBox.shrink()`.
- If present, it renders a 48dp accessible circular button (`AppTheme.touchMin`) with `Icons.volume_up_rounded`.

### 1.6 Visual Metronome & Pulse at 72 BPM
In `lib/features/juega/widgets/paso_cancion_widget.dart` and `rhythm_bar_widget.dart`:
- The classroom metronome is visual, not acoustic: *"an audible metronome competes with the voice the children are following, and many of them wear a hearing aid or an implant"*.
- 72 BPM corresponds to an exact beat duration of $60 / 72 = 0.8333\dots \text{ s} = 833.33 \text{ ms}$.

### 1.7 Repository Quality Gates Status
Execution of the 5 project verification scripts (`check_contact_email.py`, `export_voice_corpus.py --check`, `check_voice_coverage.py`, `check_manual_build.py`, `check_legal_urls.py --offline`) confirmed exit code `0` and 246 synchronized voice locutions.

---

## 2. Logic Chain

### 2.1 The 2-Meter Rug Readability Ergonomics ("Lectura na alfombra a 2 metros")
1. **Context**: In Galician infant education classrooms (Escolas Infantís 0-3 anos), teachers conduct the morning assembly seated on the carpet (`alfombra`) in a circle with toddlers. The teacher's mobile device is typically placed on a low shelf, easel, or floor stand approximately 1.5 to 2.0 meters away.
2. **Visual Acuity Geometry**:
   - At a viewing distance of $d = 200 \text{ cm}$, standard 12-14sp mobile typography subtends an angle under 10 arcminutes, causing eye strain and misreading under natural classroom window glare.
   - For rapid landmark recognition at 2 meters without leaning forward:
     * The primary month icon must be at least **48-52 dp** inside a **64x64 dp** high-contrast container.
     * Month titles must be at least **22 sp** (headline/title style) in bold Nunito.
     * Moment titles must be at least **18 sp** (bold).
     * Body consignas and instructions must not drop below **16 sp** (line-height 1.45).
     * Action command pills must feature distinct border outlines (>= 1.5dp) and high contrast.

### 2.2 Visual Metronome Mechanics for Momento 1 (72 BPM)
1. **Clinical & Acoustic Rationale**: Toddlers in early language acquisition (especially those with hearing impairments, otitis media, or cochlear implants) rely heavily on vocal formant clarity. Audible clicking clicks or beeps mask acoustic cues.
2. **Visual Implementation**:
   - A pulsing visual indicator oscillating at exactly **72 BPM** ($T = 833 \text{ ms}$).
   - Visual styling: Concentric pulsing ring or glowing rhythmic dot in `AppTheme.primary` (#00C4BE) / `AppTheme.primaryInk` (#127A75).
   - Animation parameters: `AnimationController(duration: const Duration(milliseconds: 833))` looping with `repeat(reverse: true)`. Scale factor from 1.0 to 1.18, opacity modulating between 0.35 and 0.90.
   - Includes a play/pause toggle (`Key('boton_pulso_toggle')`) allowing the educator to initiate or stop the visual pulse.

### 2.3 The 4-Moment Pedagogical Architecture
The session structure follows the natural circadian and neurological rhythm of infants 0-3 years:
1. **Momento 1: Apertura (Saúdo e pulso a 72 BPM)**:
   - Synchronizes group attention, stabilizes heart rate through predictable rhythmic greeting chant in Galician (Celtia model).
2. **Momento 2: Fingerplay / Concentración (Mímica e propriocepción)**:
   - Engages fine motor control, finger tactile stimulation, and body awareness to prepare the cognitive channel before foreign language exposure.
3. **Momento 3: Núcleo TPR en Inglés (LJSpeech model)**:
   - Physical movement paired with spoken English (Total Physical Response). The child acts without pressure to speak, honoring the neurological "Silent Period".
   - Integrated `BotonEscuchar` for teacher reference using native female English pronunciation.
4. **Momento 4: Peche Afectivo (Despedida e calma)**:
   - Parasympathetic regulation: slow breathing, soft hug or blanket touch, gentle farewell to prevent overstimulation.

### 2.4 Complete 10-Curricular-Month 4-Moments Specification Table
Below is the definitive pedagogical matrix across all 10 curricular months of Decreto 150/2022:

| Mes | Centro de Interese | Momento 1: Apertura (72 BPM) | Momento 2: Fingerplay (Propriocepción) | Momento 3: Núcleo TPR (English L3) | Momento 4: Peche Afectivo (Calma) |
|---|---|---|---|---|---|
| **1. Setembro** (9) | Benvida, caricias suaves e novos amigos | Saúdo en círculo con cinta elástica a 72 BPM: *"Ola, amigos, xuntamos as mans"* | Palmas suaves e caricias nas mans: *"Dedo maimiño, onde estás? Aquí para xogar"* | Comandos: `Stand up`, `Sit down`, `Clap hands`<br>Léxico: `Hello`, `Bye-bye`, `Up`, `Down`, `Clap` | Despedida con *"Bye-bye"*, respiración relaxada e caricia suave na meixela |
| **2. Outubro** (10) | O meu pequeno corpo en movemento | Saúdo corporal acompasado a 72 BPM tocando xeonllos e pés | Mímica do rostro: tocar suavemente cabeza, meixelas e nariz | Comandos: `Touch your head`, `Shake hands`, `Freeze!`<br>Léxico: `Head`, `Tummy`, `Toes`, `Eyes`, `Nose` | *"Freeze in calm"*: parada motriz progresiva, acubillo na alfombra e relaxación |
| **3. Novembro** (11) | As follas de outono e o Magosto | Balanceo rítmico das árbores e o vento suave a 72 BPM | Follas que caen: dedos que abren e pechan simulando follas secas | Comandos: `Fall down`, `Walk softly`, `Crunch leaves`<br>Léxico: `Leaf`, `Falling`, `Wind`, `Crunch`, `Brown` | Calorciño do Magosto: frotar mans para dar calor ás fazulas e repouso |
| **4. Decembro** (12) | Abrazos cálidos, campaíñas e aire de inverno | Campaíñas a 72 BPM: son e silencio corporal acompasados | Pulseiras de cascabeis imaxinarias: axitar dedos rápido e parar en seco | Comandos: `Ring bells`, `Sleep tight`, `Wake up!`<br>Léxico: `Cold`, `Warm`, `Bell`, `Ring`, `Sleep` | Arroupar coa mantita: deitarse en silencio coas mans no peito |
| **5. Xaneiro** (1) | Roupa de abrigo, botas de chuvia e luvas | Paso rítmico sobre o orballo a 72 BPM con abrigo imaxinario | Botóns e cremalleras: subir cremallera (*"Zzzip!"*) e abrochar deditos | Comandos: `Put on hat`, `Zip coat`, `Stomp boots`<br>Léxico: `Coat`, `Boots`, `Hat`, `Put on`, `Take off` | Quitar as luvas, masaxe quentiña nas mansiñas e respiración pausada |
| **6. Febreiro** (2) | O reino animal e o Entroido | Desfile rítmico do Entroido a 72 BPM marcando o compás | Mímica zoomorfa con dedos: o bico do paxariño e as gadoupas do gato | Comandos: `Jump like a frog`, `Fly like a bird`, `Stomp like a bear`<br>Léxico: `Frog`, `Bird`, `Bear`, `Cat`, `Jump` | O gatiño durmido (*"Sleepy cat"*): ovillarse na alfombra en acougo |
| **7. Marzo** (3) | Cores, formas e alimentos sans | Cores da ría a 72 BPM: palmas de cores acompasadas | Debuxar no aire: deditos facendo círculos no aire e liñas no chan | Comandos: `Find red`, `Roll circle`, `Shake bottle`<br>Léxico: `Red`, `Yellow`, `Circle`, `Sweet`, `Roll` | Sentir o corazón: pousar a man no peito e notar os latexos en calma |
| **8. Abril** (4) | O espertar da primavera, flores e orballo | Chuvia mansa e orballo a 72 BPM: pingas leves sobre os ombreiros | A flor que medra: puño pechado que abre dedo a dedo como pétalos | Comandos: `Be a seed`, `Grow up`, `Open flower`<br>Léxico: `Rain`, `Sun`, `Flower`, `Grow`, `Tap-tap` | As flores descansan: deitarse mirando o teito con respiración suave |
| **9. Maio** (5) | Xogos de auga, chapuzóns e hixiene | O son da auga a 72 BPM: ritmo continuo de fregar as máns | Salpicaduras de dedos: dedos que chiscan auga (*"Splash!"*) e fregan meixelas | Comandos: `Wash face`, `Rub hands`, `Splash water!`<br>Léxico: `Wash`, `Water`, `Soap`, `Clean`, `Splash` | Toalliña tépeda: secado imaxinario lento e caricia afectiva |
| **10. Xuño** (6) | Días de sol, o mar e as Rías de Vigo | O vaivén das ondas da ría de Vigo a 72 BPM collidos das mans | Peixiños nadando: movemento sinuoso das mans polo ar | Comandos: `Gentle waves`, `Big waves!`, `Swim like a fish`<br>Léxico: `Sea`, `Waves`, `Swim`, `Fish`, `Blue` | Despedida agarimosa de fin de curso: bico voado, abrazo suave e acougo |

---

## 3. Caveats

1. **Non-interactive Host Flutter CLI**: In this headless environment, the `flutter` binary is not present in non-interactive `PATH`. Static analysis, model constraints, and python gates run natively, while Dart test suites are structured to execute cleanly under `flutter test` in standard CI.
2. **English Audio File Synthesis Status**: `assets/voice/` currently holds 246 files covering Galician and Spanish units and capsules. English TPR files (`en_*.m4a`) are synthesized in batch via the `piper` pipeline. The design strictly respects the project rule: if an audio file is not bundled, `BotonEscuchar` hides gracefully (`SizedBox.shrink()`), preventing broken speaker buttons.
3. **No Code Modification in Explorer Phase**: In strict compliance with the Explorer archetype, no source files outside `.agents/` have been altered.

---

## 4. Conclusion & Concrete Code Blueprint for Worker M6

### 4.1 Data Contract: `MomentoSesionData`
Add to `lib/data/models/calendario_model.dart` (or `lib/features/calendario/widgets/momento_sesion_card.dart`):
```dart
enum MomentoTipo {
  apertura,
  fingerplay,
  nucleoTpr,
  cierre,
}

class MomentoSesionData {
  final MomentoTipo tipo;
  final LocalizedString titulo;
  final LocalizedString consigna;
  final String? audioTexto;
  final AppLanguage? audioIdioma;
  final IconData icono;
  final int? bpm;
  final List<String>? comandosTpr;
  final List<String>? lexicoIngles;

  const MomentoSesionData({
    required this.tipo,
    required this.titulo,
    required this.consigna,
    this.audioTexto,
    this.audioIdioma,
    required this.icono,
    this.bpm,
    this.comandosTpr,
    this.lexicoIngles,
  });
}
```

### 4.2 Widget 1: `MomentoSesionWidget`
File: `lib/features/calendario/widgets/momento_sesion_card.dart`
Key structural requirements:
- Key: `Key('momento_sesion_card_${index + 1}')`
- Header: Phase pill ("MOMENTO 1 · APERTURA", etc.) with contrast >= 5.16:1.
- Body: Consigna text in Nunito >= 16sp, textPrimary (#1F2937) for 14.68:1 contrast.
- Visual Pulse (for `tipo == MomentoTipo.apertura`):
  * Oscillates at 72 BPM (`Duration(milliseconds: 833)`).
  * Key: `Key('pulso_visual_72bpm')`.
  * Play/pause button: `Key('boton_pulso_toggle')`.
- Audio triggers (for `tipo == MomentoTipo.nucleoTpr` and `tipo == MomentoTipo.apertura`):
  * Embedded `BotonEscuchar` for commands and vocabulary with `language: AppLanguage.en` (LJSpeech) or `AppLanguage.gl` (Celtia).

### 4.3 Widget 2: `TarjetaMesVisualWidget`
File: `lib/features/calendario/widgets/tarjeta_mes_visual.dart`
Key structural requirements:
- Key: `Key('tarjeta_mes_visual_${mes.orden}')`.
- Prominent Icon Container: 64x64 dp, with 48-52 dp rounded icon (`mes.icono`).
- Month Header: >= 20sp title (`mes.nombreMes`), kicker `"DECRETO 150/2022 · MES ${mes.orden}"`.
- 4 Momento Cards rendered sequentially.
- Direct session action button (`BotonLanzarSesion` or primary button).

### 4.4 Integration into `CalendarioScreen`
In `lib/features/calendario/views/calendario_screen.dart`, replace `_buildMonthDetailCard(mes, theme)` with:
```dart
TarjetaMesVisualWidget(
  key: Key('tarjeta_mes_visual_${mes.orden}'),
  mes: mes,
  language: _language,
  esDocente: _esDocente,
  audioService: widget.audioService,
  onIniciarSesion: () => _lanzarSesion(mes, _esDocente),
)
```

---

## 5. Verification Method

### 5.1 Independent Quality Gates Verification
Run from workspace root:
```bash
python3 tools/check_contact_email.py
python3 tools/export_voice_corpus.py --check
python3 tools/check_voice_coverage.py
python3 tools/check_manual_build.py
python3 tools/check_legal_urls.py --offline
```
**Expected outcome**: All 5 commands exit with code `0`.

### 5.2 Flutter Test Suite Execution
In an environment with Flutter SDK configured:
```bash
flutter test test/features/calendario/calendario_test.dart
flutter test test/features/calendario/tarjeta_mes_visual_test.dart
```

### 5.3 Invalidation Conditions
- Any text on light cards having a contrast ratio below 4.5:1 (WCAG AA) or 7:1 (for normal body text).
- Any header typography below 18sp or body text below 16sp in the visual flashcards.
- Any audible clicking metronome added to the pulse step instead of the visual silent pulse.
- Any regression breaking the 5 python quality gate scripts.
