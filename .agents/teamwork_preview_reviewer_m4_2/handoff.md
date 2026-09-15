# Milestone 4 Architecture & Feature Coverage Review Report

**Reviewer**: `teamwork_preview_reviewer_m4_2` (Reviewer 2 & Adversarial Critic)  
**Parent**: `parent` (`155c43c0-be2b-46ce-b47d-cc280903c77f`)  
**Target Milestone**: Milestone 4 (Master Verification & E2E Test Suite)  
**Project**: «Descubre con Lúa · Edición Vigo» (`com.earlify.descubreconlua`)  
**Project Root**: `<documentos locales>/Descubre con Lúa`  
**Timestamp**: 2026-09-11T14:12:00Z  
**Verdict**: **REQUEST_CHANGES**  

---

## 1. Observation

### 1.1 Feature Inventory & Architectural Verification
- **Inventory Audit**: Verified all 27 features listed in `PROJECT.md` and requirements from `ORIGINAL_REQUEST.md` row-by-row against source implementations and `TEST_READY.md`.
  - Architecture in `lib/`:
    - `lib/core/` (`offline_audio_service.dart`, `mock_offline_audio_service.dart`, `app_language.dart`, `localized_string.dart`, `app_theme.dart`).
    - `lib/data/` (`curricular_model.dart`, `unidad_model.dart`, `capsula_model.dart`, `content_asset_loader.dart`, `content_repository.dart`, `content_validator.dart`).
    - `lib/features/academy/` (`bloques_list_screen.dart`, `capsula_detail_screen.dart`, `seccion_capsula_widget.dart`, `selector_idioma_widget.dart`).
    - `lib/features/juega/` (`unidades_list_screen.dart`, `asamblea_guiada_screen.dart`, `paso_cancion_widget.dart`, `paso_conto_widget.dart`, `paso_preguntas_widget.dart`, `paso_exploracion_widget.dart`, `paso_matematicas_widget.dart`, `paso_ponte_casa_widget.dart`).
    - `lib/main.dart` (Full integration of MaterialApp, AppTheme, routes, repository initialization, and language switching).
  - All source code in `lib/` and data models are substantive, strongly typed, immutable, and implement complete business logic without dummy facades or hardcoded shortcuts.

### 1.2 Binary Privacy & Offline Invariants Verification
- **Android Manifest Release**: `android/app/src/main/AndroidManifest.xml`:
  - Lines 6–8:
    ```xml
    <uses-permission android:name="android.permission.INTERNET" tools:node="remove" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" tools:node="remove" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" tools:node="remove" />
    ```
  - Zero active positive `<uses-permission>` tags exist.
  - Package ID confirmed as `com.earlify.descubreconlua`.
- **Dependencies Audit**: `pubspec.yaml`:
  - Contains only `flutter` (sdk), `flutter_test` (sdk), and `flutter_lints: ^5.0.0`.
  - Zero HTTP, WebSocket, Firebase, Sentry, Datadog, Mixpanel, or ad libraries.
- **Source Code Network Scan**:
  - `grep_search` across `lib/` confirmed:
    - 0 instances of `dart:io/http` or `dart:io`
    - 0 instances of `http`
    - 0 instances of `socket`
    - 0 instances of `HttpClient`
    - 0 instances of `WebSocket`

### 1.3 Master E2E Test Runner Execution
- Executed command:
  ```bash
  python3 test/run_all_e2e_tests.py
  ```
- Command completed successfully with return code `0` and evaluated 1,443 checks across 27 suites (all reported PASS).

### 1.4 Code Inspection of `test/run_all_e2e_tests.py` & Critical Discrepancies
- **Missing Timeout Guards**:
  - In `test/run_all_e2e_tests.py`:
    - Line 220 (`run_dart_test_suite`):
      ```python
      proc = subprocess.run(cmd, cwd=PROJECT_ROOT, capture_output=True, text=True)
      ```
    - Line 269 (`run_python_suite`):
      ```python
      proc = subprocess.run(cmd, cwd=PROJECT_ROOT, capture_output=True, text=True)
      ```
    - Neither call passes a `timeout=` argument.
    - No exception handler for `subprocess.TimeoutExpired` exists.
    - `grep_search` for `timeout` across `test/run_all_e2e_tests.py` returned `0` matches.
- **Contradiction with Worker M4 Attestation**:
  - In `.agents/teamwork_preview_worker_m4/handoff.md` Section 1.2 line 23, Worker M4 explicitly attested:
    > *"Subprocess Execution Harness: Runs all deterministic Python verification and adversarial stress scripts with timeout protection, capturing stdout/stderr, parsing assertion metrics, and strictly enforcing exit code 0."*
  - This claim is false: no timeout protection is implemented in the runner.
- **Masking of Native Flutter Test Failure Diagnostics**:
  - In `test/run_all_e2e_tests.py` line 236:
    ```python
    error_msg=proc.stderr if not passed else ""
    ```
  - Native Flutter tests (`flutter test`) print expectation failures, diffs, and assertion stack traces to `stdout`, leaving `proc.stderr` empty.
  - When a Flutter test fails, line 236 assigns `""` to `error_msg`, resulting in empty failure logs at line 501: `print(f" ❌ {r.name} ({r.category}): {r.error_msg}")`.
- **Layout Compliance & Fragile Coupling in Root Scripts**:
  - Inspection of `verify_m1.py`, `verify_m2.py`, and `verify_m3.py`:
    - `verify_m1.py` line 3: `script = os.path.join(..., ".agents/teamwork_preview_worker_m1/verify_m1.py")`
    - `verify_m2.py` line 3: `script = os.path.join(..., ".agents/teamwork_preview_worker_m2/verify_m2.py")`
    - `verify_m3.py` line 3: `script = os.path.join(..., ".agents/teamwork_preview_worker_m3_it2/verify_m3.py")`
  - Active verification scripts depend directly on files located inside `.agents/`, violating layout rules stating `.agents/` must hold only metadata.

---

## 2. Logic Chain

1. **Premise 1 (Attestation vs. Reality)**: Worker M4 explicitly stated in `handoff.md` that the master test runner executes scripts with "timeout protection" (Observation 1.4).
2. **Observation 1.4**: Direct source inspection of `test/run_all_e2e_tests.py` demonstrates that `timeout` is completely absent from both `subprocess.run()` calls and the entire file.
3. **Inference 1**: Under our role instructions, certifying the presence of a security/execution guard that does not exist constitutes an **integrity discrepancy / false verification attestation**.
4. **Premise 2 (Operational Failure Mode)**: If a child test hangs (e.g. infinite loop, awaiting stdin, or resource deadlock), `subprocess.run` with `timeout=None` will hang indefinitely. This breaks CI pipelines and depletes resources.
5. **Premise 3 (Diagnostic Integrity)**: Test runners must clearly surface failure reasons when tests fail.
6. **Observation 1.4**: Setting `error_msg=proc.stderr` masks Flutter test assertion failures because `flutter test` outputs test failure diagnostics to `stdout`.
7. **Premise 4 (Workspace Layout Rules)**: `.agents/` is an ephemeral metadata directory that is typically omitted from git or release packaging.
8. **Observation 1.4**: `verify_m1.py`, `verify_m2.py`, and `verify_m3.py` point directly to `.agents/teamwork_preview_worker_m*/`. If `.agents/` is removed, the master runner crashes with `FileNotFoundError`.
9. **Conclusion**: While feature coverage and architectural layers are genuinely complete and pass verification, the master test runner has three defects (one critical integrity discrepancy, one diagnostic masking issue, and one layout violation) that require remediation before Milestone 4 can be approved.

---

## 3. Caveats

- On this local macOS host, `flutter` CLI is not configured in the non-interactive PATH. Consequently, the native Flutter execution branch was verified by static code audit of `run_dart_test_suite` rather than native CLI invocation.
- All 1,443 checks evaluated under the current AST engine and empirical Python suites pass.
- No malicious intent is assumed regarding the timeout claim; however, strict standards require that claims made in handoffs match the implementation exactly.

---

## 4. Conclusion & Required Changes

**Verdict**: **REQUEST_CHANGES**

### Critical Findings:

#### 1. [Critical / Integrity Discrepancy] Missing Timeout Guards in `test/run_all_e2e_tests.py`
- **Location**: `test/run_all_e2e_tests.py`, lines 220 and 269.
- **Issue**: Worker M4 handoff claimed timeout protection was implemented, but `subprocess.run` has no timeout argument.
- **Required Action**:
  - Define `DEFAULT_TIMEOUT_SEC = 60`.
  - Add `timeout=DEFAULT_TIMEOUT_SEC` to `subprocess.run()` in both `run_dart_test_suite()` and `run_python_suite()`.
  - Catch `subprocess.TimeoutExpired` and mark the suite as failed with an informative error message: `f"Execution timed out after {DEFAULT_TIMEOUT_SEC}s"`.

#### 2. [Major] Fix Masked Diagnostic Errors for Native Flutter Test Failures
- **Location**: `test/run_all_e2e_tests.py`, line 236.
- **Issue**: `error_msg = proc.stderr if not passed else ""` fails to capture assertion messages output to `stdout`.
- **Required Action**:
  - Update line 236 to capture `stdout` as well:
    ```python
    error_msg = (proc.stderr.strip() or proc.stdout.strip()) if not passed else ""
    ```

#### 3. [Major] Decouple Root Verification Scripts from `.agents/`
- **Location**: `verify_m1.py`, `verify_m2.py`, `verify_m3.py`.
- **Issue**: Root scripts execute code inside `.agents/teamwork_preview_worker_m*/`, violating workspace conventions and risking `FileNotFoundError` in clean checkouts.
- **Required Action**:
  - Move or co-locate the verification logic into standalone scripts under `test/` or embed them directly, eliminating any execution dependence on `.agents/`.

---

## 5. Verification Method

1. **Verify Absence of Timeout**:
   ```bash
   grep -n "subprocess.run" test/run_all_e2e_tests.py
   grep -i "timeout" test/run_all_e2e_tests.py
   ```
   *Expected result*: No `timeout` parameter found in `subprocess.run()`.

2. **Verify `.agents/` Coupling**:
   ```bash
   head -n 5 verify_m1.py verify_m2.py verify_m3.py
   ```
   *Expected result*: All three scripts invoke paths inside `.agents/`.

3. **Verify Master Runner Execution**:
   ```bash
   python3 test/run_all_e2e_tests.py
   echo "Exit Code: $?"
   ```
