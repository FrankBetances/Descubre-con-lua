#!/usr/bin/env python3
"""
Milestone 3 Independent Reviewer Audit & Adversarial Test Suite
Reviewer 1: M3 Academy UI & Pedagogical Reviewer
Target: lib/features/academy/, test/features/academy/, assets/content/capsulas/
"""

import os
import re
import json
import sys

PROJECT_ROOT = "/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa"

passed = 0
failed = 0
findings = []

def record_check(success, message, finding_details=None):
    global passed, failed
    if success:
        passed += 1
        print(f"  ✅ PASS: {message}")
    else:
        failed += 1
        print(f"  ❌ FAIL: {message}")
        if finding_details:
            findings.append(finding_details)

print("================================================================================")
print("Reviewer 1: Independent Audit of Academy (Familias) Module — Milestone 3")
print("«Descubre con Lúa · Edición Vigo»")
print("================================================================================\n")

# ----------------------------------------------------------------------
# 1. FILE EXISTENCE & CLEAN ARCHITECTURE CHECK
# ----------------------------------------------------------------------
print("--- 1. File Structure & Clean Architecture ---")

files_to_check = {
    "bloques_view": "lib/features/academy/views/bloques_list_screen.dart",
    "capsula_view": "lib/features/academy/views/capsula_detail_screen.dart",
    "seccion_widget": "lib/features/academy/widgets/seccion_capsula_widget.dart",
    "selector_widget": "lib/features/academy/widgets/selector_idioma_widget.dart",
    "academy_test": "test/features/academy/academy_flow_test.dart",
    "base_capsula_json": "assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json",
    "capsula_model": "lib/data/models/capsula_model.dart",
    "content_repo": "lib/data/repositories/content_repository.dart",
}

file_contents = {}
for key, rel_path in files_to_check.items():
    abs_path = os.path.join(PROJECT_ROOT, rel_path)
    exists = os.path.exists(abs_path)
    record_check(exists, f"File exists: {rel_path}")
    if exists:
        with open(abs_path, "r", encoding="utf-8") as f:
            file_contents[key] = f.read()
    else:
        file_contents[key] = ""

# ----------------------------------------------------------------------
# 2. INTEGRITY AUDIT (ZERO HARDFACADE, ZERO FABRICATION, ZERO NETWORK)
# ----------------------------------------------------------------------
print("\n--- 2. Integrity & Non-Bypass Audit ---")

forbidden_network = [
    "http://", "https://", "package:http", "dart:io/HttpClient",
    "WebSocket", "dart:io/Socket", "Firebase", "analytics", "url_launcher"
]

for key, content in file_contents.items():
    if not content:
        continue
    rel_path = files_to_check[key]
    
    # Check for forbidden network imports/tokens
    net_found = [token for token in forbidden_network if token in content]
    record_check(
        len(net_found) == 0,
        f"{rel_path}: zero network tokens found",
        {"level": "CRITICAL", "type": "INTEGRITY VIOLATION", "file": rel_path, "msg": f"Found network tokens: {net_found}"} if net_found else None
    )

# Check for hardcoded test results / bypass in model & repository
repo_content = file_contents.get("content_repo", "")
record_check(
    "getCapsulasByBloqueId" in repo_content and "where" in repo_content,
    "ContentRepository implements genuine filtering for capsules by block ID"
)
record_check(
    "getAllBloques" in repo_content and "Bloque.todos" in repo_content,
    "ContentRepository returns canonical Bloque.todos list"
)

# ----------------------------------------------------------------------
# 3. ADULT TYPOGRAPHY & ZERO CHILD GAME MECHANICS AUDIT
# ----------------------------------------------------------------------
print("\n--- 3. Strict Adult Design & Typography Audit ---")

seccion_content = file_contents.get("seccion_widget", "")
# Verify body typography >= 16sp in SeccionCapsulaWidget
body_font_match = re.search(r"fontSize:\s*([0-9.]+)", seccion_content)
font_size_val = float(body_font_match.group(1)) if body_font_match else 0.0

record_check(
    font_size_val >= 16.0,
    f"SeccionCapsulaWidget enforces body typography >= 16.0sp (found {font_size_val}sp)",
    {"level": "MAJOR", "type": "TYPOGRAPHY", "file": files_to_check["seccion_widget"], "msg": f"Body font size {font_size_val}sp is less than 16sp"} if font_size_val < 16.0 else None
)

# Check for child game mechanics tokens in academy module (excluding UI badge chips like 'reading time badge')
child_game_tokens = [
    r"\bpoints\b", r"\bpuntos\b", r"\bpuntuacion\b", r"\bcoins\b", r"\bmoedas\b", r"\bmonedas\b",
    r"\binsignia\b", r"\bstreak\b", r"\bracha\b", r"\bgame_over\b", r"\blevel_up\b",
    r"\bconfetti\b", r"\breward\b", r"\brecompensa\b", r"\bstar_rating\b", r"\bestrellas\b",
    r"\bgamif\w*"
]

academy_files = ["bloques_view", "capsula_view", "seccion_widget", "selector_widget"]
for key in academy_files:
    content = file_contents.get(key, "")
    rel_path = files_to_check[key]
    tokens_present = []
    for pattern in child_game_tokens:
        matches = re.findall(pattern, content, re.IGNORECASE)
        if matches:
            tokens_present.extend(matches)
    record_check(
        len(tokens_present) == 0,
        f"{rel_path}: zero child gamification mechanics detected",
        {"level": "CRITICAL", "type": "ADULT_DESIGN_VIOLATION", "file": rel_path, "msg": f"Gamification tokens found: {tokens_present}"} if tokens_present else None
    )

# Check zero external links (no url_launcher, no href, no openUrl)
for key in academy_files:
    content = file_contents.get(key, "")
    rel_path = files_to_check[key]
    has_links = bool(re.search(r"\b(launchUrl|canLaunchUrl|url_launcher|mailto:|tel:)\b", content))
    record_check(
        not has_links,
        f"{rel_path}: zero external web link launchers detected",
        {"level": "CRITICAL", "type": "ADULT_DESIGN_VIOLATION", "file": rel_path, "msg": "External web link launchers detected"} if has_links else None
    )

# ----------------------------------------------------------------------
# 4. PEDAGOGICAL SPECIFICATIONS (5 BLOCKS & 4 SECTIONS)
# ----------------------------------------------------------------------
print("\n--- 4. Pedagogical Specifications Audit ---")

# Verify 5 canonical blocks in capsula_model.dart
model_content = file_contents.get("capsula_model", "")
canonical_blocks = [
    "desarrollo_comunicativo",
    "rutinas_y_bano_de_lenguaje",
    "turnos_y_atencion_conjunta",
    "juego_movimiento_sin_pantallas",
    "bilinguismo_y_cultura"
]

for b_id in canonical_blocks:
    record_check(
        b_id in model_content,
        f"Bloque model defines canonical block: {b_id}"
    )

# Verify 4 canonical sections in SeccionCapsulaWidget & CapsulaDetailScreen
canonical_sections = [
    "ideaClave",
    "porQueImporta",
    "queHacerEnCasa",
    "ejemploCotidiano"
]

for sec in canonical_sections:
    record_check(
        sec in seccion_content,
        f"TipoSeccionCapsula defines: {sec}"
    )

capsula_view_content = file_contents.get("capsula_view", "")
for sec in canonical_sections:
    record_check(
        sec in capsula_view_content,
        f"CapsulaDetailScreen instantiates section: {sec}"
    )

# Verify Formative Reflection (Afirmacion) in CapsulaDetailScreen
record_check(
    "afirmaciones" in capsula_view_content and "esVerdadera" in capsula_view_content,
    "CapsulaDetailScreen implements formative reflection question logic"
)
record_check(
    "Verdadeiro" in capsula_view_content and "Falso" in capsula_view_content,
    "CapsulaDetailScreen provides Verdadeiro/Falso response options"
)
record_check(
    "explicacion" in capsula_view_content,
    "CapsulaDetailScreen displays immediate formative explanation after answering"
)

# ----------------------------------------------------------------------
# 5. DYNAMIC LANGUAGE SWITCHER & BILINGUAL PARITY
# ----------------------------------------------------------------------
print("\n--- 5. Dynamic Language Switcher & Bilingual Support ---")

selector_content = file_contents.get("selector_widget", "")
record_check(
    "AppLanguage.gl" in selector_content and "AppLanguage.es" in selector_content,
    "SelectorIdiomaWidget supports both AppLanguage.gl and AppLanguage.es"
)
record_check(
    "onLanguageChanged" in selector_content,
    "SelectorIdiomaWidget triggers onLanguageChanged callback"
)

bloques_view_content = file_contents.get("bloques_view", "")
record_check(
    "SelectorIdiomaWidget" in bloques_view_content and "_onToggleLanguage" in bloques_view_content,
    "BloquesListScreen embeds SelectorIdiomaWidget with reactive state update"
)
record_check(
    "SelectorIdiomaWidget" in capsula_view_content and "_onToggleLanguage" in capsula_view_content,
    "CapsulaDetailScreen embeds SelectorIdiomaWidget with reactive state update"
)

# Check base capsule JSON bilingual parity
base_json_str = file_contents.get("base_capsula_json", "")
if base_json_str:
    base_json = json.loads(base_json_str)
    
    # Check 4 sections present in base json
    for sec_key in ["ideaClave", "porQueImporta", "queHacerEnCasa", "ejemploCotidiano"]:
        has_sec = sec_key in base_json
        record_check(has_sec, f"Base JSON contains '{sec_key}'")
        if has_sec:
            gl_val = base_json[sec_key].get("gl", "").strip()
            es_val = base_json[sec_key].get("es", "").strip()
            record_check(
                bool(gl_val) and bool(es_val),
                f"Base JSON section '{sec_key}' has non-empty GL and ES parity"
            )
            
    # Check afirmaciones
    afirmaciones = base_json.get("afirmaciones", [])
    record_check(len(afirmaciones) >= 2, f"Base JSON has {len(afirmaciones)} formative reflection affirmations (>=2)")
    for idx, af in enumerate(afirmaciones):
        enunciado = af.get("enunciado", {})
        explicacion = af.get("explicacion", {})
        has_gl_es = bool(enunciado.get("gl")) and bool(enunciado.get("es")) and bool(explicacion.get("gl")) and bool(explicacion.get("es"))
        record_check(has_gl_es, f"Affirmation {idx+1} has complete GL/ES bilingual parity")

# ----------------------------------------------------------------------
# 6. CLINICAL BLACKLIST LINTER AUDIT
# ----------------------------------------------------------------------
print("\n--- 6. Clinical Blacklist Audit Across Academy ---")

clinical_pattern = re.compile(
    r'\b(trastorno|trastornos|patolog[ií]a|patolog[ií]as|patolox[ií]a|patolox[ií]as|patol[oó][gx]ic[oa]s?|'
    r'diagn[oó]stic[oa]s?|diagnostic[a-záéíóúñ]+|s[ií]ntoma|s[ií]ntomas|sintomatolog[ií]a|'
    r'sintomatolox[ií]a|d[eé]ficit|d[eé]ficits|paciente|pacientes|terapia|'
    r'terapias|terap[eé]utic[oa]s?|'
    r'(?!(tratamiento|tratamento)\s+d[eé]\s+a(ug|gu)a)(tratamiento|tratamientos|tratamento|tratamentos)|'
    r'retrasos?\s+cl[ií]nic[oa]s?|dislalia|dislalias|disl[aá]lic[oa]s?|dislexia|dislexias|disl[eé]xic[oa]s?|'
    r'hipoacusia\s+cl[ií]nica|afasia|disfasia|rehabilit[a-záéíóúñ]+|'
    r'criba[sxd]?[a-záéíóúñ]*|screening|pron[oó]stico)\b',
    re.IGNORECASE
)

for key in ["bloques_view", "capsula_view", "seccion_widget", "selector_widget", "base_capsula_json"]:
    content = file_contents.get(key, "")
    rel_path = files_to_check[key]
    matches = clinical_pattern.findall(content)
    record_check(
        len(matches) == 0,
        f"{rel_path}: zero clinical/pathological terms detected",
        {"level": "CRITICAL", "type": "CLINICAL_VIOLATION", "file": rel_path, "msg": f"Found clinical terms: {matches}"} if matches else None
    )

# ----------------------------------------------------------------------
# 7. ADVERSARIAL ANALYSIS OF ACADEMY_FLOW_TEST.DART
# ----------------------------------------------------------------------
print("\n--- 7. Adversarial Test Suite Analysis (academy_flow_test.dart) ---")

test_content = file_contents.get("academy_test", "")
record_check(
    "group('Academy Feature Tests'" in test_content,
    "academy_flow_test.dart defines 'Academy Feature Tests' group"
)

# Check test cases present
record_check(
    "testWidgets('SelectorIdiomaWidget toggles between GL and ES correctly'" in test_content,
    "academy_flow_test.dart contains SelectorIdiomaWidget test"
)
record_check(
    "testWidgets('BloquesListScreen displays all 5 developmental blocks'" in test_content,
    "academy_flow_test.dart contains BloquesListScreen test"
)
record_check(
    "testWidgets('CapsulaDetailScreen displays 4 canonical sections and reflection'" in test_content,
    "academy_flow_test.dart contains CapsulaDetailScreen test"
)

# Detailed simulation of BloquesListScreen widget tree search:
# Look at Bloque 1 title:
# Bloque.todos[0].titulo.gl is 'Como se aprende a falar'
# testCapsula.titulo.gl is 'Como se aprende a falar'
# In BloquesListScreen:
# 1) Bloque title rendered in Text widget: 'Como se aprende a falar'
# 2) testCapsula is added to repository, so getCapsulasByBloqueId returns [testCapsula]
# 3) Capsule title rendered in ListTile Text widget: 'Como se aprende a falar'
# Therefore find.text('Como se aprende a falar') finds TWO widgets!
has_collision_risk = False
if "Como se aprende a falar" in test_content:
    # Check how many times 'Como se aprende a falar' is expected
    # In testCapsula setup:
    # gl: 'Como se aprende a falar'
    # And in assertion:
    # expect(find.text('Como se aprende a falar'), findsOneWidget);
    m = re.search(r"expect\(find\.text\(['\"]Como se aprende a falar['\"]\),\s*findsOneWidget\);", test_content)
    if m:
        has_collision_risk = True

record_check(
    not has_collision_risk,
    "academy_flow_test.dart does not have widget title collision on 'Como se aprende a falar'",
    {
        "level": "MAJOR",
        "type": "TEST_FLAW",
        "file": files_to_check["academy_test"],
        "line": 133,
        "msg": "Collision flaw: In BloquesListScreen, Bloque 1 title is 'Como se aprende a falar' AND testCapsula title is also 'Como se aprende a falar'. When testCapsula is in the repository, both the block header and the capsule list item render a Text widget with 'Como se aprende a falar'. Running flutter test would fail on `expect(find.text('Como se aprende a falar'), findsOneWidget)` because 2 matching widgets exist. Recommended fix: differentiate testCapsula title (e.g. 'Como se aprende a falar: o baño de lingua') or use findsNWidgets(2)."
    } if has_collision_risk else None
)

# Check if screen-level dynamic language switching is tested
tests_screen_toggle = (
    "BloquesListScreen" in test_content and
    re.search(r"testWidgets\(.*BloquesListScreen.*language.*toggle", test_content, re.IGNORECASE) is not None
)
record_check(
    tests_screen_toggle,
    "academy_flow_test.dart tests language toggle directly on BloquesListScreen",
    {
        "level": "MINOR",
        "type": "COVERAGE_GAP",
        "file": files_to_check["academy_test"],
        "msg": "SelectorIdiomaWidget is tested in isolation, but language switching is not tested end-to-end within BloquesListScreen or CapsulaDetailScreen to verify text re-rendering."
    } if not tests_screen_toggle else None
)

# Check if navigation from BloquesListScreen to CapsulaDetailScreen is tested
tests_navigation = "CapsulaDetailScreen" in test_content and "arrow_forward_ios" in test_content
record_check(
    tests_navigation,
    "academy_flow_test.dart tests navigation from BloquesListScreen to CapsulaDetailScreen",
    {
        "level": "MINOR",
        "type": "COVERAGE_GAP",
        "file": files_to_check["academy_test"],
        "msg": "Direct tap-to-navigate flow from BloquesListScreen to CapsulaDetailScreen is not exercised in academy_flow_test.dart."
    } if not tests_navigation else None
)

# ----------------------------------------------------------------------
# 8. SUMMARY & VERDICT CALCULATION
# ----------------------------------------------------------------------
print("\n================================================================================")
print(f"Audit Summary: {passed} PASSED, {failed} FAILED / FINDINGS")
print(f"Total Findings: {len(findings)}")
for f in findings:
    print(f"  [{f['level']}] {f['type']} in {f.get('file', 'N/A')}: {f['msg']}")
print("================================================================================")

# Output exit code
sys.exit(0 if len([f for f in findings if f['level'] == 'CRITICAL']) == 0 else 1)
