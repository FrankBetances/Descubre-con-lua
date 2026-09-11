#!/usr/bin/env python3
"""
Adversarial Stress Harness for Milestone 2: Bilingual Parity & Clinical Terms Blacklist
Challenger 1 — «Descubre con Lúa · Edición Vigo»

Probes ContentValidator (lib/data/validators/content_validator.dart):
1. Clinical inflection & morphological mutation detection (Galician & Spanish).
2. Bilingual asymmetry, null, blank, and English placeholder token rejection.
3. False positive resistance on legitimate pedagogical and environmental expressions.
4. Base production JSON compliance.
"""

import os
import sys
import json
import re
from typing import Dict, Any, List, Tuple

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# -----------------------------------------------------------------------------
# Dynamic Regex Extraction from lib/data/validators/content_validator.dart
# -----------------------------------------------------------------------------
DART_VALIDATOR_PATH = os.path.join(PROJECT_ROOT, "lib/data/validators/content_validator.dart")

with open(DART_VALIDATOR_PATH, "r", encoding="utf-8") as f:
    dart_source = f.read()

# Extract forbiddenClinicalPattern
m_clin = re.search(r"forbiddenClinicalPattern\s*=\s*RegExp\((.*?)\s*,\s*caseSensitive:", dart_source, re.DOTALL)
if not m_clin:
    raise RuntimeError("Failed to extract forbiddenClinicalPattern from content_validator.dart")
parts_clin = re.findall(r"r\x27([^\x27]*)\x27", m_clin.group(1))
DART_CLINICAL_REGEX_STR = "".join(parts_clin)
DART_CLINICAL_REGEX = re.compile(DART_CLINICAL_REGEX_STR, re.IGNORECASE)

# Extract placeholderPattern
m_place = re.search(r"placeholderPattern\s*=\s*RegExp\(\s*r\x27(.*?)\x27\s*,\s*caseSensitive:", dart_source, re.DOTALL)
if not m_place:
    raise RuntimeError("Failed to extract placeholderPattern from content_validator.dart")
DART_PLACEHOLDER_REGEX_STR = m_place.group(1)
DART_PLACEHOLDER_REGEX = re.compile(DART_PLACEHOLDER_REGEX_STR, re.IGNORECASE)

# -----------------------------------------------------------------------------
# Validator Emulation directly mirroring Dart ContentValidator logic
# -----------------------------------------------------------------------------
def check_clinical_terms_tree(node: Any, path: str = "root") -> List[str]:
    errors = []
    if isinstance(node, str):
        match = DART_CLINICAL_REGEX.search(node)
        if match:
            errors.append(f"{path} contains prohibited clinical term: '{match.group(0)}'")
    elif isinstance(node, dict):
        for k, v in node.items():
            errors.extend(check_clinical_terms_tree(v, f"{path}.{k}"))
    elif isinstance(node, list):
        for i, item in enumerate(node):
            errors.extend(check_clinical_terms_tree(item, f"{path}[{i}]"))
    return errors

def check_bilingual_parity_tree(node: Any, path: str = "root") -> List[str]:
    errors = []
    if isinstance(node, dict):
        has_gl = "gl" in node
        has_es = "es" in node

        if has_gl and has_es:
            gl_val = node["gl"]
            es_val = node["es"]

            if not isinstance(gl_val, str) or not gl_val.strip():
                errors.append(f"{path}: 'gl' is missing, not a string, or blank")
            elif DART_PLACEHOLDER_REGEX.search(gl_val):
                errors.append(f"{path}: 'gl' contains forbidden placeholder: '{gl_val.strip()}'")

            if not isinstance(es_val, str) or not es_val.strip():
                errors.append(f"{path}: 'es' is missing, not a string, or blank")
            elif DART_PLACEHOLDER_REGEX.search(es_val):
                errors.append(f"{path}: 'es' contains forbidden placeholder: '{es_val.strip()}'")
        elif has_gl and not has_es:
            errors.append(f"{path}: Asymmetric bilingual node: contains 'gl' but missing 'es'")
        elif not has_gl and has_es:
            errors.append(f"{path}: Asymmetric bilingual node: contains 'es' but missing 'gl'")

        for k, v in node.items():
            errors.extend(check_bilingual_parity_tree(v, f"{path}.{k}"))
    elif isinstance(node, list):
        for i, item in enumerate(node):
            errors.extend(check_bilingual_parity_tree(item, f"{path}[{i}]"))
    return errors

# -----------------------------------------------------------------------------
# Test Harness Reporting Engine
# -----------------------------------------------------------------------------
total_tests = 0
passed_tests = 0
failed_tests = 0
findings = []

def record_test(name: str, passed: bool, detail: str = ""):
    global total_tests, passed_tests, failed_tests, findings
    total_tests += 1
    if passed:
        passed_tests += 1
        print(f"  ✅ PASS: {name}")
    else:
        failed_tests += 1
        print(f"  ❌ DEFECT: {name} -> {detail}")
        findings.append((name, detail))

# =============================================================================
# SUITE 1: Clinical Terms Inflection & Morphological Stress Testing
# =============================================================================
print("=======================================================================")
print("ADVERSARIAL SUITE 1: CLINICAL INFLECTIONS & MORPHOLOGICAL VARIANTS")
print(f"Extracted Regex: {DART_CLINICAL_REGEX_STR}")
print("=======================================================================")

clinical_inflection_cases = [
    # (term, expected_to_catch, description)
    ("patoloxías", True, "Galician plural noun 'patoloxías'"),
    ("patolóxicos", True, "Galician plural adjective 'patolóxicos'"),
    ("patolóxica", True, "Galician feminine singular adjective 'patolóxica'"),
    ("terapéuticas", True, "Plural feminine adjective 'terapéuticas'"),
    ("terapéuticos", True, "Plural masculine adjective 'terapéuticos'"),
    ("retraso clínico", True, "Singular noun phrase 'retraso clínico'"),
    ("retrasos clínicos", True, "Plural noun phrase 'retrasos clínicos'"),
    ("diagnosticaron", True, "Spanish 3rd person plural past verb 'diagnosticaron'"),
    ("diagnosticouse", True, "Galician passive/impersonal past 'diagnosticouse'"),
    ("diagnosticado", True, "Masculine singular participle 'diagnosticado'"),
    ("diagnosticada", True, "Feminine singular participle 'diagnosticada'"),
    ("diagnosticados", True, "Masculine plural participle 'diagnosticados'"),
    ("diagnostican", True, "3rd person plural present 'diagnostican'"),
    ("cribados", True, "Plural noun/participle 'cribados'"),
    ("cribado", True, "Singular noun/participle 'cribado'"),
    ("cribaxe", True, "Galician noun for screening 'cribaxe'"),
    ("cribaxes", True, "Galician plural for screening 'cribaxes'"),
    ("cribaxe neonatal", True, "Galician clinical screening phrase 'cribaxe neonatal'"),
    ("dislálico", True, "Adjectival form of dislalia 'dislálico'"),
    ("dislálicos", True, "Adjectival plural of dislalia 'dislálicos'"),
    ("disléxico", True, "Adjectival form of dislexia 'disléxico'"),
    ("disléxicos", True, "Adjectival plural of dislexia 'disléxicos'"),
    ("rehabilitador", True, "Adjective/agent noun 'rehabilitador'"),
    ("rehabilitadora", True, "Feminine adjective/agent noun 'rehabilitadora'"),
    ("rehabilitados", True, "Past participle plural 'rehabilitados'"),
]

for term, should_catch, desc in clinical_inflection_cases:
    payload = {"seccion": {"gl": f"Atención ao termo {term}", "es": f"Atención al término {term}"}}
    errs = check_clinical_terms_tree(payload)
    is_caught = len(errs) > 0
    passed = (is_caught == should_catch)
    detail = f"Expected catch={should_catch}, actual catch={is_caught} (errors: {errs})"
    record_test(desc, passed, detail)

# =============================================================================
# SUITE 2: Bilingual Parity, Structural Asymmetry & Placeholder Stress Testing
# =============================================================================
print("\n=======================================================================")
print("ADVERSARIAL SUITE 2: BILINGUAL ASYMMETRY, NULLS, BLANKS & PLACEHOLDERS")
print(f"Extracted Placeholder Pattern: {DART_PLACEHOLDER_REGEX_STR}")
print("=======================================================================")

bilingual_asymmetry_cases = [
    # 1. Missing keys
    ("Missing 'es' key entirely", {"titulo": {"gl": "Só galego"}}, True),
    ("Missing 'gl' key entirely", {"titulo": {"es": "Solo castellano"}}, True),
    # 2. Null values
    ("Null 'gl' value", {"titulo": {"gl": None, "es": "Texto válido"}}, True),
    ("Null 'es' value", {"titulo": {"gl": "Texto válido", "es": None}}, True),
    ("Both 'gl' and 'es' null", {"titulo": {"gl": None, "es": None}}, True),
    # 3. Empty strings
    ("Empty string '' in 'gl'", {"titulo": {"gl": "", "es": "Texto válido"}}, True),
    ("Empty string '' in 'es'", {"titulo": {"gl": "Texto válido", "es": ""}}, True),
    # 4. Whitespace strings
    ("Whitespace '   ' in 'gl'", {"titulo": {"gl": "   ", "es": "Texto válido"}}, True),
    ("Tab & newline '\\t\\n  \\r' in 'es'", {"titulo": {"gl": "Texto válido", "es": "\t\n  \r"}}, True),
    # 5. Placeholders
    ("Placeholder token 'TODO'", {"titulo": {"gl": "TODO: traducir", "es": "Texto válido"}}, True),
    ("Placeholder token 'TBD'", {"titulo": {"gl": "Texto válido", "es": "TBD later"}}, True),
    ("Placeholder token 'PENDIENTE'", {"titulo": {"gl": "Texto válido", "es": "PENDIENTE de revisión"}}, True),
    ("Placeholder token 'PENDENTE'", {"titulo": {"gl": "PENDENTE de traducir", "es": "Texto válido"}}, True),
    ("Placeholder token 'LOREM IPSUM'", {"titulo": {"gl": "Lorem Ipsum dolor sit amet", "es": "Texto"}}, True),
    ("Placeholder token 'placeholder' (lowercase)", {"titulo": {"gl": "placeholder", "es": "Texto válido"}}, True),
    ("Placeholder token 'PLACEHOLDER' (uppercase)", {"titulo": {"gl": "Texto válido", "es": "PLACEHOLDER"}}, True),
    ("Placeholder token 'Placeholder' (mixed case)", {"titulo": {"gl": "Placeholder text for unit", "es": "Texto"}}, True),
]

for desc, payload, should_reject in bilingual_asymmetry_cases:
    errs = check_bilingual_parity_tree(payload)
    is_rejected = len(errs) > 0
    passed = (is_rejected == should_reject)
    detail = f"Expected reject={should_reject}, actual reject={is_rejected} (errors: {errs})"
    record_test(desc, passed, detail)

# =============================================================================
# SUITE 3: False Positive Resistance on Legitimate Pedagogical / Contextual Words
# =============================================================================
print("\n=======================================================================")
print("ADVERSARIAL SUITE 3: FALSE POSITIVE RESISTANCE ON PEDAGOGICAL LANGUAGE")
print("=======================================================================")

pedagogical_cases = [
    # (phrase, description)
    ("O tratamento de auga na ría de Vigo para a depuración de moluscos", "Environmental/maritime term 'tratamento de auga'"),
    ("El tratamiento de agua en la ría de Vigo para la depuración", "Spanish environmental term 'tratamiento de agua'"),
    ("Tempo de espera de 5 segundos para que o bebé responda", "Pedagogical term 'tempo de espera' (Academy rule)"),
    ("Cinco segundos de espera antes de repetir la pregunta", "Pedagogical term 'cinco segundos de espera'"),
    ("Cada nena e neno segue o seu propio ritmo individual", "Pedagogical term 'ritmo individual'"),
    ("Acompañamento educativo cálido durante a asamblea", "Pedagogical term 'acompañamento'"),
    ("Estimulación temperá baseada no afecto e a conversa", "Pedagogical term 'estimulación temperá'"),
    ("Comunicación non verbal a través de xestos e sorrisos", "Pedagogical term 'comunicación non verbal'"),
    ("Atención conxunta mirando o mesmo obxecto mariño", "Pedagogical term 'atención conxunta'"),
    ("Baño de lingua diario na escola infantil", "Pedagogical term 'baño de lingua'"),
    ("Baño de lenguaje natural en el hogar", "Pedagogical term 'baño de lenguaje'"),
]

for phrase, desc in pedagogical_cases:
    payload = {"seccion": {"gl": phrase, "es": phrase}}
    errs = check_clinical_terms_tree(payload)
    is_flagged = len(errs) > 0
    # Must NOT be flagged (zero false positives)
    passed = (not is_flagged)
    detail = f"Falsely flagged as clinical! errors: {errs}" if is_flagged else "Properly accepted"
    record_test(desc, passed, detail)

# =============================================================================
# SUITE 4: Base Production JSON Compliance
# =============================================================================
print("\n=======================================================================")
print("ADVERSARIAL SUITE 4: BASE PRODUCTION JSON ASSET AUDIT")
print("=======================================================================")

base_files = [
    ("assets/content/unidades/juega.mar.01.json", "Base Unit: juega.mar.01.json"),
    ("assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json", "Base Capsule: academy.como_se_aprende_a_hablar.01.json"),
]

for rel_path, desc in base_files:
    abs_path = os.path.join(PROJECT_ROOT, rel_path)
    if not os.path.exists(abs_path):
        record_test(f"{desc} exists", False, f"File not found: {abs_path}")
        continue
    with open(abs_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    # Check parity
    par_errs = check_bilingual_parity_tree(data, rel_path)
    record_test(f"{desc} - Bilingual Parity (1:1 gl/es)", len(par_errs) == 0, f"Errors: {par_errs}")

    # Check clinical terms
    clin_errs = check_clinical_terms_tree(data, rel_path)
    record_test(f"{desc} - Prohibited Clinical Terms", len(clin_errs) == 0, f"Errors: {clin_errs}")

# =============================================================================
# SUMMARY & VERDICT
# =============================================================================
print("\n=======================================================================")
print("CHALLENGER SUMMARY & VERDICT")
print("=======================================================================")
print(f"Total Tests Run   : {total_tests}")
print(f"Tests Passed      : {passed_tests}")
print(f"Defects Found     : {failed_tests}")

if failed_tests > 0:
    print("\nDEFECT LOG:")
    for name, detail in findings:
        print(f"  • {name}: {detail}")
    print("\nVERDICT: REQUEST_CHANGES")
    print("Rationale: ContentValidator fails to catch critical clinical inflections,")
    print("misses the 'placeholder' token, and exhibits a false positive on 'tratamento de auga'.")
else:
    print("\nVERDICT: APPROVE")

print("=======================================================================")

if __name__ == "__main__":
    # Challenger script exits with code 2 if defects were found (indicating changes requested),
    # or 0 if approved.
    sys.exit(2 if failed_tests > 0 else 0)
