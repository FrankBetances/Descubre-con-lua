## 2026-09-20T15:13:00Z

<USER_REQUEST>
You are the Dart Models & Core Services Worker for Milestone 2 (R2 & R4 Core) of the project "Descubre con Lúa · Edición Vigo".

Working directory for your metadata:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_worker_m2/

Project root:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa

REFERENCE SOURCE (READ-ONLY):
The entire reference codebase is available in the workspace at:
`/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.studio_ref/`
Specifically inspect:
- `.studio_ref/src/utils/fsrsAlgorithm.ts` (for FSRS v4.5 port)
- `.studio_ref/src/data/` (for TypeScript types and data structures)

MANDATORY FIRST STEP:
Read /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/ORIGINAL_REQUEST.md and /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/CLAUDE.md.
Also inspect existing models in `lib/data/models/` (e.g. `unidad_model.dart`, `capsula_model.dart`) and `lib/core/localization/localized_string.dart` for coding conventions, `@immutable`, `LocalizedString`, and `fromJson`/`toJson` style.

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

OWNED FILES:
You exclusively own:
- All new model files in `lib/data/models/`:
  - `lib/data/models/cuento_model.dart`
  - `lib/data/models/lamina_model.dart`
  - `lib/data/models/corpus_palabra_model.dart`
  - `lib/data/models/dia_calendario_dual_model.dart`
  - `lib/data/models/fsrs_card_model.dart`
  - `lib/data/models/english_corpus_model.dart`
  - `lib/data/models/phonics_model.dart`
  - `lib/data/models/estrategia_model.dart`
  - `lib/data/models/dinamica_model.dart`
- Core services in `lib/core/`:
  - `lib/core/fsrs_service.dart` (port of FSRS v4.5 from `.studio_ref/src/utils/fsrsAlgorithm.ts`)
  - `lib/core/progress_service.dart` (UserProgress service on top of LocalStore)
- Content repository in `lib/data/repositories/`:
  - `lib/data/repositories/content_repository.dart` (extend with loader and query methods for all new models)

TASKS:
1. Create `lib/core/fsrs_service.dart`:
   - Pure Dart implementation of FSRS v4.5 ported from `.studio_ref/src/utils/fsrsAlgorithm.ts`.
   - Default 17 weights: `[0.4, 0.6, 2.4, 5.8, 4.93, 0.94, 0.86, 0.01, 1.49, 0.14, 0.94, 2.18, 0.05, 0.34, 1.26, 0.29, 2.61]`.
   - Retrievability formula: $R = (1 + \text{factor} \cdot t / S)^{-0.5}$.
   - Methods: `initStability`, `initDifficulty`, `nextStability`, `nextDifficulty`, `nextInterval`, `repeat(card, rating, now)`.
2. Create `lib/core/progress_service.dart`:
   - Manages user XP, streaks, completed assemblies, completed capsules, dual-track logs (aula vs fogar), and FSRS card reviews.
   - Uses `LocalStore` (`lib/core/storage/local_store.dart`) for atomic offline file persistence.
   - Zero network, zero external dependencies.
3. Create Dart data models in `lib/data/models/`:
   - Follow existing patterns in `unidad_model.dart` and `capsula_model.dart`:
     - `@immutable`
     - Use `LocalizedString` for bilingual text (`gl` / `es`).
     - Provide factory `fromJson(Map<String, dynamic> json)` and `Map<String, dynamic> toJson()`.
     - Implement `==` and `hashCode`.
4. Extend `lib/data/repositories/content_repository.dart`:
   - Add caching and loading methods:
     - `loadCuentos({String? cursoId, int? mesNumero})`
     - `getCuentoById(String id)`
     - `loadLaminas({String? categoria, String? nivel})`
     - `getLaminaById(String id)`
     - `loadCorpusPalabras({int? banda, String? cefr})`
     - `searchPalabras(String query)`
     - `loadCalendarioDias({required String cursoId, int? mes})`
     - `loadEnglishCorpus()`
     - `loadPhonicsTaxonomy()`
     - `loadEstrategias()`
     - `loadDinamicas()`
     - `loadCurriculo50Meses()`

COMPLETION CRITERIA:
- All model files created in `lib/data/models/`.
- `fsrs_service.dart` and `progress_service.dart` created in `lib/core/`.
- `content_repository.dart` extended.
- Code formatted and free of syntax errors.
- Report completion via send_message to parent orchestrator.
</USER_REQUEST>
