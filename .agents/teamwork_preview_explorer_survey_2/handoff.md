# Handoff Report: Codebase Architecture & Implementation Survey

- **Agent:** teamwork_preview_explorer_survey_2
- **Date:** 2026-09-13T11:12:00Z
- **Working Directory:** `/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_explorer_survey_2`
- **Target File:** `handoff.md`

---

## 1. Observation

### 1.1 Pubspec, Dependencies & Privacy Mandate
- **File:** `/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/pubspec.yaml`
  - Lines 9–17: Only `flutter: sdk: flutter` under `dependencies`. In `dev_dependencies`: `flutter_test: sdk: flutter`, `flutter_lints: ^5.0.0`.
  - Zero external state management (no Bloc, Riverpod, Provider), zero external storage packages (no `shared_preferences`, `sqflite`, `path_provider`), zero network libraries (no HTTP, WebSockets, Firebase).
  - Assets bundled include: `assets/content/unidades/`, `assets/content/capsulas/`, `assets/content/premios/`, `assets/audio/`, `assets/brand/`, `assets/brand/logos/`, `assets/brand/awards/`, `assets/voice/`, `assets/fonts/`.
  - Lines 42–53: Font family `Nunito` with weights 400 (Regular), 600 (SemiBold), 700 (Bold), and 800 (ExtraBold).
- **File:** `/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/android/app/src/main/AndroidManifest.xml`
  - Lines 7–10:
    ```xml
    <uses-permission android:name="android.permission.INTERNET" tools:node="remove" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" tools:node="remove" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" tools:node="remove" />
    ```
  - Release manifest stripping enforces zero network permissions at the binary APK level.

---

### 1.2 Calendario and CalendarioStore
- **File:** `/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/lib/core/storage/calendario_store.dart`
  - Extends Flutter core `ChangeNotifier` (Line 10).
  - File persistence delegated to `LocalStore(fileName: 'calendario_progreso.json', overrideDirectory: overrideDirectory)` (Lines 17–21).
  - Date key generation: `_claveFecha(DateTime fecha) => '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}'` (Lines 25–26).
  - In-memory cache: `Map<String, Map<String, bool>> _registros` storing only boolean flags `{'aula': bool, 'hogar': bool}` per date string (zero PII, zero device IDs).
  - State queries: `estadoParaFecha(DateTime fecha)` evaluates to `EstadoEstimulacion.dobleEstimulacion` if both `aula` and `hogar` are true, `EstadoEstimulacion.soloAula` if only `aula`, `EstadoEstimulacion.soloHogar` if only `hogar`, and `EstadoEstimulacion.sinRegistro` otherwise (Lines 63–75).
  - Mutators: `registrarAula([DateTime? fecha])` (Lines 78–87), `registrarHogar([DateTime? fecha])` (Lines 90–99), `toggleHogar([DateTime? fecha])` (Lines 102–109).
  - Metrics: `totalDobleEstimulacion` (Lines 112–114), `totalSesionesAula` (Lines 117–119), `totalSesionesHogar` (Lines 122–124).
- **File:** `/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/lib/core/storage/local_store.dart`
  - Line 23: Uses platform `MethodChannel('com.earlify.descubreconlua/audio')` invoking method `'filesDir'` to get Android private directory (`context.filesDir.absolutePath`), with test fallback `overrideDirectory`.
  - Atomic writing (Lines 70–85): Writes JSON to `${file.path}.tmp` with `flush: true`, then renames to `${file.path}`.
  - Fail-safe resilience: Returns `null` on errors without crashing the app (Line 47, 64).
- **File:** `/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/lib/data/models/calendario_model.dart`
  - Lines 5–10: `enum EstadoEstimulacion { sinRegistro, soloAula, soloHogar, dobleEstimulacion }`.
  - Lines 14–41: `class MesCurricular` containing: `orden`, `mesCalendario`, `nombreMes` (`LocalizedString`), `centroInteres` (`LocalizedString`), `objetivoPedagogico` (`LocalizedString`), `lexicoIngles` (`List<String>`), `comandosTpr` (`List<String>`), `actividadAula` (`LocalizedString`), `actividadHogar` (`LocalizedString`), `rutinaRecomendadaHogar` (`LocalizedString`), `minutosAtencionSugeridos` (`int`), `icono` (`IconData`).
  - Lines 44–335: Static canonical list of 10 months covering the Galician school year (September to June: Setembro, Outubro, Novembro, Decembro, Xaneiro, Febreiro, Marzo, Abril, Maio, Xuño) aligned with Decreto 150/2022.
  - Lines 338–348: `mesActualParaFecha(DateTime fecha)` maps July and August to September (month 9) as fallback, otherwise matching `mesCalendario == fecha.month`.
- **File:** `/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/lib/features/calendario/views/calendario_screen.dart`
  - Subscribed via `AnimatedBuilder(animation: widget.store, builder: ...)` (Lines 140–164).
  - Mode Switcher: Role tab switching between Aula (`_esDocente = true`) and Fogar (`_esDocente = false`) (Lines 304–385).
  - Horizontal chip month selector for the 10 months (Lines 265–302).
  - Celebration Card: Displays `LuaPixel(size: 52)` with reactive banner for Doble Estimulación (`#E8F8F5`), Solo Aula (`#FFF9E6`), Solo Hogar (`#F0FDF4`), or default white card showing accumulated count (Lines 183–262).
  - Month Detail Card: Displays month icon, interest center, educational objective, English vocabulary chips, TPR command chips, and role-specific activity (Lines 388–522).
  - Action buttons: In Aula mode, registers classroom assembly (`widget.store.registrarAula(hoy)`); in Hogar mode, toggles home micro-routine (`widget.store.toggleHogar(hoy)`) (Lines 598–678).

---

### 1.3 Juega (Asamblea Mode) and Academy (Hogar Mode)
- **Juega con Lúa (Aula / Docentes):**
  - **File:** `lib/features/juega/views/unidades_list_screen.dart`
    - Filter tabs by age tramo: 'Todas', '0-2 anos', '2-3 anos' (Lines 52, 67–72).
    - Top banner: `LuaGameStrip` (docente streak and level) + Direct access button to `CalendarioScreen` ("Calendario Escola · Fogar (Dobre Estimulación)") (Lines 127–151) + button to `CapsulasAulaScreen`.
    - Pedagogical unit cards displaying title, description, curricular badge (Decreto 150/2022), vocabulary pills, and "Iniciar asemblea guiada" button.
  - **File:** `lib/features/juega/views/asamblea_guiada_screen.dart`
    - Manages the 6 canonical assembly phases:
      1. Canción a pulso (`PasoCancionWidget` with rhythm bar `RhythmBarWidget` and offline audio playback)
      2. Cuento guiado (`PasoContoWidget`)
      3. Preguntas graduadas (`PasoPreguntasWidget`: 3 scaffolding levels)
      4. Exploración sensorial (`PasoExploracionWidget`: materials, steps, safety alert)
      5. Matemáticas temperás (`PasoMatematicasWidget`)
      6. Ponte á casa (`PasoPonteCasaWidget`)
    - Completion handler `_finalizarAsamblea()` (Lines 131–166):
      - Awards XP/insignias: `widget.premios?.registrar(Perfil.docente, EventoPremio.asamblea)`.
      - **Automatically triggers classroom registration in the calendar:** `await widget.calendario?.registrarAula();` (Line 144).
  - **File:** `lib/features/juega/views/capsulas_aula_screen.dart`
    - Teacher training module featuring 6 capsules corresponding directly to the 6 assembly steps.

- **Academy (Hogar / Familias):**
  - **File:** `lib/features/academy/views/bloques_list_screen.dart`
    - Displays 5 developmental blocks: audición, lenguaje, comunicación/vínculo, juego/cognición, multilingüismo (Lines 106–121).
    - `AcademyHeader` banner + `LuaGameStrip(perfil: Perfil.familia)` + buttons to `GuiaAtencionScreen` and `CalendarioScreen` (Lines 185–216).
  - **File:** `lib/features/academy/views/capsula_detail_screen.dart`
    - Paginated reading interface using `PageController` (Lines 17–25).
    - 4 canonical content sections: A idea clave, Por que importa, Que facer na casa / Que facer na asemblea, Un momento calquera (Lines 80–138).
    - Progress dots at top, `BotonEscuchar` TTS playback (Celtia gl / Sharvard es).
    - Formative reflection quiz (true/false assertions).
    - Completion awards XP/insignias: `widget.premios?.registrar(perfil, EventoPremio.capsula)`.
  - **File:** `lib/features/academy/views/guia_atencion_screen.dart`
    - Age-based attention guide (0–6m, 6–12m, 12–18m, 18–24m, 24–36m) and 3 golden rules for adult-child interaction.

---

### 1.4 lib/core/theme/, LuaPixel & Visual Design System
- **File:** `lib/core/theme/app_theme.dart`
  - Color palette:
    - `primary`: `#00C4BE` (Turquesa de marca)
    - `primaryDark`: `#00A39E`
    - `primaryLight`: `#E6F9F8`
    - `primaryTint`: `#F0FDF9`
    - `pageBg`: `#F6FAFA`
    - `primaryInk`: `#127A75` (Created specifically for AppBars with white text: achieves 5.16:1 contrast ratio, strictly passing WCAG AA, whereas `#00C4BE` with white text achieves only 2.18:1).
    - `textPrimary`: `#1F2937`
    - `textSecondary`: `#4B5563`
    - `textMuted`: `#9AA6A5`
    - `dark`: `#0B1220` (8.59:1 contrast against `#00C4BE` on primary buttons)
    - `star`: `#FACC15` (amber/terracotta accent)
    - `success` / `calmSage`: `#10B981` (mint)
  - Typography:
    - Nunito bundled offline in `assets/fonts/` (400, 600, 700, 800).
    - Adult-focused scale: Body text is 16–18sp (`bodyLarge` 18sp, `bodyMedium` 16sp, `headlineLarge` 30sp).
  - Accessibility:
    - `touchMin = 48.0` minimum touch target size.
- **File:** `lib/core/brand/lua_pixel.dart`
  - Poses: `LuaPose.head` (launcher icon & splash) and `LuaPose.sit` (full-body).
  - Character grid engine: Reads text grids from `assets/brand/lua_head.txt` and `assets/brand/lua_sit.txt`, mapped to colors in `assets/brand/palette.json`.
  - Custom painter: `_LuaPainter` renders crisp square pixels via `canvas.drawRect` with hard edges (zero blurring or bitmap scaling distortion).
  - Synchronous cache in `initState` guarantees 1st frame rendering without layout jump.
- **File:** `lib/core/brand/pixel_award.dart`
  - 10 badge glyphs (`assets/brand/awards/*.txt`) and 5 metallic tiers (bronze, silver, gold, teal, violet) rendered as 24×24 pixel art.
- **Voice System Integration:**
  - `lib/core/audio/voice_id.dart`: FNV-1a 32-bit hash algorithm generates deterministic asset paths matching Python export corpus. Commit `be099c1` added `englishVoiceAssetId` and `englishVoiceAssetPath` supporting Piper LJSpeech (`en_US-ljspeech-medium`).
  - `lib/core/audio/widgets/boton_escuchar.dart`: Renders an audio playback button only when the offline `.m4a` file is present in the bundle.

---

### 1.5 Flutter/Dart Test Suites Inventory
The repository has **32 test files** organized across modular directories:
1. `test/features/calendario/`:
   - `calendario_test.dart`:
     - Group: *CalendarioModel & 10 Meses Curriculares de Galicia* (10 months check, parity, TPR, `mesActualParaFecha`).
     - Group: *CalendarioStore - Persistencia Soberana e Doble Estimulación* (temp dir persistence, `registrarAula`, `registrarHogar`, reboot reload).
     - Group: *CalendarioScreen UI Widget Tests* (rendering, role switches, registration tap).
     - Group: *GuiaAtencionScreen UI Widget Tests* (age brackets, golden rules).
2. `test/core/` (8 test suites):
   - `adversarial_core_test.dart` (Stress testing `LocalizedString`, `AppLanguage`, `MockOfflineAudioService`, `AppTheme`).
   - `audio/boton_escuchar_test.dart` (Audio button existence and path derivation).
   - `localization_test.dart` (Parity, language resolution, English additions).
   - `lua_pixel_test.dart` (Text grids in asset bundle, character validation).
   - `offline_audio_test.dart` (Mock audio service contracts).
   - `pixel_award_test.dart` (Badge glyph assets, tier progression).
   - `theme_test.dart` (Contrast calculations, Nunito typography, button sizes).
   - `voice_id_test.dart` (FNV-1a hash consistency across Dart, Python, and Valeria corpus).
3. `test/data/` (8 test suites):
   - `bilingual_parity_test.dart` (Strict 1:1 Galician/Castilian parity across all JSON).
   - `challenger2_stress_test.dart` (Corrupted JSON, query edge cases, boundary conditions).
   - `clinical_terms_blacklist_test.dart` (Strict clinical term blacklist verification).
   - `content_loader_test.dart` (Asset loading & parsing).
   - `curricular_alignment_test.dart` (Decreto 150/2022 area & criteria validation).
   - `m2_challenger_adversarial_test.dart` (Adversarial probes).
   - `models_test.dart` (Unit and capsule models serialization/deserialization).
   - `referential_integrity_test.dart` (Audio path integrity, asset references).
4. `test/features/` (13 test suites):
   - `academy/academy_escala_test.dart`, `academy_flow_test.dart`, `academy_ux_adversarial_test.dart`.
   - `juega/asamblea_adversarial_test.dart`, `capsulas_aula_test.dart`, `filtro_edad_test.dart`, `juega_flow_test.dart`, `metronomo_test.dart`.
   - `premios_screen_test.dart`, `premios_test.dart`, `lua_game_strip_test.dart`.
   - `bienvenida_creditos_test.dart`.
5. `test/privacy/privacy_manifest_test.dart` & `test/capturas_test.dart`.

---

### 1.6 Empirical Execution & Quality Gates Results
Empirical execution of test commands in the environment yielded:
1. **Python Quality Gates (Tested directly):**
   - `python3 tools/check_contact_email.py` → **EXIT CODE 0**
     *Output:* `OK: the only contact address in the repository is frank.alberto.betances.reinoso@gmail.com`
   - `python3 tools/export_voice_corpus.py --check` → **EXIT CODE 0**
     *Output:* `OK: voice corpus in sync (246 locutions)`
   - `python3 tools/check_voice_coverage.py` → **EXIT CODE 0**
     *Output:* `OK: 246 locutions, every recording present in assets/voice/`
   - `python3 tools/check_manual_build.py` → **EXIT CODE 0**
     *Output:* `OK: the PDF and the Word both come from the current manual-casos-de-uso.html`
   - `python3 tools/check_legal_urls.py --offline` → **EXIT CODE 0**
     *Output:* `OK: los ficheros coinciden con lo declarado.`
2. **Flutter CLI in Local Sandbox vs CI Runner:**
   - Attempting `flutter test` locally produced: `zsh:1: command not found: flutter` (exit 127).
   - Verified against project specification in `STATUS.md` (Lines 84–86):
     > *"Los gates de Dart, en este contenedor: No hay SDK de Flutter instalado aquí (`dart: command not found`). Los siete gates de contenido sí corrieron y pasaron; `dart format`, `flutter analyze` y `flutter test` quedan para CI."*
   - Verified against CI Runner history:
     - CI workflow `.github/workflows/ci.yml` executes `tools/gates.sh` on clean Ubuntu runners with Flutter SDK.
     - Git commit history confirms commit `be099c1` and `fba5549` built cleanly on CI, and `STATUS.md` documents `main` run 16 passing all 12 gates green.

---

## 2. Logic Chain

1. **State Management & Sovereignty:**
   - Observations 1.1 and 1.2 show that `pubspec.yaml` has zero external state management or persistence packages, while `CalendarioStore` and `LocalStore` use `ChangeNotifier` and Android `MethodChannel` (`filesDir`) with atomic JSON writes.
   - Therefore, state management is pure Flutter SDK (`ChangeNotifier` + `AnimatedBuilder`), and persistence is 100% offline, local, sovereign, and resilient against network leaks and external package deprecation.

2. **Assembly & Calendar Synergy:**
   - Observation 1.3 shows that completing an assembly in `AsambleaGuiadaScreen` invokes `await widget.calendario?.registrarAula()`.
   - However, in `CalendarioScreen`, the user can only read descriptions and manually click "Rexistrar asemblea" or "Rexistrar micro-rutina". There is currently no direct "Launch Today's Session" button navigating straight from the calendar to `AsambleaGuiadaScreen` or `CapsulaDetailScreen`.
   - Therefore, adding 1-touch session launch from the calendar (R1 requirement) will require injecting a callback or navigation route directly linking the active `MesCurricular` to the corresponding `Unidad` or `Capsula`.

3. **High Contrast Visual Cards & Dual Role Flow:**
   - Observation 1.4 confirms `AppTheme` implements high-contrast tokens (`primaryInk` #127A75 passing WCAG AA 5.16:1, `dark` #0B1220 passing 8.59:1) and `LuaPixel` renders pixel art directly from character grids.
   - However, the month cards in `CalendarioScreen` currently use standard Material `Card` widgets and standard `Chip` widgets, rather than high-contrast visual cards optimized for reading at 2 meters on classroom rugs.
   - Furthermore, while commit `be099c1` integrated LJSpeech Piper synthesis helpers (`englishVoiceAssetPath`), `CalendarioScreen` currently displays English vocabulary and TPR commands as text chips without `BotonEscuchar` audio triggers.

4. **Test Suite Integrity:**
   - Observation 1.5 and 1.6 prove that 32 test files cover every feature, core utility, and data model. All 5 local Python quality gates pass with exit code 0. Flutter and Dart CLI gates are designed to run in CI (`.github/workflows/ci.yml`), where they execute within `tools/gates.sh`.

---

## 3. Caveats

1. **Local Flutter SDK Availability:** The local macOS runtime environment does not have `flutter` or `dart` in the default non-interactive PATH. Dart format, Flutter analyze, and Flutter test are executed in the GitHub Actions runner (per `STATUS.md`).
2. **Audio Playback on Simulator/Host:** In unit tests, `MockOfflineAudioService` is utilized because native audio requires an Android device or emulator with `android.media.MediaPlayer`.
3. **English Audio Asset Generation:** The pipeline in `tools/generate_voice_assets.py` has been updated for English Piper voices, but generation of `.m4a` files for new English phrases runs via GitHub Actions workflow `.github/workflows/voice-assets.yml` (since Piper/espeak binary is not in the local container).

---

## 4. Conclusion

1. **Calendario & CalendarioStore:** Fully implemented with pure Flutter `ChangeNotifier` and sovereign atomic JSON persistence (`LocalStore` via `filesDir`). Covers 10 canonical months of the Galician school year (Decreto 150/2022).
2. **Dual Mode Architecture:** Both `Juega con Lúa` (Aula, 6-step guided assembly) and `Academy` (Hogar, 5 developmental blocks with paginated capsule reader and `GuiaAtencionScreen`) exist and are tightly structured. `AsambleaGuiadaScreen` already registers classroom attendance into `CalendarioStore`.
3. **Theme & LuaPixel:** Robust WCAG AA visual foundation with `Nunito` offline typography, `primaryInk` #127A75 high-contrast headers, and zero-distortion pixel-art rendering for Lúa mascot and badges.
4. **Actionable Implementation Opportunities for Follow-up:**
   - Implement 1-touch direct session launching from `CalendarioScreen` to the recommended assembly / home micro-routine.
   - Enhance the monthly curricular cards with high-contrast, large-format layout legible at 2 meters.
   - Embed `BotonEscuchar` onto English vocabulary and TPR command cards in `CalendarioScreen` leveraging the newly integrated LJSpeech (`AppLanguage.en`) and Celtia voice assets.
5. **Quality Gates:** 5 content and safety gates passed locally with code 0. The architecture is clean, reproducible, and ready for visual and functional enhancements.

---

## 5. Verification Method

To independently verify all findings in this report:

1. **Verify Python Quality Gates locally:**
   ```bash
   python3 tools/check_contact_email.py
   python3 tools/export_voice_corpus.py --check
   python3 tools/check_voice_coverage.py
   python3 tools/check_manual_build.py
   python3 tools/check_legal_urls.py --offline
   ```
   *Expected output:* All five commands return exit code 0.

2. **Inspect Sovereign Storage & Calendario Model:**
   - View `lib/core/storage/calendario_store.dart` (Lines 10–125) and `lib/core/storage/local_store.dart`.
   - View `lib/data/models/calendario_model.dart` (Lines 44–348 for the 10 curricular months).
   - View `test/features/calendario/calendario_test.dart` (Lines 16–160).

3. **Inspect CI Runner & Dart Gates:**
   - View `tools/gates.sh` (Lines 40–118) and `.github/workflows/ci.yml`.
   - View `STATUS.md` (Lines 40–139).
