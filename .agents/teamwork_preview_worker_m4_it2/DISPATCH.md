## 2026-09-11T14:12:03Z
You are the Remediation Worker for Milestone 4 (Iteration 2) in «Descubre con Lúa · Edición Vigo».

Your identity:
- Archetype: teamwork_preview_worker
- Role: M4 Remediation Worker
- Working directory: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_worker_m4_it2/
- Project root: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa

Mandatory: Read ORIGINAL_REQUEST.md first:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/ORIGINAL_REQUEST.md

Read PROJECT.md for architecture, feature inventory, and contracts:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/PROJECT.md

Read Reviewer 1 and Reviewer 2 handoffs:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_reviewer_m4_1/handoff.md
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_reviewer_m4_2/handoff.md

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

Your write ownership:
`test/**`, `verify_m1.py`, `verify_m2.py`, `verify_m3.py`, `TEST_READY.md`, `.agents/teamwork_preview_worker_m4_it2/**`.

Specific tasks to execute:
1. Fix `test/run_all_e2e_tests.py`:
   - Implement `DEFAULT_TIMEOUT_SEC = 60` (or 120s for heavier suites).
   - Add `timeout=DEFAULT_TIMEOUT_SEC` to all `subprocess.run()` calls in `run_dart_test_suite` and `run_python_suite`.
   - Add explicit `try ... except subprocess.TimeoutExpired as exc:` handling that records a descriptive timeout failure message, captures partial output, sets `passed = False`, and ensures clean process termination.
   - Fix Flutter error diagnostic capture on line 236:
     ```python
     error_msg = (proc.stderr.strip() or proc.stdout.strip()) if not passed else ""
     ```
     so that native `flutter test` failure traces printed to stdout are not masked by empty stderr.
2. Decouple root verification scripts from `.agents/`:
   - Inspect `verify_m1.py`, `verify_m2.py`, and `verify_m3.py` at the project root.
   - Remove any dependency or delegation to files inside `.agents/teamwork_preview_worker_m*/`.
   - Incorporate the complete verification logic directly inside `verify_m1.py`, `verify_m2.py`, and `verify_m3.py` (or co-locate helper modules in `test/tools/` or `test/infrastructure/`), making them 100% self-contained and runnable in clean checkouts where `.agents/` does not exist.
3. Verify test suite execution:
   - Run `python3 test/run_all_e2e_tests.py` and verify all 27 suites pass with exit code 0.
   - Run `python3 verify_m1.py`, `python3 verify_m2.py`, `python3 verify_m3.py` directly to confirm they work independently.
   - Run `python3 test/probe_master_runner_resilience.py` to ensure all runner resilience assertions pass.
   - Update `TEST_READY.md` if any references changed.
4. Deliverables:
   - Write `progress.md` with timestamps.
   - Write `handoff.md` following the Handoff Protocol (Observation, Logic Chain, Caveats, Conclusion, Verification Method) with all command execution outputs.
   - Send completion message to parent orchestrator.
