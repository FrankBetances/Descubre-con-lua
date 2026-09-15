# Dispatch for teamwork_preview_explorer_m6_3_rep

## Task: Milestone M6 Exploration — Static Assets Strict Audit & Widget Test Blueprint (Replacement)
You are teamwork_preview_explorer_m6_3_rep.
Your working directory is:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_explorer_m6_3_rep

Workspace root:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa

Authoritative user request:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/ORIGINAL_REQUEST.md

Master project scope:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_orchestrator_2/PROJECT.md

CRITICAL ENVIRONMENT MANDATE:
DO NOT use BypassSandbox=true. DO NOT attempt to find or execute flutter on the host system. Flutter CLI runs in CI runners (per STATUS.md). Use python3 quality gate scripts, directory listings, and file viewing tools for empirical verification.

Scope of Milestone M6:
Requirement R2 & Quality:
1. Strict physical verification of static assets:
   - Check all asset files in `assets/brand/`, `assets/brand/logos/`, `assets/voice/`, `assets/audio/`, `assets/fonts/`.
   - Verify that 100% of declared extensions match physical files (`.png`, `.jpg`, `.m4a`, `.ttf`, `.wav`).
   - Re-verify with python3 quality scripts in `tools/`.
2. Widget test strategy for Milestone M6:
   - Identify new widget tests to add in `test/features/calendario/` for:
     * High-contrast visual flashcard rendering for each of the 10 curricular months.
     * 4 session moments rendering on the card (Apertura, Fingerplay, TPR con LJSpeech, Cierre).
     * `BotonEscuchar` presence and audio path verification for English TPR and Galician models.
     * Atlantic palette token usage and contrast compliance.
3. Provide concrete Dart test blueprints for Worker M6.

Write your findings to:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_explorer_m6_3_rep/handoff.md

Notify parent via send_message when complete.

## 2026-09-13T09:37:32Z
You are teamwork_preview_explorer_m6_3_rep.
Working directory: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_explorer_m6_3_rep
Workspace root: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa

Read /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_explorer_m6_3_rep/DISPATCH.md, /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/ORIGINAL_REQUEST.md, and /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_orchestrator_2/PROJECT.md.

CRITICAL: DO NOT use BypassSandbox=true. DO NOT attempt to run flutter on host.

Strict physical audit of static assets and extensions. Re-verify python3 quality gates. Formulate widget test blueprints for Milestone M6 visual cards and audio buttons in test/features/calendario/.
Write report to:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_explorer_m6_3_rep/handoff.md
When done, notify parent via send_message.
