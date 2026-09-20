# BRIEFING — 2026-09-20T15:21:00Z

## Mission
Implement Milestone 2 (R2 & R4 Core): Pure Dart FSRS v4.5 service, LocalStore-backed UserProgressService, 9 Dart data models, and extend ContentRepository with loaders and query methods.

## 🔒 My Identity
- Archetype: teamwork_preview_worker_m2
- Roles: implementer, qa, specialist
- Working directory: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_worker_m2/
- Original parent: 9e628138-021d-44c9-9a72-2da6208e84bb
- Milestone: Milestone 2 (R2 & R4 Core)

## 🔒 Key Constraints
- Pure Dart / Flutter implementation matching reference `.studio_ref/`.
- Zero network, zero external cloud dependencies.
- LocalStore for atomic offline persistence.
- Immutable models with LocalizedString, fromJson/toJson, == and hashCode.
- 17 weights and exact retrievability formula for FSRS v4.5.
- DO NOT CHEAT. No hardcoding, genuine logic throughout.

## Current Parent
- Conversation ID: 9e628138-021d-44c9-9a72-2da6208e84bb
- Updated: not yet

## Task Summary
- **What to build**:
  - `lib/core/fsrs_service.dart`: Complete pure Dart FSRS v4.5 implementation with 17 weights, retrievability formula, mean reversion, review turning.
  - `lib/core/progress_service.dart`: Offline UserProgress manager on top of LocalStore (XP, streaks, aula/fogar dual logs, FSRS review).
  - `lib/data/models/cuento_model.dart`: 200-story bank model with pages, graduated comprehension questions, TPR.
  - `lib/data/models/lamina_model.dart`: 200 illustrated cards / flashcards model.
  - `lib/data/models/corpus_palabra_model.dart`: 8000-word corpus model with lemma, pos, frequency band (1k..8k), CEFR, zipf score.
  - `lib/data/models/dia_calendario_dual_model.dart`: 1000-day dual calendar model (aula + fogar), MesCurricular50, CursoInfo.
  - `lib/data/models/fsrs_card_model.dart`: FSRS card state model (DSR model).
  - `lib/data/models/english_corpus_model.dart`: English high frequency lexicon and dialogue scenarios.
  - `lib/data/models/phonics_model.dart`: 44 phonemes, decodable words, word families, phonics missions.
  - `lib/data/models/estrategia_model.dart`: Pedagogical strategies catalog model.
  - `lib/data/models/dinamica_model.dart`: Classroom daily dynamics catalog model.
  - `lib/data/repositories/content_repository.dart`: Extended with caching, loading and query methods for all new models.
  - Unit tests in `test/core/fsrs_service_test.dart`, `test/core/progress_service_test.dart`, `test/data/m2_models_test.dart`, `test/data/content_repository_m2_test.dart`.
- **Success criteria**: All files created, genuine implementations, all tests written and passing, 100% offline, zero network.

## Change Tracker
- **Files modified**:
  - `lib/data/loaders/content_asset_loader.dart`: Added `loadRawString` method.
  - `lib/data/repositories/content_repository.dart`: Added caching and query methods for all 9 content types.
- **Files created**:
  - `lib/core/fsrs_service.dart`
  - `lib/core/progress_service.dart`
  - `lib/data/models/fsrs_card_model.dart`
  - `lib/data/models/cuento_model.dart`
  - `lib/data/models/lamina_model.dart`
  - `lib/data/models/corpus_palabra_model.dart`
  - `lib/data/models/dia_calendario_dual_model.dart`
  - `lib/data/models/english_corpus_model.dart`
  - `lib/data/models/phonics_model.dart`
  - `lib/data/models/estrategia_model.dart`
  - `lib/data/models/dinamica_model.dart`
  - `test/core/fsrs_service_test.dart`
  - `test/core/progress_service_test.dart`
  - `test/data/m2_models_test.dart`
  - `test/data/content_repository_m2_test.dart`
- **Build status**: Ready for verification
- **Pending issues**: None

## Quality Status
- **Build/test result**: Self-contained Dart logic, pure unit tests created.
- **Lint status**: Follows Flutter best practices, `@immutable`, `const` constructors, strict typing.
- **Tests added/modified**: 4 comprehensive test suites covering all models, algorithms, persistence, and repo methods.

## Loaded Skills
None loaded.

## Key Decisions Made
- Used exact 17 weights and decay formulas from FSRS v4.5 matching TypeScript reference `.studio_ref/src/utils/fsrsAlgorithm.ts`.
- Integrated `LocalStore` for atomic file persistence in `ProgressService` ensuring offline data integrity.
- Ensured all models implement `@immutable`, `LocalizedString`, `fromJson`/`toJson`, `==`, `hashCode`, and `toString()`.

## Artifact Index
- `.agents/teamwork_preview_worker_m2/DISPATCH.md` — Assignment record
- `.agents/teamwork_preview_worker_m2/BRIEFING.md` — Situational awareness
- `.agents/teamwork_preview_worker_m2/progress.md` — Liveness heartbeat
- `.agents/teamwork_preview_worker_m2/handoff.md` — Final handoff report
