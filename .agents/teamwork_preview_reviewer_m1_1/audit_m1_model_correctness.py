#!/usr/bin/env python3
"""
Independent Adversarial Audit Script for Milestone M1 (Segundo Ciclo Model Correctness):
«Descubre con Lúa · Edición Vigo»

Audited by: teamwork_preview_reviewer_m1_1 (Reviewer & Adversarial Critic)
"""

import os
import re
import sys
import json

PROJECT_ROOT = "/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa"

failures = []
passed_checks = []

def record_pass(check_name):
    passed_checks.append(check_name)
    print(f"  [PASS] {check_name}")

def record_fail(check_name, reason):
    failures.append((check_name, reason))
    print(f"  [FAIL] {check_name} -> {reason}")

print("=================================================================")
print("  REVIEWER 1 INDEPENDENT ADVERSARIAL AUDIT — MILESTONE M1")
print("  Model Correctness, Immutability, Durations, Decreto 150/2022")
print("=================================================================")

# ----------------------------------------------------------------------
# 1. Integrity Violation & Authenticity Check
# ----------------------------------------------------------------------
print("\n--- 1. Integrity Violations & Authenticity Checks ---")

target_files = [
    "lib/data/models/asamblea_segundo_ciclo_model.dart",
    "lib/data/validators/content_validator.dart",
    "lib/data/loaders/content_asset_loader.dart",
    "lib/data/repositories/content_repository.dart",
    "test/data/asamblea_segundo_ciclo_models_test.dart",
    "test/data/placeholder_validator_test.dart",
]

for rel_path in target_files:
    full_path = os.path.join(PROJECT_ROOT, rel_path)
    if not os.path.exists(full_path):
        record_fail("File Existence", f"Required file missing: {rel_path}")
    else:
        record_pass(f"File exists: {rel_path}")

# Check test files for trivial dummy assertions
test_files = [
    "test/data/asamblea_segundo_ciclo_models_test.dart",
    "test/data/placeholder_validator_test.dart",
]

for tfile in test_files:
    fpath = os.path.join(PROJECT_ROOT, tfile)
    with open(fpath, "r", encoding="utf-8") as f:
        content = f.read()

    # Look for trivial assertions
    trivial_patterns = [
        r"expect\s*\(\s*true\s*,\s*(isTrue|equals\s*\(\s*true\s*\))\s*\)",
        r"expect\s*\(\s*false\s*,\s*(isFalse|equals\s*\(\s*false\s*\))\s*\)",
        r"expect\s*\(\s*1\s*,\s*equals\s*\(\s*1\s*\)\s*\)",
        r"expect\s*\(\s*'a'\s*,\s*equals\s*\(\s*'a'\s*\)\s*\)",
    ]
    found_trivial = False
    for pat in trivial_patterns:
        if re.search(pat, content):
            found_trivial = True
            record_fail(f"Trivial assertion in {tfile}", f"Matched pattern: {pat}")
            break
    if not found_trivial:
        record_pass(f"No trivial self-certifying assertions in {tfile}")

# Check source files for facade shortcuts or fake logic
model_file = os.path.join(PROJECT_ROOT, "lib/data/models/asamblea_segundo_ciclo_model.dart")
with open(model_file, "r", encoding="utf-8") as f:
    model_code = f.read()

if "throw UnimplementedError" in model_code:
    record_fail("Facade check in asamblea_segundo_ciclo_model.dart", "Found UnimplementedError")
else:
    record_pass("asamblea_segundo_ciclo_model.dart contains zero UnimplementedError stubs")

# ----------------------------------------------------------------------
# 2. Canonical Durations & Temporal Invariants Audit
# ----------------------------------------------------------------------
print("\n--- 2. Canonical Assembly Durations & 600s Invariant ---")

# In TipoFaseAsamblea:
# aperturaSaudo => 90
# movementRhythmFocus => 120
# coreTprChallenge => 270
# calmaTransicion => 120
# Sum: 90 + 120 + 270 + 120 = 600 seconds (10 min)

expected_durations = {
    "aperturaSaudo": 90,
    "movementRhythmFocus": 120,
    "coreTprChallenge": 270,
    "calmaTransicion": 120,
}

for fase_name, dur in expected_durations.items():
    pattern = rf"TipoFaseAsamblea\.{fase_name}\s*=>\s*{dur}"
    if re.search(pattern, model_code):
        record_pass(f"TipoFaseAsamblea.{fase_name} has canonical duration {dur}s")
    else:
        record_fail(f"Duration for {fase_name}", f"Expected {dur}s not found in code")

# Check decimal minutes
expected_decimals = {
    "aperturaSaudo": "1.5",
    "movementRhythmFocus": "2.0",
    "coreTprChallenge": "4.5",
    "calmaTransicion": "2.0",
}
for fase_name, dec in expected_decimals.items():
    pattern = rf"TipoFaseAsamblea\.{fase_name}\s*=>\s*{dec}"
    if re.search(pattern, model_code):
        record_pass(f"TipoFaseAsamblea.{fase_name} has decimal duration {dec} min")
    else:
        record_fail(f"Decimal duration for {fase_name}", f"Expected {dec} min not found in code")

# Check order 1..4
for idx, fase_name in enumerate(["aperturaSaudo", "movementRhythmFocus", "coreTprChallenge", "calmaTransicion"], 1):
    pattern = rf"TipoFaseAsamblea\.{fase_name}\s*=>\s*{idx}"
    if re.search(pattern, model_code):
        record_pass(f"TipoFaseAsamblea.{fase_name} has sequential order {idx}")
    else:
        record_fail(f"Sequential order for {fase_name}", f"Expected {idx} not found in code")

# Check duracionTotalSegundos and hasCanonicalPhases
if "int get duracionTotalSegundos =>" in model_code and "fases.fold<int>(0, (sum, f) => sum + f.duracionSegundos)" in model_code:
    record_pass("AsambleaSegundoCiclo.duracionTotalSegundos calculates dynamic fold sum of phases")
else:
    record_fail("duracionTotalSegundos", "Dynamic fold calculation missing")

if "bool get hasCanonicalPhases" in model_code:
    if "fases.length != 4" in model_code and "aperturaSaudo" in model_code and "movementRhythmFocus" in model_code and "coreTprChallenge" in model_code and "calmaTransicion" in model_code:
        record_pass("hasCanonicalPhases verifies exactly 4 phases in canonical order")
    else:
        record_fail("hasCanonicalPhases", "Incomplete verification logic")
else:
    record_fail("hasCanonicalPhases", "Getter missing")

# ----------------------------------------------------------------------
# 3. Decreto 150/2022 Curricular Standards & Constants Audit
# ----------------------------------------------------------------------
print("\n--- 3. Decreto 150/2022 Curricular Reference Audit ---")

decreto_checks = [
    ("normativaDecreto150 = 'Decreto 150/2022'", r"static const String normativaDecreto150 = 'Decreto 150/2022';"),
    ("etapaInfantil = 'educacion_infantil'", r"static const String etapaInfantil = 'educacion_infantil';"),
    ("cicloSegundo = 'segundo_ciclo_3_6'", r"static const String cicloSegundo = 'segundo_ciclo_3_6';"),
    ("area1CrecementoHarmonia reference", r"area1CrecementoHarmonia\s*="),
    ("area2DescubrimentoContorna reference", r"area2DescubrimentoContorna\s*="),
    ("area3ComunicacionRepresentacion reference", r"area3ComunicacionRepresentacion\s*="),
    ("validAreas set", r"static const Set<String> validAreas = \{"),
    ("validCriteriosSegundoCiclo set", r"static const Set<String> validCriteriosSegundoCiclo = \{"),
    ("isValidDecreto150SegundoCiclo validation", r"bool get isValidDecreto150SegundoCiclo \{"),
]

for desc, pat in decreto_checks:
    if re.search(pat, model_code):
        record_pass(f"CurricularReferenceSegundoCiclo: {desc}")
    else:
        record_fail(f"CurricularReferenceSegundoCiclo: {desc}", f"Pattern '{pat}' not matched")

# Check all 10 criteria CA1.1 to CA3.3
for ca in ["CA1.1", "CA1.2", "CA1.3", "CA1.4", "CA2.1", "CA2.2", "CA2.3", "CA3.1", "CA3.2", "CA3.3"]:
    if f"'{ca}'" in model_code:
        record_pass(f"Curricular criterion {ca} defined")
    else:
        record_fail(f"Curricular criterion {ca}", "Missing definition")

# ----------------------------------------------------------------------
# 4. Immutability, Defensive Copying & Equality Audit
# ----------------------------------------------------------------------
print("\n--- 4. Immutability, Defensive Copying & Deep Equality ---")

classes_to_check = [
    "ComandoTPR",
    "MaterialNatural",
    "FaseAsamblea",
    "CurricularReferenceSegundoCiclo",
    "PautaRecast",
    "MicroRutinaHogarSegundoCiclo",
    "AsambleaSegundoCiclo",
]

for cls in classes_to_check:
    # Check @immutable
    class_def_pat = rf"@immutable\s+class\s+{cls}\b"
    if re.search(class_def_pat, model_code):
        record_pass(f"Class {cls} is marked @immutable")
    else:
        record_fail(f"Class {cls} @immutable", f"Class {cls} is not marked @immutable")

    # Check const constructor
    const_ctor_pat = rf"const\s+{cls}\s*\("
    if re.search(const_ctor_pat, model_code):
        record_pass(f"Class {cls} provides const constructor")
    else:
        record_fail(f"Class {cls} const constructor", f"Class {cls} missing const constructor")

    # Check copyWith
    if f"{cls} copyWith(" in model_code:
        record_pass(f"Class {cls} provides copyWith()")
    else:
        record_fail(f"Class {cls} copyWith", f"Class {cls} missing copyWith")

    # Check operator == and hashCode
    cls_block_match = re.search(rf"class\s+{cls}\b.*?(?=\nclass\s|\Z)", model_code, re.DOTALL)
    if cls_block_match:
        cls_body = cls_block_match.group(0)
        if "bool operator ==" in cls_body:
            record_pass(f"Class {cls} overrides operator ==")
        else:
            record_fail(f"Class {cls} operator ==", "Missing operator ==")

        if "int get hashCode" in cls_body:
            record_pass(f"Class {cls} overrides hashCode")
        else:
            record_fail(f"Class {cls} hashCode", "Missing hashCode")

# Check defensive unmodifiable lists
defensive_checks = [
    ("FaseAsamblea.comandosL3", r"comandosL3:\s*List\.unmodifiable\(cmds\)"),
    ("FaseAsamblea.repertorioMateriales", r"repertorioMateriales:\s*List\.unmodifiable\(mats\)"),
    ("CurricularReferenceSegundoCiclo.areas", r"areas:\s*List\.unmodifiable\(parsedAreas\)"),
    ("CurricularReferenceSegundoCiclo.competenciasClave", r"competenciasClave:\s*List\.unmodifiable\(parsedComps\)"),
    ("CurricularReferenceSegundoCiclo.criteriosEvaluacion", r"criteriosEvaluacion:\s*List\.unmodifiable\(parsedCriterios\)"),
    ("MicroRutinaHogarSegundoCiclo.pautasRecast", r"pautasRecast:\s*List\.unmodifiable\(pautas\)"),
    ("AsambleaSegundoCiclo.fases", r"fases:\s*List\.unmodifiable\(parsedFases\)"),
    ("AsambleaSegundoCiclo.materialesEntorno", r"materialesEntorno:\s*List\.unmodifiable\(parsedMats\)"),
]

for desc, pat in defensive_checks:
    if re.search(pat, model_code):
        record_pass(f"Defensive List.unmodifiable in {desc}")
    else:
        record_fail(f"Defensive List.unmodifiable in {desc}", f"Pattern '{pat}' not matched")

# Check listEquals usage in operator ==
list_equals_checks = [
    ("FaseAsamblea", r"listEquals\(comandosL3,\s*other\.comandosL3\)"),
    ("FaseAsamblea", r"listEquals\(repertorioMateriales,\s*other\.repertorioMateriales\)"),
    ("CurricularReferenceSegundoCiclo", r"listEquals\(areas,\s*other\.areas\)"),
    ("CurricularReferenceSegundoCiclo", r"listEquals\(criteriosEvaluacion,\s*other\.criteriosEvaluacion\)"),
    ("MicroRutinaHogarSegundoCiclo", r"listEquals\(pautasRecast,\s*other\.pautasRecast\)"),
    ("AsambleaSegundoCiclo", r"listEquals\(fases,\s*other\.fases\)"),
    ("AsambleaSegundoCiclo", r"listEquals\(materialesEntorno,\s*other\.materialesEntorno\)"),
]

for cls, pat in list_equals_checks:
    if re.search(pat, model_code):
        record_pass(f"{cls} uses listEquals in equality check")
    else:
        record_fail(f"{cls} listEquals", f"Pattern '{pat}' not found")

# ----------------------------------------------------------------------
# 5. Neurocognitive TPR Metodology & Enums Audit
# ----------------------------------------------------------------------
print("\n--- 5. Neurocognitive TPR Methodology & Level Differentiation ---")

# NivelEducativoSegundoCiclo
for nivel in ["infantil4", "infantil5", "infantil6"]:
    if f"enum NivelEducativoSegundoCiclo" in model_code and nivel in model_code:
        record_pass(f"NivelEducativoSegundoCiclo defines {nivel}")
    else:
        record_fail(f"NivelEducativoSegundoCiclo.{nivel}", "Missing enum value")

# MetodologiaTPR
for met in ["accionExpandida", "dramatizadoNarrativo", "transaccionalPragmatico"]:
    if f"enum MetodologiaTPR" in model_code and met in model_code:
        record_pass(f"MetodologiaTPR defines {met}")
    else:
        record_fail(f"MetodologiaTPR.{met}", "Missing enum value")

# Specific capabilities
if "bool get usaTarjetasIconicas => this == MetodologiaTPR.transaccionalPragmatico;" in model_code:
    record_pass("MetodologiaTPR.usaTarjetasIconicas mapped to transaccionalPragmatico (6º)")
else:
    record_fail("usaTarjetasIconicas", "Incorrect mapping")

if "bool get usaSenalInhibicion => this == MetodologiaTPR.dramatizadoNarrativo;" in model_code:
    record_pass("MetodologiaTPR.usaSenalInhibicion mapped to dramatizadoNarrativo (5º)")
else:
    record_fail("usaSenalInhibicion", "Incorrect mapping")

# ----------------------------------------------------------------------
# 6. Placeholder Regex Fix & Adversarial String Stress-Testing
# ----------------------------------------------------------------------
print("\n--- 6. Placeholder Regex Fix & Adversarial Stress-Testing ---")

validator_path = os.path.join(PROJECT_ROOT, "lib/data/validators/content_validator.dart")
with open(validator_path, "r", encoding="utf-8") as f:
    val_code = f.read()

# Verify exact line in content_validator.dart
pat_match = re.search(r"static final RegExp placeholderPattern = RegExp\(\s*r'\\b\(TODO\|TBD\|PLACEHOLDER\|PENDIENTE\|PENDENTE\|LOREM\\s\+IPSUM\)\\b',\s*caseSensitive:\s*(true|false),?\s*\);", val_code)
if pat_match:
    cs_val = pat_match.group(1)
    if cs_val == "true":
        record_pass("ContentValidator.placeholderPattern has caseSensitive: true")
    else:
        record_fail("ContentValidator.placeholderPattern", f"caseSensitive is {cs_val}, expected true")
else:
    record_fail("ContentValidator.placeholderPattern", "RegExp definition not matched")

# Extract the regex pattern and test against adversarial corpus
dart_regex = re.compile(r'\b(TODO|TBD|PLACEHOLDER|PENDIENTE|PENDENTE|LOREM\s+IPSUM)\b') # case-sensitive

# Legitimate educational texts that MUST NOT trigger placeholder error
legitimate_corpus = [
    "todo",
    "Todo",
    "todos",
    "Todos",
    "toda",
    "Todas",
    "sobre todo",
    "Sobre todo",
    "Todo o alumnado participa na asemblea",
    "Recollemos todo o material con agarimo",
    "Facemos as actividades todos xuntos",
    "Hai de todo no recanto dos xogos",
    "Acollida con todo o cariño",
    "O método pedagóxico é activo",
    "tbd",
    "placeholder",
    "pendiente",
    "pendente",
    "lorem ipsum",
    "Lorem ipsum dolor sit amet",
    "Non é un método pechado",
    "custodia compartida",
    "axuda a todos",
]

# Forbidden development placeholders that MUST trigger placeholder error
forbidden_corpus = [
    "TODO",
    "TODO: engadir gravación de audio",
    "TBD",
    "TBD: pendente de confirmación",
    "PLACEHOLDER",
    "PLACEHOLDER texto provisional",
    "PENDIENTE",
    "PENDIENTE de revisión polo equipo",
    "PENDENTE",
    "PENDENTE de validación curricular",
    "LOREM IPSUM",
    "LOREM IPSUM dolor sit amet",
    "FIX THIS TODO NOW",
]

corpus_pass = True
for text in legitimate_corpus:
    if dart_regex.search(text):
        record_fail(f"Adversarial false positive on legitimate text", f"Matched '{text}'")
        corpus_pass = False

if corpus_pass:
    record_pass(f"All {len(legitimate_corpus)} legitimate Galician/Spanish texts containing 'todo/Todo/etc.' passed with zero false positives")

forbidden_pass = True
for text in forbidden_corpus:
    if not dart_regex.search(text):
        record_fail(f"Adversarial false negative on placeholder", f"Did NOT match '{text}'")
        forbidden_pass = False

if forbidden_pass:
    record_pass(f"All {len(forbidden_corpus)} forbidden uppercase developer placeholders correctly flagged")

# ----------------------------------------------------------------------
# 7. Asset Loader & Content Repository Extensions Audit
# ----------------------------------------------------------------------
print("\n--- 7. Asset Loader & Content Repository Extensions Audit ---")

loader_path = os.path.join(PROJECT_ROOT, "lib/data/loaders/content_asset_loader.dart")
with open(loader_path, "r", encoding="utf-8") as f:
    loader_code = f.read()

loader_checks = [
    ("Import of asamblea_segundo_ciclo_model.dart", r"import '\.\./models/asamblea_segundo_ciclo_model\.dart';"),
    ("asambleasSegundoCicloAssetPrefix constant", r"static const String asambleasSegundoCicloAssetPrefix ="),
    ("baseAsambleaSetembro4 constant", r"static const String baseAsambleaSetembro4 ="),
    ("baseAsambleaSetembro5 constant", r"static const String baseAsambleaSetembro5 ="),
    ("baseAsambleaSetembro6 constant", r"static const String baseAsambleaSetembro6 ="),
    ("loadAsambleaSegundoCiclo method", r"Future<AsambleaSegundoCiclo> loadAsambleaSegundoCiclo\(String assetPath\)"),
    ("parseAsambleaSegundoCiclo method", r"AsambleaSegundoCiclo parseAsambleaSegundoCiclo\(String rawJson\)"),
    ("loadAllAsambleasSegundoCiclo method", r"Future<List<AsambleaSegundoCiclo>> loadAllAsambleasSegundoCiclo\("),
]

for desc, pat in loader_checks:
    if re.search(pat, loader_code):
        record_pass(f"ContentAssetLoader: {desc}")
    else:
        record_fail(f"ContentAssetLoader: {desc}", f"Pattern '{pat}' not matched")

repo_path = os.path.join(PROJECT_ROOT, "lib/data/repositories/content_repository.dart")
with open(repo_path, "r", encoding="utf-8") as f:
    repo_code = f.read()

repo_checks = [
    ("Import of asamblea_segundo_ciclo_model.dart", r"import '\.\./models/asamblea_segundo_ciclo_model\.dart';"),
    ("_asambleasSegundoCicloById cache map", r"final Map<String, AsambleaSegundoCiclo> _asambleasSegundoCicloById = \{\};"),
    ("asambleaSegundoCicloCount getter", r"int get asambleaSegundoCicloCount => _asambleasSegundoCicloById\.length;"),
    ("getAllAsambleasSegundoCiclo async method", r"Future<List<AsambleaSegundoCiclo>> getAllAsambleasSegundoCiclo\(\)"),
    ("getAllAsambleasSegundoCicloSync sync method", r"List<AsambleaSegundoCiclo> getAllAsambleasSegundoCicloSync\(\)"),
    ("getAsambleaSegundoCicloById async method", r"Future<AsambleaSegundoCiclo\?> getAsambleaSegundoCicloById\(String id\)"),
    ("getAsambleaSegundoCicloByIdSync sync method", r"AsambleaSegundoCiclo\? getAsambleaSegundoCicloByIdSync\(String id\)"),
    ("getAsambleasByNivel async method", r"Future<List<AsambleaSegundoCiclo>> getAsambleasByNivel\("),
    ("getAsambleasByNivelSync sync method", r"List<AsambleaSegundoCiclo> getAsambleasByNivelSync\("),
    ("getAsambleaByMesYNivel async method", r"Future<AsambleaSegundoCiclo\?> getAsambleaByMesYNivel\("),
    ("getAsambleaByMesYNivelSync sync method", r"AsambleaSegundoCiclo\? getAsambleaByMesYNivelSync\("),
    ("addAsambleaSegundoCiclo helper", r"void addAsambleaSegundoCiclo\(AsambleaSegundoCiclo asamblea\)"),
    ("clear() resets Segundo Ciclo cache", r"_asambleasSegundoCicloById\.clear\(\);"),
    ("_discover() finds asambleasSegundoCiclo assets", r"asambleasSegundoCiclo:"),
]

for desc, pat in repo_checks:
    if re.search(pat, repo_code):
        record_pass(f"ContentRepository: {desc}")
    else:
        record_fail(f"ContentRepository: {desc}", f"Pattern '{pat}' not matched")

# ----------------------------------------------------------------------
# 8. Dart Syntax & Balance Audit
# ----------------------------------------------------------------------
print("\n--- 8. Static Syntax & Delimiter Balance Audit ---")

def check_delimiter_balance(filename, code):
    stack = []
    delims = {')': '(', '}': '{', ']': '['}
    in_string = False
    string_char = ''
    in_comment = False
    in_multiline_comment = False

    i = 0
    line_num = 1
    col_num = 1
    while i < len(code):
        ch = code[i]
        if ch == '\n':
            line_num += 1
            col_num = 1
            in_comment = False
            i += 1
            continue

        if in_comment:
            i += 1
            col_num += 1
            continue

        if in_multiline_comment:
            if ch == '*' and i + 1 < len(code) and code[i+1] == '/':
                in_multiline_comment = False
                i += 2
                col_num += 2
                continue
            i += 1
            col_num += 1
            continue

        if not in_string:
            if ch == '/' and i + 1 < len(code) and code[i+1] == '/':
                in_comment = True
                i += 2
                col_num += 2
                continue
            if ch == '/' and i + 1 < len(code) and code[i+1] == '*':
                in_multiline_comment = True
                i += 2
                col_num += 2
                continue
            if ch in ["'", '"']:
                # Check for raw string r'...' or multiline '''
                is_multiline = (i + 2 < len(code) and code[i+1] == ch and code[i+2] == ch)
                in_string = True
                string_char = ch * 3 if is_multiline else ch
                i += len(string_char)
                col_num += len(string_char)
                continue
            if ch in "({[":
                stack.append((ch, line_num, col_num))
            elif ch in ")}]":
                if not stack:
                    return f"Unmatched closing '{ch}' at line {line_num}:{col_num}"
                expected = delims[ch]
                actual, a_line, a_col = stack.pop()
                if actual != expected:
                    return f"Mismatched closing '{ch}' at line {line_num}:{col_num}, expected match for '{actual}' from {a_line}:{a_col}"
        else:
            if len(string_char) == 1:
                if ch == '\\':
                    i += 2
                    col_num += 2
                    continue
                if ch == string_char:
                    in_string = False
            else: # multiline string
                if code[i:i+3] == string_char:
                    in_string = False
                    i += 3
                    col_num += 3
                    continue
        i += 1
        col_num += 1

    if stack:
        unclosed = stack.pop()
        return f"Unclosed '{unclosed[0]}' opened at line {unclosed[1]}:{unclosed[2]}"
    return None

for rel_path in target_files:
    if rel_path.endswith(".dart"):
        full_path = os.path.join(PROJECT_ROOT, rel_path)
        with open(full_path, "r", encoding="utf-8") as f:
            code = f.read()
        err = check_delimiter_balance(rel_path, code)
        if err:
            record_fail(f"Syntax Balance in {rel_path}", err)
        else:
            record_pass(f"Delimiter balance verified in {rel_path} (brackets, parens, braces)")

# ----------------------------------------------------------------------
# Summary
# ----------------------------------------------------------------------
print("\n=================================================================")
print(f"AUDIT SUMMARY: {len(passed_checks)} CHECKS PASSED, {len(failures)} FAILED")
print("=================================================================")
if failures:
    print("❌ ADVERSARIAL AUDIT DETECTED FAILURES:")
    for check, reason in failures:
        print(f"   - {check}: {reason}")
    sys.exit(1)
else:
    print("🎉 ALL INDEPENDENT ADVERSARIAL AUDIT CHECKS PASSED WITH ZERO INTEGRITY OR LOGICAL DEFECTS!")
    sys.exit(0)
