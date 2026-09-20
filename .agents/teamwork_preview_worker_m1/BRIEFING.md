# BRIEFING — 2026-09-20T17:14:00+02:00

## Mission
Milestone 1: Extract and convert all 15+ pedagogical data sources from `.studio_ref/` into offline JSON assets under `assets/content/`, register them in `pubspec.yaml`, and validate counts and integrity.

## 🔒 My Identity
- Archetype: implementer
- Roles: implementer, qa, specialist
- Working directory: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_worker_m1
- Original parent: 9e628138-021d-44c9-9a72-2da6208e84bb
- Milestone: Milestone 1 (R1: Data Extraction, Conversion to JSON, Asset Registration)

## 🔒 Key Constraints
- Pure offline JSON assets, zero network, zero analytics/telemetry.
- Strict integrity: no hardcoding, no fake counts, full data parsing.
- Read reference files strictly from `.studio_ref/`.
- Owned files: `assets/content/**`, `tools/**`, `pubspec.yaml`.
- Git branch: `studio` only.

## Current Parent
- Conversation ID: 9e628138-021d-44c9-9a72-2da6208e84bb
- Updated: 2026-09-20T17:14:00+02:00

## Task Summary
- **What to build**: Full extraction script for all 15+ data sources from `.studio_ref/` to `assets/content/`, registration in `pubspec.yaml`, and verification script.
- **Success criteria**:
  - `banco200_cuentos.json`: exactly 200 stories with required fields.
  - `banco200_laminas.json`: exactly 200 cards.
  - `banco100_cuentos.json`: 100 extra stories.
  - `historias_progresivas.json`: progressive stories.
  - `curriculo_50_meses.json`: 5 courses × 10 months.
  - `calendario_dias.json`: exactly 1,000 days.
  - `english_corpus.json`: English corpus items.
  - `collocations_grammar.json`: Collocations & grammar.
  - `phonics_taxonomy.json`: 44 English phonemes.
  - `estrategias_pedagogicas.json`: pedagogical strategies.
  - `dinamicas_aula.json`: classroom dynamics.
  - `curriculo_catalogo.json`: catalogs from contentRepository.ts.
  - `lua_art.json`: Lua art definitions.
  - `bnc_coca_8000.json`: >= 7,500 words with lemma & frequency.
  - `bnc_coca_8000_cefr.json`: >= 7,500 words with lemma & CEFR.
  - `calendario_3_6_anos.json`: from `.studio_ref/calendario-3-6-anos.json`.
  - Direct copy of `bncCoca8000.json` and `bncCoca8000Cefr.json`.
  - `pubspec.yaml` updated with asset paths.
- **Interface contracts**: `ORIGINAL_REQUEST.md` (R1) and `CLAUDE.md`.
- **Code layout**: `assets/content/{cuentos,laminas,calendario,english,corpus}/`

## Change Tracker
- **Files modified**: None yet
- **Build status**: Pending
- **Pending issues**: None

## Quality Status
- **Build/test result**: Pending
- **Lint status**: Pending
- **Tests added/modified**: Pending

## Loaded Skills
- None required

## Key Decisions Made
- Will check environment node / python version to build an extraction script.

## Artifact Index
- `.agents/teamwork_preview_worker_m1/DISPATCH.md` — Assignment instructions
- `.agents/teamwork_preview_worker_m1/BRIEFING.md` — Situational awareness
- `.agents/teamwork_preview_worker_m1/progress.md` — Heartbeat and step progress
