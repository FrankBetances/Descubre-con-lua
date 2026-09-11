#!/usr/bin/env python3
"""
Forensic Integrity Audit Script for Milestone 2 Deliverables
«Descubre con Lúa · Edición Vigo»
Independent adversarial and forensic verification.
"""

import os
import sys
import json
import re
from typing import Dict, Any, List, Set, Tuple

PROJECT_ROOT = "/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa"
AUDIT_ERRORS = []

def audit_assert(condition: bool, check_name: str, details: str = ""):
    global AUDIT_ERRORS
    if not condition:
        msg = f"FAIL: {check_name} - {details}"
        AUDIT_ERRORS.append(msg)
        print(f"❌ {msg}")
    else:
        print(f"✅ PASS: {check_name}")

def test_source_code_integrity():
    print("\n--- PHASE 1: SOURCE CODE INTEGRITY IN LIB/DATA ---")
    data_dir = os.path.join(PROJECT_ROOT, "lib/data")
    
    dart_files = []
    for root, _, files in os.walk(data_dir):
        for f in files:
            if f.endswith(".dart"):
                dart_files.append(os.path.join(root, f))
                
    audit_assert(len(dart_files) == 6, "Expected exactly 6 Dart source files in lib/data", f"Found {len(dart_files)}")
    
    # Exact package/import network check
    prohibited_import_patterns = [
        re.compile(r'import\s+[\'"]dart:io[\'"]'),
        re.compile(r'import\s+[\'"]package:(http|dio|retrofit|web_socket_channel|firebase|cloud_firestore)'),
        re.compile(r'\bHttpClient\b'),
        re.compile(r'\bWebSocket\b'),
        re.compile(r'\bSocket\.connect\b'),
    ]
    
    for file_path in dart_files:
        rel = os.path.relpath(file_path, PROJECT_ROOT)
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()
            
        # 1. Network check
        for pattern in prohibited_import_patterns:
            audit_assert(not pattern.search(content), f"Zero prohibited network pattern '{pattern.pattern}' in {rel}")
            
        # 2. Hardcoded test stubs check in code (excluding comments)
        code_lines = [l for l in content.splitlines() if not l.strip().startswith("//") and not l.strip().startswith("/*") and not l.strip().startswith("*")]
        code_text = "\n".join(code_lines)
        audit_assert(not re.search(r'\bclass\s+\w*(Fake|Dummy)\w*', code_text), f"No Fake/Dummy class definitions in {rel}")
        
        # 3. Method implementation check (no empty classes or all-unimplemented methods)
        audit_assert("throw UnimplementedError" not in content, f"No UnimplementedError in {rel}")
        audit_assert("throw UnsupportedError" not in content, f"No UnsupportedError in {rel}")

def test_json_production_assets():
    print("\n--- PHASE 2: BASE JSON ASSETS FORENSIC INTEGRITY ---")
    
    # 1. juega.mar.01.json
    unidad_path = os.path.join(PROJECT_ROOT, "assets/content/unidades/juega.mar.01.json")
    audit_assert(os.path.exists(unidad_path), "juega.mar.01.json exists")
    
    with open(unidad_path, "r", encoding="utf-8") as f:
        u_data = json.load(f)
        
    audit_assert(u_data.get("id") == "juega.mar.01", "Unidad ID is genuine 'juega.mar.01'")
    audit_assert(u_data.get("tramoEtario") == "0-3", "Unidad tramo is '0-3'")
    audit_assert(len(u_data.get("titulo", {}).get("gl", "")) > 10, "Unidad gl title is substantial")
    audit_assert(len(u_data.get("titulo", {}).get("es", "")) > 10, "Unidad es title is substantial")
    audit_assert(u_data.get("cancionPulso", {}).get("bpm") == 80, "Cancion pulso BPM is 80")
    gl_letra = u_data.get("cancionPulso", {}).get("letraConPulsos", {}).get("gl", "").lower()
    es_letra = u_data.get("cancionPulso", {}).get("letraConPulsos", {}).get("es", "").lower()
    audit_assert("on-das" in gl_letra or "ondas" in gl_letra, "Song contains Vigo maritime waves lyrics in gl")
    audit_assert("o-las" in es_letra or "olas" in es_letra, "Song contains Vigo maritime waves lyrics in es")
    
    # Story
    paginas = u_data.get("cuento", {}).get("paginas", [])
    audit_assert(len(paginas) == 3, "Story has exactly 3 pages", f"Found {len(paginas)}")
    for i, p in enumerate(paginas):
        audit_assert(p.get("orden") == i + 1, f"Story page {i+1} order matches")
        audit_assert(len(p.get("texto", {}).get("gl", "")) > 20, f"Story page {i+1} gl text is rich")
        audit_assert(len(p.get("texto", {}).get("es", "")) > 20, f"Story page {i+1} es text is rich")
        
    # Vocab
    vocab = u_data.get("vocabulario", [])
    audit_assert(len(vocab) == 5, "Vocabulario has exactly 5 items", f"Found {len(vocab)}")
    for v in vocab:
        audit_assert(v.get("audioAsset", {}).get("gl", "").startswith("assets/audio/"), f"Vocab '{v.get('id')}' audio is local asset")
        audit_assert(len(v.get("definicionBreve", {}).get("gl", "")) > 10, f"Vocab '{v.get('id')}' has rich gl definition")
        
    # Questions
    preguntas = u_data.get("preguntas", [])
    audit_assert(len(preguntas) == 3, "Preguntas has 3 graduated levels")
    levels = [p.get("nivel") for p in preguntas]
    audit_assert(levels == [1, 2, 3], "Preguntas levels are strictly [1, 2, 3]", f"Found {levels}")
    
    # Exploracion & Safety
    exploracion = u_data.get("exploracion", {})
    aviso = exploracion.get("avisoSeguridad", {})
    audit_assert("5 cm" in aviso.get("gl", ""), "Safety notice mandates >= 5cm pieces in gl")
    audit_assert("5 cm" in aviso.get("es", ""), "Safety notice mandates >= 5cm pieces in es")
    audit_assert("supervisión" in aviso.get("gl", "").lower(), "Safety notice mandates constant supervision in gl")
    audit_assert("supervisión" in aviso.get("es", "").lower(), "Safety notice mandates constant supervision in es")
    
    # Early math & Bridge to home
    mat = u_data.get("matematicas", {})
    audit_assert("grande" in mat.get("concepto", {}).get("gl", "").lower(), "Math covers grande/pequeno magnitude")
    puente = u_data.get("puenteCasa", {})
    audit_assert(len(puente.get("actividadesSugeridas", [])) >= 2, "Puente casa has at least 2 home suggestions")
    
    # Curricular
    curriculo = u_data.get("curriculo", {})
    audit_assert(curriculo.get("normativa") == "Decreto 150/2022", "Unidad normative is Decreto 150/2022")
    audit_assert(curriculo.get("etapa") == "educacion_infantil", "Unidad stage is educacion_infantil")
    audit_assert(curriculo.get("ciclo") == "primeiro_ciclo_0_3", "Unidad cycle is primeiro_ciclo_0_3")
    
    # 2. academy.como_se_aprende_a_hablar.01.json
    cap_path = os.path.join(PROJECT_ROOT, "assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json")
    audit_assert(os.path.exists(cap_path), "academy.como_se_aprende_a_hablar.01.json exists")
    
    with open(cap_path, "r", encoding="utf-8") as f:
        c_data = json.load(f)
        
    audit_assert(c_data.get("id") == "academy.como_se_aprende_a_hablar.01", "Capsule ID matches")
    audit_assert(c_data.get("bloqueId") == "desarrollo_comunicativo", "Capsule block is desarrollo_comunicativo")
    audit_assert(c_data.get("tiempoLecturaMinutos") == 3, "Capsule reading time is 3 min")
    
    for sec in ["ideaClave", "porQueImporta", "queHacerEnCasa", "ejemploCotidiano"]:
        audit_assert(len(c_data.get(sec, {}).get("gl", "")) > 30, f"Capsule section '{sec}' gl is pedagogically detailed")
        audit_assert(len(c_data.get(sec, {}).get("es", "")) > 30, f"Capsule section '{sec}' es is pedagogically detailed")
        
    afirmaciones = c_data.get("afirmaciones", [])
    audit_assert(len(afirmaciones) == 2, "Capsule has exactly 2 formative statements")
    audit_assert(afirmaciones[0].get("esVerdadera") is True, "Afirmacion 1 is True with positive explanation")
    audit_assert(afirmaciones[1].get("esVerdadera") is False, "Afirmacion 2 is False with gentle corrective explanation")

def test_clinical_blacklist_deep_scan():
    print("\n--- PHASE 3: CLINICAL BLACKLIST DEEP FORENSIC SCAN ---")
    
    clinical_regex = re.compile(
        r'\b(trastorno|trastornos|patolog[ií]a|patolog[ií]as|patolox[ií]a|patolox[ií]as|patol[oó]xic[oa]s?|'
        r'diagn[oó]stic[oa]s?|diagnosticar|s[ií]ntoma|s[ií]ntomas|sintomatolog[ií]a|'
        r'sintomatolox[ií]a|d[eé]ficit|d[eé]ficits|paciente|pacientes|terapia|'
        r'terapias|terap[eé]utic[oa]s?|tratamiento|tratamientos|tratamento|tratamentos|'
        r'retraso\s+cl[ií]nico|dislalia|dislalias|dislexia|dislexias|'
        r'hipoacusia\s+cl[ií]nica|afasia|disfasia|rehabilitaci[oó]n|rehabilitar|'
        r'criba\s+cl[ií]nica|screening|pron[oó]stico)\b',
        re.IGNORECASE
    )
    
    target_json_files = [
        os.path.join(PROJECT_ROOT, "assets/content/unidades/juega.mar.01.json"),
        os.path.join(PROJECT_ROOT, "assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json")
    ]
    
    for jp in target_json_files:
        rel = os.path.relpath(jp, PROJECT_ROOT)
        with open(jp, "r", encoding="utf-8") as f:
            raw_text = f.read()
            
        matches = clinical_regex.findall(raw_text)
        audit_assert(len(matches) == 0, f"Deep scan found 0 clinical blacklist matches in {rel}", f"Found: {matches}")

def test_test_suite_assertion_authenticity():
    print("\n--- PHASE 4: TEST SUITE ASSERTION AUTHENTICITY ---")
    test_dir = os.path.join(PROJECT_ROOT, "test/data")
    dart_tests = [
        "models_test.dart",
        "content_loader_test.dart",
        "bilingual_parity_test.dart",
        "curricular_alignment_test.dart",
        "clinical_terms_blacklist_test.dart",
        "referential_integrity_test.dart"
    ]
    
    for dt in dart_tests:
        full_path = os.path.join(test_dir, dt)
        audit_assert(os.path.exists(full_path), f"Test file {dt} exists")
        with open(full_path, "r", encoding="utf-8") as f:
            code = f.read()
            
        # Count expect() statements
        expect_count = len(re.findall(r'\bexpect\s*\(', code))
        audit_assert(expect_count >= 5, f"{dt} has genuine assertions (found {expect_count} expect calls)")
        
        # Verify no self-certifying tautologies like expect(true, isTrue) or expect(1, 1) without variables
        tautologies = re.findall(r'expect\s*\(\s*(true\s*,\s*isTrue|1\s*,\s*equals\(1\)|"a"\s*,\s*equals\("a"\))\s*\)', code)
        audit_assert(len(tautologies) == 0, f"{dt} contains no self-certifying tautologies")

def main():
    print("=" * 70)
    print("FORENSIC INTEGRITY AUDIT — MILESTONE 2 DELIVERABLES")
    print("=" * 70)
    
    test_source_code_integrity()
    test_json_production_assets()
    test_clinical_blacklist_deep_scan()
    test_test_suite_assertion_authenticity()
    
    print("\n" + "=" * 70)
    if not AUDIT_ERRORS:
        print("FINAL VERDICT: CLEAN")
        print("Zero integrity violations detected across all Milestone 2 deliverables.")
        print("=" * 70)
        sys.exit(0)
    else:
        print("FINAL VERDICT: INTEGRITY VIOLATION")
        print(f"Total Violations: {len(AUDIT_ERRORS)}")
        for err in AUDIT_ERRORS:
            print(f" - {err}")
        print("=" * 70)
        sys.exit(1)

if __name__ == "__main__":
    main()
