# Dispatch for teamwork_preview_worker_m5_1

## Task: Milestone M5 Implementation — 1-Touch Calendar Launch & Agile Dual Flow
You are teamwork_preview_worker_m5_1.
Your working directory is:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_worker_m5_1

The project workspace root is:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa

Authoritative user request:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/ORIGINAL_REQUEST.md

Master project scope:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_orchestrator_2/PROJECT.md

Explorer findings and specifications:
- /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_explorer_m5_1/handoff.md
- /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_explorer_m5_2/handoff.md
- /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_explorer_m5_3/handoff.md

Exclusive file ownership:
- `lib/features/calendario/widgets/temporizador_sutil_widget.dart`
- `lib/features/calendario/widgets/boton_lanzar_sesion.dart`
- `lib/features/calendario/views/calendario_screen.dart`
- `lib/main.dart`
- `lib/features/juega/views/unidades_list_screen.dart`
- `lib/features/academy/views/bloques_list_screen.dart`
- `test/features/calendario/calendario_test.dart`

Mandatory Integrity Warning:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

Implementation steps:
1. Create `lib/features/calendario/widgets/temporizador_sutil_widget.dart` with adult-oriented, non-distracting visual timer and duration window (5-8 min for Aula, 3-5 min for Fogar).
2. Create `lib/features/calendario/widgets/boton_lanzar_sesion.dart` with accessible 52dp 1-touch launch action button.
3. Update `lib/features/calendario/views/calendario_screen.dart`:
   - Add `typedef IniciarSesionCallback = void Function(MesCurricular mes, bool esDocente);`.
   - Add `onIniciarSesion`, `repository`, `audioService`, and `premios` to constructor.
   - Implement `_lanzarSesion` method navigating to `AsambleaGuiadaScreen` (Aula) or `CapsulaDetailScreen`/`GuiaAtencionScreen` (Fogar).
   - Integrate `TemporizadorSutilWidget`, brief teacher cues, family explanation, and link to `GuiaAtencionScreen`.
   - Revamp action area with `BotonLanzarSesion` as primary 1-touch action, plus secondary manual toggle.
4. Update call sites in `lib/main.dart`, `unidades_list_screen.dart`, and `bloques_list_screen.dart` to pass repository, audioService, and premios.
5. Augment `test/features/calendario/calendario_test.dart` with comprehensive tests verifying:
   - 1-touch launch callback execution for both Aula and Fogar modes.
   - Dual-role switcher and subtle timer rendering.
   - Reactive Doble Estimulación UI state transitions.
   - Bilingual parity in launcher and timer labels.
6. Verify locally:
   - Run python3 tools gates (`check_contact_email.py`, `export_voice_corpus.py --check`, `check_voice_coverage.py`, `check_manual_build.py`, `check_legal_urls.py --offline`).
   - Check code formatting and static analysis cleanliness.

Write your report to:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_worker_m5_1/handoff.md

Follow the Handoff Protocol (Observation, Logic Chain, Caveats, Conclusion, Verification Method).
When done, notify parent via send_message.

## 2026-09-13T09:18:31Z
You are teamwork_preview_worker_m5_1.
Working directory: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_worker_m5_1
Workspace root: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa

Read /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_worker_m5_1/DISPATCH.md and the explorer handoffs referenced therein.
Authoritative user request: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/ORIGINAL_REQUEST.md

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

Exclusive file ownership:
- lib/features/calendario/widgets/temporizador_sutil_widget.dart
- lib/features/calendario/widgets/boton_lanzar_sesion.dart
- lib/features/calendario/views/calendario_screen.dart
- lib/main.dart
- lib/features/juega/views/unidades_list_screen.dart
- lib/features/academy/views/bloques_list_screen.dart
- test/features/calendario/calendario_test.dart

Implement the 1-touch session launcher, agile dual flow (Aula vs Fogar), subtle timer, and comprehensive tests according to the instructions in DISPATCH.md.
Run the local python3 quality gates and verify everything passes cleanly.

Write your report to:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_worker_m5_1/handoff.md

Follow the Handoff Protocol (Observation, Logic Chain, Caveats, Conclusion, Verification Method).
When done, notify parent via send_message.
