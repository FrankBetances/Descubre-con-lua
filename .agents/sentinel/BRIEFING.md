# BRIEFING — 2026-09-20T15:13:30Z

## Mission
Sentinel lifecycle supervision and monitoring for the migration of pedagogical content and UI modules from React/TS prototype into native Flutter (Descubre con Lúa · Edición Vigo).

## 🔒 My Identity
- Archetype: sentinel
- Working directory: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/sentinel
- Orchestrator: 9e628138-021d-44c9-9a72-2da6208e84bb
- Victory Auditor: [to be spawned on victory claim]

## 🔒 Key Constraints
- No technical decisions — relay only
- Victory Audit is MANDATORY before reporting completion
- Must not write code, analyze problems, or make technical decisions; keep context ultra-light
- Strictly record user requests verbatim to ORIGINAL_REQUEST.md
- Spawn teamwork_preview_orchestrator for the General execution path
- Run progress reporting cron (*/8) and liveness check cron (*/10)
- On completion claim, spawn teamwork_preview_victory_auditor; report success only after VICTORY CONFIRMED
- Clean up subagents and cancel crons before final delivery
- Git branch: work on `studio` only, never touch `main`
- Zero internet permissions in AndroidManifest.xml (tools:node="remove")
- Offline only: no network libraries, no TTS/speech web APIs

## User Context
- **Last user request**: Migrar todo el contenido pedagógico y módulos de UI desde el prototipo React/TS (disponible localmente en `.studio_ref/`) a la app nativa Flutter en la rama `studio`. Cero código React/web en el repo Flutter. Todo Dart + JSON offline sin internet. R1 (conversión de 15+ archivos TS a JSON), R2 (modelos Dart y repositorio), R3 (pantallas para cuentos, láminas, palabras 8000, english, lectura, planificador), R4 (calendario 5 cursos, Portal Dual, UserProgress, FSRS v4.5), R5 (commit y push a origin/studio).
- **Pending clarifications**: none (reference files placed inside workspace at `.studio_ref/`).
- **Delivered results**:
  - Relevamiento y especificaciones técnicas completadas al 100% por el orquestador y subagentes.
  - Diseño de suites E2E (Dual Track) preparadas para validación de privacidad y contenido JSON.

## Project Status
- **Phase**: in progress
- **Route**: General (`teamwork_preview_orchestrator`)
- **Active Orchestrator**: 9e628138-021d-44c9-9a72-2da6208e84bb (.agents/teamwork_preview_orchestrator_2/)
- **Cron 1 (Reporting, */8)**: task-26
- **Cron 2 (Liveness, */10)**: task-28

## Victory Audit Status
- **Triggered**: no
- **Verdict**: pending
- **Retry count**: 0

## Artifact Index
- /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/ORIGINAL_REQUEST.md — Authoritative record of user request
- /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/ORIGINAL_REQUEST.md — Duplicate copy of authoritative record of user request
- /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_orchestrator_2/context.md — Active orchestrator initial context
