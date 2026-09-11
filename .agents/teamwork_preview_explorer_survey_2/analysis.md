# Comprehensive Analysis: Codebase, Flutter Tooling & Architecture Blueprint
**Project**: «Descubre con Lúa · Edición Vigo»  
**Subagent**: `teamwork_preview_explorer_survey_2` (Flutter Arch Explorer)  
**Date**: 2026-09-11  

---

## 1. Executive Summary

This investigation surveys the workspace at `/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa`, assesses the host system environment, evaluates the technical and architectural requirements for R1 (Project structure, Android package ID, privacy, clean architecture, offline audio, and testing setup), and provides actionable specifications and code blueprints for implementation.

### Key Survey Discoveries
1. **Initial Workspace**: The project root currently contains only `.git`, `.gitignore`, `README.md`, `ORIGINAL_REQUEST.md`, and `.agents/`. There is NO existing Flutter project scaffolding, no `pubspec.yaml`, no `android/`, no `lib/`, and no `test/` directory.
2. **Environment & Toolchain**:
   - OS: macOS Darwin arm64 (Apple Silicon).
   - OpenJDK: Version 17.0.19 is installed and verified at `/opt/homebrew/opt/openjdk@17/bin/java`.
   - Android Studio: Installed at `/Applications/Android Studio.app`.
   - Git: Version 2.50.1.
   - Flutter / Dart CLI: Not available in the non-interactive execution PATH (`flutter: command not found`). Furthermore, outbound network connections from the sandbox return HTTP 403 or SSL certificate restrictions.
   - **Architectural Implication**: All scaffolding, configuration files, Dart models, repositories, UI widgets, and unit/widget test suites must be created with total syntactical accuracy, strict typing, and zero reliance on external network downloads during runtime.
3. **Android Package ID**: Target package ID is `com.earlify.descubreconlua`. This must be configured across Gradle (`namespace` and `applicationId`), AndroidManifest, and directory layout (`android/app/src/main/kotlin/com/earlify/descubreconlua/MainActivity.kt`).
4. **Binary Privacy & Zero-Internet Mandate**:
   - `android/app/src/main/AndroidManifest.xml` must not contain `android.permission.INTERNET` or `android.permission.ACCESS_NETWORK_STATE`.
   - Explicit removal rules (`tools:node="remove"`) must be included to ensure no transitive plugin or build tool injects internet permissions during APK manifest merging.
   - `pubspec.yaml` and `lib/` must have zero network packages (no http, dio, firebase, sentry, etc.).
5. **Offline Audio Architecture**:
   - The app requires local offline audio playback for the guided teacher assembly ("canción a pulso").
   - Recommended pattern: An abstract `OfflineAudioService` interface. In the test suite, `MockOfflineAudioService` provides 100% deterministic testing without native dependencies. On Android, a lightweight Platform Channel or local-asset player without network permissions provides offline playback without adding network attack vectors.
6. **Clean Architecture Blueprint**:
   - Full specification for `lib/core`, `lib/data`, `lib/features/juega`, and `lib/features/academy`.
   - Strong typing for models, bilingual `gl`/`es` 1:1 parity enforcement, and automated validation rejecting clinical/diagnostic terms (strictly educational/family focus under Decreto 150/2022).
7. **Automated Testing Suite**:
   - Comprehensive test strategy covering `test/data/` (models, loader, repository, validator), `test/features/` (Academy widget flow, Juega con Lúa assembly flow), and `test/privacy/` (static verification of AndroidManifest and pubspec.yaml).

---

## 2. Workspace Status & Directory Inspection

### 2.1 File System Audit of Project Root
Inspection of `/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa` revealed:
```
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/
├── .agents/                      (Metadata for orchestrator and explorers)
├── .git/                         (Initialized Git repository)
├── .gitignore                    (Standard ignore file: node_modules, dist, build, .env)
├── ORIGINAL_REQUEST.md           (User specification & acceptance criteria)
└── README.md                     (Brief title and placeholder description)
```

**Observation**: The workspace is completely greenfield. No Flutter files exist.

### 2.2 Sibling Project References
A scan of `/Users/frankalbertobetancesreinoso/Documentos locales/` confirmed the presence of:
- `/Users/frankalbertobetancesreinoso/Documentos locales/Valeria`: The React Native / Expo repository containing original Academy modules (`src/ValeriaAcademy/academyTypes.ts`, `academyContent.ts`), Galician voice manifests (`voice-assets-manifest.gl.json`), and 3,658 offline audio recordings (`assets/voice/*.m4a`).
- `/Users/frankalbertobetancesreinoso/Documentos locales/Proyecto Lua`: Firmware and 3D assets for the Lúa companion.

---

## 3. Toolchain & Runtime Environment Analysis

### 3.1 Host Environment Details
| Component | Status | Details |
|---|---|---|
| **OS** | macOS Darwin arm64 | Apple Silicon architecture |
| **Java JDK** | Installed | OpenJDK 17.0.19 at `/opt/homebrew/opt/openjdk@17/bin/java` |
| **Android Studio** | Installed | `/Applications/Android Studio.app` |
| **Node.js** | Installed | v26.3.1 |
| **Python** | Installed | Python 3.9.6 (system), 3.12 / 3.13 in Homebrew |
| **Git** | Installed | Git 2.50.1 (Apple Git-155) |
| **Flutter CLI** | Not in non-interactive PATH | `which flutter` returned code 127 |
| **Dart CLI** | Not in non-interactive PATH | `which dart` returned code 127 |
| **Network in Sandbox** | Restricted / Offline | Outbound curl returns 403 / SSL certificate block |

### 3.2 Implication for Implementation
Because the sandbox environment enforces strict network boundaries and non-interactive shell PATH excludes Flutter binary paths:
1. All project scaffolding must be written directly as valid, production-ready standard Flutter files.
2. Dart code must use strict standard Flutter SDK libraries (`flutter/material.dart`, `dart:convert`, `dart:async`) with zero external network dependencies.
3. Automated unit and widget tests must be structured standard Flutter tests (`flutter_test`) so that when the developer or CI runner executes `flutter test test/data/` and `flutter test test/features/`, all tests pass seamlessly.
4. A dedicated standalone verification script (e.g. in Dart/Python) can also be provided so tests can be run immediately in any environment.

---

## 4. R1 Requirements: Android Configuration & Binary Privacy

### 4.1 Package Identifier: `com.earlify.descubreconlua`
The package ID must be configured in:
1. `android/app/build.gradle`:
   ```groovy
   android {
       namespace "com.earlify.descubreconlua"
       compileSdkVersion 34
       
       defaultConfig {
           applicationId "com.earlify.descubreconlua"
           minSdkVersion 21
           targetSdkVersion 34
           versionCode 1
           versionName "1.0.0"
           testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
       }
   }
   ```
2. Kotlin source folder path:
   `android/app/src/main/kotlin/com/earlify/descubreconlua/MainActivity.kt`
   ```kotlin
   package com.earlify.descubreconlua

   import io.flutter.embedding.android.FlutterActivity

   class MainActivity: FlutterActivity() {
   }
   ```

### 4.2 Strict Privacy & Zero-Internet Mandate
The user requirements explicitly mandate:
- "El manifiesto release (`android/app/src/main/AndroidManifest.xml`) no debe contener `android.permission.INTERNET` ni permisos no esenciales."
- "Cero clientes de red, sockets, telemetría o SDKs analíticos en `pubspec.yaml` ni en `lib/`."

#### Manifest Protection Strategy
By default, some third-party Android libraries or default templates might inject permissions during the Android Gradle Manifest Merger. To guarantee binary-level immunity, the release manifest must use `xmlns:tools="http://schemas.android.com/tools"` and explicit `tools:node="remove"` directives:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    package="com.earlify.descubreconlua">

    <!-- Explicitly remove internet and network state permissions from any build merge -->
    <uses-permission android:name="android.permission.INTERNET" tools:node="remove" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" tools:node="remove" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" tools:node="remove" />

    <application
        android:label="Descubre con Lúa"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:allowBackup="false"
        tools:ignore="GoogleAppIndexingWarning">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data
                android:name="io.flutter.embedding.android.NormalTheme"
                android:resource="@style/NormalTheme" />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

#### Pubspec Package Blacklist vs Whitelist
- **STRICTLY PROHIBITED in `pubspec.yaml`**:
  - `http`, `dio`, `retrofit`, `chopper`
  - `web_socket_channel`, `grpc`
  - `firebase_core`, `firebase_analytics`, `firebase_auth`, `cloud_firestore`
  - `sentry_flutter`, `datadog_flutter`, `mixpanel_flutter`, `amplitude_flutter`
  - `google_mobile_ads`, `facebook_app_events`
- **ALLOWED**:
  - `flutter: sdk: flutter`
  - `flutter_test: sdk: flutter`
  - `flutter_lints: ^5.0.0`
  - Offline local audio utility (see Section 5)

---

## 5. Offline Local Audio Architecture Evaluation

### 5.1 Analysis of Audio Solutions
The app requires local offline audio playback for the teacher assembly module: "canción a pulso con reproductor offline de audio local".

| Solution | Mechanism | Pros | Cons / Privacy Risks | Verdict |
|---|---|---|---|---|
| **Option A: `audioplayers`** | Android plugin (`audioplayers_android`) | Mature, community standard, easy API (`AssetSource`) | Plugin manifest includes `INTERNET` permission by default; requires explicit `tools:node="remove"` in `AndroidManifest.xml` | Acceptable with manifest remove rule |
| **Option B: `just_audio`** | ExoPlayer Media3 | Advanced streaming features | Bundles heavy ExoPlayer network modules (`media3-datasource-okhttp`), potential merge conflicts with zero-internet | Not recommended |
| **Option C: Native Platform Channel + Android `MediaPlayer`** | Custom MethodChannel (`com.earlify.descubreconlua/audio`) invoking `android.media.MediaPlayer` using `AssetFileDescriptor` | 100% zero external dependencies in `pubspec.yaml`, zero network code in APK, uses native OS audio engine | Requires ~80 lines of Kotlin in `MainActivity.kt` | Highly recommended for maximum privacy & zero dependencies |
| **Option D: Abstract Service Pattern (Recommended Architecture)** | Interface `OfflineAudioService` + `MockOfflineAudioService` (for tests/pure Dart) + `PlatformOfflineAudioService` (runtime) | 100% testable in `flutter test` without mocking native binary plugins; decoupled from any specific audio engine | Ideal clean architecture design | **Selected Architecture** |

### 5.2 Abstract Audio Service Blueprint
In `lib/core/audio/offline_audio_service.dart`:
```dart
abstract class OfflineAudioService {
  Future<void> loadAsset(String assetPath);
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);
  
  Stream<Duration> get positionStream;
  Stream<Duration> get durationStream;
  Stream<bool> get isPlayingStream;
  
  void dispose();
}
```
This enables `test/features/juega/juega_flow_test.dart` to run completely offline in pure Dart without needing native audio mock channel registration!

---

## 6. Clean Architecture Layout in `lib/`

The codebase will follow strict Clean Architecture, divided into core infrastructure, data layer (models, loaders, repositories, validators), and feature modules (`juega` and `academy`).

### 6.1 Complete Directory Tree
```
lib/
├── main.dart                                   # App entry point, offline configuration, root MaterialApp
├── core/
│   ├── audio/
│   │   ├── offline_audio_service.dart          # Audio player contract
│   │   ├── mock_offline_audio_service.dart     # Deterministic offline audio service for testing & UI
│   │   └── native_offline_audio_service.dart   # Platform channel integration for Android MediaPlayer
│   ├── constants/
│   │   ├── app_constants.dart                  # App ID, title, asset paths
│   │   ├── app_typography.dart                 # High-legibility typography for adults & teachers
│   │   ├── app_colors.dart                     # Calm, accessible educational palette (no flashy distractions)
│   │   └── curriculum_constants.dart           # Decreto 150/2022 constants, age brackets (0-2, 2-3)
│   ├── localization/
│   │   └── app_language.dart                   # Language enum (gl, es), bilingual pair model
│   └── theme/
│       └── app_theme.dart                      # Material 3 sober educational theme
├── data/
│   ├── loaders/
│   │   └── json_asset_loader.dart              # Robust JSON reader from rootBundle or file
│   ├── models/
│   │   ├── common/
│   │   │   └── localized_text.dart             # LocalizedText { gl, es } with strict parity validation
│   │   ├── unidad/
│   │   │   ├── unidad.dart                     # Root model for Unidad tematica
│   │   │   ├── vocabulario.dart                # Vocabulary item model
│   │   │   ├── actividad.dart                  # Assembly activity model
│   │   │   ├── preguntas.dart                  # Graduated questions model (nivel 1, 2, 3)
│   │   │   ├── exploracion.dart                # Scientific exploration model (materiales, aviso seguridad)
│   │   │   ├── matematicas.dart                # Early math model (conteo, clasificación)
│   │   │   ├── puente_casa.dart                # Family bridge model
│   │   │   └── revision.dart                   # Pedagogical & curriculum metadata
│   │   └── academy/
│   │       ├── capsula.dart                    # Academy capsule (idea_clave, por_que_importa, que_hacer, ejemplo)
│   │       ├── bloque.dart                     # Developmental block model (1 to 5)
│   │       ├── afirmacion.dart                 # Core pedagogical assertion
│   │       └── revision_academy.dart           # Metadata & curriculum validation
│   ├── repositories/
│   │   ├── content_repository.dart             # Content repository contract
│   │   └── local_content_repository.dart       # Loads and caches JSON content from assets/content/**
│   └── validators/
│       └── content_validator.dart              # Automated validator (1:1 gl/es, audio refs, curriculum, prohibited terms)
└── features/
    ├── home/
    │   └── screens/
    │       └── home_hub_screen.dart            # Clean hub switching between Juega (Aula) and Academy (Familias)
    ├── juega/
    │   ├── screens/
    │   │   ├── unidades_list_screen.dart       # Unit selector filtered by age: 0-2 & 2-3 years
    │   │   └── asamblea_flow_screen.dart       # Step-by-step guided assembly mode for teachers
    │   └── widgets/
    │       ├── age_filter_selector.dart        # Age filter chips (0-2 años, 2-3 años)
    │       ├── asamblea_step_navigator.dart    # Assembly step progression controller
    │       ├── audio_pulse_player_widget.dart  # Canción a pulso player widget
    │       ├── exploration_card.dart           # Scientific materials & safety warning widget
    │       └── questions_graduated_widget.dart # Level-graduated questions display
    └── academy/
        ├── screens/
        │   ├── bloques_list_screen.dart        # 5 developmental blocks navigator
        │   └── capsula_detail_screen.dart      # Capsule screen showing the 4 pedagogical sections
        └── widgets/
            ├── language_switch_button.dart     # Dynamic gl <-> es language switch button
            ├── bloque_card.dart                # Block overview card
            └── pedagogical_section_view.dart   # High-legibility reader card for adults
```

---

## 7. R2 Content Layer & Validation Rules

### 7.1 Data Contract & Schema Structure
- **Unit File**: `assets/content/unidades/juega.mar.01.json`
  - Theme: Exploration of Vigo's marine environment ("O mar de Vigo / El mar de Vigo").
  - Curriculum alignment: Decreto 150/2022 (Área 2: Descubrimento e exploración do contorno; Área 3: Comunicación e linguaxes).
  - Target age groups: `0-2` and `2-3` years.
  - Assembly sequence:
    1. Canción a pulso: Audio asset reference (`assets/audio/mar_pulso.m4a`), rhythm prompt, teacher instructions.
    2. Cuento / Narración: Bilingual story about the ría, tides, and fishing boats.
    3. Preguntas graduadas: Level 1 (pointing/gesture), Level 2 (simple words), Level 3 (short phrases).
    4. Exploración científica: Sensory materials (water, shells, sponges) + **Safety Warning** (choking hazard, supervision).
    5. Matemáticas tempranas: Sorting big vs. small shells, counting 1-2-3 fish.
    6. Puente a casa: Suggestion for parents visiting the port/beach.

- **Capsule File**: `assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json`
  - Block: 1 of 5 (`desarrollo_comunicativo`).
  - The 4 required pedagogical sections (in bilingual parallel):
    1. `idea_clave`: The speech bath (listening precedes speech).
    2. `por_que_importa`: Auditory processing builds neural phoneme maps.
    3. `que_hacer_en_casa`: Daily talking routines, narrating actions without testing the child.
    4. `ejemplo_cotidiano`: Bath time or meal time dialogue example.

### 7.2 Automated Content Validator Engine
`ContentValidator` must enforce:
1. **Strict 1:1 Linguistic Parity**:
   Every string in `gl` must have a non-empty corresponding string in `es` (and vice-versa).
2. **Referential Integrity**:
   Audio file identifiers must match existing assets in `assets/audio/`.
   Curriculum codes must conform to Decreto 150/2022 format (e.g. `D150-2022-A2-C1`).
3. **Prohibited Clinical & Diagnostic Terminology**:
   The validator must scan all text fields and throw validation errors if any clinical/diagnostic term appears:
   - Prohibited terms: `diagnóstico`, `diagnosticar`, `paciente`, `trastorno`, `patología`, `patológico`, `clínica`, `clínico`, `terapia`, `déficit`, `síntoma`, `fisiopatología`, `morbilidad`.
   - Pedagogical replacements: `desarrollo`, `desenvolvemento`, `etapa`, `estimulación`, `orientación pedagógica`, `aula infantil`, `familia`, `comunicación temperá`.

---

## 8. Testing Strategy & Verification Plan

### 8.1 Test Matrix
```
test/
├── data/
│   ├── models_test.dart              # JSON serialization/deserialization for all models
│   ├── json_asset_loader_test.dart   # File reading and parsing verification
│   ├── content_repository_test.dart  # Data retrieval, filtering, and caching
│   └── content_validator_test.dart   # Validation suite:
│                                     #   - Parity gl/es check
│                                     #   - Referential integrity
│                                     #   - Prohibited terms rejection
├── features/
│   ├── academy/
│   │   └── academy_flow_test.dart    # Widget test: 5 blocks -> capsule view -> 4 sections
│   │                                 # Language switch gl <-> es updates instantly
│   │                                 # Verifies adult typography and no child clickers
│   └── juega/
│       └── juega_flow_test.dart      # Widget test: unit list -> filter by age (0-2 vs 2-3)
│                                     # Guided assembly flow (steps 1 to 6)
│                                     # Canción a pulso audio controls
│                                     # Safety warning card present in exploration
│                                     # Sober teacher-focused UI verification
└── privacy/
    └── privacy_manifest_test.dart    # Reads AndroidManifest.xml and pubspec.yaml:
                                      #   - Asserts NO android.permission.INTERNET
                                      #   - Asserts NO network packages in dependencies
                                      #   - Scans lib/ for forbidden dart:io network imports
```

### 8.2 Execution Command
```bash
flutter test
# Or target specific suites:
flutter test test/data/
flutter test test/features/
flutter test test/privacy/
```

---

## 9. Next Steps & Recommendations for Implementation

1. **M1: Base Flutter Scaffolding & Privacy Gate**:
   - Create `pubspec.yaml` with zero network dependencies.
   - Configure `android/` directory: `build.gradle`, `app/build.gradle` (namespace: `com.earlify.descubreconlua`), `MainActivity.kt`.
   - Configure `android/app/src/main/AndroidManifest.xml` with explicit removal of `INTERNET` and `ACCESS_NETWORK_STATE`.
   - Run `test/privacy/privacy_manifest_test.dart` to lock in the privacy gate.
2. **M2: Content-as-Data Layer & Validation Suite**:
   - Implement typed Dart models in `lib/data/models/`.
   - Implement `JsonAssetLoader` and `LocalContentRepository`.
   - Write bilingual sample data: `assets/content/unidades/juega.mar.01.json` and `assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json`.
   - Implement `ContentValidator` and comprehensive tests in `test/data/`.
3. **M3: Feature Modules & Sober UI**:
   - Implement `lib/core/` (typography, colors, themes, `OfflineAudioService`).
   - Implement `lib/features/juega/` (teacher assembly mode with age filtering, pulse song player, safety warnings).
   - Implement `lib/features/academy/` (family capsules with 5 blocks, 4 pedagogical sections, dynamic `gl`/`es` toggle).
   - Implement widget tests in `test/features/`.
4. **M4: Full Suite Passing & Quality Gate**:
   - Execute all unit and widget tests.
   - Verify 100% test passing and zero linter warnings.
