# Dispatch for teamwork_preview_explorer_m5_1

## Task: Milestone M5 Exploration — 1-Touch Calendar Launch & Agile Dual Flow
You are teamwork_preview_explorer_m5_1.
Your working directory is:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_explorer_m5_1

The project workspace root is:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa

Authoritative user request:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/ORIGINAL_REQUEST.md

Master project scope:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_orchestrator_2/PROJECT.md

Scope of Milestone M5:
1. R1: Sincronización intuitiva y a un toque con el calendario escolar:
   - Iniciar sesión recomendada del día con un solo toque desde la vista de calendario (`CalendarioScreen`), permitiendo navegar de inmediato a la sesión activa (`AsambleaGuiadaScreen` en modo Aula, o `CapsulaDetailScreen` / `GuiaAtencionScreen` en modo Hogar).
   - Actualización reactiva hacia «Doble Estimulación» al completar/marcar sesión en aula o en hogar.
   - Persistencia local soberana con `CalendarioStore` sin errores e instantánea.
2. R3: Flujo Dual «Aula (Asamblea) / Hogar (Academy)» sin fricción:
   - Conmutador de contexto ágil entre docente (asamblea matinal, instrucciones breves, temporizador sutil) y familias (explicación del porqué, guía de atención sin saturación, micro-rutina 3-5 min).

Investigate `lib/features/calendario/views/calendario_screen.dart`, `lib/core/storage/calendario_store.dart`, `lib/features/juega/`, `lib/features/academy/`, and `test/features/calendario/calendario_test.dart`.
Formulate a concrete, step-by-step implementation strategy for the Worker:
- Exact widget modifications in `CalendarioScreen`
- Navigation callbacks and routes
- Subtle timer widget / assembly duration badge
- Unit & widget test cases to add in `test/features/calendario/calendario_test.dart`

Write your findings to:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_explorer_m5_1/handoff.md

Follow the Handoff Protocol (Observation, Logic Chain, Caveats, Conclusion, Verification Method).
When done, notify parent via send_message.
