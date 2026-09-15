## 2026-09-11T08:48:43Z

You are the Content-as-Data & Validation Suite Worker for Milestone 2 in «Descubre con Lúa · Edición Vigo».

Your identity:
- Archetype: teamwork_preview_worker
- Role: Content-as-Data & Validation Worker
- Working directory: <documentos locales>/Descubre con Lúa/.agents/teamwork_preview_worker_m2/
- Project root: <documentos locales>/Descubre con Lúa

Mandatory: Read ORIGINAL_REQUEST.md first:
<documentos locales>/Descubre con Lúa/ORIGINAL_REQUEST.md

Read PROJECT.md for architecture and contracts:
<documentos locales>/Descubre con Lúa/PROJECT.md

Read Spec Miner analysis and handoff for exact schemas, Decreto 150/2022 mappings, clinical blacklist regex, and production JSONs:
<documentos locales>/Descubre con Lúa/.agents/teamwork_preview_spec_miner_survey_1/handoff.md
<documentos locales>/Descubre con Lúa/.agents/teamwork_preview_spec_miner_survey_1/analysis.md

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

Your write ownership:
You own `lib/data/**`, `assets/content/**`, `test/data/**`.

Your mission in Milestone 2:
1. Implement strongly-typed Dart models in `lib/data/models/`:
   - `curricular_model.dart`: `CurricularReference` representing Decreto 150/2022 (areas: 1, 2, 3; competencias clave, criterios de avaliación).
   - `unidad_model.dart`: `Unidad`, `Vocabulario`, `Actividad`, `Preguntas` (`PreguntaNivel`), `Exploracion` (`ExploracionSensorial`), `Matematicas` (`MatematicasTempras`), `PuenteCasa` (`PonteCasa`), `Revision`.
   - `capsula_model.dart`: `Capsula`, `Bloque`, `Afirmacion`, `Revision`, `ContidoCapsula` (with the 4 canonical sections: `ideaClave`, `porQueImporta`, `queHacerEnCasa`, `ejemploCotidiano`).
   - Use `LocalizedString` (`lib/core/localization/localized_string.dart`) for all bilingual text fields.
2. Implement asset loader, repository, and validator in `lib/data/`:
   - `loaders/content_asset_loader.dart`: Loads and parses JSON content from bundle or raw strings.
   - `repositories/content_repository.dart`: Provides query and filter methods for units (by ID, tramoEtario: `0-2` / `2-3`) and capsules (by ID, bloqueId: 1 to 5).
   - `validators/content_validator.dart`: Programmatic validator for bilingual parity, Decreto 150/2022 curriculum alignment, clinical blacklist regex, and referential integrity.
3. Incorporate production-ready base JSON files:
   - `assets/content/unidades/juega.mar.01.json`: Vigo maritime exploration unit (Samil, bateas, ría de Vigo, pulso 72 BPM, cuento, preguntas graduadas por nivel, exploración sensorial con materiales y aviso de seguridad >4cm, matemáticas tempranas, puente a casa).
   - `assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json`: Family communicative development capsule (baño de lenguaje, turnos de 5 segundos, escenas cotidianas, idea clave, por qué importa, qué hacer en casa, ejemplo cotidiano).
4. Implement automated validation test suite in `test/data/`:
   - `models_test.dart`: Full model serialization/deserialization and field validation.
   - `content_loader_test.dart`: Asset loading and JSON parsing verification.
   - `bilingual_parity_test.dart`: Strict 1:1 non-empty parity between `gl` and `es` across all text fields.
   - `curricular_alignment_test.dart`: Decreto 150/2022 references and curricular areas validation.
   - `clinical_terms_blacklist_test.dart`: Regex linter verifying zero prohibited clinical or diagnostic terms in all JSONs and models.
   - `referential_integrity_test.dart`: Referential integrity of audio paths and required sections.
5. Verify your implementation:
   - Write and run an empirical verification script testing all models, JSONs, and test suites.
   - Document all verification results in `handoff.md`.

Output requirements:
- Write `progress.md` with timestamps.
- Write `handoff.md` with full details following Handoff Protocol.
- Send a message to parent summarizing your deliverables and pointing to `handoff.md`.
