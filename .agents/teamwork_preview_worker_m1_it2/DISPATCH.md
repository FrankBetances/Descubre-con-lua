# DISPATCH — Worker M1 Iteration 2

## Identity
- Type: teamwork_preview_worker
- Working Directory: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_worker_m1_it2
- Parent Conversation ID: e7633361-cefb-4427-91ff-c3fbb93625fc

## Objective
Apply remediation for Milestone M1 Iteration 2:
1. MANDATORY: Read `/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/ORIGINAL_REQUEST.md` (specifically `## Follow-up — 2026-09-14T13:15:17Z`) and `.agents/teamwork_preview_orchestrator_3/PROJECT.md`.
2. Inspect the explorer remediation reports:
   - `.agents/teamwork_preview_explorer_m1_it2_1/has_canonical_phases.patch` and `handoff.md`
   - `.agents/teamwork_preview_explorer_m1_it2_2/handoff.md`
   - `.agents/teamwork_preview_explorer_m1_it2_3/handoff.md`

## Exclusive Write Ownership
1. `lib/data/models/asamblea_segundo_ciclo_model.dart`
2. `lib/data/repositories/content_repository.dart`

## Tasks
1. In `lib/data/models/asamblea_segundo_ciclo_model.dart`:
   - Add `bool get hasCanonicalDuration => duracionSegundos == tipo.duracionCanonicoSegundos;` to `FaseAsamblea`.
   - Update `hasCanonicalPhases` in `AsambleaSegundoCiclo` to check:
     `fases.length == 4 &&`
     `fases[0].tipo == TipoFaseAsamblea.aperturaSaudo && fases[0].duracionSegundos == TipoFaseAsamblea.aperturaSaudo.duracionCanonicoSegundos &&`
     `fases[1].tipo == TipoFaseAsamblea.movementRhythmFocus && fases[1].duracionSegundos == TipoFaseAsamblea.movementRhythmFocus.duracionCanonicoSegundos &&`
     `fases[2].tipo == TipoFaseAsamblea.coreTprChallenge && fases[2].duracionSegundos == TipoFaseAsamblea.coreTprChallenge.duracionCanonicoSegundos &&`
     `fases[3].tipo == TipoFaseAsamblea.calmaTransicion && fases[3].duracionSegundos == TipoFaseAsamblea.calmaTransicion.duracionCanonicoSegundos;`
2. In `lib/data/repositories/content_repository.dart`:
   - Add `Future<void>? _initFuture;` to latch `initialize()` and eliminate concurrent redundant re-initialization, resetting it safely on `clear()`.
3. Run verification:
   - `dart format --set-exit-if-changed lib/data/ test/data/`
   - `flutter analyze`
   - `flutter test test/data/asamblea_segundo_ciclo_models_test.dart`
   - `flutter test test/data/asamblea_segundo_ciclo_stress_test.dart`
   - `flutter test test/data/placeholder_validator_test.dart`
   - `flutter test test/data/content_loader_test.dart`
   - `flutter test test/data/models_test.dart`
   - `flutter test test/data/challenger2_stress_test.dart`
4. Document all commands and results in `handoff.md` and send message to parent orchestrator.

## Integrity Warning
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

## 2026-09-14T13:51:37Z
You are Worker M1 Iteration 2 for Milestone M1 in «Descubre con Lúa · Edición Vigo».
Your working directory is: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_worker_m1_it2
Your dispatch instructions are at: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_worker_m1_it2/DISPATCH.md

MANDATORY: Read /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/ORIGINAL_REQUEST.md before doing any work (specifically the section '## Follow-up — 2026-09-14T13:15:17Z').
Also read /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_orchestrator_3/PROJECT.md and inspect the explorer remediation reports:
- .agents/teamwork_preview_explorer_m1_it2_1/has_canonical_phases.patch and handoff.md
- .agents/teamwork_preview_explorer_m1_it2_2/handoff.md
- .agents/teamwork_preview_explorer_m1_it2_3/handoff.md

Exclusive write ownership:
1. lib/data/models/asamblea_segundo_ciclo_model.dart
2. lib/data/repositories/content_repository.dart

Tasks:
1. In lib/data/models/asamblea_segundo_ciclo_model.dart:
   - Add `bool get hasCanonicalDuration => duracionSegundos == tipo.duracionCanonicoSegundos;` to `FaseAsamblea`.
   - Update `hasCanonicalPhases` in `AsambleaSegundoCiclo` to check:
     fases.length == 4 &&
     fases[0].tipo == TipoFaseAsamblea.aperturaSaudo && fases[0].duracionSegundos == TipoFaseAsamblea.aperturaSaudo.duracionCanonicoSegundos &&
     fases[1].tipo == TipoFaseAsamblea.movementRhythmFocus && fases[1].duracionSegundos == TipoFaseAsamblea.movementRhythmFocus.duracionCanonicoSegundos &&
     fases[2].tipo == TipoFaseAsamblea.coreTprChallenge && fases[2].duracionSegundos == TipoFaseAsamblea.coreTprChallenge.duracionCanonicoSegundos &&
     fases[3].tipo == TipoFaseAsamblea.calmaTransicion && fases[3].duracionSegundos == TipoFaseAsamblea.calmaTransicion.duracionCanonicoSegundos;
2. In lib/data/repositories/content_repository.dart:
   - Add `Future<void>? _initFuture;` to latch `initialize()` and eliminate redundant concurrent re-initialization, resetting it safely on `clear()`.
3. Run verification:
   - dart format --set-exit-if-changed lib/data/ test/data/
   - flutter analyze
   - flutter test test/data/asamblea_segundo_ciclo_models_test.dart
   - flutter test test/data/asamblea_segundo_ciclo_stress_test.dart
   - flutter test test/data/placeholder_validator_test.dart
   - flutter test test/data/content_loader_test.dart
   - flutter test test/data/models_test.dart
   - flutter test test/data/challenger2_stress_test.dart
4. Document all commands, diffs, and test outputs in handoff.md and send message to parent orchestrator.

