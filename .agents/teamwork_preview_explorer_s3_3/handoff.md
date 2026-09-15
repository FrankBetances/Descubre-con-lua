# Handoff Report — UI/UX & Integration Architecture for Segundo Ciclo (3-6 Years)

- **Agent**: teamwork_preview_explorer_s3_3 (UI/UX & Integration Explorer)
- **Role**: Explorer (Read-only investigation & architecture design)
- **Parent Conversation ID**: `e7633361-cefb-4427-91ff-c3fbb93625fc`
- **Working Directory**: `/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_explorer_s3_3`
- **Date**: 2026-09-14T13:21:00Z

---

## 1. Observation

Direct observations from inspecting the codebase, configuration, and documentation:

1. **Follow-up Requirements (`ORIGINAL_REQUEST.md:94-161`)**:
   - `ORIGINAL_REQUEST.md:120-125` (R2. Asistente de Aula para el Docente): "Desarrollar la pantalla y componentes del flujo guiado de asamblea matinal orientados exclusivamente al docente (herramienta de trastienda / backstage, garantizando cero exposición de pantallas a los escolares). Interfaz de un vistazo (glanceable UI) en modo oscuro con tipografía de alto contraste (textos clave >= 24sp) legible a dos metros de distancia. Controles táctiles de gran formato para avance de fases, temporizador discreto por fase y gestión de audio ambiental/pulsos con fundidos suaves (fade-in / fade-out automáticos). Selector de nivel (4.º, 5.º, 6.º de Infantil) integrado de manera continuista en la navegación principal sin romper el flujo del primer ciclo (0-3 años)."
   - `ORIGINAL_REQUEST.md:101-109`: 4-phase canonical session (8-10 min total): Opening / Greeting (1:30 min), Movement & Rhythmic Focus (2:00 min), Core TPR Challenge (4:30 min), Calm & Transition Out (2:00 min).
   - `ORIGINAL_REQUEST.md:126-132`: Vertical slice pilot month ("Septiembre: Acollida, espazos escolares e novas rutinas") differentiated for 4º (Expanded Action), 5º (Dramatized & Freeze), and 6º (Peer-to-peer transactional). Academy home extension with indirect corrective modeling (recast) without frontal inhibitory testing.
   - `ORIGINAL_REQUEST.md:133-138`: Zero network dependencies, 100% offline, zero child gamification in teacher UI.

2. **Existing Theme & Dark Mode State (`lib/core/theme/app_theme.dart:14-292`)**:
   - `app_theme.dart:34`: `static const Color dark = Color(0xFF0B1220);` already exists in tokens.
   - `app_theme.dart:18-35`: Brand palette defined (`primary = Color(0xFF00C4BE)`, `primaryDark = Color(0xFF00A39E)`, `primaryInk = Color(0xFF127A75)`, `card = Color(0xFFFFFFFF)`).
   - `app_theme.dart:102-290`: Only `ThemeData get lightTheme` is currently implemented. There is currently no dedicated backstage dark theme (`AppTheme.darkBackstageTheme` or `AppTheme.darkTheme`).
   - `app_theme.dart:76`: `static const double touchMin = 48.0;` defined as Android accessible touch minimum.

3. **Current Assembly Screen for 1st Cycle (`lib/features/juega/views/asamblea_guiada_screen.dart:1-395`)**:
   - `asamblea_guiada_screen.dart:30-56`: `AsambleaGuiadaScreen` is hardcoded to 6 phases (`_titulosPasosGl` / `_titulosPasosEs`: Canción a pulso, Cuento guiado, Preguntas graduadas, Exploración sensorial, Matemáticas temperás, Ponte á casa).
   - `asamblea_guiada_screen.dart:111-121`: `_nextPaso()` advances step 0 to 5 and explicitly pauses audio when moving away from Phase 1 (`if (_currentPaso == 0 && _audioService.isPlaying) _audioService.pause();`).
   - `asamblea_guiada_screen.dart:137-145`: Calls `premios?.registrar(Perfil.docente, EventoPremio.asamblea)` and `calendario?.registrarAula()`.
   - `asamblea_guiada_screen.dart:283-324`: Renders an alert banner `"Asistente docente · Móbil fóra da vista · 5-8 min máx."` with static `~1-2 min` badge. There is no active countdown timer.

4. **Offline Audio Service & Android Native Channel (`lib/core/audio/` & `android/app/src/main/kotlin/com/earlify/descubreconlua/MainActivity.kt`)**:
   - `offline_audio_service.dart:7-28`: Contract defines `playAsset(String assetPath)`, `pause()`, `stop()`, `isPlayingStream`, `isPlaying`, `currentAssetPath`, and `dispose()`. It lacks volume modulation (`setVolume`).
   - `MainActivity.kt:31-61`: MethodChannel `"com.earlify.descubreconlua/audio"` supports `"play"`, `"pause"`, `"stop"`, `"release"`, `"filesDir"`.
   - `MainActivity.kt:82-97`: Uses native `android.media.MediaPlayer`.

5. **Existing Navigation Architecture (`lib/main.dart:107-196`)**:
   - Named routes: `/` (`WelcomeScreen`), `/creditos` (`CreditsScreen`), `/home` (`HomeScreen`), `/academy` (`BloquesListScreen`), `/juega` (`UnidadesListScreen`), `/calendario` (`CalendarioScreen`), `/guia-atencion` (`GuiaAtencionScreen`).
   - Generated routes: `/academy/capsula` -> `CapsulaDetailScreen`, `/juega/asamblea` -> `AsambleaGuiadaScreen`.
   - `HomeScreen` cards (`main.dart:317-383`): Currently shows `Juega con Lúa · Aula` (0-3), `Academy · Familias`, and `Calendario Escola · Fogar`.

6. **Existing Unit Selector & Age Filter (`lib/features/juega/views/unidades_list_screen.dart:51-72, 214-232`)**:
   - `UnidadesListScreen` filters by `_selectedAgeFilter`: `'todas'`, `'0-2'`, `'2-3'`.
   - Units are fetched via `repository.getAllUnidades()` or `repository.getUnidadesByTramoEtario(...)`.

7. **Existing Academy & Attention Guide (`lib/features/academy/views/`)**:
   - `bloques_list_screen.dart:171-222`: Renders header, `LuaGameStrip`, two featured cards (`GuiaAtencionScreen` and `CalendarioScreen`), and list of 5 developmental blocks.
   - `guia_atencion_screen.dart:96-202`: Features 5 age brackets strictly covering 0-3 years (`0 a 6 meses`, `6 a 12 meses`, `12 a 18 meses`, `18 a 24 meses`, `24 a 36 meses`). Does not yet cover 3-6 years or the September micro-routine recast guidance.

8. **Existing Test Suites & Coverage (`test/features/juega/` and `test/features/academy/`)**:
   - `juega_flow_test.dart:179-271` & `asamblea_adversarial_test.dart:140-452`: Test navigation 1..6, button disabled boundaries, rapid back-and-forth transitions, audio auto-pause when leaving Phase 1, audio release on pop without disposing injected service, age filter segregation, and prominent non-dismissible safety alerts.

---

## 2. Logic Chain

1. **Backstage UI Mode & Teleprompter Requirement**:
   - From Observation 1 & 2, the teacher uses the device in the classroom at approximately 2 meters distance from the circle. Bright white UI distracts young children and breaks circle eye-contact.
   - Therefore, a dedicated dark backstage theme (`AppTheme.darkBackstageTheme`) must be established with background `AppTheme.dark` (`#0B1220`), card surface `#131D31`, text colors `#FFFFFF` / `#F8FAFC`, and accent `#00C4BE`.
   - For glanceability at 2 meters, key L3 commands and physical actions must have `fontSize >= 26.0sp` (exceeding the >= 24sp requirement), bold/extrabold font weight (`w800`), and generous line height (`1.3`).
   - Touch targets for backstage controls (next, timer, audio) must have a minimum touch target height of `64.0dp` (well above the standard `48.0dp`) so teachers can operate them with an outstretched arm or glance-tap without squinting.
   - Children's gamification elements (`LuaPixel`, `LuaGameStrip`, medals, confetti, reward sounds) must be strictly omitted from the backstage assembly flow.

2. **Discrete Phase Timer & 4-Phase Navigation**:
   - From Observation 1 & 3, the 2nd cycle assembly has 4 canonical phases:
     - Phase 1: Opening / Greeting (`01:30`, 90 seconds)
     - Phase 2: Movement & Rhythmic Focus (`02:00`, 120 seconds)
     - Phase 3: Core TPR Challenge (`04:30`, 270 seconds)
     - Phase 4: Calm & Transition Out (`02:00`, 120 seconds)
     - Total: 10:00 minutes.
   - In early childhood classrooms, alarms, chimes, or beeps startle children and ruin concentration.
   - Therefore, `BackstagePhaseTimerWidget` must operate silently:
     - Countdown display in large tabular monospace format (`34sp` font size).
     - Color transitions from turquoise (`#00C4BE`) during normal countdown to warm amber (`#F59E0B`) upon reaching threshold or overtime, counting gently upward (`+00:15`), with zero acoustic alarms.
     - Single tap to pause/resume.
     - Advancing to next phase resets the timer to that phase's target duration automatically.
   - The stepper must display 4 distinct segments (`BackstagePhaseStepper`) with linear progress, active phase highlighting, and allow direct tap-jumping between phases if the educator needs to adapt in real time.

3. **Audio Controls & Fade-in / Fade-out Compatibility**:
   - From Observation 4, `OfflineAudioService` handles offline assets (`playAsset`, `pause`, `stop`).
   - Abrupt audio stops/starts startle young children. Soft fades (800ms - 1200ms) provide smooth sensory transitions.
   - Because `MainActivity.kt` and `OfflineAudioService` currently lack volume modulation, we propose an architectural pattern:
     - `FadeAudioCoordinator`: Wraps `OfflineAudioService`.
     - In Dart: Supports volume ramping if platform channel supports `setVolume` or graceful standard playback fallback.
     - Auto-Fade on Phase Change: When the teacher advances from Phase 1 to Phase 2 (or any phase transition), currently playing audio fades out over 800ms before pausing/stopping.
     - Disposal Safety: On screen pop, audio stops immediately and the service is freed without disposing an injected service instance (adhering to adversarial tests).

4. **Continuous Level Switcher (4.º, 5.º, 6.º Infantil) & Non-destructive Navigation**:
   - From Observation 5 & 6, existing routes and tests depend heavily on `UnidadesListScreen` with 0-2 and 2-3 age bands and `AsambleaGuiadaScreen` (6 phases).
   - If we replace `UnidadesListScreen` or mutate `Unidad`, existing tests (`juega_flow_test.dart`, `asamblea_adversarial_test.dart`) will break.
   - Therefore, we design a clean, non-destructive navigation structure:
     - **Dual Entry Point**:
       1. On `HomeScreen`: Add a dedicated card `Asambleas Infantil · 2.º Ciclo (3-6 anos)` alongside `Juega con Lúa · Aula (0-3 anos)`.
       2. In `UnidadesListScreen`: Add a Cycle Switcher tab bar at the top: `[ 1.er Ciclo (0-3 anos) | 2.º Ciclo (3-6 anos) ]`. When `1.er Ciclo` is selected (default), it displays the existing 0-2 / 2-3 filters exactly as before. When `2.º Ciclo` is selected, it displays level filters: `[ Todos | 4.º Infantil (3-4) | 5.º Infantil (4-5) | 6.º Infantil (5-6) ]`.
     - Selecting a 2nd cycle unit opens `BackstageAsambleaScreen`.
     - Inside `BackstageAsambleaScreen`: A glanceable, continuous level switcher (`BackstageLevelSwitcher`: `4.º Inf. | 5.º Inf. | 6.º Inf.`) allows the teacher to seamlessly switch grade level during the session (adapting Phase 3 Core TPR between Expanded Action, Dramatized/Freeze, and Peer-to-peer) without resetting the timer or phase!

5. **Academy Home View Extension for September Micro-Routine & Recast Guidance**:
   - From Observation 7, Academy currently covers 0-3 years across 5 blocks and `GuiaAtencionScreen`.
   - In 3-6 years, the home routine centers on the "Time and Place" principle (3-5 minute routine niche: coat hanging, putting on shoes, packing bag) and Indirect Corrective Modeling (Recast).
   - Therefore, we extend Academy:
     - In `BloquesListScreen`: Add a featured card for `Micro-rutina de Setembro: Autonomía e Acollemento (3-6 anos)`.
     - Create `MicroRutinaSetembroScreen` (or `RecastGuiaScreen`) featuring:
       - The 3-5 minute daily routine niche (morning coat hanging and shoe autonomy).
       - Explicit Recast table: What to avoid (frontal interrogation like "¿Cómo se dice coat?", negative corrections) vs. What to do (natural expanded linguistic repetition in L3 accompanied by physical gestures).
       - Model audio clips via `BotonEscuchar` for adult English modeling (LJSpeech).

6. **Widget Testing Strategy**:
   - From Observation 8, tests verify navigation, state boundaries, audio lifecycle, and accessibility.
   - A robust widget test suite (`test/features/juega/backstage_asamblea_test.dart`) must systematically verify:
     - Dark mode styling (background `#0B1220`, key texts >= 24sp).
     - Absence of child gamification (`LuaPixel`, `LuaGameStrip`, rewards).
     - 4-phase step-by-step navigation, back button disabled in Phase 1, "Finalizar" in Phase 4.
     - Discrete timer countdown per phase (90s, 120s, 270s, 120s) and silent overtime transition.
     - Auto-fade/pause of audio when advancing phases.
     - Continuous level switching (4º, 5º, 6º) updating TPR challenges dynamically.
     - 100% backward compatibility of existing 0-3 widget tests.

---

## 3. Caveats

1. **Android Native Volume Channel Support**:
   - `MainActivity.kt` currently implements `"play"`, `"pause"`, `"stop"`, `"release"`, `"filesDir"`. It does not yet have `"setVolume"`.
   - To achieve hardware-level volume fades, 4 lines of Kotlin can be added to `MainActivity.kt` (`"setVolume" -> { val v = call.argument<Double>("volume")?.toFloat() ?: 1.0f; player?.setVolume(v, v); result.success(null) }`).
   - However, our UI/UX component architecture is designed defensively: `FadeAudioCoordinator` provides software timer fades when volume is supported, and falls back gracefully to clean play/pause/stop if volume is unavailable or when running in test environments (`MockOfflineAudioService`).
2. **Screen Wake Lock**:
   - In a 10-minute backstage assembly session where the teacher glances at the screen without tapping every 30 seconds, Android's OS display sleep (typically 30s-60s) could turn off the screen.
   - Adding `wakelock_plus` would introduce a third-party dependency (which might conflict with zero-dependency policies). Alternatively, keeping the discrete timer ticking with active `setState` or recommending standard OS display timeout adjustments during classroom hours avoids adding network/analytics SDKs.
3. **Voice Recordings for Segundo Ciclo**:
   - Locutions for LJSpeech English commands in 4º, 5º, 6º will be synthesized offline via CI (`tools/export_voice_corpus.py`), maintaining zero runtime inference and zero network permissions.

---

## 4. Conclusion & Component Architecture Proposal

### 4.1 Component Architecture Overview

```
lib/features/juega/
├── views/
│   ├── unidades_list_screen.dart             [EXTENDED: Cycle Switcher (0-3 vs 3-6)]
│   ├── asamblea_guiada_screen.dart           [PRESERVED 100%: 0-3 6-phase assembly]
│   └── backstage_asamblea_screen.dart        [NEW: 3-6 4-phase dark backstage assistant]
└── widgets/
    ├── backstage/
    │   ├── backstage_phase_stepper.dart      [NEW: 4 canonical phases progress]
    │   ├── backstage_phase_timer_widget.dart [NEW: Discrete silent timer per phase]
    │   ├── backstage_level_switcher.dart     [NEW: Glanceable 4º/5º/6º level switcher]
    │   ├── backstage_audio_bar.dart          [NEW: Large touch target audio controller]
    │   ├── paso_opening_widget.dart          [NEW: Phase 1 (1:30 min)]
    │   ├── paso_rhythm_widget.dart           [NEW: Phase 2 (2:00 min)]
    │   ├── paso_core_tpr_widget.dart         [NEW: Phase 3 (4:30 min)]
    │   └── paso_calm_widget.dart             [NEW: Phase 4 (2:00 min)]
lib/features/academy/
├── views/
│   ├── bloques_list_screen.dart              [EXTENDED: Featured card for September micro-routine]
│   └── micro_rutina_setembro_screen.dart     [NEW: Autonomy, Time & Place, Recast guide]
└── widgets/
    └── recast_guia_card.dart                 [NEW: Recast comparison table & audio model]
```

### 4.2 Proposed Backstage UI Theme Tokens (`lib/core/theme/app_theme.dart`)

```dart
// Backstage Dark Mode Tokens (Optimized for 2-meter glanceability and zero glare)
static const Color backstageBg = Color(0xFF0B1220); // Deep Obsidian
static const Color backstageCard = Color(0xFF131D31); // Elevated Surface
static const Color backstageCardBorder = Color(0xFF24324B); // Subtle Contrast Border
static const Color backstageTextPrimary = Color(0xFFFFFFFF); // Crisp White (>14:1 contrast)
static const Color backstageTextSecondary = Color(0xFF94A3B8); // High-contrast Slate
static const Color backstageAccent = Color(0xFF00C4BE); // Atlantic Turquoise
static const Color backstageAmber = Color(0xFFF59E0B); // Soft Overtime Warning
static const Color backstageEmerald = Color(0xFF10B981); // Completed Phase Green

// Backstage Touch Target Constants
static const double backstageTouchMin = 64.0; // Extra-large touch area for outstretched reach
static const double backstageKeyTextSize = 26.0; // Readability >= 2 meters
```

### 4.3 Proposed Component Signatures & State

#### 1. `BackstageAsambleaScreen` (`lib/features/juega/views/backstage_asamblea_screen.dart`)
- **Purpose**: Root orchestrator for the teacher backstage assistant.
- **Parameters**:
  - `final UnidadSegundoCiclo unidad;` (or unit payload containing 4-phase data)
  - `final OfflineAudioService? audioService;`
  - `final AppLanguage initialLanguage;`
  - `final NivelInfantil initialNivel;` (`nivel4`, `nivel5`, `nivel6`)
  - `final PremiosRepository? premios;`
  - `final CalendarioStore? calendario;`
- **Internal State**:
  - `int _currentPhase = 0;` (0: Opening, 1: Rhythm, 2: Core TPR, 3: Calm)
  - `NivelInfantil _selectedNivel;`
  - `late final FadeAudioCoordinator _audioCoordinator;`
  - Phase durations: `[90, 120, 270, 120]` seconds.
- **Key Methods**:
  - `void _advancePhase()`: Triggers 800ms audio fade-out, updates `_currentPhase`, resets phase timer to new duration.
  - `void _retreatPhase()`: Moves back one phase, resets timer.
  - `void _switchNivel(NivelInfantil nuevo)`: Updates level for Phase 3 without altering current phase or timer.
  - `Future<void> _finalizarAsamblea()`: Fades and stops audio, registers calendar/award events, pops screen.

#### 2. `BackstagePhaseTimerWidget` (`lib/features/juega/widgets/backstage/backstage_phase_timer_widget.dart`)
- **Purpose**: Discrete, non-distracting phase countdown timer.
- **Parameters**:
  - `final int targetSeconds;` (90, 120, 270, 120)
  - `final bool autoStart;` (default `true`)
  - `final VoidCallback? onThresholdReached;`
- **Visual Presentation**:
  - Format: `MM:SS` (e.g., `01:28` or `+00:14` if overtime) rendered in `TextStyle(fontSize: 34.0, fontWeight: FontWeight.w800, fontFamily: 'monospace')`.
  - Color: `backstageAccent` (`#00C4BE`) when active, `backstageAmber` (`#F59E0B`) when overtime.
  - Status indicator: Subtle dot icon (pulsing quietly) and touch toggle to pause/resume. Zero audio alarms.

#### 3. `BackstagePhaseStepper` (`lib/features/juega/widgets/backstage/backstage_phase_stepper.dart`)
- **Purpose**: Horizontal progress indicator with 4 glanceable segments.
- **Segments**:
  1. `1. Opening (1:30)`
  2. `2. Rhythm (2:00)`
  3. `3. Core TPR (4:30)`
  4. `4. Calm (2:00)`
- **Behavior**: Tapping a segment allows educator direct access to that phase.

#### 4. `BackstageLevelSwitcher` (`lib/features/juega/widgets/backstage/backstage_level_switcher.dart`)
- **Purpose**: Seamless switching between 4.º (3-4a), 5.º (4-5a), and 6.º (5-6a) Infantil.
- **Layout**: Large pill segmented control (`minHeight: 48dp`, high contrast).
- **Functionality**: Dynamically adjusts Phase 3 Core TPR challenge instructions without interrupting ongoing phase timing.

#### 5. `PasoCoreTprWidget` (`lib/features/juega/widgets/backstage/paso_core_tpr_widget.dart`)
- **Purpose**: Phase 3 view presenting level-specific TPR methodology:
  - **4.º Infantil**: Expanded Action commands (2 coordinated actions with "and", e.g., `"Put on your coat AND stand in line"`), modeling and fading cue.
  - **5.º Infantil**: Dramatized narrative ("The Backpack Adventure") and Stop-Signal / Freeze dynamics with acoustic cues.
  - **6.º Infantil**: Peer-to-peer transactional TPR using textless icon cue cards (`CueCardWidget`) and natural Galician materials (mimbre, castañas, conchas).
- **Typography**: Key English phrases in `28sp` bold white, Galician teacher notes in `20sp` slate.

#### 6. `FadeAudioCoordinator` (`lib/core/audio/fade_audio_coordinator.dart`)
- **Purpose**: Manages smooth audio fade transitions over `OfflineAudioService`.
- **Methods**:
  - `Future<void> playWithFadeIn(String assetPath, {Duration duration = const Duration(milliseconds: 1000)})`
  - `Future<void> fadeOutAndStop({Duration duration = const Duration(milliseconds: 800)})`
  - `Future<void> fadeOutAndPause({Duration duration = const Duration(milliseconds: 800)})`

#### 7. `MicroRutinaSetembroScreen` & `RecastGuiaCard` (`lib/features/academy/`)
- **Purpose**: Home extension for families in Segundo Ciclo (3-6 years).
- **Components**:
  - `RecastGuiaCard`: Two-column comparison illustrating negative frontal testing vs. indirect corrective modeling (recast).
  - Audio model player (`BotonEscuchar`) for parent pronunciation practice.
  - Autonomy checklist: Dressing, hanging coat on low hooks, backpack handling.

---

## 5. Verification Method

### 5.1 Static Analysis & Compilation Check
```bash
flutter analyze
dart format --output=none --set-exit-if-changed lib/ test/
```

### 5.2 Unit & Model Tests
Verify that Segundo Ciclo models and loaders load cleanly alongside 1st cycle models:
```bash
flutter test test/data/models_test.dart
flutter test test/data/content_loader_test.dart
flutter test test/data/bilingual_parity_test.dart
flutter test test/data/curricular_alignment_test.dart
```

### 5.3 Widget & Backstage Integration Tests
Run existing and proposed widget suites:
```bash
flutter test test/features/juega/juega_flow_test.dart
flutter test test/features/juega/asamblea_adversarial_test.dart
flutter test test/features/juega/backstage_asamblea_test.dart
flutter test test/features/academy/academy_flow_test.dart
flutter test test/features/academy/recast_guia_test.dart
```

### 5.4 Test Assertions for Backstage UI
The widget tests must assert:
1. `expect(find.byType(LuaGameStrip), findsNothing);` inside backstage assistant (zero gamification).
2. `expect(find.byType(LuaPixel), findsNothing);` inside backstage assistant (zero child screens).
3. `final scaffold = tester.widget<Scaffold>(find.byType(Scaffold)); expect(scaffold.backgroundColor, AppTheme.dark);` (dark mode verified).
4. `final cmdText = tester.widget<Text>(find.byKey(const Key('tpr_command_text'))); expect(cmdText.style?.fontSize, greaterThanOrEqualTo(24.0));` (readable at 2 meters).
5. Advance Phase 1 -> Phase 2: verify `mockAudioService.isPlaying` becomes `false` and timer resets from 90s to 120s.
6. Toggle level switcher: verify command text changes between 4º, 5º, and 6º while timer continues smoothly.
7. Phase 4 completion: verify tapping 'Finalizar' calls `audioService.stop()` and pops the route.

### 5.5 Invalidation Conditions
- Any appearance of child-facing gamification (badges, animated pixels, confetti) in the teacher backstage screen.
- Any regression breaking the 0-3 years assembly flow or existing unit tests in `test/features/juega/`.
- Introduction of any internet permission or network packages into `pubspec.yaml` or `AndroidManifest.xml`.
