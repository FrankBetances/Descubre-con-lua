# DISPATCH — M2 Explorer 3 (Validation Test Explorer)

## Identity
- Type: teamwork_preview_explorer
- Working Directory: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_explorer_m2_3
- Parent Conversation ID: e7633361-cefb-4427-91ff-c3fbb93625fc

## Objective
Design the automated validation unit test suite for Milestone M2:
1. MANDATORY: Read `/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/ORIGINAL_REQUEST.md` (specifically `## Follow-up — 2026-09-14T13:15:17Z`) and `.agents/teamwork_preview_orchestrator_3/PROJECT.md`.
2. Inspect `test/data/curricular_alignment_test.dart`, `test/data/bilingual_parity_test.dart`, and `test/data/clinical_terms_blacklist_test.dart`.
3. Design `test/data/asamblea_segundo_ciclo_validation_test.dart`:
   - Validating that the real September JSON assets for 4º, 5º, and 6º pass all validator checks with 0 errors.
   - Validating rejection of invalid phase counts, wrong phase order, mismatched durations (e.g. 80s instead of 90s).
   - Validating rejection of non-Decreto 150/2022 standards, wrong stages/cycles, and missing criteria.
   - Validating clinical blacklist rejection if medical terms are injected.
   - Validating bilingual parity enforcement across all localized text fields.
4. Write your report to `handoff.md` and notify parent orchestrator via `send_message`.

## 2026-09-14T14:00:00Z
<USER_REQUEST>
You are Explorer 3 for Milestone M2 in «Descubre con Lúa · Edición Vigo».
Your working directory is: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_explorer_m2_3
Your dispatch instructions are at: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_explorer_m2_3/DISPATCH.md

MANDATORY: Read /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/ORIGINAL_REQUEST.md before doing any work (specifically the section '## Follow-up — 2026-09-14T13:15:17Z').
Also read /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_orchestrator_3/PROJECT.md and inspect test/data/curricular_alignment_test.dart.

Design the comprehensive unit test suite in `test/data/asamblea_segundo_ciclo_validation_test.dart`:
- Validating the 3 September JSON files pass with 0 errors.
- Validating rejection of invalid phase counts, wrong order, duration mismatch.
- Validating rejection of non-Decreto 150/2022 standards and clinical blacklist terms.
- Validating bilingual parity.
Write your complete test suite draft to handoff.md and notify parent orchestrator via send_message.
</USER_REQUEST>
