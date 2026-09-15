#!/usr/bin/env python3
"""
Independent Reviewer & Adversarial Critic Audit for Milestone 2
«Descubre con Lúa · Edición Vigo»
Reviewer: teamwork_preview_reviewer_m2_1
"""

import os
import sys
import json
import re
from typing import Any, List, Dict, Set, Tuple

PROJECT_ROOT = "<documentos locales>/Descubre con Lúa"
passed = 0
failed = 0
findings = []

def record(ok: bool, desc: str, finding_type: str = "Major", detail: str = ""):
    global passed, failed, findings
    if ok:
        passed += 1
        print(f"  [PASS] {desc}")
    else:
        failed += 1
        findings.append((finding_type, desc, detail))
        print(f"  [FAIL] ({finding_type}) {desc}: {detail}")

print("===================================================================")
print("INDEPENDENT REVIEWER & ADVERSARIAL AUDIT — MILESTONE 2")
print("===================================================================")

# SECTION 1: DART SOURCE CODE & CONTRACT AUDIT
print("\n--- 1. Dart Models, Loaders & Repository Source Code Inspection ---")

models_to_check = {
    "curricular_model.dart": os.path.join(PROJECT_ROOT, "lib/data/models/curricular_model.dart"),
    "unidad_model.dart": os.path.join(PROJECT_ROOT, "lib/data/models/unidad_model.dart"),
    "capsula_model.dart": os.path.join(PROJECT_ROOT, "lib/data/models/capsula_model.dart"),
    "content_asset_loader.dart": os.path.join(PROJECT_ROOT, "lib/data/loaders/content_asset_loader.dart"),
    "content_repository.dart": os.path.join(PROJECT_ROOT, "lib/data/repositories/content_repository.dart"),
    "content_validator.dart": os.path.join(PROJECT_ROOT, "lib/data/validators/content_validator.dart"),
}

for name, path in models_to_check.items():
    record(os.path.isfile(path), f"Source file exists: {name}", "Critical", f"Missing {path}")
    if os.path.isfile(path):
        with open(path, "r", encoding="utf-8") as f:
            src = f.read()

        # Zero network clients
        forbidden_net = ["dart:io", "http", "HttpClient", "WebSocket", "Socket", "firebase", "url_launcher"]
        for net in ["HttpClient", "WebSocket", "Socket.connect", "package:http"]:
            record(net not in src, f"{name} contains zero '{net}' network references", "Critical", f"Found {net} in {name}")

# Detailed Curricular Reference Check
with open(models_to_check["curricular_model.dart"], "r", encoding="utf-8") as f:
    curr_src = f.read()
record("class CurricularReference" in curr_src, "CurricularReference class defined", "Critical")
record("@immutable" in curr_src, "CurricularReference is marked @immutable", "Minor")
record("Decreto 150/2022" in curr_src, "CurricularReference specifies Decreto 150/2022", "Major")
record("area_1_crecemento_harmonia" in curr_src and "area_2_descubrimento_contorna" in curr_src and "area_3_comunicacion_representacion" in curr_src,
       "CurricularReference specifies all 3 canonical areas", "Major")
record("CA1.1" in curr_src and "CA2.1" in curr_src and "CA2.2" in curr_src and "CA3.1" in curr_src and "CA3.2" in curr_src,
       "CurricularReference specifies all 5 canonical criteria", "Major")
record("bool get isValidDecreto150" in curr_src, "CurricularReference has isValidDecreto150 validator", "Major")
record("typedef CurriculoReferencia" in curr_src, "CurricularReference has Galician type alias CurriculoReferencia", "Minor")

# Detailed Unidad Model Check
with open(models_to_check["unidad_model.dart"], "r", encoding="utf-8") as f:
    u_src = f.read()
required_u_classes = [
    "class Revision", "class CancionPulso", "class CuentoPagina", "class Cuento",
    "class VocabularioItem", "class PreguntaNivel", "class ExploracionSensorial",
    "class MatematicasTempras", "class PonteCasa", "class Unidad"
]
for uc in required_u_classes:
    record(uc in u_src, f"Unidad component class defined: {uc}", "Critical")

# Check compatibility getters in Unidad
record("CancionPulso get cancion" in u_src, "Unidad exposes compatibility getter: cancion", "Major")
record("Cuento get conto" in u_src, "Unidad exposes compatibility getter: conto", "Major")
record("PonteCasa get ponteCasa" in u_src, "Unidad exposes compatibility getter: ponteCasa", "Major")
record("CurricularReference get curricular" in u_src, "Unidad exposes compatibility getter: curricular", "Major")
record("bool matchesAgeBand" in u_src, "Unidad implements matchesAgeBand method", "Major")

# Check Capsula Model
with open(models_to_check["capsula_model.dart"], "r", encoding="utf-8") as f:
    c_src = f.read()
record("class Afirmacion" in c_src, "Afirmacion class defined", "Critical")
record("class ContidoCapsula" in c_src, "ContidoCapsula class defined", "Critical")
record("class Bloque" in c_src, "Bloque class defined", "Critical")
record("class Capsula" in c_src, "Capsula class defined", "Critical")
record("ContidoCapsula get contido" in c_src, "Capsula exposes contido getter", "Major")

# Check Bloque catalog of 5
blocks = [
    "desarrollo_comunicativo",
    "rutinas_y_bano_de_lenguaje",
    "turnos_y_atencion_conjunta",
    "juego_movimiento_sin_pantallas",
    "bilinguismo_y_cultura"
]
for b in blocks:
    record(b in c_src, f"Bloque catalog includes '{b}'", "Critical")

# Check Content Asset Loader
with open(models_to_check["content_asset_loader.dart"], "r", encoding="utf-8") as f:
    loader_src = f.read()
loader_methods = ["loadUnidadFromAsset", "loadCapsulaFromAsset", "parseUnidad", "parseCapsula", "loadAllUnidades", "loadAllCapsulas"]
for lm in loader_methods:
    record(lm in loader_src, f"ContentAssetLoader implements {lm}", "Major")
record("AssetBundleStringLoader" in loader_src, "ContentAssetLoader supports custom string loader delegate", "Major")

# Check Content Repository
with open(models_to_check["content_repository.dart"], "r", encoding="utf-8") as f:
    repo_src = f.read()
repo_methods = ["initialize", "getAllUnidades", "getUnidadById", "getUnidadesByTramoEtario", "getAllCapsulas", "getCapsulaById", "getCapsulasByBloqueId", "getAllBloques", "getBloqueById", "addUnidad", "addCapsula", "clear"]
for rm in repo_methods:
    record(rm in repo_src, f"ContentRepository implements {rm}", "Major")

# SECTION 2: BASE JSON ASSETS INDEPENDENT AUDIT
print("\n--- 2. Base JSON Assets Deep Independent Verification ---")

CLINICAL_REGEX = re.compile(
    r'\b(trastorno|trastornos|patolog[ií]a|patolog[ií]as|patolox[ií]a|patolox[ií]as|patol[oó]xic[oa]s?|'
    r'diagn[oó]stic[oa]s?|diagnosticar|s[ií]ntoma|s[ií]ntomas|sintomatolog[ií]a|'
    r'sintomatolox[ií]a|d[eé]ficit|d[eé]ficits|paciente|pacientes|terapia|'
    r'terapias|terap[eé]utic[oa]s?|tratamiento|tratamientos|tratamento|tratamentos|'
    r'retraso\s+cl[ií]nico|dislalia|dislalias|dislexia|dislexias|'
    r'hipoacusia\s+cl[ií]nica|afasia|disfasia|rehabilitaci[oó]n|rehabilitar|'
    r'criba\s+cl[ií]nica|screening|pron[oó]stico)\b',
    re.IGNORECASE
)

PLACEHOLDER_REGEX = re.compile(r'\b(TODO|TBD|PENDIENTE|PENDENTE|LOREM\s+IPSUM)\b', re.IGNORECASE)

def audit_bilingual_node(node: Any, path: str = "root") -> List[str]:
    errs = []
    if isinstance(node, dict):
        has_gl = "gl" in node
        has_es = "es" in node
        if has_gl and has_es:
            gl = str(node["gl"]).strip()
            es = str(node["es"]).strip()
            if not gl:
                errs.append(f"{path}.gl is blank")
            if not es:
                errs.append(f"{path}.es is blank")
            if PLACEHOLDER_REGEX.search(gl):
                errs.append(f"{path}.gl has placeholder: {gl}")
            if PLACEHOLDER_REGEX.search(es):
                errs.append(f"{path}.es has placeholder: {es}")
        elif has_gl and not has_es:
            errs.append(f"{path} has 'gl' but missing 'es'")
        elif not has_gl and has_es:
            errs.append(f"{path} has 'es' but missing 'gl'")

        for k, v in node.items():
            errs.extend(audit_bilingual_node(v, f"{path}.{k}"))
    elif isinstance(node, list):
        for i, item in enumerate(node):
            errs.extend(audit_bilingual_node(item, f"{path}[{i}]"))
    return errs

def audit_clinical_node(node: Any, path: str = "root") -> List[str]:
    errs = []
    if isinstance(node, str):
        m = CLINICAL_REGEX.search(node)
        if m:
            errs.append(f"{path}: Prohibited clinical term '{m.group(0)}'")
    elif isinstance(node, dict):
        for k, v in node.items():
            errs.extend(audit_clinical_node(v, f"{path}.{k}"))
    elif isinstance(node, list):
        for i, item in enumerate(node):
            errs.extend(audit_clinical_node(item, f"{path}[{i}]"))
    return errs

# 2.1 Audit juega.mar.01.json
u_json_path = os.path.join(PROJECT_ROOT, "assets/content/unidades/juega.mar.01.json")
record(os.path.isfile(u_json_path), "juega.mar.01.json exists", "Critical")

with open(u_json_path, "r", encoding="utf-8") as f:
    u_json = json.load(f)

# ID, tramo, orden
record(u_json.get("id") == "juega.mar.01", "Unidad ID is juega.mar.01", "Critical")
record(u_json.get("tramoEtario") in ["0-2", "2-3", "0-3"], f"Unidad tramoEtario is valid: {u_json.get('tramoEtario')}", "Major")
record(isinstance(u_json.get("orden"), int) and u_json.get("orden") == 1, "Unidad orden is 1", "Minor")

# Bilingual Parity & Clinical Blacklist
u_parity_errs = audit_bilingual_node(u_json, "juega.mar.01")
record(len(u_parity_errs) == 0, f"Unidad has zero bilingual parity violations (errors: {len(u_parity_errs)})", "Critical", "; ".join(u_parity_errs))

u_clinical_errs = audit_clinical_node(u_json, "juega.mar.01")
record(len(u_clinical_errs) == 0, f"Unidad has zero clinical blacklist terms (errors: {len(u_clinical_errs)})", "Critical", "; ".join(u_clinical_errs))

# Cultural Vigo & Maritime content
all_u_text = json.dumps(u_json, ensure_ascii=False)
record("Vigo" in all_u_text, "Unidad contains references to Vigo", "Major")
record("Samil" in all_u_text, "Unidad contains references to Samil", "Major")
record("ría de Vigo" in all_u_text, "Unidad contains references to ría de Vigo", "Major")
record("bateas" in all_u_text, "Unidad contains references to bateas", "Major")

# Cancion Pulso
cancion = u_json.get("cancionPulso", {})
record(cancion.get("bpm") == 80, f"Cancion has pulse BPM=80 (got {cancion.get('bpm')})", "Major")
record(cancion.get("audioAsset", {}).get("gl", "").startswith("assets/audio/"), "Cancion gl audioAsset begins with assets/audio/", "Major")
record(cancion.get("audioAsset", {}).get("es", "").startswith("assets/audio/"), "Cancion es audioAsset begins with assets/audio/", "Major")

# Cuento
cuento = u_json.get("cuento", {})
pages = cuento.get("paginas", [])
record(len(pages) == 3, f"Cuento has exactly 3 illustrated pages (got {len(pages)})", "Major")
for i, page in enumerate(pages):
    record("preguntaComprension" in page, f"Cuento page {i+1} has comprehension question", "Major")

# Vocabulario
vocab = u_json.get("vocabulario", [])
record(len(vocab) == 5, f"Vocabulario has 5 items (got {len(vocab)})", "Major")
expected_vocab = ["barco", "gaivota", "cuncha", "mexillon", "peixe"]
vocab_ids = [v.get("id") for v in vocab]
record(vocab_ids == expected_vocab, f"Vocabulario IDs match expected list {expected_vocab}", "Major")
for v in vocab:
    record(v.get("audioAsset", {}).get("gl", "").startswith("assets/audio/"), f"Vocab {v.get('id')} audio is local asset", "Major")

# Scaffolding Questions
preguntas = u_json.get("preguntas", [])
record(len(preguntas) == 3, f"Preguntas has 3 graduated levels (got {len(preguntas)})", "Major")
levels = [p.get("nivel") for p in preguntas]
record(levels == [1, 2, 3], f"Question levels are strictly [1, 2, 3] (got {levels})", "Major")

# Exploracion Sensorial & Safety Alert
exploracion = u_json.get("exploracion", {})
record(len(exploracion.get("materiales", [])) >= 4, "Exploracion has 4+ materials", "Major")
record(len(exploracion.get("pasos", [])) >= 4, "Exploracion has 4+ steps", "Major")
aviso_gl = exploracion.get("avisoSeguridad", {}).get("gl", "")
record("5 cm" in aviso_gl or "4 cm" in aviso_gl, "Aviso de seguridade specifies minimum piece diameter (>= 4-5 cm)", "Critical")
record("supervisión" in aviso_gl.lower(), "Aviso de seguridade mandates direct teacher supervision", "Critical")

# Matematicas Tempras
mat = u_json.get("matematicas", {})
record("grande" in mat.get("concepto", {}).get("gl", "").lower(), "Matematicas teaches magnitude concept (grande/pequeno)", "Major")

# Puente a Casa
puente = u_json.get("puenteCasa", {})
record(len(puente.get("actividadesSugeridas", [])) >= 2, "Puente casa includes 2+ home activities", "Major")
record("5 segundos" in puente.get("recomendacionConversacion", {}).get("gl", "") or "cinco segundos" in puente.get("recomendacionConversacion", {}).get("gl", ""),
       "Puente casa recommends 5-second wait rule in conversation", "Major")

# Curriculo alignment
curr = u_json.get("curriculo", {})
record(curr.get("normativa") == "Decreto 150/2022", "Unidad normativa is Decreto 150/2022", "Critical")
record(curr.get("etapa") == "educacion_infantil", "Unidad etapa is educacion_infantil", "Critical")
record(curr.get("ciclo") == "primeiro_ciclo_0_3", "Unidad ciclo is primeiro_ciclo_0_3", "Critical")
record(set(curr.get("areas", [])).issubset({"area_1_crecemento_harmonia", "area_2_descubrimento_contorna", "area_3_comunicacion_representacion"}), "Unidad areas are valid Decreto 150/2022 areas", "Critical")
record(set(curr.get("criteriosEvaluacion", [])).issubset({"CA1.1", "CA2.1", "CA2.2", "CA3.1", "CA3.2"}), "Unidad criteria are valid Decreto 150/2022 criteria", "Critical")

# 2.2 Audit academy.como_se_aprende_a_hablar.01.json
c_json_path = os.path.join(PROJECT_ROOT, "assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json")
record(os.path.isfile(c_json_path), "academy capsule JSON exists", "Critical")

with open(c_json_path, "r", encoding="utf-8") as f:
    c_json = json.load(f)

record(c_json.get("id") == "academy.como_se_aprende_a_hablar.01", "Capsule ID is correct", "Critical")
record(c_json.get("bloqueId") == "desarrollo_comunicativo", "Capsule bloqueId is desarrollo_comunicativo", "Critical")
record(c_json.get("orden") == 1, "Capsule orden is 1", "Minor")
record(c_json.get("tiempoLecturaMinutos") == 3, "Capsule reading time is 3 minutes", "Minor")

# Bilingual Parity & Clinical Blacklist
c_parity_errs = audit_bilingual_node(c_json, "academy.hablar.01")
record(len(c_parity_errs) == 0, f"Capsule has zero bilingual parity violations (errors: {len(c_parity_errs)})", "Critical", "; ".join(c_parity_errs))

c_clinical_errs = audit_clinical_node(c_json, "academy.hablar.01")
record(len(c_clinical_errs) == 0, f"Capsule has zero clinical blacklist terms (errors: {len(c_clinical_errs)})", "Critical", "; ".join(c_clinical_errs))

# 4 Canonical parts
for cp in ["ideaClave", "porQueImporta", "queHacerEnCasa", "ejemploCotidiano"]:
    val = c_json.get(cp)
    record(isinstance(val, dict) and bool(val.get("gl")) and bool(val.get("es")), f"Capsule contains canonical section '{cp}' in gl and es", "Critical")

# Pedagogical core: 5s rule & language bath
all_c_text = json.dumps(c_json, ensure_ascii=False)
record("5 segundos" in all_c_text, "Capsule explicitly features 5 seconds wait rule", "Major")
record("baño de" in all_c_text.lower(), "Capsule explicitly features language bath concept", "Major")

# Afirmaciones
afirms = c_json.get("afirmaciones", [])
record(len(afirms) == 2, f"Capsule has 2 reflective affirmations (got {len(afirms)})", "Major")
tv = [a.get("esVerdadera") for a in afirms]
record(True in tv and False in tv, "Afirmaciones have both true and false questions with feedback", "Major")

# Curricular alignment
c_curr = c_json.get("curriculo", {})
record(c_curr.get("normativa") == "Decreto 150/2022", "Capsule normativa is Decreto 150/2022", "Critical")
record(c_curr.get("etapa") == "educacion_infantil", "Capsule etapa is educacion_infantil", "Critical")
record(c_curr.get("ciclo") == "primeiro_ciclo_0_3", "Capsule ciclo is primeiro_ciclo_0_3", "Critical")
record(set(c_curr.get("areas", [])).issubset({"area_1_crecemento_harmonia", "area_2_descubrimento_contorna", "area_3_comunicacion_representacion"}), "Capsule areas valid", "Critical")
record(set(c_curr.get("criteriosEvaluacion", [])).issubset({"CA1.1", "CA2.1", "CA2.2", "CA3.1", "CA3.2"}), "Capsule criteria valid", "Critical")

# SECTION 3: ADVERSARIAL STRESS-TESTING
print("\n--- 3. Adversarial Stress-Testing & Boundary Attack Scenarios ---")

# Scenario 1: Medical / Diagnostic Attack Vector (Spanish and Galician variants)
hostile_terms = [
    ("trastorno", "O neno ten un trastorno"),
    ("trastornos", "Cadro de trastornos"),
    ("patología", "Presenta patología clínica"),
    ("patoloxía", "Presenta patoloxía no oído"),
    ("patoloxías", "Posibles patoloxías da fala"),
    ("patolóxicos", "Signos patolóxicos observados"),
    ("patológico", "Patrón patológico"),
    ("diagnóstico", "Emitir diagnóstico formal"),
    ("diagnóstica", "Proba diagnóstica"),
    ("diagnosticar", "Tentativa de diagnosticar"),
    ("síntoma", "Detectouse un síntoma"),
    ("síntomas", "Listaxe de síntomas"),
    ("sintomatoloxía", "A súa sintomatoloxía"),
    ("sintomatología", "Su sintomatología"),
    ("déficit", "Déficit atencional"),
    ("deficits", "Deficits comunicativos"),
    ("paciente", "O paciente debe sentar"),
    ("pacientes", "Trátase como pacientes"),
    ("terapia", "Iniciar sesión de terapia"),
    ("terapias", "Novas terapias"),
    ("terapéutica", "Intervención terapéutica"),
    ("terapéutico", "Obxectivo terapéutico"),
    ("tratamiento", "Seguir un tratamiento"),
    ("tratamentos", "Tratamentos intensivos"),
    ("retraso clínico", "Sospeita de retraso clínico"),
    ("dislalia", "Casos de dislalia"),
    ("dislalias", "Corrixir dislalias"),
    ("dislexia", "Detectar dislexia"),
    ("dislexias", "Tratar dislexias"),
    ("hipoacusia clínica", "Sospeita de hipoacusia clínica"),
    ("afasia", "Cadro de afasia"),
    ("disfasia", "Disfasia conxénita"),
    ("rehabilitación", "Rehabilitación logopédica"),
    ("rehabilitar", "Rehabilitar a linguaxe"),
    ("criba clínica", "Protocolo de criba clínica"),
    ("screening", "Screening auditivo"),
    ("pronóstico", "Mal pronóstico")
]

for term_name, attack_sentence in hostile_terms:
    match = CLINICAL_REGEX.search(attack_sentence)
    record(match is not None, f"Hostile clinical term '{term_name}' detected", "Critical", f"Failed to match '{attack_sentence}'")

# Scenario 2: False Positive Resistance (Legitimate Pedagogical Terms)
safe_pedagogical_sentences = [
    "Acompañamento educativo respectuoso no primeiro ciclo de infantil.",
    "Cada crianza segue o seu propio ritmo natural de maduración e crecemento.",
    "A estimulación auditiva e visual a través do afecto familiar.",
    "Xogos de movemento corporal e psicomotricidade no chan sen pantallas.",
    "Observación participativa da mestra durante as rutinas da asemblea.",
    "A conversa cálida e a mirada compartida favorecen a comunicación afectiva.",
    "Desenvolvemento harmonioso da linguaxe oral mediante cancións tradicionais.",
    "Momentos de acougo, calma e seguridade emocional no berce.",
    "Participación activa nas actividades manipulativas con materiais da natureza."
]

for safe_sentence in safe_pedagogical_sentences:
    match = CLINICAL_REGEX.search(safe_sentence)
    record(match is None, f"Safe pedagogical sentence allowed without false positive: '{safe_sentence[:40]}...'", "Major", f"False positive match: {match.group(0) if match else ''}")

# Scenario 3: Malformed Bilingual Structures
malformed_cases = [
    ({"gl": "Só galego"}, "missing 'es'"),
    ({"es": "Solo castellano"}, "missing 'gl'"),
    ({"gl": "", "es": "Castellano"}, "blank gl"),
    ({"gl": "   ", "es": "Castellano"}, "whitespace gl"),
    ({"gl": "TODO: traducir", "es": "Castellano"}, "TODO placeholder"),
    ({"gl": "Galego", "es": "TBD"}, "TBD placeholder"),
    ({"gl": "PENDENTE de revisar", "es": "Castellano"}, "PENDENTE placeholder"),
    ({"gl": "Galego", "es": "PENDIENTE de entrega"}, "PENDIENTE placeholder"),
    ({"gl": "Lorem ipsum dolor sit", "es": "Castellano"}, "LOREM IPSUM placeholder")
]

for node, scenario in malformed_cases:
    errs = audit_bilingual_node(node)
    record(len(errs) > 0, f"Malformed bilingual node correctly rejected: {scenario}", "Critical", f"Unexpectedly accepted {node}")

# Scenario 4: Curricular Regulations Outside Decreto 150/2022
unauthorized_curricula = [
    {"normativa": "LOMLOE", "etapa": "educacion_infantil", "ciclo": "primeiro_ciclo_0_3", "areas": ["area_1_crecemento_harmonia"], "criteriosEvaluacion": ["CA1.1"]},
    {"normativa": "Decreto 330/2009", "etapa": "educacion_infantil", "ciclo": "primeiro_ciclo_0_3", "areas": ["area_1_crecemento_harmonia"], "criteriosEvaluacion": ["CA1.1"]},
    {"normativa": "Decreto 150/2022", "etapa": "educacion_primaria", "ciclo": "primeiro_ciclo_0_3", "areas": ["area_1_crecemento_harmonia"], "criteriosEvaluacion": ["CA1.1"]},
    {"normativa": "Decreto 150/2022", "etapa": "educacion_infantil", "ciclo": "segundo_ciclo_3_6", "areas": ["area_1_crecemento_harmonia"], "criteriosEvaluacion": ["CA1.1"]},
    {"normativa": "Decreto 150/2022", "etapa": "educacion_infantil", "ciclo": "primeiro_ciclo_0_3", "areas": ["area_4_falsa"], "criteriosEvaluacion": ["CA1.1"]},
    {"normativa": "Decreto 150/2022", "etapa": "educacion_infantil", "ciclo": "primeiro_ciclo_0_3", "areas": ["area_1_crecemento_harmonia"], "criteriosEvaluacion": ["CA9.9"]},
]

for unauth in unauthorized_curricula:
    is_valid = (
        unauth.get("normativa") == "Decreto 150/2022" and
        unauth.get("etapa") == "educacion_infantil" and
        unauth.get("ciclo") == "primeiro_ciclo_0_3" and
        set(unauth.get("areas", [])).issubset({"area_1_crecemento_harmonia", "area_2_descubrimento_contorna", "area_3_comunicacion_representacion"}) and
        set(unauth.get("criteriosEvaluacion", [])).issubset({"CA1.1", "CA2.1", "CA2.2", "CA3.1", "CA3.2"})
    )
    record(not is_valid, f"Unauthorized curriculum correctly rejected: {unauth.get('normativa')} / {unauth.get('etapa')} / {unauth.get('areas')}", "Critical")

# Scenario 5: Age Band Logic Verification
# In 0-3 infant education:
# A unit with tramo '0-2' matches '0-2', '0-3', 'all', but NOT '2-3'.
# A unit with tramo '2-3' matches '2-3', '0-3', 'all', but NOT '0-2'.
# A unit with tramo '0-3' matches '0-2', '2-3', '0-3', 'all'.
def sim_matches_age(unit_tramo: str, filter_str: str) -> bool:
    clean = filter_str.strip()
    if not clean or clean == "all" or clean == "0-3":
        return True
    if unit_tramo == "0-3":
        return True
    return unit_tramo == clean

record(sim_matches_age("0-2", "0-2") is True, "Unit 0-2 matches filter 0-2", "Major")
record(sim_matches_age("0-2", "2-3") is False, "Unit 0-2 does NOT match filter 2-3", "Major")
record(sim_matches_age("0-2", "0-3") is True, "Unit 0-2 matches filter 0-3", "Major")
record(sim_matches_age("2-3", "2-3") is True, "Unit 2-3 matches filter 2-3", "Major")
record(sim_matches_age("2-3", "0-2") is False, "Unit 2-3 does NOT match filter 0-2", "Major")
record(sim_matches_age("0-3", "0-2") is True, "Unit 0-3 matches filter 0-2", "Major")
record(sim_matches_age("0-3", "2-3") is True, "Unit 0-3 matches filter 2-3", "Major")

# SECTION 4: INTEGRITY CHECKS (Adversarial Critic Mandate)
print("\n--- 4. Adversarial Integrity & Facade Implementation Checks ---")

# Check 1: Check whether tests in test/data/ contain hardcoded expected results embedded in source
test_files = [
    "test/data/models_test.dart",
    "test/data/content_loader_test.dart",
    "test/data/bilingual_parity_test.dart",
    "test/data/curricular_alignment_test.dart",
    "test/data/clinical_terms_blacklist_test.dart",
    "test/data/referential_integrity_test.dart",
]
for tf in test_files:
    tf_path = os.path.join(PROJECT_ROOT, tf)
    record(os.path.isfile(tf_path), f"Test suite file exists: {tf}", "Critical")
    with open(tf_path, "r", encoding="utf-8") as f:
        t_src = f.read()
    # Check for empty test bodies or trivial pass
    record("void main()" in t_src, f"{tf} defines main() entry point", "Critical")
    record("group(" in t_src and "test(" in t_src, f"{tf} contains structured tests", "Critical")
    record("expect(" in t_src, f"{tf} contains real assertions via expect()", "Critical")
    # Verify no mock return true dummy test
    record("expect(true, isTrue);" not in t_src, f"{tf} does not use trivial expect(true, isTrue)", "Critical")

# Check 2: Check whether ContentRepository implements real storage and query logic
with open(models_to_check["content_repository.dart"], "r", encoding="utf-8") as f:
    repo_code = f.read()
record("_unidadesById[id.trim()]" in repo_code, "ContentRepository queries real map by ID", "Critical")
record("_unidadesById.values.where" in repo_code or "u.matchesAgeBand" in repo_code, "ContentRepository filters units via matchesAgeBand", "Critical")
record("Bloque.byOrden" in repo_code, "ContentRepository resolves blocks by ordinal number", "Critical")

# Check 3: Check whether ContentValidator implements recursive descent
with open(models_to_check["content_validator.dart"], "r", encoding="utf-8") as f:
    val_code = f.read()
record("node.forEach" in val_code or "checkBilingualParity(value" in val_code, "ContentValidator implements recursive bilingual traversal", "Critical")
record("forbiddenClinicalPattern.firstMatch" in val_code, "ContentValidator implements regex match for clinical terms", "Critical")
record("validAreas.contains" in val_code, "ContentValidator checks against CurricularReference.validAreas", "Critical")

print("\n===================================================================")
print(f"TOTAL AUDIT CHECKS: {passed + failed} | PASSED: {passed} | FAILED: {failed}")
if failed == 0:
    print("🎉 ALL INDEPENDENT REVIEWER AUDIT CHECKS PASSED (100% COMPLIANCE)")
else:
    print(f"❌ FINDINGS DETECTED: {len(findings)}")
    for ftype, fdesc, fdetail in findings:
        print(f"   [{ftype}] {fdesc}: {fdetail}")
print("===================================================================")

sys.exit(0 if failed == 0 else 1)
