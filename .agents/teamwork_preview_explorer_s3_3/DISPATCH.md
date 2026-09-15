# DISPATCH — UI/UX & Integration Explorer (s3_3)

## Identity
- Type: teamwork_preview_explorer
- Working Directory: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_explorer_s3_3
- Parent Conversation ID: e7633361-cefb-4427-91ff-c3fbb93625fc

## Objective
Investigate the UI/UX, navigation, audio integration, and widget testing architecture for «Descubre con Lúa · Edición Vigo».
1. Read `/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/ORIGINAL_REQUEST.md` (specifically section `## Follow-up — 2026-09-14T13:15:17Z`), `PROJECT.md`, `STATUS.md`, and inspect `lib/features/`, `lib/core/`, and `test/features/`.
2. Analyze how to implement the Classroom Backstage Assistant for teachers (Morning Circle / Asamblea Guiada 3-6 years):
   - Dedicated teacher-only backstage interface (glanceable UI, dark mode, high contrast >= 24sp readable from 2m, zero gamification or child interaction).
   - Phase progress indicator and large touch targets for transitions across the 4 phases.
   - Discrete timer per phase.
   - Audio controls integration (fade-in / fade-out, offline audio service compatibility).
   - Continuous level switcher (4th, 5th, 6th Infantil) integrated cleanly into navigation without breaking 1st cycle (0-3).
   - Academy home view extension for the September micro-routine and recast guide.
3. Formulate testing strategy for widgets (verifying no child elements, verifying timer, navigation, level switching).
4. 
## 2026-09-14T13:18:16Z
You are the UI/UX & Integration Explorer for the Segundo Ciclo (3-6 years) module in «Descubre con Lúa · Edición Vigo».
Your working directory is: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_explorer_s3_3
Your dispatch instructions are at: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_explorer_s3_3/DISPATCH.md

MANDATORY: You MUST read /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/ORIGINAL_REQUEST.md before doing any work (specifically the section '## Follow-up — 2026-09-14T13:15:17Z').
Also read /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/STATUS.md, PROJECT.md, and inspect lib/features/ (juega, academy, home), lib/core/ (theme, audio), and test/features/.

Investigate:
1. Teacher-only backstage interface design (dark mode, glanceable, high contrast >= 24sp readable at 2 meters, large touch targets, zero child screens or gamification).
2. Discrete phase timer per phase (1:30, 2:00, 4:30, 2:00) and smooth phase navigation.
3. Audio controls integration (fade-in / fade-out, OfflineAudioService compatibility).
4. Continuous level switcher (4th, 5th, 6th) and integration with main app navigation without breaking 1st cycle (0-3).
5. Academy home view extension for September micro-routine and recast guidance.
6. Widget test strategy for teacher backstage UI and navigation.
7. Write your detailed findings and component architecture proposal to handoff.md in your working directory and notify the parent orchestrator via send_message.
