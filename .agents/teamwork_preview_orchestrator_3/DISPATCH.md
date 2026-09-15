# DISPATCH

## 2026-09-14T13:16:51Z

You are the Project Orchestrator for the next milestone of «Descubre con Lúa · Edición Vigo».

Your working directory is:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_orchestrator_3

The project root is:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa

The authoritative user request is located at:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/ORIGINAL_REQUEST.md
(Refer to the latest section: "## Follow-up — 2026-09-14T13:15:17Z")

### Task Summary
Implement the specific module for Early Childhood Assemblies for schools (Segundo Ciclo: 4.º, 5.º and 6.º de Educación Infantil, 3 to 6 years) in «Descubre con Lúa», based on Total Physical Response (TPR) in L3 (English) within the trilingual context of Galicia (Decreto 150/2022), maintaining strict Clean Architecture continuity, sober glanceable UI for teachers (zero screens for children), staggered curricular progression (vertical slice centered on September for all three levels: 4th, 5th, 6th), and ecological home transfer (Academy / recast).

### Scope & Requirements
1. **R1. Data Model and JSON Schemas for Segundo Ciclo (4th, 5th, 6th Infantil)**:
   - Immutable data structures and JSON schemas decoupled from and compatible with existing 0-3 architecture.
   - Distinct TPR methodologies by level: Action-Expanded (4th), Dramatized/Narrative (5th), Transactional/Pragmatic peer-to-peer (6th).
   - 4 canonical assembly phases: Opening/Greeting (1:30 min), Movement & Rhythmic Focus (2:00 min), Core TPR Challenge (4:30 min), Calm & Transition Out (2:00 min).
   - Metadata linking to Decreto 150/2022 (areas: Comunicación e Representación da Realidade, Crecemento en Harmonía, Descubrimento e Exploración da Contorna), unstructured natural materials of Galicia (mimbre, castañas, conchas, gasas), and home routine link.

2. **R2. Classroom Backstage Assistant for Teachers (Morning Circle / Asamblea Guiada 3-6 years)**:
   - Dedicated teacher-only backstage interface (glanceable UI, dark mode, high contrast >= 24sp readable from 2m, zero gamification or child interaction).
   - Broad touch targets for phase transitions, discrete timer per phase, smooth fade-in/fade-out audio controls integrated with offline audio.
   - Continuous level switcher (4th, 5th, 6th) integrated cleanly with main navigation without breaking 1st cycle (0-3).

3. **R3. Curricular Vertical Slice (Pilot Month: September) & Home Micro-routines**:
   - Complete content for September ("Acollida, espazos escolares e novas rutinas") differentiated for 4th, 5th, and 6th Infantil.
   - Academy home micro-routine for September (getting dressed / hanging coats) with indirect corrective modeling (recast) guide, 3-5 min niching.

4. **R4. Validation Suite, Privacy & Automated Tests**:
   - Curricular validator for Decreto 150/2022 areas and zero clinical/diagnostic terms (blacklist).
   - Structural integrity check of the 4 phases and content parity.
   - Widget tests for phase navigation and ensuring no child game elements in teacher UI.
   - 100% offline, zero network calls, zero internet permissions.
   - All tests passing with exit code 0 (`flutter test`).

### Rules & Protocol
- Keep `BRIEFING.md` and `progress.md` updated in your working directory.
- Dispatch subagents following the subagent directory conventions (`.agents/<type>_<milestone>...`).
- When all implementations, validations, and tests pass, send your final completion report to parent sentinel.
