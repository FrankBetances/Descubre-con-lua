# DISPATCH — M1 Test and Linter Explorer (m1_3)

## Identity
- Type: teamwork_preview_explorer
- Working Directory: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_explorer_m1_3
- Parent Conversation ID: e7633361-cefb-4427-91ff-c3fbb93625fc

## Objective
Read:
1. `/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/ORIGINAL_REQUEST.md` (specifically `## Follow-up — 2026-09-14T13:15:17Z`)
2. `/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_orchestrator_3/PROJECT.md`
3. Inspect `test/data/models_test.dart`, `lib/data/validators/content_validator.dart` (line 60), and `STATUS.md` (lines 177-185)

Investigate:
1. Exact unit test suite design for `test/data/asamblea_segundo_ciclo_models_test.dart`:
   - Testing parsing of all 3 levels (4º, 5º, 6º), 4 phases, durations, L3 commands, natural materials, recast guidance.
   - Testing JSON serialization round-trip (`toJson` -> `fromJson`).
   - Testing edge cases: missing fields, invalid durations, empty command strings.
2. The exact one-line fix in `lib/data/validators/content_validator.dart` for `placeholderPattern`:
   - Verify why `caseSensitive: true` is needed to prevent false positives on the Spanish/Galician word "todo".
   - Specify test assertions to verify that "todo" is accepted while "TODO" and "TBD" are rejected.
Write your findings to `handoff.md` and notify parent via `send_message`.

## 2026-09-14T13:22:40Z
You are the M1 Test & Linter Explorer for Milestone M1 in «Descubre con Lúa · Edición Vigo».
Your working directory is: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_explorer_m1_3
Your dispatch instructions are at: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_explorer_m1_3/DISPATCH.md

MANDATORY: Read /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/ORIGINAL_REQUEST.md before doing any work (specifically the section '## Follow-up — 2026-09-14T13:15:17Z').
Also read /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_orchestrator_3/PROJECT.md, /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/STATUS.md (specifically lines 177-185), and inspect lib/data/validators/content_validator.dart (line 60) and test/data/models_test.dart.

Investigate:
1. Complete unit test specifications for test/data/asamblea_segundo_ciclo_models_test.dart:
   - Deserialization and serialization round-trip of 4.º, 5.º, and 6.º models.
   - Validation of duration invariants (90s, 120s, 270s, 120s = 600s total).
   - Invariant enforcement for TPR methodology, materials, and recast guidance.
2. The exact one-line fix in lib/data/validators/content_validator.dart:
   - Change placeholderPattern from caseSensitive: false to caseSensitive: true.
   - Design test cases verifying that lowercase 'todo' (Spanish/Galician for all) passes validation, while uppercase 'TODO' and 'TBD' are rejected.
Write your findings to handoff.md in your working directory and notify the parent orchestrator via send_message.
