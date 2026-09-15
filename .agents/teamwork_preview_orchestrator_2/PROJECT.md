# Project: Descubre con Lúa · Edición Vigo (Follow-Up Master Scope)

## Architecture
Clean architecture decoupled into four layers:
- `lib/core/`:
  - `theme/`: Material 3 Atlantic warm palette (`primary` #00C4BE, `primaryInk` #127A75 WCAG AA 5.16:1, `coralSuave` #F4A9B6/#EF8296, `amber` #FACC15, `mint` #10B981, `dark` #0B1220), Nunito offline typography (>= 16sp body, >= 18sp headings).
  - `brand/`: `LuaPixel` custom painter rendering mascot matrices from `lua_head.txt` and `lua_sit.txt` without bitmap distortion, and `PixelAward`.
  - `audio/`: `OfflineAudioService`, `LocalAudioPlayer` via MethodChannel, `MockOfflineAudioService` for tests, `voice_id.dart` with deterministic FNV-1a hashing (`voiceAssetPath` and `englishVoiceAssetPath`), `BotonEscuchar` audio trigger widget.
  - `storage/`: `CalendarioStore` (`ChangeNotifier`) backed by `LocalStore` (`filesDir/calendario_progreso.json`), sovereign, zero PII, atomic writes.
  - `localization/`: `AppLanguage` (`gl`, `es`, `en`), `LocalizedString`.
- `lib/data/`:
  - `models/`: `CalendarioModel` (`MesCurricular` covering 10 months of Decreto 150/2022, `EstadoEstimulacion`), `UnidadModel`, `CapsulaModel`, `CurricularReference`.
  - `loaders/`: `ContentAssetLoader` loading JSON assets from `assets/content/**`.
  - `repositories/`: `ContentRepository` providing query and filter methods.
  - `validators/`: `ContentValidator` enforcing 1:1 bilingual parity, Decreto 150/2022 compliance, and clinical term blacklist.
- `lib/features/calendario/`:
  - `views/`: `CalendarioScreen` with 1-touch session launcher, agile dual-role switcher (`Aula (Asamblea)` vs `Fogar (Academy)`), reactive Doble Estimulación celebration banner, and 10-month high-contrast visual flashcards with embedded audio playback.
  - `widgets/`: `TarjetaMesVisualWidget` (reading distance 2m), `MomentoSesionWidget` (Apertura 72 BPM, Fingerplay, TPR inglés con LJSpeech, Cierre afectivo), `BotonLanzarSesion`.
- `lib/features/juega/`:
  - `views/`: `UnidadesListScreen` (age filter 0-2 / 2-3) and `AsambleaGuiadaScreen` (6 steps, automatic `registrarAula()` call on completion).
- `lib/features/academy/`:
  - `views/`: `BloquesListScreen` (5 blocks), `CapsulaDetailScreen` (4 sections, reflection quiz), `GuiaAtencionScreen` (5 age brackets, 3 golden rules).
- `test/`:
  - `features/calendario/`: Unit and widget tests for calendar models, store, screen, and attention guide.
  - `core/`: Unit tests for theme, audio, voice_id, lua_pixel, storage.
  - `data/`: Model validation, bilingual parity, clinical terms blacklist.
  - `privacy/`: Manifest privacy and zero-network audits.

## Feature Inventory
| # | Feature | Description | Milestone | Source |
|---|---------|-------------|-----------|--------|
| 1 | 1-Touch Session Launcher | Directly launch the recommended session for the active month (assembly or home capsule) from `CalendarioScreen` in 1 tap | M5 | Follow-up R1 |
| 2 | Agile Dual-Role Context Switcher | Instant tab switch between Aula (assembly instructions, subtle timer) and Fogar (family why-it-matters, 3-5m micro-routine) | M5 | Follow-up R3 |
| 3 | Reactive Doble Estimulación Celebration | Transparent reactive status update in `CalendarioStore` and `CalendarioScreen` when both aula and hogar sessions are marked | M5 | Follow-up R1 |
| 4 | Sovereign CalendarioStore Atomic Persistence | Zero-network local storage with atomic JSON writes to `calendario_progreso.json`, error-resilient and instant | M5 | Follow-up R1 |
| 5 | Automatic Assembly Completion Sync | Auto-register classroom attendance in `CalendarioStore` upon finishing `AsambleaGuiadaScreen` | M5 | Follow-up R1 |
| 6 | 10-Month High-Contrast Visual Flashcards | Visual cards for Setembro to Xuño (Decreto 150/2022) optimized for 2-meter rug readability in classroom and close home interaction | M6 | Follow-up R2 |
| 7 | 4-Phase Session Moments Architecture | Apertura (72 BPM visual pulse), Fingerplay/Concentración, Núcleo TPR en inglés (LJSpeech), and Cierre afectivo | M6 | Follow-up R2 |
| 8 | Direct LJSpeech · piper English Audio Access | Embedded `BotonEscuchar` on each card for English TPR commands and vocabulary with native female ONNX voice model | M6 | Follow-up R2 |
| 9 | Direct Celtia · Proxecto Nós Galician Audio Access | Embedded `BotonEscuchar` on each card for Galician instructions and stories with Proxecto Nós Coqui-TTS voice model | M6 | Follow-up R2 |
| 10 | Atlantic Warm Palette & Minimalist Vector Iconography | Aguamarina (#00C4BE / #127A75), coral suave (#F4A9B6/#EF8296), ámbar (#FACC15), menta (#10B981) in harmony with `LuaPixel` | M6 | Follow-up R2 |
| 11 | Physical Asset & Extension Strict Verification | 100% physical existence and exact extension verification for all declared assets, brand logos, and audio files | M6 | Follow-up R2 / Rules |
| 12 | Repository Quality Gates Execution | Pass all 5 tools scripts (`check_contact_email.py`, `export_voice_corpus.py --check`, `check_voice_coverage.py`, `check_manual_build.py`, `check_legal_urls.py --offline`) with exit code 0 | M7 | Follow-up AC |
| 13 | Comprehensive Flutter/Dart Test Suite Pass | 100% passing tests in `test/features/calendario/`, `test/core/`, `test/data/`, `test/features/`, and `test/privacy/` | M7 | Follow-up AC |
| 14 | Forensic Integrity Audit & Binary Privacy Verification | Independent forensic audit ensuring clean implementation, zero mocks/stubs in production paths, zero internet permissions | M7 | Follow-up AC / System |

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| M5 | 1-Touch Calendar Launch & Agile Dual Flow | 1-touch session launching from `CalendarioScreen` to `AsambleaGuiadaScreen` / `CapsulaDetailScreen`, agile dual role switch with subtle timer & instructions, reactive Doble Estimulación, CalendarioStore atomic sync | none | DONE |
| M6 | 10-Month High-Contrast Visual Cards & Audio | 10 curricular months visual flashcards with 4 session moments, 2m reading distance layout, LJSpeech English & Celtia Galician audio buttons, Atlantic warm palette, 100% asset extension audit | M5 | IN_PROGRESS |
| M7 | Quality Gates, Test Suite & Forensic Audit | Verification of all 5 tools/*.py gates, 100% Flutter/Dart test passing, forensic integrity audit, zero internet manifest verification | M5, M6 | PLANNED |

## Interface Contracts

### Session Launch Contract
```dart
typedef IniciarSesionCallback = void Function(MesCurricular mes, bool esDocente);
```
In `CalendarioScreen`:
- When in Aula mode: tapping "Iniciar asemblea guiada" invokes `onIniciarSesion(mes, true)` which navigates to `AsambleaGuiadaScreen` with the corresponding thematic unit.
- When in Fogar mode: tapping "Iniciar micro-rutina no fogar" invokes `onIniciarSesion(mes, false)` which navigates to `CapsulaDetailScreen` or `GuiaAtencionScreen`.

### 4 Moments of Session Component Contract
```dart
class MomentoSesionData {
  final String titulo;
  final String consigna;
  final String? audioTexto;
  final AppLanguage? audioIdioma;
  final IconData icono;
}
```
Each `TarjetaMesVisual`:
1. Momento 1: Apertura (Rima / Canción de saúdo acompasada a 72 BPM).
2. Momento 2: Fingerplay / Concentración (Mímica e propriocepción).
3. Momento 3: Núcleo TPR en Inglés (Comando de movemento con `BotonEscuchar` e modelo LJSpeech).
4. Momento 4: Peche Afectivo (Despedida e calma).

## Code Layout
```
lib/
├── main.dart
├── core/
│   ├── theme/app_theme.dart
│   ├── brand/
│   │   ├── lua_pixel.dart
│   │   └── pixel_award.dart
│   ├── audio/
│   │   ├── voice_id.dart
│   │   ├── widgets/boton_escuchar.dart
│   │   └── offline_audio_service.dart
│   ├── storage/
│   │   ├── calendario_store.dart
│   │   └── local_store.dart
│   └── localization/
│       ├── app_language.dart
│       └── localized_string.dart
├── data/
│   └── models/
│       ├── calendario_model.dart
│       ├── curricular_model.dart
│       ├── unidad_model.dart
│       └── capsula_model.dart
├── features/
│   ├── calendario/
│   │   ├── views/calendario_screen.dart
│   │   └── widgets/
│   │       ├── tarjeta_mes_visual.dart
│   │       └── momento_sesion_card.dart
│   ├── juega/
│   │   └── views/
│   │       ├── unidades_list_screen.dart
│   │       └── asamblea_guiada_screen.dart
│   └── academy/
│       └── views/
│           ├── bloques_list_screen.dart
│           ├── capsula_detail_screen.dart
│           └── guia_atencion_screen.dart
test/
├── features/calendario/calendario_test.dart
├── core/
└── data/
```
