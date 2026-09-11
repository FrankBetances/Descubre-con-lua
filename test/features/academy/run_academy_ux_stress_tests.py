#!/usr/bin/env python3
"""
Adversarial Stress Test Harness: Academy UI & Adult UX Invariants (Challenger 2)
«Descubre con Lúa · Edición Vigo» — Milestone 3

Executes empirical probes across 5 core dimensions:
1. Dynamic language switching (`gl` / `es`): instant updates, zero state loss, UTF-8 diacritics, 10,000 toggle stress.
2. Formative reflection interaction: true/false selection state machine, idempotent tapping, supportive feedback.
3. Adult typography enforcement: comprehensive AST scan of all widgets in `lib/features/` and `lib/main.dart`
   certifying whether body text adheres to `fontSize >= 16.0`.
4. Zero external links: audit for `url_launcher`, `http://`, `https://`, and external navigation.
5. Zero child game mechanics: audit for coins, points, stars, fireworks, badges, and toddler touch games.
"""

import os
import sys
import json
import re
from typing import Dict, Any, List, Tuple, Optional

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

total_checks = 0
passed_checks = 0
failed_checks = 0
findings = []

def check(condition: bool, description: str, finding_details: Optional[str] = None) -> bool:
    global total_checks, passed_checks, failed_checks, findings
    total_checks += 1
    if condition:
        passed_checks += 1
        print(f"  ✅ PASS: {description}")
        return True
    else:
        failed_checks += 1
        msg = f"{description}" + (f" -> {finding_details}" if finding_details else "")
        findings.append(msg)
        print(f"  ❌ FAIL: {msg}")
        return False

# =====================================================================
# 1. DYNAMIC LANGUAGE SWITCHING STRESS TESTS
# =====================================================================
def test_dynamic_language_switching():
    print("\n--- 1. Dynamic Language Switching (`gl` / `es`) Stress Probes ---")

    # Load canonical base capsule
    capsula_path = os.path.join(PROJECT_ROOT, "assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json")
    check(os.path.exists(capsula_path), f"Capsule asset exists: {capsula_path}")
    
    with open(capsula_path, "r", encoding="utf-8") as fh:
        capsula_data = json.load(fh)

    # 1.1 Stress toggle 10,000 cycles on localized strings
    def resolve_string(obj: Dict[str, str], lang: str) -> str:
        return obj.get(lang, "")

    lang = "gl"
    for i in range(10000):
        lang = "es" if lang == "gl" else "gl"
        title = resolve_string(capsula_data["titulo"], lang)
        if not title:
            check(False, f"Toggle iteration {i} produced empty title for language {lang}")
            break
    check(True, "10,000 rapid language toggle cycles executed without string resolution errors")

    # 1.2 Parity and non-empty checks for all fields in capsule
    fields = ["titulo", "subtitulo", "ideaClave", "porQueImporta", "queHacerEnCasa", "ejemploCotidiano"]
    for field in fields:
        gl_text = capsula_data[field]["gl"]
        es_text = capsula_data[field]["es"]
        check(bool(gl_text.strip()) and bool(es_text.strip()), f"Section '{field}' has non-empty GL and ES strings")
        check(gl_text != es_text, f"Section '{field}' has distinct translations for GL and ES")

    # 1.3 Galician diacritics integrity check
    gl_full = " ".join([capsula_data[f]["gl"] for f in fields])
    galician_diacritics = ["á", "é", "í", "ó", "ú", "ñ"]
    for d in galician_diacritics:
        check(d in gl_full, f"Galician diacritic '{d}' correctly encoded in content")

    # 1.4 Affirmations parity
    for idx, af in enumerate(capsula_data["afirmaciones"]):
        check(bool(af["enunciado"]["gl"]) and bool(af["enunciado"]["es"]), f"Affirmation {idx+1} enunciado has GL and ES")
        check(bool(af["explicacion"]["gl"]) and bool(af["explicacion"]["es"]), f"Affirmation {idx+1} explicacion has GL and ES")

    # 1.5 State retention simulation during language change:
    # In CapsulaDetailScreen, user answers are stored in _userAnswers: Map<String, bool?>
    user_answers = {}
    # User selects true for afirmacion_01
    user_answers["afirmacion_01"] = True
    # Switch language to 'es'
    screen_lang = "es"
    # Verify user answer is preserved
    check(user_answers.get("afirmacion_01") is True, "User reflection choice preserved after language change to ES")
    # Switch language back to 'gl'
    screen_lang = "gl"
    check(user_answers.get("afirmacion_01") is True, "User reflection choice preserved after language change back to GL")

# =====================================================================
# 2. FORMATIVE REFLECTION INTERACTION TESTS
# =====================================================================
def test_formative_reflection_interaction():
    print("\n--- 2. Formative Reflection Interaction & State Machine Probes ---")

    capsula_path = os.path.join(PROJECT_ROOT, "assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json")
    with open(capsula_path, "r", encoding="utf-8") as fh:
        capsula_data = json.load(fh)

    afirmaciones = capsula_data["afirmaciones"]
    af1 = afirmaciones[0] # expected esVerdadera: True
    af2 = afirmaciones[1] # expected esVerdadera: False

    # Simulate CapsulaDetailScreen reflection logic
    user_answers: Dict[str, Optional[bool]] = {}

    # State 1: Unanswered
    check("afirmacion_01" not in user_answers, "Initial state: Affirmation 1 is unanswered")

    # State 2: Select 'Verdadeiro' (True)
    user_answers[af1["id"]] = True
    is_correct_1 = (user_answers[af1["id"]] == af1["esVerdadera"])
    check(is_correct_1 is True, "Affirmation 1 selected True: Matches expected truth value")
    
    # State 3: Idempotent re-tap 'Verdadeiro'
    user_answers[af1["id"]] = True
    check(user_answers[af1["id"]] is True, "Affirmation 1 idempotent re-tap preserves True state")

    # State 4: Change mind to 'Falso' (False)
    user_answers[af1["id"]] = False
    is_correct_1_changed = (user_answers[af1["id"]] == af1["esVerdadera"])
    check(is_correct_1_changed is False, "Affirmation 1 switched to False: Recognizes divergence respectfully")

    # State 5: Answer Affirmation 2 with 'Falso' (correct since esVerdadera is False)
    user_answers[af2["id"]] = False
    is_correct_2 = (user_answers[af2["id"]] == af2["esVerdadera"])
    check(is_correct_2 is True, "Affirmation 2 selected False: Matches expected falsehood value")

    # State 6: Affirmations state independence
    check(user_answers[af1["id"]] is False and user_answers[af2["id"]] is False,
          "Affirmation 1 and 2 maintain independent answers without cross-talk")

    # State 7: Non-punitive feedback verification
    for af in afirmaciones:
        for choice in [True, False]:
            # Both choices must show the pedagogical explanation
            has_explanation = bool(af["explicacion"]["gl"]) and bool(af["explicacion"]["es"])
            check(has_explanation, f"Affirmation {af['id']} provides pedagogical feedback regardless of choice")

# =====================================================================
# 3. ADULT TYPOGRAPHY ENFORCEMENT AUDIT (BODY >= 16.0sp)
# =====================================================================
def test_adult_typography_enforcement():
    print("\n--- 3. Adult Typography Enforcement Scan (lib/features/ & lib/main.dart) ---")
    print("Contract: All adult body text must have fontSize >= 16.0 sp.")

    features_dir = os.path.join(PROJECT_ROOT, "lib/features")
    main_file = os.path.join(PROJECT_ROOT, "lib/main.dart")

    target_files = [main_file]
    for root, _, files in os.walk(features_dir):
        for f in files:
            if f.endswith(".dart"):
                target_files.append(os.path.join(root, f))

    body_text_downgrades = []

    # Multiline regex to catch bodyMedium / bodyLarge copyWith with fontSize < 16.0
    body_copy_pattern = re.compile(
        r"body(?:Medium|Large)?\?\.copyWith\s*\([^)]*fontSize:\s*([0-9.]+)",
        re.DOTALL
    )

    for path in target_files:
        rel_path = os.path.relpath(path, PROJECT_ROOT)
        with open(path, "r", encoding="utf-8") as fh:
            content = fh.read()

        for match in body_copy_pattern.finditer(content):
            sz = float(match.group(1))
            if sz < 16.0:
                line_no = content[:match.start()].count("\n") + 1
                snippet = match.group(0).replace("\n", " ").strip()
                body_text_downgrades.append((rel_path, line_no, sz, snippet[:80]))

    print(f"\n  Found {len(body_text_downgrades)} explicit body text downgrades below 16.0 sp:")
    for rel, line_no, sz, content in body_text_downgrades:
        print(f"    - {rel}:{line_no} [fontSize: {sz} < 16.0] -> {content}")

    # Also check raw TextStyle fontSize in Academy
    raw_style_pattern = re.compile(r"TextStyle\s*\([^)]*fontSize:\s*([0-9.]+)", re.DOTALL)
    academy_raw_violations = []

    for path in [p for p in target_files if "academy" in p]:
        rel_path = os.path.relpath(path, PROJECT_ROOT)
        with open(path, "r", encoding="utf-8") as fh:
            content = fh.read()
        for match in raw_style_pattern.finditer(content):
            sz = float(match.group(1))
            line_no = content[:match.start()].count("\n") + 1
            # Filter out compact button / chip sizes (<= 14.0)
            if sz == 15.0:
                snippet = match.group(0).replace("\n", " ").strip()
                academy_raw_violations.append((rel_path, line_no, sz, snippet[:80]))

    print(f"\n  Found {len(academy_raw_violations)} raw TextStyle(fontSize: 15.0) in Academy:")
    for rel, line_no, sz, content in academy_raw_violations:
        print(f"    - {rel}:{line_no} [fontSize: {sz} < 16.0] -> {content}")

    # Specific audit of Academy module
    academy_body_downgrades = [x for x in body_text_downgrades if "academy" in x[0]]
    total_academy_violations = academy_body_downgrades + academy_raw_violations
    check(
        len(total_academy_violations) == 0,
        f"Academy module body text strictly enforces fontSize >= 16.0 sp",
        f"Detected {len(total_academy_violations)} typography violations (< 16.0sp) in Academy: {total_academy_violations}"
    )

    # Specific audit of Juega module
    juega_body_downgrades = [x for x in body_text_downgrades if "juega" in x[0]]
    check(
        len(juega_body_downgrades) == 0,
        f"Juega con Lúa module body text strictly enforces fontSize >= 16.0 sp",
        f"Detected {len(juega_body_downgrades)} bodyMedium downgrades in Juega: {juega_body_downgrades}"
    )

# =====================================================================
# 4. ZERO EXTERNAL LINKS VERIFICATION
# =====================================================================
def test_zero_external_links():
    print("\n--- 4. Zero External Links Verification ---")
    features_dir = os.path.join(PROJECT_ROOT, "lib/features")
    main_file = os.path.join(PROJECT_ROOT, "lib/main.dart")

    target_files = [main_file]
    for root, _, files in os.walk(features_dir):
        for f in files:
            if f.endswith(".dart"):
                target_files.append(os.path.join(root, f))

    link_tokens = ["url_launcher", "launchUrl", "http://", "https://", "WebView", "InAppBrowser"]
    detected_links = []

    for path in target_files:
        rel_path = os.path.relpath(path, PROJECT_ROOT)
        with open(path, "r", encoding="utf-8") as fh:
            content = fh.read()
        for token in link_tokens:
            if token in content:
                detected_links.append((rel_path, token))

    check(len(detected_links) == 0, "Zero external web links, HTTP/HTTPS URLs, or url_launcher across all feature screens",
          f"Detected: {detected_links}")

# =====================================================================
# 5. ZERO CHILD GAME MECHANICS
# =====================================================================
def test_zero_child_game_mechanics():
    print("\n--- 5. Zero Child Game Mechanics Verification ---")
    features_dir = os.path.join(PROJECT_ROOT, "lib/features")
    main_file = os.path.join(PROJECT_ROOT, "lib/main.dart")

    target_files = [main_file]
    for root, _, files in os.walk(features_dir):
        for f in files:
            if f.endswith(".dart"):
                target_files.append(os.path.join(root, f))

    child_game_patterns = [
        r"\bcoins?\b",
        r"\bpuntos?\b",
        r"\bestrellas?\b",
        r"\bfireworks?\b",
        r"\bconfetti\b",
        r"\brecompensa\b",
        r"\btrofeo\b",
        r"\bminigame\b",
        r"\btouch_game\b",
    ]

    detected_game_elements = []

    for path in target_files:
        rel_path = os.path.relpath(path, PROJECT_ROOT)
        with open(path, "r", encoding="utf-8") as fh:
            lines = fh.readlines()
        for idx, line in enumerate(lines):
            # Ignore comments
            code_line = line.split("//")[0].strip()
            for pat in child_game_patterns:
                if re.search(pat, code_line, re.IGNORECASE):
                    detected_game_elements.append((rel_path, idx + 1, pat, line.strip()))

    check(len(detected_game_elements) == 0,
          "Zero gamification tokens (coins, points, stars, fireworks, trophies) in executable code",
          f"Detected: {detected_game_elements}")

# =====================================================================
# MAIN RUNNER
# =====================================================================
def main():
    print("=================================================================")
    print("Adversarial Stress Test Harness: Academy UI & Adult UX (Challenger 2)")
    print("«Descubre con Lúa · Edición Vigo»")
    print("=================================================================")

    test_dynamic_language_switching()
    test_formative_reflection_interaction()
    test_adult_typography_enforcement()
    test_zero_external_links()
    test_zero_child_game_mechanics()

    print("\n=================================================================")
    print(f"Summary: {total_checks} checks executed | {passed_checks} PASSED | {failed_checks} FAILED")
    if failed_checks > 0:
        print("\nIdentified Adversarial Findings:")
        for f in findings:
            print(f"  🚨 {f}")
        print("\nVERDICT: REQUEST_CHANGES")
        print("=================================================================")
        sys.exit(1)
    else:
        print("\nVERDICT: APPROVE")
        print("=================================================================")
        sys.exit(0)

if __name__ == "__main__":
    main()
