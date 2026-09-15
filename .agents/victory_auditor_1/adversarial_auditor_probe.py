#!/usr/bin/env python3
"""
Independent Post-Victory Auditor Adversarial Probe
Evaluates all requirements R1, R2, R3 and acceptance criteria independently.
"""
import os
import sys
import json
import re
import xml.etree.ElementTree as ET
import wave

PROJECT_ROOT = "<documentos locales>/Descubre con Lúa"

failures = []

def check(condition, message):
    if not condition:
        print(f"❌ FAIL: {message}")
        failures.append(message)
    else:
        print(f"✅ PASS: {message}")

print("==================================================")
print("INDEPENDENT AUDITOR ADVERSARIAL PROBE")
print("==================================================")

# 1. R1: Base Flutter Android setup & Privacy
print("\n--- 1. R1: Android Manifest & Package ID & Privacy ---")
manifest_path = os.path.join(PROJECT_ROOT, "android/app/src/main/AndroidManifest.xml")
check(os.path.exists(manifest_path), "AndroidManifest.xml exists")

tree = ET.parse(manifest_path)
root = tree.getroot()
check(root.attrib.get("package") == "com.earlify.descubreconlua", "Package ID is com.earlify.descubreconlua in AndroidManifest.xml")

gradle_path = os.path.join(PROJECT_ROOT, "android/app/build.gradle")
with open(gradle_path) as f:
    gradle_content = f.read()
check('namespace "com.earlify.descubreconlua"' in gradle_content, "Gradle namespace is com.earlify.descubreconlua")
check('applicationId "com.earlify.descubreconlua"' in gradle_content, "Gradle applicationId is com.earlify.descubreconlua")

# Check permissions in manifest
uses_perms = root.findall("uses-permission")
internet_removed = False
network_state_removed = False
wifi_state_removed = False
positive_perms = []

for p in uses_perms:
    name = p.attrib.get("{http://schemas.android.com/apk/res/android}name", "")
    node = p.attrib.get("{http://schemas.android.com/tools}node", "")
    if name == "android.permission.INTERNET":
        if node == "remove":
            internet_removed = True
        else:
            positive_perms.append(name)
    elif name == "android.permission.ACCESS_NETWORK_STATE":
        if node == "remove":
            network_state_removed = True
        else:
            positive_perms.append(name)
    elif name == "android.permission.ACCESS_WIFI_STATE":
        if node == "remove":
            wifi_state_removed = True
        else:
            positive_perms.append(name)
    else:
        if node != "remove":
            positive_perms.append(name)

check(internet_removed, "android.permission.INTERNET has tools:node='remove'")
check(network_state_removed, "android.permission.ACCESS_NETWORK_STATE has tools:node='remove'")
check(wifi_state_removed, "android.permission.ACCESS_WIFI_STATE has tools:node='remove'")
check(len(positive_perms) == 0, f"No positive permission grants in manifest: {positive_perms}")

# Pubspec zero network packages
print("\n--- 2. R1: Pubspec Dependencies Zero-Network Audit ---")
pubspec_path = os.path.join(PROJECT_ROOT, "pubspec.yaml")
with open(pubspec_path) as f:
    pubspec = f.read()

prohibited_pkgs = [
    "http", "dio", "retrofit", "chopper", "web_socket_channel", "grpc",
    "firebase_core", "firebase_analytics", "firebase_auth", "cloud_firestore",
    "sentry", "sentry_flutter", "datadog_flutter", "mixpanel_flutter",
    "amplitude_flutter", "google_mobile_ads", "socket_io_client"
]
found_pkgs = []
for pkg in prohibited_pkgs:
    if re.search(rf"^\s*{pkg}\s*:", pubspec, re.MULTILINE):
        found_pkgs.append(pkg)
check(len(found_pkgs) == 0, f"Pubspec is free of network packages (found: {found_pkgs})")

# Lib/ zero network calls/imports
print("\n--- 3. R1: lib/ Zero-Network Imports & Symbols ---")
lib_dir = os.path.join(PROJECT_ROOT, "lib")
network_tokens = [
    r"\bHttpClient\b", r"\bSocket\.connect\b", r"\bWebSocket\b",
    r"\bdart:io/http\b", r"package:http/", r"package:dio/", r"package:firebase",
    r"http://", r"https://", r"ws://", r"wss://"
]
lib_files = []
for r, d, files in os.walk(lib_dir):
    for fl in files:
        if fl.endswith(".dart"):
            lib_files.append(os.path.join(r, fl))

check(len(lib_files) >= 15, f"Found {len(lib_files)} Dart files in lib/")

leaks = []
for fpath in lib_files:
    with open(fpath, "r", encoding="utf-8") as f:
        content = f.read()
    rel = os.path.relpath(fpath, PROJECT_ROOT)
    for tok in network_tokens:
        matches = re.findall(tok, content)
        if matches:
            leaks.append(f"{rel}: matched {tok}")

check(len(leaks) == 0, f"lib/ has zero network imports or symbols (leaks: {leaks})")

# R2: Content-as-data layer
print("\n--- 4. R2: Content-as-Data & Parity & Schema ---")
unidades_json_path = os.path.join(PROJECT_ROOT, "assets/content/unidades/juega.mar.01.json")
capsulas_json_path = os.path.join(PROJECT_ROOT, "assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json")

check(os.path.exists(unidades_json_path), "juega.mar.01.json exists")
check(os.path.exists(capsulas_json_path), "academy.como_se_aprende_a_hablar.01.json exists")

with open(unidades_json_path, encoding="utf-8") as f:
    unidad_data = json.load(f)

with open(capsulas_json_path, encoding="utf-8") as f:
    capsula_data = json.load(f)

# Parity checking function
def check_parity(obj, path=""):
    errors = []
    if isinstance(obj, dict):
        if "gl" in obj and "es" in obj and len(obj) == 2:
            gl = str(obj["gl"]).strip()
            es = str(obj["es"]).strip()
            if not gl:
                errors.append(f"{path}: gl is empty")
            if not es:
                errors.append(f"{path}: es is empty")
        else:
            for k, v in obj.items():
                errors.extend(check_parity(v, f"{path}.{k}" if path else k))
    elif isinstance(obj, list):
        for idx, item in enumerate(obj):
            errors.extend(check_parity(item, f"{path}[{idx}]"))
    return errors

unidad_parity_errs = check_parity(unidad_data)
check(len(unidad_parity_errs) == 0, f"juega.mar.01.json 1:1 bilingual parity (errors: {unidad_parity_errs})")

capsula_parity_errs = check_parity(capsula_data)
check(len(capsula_parity_errs) == 0, f"academy.como_se_aprende_a_hablar.01.json 1:1 bilingual parity (errors: {capsula_parity_errs})")

# Curricular reference check (Decreto 150/2022)
check(unidad_data.get("curriculo", {}).get("normativa") == "Decreto 150/2022", "juega.mar.01.json cites Decreto 150/2022")
check(capsula_data.get("curriculo", {}).get("normativa") == "Decreto 150/2022", "academy.como_se_aprende_a_hablar.01.json cites Decreto 150/2022")

# Clinical terms blacklist
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

def find_clinical_terms(obj, path=""):
    found = []
    if isinstance(obj, str):
        matches = clinical_pattern.findall(obj)
        if matches:
            found.append(f"{path}: matched {matches}")
    elif isinstance(obj, dict):
        for k, v in obj.items():
            found.extend(find_clinical_terms(v, f"{path}.{k}" if path else k))
    elif isinstance(obj, list):
        for i, v in enumerate(obj):
            found.extend(find_clinical_terms(v, f"{path}[{i}]"))
    return found

unidad_clinical = find_clinical_terms(unidad_data)
check(len(unidad_clinical) == 0, f"juega.mar.01.json zero clinical terms (found: {unidad_clinical})")

capsula_clinical = find_clinical_terms(capsula_data)
check(len(capsula_clinical) == 0, f"academy.como_se_aprende_a_hablar.01.json zero clinical terms (found: {capsula_clinical})")

# R3: Audio file check
print("\n--- 5. R3: Offline Audio Asset 72 BPM WAV ---")
wav_path = os.path.join(PROJECT_ROOT, "assets/audio/mar_pulso_72bpm.wav")
check(os.path.exists(wav_path), "assets/audio/mar_pulso_72bpm.wav exists")
with wave.open(wav_path, "rb") as w:
    duration = w.getnframes() / float(w.getframerate())
    check(w.getnchannels() == 1, "WAV is mono")
    check(w.getsampwidth() == 2, "WAV is 16-bit")
    check(w.getframerate() == 44100, "WAV is 44.1 kHz")
    check(20 < duration < 35, f"WAV duration {duration:.2f}s is plausible (~26.7s)")

# R3: Academy 4 parts & 5 blocks
print("\n--- 6. R3: Academy Architecture & 4-part / 5-block Invariants ---")
for part in ["ideaClave", "porQueImporta", "queHacerEnCasa", "ejemploCotidiano"]:
    check(part in capsula_data, f"academy capsule has canonical section: {part}")

capsula_model_path = os.path.join(PROJECT_ROOT, "lib/data/models/capsula_model.dart")
with open(capsula_model_path) as f:
    cm_content = f.read()
check("desarrollo_comunicativo" in cm_content, "Bloque model defines desarrollo_comunicativo")
check("rutinas_y_bano_de_lenguaje" in cm_content, "Bloque model defines rutinas_y_bano_de_lenguaje")
check("turnos_y_atencion_conjunta" in cm_content, "Bloque model defines turnos_y_atencion_conjunta")
check("juego_movimiento_sin_pantallas" in cm_content, "Bloque model defines juego_movimiento_sin_pantallas")
check("bilinguismo_y_cultura" in cm_content, "Bloque model defines bilinguismo_y_cultura")

bloques_screen = os.path.join(PROJECT_ROOT, "lib/features/academy/views/bloques_list_screen.dart")
with open(bloques_screen) as f:
    bcontent = f.read()
check("getAllBloques()" in bcontent, "BloquesListScreen retrieves blocks from repository")

# R3: Juega 6 phases and safety alert
print("\n--- 7. R3: Juega 6 Assembly Phases & Non-Bypassable Safety Alert ---")
asamblea_screen = os.path.join(PROJECT_ROOT, "lib/features/juega/views/asamblea_guiada_screen.dart")
with open(asamblea_screen) as f:
    acontent = f.read()
check("PasoCancionWidget" in acontent, "Asamblea links to Phase 1 PasoCancionWidget")
check("PasoContoWidget" in acontent, "Asamblea links to Phase 2 PasoContoWidget")
check("PasoPreguntasWidget" in acontent, "Asamblea links to Phase 3 PasoPreguntasWidget")
check("PasoExploracionWidget" in acontent, "Asamblea links to Phase 4 PasoExploracionWidget")
check("PasoMatematicasWidget" in acontent, "Asamblea links to Phase 5 PasoMatematicasWidget")
check("PasoPonteCasaWidget" in acontent, "Asamblea links to Phase 6 PasoPonteCasaWidget")

exploracion_widget = os.path.join(PROJECT_ROOT, "lib/features/juega/widgets/paso_exploracion_widget.dart")
with open(exploracion_widget) as f:
    econtent = f.read()
check("avisoSeguridad" in econtent, "PasoExploracionWidget renders avisoSeguridad")
check("Supervisión adulta continua" in econtent or "Supervisión adulta" in econtent, "Safety notice mandates adult supervision")
check("4-5 cm" in econtent, "Safety notice specifies piece size > 4-5 cm")

# Adult typography check for body text (paragraphs, reading text)
print("\n--- 8. Adult Typography Invariant on Body Reading Text ---")
body_copy_pattern = re.compile(
    r"body(?:Medium|Large)?\?\.copyWith\s*\([^)]*fontSize:\s*([0-9.]+)",
    re.DOTALL
)
body_downgrades = []
for fpath in lib_files:
    if "features" in fpath or "main.dart" in fpath:
        with open(fpath) as f:
            txt = f.read()
        rel = os.path.relpath(fpath, PROJECT_ROOT)
        for m in body_copy_pattern.finditer(txt):
            sz = float(m.group(1))
            if sz < 16.0:
                body_downgrades.append(f"{rel}: body fontSize {sz} < 16.0")

check(len(body_downgrades) == 0, f"Zero body reading text downgrades below 16.0sp (found: {body_downgrades})")

print("\n==================================================")
if failures:
    print(f"FAILED WITH {len(failures)} DEFECTS")
    sys.exit(1)
else:
    print("ALL ADVERSARIAL PROBE CHECKS PASSED EMPIRICALLY (100% PASS)")
    sys.exit(0)
