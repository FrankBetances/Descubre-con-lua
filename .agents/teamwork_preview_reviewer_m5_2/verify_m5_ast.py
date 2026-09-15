#!/usr/bin/env python3
"""
Independent AST, syntax, and type consistency verifier for Milestone M5 Dart files.
"""

import os
import re
import sys

FILES_TO_CHECK = [
    "lib/features/calendario/widgets/boton_lanzar_sesion.dart",
    "lib/features/calendario/widgets/temporizador_sutil_widget.dart",
    "lib/features/calendario/views/calendario_screen.dart",
    "lib/main.dart",
    "lib/features/juega/views/unidades_list_screen.dart",
    "lib/features/academy/views/bloques_list_screen.dart",
    "test/features/calendario/calendario_test.dart",
]

def check_brackets_and_quotes(filepath):
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    # Simple bracket matching ignoring string literals and comments
    stack = []
    in_single_quote = False
    in_double_quote = False
    in_multiline_comment = False
    in_single_comment = False
    escaped = False

    lines = content.splitlines()
    for line_no, line in enumerate(lines, 1):
        i = 0
        in_single_comment = False
        while i < len(line):
            ch = line[i]
            next_ch = line[i+1] if i + 1 < len(line) else ""

            if in_single_comment:
                break

            if in_multiline_comment:
                if ch == "*" and next_ch == "/":
                    in_multiline_comment = False
                    i += 2
                    continue
                i += 1
                continue

            if not in_single_quote and not in_double_quote:
                if ch == "/" and next_ch == "/":
                    in_single_comment = True
                    break
                if ch == "/" and next_ch == "*":
                    in_multiline_comment = True
                    i += 2
                    continue

            if ch == "\\" and (in_single_quote or in_double_quote):
                escaped = not escaped
                i += 1
                continue

            if ch == "'" and not in_double_quote and not escaped:
                in_single_quote = not in_single_quote
                i += 1
                continue

            if ch == '"' and not in_single_quote and not escaped:
                in_double_quote = not in_double_quote
                i += 1
                continue

            escaped = False

            if not in_single_quote and not in_double_quote:
                if ch in "({[":
                    stack.append((ch, line_no, i + 1))
                elif ch in ")}]":
                    if not stack:
                        return False, f"Unexpected closing '{ch}' at line {line_no}:{i+1}"
                    top, tline, tcol = stack.pop()
                    expected = {"(": ")", "{": "}", "[": "]"}[top]
                    if ch != expected:
                        return False, f"Mismatched bracket: expected '{expected}' for '{top}' from {tline}:{tcol}, but found '{ch}' at {line_no}:{i+1}"
            i += 1

    if stack:
        top, tline, tcol = stack[-1]
        return False, f"Unclosed '{top}' from line {tline}:{tcol}"
    if in_single_quote or in_double_quote:
        return False, "Unclosed string literal"
    if in_multiline_comment:
        return False, "Unclosed multi-line comment"

    return True, "OK"

def check_imports(filepath, root_dir):
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    import_regex = re.compile(r"import\s+['\"]([^'\"]+)['\"];")
    for match in import_regex.finditer(content):
        imp = match.group(1)
        if imp.startswith("package:flutter/") or imp.startswith("package:flutter_test/") or imp.startswith("dart:"):
            continue
        if imp.startswith("package:descubre_con_lua/"):
            rel_path = imp.replace("package:descubre_con_lua/", "lib/")
            abs_path = os.path.join(root_dir, rel_path)
            if not os.path.exists(abs_path):
                return False, f"Broken package import: {imp} -> {abs_path}"
        elif imp.startswith("."):
            base_dir = os.path.dirname(filepath)
            abs_path = os.path.normpath(os.path.join(base_dir, imp))
            if not os.path.exists(abs_path):
                return False, f"Broken relative import: {imp} -> {abs_path}"
    return True, "All imports resolve"

def main():
    root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "../.."))
    print(f"Verifying files from root: {root_dir}")

    all_passed = True
    for rel_path in FILES_TO_CHECK:
        abs_path = os.path.join(root_dir, rel_path)
        if not os.path.exists(abs_path):
            print(f"[FAIL] Missing file: {rel_path}")
            all_passed = False
            continue

        ok_br, msg_br = check_brackets_and_quotes(abs_path)
        if not ok_br:
            print(f"[FAIL] Syntax/brackets error in {rel_path}: {msg_br}")
            all_passed = False
        else:
            print(f"[PASS] Brackets & quotes OK: {rel_path}")

        ok_imp, msg_imp = check_imports(abs_path, root_dir)
        if not ok_imp:
            print(f"[FAIL] Import error in {rel_path}: {msg_imp}")
            all_passed = False
        else:
            print(f"[PASS] Imports resolve OK: {rel_path}")

    if all_passed:
        print("\nALL FILES PASSED SYNTAX AND IMPORT INTEGRITY CHECKS.")
        sys.exit(0)
    else:
        print("\nSOME CHECKS FAILED.")
        sys.exit(1)

if __name__ == "__main__":
    main()
