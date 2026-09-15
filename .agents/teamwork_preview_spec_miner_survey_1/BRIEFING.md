# BRIEFING — 2026-09-13T09:06:16Z

## Mission
Survey, probe, and document all specifications for «Descubre con Lúa · Edición Vigo»: Decreto 150/2022 10-month curriculum, content models, neural audio specifications (LJSpeech · piper for English, Celtia · Proxecto Nós for Galician, Sharvard for Spanish), 4 session moments (apertura, fingerplay/concentración, núcleo TPR en inglés con pronunciación LJSpeech, cierre afectivo), high-contrast visual system, and seamless dual flow (Aula/Asamblea vs Hogar/Academy) with sovereign Doble Estimulación tracking.

## 🔒 My Identity
- Archetype: teamwork_preview_spec_miner
- Roles: Spec Miner Requirements
- Working directory: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_spec_miner_survey_1
- Original parent: 155c43c0-be2b-46ce-b47d-cc280903c77f
- Milestone: Survey & Specifications

## 🔒 Key Constraints
- Do NOT implement anything — read-only specification mining and requirements documentation.
- Prioritize authoritative sources over LLM prior knowledge.
- Be thorough but organized — group findings by category.
- If you discover features beyond your assignment, probe and include them in the Features Discovered table.
- Never write source code outside of .agents/ metadata files.
- Strict 1:1 bilingual parity (gl/es) across all user-facing content.
- Absolute zero tolerance for clinical/diagnostic terms (purely educational and family context 0-3 years).
- Strict offline privacy: AndroidManifest.xml and binary must not declare android.permission.INTERNET or any network permission.

## Current Parent
- Conversation ID: dfad01eb-fac8-43c6-b41a-17f07ad3c22a
- Updated: 2026-09-13T09:06:16Z

## Task Summary
- **What to build**: Comprehensive specification and feature inventory in `handoff.md` for the follow-up request (2026-09-13T09:04:47Z) covering curriculum, moments of session, neural audio, dual flow, and visual cards.
- **Success criteria**: 5-component handoff report with Features Discovered and Edge Cases tables, clear logic chain, verification methods, and direct reference to verified files.
- **Interface contracts**: `ORIGINAL_REQUEST.md`, `PROJECT.md`, `STATUS.md`, `lib/data/models/calendario_model.dart`, `lib/core/audio/voice_id.dart`.
- **Code layout**: `.agents/` only for metadata.

## Key Decisions Made
- Curricular grounding: Decreto 150/2022 do 8 de setembro (DOG nº 172), 1º ciclo de educación infantil (0-3 anos), Áreas 1, 2 e 3.
- Calendar model: 10 school months (September to June) mapped in `MesCurricular` with specific centers of interest, English lexicon, and TPR commands.
- Session moments: 4 canonical phases (Apertura, Fingerplay/Concentración, Núcleo TPR en inglés, Cierre afectivo).
- Neural audio pipeline: Offline synthesis only (CI build time); zero runtime ML; FNV-1a deterministic hash; English via `LJSpeech · piper`, Galician via `Celtia · Proxecto Nós`, Spanish via `Sharvard · piper`.
- Metronome: Purely visual pulse (no audio click to protect children with hearing aids/cochlear implants).
- Dual flow: Rapid context toggle between Aula (Asamblea 5-8 min, 2-meter legibility, 1-touch register) and Hogar (Academy 3-5 min screenless, attention span guide, 1-touch register) with reactive Doble Estimulación.

## Artifact Index
- /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/ORIGINAL_REQUEST.md — Base requirements & follow-up
- /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_spec_miner_survey_1/DISPATCH.md — Dispatch log
- /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_spec_miner_survey_1/BRIEFING.md — Working memory
- /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_spec_miner_survey_1/progress.md — Liveness tracker
- /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_spec_miner_survey_1/analysis.md — Initial detailed analysis
- /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_spec_miner_survey_1/handoff.md — 5-component report

