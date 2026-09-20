# Flutter Codebase Survey Report: Migration to «Descubre con Lúa · Edición Vigo»

**Date**: 2026-09-20  
**Target Repository**: `/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/`  
**Working Branch**: `studio`  
**Role**: Flutter Codebase Explorer (Survey Phase)  
**Standard Compliance**: Frank's Rules R1–R6, Strict Zero-Network Privacy Policy  

---

## 1. Executive Summary

This survey evaluates the current state of the native Flutter application «Descubre con Lúa · Edición Vigo» prior to migrating pedagogical content and UI modules from the React/TypeScript prototype.

Key baseline facts verified:
- **Git Branch & Remote**: Verified on branch `studio` (`88d2ae8`), up to date with `origin/studio`. Local tree is clean except for `.agents/` and the updated `ORIGINAL_REQUEST.md`.
- **Flutter / Dart Local Environment**: `flutter` and `dart` command-line binaries are **not installed in the local macOS host PATH**. CI/CD runs on GitHub Actions `ubuntu-latest` using `subosito/flutter-action@v2` (`channel: stable`), running `tools/gates.sh` (which enforces `dart format`, `flutter analyze`, `flutter test`, content validation gates, and `flutter build apk --release`).
- **Binary Privacy & Zero-Network Policy**: `android/app/src/main/AndroidManifest.xml` strictly removes `android.permission.INTERNET`, `android.permission.ACCESS_NETWORK_STATE`, and `android.permission.ACCESS_WIFI_STATE` with `tools:node="remove"`. `pubspec.yaml` contains **zero third-party networking or audio dependencies** (`flutter` SDK only).
- **Audio & Storage Architecture**: Offline audio uses native `MethodChannel('com.earlify.descubreconlua/audio')` backed by Kotlin `MediaPlayer` (`LocalAudioPlayer`). Storage uses atomic file I/O in Android's private `getFilesDir()` via `LocalStore` without external packages.
- **Linguistic Parity**: Bilingual Galician/Spanish (`gl`/`es`) enforced by `LocalizedString` value object with strict parity validation (`hasParity`).
- **Pedagogical Assets**: 2,442 offline pre-synthesized `.m4a` files exist in `assets/voice/`. 80 vector shape cards exist in `assets/brand/laminas/`. `assets/content/` currently houses units, capsules, assemblies (1st and 2nd cycle), daily progression, training, awards, and calendar JSON assets.

---

## 2. Git Status and Remote Tracking

Verified via `/Library/Developer/CommandLineTools/usr/bin/git status` and `branch -vv -a`:

```
On branch studio
Your branch is up to date with 'origin/studio'.
HEAD commit: 88d2ae893c76f7a688a572738d31984a04e8b5e1
Commit message: chore(voice): synthesise offline voice assets (Celtia gl / Sharvard es / LJSpeech en)
Author: github-actions[bot]
Date: Wed Sep 16 11:05:13 2026 +0000
```

Remote branch alignment:
- `studio`: `88d2ae8` [origin/studio] (Synchronized)
- `origin/main`: `88d2ae8` (Synchronized with studio HEAD)
- Local uncommitted files: Only `.agents/` metadata and `ORIGINAL_REQUEST.md`.

*Compliance Notice*: As dictated by `ORIGINAL_REQUEST.md`, all future migration commits must go exclusively to branch `studio` and pushed to `origin/studio`. Branch `main` must not be touched.

---

## 3. Flutter & Dart Environment Analysis

### 3.1 Local Host Availability
- Command: `which flutter` returned `flutter not found`.
- Command: `which dart` returned `dart not found`.
- Spotlight filesystem check: `mdfind "kMDItemFSName == 'flutter'"` returned empty.
- **Empirical Confirmation (Rule R1)**: Flutter and Dart CLI tools are **not installed locally** on this macOS development machine. Consequently, `flutter test` and `flutter analyze` cannot execute directly on the local terminal shell without installing the Flutter SDK or invoking it through a containerized/CI runner.

### 3.2 CI/CD and Quality Gates Pipeline
The authoritative build and verification specification is codified in `.github/workflows/ci.yml` and `tools/gates.sh`:
- CI Runner: `ubuntu-latest`
- Flutter Setup: `subosito/flutter-action@v2` with `channel: stable`, `cache: true`
- Java & Android SDK: Java 17 Temurin, Android `platform-tools`
- `tools/gates.sh` runs the following sequential gates:
  1. `flutter pub get`
  2. `dart format --output=none --set-exit-if-changed .`
  3. `flutter analyze`
  4. `flutter test --exclude-tags capturas`
  5. Content gates:
     - `check_contact_email.py` (`frank.alberto.betances.reinoso@gmail.com`)
     - `check_bundled_assets.py` (verifies every asset requested in code exists in `pubspec.yaml` and on disk)
     - `check_laminas.py` (verifies all vector shapes render)
     - `check_no_emoji.py` (forbids system emojis; requires custom icon sets)
     - `export_voice_corpus.py --check`
     - `check_pulse_bpm.py`
     - `check_pulse_markers.py`
     - `check_voice_coverage.py`
     - `check_voice_levels.py`
     - `check_manual_build.py`
     - `check_legal_urls.py --offline`
  6. Binary release gate:
     - `flutter build apk --release`
     - Permission inspection of release APK verifying zero network permissions.

---

## 4. Current Architecture & File Inspection

### 4.1 Dependency & Asset Declarations (`pubspec.yaml`)
- **Package ID / Name**: `descubre_con_lua`
- **SDK Constraint**: `^3.0.0`
- **Dependencies**: Zero external dependencies. Only `flutter: sdk: flutter`.
- **Dev Dependencies**: `flutter_test: sdk: flutter`, `flutter_lints: ^5.0.0`.
- **Declared Asset Paths** (14 entries):
  ```yaml
  - assets/content/unidades/
  - assets/content/capsulas/
  - assets/content/premios/
  - assets/content/calendario/
  - assets/content/asamblea/
  - assets/content/formacion/
  - assets/content/asambleas_primeiro_ciclo/
  - assets/content/progresion/
  - assets/content/asambleas_segundo_ciclo/
  - assets/audio/
  - assets/brand/
  - assets/brand/logos/
  - assets/brand/awards/
  - assets/brand/laminas/
  - assets/voice/
  - assets/fonts/
  ```
- **Fonts**: Custom font family `Nunito` with weights 400 (Regular), 600 (SemiBold), 700 (Bold), 800 (ExtraBold).

### 4.2 Security & Privacy Verification (`android/app/src/main/AndroidManifest.xml`)
- Verification in manifest:
  ```xml
  <uses-permission android:name="android.permission.INTERNET" tools:node="remove" />
  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" tools:node="remove" />
  <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" tools:node="remove" />
  ```
- Verified attributes:
  - `allowBackup="false"`
  - Zero positive `<uses-permission>` tags.
  - Matches requirements tested by `test/privacy/privacy_manifest_test.dart`.

### 4.3 Core Architecture (`lib/core/`)
- **`lib/core/localization/`**:
  - `AppLanguage`: Enum supporting `.gl` (Galego) and `.es` (Castellano). Has `.toggle()`, `.clave`, `.nomeCurto`.
  - `LocalizedString`: Immutable bilingual value object with fields `gl` and `es`. Provides `resolve(lang)`, `fromJson(map)`, `toJson()`, `hasParity`, and `copyWith()`.
- **`lib/core/audio/`**:
  - `OfflineAudioService`: Pure Dart abstract contract defining `playAsset`, `pause`, `stop`, `isPlayingStream`, `isPlaying`, `currentAssetPath`, `dispose`.
  - `LocalAudioPlayer`: Concrete implementation using `MethodChannel('com.earlify.descubreconlua/audio')` to drive Android's `MediaPlayer`.
  - `MockOfflineAudioService`: Mock service for unit tests.
  - `VoiceId`: Pure deterministic SHA-256 identifier mapping text locutions to offline `.m4a` assets.
  - `BotonEscuchar`: Audio trigger widget that renders only when the corresponding offline `.m4a` asset exists.
- **`lib/core/storage/`**:
  - `LocalStore`: Atomic file read/write using `getFilesDir()` via method channel without `path_provider`. Writes to `.tmp` file and renames atomically.
  - `CalendarioStore`: `ChangeNotifier` storing daily attendance and activity checks (`aula` and `hogar` booleans per `yyyy-mm-dd`).
  - *Architecture Note for R4*: The requirement mentions persisting user progress via `SharedPreferences`. In this project, `LocalStore` is already the established zero-dependency standard for private persistent storage. Implementing `progress_service.dart` with `LocalStore` adheres strictly to zero-dependency and zero-network rules.
- **`lib/core/theme/app_theme.dart`**:
  - Color palette: `primary` (`#00C4BE`), `primaryDark` (`#00A39E`), `primaryInk` (`#127A75`), `primaryLight` (`#E6F9F8`), `card` (`#FFFFFF`), `pageBg` (`#F6FAFA`), `textPrimary` (`#1F2937`), `textSecondary` (`#4B5563`), `dark` (`#0B1220`).
  - Strict 4px spacing grid (`spaceXs: 4`, `spaceSm: 8`, `spaceMd: 12`, `spaceLg: 16`, `spaceXl: 24`, `spaceXxl: 32`).
  - Radii: `radiusCard: 16.0`, `radiusField: 12.0`, `radiusButton: 14.0`.

### 4.4 Data Layer & Models (`lib/data/models/` and `content_repository.dart`)
- **Coding Conventions**:
  - All classes annotated `@immutable`.
  - Final fields with strongly typed null-safety.
  - Factory constructor `fromJson(Map<String, dynamic> json)`.
  - Resilient deserialization supporting both camelCase and snake_case keys.
  - Deserialization of `LocalizedString` handles nested maps as well as raw strings fallback.
  - Method `toJson()` returns `Map<String, dynamic>`.
  - Equality (`operator ==`) and `hashCode` implemented via `Object.hash`.
- **`ContentRepository` (`lib/data/repositories/content_repository.dart`)**:
  - Initializes asynchronously using asset discovery (`AssetManifest.loadFromAssetBundle(rootBundle)`).
  - Maintains in-memory indexes by ID for units, capsules, assemblies, and daily progression.
  - Uses synchronization latch (`_initFuture`) preventing redundant concurrent initialization.
  - Tracks load failures via `ContentLoadFailure` list (`loadErrors`, `hasLoadErrors`).

### 4.5 Features & Presentation (`lib/features/`)
- Existing modules:
  - `features/juega/`: Educator assembly flows for 1st cycle (0-3) and 2nd cycle (3-6) (`unidades_list_screen.dart`, `asamblea_guiada_screen.dart`, `asamblea_player_screen.dart`, `backstage_asamblea_screen.dart`).
  - `features/academy/`: Parent/family development blocks (`bloques_list_screen.dart`, `capsula_detail_screen.dart`, `guia_atencion_screen.dart`, `micro_rutina_setembro_screen.dart`).
  - `features/calendario/`: Sincronización Escola · Fogar (`calendario_screen.dart`, 1,395 lines).
  - `features/premios/`: Gamification for the adult educator/parent (`premios_repository.dart`, `premios_screen.dart`, `lua_game_strip.dart`).
  - `features/bienvenida/` and `features/creditos/`.
- Entry point (`lib/main.dart`):
  - Initializes repositories, stores, and audio player.
  - Uses standard Flutter routing (`MaterialApp.routes` and `onGenerateRoute`).
  - Current `HomeScreen` displays a single list of modules (`Juega con Lúa`, `Calendario Escola · Fogar`, `Academy · Familias`, `Premios`, `Formación`).

---

## 5. Migration Roadmap & Gap Analysis (React -> Flutter)

Based on `ORIGINAL_REQUEST.md` (Follow-up 2026-09-20T14:51:45Z), the following gaps must be addressed:

### Gap 1: Pedagogical JSON Assets (Requirement R1)
The following asset folders and files must be generated in `assets/content/` and declared in `pubspec.yaml`:
1. `assets/content/cuentos/`:
   - `banco200_cuentos.json` (200 stories)
   - `banco100_cuentos.json` (100 extra stories)
   - `historias_progresivas.json`
2. `assets/content/laminas/`:
   - `banco200_laminas.json` (200 illustrated cards)
3. `assets/content/calendario/`:
   - `curriculo_50_meses.json` (5 courses × 10 months)
   - `calendario_dias.json` (1000 school days)
   - `calendario_3_6_anos.json`
4. `assets/content/english/`:
   - `english_corpus.json`
   - `collocations_grammar.json`
   - `phonics_taxonomy.json` (44 English phonemes)
5. `assets/content/corpus/`:
   - `bnc_coca_8000.json` (>= 7,500 words)
   - `bnc_coca_8000_cefr.json`
6. Root `assets/content/`:
   - `estrategias_pedagogicas.json`
   - `dinamicas_aula.json`
   - `lua_art.json`

### Gap 2: Dart Data Models (Requirement R2)
New immutable models required in `lib/data/models/`:
- `cuento_model.dart`
- `lamina_model.dart`
- `corpus_palabra_model.dart`
- `dia_calendario_dual_model.dart`
- `fsrs_card_model.dart`
- `english_corpus_model.dart`
- `phonics_model.dart`
- `estrategia_model.dart`
- `dinamica_model.dart`
- Extending `ContentRepository` with loaders and indexed accessors for each new dataset.

### Gap 3: New Feature Screens (Requirement R3)
At least 10 new screens under `lib/features/`:
- `lib/features/cuentos/views/`: `cuentos_list_screen.dart`, `cuento_viewer_screen.dart`
- `lib/features/laminas/views/`: `laminas_gallery_screen.dart`, `lamina_detail_screen.dart`
- `lib/features/palabras/views/`: `palabras_8000_screen.dart`
- `lib/features/english/views/`: `english_hub_screen.dart`, `fsrs_trainer_screen.dart`, `collocations_screen.dart`, `listening_screen.dart`
- `lib/features/lectura/views/`: `aprender_a_ler_screen.dart`, `alphabot_screen.dart`, `phonix_quest_screen.dart`
- `lib/features/planificador/views/`: `planificador_screen.dart`, `estrategias_screen.dart`, `dinamicas_screen.dart`

### Gap 4: Dual Portal Navigation & Services (Requirement R4)
- **Portal Dual**: Update `lib/main.dart` or `home_screen.dart` to offer top-level role navigation: **Familias** vs **Docentes** (distinct tab/module sets).
- **Calendar Extension**: Extend `lib/features/calendario/` to cover all 5 courses (0-2, 2-3, 3-4, 4-5, 5-6) and dual day-by-day views.
- **FSRS Algorithm**: Port `fsrsAlgorithm.ts` to `lib/core/fsrs_service.dart`.
- **User Progress**: Implement `UserProgressService` in `lib/core/progress_service.dart` backed by `LocalStore` for zero-network private persistence.

---

## 6. Recommendations for Implementation Phase

1. **Maintain Zero-Dependency Purity**: Implement `progress_service.dart` using the existing `LocalStore` rather than adding `shared_preferences` to `pubspec.yaml`, preserving the project's zero-third-party-package policy.
2. **Asset Directory Registration**: When creating new subdirectories under `assets/content/` (`cuentos/`, `laminas/`, `english/`, `corpus/`), immediately add each path to `pubspec.yaml` under `flutter.assets` to prevent missing asset errors.
3. **Audio Handling**: Ensure story viewer and listening screens reference pre-existing voice assets or fallback gracefully to adult-guided text reading when an audio recording is absent (complying with rule R1 and `BotonEscuchar` pattern).
4. **Targeted Branch Discipline**: Confirm all changes are committed strictly to `studio` with commit message format `feat(studio): ...`, keeping `main` untouched.
