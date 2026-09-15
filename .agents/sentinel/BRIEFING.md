# BRIEFING — 2026-09-14T13:16:00Z

## Mission
Sentinel monitoring and lifecycle management for Descubre con Lúa · Edición Vigo (Segundo Ciclo de Educación Infantil: 4.º, 5.º y 6.º - Módulo específico de Asambleas con TPR en L3, Decreto 150/2022, UI docente sobria de trastienda, vertical slice Septiembre y transferencia al hogar).

## 🔒 My Identity
- Archetype: sentinel
- Working directory: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/sentinel
- Orchestrator: e7633361-cefb-4427-91ff-c3fbb93625fc
- Victory Auditor: to be spawned on victory claim

## 🔒 Key Constraints
- No technical decisions — relay only
- Victory Audit is MANDATORY before reporting completion
- Must not write code, analyze problems, or make technical decisions; keep context ultra-light
- Strictly record user requests verbatim to ORIGINAL_REQUEST.md
- Spawn teamwork_preview_orchestrator for the General execution path
- Run progress reporting cron (*/8) and liveness check cron (*/10)
- On completion claim, spawn teamwork_preview_victory_auditor; report success only after VICTORY CONFIRMED
- Clean up subagents and cancel crons before final delivery

## User Context
- **Last user request**: Módulo específico de Asambleas de Infantil para colegios (Segundo Ciclo: 4.º, 5.º y 6.º de Educación Infantil, 3 a 6 años) en «Descubre con Lúa», fundamentado en TPR en L3 (inglés) dentro del contexto trilingüe de Galicia (Decreto 150/2022), diseño sobrio para docente, vertical slice Septiembre y micro-rutinas para el hogar (recast).
- **Pending clarifications**: none
- **Delivered results**:
  - Previous milestones: Foundation, 0-3 Juega con Lúa, Academy, Calendar synchronization and 10-month curriculum.

## Project Status
- **Phase**: in progress
- **Route**: General (`teamwork_preview_orchestrator`)
- **Active Orchestrator**: `e7633361-cefb-4427-91ff-c3fbb93625fc` (`teamwork_preview_orchestrator_3`)
- **Crons**:
  - Progress reporting: `task-34` (`*/8 * * * *`)
  - Liveness check: `task-36` (`*/10 * * * *`)

## Victory Audit Status
- **Triggered**: no
- **Verdict**: pending
- **Retry count**: 0

## Artifact Index
- /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/ORIGINAL_REQUEST.md — Authoritative record of user request
- /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/ORIGINAL_REQUEST.md — Duplicate copy of authoritative record of user request
