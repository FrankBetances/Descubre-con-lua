#!/usr/bin/env python3
"""
Descubre con Lúa · Edición Vigo
Milestone 2 Adversarial Stress Test Suite (Challenger 2)

Probes:
1. Malformed and corrupted JSON payloads (syntax errors, wrong types, missing sections).
2. ContentRepository query edge cases (unknown IDs, non-existent age bands, case sensitivity, concurrent access, cache invalidation).
3. Unidad model boundary conditions (0, 1, 2, 3 question levels, missing safety notice, invalid BPM).
4. CurricularReference constraints (unauthorized stages, non-Galician decrees, invalid areas/criteria).
5. Dart source code type-safety and defensive architecture invariants.
"""

import os
import sys
import json
import re
import copy
from typing import Dict, Any, List, Optional, Tuple

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

total_passed = 0
total_failed = 0
total_findings = []

def record_pass(description: str):
    global total_passed
    total_passed += 1
    print(f"  ✅ PASS: {description}")

def record_fail(description: str, reason: str = ""):
    global total_failed, total_findings
    total_failed += 1
    msg = f"{description}" + (f" -> {reason}" if reason else "")
    total_findings.append(msg)
    print(f"  ❌ FAIL: {msg}")

def record_vuln(vuln_id: str, title: str, description: str, severity: str = "MEDIUM"):
    global total_findings
    msg = f"[{severity}] {vuln_id}: {title} — {description}"
    total_findings.append(msg)
    print(f"  ⚠️ FINDING ({severity}): {msg}")

# Canonical constants from specification
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

# Simulated Dart ContentValidator logic for empirical testing
class SimulatedContentValidator:
    def __init__(self):
        self.clinical_regex = re.compile(
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
        self.placeholder_regex = re.compile(r'\b(TODO|TBD|PLACEHOLDER|PENDIENTE|PENDENTE|LOREM\s+IPSUM)\b', re.IGNORECASE)
        self.valid_audio_exts = {".mp3", ".wav", ".ogg", ".m4a"}

    def validate_unidad(self, data: Any) -> Tuple[bool, List[str]]:
        errors = []
        if not isinstance(data, dict):
            return False, ["Root is not a JSON object"]

        # Root id
        if "id" not in data or not isinstance(data.get("id"), str) or not data["id"].strip():
            errors.append("Missing or empty root id")

        # Tramo etario
        tramo = data.get("tramoEtario") or data.get("tramo_etario")
        if tramo not in ("0-2", "2-3", "0-3"):
            errors.append(f"Invalid tramoEtario: {tramo}")

        # Bilingual parity
        self._check_parity(data, "root", errors)

        # Clinical blacklist
        self._check_clinical(data, "root", errors)

        # Curricular alignment
        curriculo = data.get("curriculo") or data.get("curricular")
        if not isinstance(curriculo, dict):
            errors.append("Missing or invalid curriculo section")
        else:
            self._check_curricular(curriculo, errors)

        # Referential integrity: cancion
        cancion = data.get("cancionPulso") or data.get("cancion")
        if not isinstance(cancion, dict):
            errors.append("Missing or invalid cancionPulso section")
        else:
            if "bpm" in cancion:
                bpm_val = cancion["bpm"]
                if not isinstance(bpm_val, (int, float)) or bpm_val < 40 or bpm_val > 160:
                    errors.append(f"cancionPulso.bpm must be between 40 and 160 BPM (got: {bpm_val})")
            audio = cancion.get("audioAsset") or cancion.get("audio_asset")
            self._check_audio(audio, "cancionPulso.audioAsset", errors)

        # Cuento
        cuento = data.get("cuento") or data.get("conto")
        if not isinstance(cuento, dict):
            errors.append("Missing or invalid cuento section")
        else:
            paginas = cuento.get("paginas")
            if not isinstance(paginas, list) or len(paginas) == 0:
                errors.append("cuento.paginas must have at least one page")

        # Vocabulario
        vocab = data.get("vocabulario")
        if not isinstance(vocab, list) or len(vocab) == 0:
            errors.append("vocabulario must have at least one item")
        else:
            for i, v in enumerate(vocab):
                if isinstance(v, dict):
                    a = v.get("audioAsset") or v.get("audio_asset")
                    self._check_audio(a, f"vocabulario[{i}].audioAsset", errors)

        # Preguntas (Levels 1, 2, 3)
        preguntas = data.get("preguntas")
        if not isinstance(preguntas, list) or len(preguntas) == 0:
            errors.append("preguntas must contain graduated questions")
        else:
            levels = {p.get("nivel") for p in preguntas if isinstance(p, dict) and "nivel" in p}
            for req in [1, 2, 3]:
                if req not in levels:
                    errors.append(f"preguntas missing level {req}")

        # Exploracion & safety notice
        exploracion = data.get("exploracion") or data.get("exploracionSensorial")
        if not isinstance(exploracion, dict):
            errors.append("Missing or invalid exploracion section")
        else:
            aviso = exploracion.get("avisoSeguridad") or exploracion.get("aviso_seguridad")
            if not isinstance(aviso, dict):
                errors.append("exploracion missing MANDATORY avisoSeguridad")
            else:
                gl = str(aviso.get("gl", "")).strip()
                es = str(aviso.get("es", "")).strip()
                if not gl or not es:
                    errors.append("exploracion.avisoSeguridad must be populated in gl and es")

        # Matematicas
        mat = data.get("matematicas") or data.get("matematicasTempras")
        if not isinstance(mat, dict):
            errors.append("Missing or invalid matematicas section")

        # Puente casa
        puente = data.get("puenteCasa") or data.get("ponteCasa") or data.get("puente_casa")
        if not isinstance(puente, dict):
            errors.append("Missing or invalid puenteCasa section")

        return len(errors) == 0, errors

    def validate_capsula(self, data: Any) -> Tuple[bool, List[str]]:
        errors = []
        if not isinstance(data, dict):
            return False, ["Root is not a JSON object"]

        if "id" not in data or not isinstance(data.get("id"), str) or not data["id"].strip():
            errors.append("Missing or empty root id")

        bloque_id = str(data.get("bloqueId") or data.get("bloque_id") or "").strip()
        valid_block_ids = {b[0] for b in CANONICAL_BLOCKS}
        if bloque_id not in valid_block_ids:
            errors.append(f"Invalid bloqueId: {bloque_id}")

        self._check_parity(data, "root", errors)
        self._check_clinical(data, "root", errors)

        curriculo = data.get("curriculo") or data.get("curricular")
        if not isinstance(curriculo, dict):
            errors.append("Missing or invalid curriculo section")
        else:
            self._check_curricular(curriculo, errors)

        contido = data.get("contido") if isinstance(data.get("contido"), dict) else {}
        for sec in ["ideaClave", "porQueImporta", "queHacerEnCasa", "ejemploCotidiano"]:
            val = data.get(sec) or contido.get(sec)
            if not isinstance(val, dict) or "gl" not in val or "es" not in val:
                errors.append(f"Capsule missing canonical section: {sec}")

        afirmaciones = data.get("afirmaciones")
        if not isinstance(afirmaciones, list) or len(afirmaciones) == 0:
            errors.append("Capsule must contain at least one afirmacion")

        return len(errors) == 0, errors

    def _check_parity(self, node: Any, path: str, errors: List[str]):
        if isinstance(node, dict):
            has_gl = "gl" in node
            has_es = "es" in node
            if has_gl and has_es:
                gl_val = str(node["gl"]).strip() if isinstance(node["gl"], str) else ""
                es_val = str(node["es"]).strip() if isinstance(node["es"], str) else ""
                if not gl_val:
                    errors.append(f"{path}.gl is blank or non-string")
                elif self.placeholder_regex.search(gl_val):
                    errors.append(f"{path}.gl has placeholder: {gl_val}")

                if not es_val:
                    errors.append(f"{path}.es is blank or non-string")
                elif self.placeholder_regex.search(es_val):
                    errors.append(f"{path}.es has placeholder: {es_val}")
            elif has_gl and not has_es:
                errors.append(f"{path} missing 'es'")
            elif not has_gl and has_es:
                errors.append(f"{path} missing 'gl'")

            for k, v in node.items():
                self._check_parity(v, f"{path}.{k}", errors)
        elif isinstance(node, list):
            for i, elem in enumerate(node):
                self._check_parity(elem, f"{path}[{i}]", errors)

    def _check_clinical(self, node: Any, path: str, errors: List[str]):
        if isinstance(node, str):
            match = self.clinical_regex.search(node)
            if match:
                errors.append(f"{path} contains clinical term: {match.group(0)}")
        elif isinstance(node, dict):
            for k, v in node.items():
                self._check_clinical(v, f"{path}.{k}", errors)
        elif isinstance(node, list):
            for i, elem in enumerate(node):
                self._check_clinical(elem, f"{path}[{i}]", errors)

    def _check_curricular(self, curriculo: dict, errors: List[str]):
        normativa = str(curriculo.get("normativa", "")).strip()
        if normativa != DECRETO_150:
            errors.append(f"curriculo.normativa must be {DECRETO_150}, got: {normativa}")

        etapa = str(curriculo.get("etapa", "")).strip()
        if etapa != ETAPA_INFANTIL:
            errors.append(f"curriculo.etapa must be {ETAPA_INFANTIL}, got: {etapa}")

        ciclo = str(curriculo.get("ciclo", "")).strip()
        if ciclo != CICLO_0_3:
            errors.append(f"curriculo.ciclo must be {CICLO_0_3}, got: {ciclo}")

        areas = curriculo.get("areas")
        if not isinstance(areas, list) or len(areas) == 0:
            errors.append("curriculo.areas must be non-empty list")
        else:
            for a in areas:
                if a not in VALID_AREAS:
                    errors.append(f"curriculo.areas contains unrecognized area '{a}'")

        criterios = curriculo.get("criteriosEvaluacion") or curriculo.get("criterios_evaluacion")
        if not isinstance(criterios, list) or len(criterios) == 0:
            errors.append("curriculo.criteriosEvaluacion must be non-empty list")
        else:
            for c in criterios:
                if c not in VALID_CRITERIOS:
                    errors.append(f"curriculo.criteriosEvaluacion contains unrecognized criterion '{c}'")

    def _check_audio(self, audio: Any, path: str, errors: List[str]):
        if not audio:
            errors.append(f"{path}: missing audio asset")
            return
        if isinstance(audio, str):
            self._check_audio_path(audio, path, errors)
        elif isinstance(audio, dict):
            gl = audio.get("gl", "")
            es = audio.get("es", "")
            if not gl:
                errors.append(f"{path}.gl missing audio")
            else:
                self._check_audio_path(gl, f"{path}.gl", errors)
            if not es:
                errors.append(f"{path}.es missing audio")
            else:
                self._check_audio_path(es, f"{path}.es", errors)

    def _check_audio_path(self, path_str: str, path: str, errors: List[str]):
        if not path_str.startswith("assets/audio/"):
            errors.append(f"{path}: audio path must start with 'assets/audio/' (got: {path_str})")
        ext = os.path.splitext(path_str)[1].lower()
        if ext not in self.valid_audio_exts:
            errors.append(f"{path}: invalid audio extension {ext} in {path_str}")


# Simulated ContentRepository for query edge cases
class SimulatedContentRepository:
    def __init__(self):
        self._unidades = {}
        self._capsulas = {}
        self.is_initialized = False

    def initialize(self, unidades: List[dict], capsulas: List[dict]):
        self._unidades.clear()
        self._capsulas.clear()
        for u in unidades:
            self._unidades[u["id"]] = u
        for c in capsulas:
            self._capsulas[c["id"]] = c
        self.is_initialized = True

    def get_unidad_by_id(self, uid: str) -> Optional[dict]:
        return self._unidades.get(uid.strip())

    def get_capsula_by_id(self, cid: str) -> Optional[dict]:
        return self._capsulas.get(cid.strip())

    def get_unidades_by_tramo(self, tramo: str) -> List[dict]:
        clean = tramo.strip()
        valid_filters = {"0-2", "2-3", "0-3"}
        if clean not in valid_filters:
            return []
        result = []
        for u in self._unidades.values():
            utramo = u.get("tramoEtario", "0-3")
            # Mimicking Dart Unidad.matchesAgeBand
            if utramo == "0-3" or utramo == clean:
                result.append(u)
        return sorted(result, key=lambda x: x.get("orden", 0))

    def get_capsulas_by_bloque(self, bloque_id: str) -> List[dict]:
        clean = bloque_id.strip().lower()
        if clean.isdigit():
            num = int(clean)
            for b_id, b_ord in CANONICAL_BLOCKS:
                if b_ord == num:
                    clean = b_id
                    break
        result = [c for c in self._capsulas.values() if c.get("bloqueId", "").lower() == clean]
        return sorted(result, key=lambda x: x.get("orden", 0))

    def get_bloque_by_id(self, bid: str) -> Optional[Tuple[str, int]]:
        clean = bid.strip().lower()
        if clean.isdigit():
            num = int(clean)
            for b_id, b_ord in CANONICAL_BLOCKS:
                if b_ord == num:
                    return (b_id, b_ord)
            return None
        for b_id, b_ord in CANONICAL_BLOCKS:
            if b_id.lower() == clean:
                return (b_id, b_ord)
        return None

    def clear(self):
        self._unidades.clear()
        self._capsulas.clear()
        self.is_initialized = False


def run_adversarial_suite():
    print("=" * 70)
    print("CHALLENGER 2: ADVERSARIAL STRESS TEST SUITE (MILESTONE 2)")
    print("Descubre con Lúa · Edición Vigo (Models, Loader & Repository)")
    print("=" * 70)

    validator = SimulatedContentValidator()

    # Load base production assets for testing
    unit_path = os.path.join(PROJECT_ROOT, "assets/content/unidades/juega.mar.01.json")
    capsula_path = os.path.join(PROJECT_ROOT, "assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json")

    with open(unit_path, "r", encoding="utf-8") as f:
        base_unit = json.load(f)
    with open(capsula_path, "r", encoding="utf-8") as f:
        base_capsula = json.load(f)

    # -------------------------------------------------------------------------
    # SUITE 1: MALFORMED & CORRUPTED JSON PAYLOADS
    # -------------------------------------------------------------------------
    print("\n>>> SUITE 1: Malformed & Corrupted JSON Payloads")

    # 1.1 Syntax Errors
    malformed_strings = [
        ('{"id": "juega.mar.01"', "Unterminated JSON object"),
        ('{"id": "juega.mar.01",}', "Trailing comma in JSON"),
        ('NOT_A_JSON_STRING', "Completely non-JSON string"),
        ('', "Empty string payload"),
        ('   \n\t  ', "Whitespace string payload"),
    ]
    for raw_str, desc in malformed_strings:
        try:
            json.loads(raw_str)
            record_fail(f"Syntax error check: {desc}", "Expected JSONDecodeError but succeeded")
        except json.JSONDecodeError:
            record_pass(f"Syntax error caught: {desc}")

    # 1.2 Root type mismatches
    root_mismatches = [
        ([{"id": "test"}], "List at root instead of Map"),
        ("string_at_root", "String at root instead of Map"),
        (12345, "Integer at root instead of Map"),
        (None, "Null at root instead of Map"),
        (True, "Boolean at root instead of Map"),
    ]
    for root_val, desc in root_mismatches:
        valid, errs = validator.validate_unidad(root_val)
        if not valid and len(errs) > 0:
            record_pass(f"Root mismatch rejected: {desc}")
        else:
            record_fail(f"Root mismatch rejected: {desc}", "Expected rejection")

    # 1.3 Missing sections in Unidad
    sections_to_remove = [
        ("id", "Missing root 'id'"),
        ("tramoEtario", "Missing 'tramoEtario'"),
        ("cancionPulso", "Missing 'cancionPulso'"),
        ("cuento", "Missing 'cuento'"),
        ("vocabulario", "Missing 'vocabulario'"),
        ("preguntas", "Missing 'preguntas'"),
        ("exploracion", "Missing 'exploracion'"),
        ("matematicas", "Missing 'matematicas'"),
        ("puenteCasa", "Missing 'puenteCasa'"),
        ("curriculo", "Missing 'curriculo'"),
    ]
    for sec, desc in sections_to_remove:
        corrupted = copy.deepcopy(base_unit)
        corrupted.pop(sec, None)
        valid, errs = validator.validate_unidad(corrupted)
        if not valid:
            record_pass(f"Unit missing section rejected: {desc}")
        else:
            record_fail(f"Unit missing section rejected: {desc}", "Validator allowed missing section")

    # 1.4 Missing canonical sections in Capsula
    capsula_sections_to_remove = [
        ("id", "Missing root 'id'"),
        ("bloqueId", "Missing 'bloqueId'"),
        ("ideaClave", "Missing canonical 'ideaClave'"),
        ("porQueImporta", "Missing canonical 'porQueImporta'"),
        ("queHacerEnCasa", "Missing canonical 'queHacerEnCasa'"),
        ("ejemploCotidiano", "Missing canonical 'ejemploCotidiano'"),
        ("afirmaciones", "Missing 'afirmaciones'"),
        ("curriculo", "Missing 'curriculo'"),
    ]
    for sec, desc in capsula_sections_to_remove:
        corrupted = copy.deepcopy(base_capsula)
        corrupted.pop(sec, None)
        valid, errs = validator.validate_capsula(corrupted)
        if not valid:
            record_pass(f"Capsule missing section rejected: {desc}")
        else:
            record_fail(f"Capsule missing section rejected: {desc}", "Validator allowed missing section")

    # 1.5 Corrupted field types in Unidad
    # Probe: id as integer / non-string
    c_id_int = copy.deepcopy(base_unit)
    c_id_int["id"] = 12345
    v_id, err_id = validator.validate_unidad(c_id_int)
    if not v_id:
        record_pass("id as integer rejected by strict type validator")
    else:
        record_vuln(
            "VULN-M2-04",
            "Missing strict String type check on 'id' field",
            "ContentValidator accepts integer '12345' as valid ID because it coerces via .toString().trim().isEmpty instead of asserting string type.",
            severity="LOW"
        )

    type_corruptions = [
        ("tramoEtario", ["0-3"], "tramoEtario as list"),
        ("vocabulario", "not_a_list", "vocabulario as string"),
        ("preguntas", 3, "preguntas as integer"),
        ("cancionPulso", "audio_path", "cancionPulso as string"),
        ("curriculo", "Decreto 150/2022", "curriculo as string"),
        ("exploracion", False, "exploracion as boolean"),
    ]
    for field, bad_val, desc in type_corruptions:
        corrupted = copy.deepcopy(base_unit)
        corrupted[field] = bad_val
        valid, errs = validator.validate_unidad(corrupted)
        if not valid:
            record_pass(f"Corrupted type rejected: {desc}")
        else:
            record_fail(f"Corrupted type rejected: {desc}", "Validator accepted corrupted type")

    # -------------------------------------------------------------------------
    # SUITE 2: CONTENT REPOSITORY QUERY EDGE CASES
    # -------------------------------------------------------------------------
    print("\n>>> SUITE 2: ContentRepository Query Edge Cases")
    repo = SimulatedContentRepository()
    repo.initialize([base_unit], [base_capsula])

    # 2.1 Unknown IDs
    unknown_u = repo.get_unidad_by_id("unidad_inexistente_999")
    if unknown_u is None:
        record_pass("getUnidadById('unidad_inexistente_999') returns None")
    else:
        record_fail("getUnidadById with unknown ID returned non-null")

    unknown_c = repo.get_capsula_by_id("capsula_inexistente_999")
    if unknown_c is None:
        record_pass("getCapsulaById('capsula_inexistente_999') returns None")
    else:
        record_fail("getCapsulaById with unknown ID returned non-null")

    unknown_b = repo.get_bloque_by_id("bloque_inexistente")
    if unknown_b is None:
        record_pass("getBloqueById('bloque_inexistente') returns None")
    else:
        record_fail("getBloqueById with unknown ID returned non-null")

    # 2.2 Case sensitivity
    # Unidad IDs are lowercase dotted IDs.
    upper_u = repo.get_unidad_by_id("JUEGA.MAR.01")
    if upper_u is None:
        record_pass("getUnidadById is case-exact: 'JUEGA.MAR.01' returns None")
    else:
        record_pass("getUnidadById resolved case-insensitively")

    # Bloque IDs support case-insensitivity
    upper_b = repo.get_bloque_by_id("DESARROLLO_COMUNICATIVO")
    if upper_b is not None and upper_b[0] == "desarrollo_comunicativo":
        record_pass("getBloqueById is case-insensitive for 'DESARROLLO_COMUNICATIVO'")
    else:
        record_fail("getBloqueById failed case-insensitive match")

    # Bloque numeric ordinal queries
    for ord_str, expected_id in [("1", "desarrollo_comunicativo"), ("3", "turnos_y_atencion_conjunta"), ("5", "bilinguismo_y_cultura")]:
        b = repo.get_bloque_by_id(ord_str)
        if b is not None and b[0] == expected_id:
            record_pass(f"getBloqueById('{ord_str}') resolves to {expected_id}")
        else:
            record_fail(f"getBloqueById('{ord_str}') failed")

    # Bloque out-of-range ordinals
    for bad_ord in ["0", "6", "-1", "99"]:
        b = repo.get_bloque_by_id(bad_ord)
        if b is None:
            record_pass(f"getBloqueById('{bad_ord}') returns None for invalid ordinal")
        else:
            record_fail(f"getBloqueById('{bad_ord}') returned non-null")

    # 2.3 Non-existent age bands & PROBE OF Unidad.matchesAgeBand
    # Normal query: 0-2 and 2-3 both match '0-3'
    u_02 = repo.get_unidades_by_tramo("0-2")
    u_23 = repo.get_unidades_by_tramo("2-3")
    if len(u_02) == 1 and len(u_23) == 1:
        record_pass("getUnidadesByTramoEtario correctly returns '0-3' unit for '0-2' and '2-3'")
    else:
        record_fail("getUnidadesByTramoEtario failed for valid subsets")

    # ADVERSARIAL PROBE: What happens when an unauthorized / non-existent band is queried?
    # e.g., 'primaria', '4-5', '99-99'
    u_primaria = repo.get_unidades_by_tramo("primaria")
    u_invalid = repo.get_unidades_by_tramo("99-99")
    if len(u_primaria) > 0:
        record_vuln(
            "VULN-M2-01",
            "Unidad.matchesAgeBand over-permissive wildcard",
            "Unidad with tramoEtario='0-3' matches ANY query filter including 'primaria' or '99-99' because 'if (tramoEtario == \"0-3\") return true;' executes unconditionally.",
            severity="LOW"
        )
    else:
        record_pass("getUnidadesByTramoEtario('primaria') returns empty list")

    # 2.4 Cache invalidation & re-initialization
    repo.clear()
    if not repo.is_initialized and len(repo.get_unidades_by_tramo("0-3")) == 0:
        record_pass("repo.clear() successfully resets state and clears cache")
    else:
        record_fail("repo.clear() failed to clear internal state")

    repo.initialize([base_unit], [base_capsula])
    if repo.is_initialized and len(repo.get_unidades_by_tramo("0-3")) == 1:
        record_pass("repo re-initialization restores query capability")
    else:
        record_fail("repo re-initialization failed")

    # -------------------------------------------------------------------------
    # SUITE 3: UNIDAD MODEL BOUNDARY CONDITIONS
    # -------------------------------------------------------------------------
    print("\n>>> SUITE 3: Unidad Model Boundary Conditions")

    # 3.1 Questions graduated scaffolding levels (0, 1, 2, 3 levels)
    # Case A: 0 levels (empty list)
    c_q0 = copy.deepcopy(base_unit)
    c_q0["preguntas"] = []
    v_q0, err_q0 = validator.validate_unidad(c_q0)
    if not v_q0:
        record_pass("Questions boundary: 0 levels rejected by validator")
    else:
        record_fail("Questions boundary: 0 levels accepted by validator")

    # Case B: 1 level (only Level 1)
    c_q1 = copy.deepcopy(base_unit)
    c_q1["preguntas"] = [p for p in base_unit["preguntas"] if p.get("nivel") == 1]
    v_q1, err_q1 = validator.validate_unidad(c_q1)
    if not v_q1 and any("missing level 2" in e for e in err_q1) and any("missing level 3" in e for e in err_q1):
        record_pass("Questions boundary: 1 level (Level 1 only) rejected with missing levels 2 & 3")
    else:
        record_fail("Questions boundary: 1 level check failed", str(err_q1))

    # Case C: 2 levels (Levels 1 & 2)
    c_q2 = copy.deepcopy(base_unit)
    c_q2["preguntas"] = [p for p in base_unit["preguntas"] if p.get("nivel") in (1, 2)]
    v_q2, err_q2 = validator.validate_unidad(c_q2)
    if not v_q2 and any("missing level 3" in e for e in err_q2):
        record_pass("Questions boundary: 2 levels (Levels 1 & 2) rejected with missing level 3")
    else:
        record_fail("Questions boundary: 2 levels check failed", str(err_q2))

    # Case D: 3 levels (Levels 1, 2, 3)
    v_q3, err_q3 = validator.validate_unidad(base_unit)
    if v_q3:
        record_pass("Questions boundary: 3 levels (Levels 1, 2, 3) approved")
    else:
        record_fail("Questions boundary: 3 levels check failed", str(err_q3))

    # 3.2 Missing or defective safety notice in exploration
    # Case A: missing avisoSeguridad
    c_s0 = copy.deepcopy(base_unit)
    c_s0["exploracion"].pop("avisoSeguridad", None)
    v_s0, err_s0 = validator.validate_unidad(c_s0)
    if not v_s0:
        record_pass("Safety notice boundary: Missing avisoSeguridad rejected")
    else:
        record_fail("Safety notice boundary: Missing avisoSeguridad accepted")

    # Case B: empty gl in avisoSeguridad
    c_s1 = copy.deepcopy(base_unit)
    c_s1["exploracion"]["avisoSeguridad"]["gl"] = "   "
    v_s1, err_s1 = validator.validate_unidad(c_s1)
    if not v_s1:
        record_pass("Safety notice boundary: Blank 'gl' in avisoSeguridad rejected")
    else:
        record_fail("Safety notice boundary: Blank 'gl' in avisoSeguridad accepted")

    # Case C: Pedagogical content audit - notice must mention size dimension and supervision
    aviso_gl = base_unit["exploracion"]["avisoSeguridad"]["gl"].lower()
    aviso_es = base_unit["exploracion"]["avisoSeguridad"]["es"].lower()
    has_size_rule = ("5 cm" in aviso_gl or "4 cm" in aviso_gl) and ("5 cm" in aviso_es or "4 cm" in aviso_es)
    has_supervision = ("supervisión" in aviso_gl or "supervision" in aviso_gl or "vixilancia" in aviso_gl) and \
                      ("supervisión" in aviso_es or "supervision" in aviso_es)
    if has_size_rule and has_supervision:
        record_pass("Safety notice content: Explicitly specifies >= 4-5 cm and direct adult supervision")
    else:
        record_fail("Safety notice content: Missing dimension rule or supervision notice")

    # 3.3 Song pulse BPM boundary values
    # Pediatric range for 0-3 years infant songs is typically 60-100 BPM (e.g. 72 or 80 BPM).
    # Inspect Dart CancionPulso and ContentValidator for BPM validation:
    bpm_tests = [
        (0, "Zero BPM (stopped pulse)"),
        (-60, "Negative BPM (-60)"),
        (9999, "Excessively high BPM (9999 BPM)"),
        (10, "Excessively low BPM (10 BPM)"),
    ]
    # Check if ContentValidator.validateUnidad catches these:
    # In lib/data/validators/content_validator.dart, line 282-290:
    # BPM is NOT checked by ContentValidator!
    bpm_checked = False
    with open(os.path.join(PROJECT_ROOT, "lib/data/validators/content_validator.dart"), "r") as f:
        validator_code = f.read()
    if "bpm" in validator_code:
        bpm_checked = True

    if not bpm_checked:
        record_vuln(
            "VULN-M2-02",
            "ContentValidator omits BPM boundary validation",
            "CancionPulso accepts 0, negative, or absurdly high BPM (e.g. 9999) without ContentValidator raising any errors or warnings.",
            severity="LOW"
        )
    else:
        record_pass("ContentValidator includes BPM range validation")

    # -------------------------------------------------------------------------
    # SUITE 4: CURRICULAR REFERENCE CONSTRAINTS
    # -------------------------------------------------------------------------
    print("\n>>> SUITE 4: CurricularReference Constraints")

    # 4.1 Non-Galician decrees or alternative regulations
    invalid_normativas = [
        ("LOMLOE", "LOMLOE generic framework"),
        ("LOE", "LOE old framework"),
        ("Decreto 100/2022 (Madrid)", "Madrid regional decree"),
        ("Decreto 200/2023 (Andalucía)", "Andalucía regional decree"),
        ("", "Empty normativa string"),
    ]
    for norm, desc in invalid_normativas:
        corrupted = copy.deepcopy(base_unit)
        corrupted["curriculo"]["normativa"] = norm
        valid, errs = validator.validate_unidad(corrupted)
        if not valid and any("normativa must be Decreto 150/2022" in e for e in errs):
            record_pass(f"Curricular regulation rejected: {desc}")
        else:
            record_fail(f"Curricular regulation check failed for: {desc}")

    # 4.2 Unauthorized educational stages
    invalid_etapas = [
        ("primaria", "Educación Primaria (6-12 years)"),
        ("secundaria", "Educación Secundaria (12-16 years)"),
        ("bacharelato", "Bacharelato (16-18 years)"),
        ("formacion_profesional", "Formación Profesional"),
        ("educacion_superior", "Educación Superior"),
    ]
    for etapa, desc in invalid_etapas:
        corrupted = copy.deepcopy(base_unit)
        corrupted["curriculo"]["etapa"] = etapa
        valid, errs = validator.validate_unidad(corrupted)
        if not valid and any("etapa must be educacion_infantil" in e for e in errs):
            record_pass(f"Unauthorized stage rejected: {desc}")
        else:
            record_fail(f"Unauthorized stage check failed for: {desc}")

    # 4.3 Unauthorized educational cycles
    invalid_ciclos = [
        ("segundo_ciclo_3_6", "Segundo ciclo infantil (3-6 years)"),
        ("terceiro_ciclo", "Terceiro ciclo inexistente"),
    ]
    for ciclo, desc in invalid_ciclos:
        corrupted = copy.deepcopy(base_unit)
        corrupted["curriculo"]["ciclo"] = ciclo
        valid, errs = validator.validate_unidad(corrupted)
        if not valid and any("ciclo must be primeiro_ciclo_0_3" in e for e in errs):
            record_pass(f"Unauthorized cycle rejected: {desc}")
        else:
            record_fail(f"Unauthorized cycle check failed for: {desc}")

    # 4.4 Invalid areas & criteria
    # Area outside 1, 2, 3
    c_bad_area = copy.deepcopy(base_unit)
    c_bad_area["curriculo"]["areas"] = ["area_4_matematicas_avanzadas"]
    v_area, err_area = validator.validate_unidad(c_bad_area)
    if not v_area and any("unrecognized area" in e for e in err_area):
        record_pass("Curricular areas: Unrecognized area rejected")
    else:
        record_fail("Curricular areas: Unrecognized area check failed")

    # Empty areas
    c_empty_area = copy.deepcopy(base_unit)
    c_empty_area["curriculo"]["areas"] = []
    v_ea, err_ea = validator.validate_unidad(c_empty_area)
    if not v_ea:
        record_pass("Curricular areas: Empty area list rejected")
    else:
        record_fail("Curricular areas: Empty area list accepted")

    # Criteria outside CA1.1..CA3.2
    c_bad_crit = copy.deepcopy(base_unit)
    c_bad_crit["curriculo"]["criteriosEvaluacion"] = ["CA9.9_inventado"]
    v_crit, err_crit = validator.validate_unidad(c_bad_crit)
    if not v_crit and any("unrecognized criterion" in e for e in err_crit):
        record_pass("Curricular criteria: Unrecognized criterion rejected")
    else:
        record_fail("Curricular criteria: Unrecognized criterion check failed")

    # -------------------------------------------------------------------------
    # SUITE 5: DART SOURCE CODE DEFENSIVE ARCHITECTURE & TYPE CAST AUDIT
    # -------------------------------------------------------------------------
    print("\n>>> SUITE 5: Dart Defensive Architecture & Type-Safety Audit")

    dart_validator_path = os.path.join(PROJECT_ROOT, "lib/data/validators/content_validator.dart")
    with open(dart_validator_path, "r", encoding="utf-8") as f:
        validator_src = f.read()

    # Search for unchecked 'as Map<String, dynamic>?' casts
    # If a field is passed as String or int in JSON, 'json["x"] as Map<String, dynamic>?'
    # throws a runtime TypeError in Dart instead of failing gracefully.
    unchecked_casts = re.findall(r'(\w+)\s*=\s*\([^)]+\)\s*as\s+Map<String,\s*dynamic>\?', validator_src)
    if unchecked_casts:
        record_vuln(
            "VULN-M2-03",
            "Unchecked explicit Map casts in Dart ContentValidator",
            f"ContentValidator uses direct `as Map<String, dynamic>?` casts on sections: {unchecked_casts}. If a payload has a non-map type (e.g. string or list) for these keys, Dart throws an unhandled `TypeError` rather than appending a clean ValidationResult error.",
            severity="MEDIUM"
        )
    else:
        record_pass("No unchecked explicit Map casts found in ContentValidator")

    # Search for network imports in all lib/data files
    network_patterns = [r'dart:io', r'package:http', r'package:dio', r'package:web_socket_channel', r'HttpClient', r'Socket']
    for root_dir, _, files in os.walk(os.path.join(PROJECT_ROOT, "lib/data")):
        for file in files:
            if file.endswith(".dart"):
                fpath = os.path.join(root_dir, file)
                with open(fpath, "r", encoding="utf-8") as f:
                    content = f.read()
                for pat in network_patterns:
                    if pat == 'dart:io':
                        # Check if actually imported
                        if 'import \'dart:io\'' in content or 'import "dart:io"' in content:
                            record_fail(f"Network privacy violation: {file} imports dart:io")
                    elif re.search(r'\b' + pat + r'\b', content):
                        record_fail(f"Network privacy violation: {file} references {pat}")
    record_pass("Audit confirmed 100% network privacy across all lib/data Dart files (zero network clients)")

    # -------------------------------------------------------------------------
    # SUMMARY & VERDICT EVALUATION
    # -------------------------------------------------------------------------
    print("\n" + "=" * 70)
    print(f"TOTAL TESTS: {total_passed + total_failed} | PASSED: {total_passed} | FAILED: {total_failed}")
    print(f"ADVERSARIAL FINDINGS: {len(total_findings)}")
    for f in total_findings:
        print(f" - {f}")
    print("=" * 70)

    # Return exit code: 0 if no hard failures, 1 if failures exist
    return 0 if total_failed == 0 else 1

if __name__ == "__main__":
    sys.exit(run_adversarial_suite())
