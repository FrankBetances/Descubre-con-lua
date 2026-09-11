# Project: Descubre con Lúa · Edición Vigo

## Architecture
Clean architecture decoupled into four layers:
- `lib/core/`:
  - `theme/`: Material 3 theme adapted for adults/teachers (typography >= 16sp, contrast, sober palette, zero child-distracting neon/animations).
  - `audio/`: `OfflineAudioService` interface, `LocalAudioPlayer` native implementation, and `MockOfflineAudioService` for deterministic widget testing without hardware.
  - `localization/`: `AppLanguage` enum (`gl`, `es`), `LocalizedString` value object, and runtime language state.
- `lib/data/`:
  - `models/`: Strongly typed immutable data models for thematic units (`Unidad`, `Vocabulario`, `Actividad`, `Preguntas`, `Exploracion`, `Matematicas`, `PuenteCasa`, `Revision`) and Academy capsules (`Capsula`, `Bloque`, `Afirmacion`, `Revision`).
  - `loaders/`: `ContentAssetLoader` loading JSON assets from `assets/content/**`.
  - `repositories/`: `ContentRepository` providing query and filter methods for units and capsules.
  - `validators/`: `ContentValidator` enforcing 1:1 bilingual parity, Decreto 150/2022 curricular references, and clinical term blacklist.
- `lib/features/juega/`:
  - `views/`: Unit selector with age band filtering (0-2 years, 2-3 years) and 6-step guided assembly wizard for teachers (`Paso1Cancion`, `Paso2Cuento`, `Paso3Preguntas`, `Paso4Exploracion`, `Paso5Matematicas`, `Paso6PuenteCasa`).
  - `widgets/`: Teacher control cards, safety notices (pieces > 4cm, direct supervision), offline audio pulse controller.
- `lib/features/academy/`:
  - `views/`: 5 developmental blocks list and 4-part capsule reader (`IdeaClave`, `PorQueImporta`, `QueHacerEnCasa`, `EjemploCotidiano`).
  - `widgets/`: Dynamic language switcher (`gl`/`es`), high-legibility cards, reflection confirmation.
- `test/`:
  - `data/`: Unit tests for models, loaders, repositories, and automated validators.
  - `features/`: Widget tests for Academy and Juega con Lúa user flows.
  - `privacy/`: Binary and manifest privacy test verifying zero network permissions and zero network packages.

## Feature Inventory
| # | Feature | Description | Milestone | Source |
|---|---------|-------------|-----------|--------|
| 1 | Package ID & Flutter Scaffolding | Android package `com.earlify.descubreconlua`, Gradle namespace, Kotlin MainActivity | M1 | Survey / R1 |
| 2 | Clean Architecture Directory Setup | Scaffolding for `lib/core/`, `lib/data/`, `lib/features/juega/`, `lib/features/academy/` | M1 | Survey / R1 |
| 3 | Binary Privacy & Zero-Internet Manifest | Strict removal of `android.permission.INTERNET` and network permissions in release manifest | M1 | Survey / R1 |
| 4 | Zero Network Dependencies Audit | `pubspec.yaml` and `lib/` strictly free of HTTP, sockets, Firebase, analytics | M1 | Survey / R1 |
| 5 | Offline Audio Service Core | `OfflineAudioService` interface, `MockOfflineAudioService`, local asset playback architecture | M1 | Survey / R1 |
| 6 | Unit Data Models | `Unidad`, `Vocabulario`, `Actividad`, `Preguntas`, `Exploracion`, `Matematicas`, `PuenteCasa`, `Revision` | M2 | Survey / R2 |
| 7 | Academy Data Models | `Capsula`, `Bloque`, `Afirmacion`, `Revision`, `ContidoCapsula` | M2 | Survey / R2 |
| 8 | Bilingual Asset Loader & Repo | `ContentAssetLoader` & `ContentRepository` for parallel `gl`/`es` resolution | M2 | Survey / R2 |
| 9 | Vigo Maritime Base Unit | `assets/content/unidades/juega.mar.01.json` (Samil, bateas, ría de Vigo, pulso 72 BPM) | M2 | Survey / R2 |
| 10 | Academy Base Capsule | `assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json` (baño de lenguaje, 5s espera) | M2 | Survey / R2 |
| 11 | Bilingual Parity Validator | Unit test suite verifying 1:1 non-empty parity between `gl` and `es` across all fields | M2 | Survey / R2 |
| 12 | Decreto 150/2022 Validator | Unit test suite validating curricular references (Áreas 1, 2, 3 do 1º ciclo de infantil) | M2 | Survey / R2 |
| 13 | Clinical Term Blacklist Validator | Regex linter rejecting diagnostic, pathological, or therapy terms | M2 | Survey / R2 |
| 14 | Referential Integrity Validator | Unit test verifying references to offline audio assets and required sections | M2 | Survey / R2 |
| 15 | Academy 5 Blocks Navigation | 5 developmental blocks navigation (`comunicacion_linguaxe`, `desenvolvemento_socioemocional`, etc.) | M3 | Survey / R3 |
| 16 | Academy 4-Part Capsule View | 4 canonical sections: Idea clave, Por que importa, Que facer na casa, Exemplo cotián | M3 | Survey / R3 |
| 17 | Academy Adult-Only UI | Dynamic `gl`/`es` switcher, large typography (>= 16sp), zero external web links, zero child mechanics | M3 | Survey / R3 |
| 18 | Juega con Lúa Unit Selector | Age band filter (0-2 years and 2-3 years), unit listing | M3 | Survey / R3 |
| 19 | Juega con Lúa 6-Step Assembly | Step-by-step guided mode: canción a pulso, conto, preguntas por nivel, exploración segura, matemáticas, ponte á casa | M3 | Survey / R3 |
| 20 | Classroom Safety Notices | Explicit safety alert for manipulative materials (>4 cm, direct teacher supervision) | M3 | Survey / R3 |
| 21 | Sober Teacher UI & Zero Child Distractions | High readability, clean layout, no gamification/animations/touch game mechanics for toddlers | M3 | Survey / R3 |
| 22 | Offline Audio Asset Bundling | Procedural pulse audio asset `assets/audio/mar_pulso_72bpm.wav` at 72 BPM | M3 | Survey / R3 |
| 23 | Privacy & Security Automated Tests | Unit test verifying zero internet permissions in AndroidManifest.xml and zero network packages in pubspec.yaml | M4 | Acceptance Criteria |
| 24 | Content & Models Unit Test Suite | 100% passing tests for data models, loaders, repository, and validators | M4 | Acceptance Criteria |
| 25 | Academy Widget Test Suite | 100% passing widget tests for 5 blocks list, 4-part capsule reader, and language switching | M4 | Acceptance Criteria |
| 26 | Juega con Lúa Widget Test Suite | 100% passing widget tests for age filtering, unit selection, and 6-step assembly flow | M4 | Acceptance Criteria |
| 27 | E2E Regression & Verification Test Suite | Full automated execution of all test suites (`flutter test`) with exit code 0 | M4 | Acceptance Criteria |

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| 1 | M1: Base Flutter Android Setup & Privacy | Scaffolding, `pubspec.yaml`, `android/` setup (`com.earlify.descubreconlua`), zero internet permission manifest, `lib/core/` and `OfflineAudioService` | none | DONE |
| 2 | M2: Content-as-Data, JSON Assets & Validation Suite | Dart models, `ContentAssetLoader`, `ContentRepository`, base JSONs (`juega.mar.01.json`, `academy.como_se_aprende_a_hablar.01.json`), automated validation test suite (`test/data/`) | M1 | DONE |
| 3 | M3: Pedagogical Modules (Academy & Juega con Lúa) | Academy 5 blocks & 4-part capsule screens, Juega con Lúa 6-step assembly flow with offline audio controller, offline audio asset bundling | M2 | DONE |
| 4 | M4: Comprehensive Verification & E2E Testing | Automated privacy tests, widget tests for Academy & Juega con Lúa, full regression suite passing with exit code 0 | M3 | IN_PROGRESS |

## Interface Contracts

### Content Models & LocalizedString
```dart
class LocalizedString {
  final String gl;
  final String es;
  const LocalizedString({required this.gl, required this.es});
  String resolve(AppLanguage lang) => lang == AppLanguage.gl ? gl : es;
}

class Unidad {
  final String id;
  final LocalizedString titulo;
  final String tramoEtario; // '0-2' | '2-3'
  final CurricularReference curricular;
  final CancionPulso cancion;
  final ContoCotián conto;
  final List<PreguntaNivel> preguntas;
  final ExploracionSensorial exploracion;
  final MatematicasTempras matematicas;
  final PonteCasa ponteCasa;
}

class Capsula {
  final String id;
  final String bloqueId; // 1 to 5
  final LocalizedString titulo;
  final ContidoCapsula contido;
}
```

### Offline Audio Service
```dart
abstract class OfflineAudioService {
  Future<void> playAsset(String assetPath);
  Future<void> pause();
  Future<void> stop();
  Stream<bool> get isPlayingStream;
  void dispose();
}
```

## Code Layout
```
lib/
├── main.dart
├── core/
│   ├── theme/
│   │   └── app_theme.dart
│   ├── audio/
│   │   ├── offline_audio_service.dart
│   │   └── mock_offline_audio_service.dart
│   └── localization/
│       ├── app_language.dart
│       └── localized_string.dart
├── data/
│   ├── models/
│   │   ├── curricular_model.dart
│   │   ├── unidad_model.dart
│   │   └── capsula_model.dart
│   ├── loaders/
│   │   └── content_asset_loader.dart
│   ├── repositories/
│   │   └── content_repository.dart
│   └── validators/
│       └── content_validator.dart
├── features/
│   ├── home/
│   │   └── home_screen.dart
│   ├── juega/
│   │   ├── views/
│   │   │   ├── unidades_list_screen.dart
│   │   │   └── asamblea_guiada_screen.dart
│   │   └── widgets/
│   │       ├── paso_cancion_widget.dart
│   │       ├── paso_conto_widget.dart
│   │       ├── paso_preguntas_widget.dart
│   │       ├── paso_exploracion_widget.dart
│   │       ├── paso_matematicas_widget.dart
│   │       └── paso_ponte_casa_widget.dart
│   └── academy/
│       ├── views/
│       │   ├── bloques_list_screen.dart
│       │   └── capsula_detail_screen.dart
│       └── widgets/
│           ├── seccion_capsula_widget.dart
│           └── selector_idioma_widget.dart
assets/
├── content/
│   ├── unidades/
│   │   └── juega.mar.01.json
│   └── capsulas/
│       └── academy.como_se_aprende_a_hablar.01.json
└── audio/
    └── mar_pulso_72bpm.wav
test/
├── data/
│   ├── models_test.dart
│   ├── content_loader_test.dart
│   ├── bilingual_parity_test.dart
│   ├── curricular_alignment_test.dart
│   ├── clinical_terms_blacklist_test.dart
│   └── referential_integrity_test.dart
├── features/
│   ├── academy/
│   │   └── academy_flow_test.dart
│   └── juega/
│       └── juega_flow_test.dart
└── privacy/
    └── privacy_manifest_test.dart
```
