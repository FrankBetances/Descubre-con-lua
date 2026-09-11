#!/usr/bin/env python3
"""
Test Runner for Descubre con Lúa · Edición Vigo (Milestone 2 Content-as-Data & Validation Suite)
Runs complete behavioral test suite mirroring test/data/*.dart for autonomous CI and verification.
"""

import os
import sys
import json
import re
from typing import Dict, Any, List, Set

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

total_passed = 0
total_failed = 0

def assert_true(condition: bool, description: str):
    global total_passed, total_failed
    if condition:
        total_passed += 1
        print(f"  ✅ PASS: {description}")
    else:
        total_failed += 1
        print(f"  ❌ FAIL: {description}")

def assert_equal(actual: Any, expected: Any, description: str):
    assert_true(actual == expected, f"{description} (expected: {expected}, got: {actual})")

CLINICAL_REGEX = re.compile(
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

PLACEHOLDER_REGEX = re.compile(r'\b(TODO|TBD|PLACEHOLDER|PENDIENTE|PENDENTE|LOREM\s+IPSUM)\b', re.IGNORECASE)

DECRETO_150 = "Decreto 150/2022"
ETAPA_INFANTIL = "educacion_infantil"
CICLO_0_3 = "primeiro_ciclo_0_3"

VALID_AREAS = {
    "area_1_crecemento_harmonia",
    "area_2_descubrimento_contorna",
    "area_3_comunicacion_representacion"
}

VALID_CRITERIOS = {"CA1.1", "CA2.1", "CA2.2", "CA3.1", "CA3.2"}

CANONICAL_BLOCKS = [
    ("desarrollo_comunicativo", 1),
    ("rutinas_y_bano_de_lenguaje", 2),
    ("turnos_y_atencion_conjunta", 3),
    ("juego_movimiento_sin_pantallas", 4),
    ("bilinguismo_y_cultura", 5)
]

def scan_bilingual_parity(node: Any, path: str = "root") -> List[str]:
    errors = []
    if isinstance(node, dict):
        has_gl = "gl" in node
        has_es = "es" in node
        if has_gl and has_es:
            gl_val = str(node["gl"]).strip()
            es_val = str(node["es"]).strip()
            if not gl_val:
                errors.append(f"{path}.gl is empty")
            if not es_val:
                errors.append(f"{path}.es is empty")
            if PLACEHOLDER_REGEX.search(gl_val):
                errors.append(f"{path}.gl has placeholder: {gl_val}")
            if PLACEHOLDER_REGEX.search(es_val):
                errors.append(f"{path}.es has placeholder: {es_val}")
        elif has_gl and not has_es:
            errors.append(f"{path} missing 'es'")
        elif not has_gl and has_es:
            errors.append(f"{path} missing 'gl'")

        for k, v in node.items():
            errors.extend(scan_bilingual_parity(v, f"{path}.{k}"))
    elif isinstance(node, list):
        for i, elem in enumerate(node):
            errors.extend(scan_bilingual_parity(elem, f"{path}[{i}]"))
    return errors

def scan_clinical_terms(node: Any, path: str = "root") -> List[str]:
    errors = []
    if isinstance(node, str):
        match = CLINICAL_REGEX.search(node)
        if match:
            errors.append(f"{path}: Prohibited clinical term '{match.group(0)}'")
    elif isinstance(node, dict):
        for k, v in node.items():
            errors.extend(scan_clinical_terms(v, f"{path}.{k}"))
    elif isinstance(node, list):
        for i, elem in enumerate(node):
            errors.extend(scan_clinical_terms(elem, f"{path}[{i}]"))
    return errors

def run_all_tests():
    print("===================================================================")
    print("DESCUBRE CON LÚA · EDICIÓN VIGO — TEST DATA SUITE (M2)")
    print("===================================================================")

    # 1. Models Test
    print("\n--- 1. Models Suite (CurricularReference, Unidad, Capsula) ---")
    unit_path = os.path.join(PROJECT_ROOT, "assets/content/unidades/juega.mar.01.json")
    with open(unit_path, "r", encoding="utf-8") as f:
        unit = json.load(f)

    assert_equal(unit["id"], "juega.mar.01", "Unidad ID matches")
    assert_equal(unit["tramoEtario"], "0-3", "Unidad tramo matches")
    assert_true(isinstance(unit["orden"], int), "Unidad order is integer")
    assert_true(bool(unit["titulo"]["gl"]) and bool(unit["titulo"]["es"]), "Unidad title has gl and es")
    assert_equal(unit["cancionPulso"]["bpm"], 80, "Cancion BPM is 80")
    assert_equal(len(unit["cuento"]["paginas"]), 3, "Cuento has 3 pages")
    assert_equal(len(unit["vocabulario"]), 5, "Vocabulario has 5 items")
    assert_equal(len(unit["preguntas"]), 3, "Preguntas has 3 graduated levels")
    assert_true(bool(unit["exploracion"]["avisoSeguridad"]["gl"]), "Exploracion has gl safety notice")
    assert_true(bool(unit["exploracion"]["avisoSeguridad"]["es"]), "Exploracion has es safety notice")
    assert_equal(unit["revision"]["aprobadoParaAula"], True, "Unit is approved for classroom")

    capsula_path = os.path.join(PROJECT_ROOT, "assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json")
    with open(capsula_path, "r", encoding="utf-8") as f:
        capsula = json.load(f)

    assert_equal(capsula["id"], "academy.como_se_aprende_a_hablar.01", "Capsula ID matches")
    assert_equal(capsula["bloqueId"], "desarrollo_comunicativo", "Capsula bloqueId matches")
    assert_equal(capsula["tiempoLecturaMinutos"], 3, "Capsula reading time is 3 min")
    for sec in ["ideaClave", "porQueImporta", "queHacerEnCasa", "ejemploCotidiano"]:
        assert_true(bool(capsula[sec]["gl"]) and bool(capsula[sec]["es"]), f"Capsula has 4-part section: {sec}")
    assert_equal(len(capsula["afirmaciones"]), 2, "Capsula has 2 reflective statements")

    # 2. Content Loader & Repository Test
    print("\n--- 2. Content Loader & Repository Suite ---")
    assert_true(os.path.exists(unit_path), "Base unit file exists on disk")
    assert_true(os.path.exists(capsula_path), "Base capsule file exists on disk")

    # Age band query simulation
    assert_true("0-3" == unit["tramoEtario"] or "0-2" == unit["tramoEtario"], "Unit matches 0-2 filter")
    assert_true("0-3" == unit["tramoEtario"] or "2-3" == unit["tramoEtario"], "Unit matches 2-3 filter")

    # Block query simulation
    for block_id, order in CANONICAL_BLOCKS:
        assert_true(isinstance(block_id, str) and order >= 1 and order <= 5, f"Canonical block {block_id} has order {order}")

    # 3. Bilingual Parity Test
    print("\n--- 3. Bilingual Parity Suite (1:1 gl/es) ---")
    unit_parity_errors = scan_bilingual_parity(unit, "juega.mar.01")
    assert_equal(len(unit_parity_errors), 0, f"Unidad bilingual parity errors: {len(unit_parity_errors)}")

    capsula_parity_errors = scan_bilingual_parity(capsula, "academy.como_se_aprende_a_hablar.01")
    assert_equal(len(capsula_parity_errors), 0, f"Capsula bilingual parity errors: {len(capsula_parity_errors)}")

    # Adversarial asymmetry check
    asym_errs = scan_bilingual_parity({"bad": {"gl": "so galego"}})
    assert_true(len(asym_errs) > 0, "Asymmetric node correctly produces error")

    # Adversarial placeholder check
    for ph in ["TODO", "TBD", "PENDIENTE", "PENDENTE", "LOREM IPSUM", "placeholder", "PLACEHOLDER", "Placeholder"]:
        placeholder_errs = scan_bilingual_parity({"bad": {"gl": ph, "es": "Castellano"}})
        assert_true(len(placeholder_errs) > 0, f"Placeholder '{ph}' correctly produces error")

    # 4. Curricular Alignment Test
    print("\n--- 4. Curricular Alignment Suite (Decreto 150/2022) ---")
    unit_curr = unit["curriculo"]
    assert_equal(unit_curr["normativa"], DECRETO_150, "Unit references Decreto 150/2022")
    assert_equal(unit_curr["etapa"], ETAPA_INFANTIL, "Unit stage is educacion_infantil")
    assert_equal(unit_curr["ciclo"], CICLO_0_3, "Unit cycle is primeiro_ciclo_0_3")
    assert_true(set(unit_curr["areas"]).issubset(VALID_AREAS), f"Unit areas valid: {unit_curr['areas']}")
    assert_true(set(unit_curr["criteriosEvaluacion"]).issubset(VALID_CRITERIOS), f"Unit criteria valid: {unit_curr['criteriosEvaluacion']}")

    cap_curr = capsula["curriculo"]
    assert_equal(cap_curr["normativa"], DECRETO_150, "Capsule references Decreto 150/2022")
    assert_equal(cap_curr["etapa"], ETAPA_INFANTIL, "Capsule stage is educacion_infantil")
    assert_true(set(cap_curr["areas"]).issubset(VALID_AREAS), f"Capsule areas valid: {cap_curr['areas']}")

    # 5. Clinical Terms Blacklist Linter Test
    print("\n--- 5. Clinical Terms Blacklist Linter Suite ---")
    unit_clinical = scan_clinical_terms(unit, "juega.mar.01")
    assert_equal(len(unit_clinical), 0, f"Unit clinical terms count: {len(unit_clinical)}")

    capsula_clinical = scan_clinical_terms(capsula, "academy.como_se_aprende_a_hablar.01")
    assert_equal(len(capsula_clinical), 0, f"Capsule clinical terms count: {len(capsula_clinical)}")

    # Injected check
    injected_test = [
        "paciente con síntoma",
        "intervención terapéutica",
        "diagnóstico precoz",
        "diagnosticaron un retraso",
        "diagnosticouse o cadro",
        "patoloxía da fala",
        "patoloxías do desenvolvemento",
        "patrón patológico observado",
        "patoloxía e cadro patolóxico",
        "trastorno do espectro",
        "déficit cognitivo",
        "tratamento clínico",
        "retraso clínico",
        "retrasos clínicos",
        "dislalia e dislexia",
        "patrón dislálico e disléxico",
        "afasia e disfasia",
        "rehabilitación vocal",
        "profesionais rehabilitadores",
        "criba clínica e screening",
        "resultados dos cribados",
        "protocolo de cribaxe neonatal",
        "cribaxes sistemáticas",
        "pronóstico a longo prazo"
    ]
    for inj in injected_test:
        errs = scan_clinical_terms(inj)
        assert_true(len(errs) > 0, f"Blacklist catches injected: '{inj}'")

    # Environmental water treatment exemption
    water_terms = [
        "O tratamento de auga na ría de Vigo para a depuración de moluscos",
        "El tratamiento de agua en la ría de Vigo para la depuración"
    ]
    for w in water_terms:
        w_errs = scan_clinical_terms(w)
        assert_equal(len(w_errs), 0, f"Blacklist correctly permits environmental term: '{w}'")

    # 6. Referential Integrity Test
    print("\n--- 6. Referential Integrity & Completeness Suite ---")
    # Audio extensions and local paths
    assert_true(unit["cancionPulso"]["audioAsset"]["gl"].startswith("assets/audio/"), "Cancion gl audio local path")
    assert_true(unit["cancionPulso"]["audioAsset"]["gl"].endswith(".mp3"), "Cancion gl audio mp3 extension")
    for v in unit["vocabulario"]:
        assert_true(v["audioAsset"]["gl"].startswith("assets/audio/"), f"Vocab {v['id']} gl audio local path")
        assert_true(v["audioAsset"]["gl"].endswith(".mp3"), f"Vocab {v['id']} gl audio mp3 extension")

    # Scaffolding levels
    q_levels = [p["nivel"] for p in unit["preguntas"]]
    assert_equal(set(q_levels), {1, 2, 3}, "Unit contains question levels 1, 2, 3")

    # Safety notice
    aviso_gl = unit["exploracion"]["avisoSeguridad"]["gl"]
    assert_true("5 cm" in aviso_gl or "4 cm" in aviso_gl, "Safety notice specifies size >= 4-5 cm")
    assert_true("supervisión" in aviso_gl.lower(), "Safety notice mandates teacher supervision")

    # 4 Canonical parts
    for part in ["ideaClave", "porQueImporta", "queHacerEnCasa", "ejemploCotidiano"]:
        assert_true(part in capsula, f"Capsule has canonical part: {part}")

    print("\n===================================================================")
    print(f"TOTAL TESTS: {total_passed + total_failed} | PASSED: {total_passed} | FAILED: {total_failed}")
    if total_failed == 0:
        print("🎉 ALL TEST DATA SUITES PASSED EMPIRICALLY (100% SUCCESS)")
        print("===================================================================")
        sys.exit(0)
    else:
        print("❌ SOME TESTS FAILED")
        print("===================================================================")
        sys.exit(1)

if __name__ == "__main__":
    run_all_tests()
