# DISPATCH — Data Architecture & Backend Explorer (s3_2)

## Identity
- Type: teamwork_preview_explorer
- Working Directory: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_explorer_s3_2
- Parent Conversation ID: e7633361-cefb-4427-91ff-c3fbb93625fc

## Objective
Investigate the data architecture of «Descubre con Lúa · Edición Vigo».
1. Read `/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/ORIGINAL_REQUEST.md` (specifically section `## Follow-up — 2026-09-14T13:15:17Z`), `PROJECT.md`, and inspect `lib/data/` (models, loaders, repositories, validators) and `assets/content/`.
2. Determine how to cleanly introduce the data models and JSON schema for Segundo Ciclo (4.º, 5.º, 6.º Infantil) without breaking existing 0-3 (Primer Ciclo) models (`Unidad`, `Capsula`, etc.).
3. Formulate the exact model structures, JSON fields, and schema definitions needed for:
   - Level representation (4º, 5º, 6º).
   - The 4 assembly phases (Opening, Rhythm, Core TPR, Calm) with phase metadata, duration, audio cues, commands, and educator guide notes.
   - Curricular references to Decreto 150/2022.
   - September vertical slice JSON files for 4th, 5th, and 6th Infantil.
   - Home micro-routine integration with Academy.
4. Check content validation rules (`ContentValidator`) and specify extensions needed to validate the new JSON assets.
5. Write your complete analysis and model specifications to `handoff.md` in your working directory and notify the parent orchestrator via send_message.

## 2026-09-14T13:18:16Z
Investigate how to introduce the Segundo Ciclo models and JSON schemas cleanly:
1. Model definitions (SegundoCicloUnidad / AsambleaSegundoCiclo, FaseAsamblea, TPRLevel, MetodologiaTPR, CurricularReferenceSegundoCiclo, etc.).
2. Compatibility with existing 0-3 models (`Unidad`, `Capsula`) without breaking existing tests or assets.
3. JSON schemas and file structure for September vertical slice (e.g. assets/content/asambleas_segundo_ciclo/ or similar).
4. Validation logic required in ContentValidator (and new validator tests).
5. Write your comprehensive architecture report and model contracts to handoff.md in your working directory and notify the parent orchestrator via send_message.
