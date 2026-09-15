# BRIEFING — 2026-09-11T09:27:00Z

## Mission
Implement Milestone 3: Pedagogical Modules (Academy for Familias and Juega con Lúa for Aula/Docentes) with adult-focused Material 3 UI, canonical phase progression, bilingual toggle, offline audio asset generation, and route integration in `lib/main.dart`.

## 🔒 My Identity
- Archetype: teamwork_preview_worker
- Roles: implementer, qa, specialist
- Working directory: <documentos locales>/Descubre con Lúa/.agents/teamwork_preview_worker_m3/
- Original parent: 155c43c0-be2b-46ce-b47d-cc280903c77f
- Milestone: Milestone 3 (Pedagogical Modules)

## 🔒 Key Constraints
- Write ownership: `lib/features/**`, `lib/main.dart`, `assets/audio/**`, and `.agents/teamwork_preview_worker_m3/**`.
- Integrity Mandate: Genuine implementation, no hardcoded test shortcuts or dummy facades.
- Adult pedagogical design for Academy: ZERO external web links, ZERO child game or touch mechanics. Large adult typography (body >= 16sp).
- Teacher-focused design for Juega con Lúa: Sober, functional Material 3 UI. Zero distracting neon animations, zero child gaming mechanics. Prominent safety alerts (>4-5cm, adult supervision).
- Procedural offline audio: `assets/audio/mar_pulso_72bpm.wav` generated via Python `wave` at 72 BPM.
- Bilingual support: Dynamic `gl` and `es` language switcher.
- Empirical verification: Create and execute `verify_m3.py`; ensure M1 and M2 verification tests continue passing at 100%.

## Current Parent
- Conversation ID: 155c43c0-be2b-46ce-b47d-cc280903c77f
- Updated: 2026-09-11T09:27:00Z

## Task Summary
- **What to build**:
  1. Offline audio asset `assets/audio/mar_pulso_72bpm.wav` (72 BPM, 16-bit, 44.1kHz, mono).
  2. Academy module (`lib/features/academy/`): `bloques_list_screen.dart`, `capsula_detail_screen.dart`, `seccion_capsula_widget.dart`, `selector_idioma_widget.dart`.
  3. Juega con Lúa module (`lib/features/juega/`): `unidades_list_screen.dart`, `asamblea_guiada_screen.dart`, and the 6 canonical phase widgets.
  4. Integration and routing in `lib/main.dart`.
  5. Empirical verification script `verify_m3.py` and regression checks.
- **Success criteria**: All widgets and screens adhere to architecture contracts, pass static and unit verification, audio asset playable, no regressions.
- **Interface contracts**: PROJECT.md & M2 models/repository.
- **Code layout**: `lib/features/academy/`, `lib/features/juega/`, `lib/main.dart`, `assets/audio/`.

## Key Decisions Made
- Generated 72 BPM metronome pulse audio `mar_pulso_72bpm.wav` via pure Python standard library `wave` (16-bit PCM mono, 44.1kHz, 32 beats, 26.67s, exact 36,750 samples/beat).
- Implemented adult-only typography with body text >= 16sp, high-contrast palette, zero external web links, and formative non-punitive reflections.
- Integrated prominent safety alert card in Phase 4 of Juega con Lúa mandating pieces >4-5cm and continuous adult supervision.
- Structured Juega con Lúa as a 6-phase sequential teacher wizard (`PasoCancionWidget` through `PasoPonteCasaWidget`) with offline audio lifecycle control.
- Integrated full application routing in `lib/main.dart` supporting both static named routes and parameterized `onGenerateRoute`.

## Artifact Index
- `.agents/teamwork_preview_worker_m3/DISPATCH.md` — Assignment instructions
- `.agents/teamwork_preview_worker_m3/BRIEFING.md` — Agent state and memory
- `.agents/teamwork_preview_worker_m3/progress.md` — Liveness and task progress
- `.agents/teamwork_preview_worker_m3/verify_m3.py` — Empirical verification suite (110 checks)
- `.agents/teamwork_preview_worker_m3/handoff.md` — 5-component handoff report

## Change Tracker
- **Files modified/created**:
  - `assets/audio/mar_pulso_72bpm.wav`: 72 BPM procedural metronome audio asset
  - `lib/features/academy/widgets/selector_idioma_widget.dart`: Bilingual toggle widget
  - `lib/features/academy/widgets/seccion_capsula_widget.dart`: 4 canonical capsule section cards
  - `lib/features/academy/views/bloques_list_screen.dart`: 5 developmental blocks list
  - `lib/features/academy/views/capsula_detail_screen.dart`: 4-part capsule reader & reflection
  - `lib/features/juega/widgets/paso_cancion_widget.dart`: Phase 1 cancion a pulso & player
  - `lib/features/juega/widgets/paso_conto_widget.dart`: Phase 2 cuento guiado
  - `lib/features/juega/widgets/paso_preguntas_widget.dart`: Phase 3 graded scaffolding questions
  - `lib/features/juega/widgets/paso_exploracion_widget.dart`: Phase 4 sensory exploration & safety notice
  - `lib/features/juega/widgets/paso_matematicas_widget.dart`: Phase 5 early mathematics
  - `lib/features/juega/widgets/paso_ponte_casa_widget.dart`: Phase 6 home bridge
  - `lib/features/juega/views/asamblea_guiada_screen.dart`: 6-step assembly wizard
  - `lib/features/juega/views/unidades_list_screen.dart`: Age-filtered units list
  - `lib/main.dart`: Route navigation integration
  - `test/features/academy/academy_flow_test.dart`: Academy widget test suite
  - `test/features/juega/juega_flow_test.dart`: Juega con Lúa widget test suite
- **Build status**: PASS (100% across all suites)
- **Pending issues**: None

## Quality Status
- **Build/test result**: PASS (110 checks in verify_m3.py, 95 in verify_m1.py, 93 in verify_m2.py, 80 in m1_stress, 76 in m2_stress)
- **Lint status**: 0 violations, zero forbidden clinical terms, zero network dependencies
- **Tests added/modified**: `test/features/academy/academy_flow_test.dart`, `test/features/juega/juega_flow_test.dart`

## Loaded Skills
- None explicitly loaded
