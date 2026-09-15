# Project: Descubre con Lúa · Edición Vigo (Segundo Ciclo 3-6 Anos · TPR & Asamblea)

## Architecture
Clean architecture extension for Segundo Ciclo de Educación Infantil (3-6 years: 4.º, 5.º, 6.º Infantil) under Decreto 150/2022 de Galicia:
- `lib/core/`:
  - `theme/app_theme.dart`: Backstage dark theme tokens (background `#0B1220`, surface `#131D31`, text >= 26sp, touch target >= 64dp).
  - `audio/fade_audio_coordinator.dart`: Smooth audio volume fade coordinator wrapping `OfflineAudioService`.
- `lib/data/`:
  - `models/asamblea_segundo_ciclo_model.dart`: Strongly typed immutable data models (`AsambleaSegundoCiclo`, `FaseAsamblea`, `ComandoTPR`, `MaterialNatural`, `CurricularReferenceSegundoCiclo`, `MicroRutinaHogarSegundoCiclo`).
  - `loaders/content_asset_loader.dart`: Loading from isolated directory `assets/content/asambleas_segundo_ciclo/`.
  - `repositories/content_repository.dart`: Methods for querying Segundo Ciclo assemblies by month and level with `_initFuture` latch.
  - `validators/content_validator.dart`: Validation of the 4 canonical phases, Decreto 150/2022 alignment, clinical blacklist, and case-sensitive placeholder fix.
- `lib/features/juega/`:
  - `views/backstage_asamblea_screen.dart`: Dedicated teacher backstage interface (dark mode, glanceable UI, readable at 2m, zero child gamification).
  - `views/unidades_list_screen.dart`: Continuous cycle switcher `[ 1.er Ciclo (0-3) | 2.º Ciclo (3-6) ]` without altering 0-3 flows.
  - `widgets/backstage/`: Phase timer (`BackstagePhaseTimerWidget`), phase stepper (`BackstagePhaseStepper`), level switcher (`BackstageLevelSwitcher`), and phase widgets (`PasoOpeningWidget`, `PasoRhythmWidget`, `PasoCoreTprWidget`, `PasoCalmWidget`).
- `lib/features/academy/`:
  - `views/micro_rutina_setembro_screen.dart`: Family micro-routine for September (getting dressed / hanging coats) with recast guidance.
  - `widgets/recast_guia_card.dart`: Interactive recast comparison table and audio modeling.
- `test/`:
  - `data/asamblea_segundo_ciclo_models_test.dart`: Model parsing, serialization, and invariants.
  - `data/asamblea_segundo_ciclo_stress_test.dart`: Deep structural equality, malformed JSON defense, and mutation resistance.
  - `data/placeholder_validator_test.dart`: Case-sensitive placeholder validation.
  - `data/asamblea_segundo_ciclo_validation_test.dart`: Curricular, phase duration, and content integrity validator tests.
  - `features/juega/backstage_asamblea_test.dart`: Widget test suite for backstage teacher UI, discrete timer, audio auto-fade, and level switching.
  - `features/academy/recast_guia_test.dart`: Widget test suite for Academy home micro-routine and recast guide.

## Feature Inventory
| # | Feature | Description | Milestone | Source |
|---|---------|-------------|-----------|--------|
| 1 | Immutable Models for Segundo Ciclo | `AsambleaSegundoCiclo`, `FaseAsamblea`, `ComandoTPR`, `MaterialNatural`, `CurricularReferenceSegundoCiclo` | M1 | Survey / R1 (DONE) |
| 2 | Isolated Asset Loader & Repo Extension | Load JSON assets from `assets/content/asambleas_segundo_ciclo/` preserving existing 0-3 loaders | M1 | Survey / R1 (DONE) |
| 3 | Case-Sensitive Placeholder Pattern Fix | Fix `placeholderPattern` in `ContentValidator` with `caseSensitive: true` to prevent false positive on "todo" | M1 | Survey / STATUS.md (DONE) |
| 4 | September Vertical Slice for 4.º Infantil | Action-Expanded TPR JSON content (2-phase commands with "and", fading, silent period) | M2 | Survey / R3 |
| 5 | September Vertical Slice for 5.º Infantil | Dramatized/Narrative TPR JSON content (backpack story, stop-signal/freeze, praxias) | M2 | Survey / R3 |
| 6 | September Vertical Slice for 6.º Infantil | Transactional/Peer-to-peer TPR JSON content (textless cue cards, partner coat hanging) | M2 | Survey / R3 |
| 7 | September Academy Home Micro-routine | Time & Place (3-5 min) daily niche with indirect corrective modeling (recast) | M2 | Survey / R3 |
| 8 | Segundo Ciclo Content Validator | Enforces 4 phases (90s, 120s, 270s, 120s = 600s), Decreto 150/2022, natural materials, and clinical blacklist | M2 | Survey / R4 |
| 9 | Backstage Dark Theme Tokens | Theme tokens in `AppTheme`: background `#0B1220`, surface `#131D31`, text >= 26sp, touch target >= 64dp | M3 | Survey / R2 |
| 10 | Fade Audio Coordinator | Audio service wrapper managing 800-1200ms volume fades and auto-pause on phase transitions | M3 | Survey / R2 |
| 11 | Discrete Silent Phase Timer | Tabular countdown timer (34sp), gentle overtime color shift (amber), zero acoustic alarms | M3 | Survey / R2 |
| 12 | 4-Phase Stepper & Navigation | Horizontal progress stepper with active phase highlight and direct phase jumping | M3 | Survey / R2 |
| 13 | Continuous Level Switcher | Dynamic 4º / 5º / 6º level switcher in backstage screen adapting Phase 3 without resetting timer | M3 | Survey / R2 |
| 14 | Backstage Asamblea Screen | Teacher-only guided assembly interface with zero child gamification or screens | M3 | Survey / R2 |
| 15 | App Navigation Integration | Dedicated HomeScreen entry card and UnidadesListScreen cycle switcher tab (0-3 vs 3-6) | M4 | Survey / R2 |
| 16 | Academy Micro-routine Screen & Recast Card | Family screen and card comparing negative frontal correction vs positive indirect recast | M4 | Survey / R3 |
| 17 | Data & Validation Automated Tests | 100% passing tests for Segundo Ciclo models, loaders, validators, and clinical blacklist | M5 | Survey / R4 |
| 18 | Backstage UI Widget Test Suite | Tests verifying dark mode, font >= 24sp, absence of child gamification, timer, and audio fades | M5 | Survey / R4 |
| 19 | Academy Recast Widget Test Suite | Tests verifying recast comparison table and adult audio modeling | M5 | Survey / R4 |
| 20 | E2E Regression & Forensic Audit | Zero network permissions, 100% offline, all flutter tests passing with exit code 0, clean audit | M5 | Survey / R4 |

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| 1 | M1: Data Architecture & Immutable Models | `AsambleaSegundoCiclo`, `FaseAsamblea`, `ComandoTPR`, `MaterialNatural`, `CurricularReferenceSegundoCiclo`, loader/repo extensions, placeholder fix, unit tests | none | **DONE** |
| 2 | M2: Curricular Vertical Slice & Validator | September JSON assets for 4º, 5º, 6º and Academy home micro-routine, `ContentValidator` extensions and tests | M1 | **IN_PROGRESS** |
| 3 | M3: Backstage Teacher Classroom Assistant | Theme tokens, `FadeAudioCoordinator`, `BackstagePhaseTimerWidget`, stepper, level switcher, 4 phase widgets, `BackstageAsambleaScreen` | M2 | PLANNED |
| 4 | M4: Navigation Integration & Academy Recast View | `HomeScreen` entry, `UnidadesListScreen` cycle switcher, `MicroRutinaSetembroScreen`, `RecastGuiaCard`, routes | M3 | PLANNED |
| 5 | M5: Automated Test Suite & Forensic Verification | Widget test suites, regression verification of 0-3 flows, privacy audit, `flutter test` execution, forensic audit | M4 | PLANNED |
