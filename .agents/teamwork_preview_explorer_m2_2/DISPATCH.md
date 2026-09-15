# DISPATCH — M2 Explorer 2 (Validator Logic Explorer)

## Identity
- Type: teamwork_preview_explorer
- Working Directory: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_explorer_m2_2
- Parent Conversation ID: e7633361-cefb-4427-91ff-c3fbb93625fc

## Objective
Design the validation logic extension for Segundo Ciclo in `lib/data/validators/content_validator.dart`:
1. MANDATORY: Read `/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/ORIGINAL_REQUEST.md` (specifically `## Follow-up — 2026-09-14T13:15:17Z`), `.agents/teamwork_preview_orchestrator_3/PROJECT.md`, and inspect `lib/data/validators/content_validator.dart`.
2. Formulate:
   - `validateAsambleaSegundoCicloJson(Map<String, dynamic> json, {String source = 'inline'})`:
     - Checks root fields (`id`, `nivel`, `mes`, `titulo`, `metodologiaTpr`, `duracionTotalMinutos == 10`).
     - Checks 4 phases in canonical order (`apertura_saudo`, `movement_rhythm_focus`, `core_tpr_challenge`, `calma_transicion`) with canonical durations (`90`, `120`, `270`, `120` seconds summing to 600s).
     - Checks L3 command texts (`textoIngles`) and bilingual parity for all `gl`/`es` fields.
     - Checks natural Galician materials (`mimbre`, `castañas`, `conchas`, `gasas`) with safety warnings for rigid manipulatives (>= 4.0 cm, shells >= 5.0 cm).
     - Checks `curriculo`: `Decreto 150/2022`, `educacion_infantil`, `segundo_ciclo_3_6`, valid areas and criteria (`CA1.1` to `CA3.3`).
     - Checks clinical blacklist terms.
3. Formulate drop-in method specifications for `content_validator.dart`.
4. Write your report to `handoff.md` and notify parent orchestrator via `send_message`.
