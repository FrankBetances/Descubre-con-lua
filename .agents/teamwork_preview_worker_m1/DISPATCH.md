# DISPATCH — Milestone M1 Worker

## Identity
- Type: teamwork_preview_worker
- Working Directory: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_worker_m1
- Parent Conversation ID: e7633361-cefb-4427-91ff-c3fbb93625fc

## Objective
Implement Milestone M1: Data Architecture & Immutable Models for Segundo Ciclo (3-6 years).

## Mandatory Inputs (Read these first!)
1. `/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/ORIGINAL_REQUEST.md` (specifically `## Follow-up — 2026-09-14T13:15:17Z`)
2. `/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_orchestrator_3/PROJECT.md`
3. Explorer specifications:
   - `.agents/teamwork_preview_explorer_m1_1/proposed_asamblea_segundo_ciclo_model.dart` and `handoff.md`
   - `.agents/teamwork_preview_explorer_m1_2/handoff.md` (Section 4)
   - `.agents/teamwork_preview_explorer_m1_3/proposed_asamblea_segundo_ciclo_models_test.dart`, `proposed_placeholder_validator_test.dart`, and `content_validator_placeholder.patch`

## Exclusive Write Ownership
You exclusively own and may edit:
1. `lib/data/models/asamblea_segundo_ciclo_model.dart` (create new)
2. `lib/data/loaders/content_asset_loader.dart` (extend)
3. `lib/data/repositories/content_repository.dart` (extend)
4. `lib/data/validators/content_validator.dart` (modify line 60-63 placeholderPattern caseSensitive: true)
5. `test/data/asamblea_segundo_ciclo_models_test.dart` (create new)
6. `test/data/placeholder_validator_test.dart` (create new)

## Tasks
1. Implement `lib/data/models/asamblea_segundo_ciclo_model.dart` with all immutable models, enums (`NivelEducativoSegundoCiclo`, `MetodologiaTPR`, `TipoFaseAsamblea`), `ComandoTPR`, `MaterialNatural`, `FaseAsamblea`, `CurricularReferenceSegundoCiclo`, `MicroRutinaHogarSegundoCiclo`, `PautaRecast`, and `AsambleaSegundoCiclo`.
2. Extend `lib/data/loaders/content_asset_loader.dart` with Segundo Ciclo loader and parser methods.
3. Extend `lib/data/repositories/content_repository.dart` with Segundo Ciclo caching, initialization, and query methods.
4. Apply the `caseSensitive: true` fix to `placeholderPattern` in `lib/data/validators/content_validator.dart`.
5. Implement unit tests in `test/data/asamblea_segundo_ciclo_models_test.dart` and `test/data/placeholder_validator_test.dart`.
6. Run verification commands:
   - `dart format --set-exit-if-changed lib/data/ test/data/`
   - `flutter analyze`
   - `flutter test test/data/asamblea_segundo_ciclo_models_test.dart`
   - `flutter test test/data/placeholder_validator_test.dart`
   - `flutter test test/data/content_loader_test.dart`
   - `flutter test test/data/models_test.dart`
   - `flutter test test/data/challenger2_stress_test.dart`
   - `python3 tools/check_pulse_markers.py`
   - `python3 tools/check_pulse_bpm.py`
   - `python3 tools/export_voice_corpus.py --check`
   - `python3 tools/check_voice_coverage.py`
7. Document all commands, diffs, and exact test output in `handoff.md` and send message to parent orchestrator.

## Integrity Warning
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

## 2026-09-14T13:27:55Z
You are the Implementation Worker for Milestone M1 in «Descubre con Lúa · Edición Vigo».
Your working directory is: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_worker_m1
Your dispatch instructions are at: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_worker_m1/DISPATCH.md

MANDATORY: You MUST read /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/ORIGINAL_REQUEST.md before doing any work (specifically the section '## Follow-up — 2026-09-14T13:15:17Z').
Also read /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_orchestrator_3/PROJECT.md and the explorer specifications:
- .agents/teamwork_preview_explorer_m1_1/proposed_asamblea_segundo_ciclo_model.dart and handoff.md
- .agents/teamwork_preview_explorer_m1_2/handoff.md (Section 4)
- .agents/teamwork_preview_explorer_m1_3/proposed_asamblea_segundo_ciclo_models_test.dart, proposed_placeholder_validator_test.dart, and content_validator_placeholder.patch

Exclusive write ownership:
1. lib/data/models/asamblea_segundo_ciclo_model.dart (create new)
2. lib/data/loaders/content_asset_loader.dart (extend)
3. lib/data/repositories/content_repository.dart (extend)
4. lib/data/validators/content_validator.dart (modify line 60-63 placeholderPattern caseSensitive: true)
5. test/data/asamblea_segundo_ciclo_models_test.dart (create new)
6. test/data/placeholder_validator_test.dart (create new)

Tasks:
1. Implement lib/data/models/asamblea_segundo_ciclo_model.dart with all immutable models, enums (NivelEducativoSegundoCiclo, MetodologiaTPR, TipoFaseAsamblea), ComandoTPR, MaterialNatural, FaseAsamblea, CurricularReferenceSegundoCiclo, MicroRutinaHogarSegundoCiclo, PautaRecast, and AsambleaSegundoCiclo.
2. Extend lib/data/loaders/content_asset_loader.dart with Segundo Ciclo loader and parser methods.
3. Extend lib/data/repositories/content_repository.dart with Segundo Ciclo caching, initialization, and query methods.
4. Apply the caseSensitive: true fix to placeholderPattern in lib/data/validators/content_validator.dart.
5. Implement unit tests in test/data/asamblea_segundo_ciclo_models_test.dart and test/data/placeholder_validator_test.dart.
6. Run verification commands:
   - dart format --set-exit-if-changed lib/data/ test/data/
   - flutter analyze
   - flutter test test/data/asamblea_segundo_ciclo_models_test.dart
   - flutter test test/data/placeholder_validator_test.dart
   - flutter test test/data/content_loader_test.dart
   - flutter test test/data/models_test.dart
   - flutter test test/data/challenger2_stress_test.dart
   - python3 tools/check_pulse_markers.py
   - python3 tools/check_pulse_bpm.py
   - python3 tools/export_voice_corpus.py --check
   - python3 tools/check_voice_coverage.py
7. Document all commands, diffs, and exact test output in handoff.md and send message to parent orchestrator.

