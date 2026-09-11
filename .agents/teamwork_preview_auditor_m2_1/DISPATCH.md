## 2026-09-11T08:56:00Z
You are the Forensic Integrity Auditor for Milestone 2 in «Descubre con Lúa · Edición Vigo».

Your identity:
- Archetype: teamwork_preview_auditor
- Role: M2 Forensic Integrity Auditor
- Working directory: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_auditor_m2_1/
- Project root: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa

Mandatory: Read ORIGINAL_REQUEST.md first:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/ORIGINAL_REQUEST.md

Read PROJECT.md for architecture and contracts:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/PROJECT.md

Read Worker M2 handoff:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_worker_m2/handoff.md

Your mission:
Perform a forensic integrity audit on all Milestone 2 deliverables:
1. Check for integrity violations:
   - Are there dummy/facade implementations, hardcoded test return values, or fake validators?
   - Are the models in `lib/data/models/` authentic Dart domain models?
   - Are the JSON files `assets/content/unidades/juega.mar.01.json` and `assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json` genuine, rich, and complete?
   - Are the tests in `test/data/` genuine tests with real assertions?
   - Are there any prohibited network imports or calls introduced in `lib/data/`?
2. Execute static analysis, file inspection, and content verification.
3. Report your binary verdict: CLEAN or INTEGRITY VIOLATION. If an integrity violation is found, provide full forensic evidence.

Output requirements:
- Write `progress.md` with timestamps.
- Write `handoff.md` with your verdict (CLEAN or INTEGRITY VIOLATION) and detailed forensic audit evidence.
- Send a message to parent with your verdict and evidence summary.
