#!/usr/bin/env python3
"""
Empirical Adversarial Challenger Probe: Master Test Runner Resilience
«Descubre con Lúa · Edición Vigo» — Milestone 4

Adversarially probes test/run_all_e2e_tests.py:
1. Dart AST Verification Engine Defect Detection:
   - Missing test file detection
   - Syntax error (unbalanced brackets) detection
   - Forbidden network imports detection
   - Missing void main() detection
   - Empty or zero-test file detection
   - Dummy assertion shortcut detection: expect(true, isTrue)
2. Python Suite Subprocess Defect Detection:
   - Missing script detection
   - Non-zero exit code propagation (exit code 1)
   - Unhandled exception propagation
   - Syntax error propagation
3. Dynamic End-to-End Failure Injection into Master Runner:
   - Injected failure in a Python suite -> verify master runner exits with code 1
   - Injected syntax error in a Dart test suite -> verify master runner exits with code 1
   - Missing test file -> verify master runner exits with code 1
   - Verification that no defect can falsely produce exit code 0.
"""

import os
import sys
import shutil
import tempfile
import subprocess
from typing import List, Tuple

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(PROJECT_ROOT, "test"))

from run_all_e2e_tests import verify_dart_test_file, run_dart_test_suite, run_python_suite

checks_total = 0
checks_passed = 0
checks_failed = 0
findings = []

def check(condition: bool, description: str, detail: str = ""):
    global checks_total, checks_passed, checks_failed, findings
    checks_total += 1
    if condition:
        checks_passed += 1
        print(f"  ✅ PASS: {description}")
    else:
        checks_failed += 1
        msg = f"{description}" + (f" -> {detail}" if detail else "")
        findings.append(msg)
        print(f"  ❌ FAIL: {msg}")

print("=" * 75)
print("RUNNING ADVERSARIAL MASTER TEST RUNNER PROBE (CHALLENGER 1 - M4)")
print("=" * 75)

# =============================================================================
# 1. DART STATIC & SEMANTIC AST VERIFICATION ENGINE PROBE
# =============================================================================
print("\n>>> 1. Dart AST Verification Engine Boundary & Defect Probing")

# 1.1 Non-existent file
valid, count, issues = verify_dart_test_file("test/non_existent_file.dart")
check(not valid, "Rejects non-existent Dart test file")
check("File not found" in issues[0], "Reports 'File not found' error message")

# 1.2 Isolated temporary directory for synthetic Dart test mutations
with tempfile.TemporaryDirectory(dir=PROJECT_ROOT) as temp_dir:
    rel_temp_dir = os.path.relpath(temp_dir, PROJECT_ROOT)

    # Helper to write and probe
    def probe_dart_content(filename: str, content: str) -> Tuple[bool, int, List[str]]:
        file_path = os.path.join(temp_dir, filename)
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(content)
        rel_path = os.path.join(rel_temp_dir, filename)
        return verify_dart_test_file(rel_path)

    # 1.3 Empty / too short file
    valid, _, issues = probe_dart_content("empty_test.dart", "// short")
    check(not valid, "Rejects short/empty Dart test file (< 50 chars)")

    # 1.4 Forbidden network import
    net_content = """
    import 'package:flutter_test/flutter_test.dart';
    import 'package:http/http.dart' as http;
    void main() {
      test('test', () {
        expect(1 + 1, equals(2));
      });
    }
    """
    valid, _, issues = probe_dart_content("network_test.dart", net_content)
    check(not valid, "Rejects Dart test importing 'package:http/'")
    check(any("prohibited network import" in err for err in issues), "Flags prohibited network import")

    # 1.5 Missing void main()
    no_main = """
    import 'package:flutter_test/flutter_test.dart';
    void runMyTests() {
      test('test', () {
        expect(1 + 1, equals(2));
      });
    }
    """
    valid, _, issues = probe_dart_content("no_main_test.dart", no_main)
    check(not valid, "Rejects Dart test without 'void main()'")

    # 1.6 Missing flutter_test import
    no_import = """
    void main() {
      test('test', () {
        expect(1 + 1, equals(2));
      });
    }
    """
    valid, _, issues = probe_dart_content("no_import_test.dart", no_import)
    check(not valid, "Rejects Dart test without 'package:flutter_test'")

    # 1.7 Zero assertions
    no_expect = """
    import 'package:flutter_test/flutter_test.dart';
    void main() {
      test('dummy test without assertion', () {
        final a = 1 + 1;
        print(a);
      });
    }
    """
    valid, _, issues = probe_dart_content("no_expect_test.dart", no_expect)
    check(not valid, "Rejects Dart test with zero expect() calls")

    # 1.8 Dummy shortcut: expect(true, isTrue)
    dummy_expect = """
    import 'package:flutter_test/flutter_test.dart';
    void main() {
      test('dummy test', () {
        expect(true, isTrue);
      });
    }
    """
    valid, _, issues = probe_dart_content("dummy_expect_test.dart", dummy_expect)
    check(not valid, "Rejects dummy cheat assertion: expect(true, isTrue)")

    # 1.9 Unbalanced bracket / syntax corruption
    syntax_error = """
    import 'package:flutter_test/flutter_test.dart';
    void main() {
      test('syntax error', () {
        expect(1 + 1, equals(2));
      // Missing closing braces
    """
    valid, _, issues = probe_dart_content("syntax_error_test.dart", syntax_error)
    check(not valid, "Rejects Dart test with unbalanced bracket hierarchy")

    # 1.10 Mismatched brackets
    mismatched_brackets = """
    import 'package:flutter_test/flutter_test.dart';
    void main() {
      test('mismatch', () {
        expect(1 + 1, equals(2));
      ]);
    }
    """
    valid, _, issues = probe_dart_content("mismatched_test.dart", mismatched_brackets)
    check(not valid, "Rejects Dart test with mismatched bracket hierarchy ']' instead of '}'")

    # 1.11 Valid Dart test
    valid_content = """
    import 'package:flutter_test/flutter_test.dart';
    void main() {
      group('ValidGroup', () {
        test('valid assertion', () {
          expect(2 + 2, equals(4));
        });
      });
    }
    """
    valid, count, issues = probe_dart_content("valid_test.dart", valid_content)
    check(valid, "Accepts structurally and syntactically valid Dart test", str(issues))
    check(count > 0, f"Reports positive check count ({count} checks)")


# =============================================================================
# 2. PYTHON SUITE SUBPROCESS HARNESS PROBE
# =============================================================================
print("\n>>> 2. Python Suite Subprocess Harness Probing")

# 2.1 Non-existent python script
res = run_python_suite("test/non_existent_script.py", "Test Category")
check(not res.passed, "Rejects non-existent Python script")
check("Script not found" in res.error_msg, "Reports 'Script not found' in error_msg")

with tempfile.TemporaryDirectory(dir=PROJECT_ROOT) as temp_dir:
    rel_temp_dir = os.path.relpath(temp_dir, PROJECT_ROOT)

    # 2.2 Script that exits with 1
    fail_script = os.path.join(temp_dir, "failing_script.py")
    with open(fail_script, "w", encoding="utf-8") as f:
        f.write("import sys\nprint('Simulated failure!')\nsys.exit(1)\n")
    res = run_python_suite(os.path.join(rel_temp_dir, "failing_script.py"), "Test Category")
    check(not res.passed, "Detects non-zero exit code (1) from Python test")
    check("Simulated failure!" in res.output, "Captures stdout/stderr from failed script")

    # 2.3 Script that raises unhandled exception
    crash_script = os.path.join(temp_dir, "crash_script.py")
    with open(crash_script, "w", encoding="utf-8") as f:
        f.write("raise RuntimeError('Fatal test crash!')\n")
    res = run_python_suite(os.path.join(rel_temp_dir, "crash_script.py"), "Test Category")
    check(not res.passed, "Detects unhandled exception from Python test")
    check("Fatal test crash!" in res.output, "Captures stack trace from crashing script")

    # 2.4 Script that passes with exit code 0
    pass_script = os.path.join(temp_dir, "passing_script.py")
    with open(pass_script, "w", encoding="utf-8") as f:
        f.write("import sys\nprint('TOTAL TESTS: 10 | PASSED: 10 | FAILED: 0')\nsys.exit(0)\n")
    res = run_python_suite(os.path.join(rel_temp_dir, "passing_script.py"), "Test Category")
    check(res.passed, "Accepts successful Python test with exit code 0", res.error_msg)
    check(res.passed_checks == 10 and res.total_checks == 10, f"Accurately parses check metrics: {res.passed_checks}/{res.total_checks}")

    # 2.5 Script that times out
    timeout_script = os.path.join(temp_dir, "timeout_script.py")
    with open(timeout_script, "w", encoding="utf-8") as f:
        f.write("import time\ntime.sleep(5)\n")
    res = run_python_suite(os.path.join(rel_temp_dir, "timeout_script.py"), "Test Category", timeout=1)
    check(not res.passed, "Detects timeout in child test process")
    check("timed out" in res.error_msg.lower(), f"Reports timeout error message ({res.error_msg})")


# =============================================================================
# 3. DYNAMIC END-TO-END SYNTHETIC FAILURE INJECTION INTO MASTER RUNNER
# =============================================================================
print("\n>>> 3. Dynamic End-to-End Synthetic Failure Injection into Master Runner")

runner_path = os.path.join(PROJECT_ROOT, "test/run_all_e2e_tests.py")

# Test 3.1: Python Suite Failure Propagation
# Temporarily inject exit(1) into verify_m1.py
m1_script = os.path.join(PROJECT_ROOT, "verify_m1.py")
m1_backup = m1_script + ".challenger_bak"
try:
    shutil.copy2(m1_script, m1_backup)
    with open(m1_script, "r", encoding="utf-8") as f:
        m1_code = f.read()
    # Inject deliberate failure at top
    with open(m1_script, "w", encoding="utf-8") as f:
        f.write("import sys\nprint('SYNTHETIC_CHALLENGER_FAILURE')\nsys.exit(1)\n" + m1_code)

    proc = subprocess.run([sys.executable, runner_path], cwd=PROJECT_ROOT, capture_output=True, text=True)
    check(proc.returncode != 0, f"Master runner exits with non-zero code on Python suite failure (got {proc.returncode})")
    check("E2E AUDIT DEFECTS DETECTED" in proc.stdout, "Master runner reports 'E2E AUDIT DEFECTS DETECTED'")
    check("verify_m1.py" in proc.stdout, "Master runner names 'verify_m1.py' in defect summary")
finally:
    if os.path.exists(m1_backup):
        shutil.move(m1_backup, m1_script)

# Test 3.2: Dart Test Syntax Corruption Propagation
# Temporarily inject syntax error into test/privacy/privacy_manifest_test.dart
dart_test = os.path.join(PROJECT_ROOT, "test/privacy/privacy_manifest_test.dart")
dart_backup = dart_test + ".challenger_bak"
try:
    shutil.copy2(dart_test, dart_backup)
    with open(dart_test, "a", encoding="utf-8") as f:
        f.write("\n// UNCLOSED BRACKET SYNTHETIC CORRUPTION\nvoid broken() { ((\n")

    proc = subprocess.run([sys.executable, runner_path], cwd=PROJECT_ROOT, capture_output=True, text=True)
    check(proc.returncode != 0, f"Master runner exits with non-zero code on Dart syntax corruption (got {proc.returncode})")
    check("E2E AUDIT DEFECTS DETECTED" in proc.stdout, "Master runner flags Dart syntax error as defect")
    check("privacy_manifest_test.dart" in proc.stdout, "Master runner pinpoints corrupted Dart test file")
finally:
    if os.path.exists(dart_backup):
        shutil.move(dart_backup, dart_test)

# Test 3.3: Missing Test File Propagation
# Temporarily rename test/core/theme_test.dart
theme_test = os.path.join(PROJECT_ROOT, "test/core/theme_test.dart")
theme_temp_name = os.path.join(PROJECT_ROOT, "test/core/theme_test_hidden.dart")
try:
    shutil.move(theme_test, theme_temp_name)
    proc = subprocess.run([sys.executable, runner_path], cwd=PROJECT_ROOT, capture_output=True, text=True)
    check(proc.returncode != 0, f"Master runner exits with non-zero code when a test file is missing (got {proc.returncode})")
    check("File not found" in proc.stdout, "Master runner reports 'File not found'")
finally:
    if os.path.exists(theme_temp_name):
        shutil.move(theme_temp_name, theme_test)


# =============================================================================
# 4. BASELINE RECOVERY & VERIFICATION
# =============================================================================
print("\n>>> 4. Baseline Recovery Verification (Zero Side-Effects)")
proc_final = subprocess.run([sys.executable, runner_path], cwd=PROJECT_ROOT, capture_output=True, text=True)
check(proc_final.returncode == 0, "Master runner exits with code 0 after restoring all test files")
check("100% OF ALL CHECKS PASSED" in proc_final.stdout, "Master runner confirms 100% PASS on pristine repo")

print("\n" + "=" * 75)
print("PROBE RESULTS SUMMARY")
print("=" * 75)
print(f"Total Checks Evaluated : {checks_total}")
print(f"Passed Checks          : {checks_passed}")
print(f"Failed Checks          : {checks_failed}")
print("=" * 75)

if checks_failed == 0:
    print("MASTER RUNNER RESILIENCE CERTIFIED: ZERO FALSE PASSES, STRICT FAILURE PROPAGATION")
    sys.exit(0)
else:
    print(f"RESILIENCE PROBE FAILED: {checks_failed} checks failed!")
    for f in findings:
        print(f"  ❌ {f}")
    sys.exit(1)
