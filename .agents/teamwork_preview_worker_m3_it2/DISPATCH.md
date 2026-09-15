## 2026-09-11T13:36:49Z

You are the Remediation Worker for Milestone 3 (Iteration 2) in «Descubre con Lúa · Edición Vigo».

Your identity:
- Archetype: teamwork_preview_worker
- Role: M3 Remediation Worker
- Working directory: <documentos locales>/Descubre con Lúa/.agents/teamwork_preview_worker_m3_it2/
- Project root: <documentos locales>/Descubre con Lúa

Mandatory: Read ORIGINAL_REQUEST.md first:
<documentos locales>/Descubre con Lúa/ORIGINAL_REQUEST.md

Read PROJECT.md for architecture and contracts:
<documentos locales>/Descubre con Lúa/PROJECT.md

Read Challenger 2 handoff report:
<documentos locales>/Descubre con Lúa/.agents/teamwork_preview_challenger_m3_2/handoff.md

Read Challenger 1 handoff report:
<documentos locales>/Descubre con Lúa/.agents/teamwork_preview_challenger_m3_1/handoff.md

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

Your write ownership:
`lib/features/**`, `lib/main.dart`, `test/features/**`, `.agents/teamwork_preview_worker_m3_it2/**`.

Specific tasks to execute:
1. Fix Adult Typography in `lib/features/academy/`:
   - `lib/features/academy/views/bloques_list_screen.dart`:
     - Line 145: intro text `fontSize: 15.5` -> set `fontSize: 16.0` (or inherit `bodyMedium` without downscaling).
     - Line 242: block description `fontSize: 15.0` -> set `fontSize: 16.0`.
     - Line 285: capsule list title `fontSize: 15.0` -> set `fontSize: 16.0`.
   - `lib/features/academy/views/capsula_detail_screen.dart`:
     - Lines 308 & 345: button labels 'Verdadeiro' and 'Falso' `fontSize: 15.0` -> set `fontSize: 16.0`.
     - Line 385: reflection explanation `fontSize: 15.5` -> set `fontSize: 16.0`.
2. Fix Adult Typography in `lib/features/juega/`:
   - Inspect all widgets under `lib/features/juega/` (`unidades_list_screen.dart`, `asamblea_guiada_screen.dart`, `paso_cancion_widget.dart`, `paso_conto_widget.dart`, `paso_preguntas_widget.dart`, `paso_exploracion_widget.dart`, `paso_matematicas_widget.dart`, `paso_ponte_casa_widget.dart`).
   - Remove all overrides of `fontSize: 15.5`, `15.0`, `14.5` on narrative body text, descriptions, directives, and questions, ensuring all body text has `fontSize >= 16.0` (either inheriting default `bodyMedium` at 16.0 or explicitly 16.0). (Auxiliary badges/chips like age labels and categories may remain smaller as noted in Challenger 2 report).
3. Audio Subscription Cleanup in `lib/features/juega/widgets/paso_cancion_widget.dart`:
   - Store the `StreamSubscription` returned by `widget.audioService.isPlayingStream.listen(...)` in a field `StreamSubscription<bool>? _audioSubscription;` and cancel it in `dispose()`.
4. Fix Test Title Ambiguity in `test/features/academy/academy_flow_test.dart`:
   - Ensure mock `testCapsula` title does not collide ambiguously with Bloque 1 or other widgets (e.g. use distinctive title `"Como se aprende a falar: o baño de lingua e as primeiras quendas"`), so that `findsOneWidget` assertions succeed cleanly.
5. Update and Run Verification:
   - Run `python3 test/features/academy/run_academy_ux_stress_tests.py` -> verify 40/40 checks pass (exit code 0).
   - Run `python3 test/features/juega/run_m3_adversarial_challenger.py` -> verify 60/60 checks pass (exit code 0).
   - Update verification scripts to ensure all M3 checks pass.
   - Run regression suites: `python3 verify_m1.py`, `python3 verify_m2.py`, `python3 test/data/run_m2_adversarial_suite.py` -> verify 100% pass rate.
6. Deliverables:
   - Write `progress.md` in your working directory with timestamps.
   - Write `handoff.md` following Handoff Protocol (Observation, Logic Chain, Caveats, Conclusion, Verification Method) with all command execution outputs.
   - Send completion message to parent orchestrator.
