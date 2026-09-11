## 2026-09-11T09:02:04Z

You are the Remediation Worker for Milestone 2 (Iteration 2) in «Descubre con Lúa · Edición Vigo».

Your identity:
- Archetype: teamwork_preview_worker
- Role: M2 Remediation Worker
- Working directory: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_worker_m2_it2/
- Project root: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa

Mandatory: Read ORIGINAL_REQUEST.md first:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/ORIGINAL_REQUEST.md

Read PROJECT.md for architecture and contracts:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/PROJECT.md

Read Challenger 1, Challenger 2, Reviewer 1, and Reviewer 2 reports:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_challenger_m2_1/handoff.md
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_challenger_m2_2/handoff.md
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_reviewer_m2_1/handoff.md
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_reviewer_m2_2/handoff.md

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

Your write ownership:
`lib/data/**`, `assets/content/**`, `test/data/**`.

Tasks to execute:
1. Fix `lib/data/validators/content_validator.dart`:
   a. Update `forbiddenClinicalPattern` to catch all inflected verbs, participles, adjectives, Galician screening terms, and Spanish 'patológico', while safely exempting 'tratamento de auga' / 'tratamiento de agua':
      ```dart
      static final RegExp forbiddenClinicalPattern = RegExp(
        r'\b(trastorno|trastornos|patolog[ií]a|patolog[ií]as|patolox[ií]a|patolox[ií]as|patol[oó][gx]ic[oa]s?|'
        r'diagn[oó]stic[oa]s?|diagnostic[a-záéíóúñ]+|s[ií]ntoma|s[ií]ntomas|sintomatolog[ií]a|'
        r'sintomatolox[ií]a|d[eé]ficit|d[eé]ficits|paciente|pacientes|terapia|'
        r'terapias|terap[eé]utic[oa]s?|'
        r'(?!(tratamiento|tratamento)\s+d[eé]\s+a(ug|gu)a)(tratamiento|tratamientos|tratamento|tratamentos)|'
        r'retrasos?\s+cl[ií]nic[oa]s?|dislalia|dislalias|disl[aá]lic[oa]s?|dislexia|dislexias|disl[eé]xic[oa]s?|'
        r'hipoacusia\s+cl[ií]nica|afasia|disfasia|rehabilit[a-záéíóúñ]+|'
        r'criba[sxd]?[a-záéíóúñ]*|screening|pron[oó]stico)\b',
        caseSensitive: false,
      );
      ```
   b. Update `placeholderPattern` to include `PLACEHOLDER`:
      ```dart
      static final RegExp placeholderPattern = RegExp(
        r'\b(TODO|TBD|PLACEHOLDER|PENDIENTE|PENDENTE|LOREM\s+IPSUM)\b',
        caseSensitive: false,
      );
      ```
   c. Add defensive type-safe Map extraction (e.g. `_asMap(dynamic v)`) to prevent runtime `TypeError` crashes when non-map types are passed in nested JSON nodes.
   d. Add BPM range validation for `CancionPulso` (BPM must be integer between 40 and 160).
   e. Ensure `id` is verified as non-empty String.

2. Fix `lib/data/models/unidad_model.dart`:
   - Refine `matchesAgeBand(String filter)`:
     ```dart
     bool matchesAgeBand(String filter) {
       final f = filter.trim();
       final validFilters = const {'0-2', '2-3', '0-3'};
       if (!validFilters.contains(f)) return false;
       if (tramoEtario == '0-3') return true;
       return tramoEtario == f;
     }
     ```

3. Polish Galician text in base JSONs:
   - In `assets/content/unidades/juega.mar.01.json`:
     - Line 286: `"no aula"` -> `"na aula"`
     - Line 121: `"Pesa dura..."` -> `"Peza dura..."`
     - Line 58: remove Spanish opening exclamation `¡` (`¡Aaaah!` -> `Aaaah!`)
   - In `assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json`:
     - Line 28: `"nos dedas"` -> `"nos dedos"`

4. Update test suites in `test/data/`:
   - Ensure `test/data/clinical_terms_blacklist_test.dart` and `test/data/run_m2_adversarial_suite.py` test the expanded regex (e.g. `diagnosticaron`, `retrasos clínicos`, `cribados`, `cribaxe`, `placeholder`, and allow `tratamento de auga`).
   - Run Challenger 1's suite `test/data/m2_challenger_adversarial_suite.py` and verify all 57 checks pass (exit code 0).
   - Run Challenger 2's suite `test/data/run_m2_challenger_stress.py` and verify all 72 checks pass (exit code 0).
   - Run `verify_m2.py` and verify 100% checks pass.
   - Run `verify_m1.py` to confirm zero regressions.
