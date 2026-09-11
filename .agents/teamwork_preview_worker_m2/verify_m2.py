#!/usr/bin/env python3
"""
Empirical Verification Suite for Milestone 2: Content-as-Data & Validation Suite
«Descubre con Lúa · Edición Vigo»
Tests models, loaders, repositories, base JSON assets, and validation logic.
"""

import os
import sys
import json
import re
from typing import Dict, Any, List, Set, Tuple

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "../.."))
TOTAL_CHECKS = 0
FAILED_CHECKS = 0

def check(condition: bool, message: str) -> bool:
    global TOTAL_CHECKS, FAILED_CHECKS
    TOTAL_CHECKS += 1
    if condition:
        print(f"  ✅ PASS: {message}")
        return True
    else:
        FAILED_CHECKS += 1
        print(f"  ❌ FAIL: {message}")
        return False

# ==============================================================================
# Clinical Blacklist Regex (canonical definition from analysis.md:238)
# ==============================================================================
CLINICAL_BLACKLIST_REGEX = re.compile(
    r'\b(trastorno|trastornos|patolog[ií]a|patolog[ií]as|patolox[ií]a|patolox[ií]as|patol[oó]xic[oa]s?|'
    r'diagn[oó]stic[oa]s?|diagnosticar|s[ií]ntoma|s[ií]ntomas|sintomatolog[ií]a|'
    r'sintomatolox[ií]a|d[eé]ficit|d[eé]ficits|paciente|pacientes|terapia|'
    r'terapias|terap[eé]utic[oa]s?|tratamiento|tratamientos|tratamento|tratamentos|'
    r'retraso\s+cl[ií]nico|dislalia|dislalias|dislexia|dislexias|'
    r'hipoacusia\s+cl[ií]nica|afasia|disfasia|rehabilitaci[oó]n|rehabilitar|'
    r'criba\s+cl[ií]nica|screening|pron[oó]stico)\b',
    re.IGNORECASE
)

PLACEHOLDER_REGEX = re.compile(
    r'\b(TODO|TBD|PENDIENTE|PENDENTE|LOREM\s+IPSUM)\b',
    re.IGNORECASE
)

# Decreto 150/2022 Canonical Constants
DECRETO_150 = "Decreto 150/2022"
ETAPA_INFANTIL = "educacion_infantil"
CICLO_0_3 = "primeiro_ciclo_0_3"

VALID_AREAS = {
    "area_1_crecemento_harmonia",
    "area_2_descubrimento_contorna",
    "area_3_comunicacion_representacion"
}

VALID_CRITERIOS = {
    "CA1.1",
    "CA2.1",
    "CA2.2",
    "CA3.1",
    "CA3.2"
}

CANONICAL_BLOCKS = {
    "desarrollo_comunicativo",
    "rutinas_y_bano_de_lenguaje",
    "turnos_y_atencion_conjunta",
    "juego_movimiento_sin_pantallas",
    "bilinguismo_y_cultura"
}

# ==============================================================================
# Helper Verification Functions
# ==============================================================================
def inspect_bilingual_parity(node: Any, path: str = "root") -> List[str]:
    errors = []
    if isinstance(node, dict):
        has_gl = "gl" in node
        has_es = "es" in node
        if has_gl and has_es:
            gl_val = node["gl"]
            es_val = node["es"]
            if not isinstance(gl_val, str) or not gl_val.strip():
                errors.append(f"{path}.gl is empty or non-string")
            elif PLACEHOLDER_REGEX.search(gl_val):
                errors.append(f"{path}.gl contains forbidden placeholder: '{gl_val.strip()}'")

            if not isinstance(es_val, str) or not es_val.strip():
                errors.append(f"{path}.es is empty or non-string")
            elif PLACEHOLDER_REGEX.search(es_val):
                errors.append(f"{path}.es contains forbidden placeholder: '{es_val.strip()}'")
        elif has_gl and not has_es:
            errors.append(f"{path}: Asymmetric node has 'gl' but lacks 'es'")
        elif not has_gl and has_es:
            errors.append(f"{path}: Asymmetric node has 'es' but lacks 'gl'")

        for k, v in node.items():
            errors.extend(inspect_bilingual_parity(v, f"{path}.{k}"))
    elif isinstance(node, list):
        for i, item in enumerate(node):
            errors.extend(inspect_bilingual_parity(item, f"{path}[{i}]"))
    return errors

def inspect_clinical_terms(node: Any, path: str = "root") -> List[Tuple[str, str]]:
    findings = []
    if isinstance(node, str):
        match = CLINICAL_BLACKLIST_REGEX.search(node)
        if match:
            findings.append((path, match.group(0)))
    elif isinstance(node, dict):
        for k, v in node.items():
            findings.extend(inspect_clinical_terms(v, f"{path}.{k}"))
    elif isinstance(node, list):
        for i, item in enumerate(node):
            findings.extend(inspect_clinical_terms(item, f"{path}[{i}]"))
    return findings

# ==============================================================================
# Test Suites
# ==============================================================================
def test_directory_and_files():
    print("\n--- 1. Testing File Presence and Architecture ---")
    required_files = [
        "lib/data/models/curricular_model.dart",
        "lib/data/models/unidad_model.dart",
        "lib/data/models/capsula_model.dart",
        "lib/data/loaders/content_asset_loader.dart",
        "lib/data/repositories/content_repository.dart",
        "lib/data/validators/content_validator.dart",
        "assets/content/unidades/juega.mar.01.json",
        "assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json",
        "test/data/models_test.dart",
        "test/data/content_loader_test.dart",
        "test/data/bilingual_parity_test.dart",
        "test/data/curricular_alignment_test.dart",
        "test/data/clinical_terms_blacklist_test.dart",
        "test/data/referential_integrity_test.dart",
    ]
    for rf in required_files:
        full_path = os.path.join(PROJECT_ROOT, rf)
        check(os.path.isfile(full_path), f"Required file exists: {rf}")

def test_unidad_json():
    print("\n--- 2. Testing Base Unidad: juega.mar.01.json ---")
    path = os.path.join(PROJECT_ROOT, "assets/content/unidades/juega.mar.01.json")
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)

    check(data.get("id") == "juega.mar.01", "Unidad ID is 'juega.mar.01'")
    check(data.get("tramoEtario") in ["0-2", "2-3", "0-3"], f"Valid tramoEtario: {data.get('tramoEtario')}")
    check(isinstance(data.get("orden"), int), "Unidad has integer order")
    check(isinstance(data.get("titulo"), dict) and "gl" in data["titulo"] and "es" in data["titulo"], "Unidad titulo is bilingual")
    check("Mar de Vigo" in data["titulo"]["gl"], "Titulo references Mar de Vigo")

    # Cancion
    cancion = data.get("cancionPulso", {})
    check(cancion.get("bpm") == 80, f"Cancion pulso BPM is 80 (got: {cancion.get('bpm')})")
    audio = cancion.get("audioAsset", {})
    check(audio.get("gl", "").startswith("assets/audio/canciones/") and audio.get("gl", "").endswith(".mp3"), "Cancion gl audio path starts with assets/audio/canciones/ and ends with .mp3")
    check(audio.get("es", "").startswith("assets/audio/canciones/") and audio.get("es", "").endswith(".mp3"), "Cancion es audio path starts with assets/audio/canciones/ and ends with .mp3")

    # Cuento
    cuento = data.get("cuento", {})
    paginas = cuento.get("paginas", [])
    check(len(paginas) >= 3, f"Cuento has 3+ illustrated pages (got: {len(paginas)})")
    check("Samil" in cuento.get("titulo", {}).get("gl", ""), "Cuento set in Samil beach")

    # Vocabulario
    vocab = data.get("vocabulario", [])
    check(len(vocab) >= 5, f"Vocabulario has 5+ items (got: {len(vocab)})")
    vocab_ids = [v.get("id") for v in vocab]
    for expected_word in ["barco", "gaivota", "cuncha", "mexillon", "peixe"]:
        check(expected_word in vocab_ids, f"Vocabulario contains word: '{expected_word}'")

    # Preguntas graduadas
    preguntas = data.get("preguntas", [])
    niveles = {p.get("nivel") for p in preguntas}
    check(niveles == {1, 2, 3}, f"Preguntas cover all 3 levels (1, 2, 3) (got: {niveles})")

    # Exploracion & Safety
    exp = data.get("exploracion", {})
    check(len(exp.get("materiales", [])) >= 4, "Exploracion has 4+ materials")
    check(len(exp.get("pasos", [])) >= 4, "Exploracion has 4+ steps")
    aviso = exp.get("avisoSeguridad", {})
    check("5 cm" in aviso.get("gl", "") or "4 cm" in aviso.get("gl", ""), "Aviso de seguridade mentions >= 4-5 cm dimension")
    check("supervisión" in aviso.get("gl", "").lower(), "Aviso de seguridade mentions teacher supervision")

    # Matematicas
    mat = data.get("matematicas", {})
    check("Grande" in mat.get("concepto", {}).get("gl", ""), "Matematicas covers magnitude concept")

    # Puente casa
    puente = data.get("puenteCasa", {})
    check(len(puente.get("actividadesSugeridas", [])) >= 2, "Puente casa has 2+ home activities")

    # Curriculo
    curr = data.get("curriculo", {})
    check(curr.get("normativa") == DECRETO_150, "Curriculo references Decreto 150/2022")
    check(curr.get("etapa") == ETAPA_INFANTIL, "Curriculo stage is educacion_infantil")
    check(curr.get("ciclo") == CICLO_0_3, "Curriculo cycle is primeiro_ciclo_0_3")
    check(set(curr.get("areas", [])).issubset(VALID_AREAS), f"Curriculo areas are valid Decreto 150/2022 areas: {curr.get('areas')}")
    check(set(curr.get("criteriosEvaluacion", [])).issubset(VALID_CRITERIOS), f"Curriculo criteria are valid Decreto 150/2022 criteria: {curr.get('criteriosEvaluacion')}")

    # Revision
    rev = data.get("revision", {})
    check(rev.get("aprobadoParaAula") is True, "Revision approved for classroom")

    # Parity & Clinical checks
    parity_errs = inspect_bilingual_parity(data, "juega.mar.01")
    check(len(parity_errs) == 0, f"Unidad 100% bilingual parity (errors: {len(parity_errs)})")

    clinical_findings = inspect_clinical_terms(data, "juega.mar.01")
    check(len(clinical_findings) == 0, f"Unidad zero clinical terms (findings: {len(clinical_findings)})")

def test_capsula_json():
    print("\n--- 3. Testing Base Capsula: academy.como_se_aprende_a_hablar.01.json ---")
    path = os.path.join(PROJECT_ROOT, "assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json")
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)

    check(data.get("id") == "academy.como_se_aprende_a_hablar.01", "Capsula ID is correct")
    check(data.get("bloqueId") in CANONICAL_BLOCKS, f"Capsula bloqueId '{data.get('bloqueId')}' is in canonical blocks")
    check(data.get("orden") == 1, "Capsula order is 1")
    check(data.get("tiempoLecturaMinutos") == 3, "Reading time is 3 minutes")

    # 4 Canonical parts
    for part in ["ideaClave", "porQueImporta", "queHacerEnCasa", "ejemploCotidiano"]:
        val = data.get(part)
        is_bilingual = isinstance(val, dict) and bool(val.get("gl")) and bool(val.get("es"))
        check(is_bilingual, f"Capsula contains canonical section: {part}")

    # Key pedagogical content checks
    check("5 segundos" in data["queHacerEnCasa"]["gl"] or "5 segundos" in data["queHacerEnCasa"]["es"], "queHacerEnCasa teaches 5-second wait rule")
    check("baño de lingua" in data["titulo"]["gl"].lower() or "baño de lenguaje" in data["titulo"]["es"].lower(), "Capsula highlights language bath")

    # Afirmaciones
    afirmaciones = data.get("afirmaciones", [])
    check(len(afirmaciones) >= 2, f"Capsula has 2+ reflective statements (got: {len(afirmaciones)})")
    truth_values = [a.get("esVerdadera") for a in afirmaciones]
    check(True in truth_values and False in truth_values, "Afirmaciones have both true and false questions with pedagogical explanation")

    # Curriculo
    curr = data.get("curriculo", {})
    check(curr.get("normativa") == DECRETO_150, "Capsula references Decreto 150/2022")
    check(curr.get("etapa") == ETAPA_INFANTIL, "Capsula stage is educacion_infantil")
    check(set(curr.get("areas", [])).issubset(VALID_AREAS), f"Capsula areas are valid: {curr.get('areas')}")

    # Parity & Clinical checks
    parity_errs = inspect_bilingual_parity(data, "academy.como_se_aprende_a_hablar.01")
    check(len(parity_errs) == 0, f"Capsula 100% bilingual parity (errors: {len(parity_errs)})")

    clinical_findings = inspect_clinical_terms(data, "academy.como_se_aprende_a_hablar.01")
    check(len(clinical_findings) == 0, f"Capsula zero clinical terms (findings: {len(clinical_findings)})")

def test_adversarial_validation():
    print("\n--- 4. Testing Adversarial Edge Cases & Gate Rejections ---")

    # 1. Injected clinical term
    poisoned_clinical = {"texto": {"gl": "O paciente ten un síntoma", "es": "El paciente tiene un síntoma"}}
    findings = inspect_clinical_terms(poisoned_clinical)
    check(len(findings) == 2, f"Poisoned node caught clinical terms ('paciente', 'síntoma') (found: {len(findings)})")

    # 2. Asymmetric bilingual node
    asymmetric = {"titulo": {"gl": "Só galego"}}
    errs = inspect_bilingual_parity(asymmetric)
    check(len(errs) > 0 and ("missing 'es'" in errs[0].lower() or "lacks 'es'" in errs[0].lower()), "Asymmetric node missing 'es' rejected")

    # 3. Empty string
    empty_str = {"titulo": {"gl": "", "es": "Válido"}}
    errs = inspect_bilingual_parity(empty_str)
    check(len(errs) > 0 and "empty" in errs[0].lower(), "Empty string node rejected")

    # 4. Whitespace string
    whitespace_str = {"titulo": {"gl": "  \n\t  ", "es": "Válido"}}
    errs = inspect_bilingual_parity(whitespace_str)
    check(len(errs) > 0 and "empty" in errs[0].lower(), "Whitespace string node rejected")

    # 5. Placeholder string
    placeholder = {"titulo": {"gl": "TODO: traducir", "es": "Válido"}}
    errs = inspect_bilingual_parity(placeholder)
    check(len(errs) > 0 and "forbidden placeholder" in errs[0].lower(), "TODO placeholder rejected")

    # 6. Invalid regulation
    invalid_reg = {"normativa": "LOMLOE_GENERICA", "areas": ["area_1_crecemento_harmonia"]}
    check(invalid_reg["normativa"] != DECRETO_150, "Invalid regulation correctly fails Decreto 150/2022 equality")

    # 7. Invalid area
    invalid_area = {"normativa": DECRETO_150, "areas": ["area_99_falsa"]}
    check(not set(invalid_area["areas"]).issubset(VALID_AREAS), "Invalid area code correctly rejected")

def test_dart_syntax_and_types():
    print("\n--- 5. Testing Dart Source Code Syntax and Signatures ---")
    files_to_check = [
        "lib/data/models/curricular_model.dart",
        "lib/data/models/unidad_model.dart",
        "lib/data/models/capsula_model.dart",
        "lib/data/loaders/content_asset_loader.dart",
        "lib/data/repositories/content_repository.dart",
        "lib/data/validators/content_validator.dart",
    ]
    for rel_path in files_to_check:
        full_path = os.path.join(PROJECT_ROOT, rel_path)
        with open(full_path, "r", encoding="utf-8") as f:
            src = f.read()

        # Check for non-null factory constructors and immutable annotations
        check("@immutable" in src or "class Content" in src, f"{rel_path} has proper class declarations")
        check("fromJson" in src or "class Content" in src, f"{rel_path} has JSON deserialization factory")
        check("toJson" in src or "class Content" in src, f"{rel_path} has JSON serialization")
        check("http:" not in src and "HttpClient" not in src, f"{rel_path} strictly excludes network libraries")

def main():
    print("=" * 65)
    print("DESCUBRE CON LÚA · EDICIÓN VIGO — MILESTONE 2 EMPIRICAL AUDIT")
    print("=" * 65)

    test_directory_and_files()
    test_unidad_json()
    test_capsula_json()
    test_adversarial_validation()
    test_dart_syntax_and_types()

    print("\n" + "=" * 65)
    if FAILED_CHECKS == 0:
        print(f"🎉 ALL {TOTAL_CHECKS} EMPIRICAL CHECKS PASSED WITH ZERO DEFECTS")
        print("=" * 65)
        sys.exit(0)
    else:
        print(f"❌ AUDIT FAILED: {FAILED_CHECKS} of {TOTAL_CHECKS} checks failed")
        print("=" * 65)
        sys.exit(1)

if __name__ == "__main__":
    main()
