## 2026-09-20T15:12:50Z

You are the Data Migration Worker for Milestone 1 (R1: Data Extraction, Conversion to JSON, Asset Registration) of the project "Descubre con Lúa · Edición Vigo".

Working directory for your metadata:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_worker_m1/

Project root:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa

REFERENCE SOURCE (READ-ONLY, INSIDE WORKSPACE):
The entire reference codebase is located inside the workspace at:
`/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.studio_ref/`
All files are accessible directly within the workspace.

MANDATORY FIRST STEP:
Read /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/ORIGINAL_REQUEST.md (specifically ## Follow-up — 2026-09-20T14:51:45Z) and /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/CLAUDE.md.

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

OWNED FILES:
You exclusively own:
- All files under `assets/content/` (create subdirectories as needed: `cuentos/`, `laminas/`, `calendario/`, `english/`, `corpus/`, etc.)
- Helper scripts in `tools/` (e.g. `tools/extract_data.py` or `tools/extract_data.mjs` - use `/Library/Developer/CommandLineTools/usr/bin/python3` or `node`)
- `pubspec.yaml` (adding the new asset directory declarations)

TASK OBJECTIVE:
Extract and convert all 15+ data sources from `.studio_ref/` into offline JSON assets under `assets/content/`:

1. `.studio_ref/src/data/banco200CuentosData.ts` (28,243 lines — exactly 200 stories) -> `assets/content/cuentos/banco200_cuentos.json`.
   MUST contain exactly 200 story objects, each with `id`, `titulo.gl`, `titulo.es`, `paginas[]` (non-empty), `preguntasGraduadas`, `tprOral`.
2. `.studio_ref/src/data/banco200LaminasData.ts` (200 illustrated cards) -> `assets/content/laminas/banco200_laminas.json`.
   MUST contain 200 card objects.
3. `.studio_ref/src/data/banco100CuentosData.ts` (100 extra stories) -> `assets/content/cuentos/banco100_cuentos.json`.
4. `.studio_ref/src/data/historiasProgresivasData.ts` -> `assets/content/cuentos/historias_progresivas.json`.
5. `.studio_ref/src/data/curriculo50Meses.ts` (5 courses × 10 months) -> `assets/content/calendario/curriculo_50_meses.json`.
6. `.studio_ref/src/data/calendarDaysData.ts` (1,000 school days) -> `assets/content/calendario/calendario_dias.json`.
7. `.studio_ref/src/data/englishCorpus.ts` -> `assets/content/english/english_corpus.json`.
8. `.studio_ref/src/data/collocationsAndGrammar.ts` -> `assets/content/english/collocations_grammar.json`.
9. `.studio_ref/src/data/phonicsTaxonomyData.ts` (44 English phonemes) -> `assets/content/english/phonics_taxonomy.json`.
10. `.studio_ref/src/data/estrategiasPedagogicasData.ts` -> `assets/content/estrategias_pedagogicas.json`.
11. `.studio_ref/src/data/dinamicasPedagogicasData.ts` -> `assets/content/dinamicas_aula.json`.
12. `.studio_ref/src/data/contentRepository.ts` (catalogs) -> `assets/content/curriculo_catalogo.json`.
13. `.studio_ref/src/data/luaArt.ts` -> `assets/content/lua_art.json`.
14. Root `.studio_ref/corpus_8000_palabras.csv` and `.studio_ref/corpus_8000_palabras_cefr.csv` -> `assets/content/corpus/bnc_coca_8000.json` and `assets/content/corpus/bnc_coca_8000_cefr.json` (MUST have >= 7,500 entries with lemma and frequency/cefr).
15. Root `.studio_ref/calendario-3-6-anos.json` -> `assets/content/calendario/calendario_3_6_anos.json`.
16. Direct copy of `.studio_ref/src/data/bncCoca8000.json` and `.studio_ref/src/data/bncCoca8000Cefr.json` to `assets/content/corpus/`.

EXTRACTION METHODOLOGY:
Write robust, complete conversion scripts in `tools/` using Node.js or Python (`/Library/Developer/CommandLineTools/usr/bin/python3`) to load the TypeScript/CSV files and serialize them to pure, valid JSON. Note: For TypeScript data files that export objects/arrays, you can use Node.js or Python to evaluate/parse and output valid JSON.
DO NOT truncate. Validate with a Python validation script:
- Verify all JSON files parse with `json.loads()`.
- Verify `banco200_cuentos.json` has `len == 200`.
- Verify `bnc_coca_8000.json` has `len >= 7500`.
- Verify `banco200_laminas.json` has `len == 200`.
- Verify `calendario_dias.json` has `len == 1000`.

UPDATE PUBSPEC.YAML:
Declare all new asset directories under `flutter: assets:` in `pubspec.yaml`:
```yaml
    - assets/content/cuentos/
    - assets/content/laminas/
    - assets/content/english/
    - assets/content/corpus/
    - assets/content/calendario/
```

COMPLETION CRITERIA:
- All 15+ JSON files exist in `assets/content/` and are valid JSON.
- `pubspec.yaml` updated and valid.
- Run your validation script and document exact counts and sizes.
- Report completion via send_message to parent orchestrator.
