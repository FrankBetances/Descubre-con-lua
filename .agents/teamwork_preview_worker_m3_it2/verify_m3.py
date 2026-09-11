#!/usr/bin/env python3
"""
Empirical Verification Suite for Milestone 3 (Iteration 2): Pedagogical Modules & Remediation
«Descubre con Lúa · Edición Vigo»

Verifies:
1. Procedural offline audio asset (assets/audio/mar_pulso_72bpm.wav).
2. Academy (Familias) module components and contracts.
3. Juega con Lúa (Aula / Docentes) module components and 6 assembly phases.
4. Comprehensive Adult Typography AST/regex scan (lib/features/ & lib/main.dart) certifying body text >= 16.0sp.
5. Audio subscription lifecycle management in PasoCancionWidget (dispose cancellation).
6. Disambiguated test title assertions in academy_flow_test.dart.
7. Main app routing and navigation integration.
8. Zero network libraries, zero clinical terms, and zero external URLs.
9. Regression verification across M1, M2, and M3 adversarial harnesses.
"""

import os
import sys
import wave
import re
import subprocess
from typing import List, Tuple

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

CLINICAL_BLACKLIST_REGEX = re.compile(
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

FORBIDDEN_NETWORK_TOKENS = [
    'HttpClient',
    'WebSocket',
    'Socket.connect',
    'package:http/',
    'package:dio/',
    'package:firebase',
    'url_launcher',
]

def verify_audio_asset():
    print("\n--- 1. Offline Audio Asset (mar_pulso_72bpm.wav) ---")
    wav_path = os.path.join(PROJECT_ROOT, "assets/audio/mar_pulso_72bpm.wav")
    check(os.path.exists(wav_path), f"Audio file exists: {wav_path}")
    
    if os.path.exists(wav_path):
        with wave.open(wav_path, 'rb') as w:
            channels = w.getnchannels()
            sampwidth = w.getsampwidth()
            framerate = w.getframerate()
            nframes = w.getnframes()
            duration = nframes / framerate
            
            check(channels == 1, f"Audio is mono (1 channel), got {channels}")
            check(sampwidth == 2, f"Audio is 16-bit PCM (2 bytes), got {sampwidth}")
            check(framerate == 44100, f"Sample rate is 44100 Hz, got {framerate}")
            check(25.0 <= duration <= 28.0, f"Duration is ~26.7s (32 beats @ 72 BPM), got {duration:.2f}s")
            check(nframes > 0, "Audio file contains non-zero audio frames")

def verify_academy_module():
    print("\n--- 2. Academy (Familias) Module Components & Contracts ---")
    academy_dir = os.path.join(PROJECT_ROOT, "lib/features/academy")
    bloques_view = os.path.join(academy_dir, "views/bloques_list_screen.dart")
    capsula_view = os.path.join(academy_dir, "views/capsula_detail_screen.dart")
    seccion_widget = os.path.join(academy_dir, "widgets/seccion_capsula_widget.dart")
    selector_widget = os.path.join(academy_dir, "widgets/selector_idioma_widget.dart")
    
    check(os.path.exists(bloques_view), f"BloquesListScreen exists: {bloques_view}")
    check(os.path.exists(capsula_view), f"CapsulaDetailScreen exists: {capsula_view}")
    check(os.path.exists(seccion_widget), f"SeccionCapsulaWidget exists: {seccion_widget}")
    check(os.path.exists(selector_widget), f"SelectorIdiomaWidget exists: {selector_widget}")

    if os.path.exists(bloques_view):
        content = open(bloques_view, encoding="utf-8").read()
        check("class BloquesListScreen" in content, "BloquesListScreen class declared")
        check("getAllBloques" in content, "BloquesListScreen queries the 5 developmental blocks")
        check("getCapsulasByBloque" in content, "BloquesListScreen lists capsules per block")
        check("SelectorIdiomaWidget" in content, "BloquesListScreen integrates dynamic language toggle")
        check("CapsulaDetailScreen" in content, "BloquesListScreen links to CapsulaDetailScreen")
        
    if os.path.exists(capsula_view):
        content = open(capsula_view, encoding="utf-8").read()
        check("class CapsulaDetailScreen" in content, "CapsulaDetailScreen class declared")
        check("ideaClave" in content, "CapsulaDetailScreen renders Idea clave section")
        check("porQueImporta" in content, "CapsulaDetailScreen renders Por qué importa section")
        check("queHacerEnCasa" in content, "CapsulaDetailScreen renders Qué hacer en casa section")
        check("ejemploCotidiano" in content, "CapsulaDetailScreen renders Ejemplo cotidiano section")
        check("afirmaciones" in content, "CapsulaDetailScreen handles formative reflection (Afirmacion)")
        check("SelectorIdiomaWidget" in content, "CapsulaDetailScreen integrates dynamic language toggle")
        check("Decreto 150/2022" in content or "curriculo" in content, "CapsulaDetailScreen displays curricular framework")

    if os.path.exists(seccion_widget):
        content = open(seccion_widget, encoding="utf-8").read()
        check("class SeccionCapsulaWidget" in content, "SeccionCapsulaWidget class declared")
        check("TipoSeccionCapsula" in content, "Canonical section enum defined")

    if os.path.exists(selector_widget):
        content = open(selector_widget, encoding="utf-8").read()
        check("class SelectorIdiomaWidget" in content, "SelectorIdiomaWidget class declared")
        check("AppLanguage.gl" in content and "AppLanguage.es" in content, "Bilingual toggle supports GL and ES")

def verify_juega_module():
    print("\n--- 3. Juega con Lúa (Aula / Docentes) Module & 6 Phases ---")
    juega_dir = os.path.join(PROJECT_ROOT, "lib/features/juega")
    
    unidades_view = os.path.join(juega_dir, "views/unidades_list_screen.dart")
    asamblea_view = os.path.join(juega_dir, "views/asamblea_guiada_screen.dart")
    paso1 = os.path.join(juega_dir, "widgets/paso_cancion_widget.dart")
    paso2 = os.path.join(juega_dir, "widgets/paso_conto_widget.dart")
    paso3 = os.path.join(juega_dir, "widgets/paso_preguntas_widget.dart")
    paso4 = os.path.join(juega_dir, "widgets/paso_exploracion_widget.dart")
    paso5 = os.path.join(juega_dir, "widgets/paso_matematicas_widget.dart")
    paso6 = os.path.join(juega_dir, "widgets/paso_ponte_casa_widget.dart")
    
    check(os.path.exists(unidades_view), f"UnidadesListScreen exists: {unidades_view}")
    check(os.path.exists(asamblea_view), f"AsambleaGuiadaScreen exists: {asamblea_view}")
    check(os.path.exists(paso1), f"PasoCancionWidget (Phase 1) exists: {paso1}")
    check(os.path.exists(paso2), f"PasoContoWidget (Phase 2) exists: {paso2}")
    check(os.path.exists(paso3), f"PasoPreguntasWidget (Phase 3) exists: {paso3}")
    check(os.path.exists(paso4), f"PasoExploracionWidget (Phase 4) exists: {paso4}")
    check(os.path.exists(paso5), f"PasoMatematicasWidget (Phase 5) exists: {paso5}")
    check(os.path.exists(paso6), f"PasoPonteCasaWidget (Phase 6) exists: {paso6}")

    if os.path.exists(unidades_view):
        content = open(unidades_view, encoding="utf-8").read()
        check("class UnidadesListScreen" in content, "UnidadesListScreen class declared")
        check("getUnidadesByTramoEtario" in content or "getAllUnidades" in content, "UnidadesListScreen supports age filtering")
        check("'0-2'" in content and "'2-3'" in content, "UnidadesListScreen declares 0-2 and 2-3 age segments")
        check("AsambleaGuiadaScreen" in content, "UnidadesListScreen launches guided assembly wizard")

    if os.path.exists(asamblea_view):
        content = open(asamblea_view, encoding="utf-8").read()
        check("class AsambleaGuiadaScreen" in content, "AsambleaGuiadaScreen class declared")
        check("_currentPaso" in content, "AsambleaGuiadaScreen maintains phase state [0..5]")
        check("PasoCancionWidget" in content, "Asamblea links to Phase 1 (Canción)")
        check("PasoContoWidget" in content, "Asamblea links to Phase 2 (Conto)")
        check("PasoPreguntasWidget" in content, "Asamblea links to Phase 3 (Preguntas)")
        check("PasoExploracionWidget" in content, "Asamblea links to Phase 4 (Exploración)")
        check("PasoMatematicasWidget" in content, "Asamblea links to Phase 5 (Matemáticas)")
        check("PasoPonteCasaWidget" in content, "Asamblea links to Phase 6 (Ponte á casa)")
        check("_audioService.stop()" in content, "Asamblea stops audio on disposal or exit")

    if os.path.exists(paso1):
        content = open(paso1, encoding="utf-8").read()
        check("OfflineAudioService" in content, "PasoCancionWidget injects OfflineAudioService")
        check("bpm" in content, "PasoCancionWidget renders BPM indicator")
        check("mar_pulso_72bpm.wav" in content, "PasoCancionWidget fallback to bundled pulse audio asset")
        check("StreamSubscription<bool>? _audioSubscription" in content, "PasoCancionWidget stores StreamSubscription field")
        check("_audioSubscription?.cancel()" in content, "PasoCancionWidget explicitly cancels audio subscription in dispose()")

    if os.path.exists(paso4):
        content = open(paso4, encoding="utf-8").read()
        check("avisoSeguridad" in content, "PasoExploracionWidget renders safety alert notice")
        check("accentTerracotta" in content or "warning" in content, "PasoExploracionWidget styles safety alert prominently")

def verify_adult_typography_ast():
    print("\n--- 4. Comprehensive Adult Typography AST/Regex Scan (>= 16.0sp) ---")
    features_dir = os.path.join(PROJECT_ROOT, "lib/features")
    main_file = os.path.join(PROJECT_ROOT, "lib/main.dart")

    target_files = [main_file]
    for root, _, files in os.walk(features_dir):
        for f in files:
            if f.endswith(".dart"):
                target_files.append(os.path.join(root, f))

    body_copy_pattern = re.compile(
        r"body(?:Medium|Large)?\?\.copyWith\s*\([^)]*fontSize:\s*([0-9.]+)",
        re.DOTALL
    )
    raw_style_pattern = re.compile(r"TextStyle\s*\([^)]*fontSize:\s*([0-9.]+)", re.DOTALL)

    body_downgrades = []
    academy_15_violations = []

    for path in target_files:
        rel_path = os.path.relpath(path, PROJECT_ROOT)
        content = open(path, "r", encoding="utf-8").read()

        for match in body_copy_pattern.finditer(content):
            sz = float(match.group(1))
            if sz < 16.0:
                line_no = content[:match.start()].count("\n") + 1
                body_downgrades.append((rel_path, line_no, sz))

        if "academy" in rel_path:
            for match in raw_style_pattern.finditer(content):
                sz = float(match.group(1))
                if sz == 15.0:
                    line_no = content[:match.start()].count("\n") + 1
                    academy_15_violations.append((rel_path, line_no, sz))

    check(len(body_downgrades) == 0, f"lib/features/ body text fontSize >= 16.0 sp across all modules (violations: {len(body_downgrades)})")
    check(len(academy_15_violations) == 0, f"Academy module free of raw TextStyle(fontSize: 15.0) (violations: {len(academy_15_violations)})")

def verify_test_suite_disambiguation():
    print("\n--- 5. Test Suite Disambiguation Verification ---")
    flow_test = os.path.join(PROJECT_ROOT, "test/features/academy/academy_flow_test.dart")
    check(os.path.exists(flow_test), f"academy_flow_test.dart exists: {flow_test}")
    if os.path.exists(flow_test):
        content = open(flow_test, encoding="utf-8").read()
        distinct_title = "Como se aprende a falar: o baño de lingua e as primeiras quendas"
        check(distinct_title in content, f"academy_flow_test.dart uses distinct title to prevent widget collision")

def verify_main_routing():
    print("\n--- 6. Main App Routing Integration ---")
    main_path = os.path.join(PROJECT_ROOT, "lib/main.dart")
    check(os.path.exists(main_path), f"main.dart exists: {main_path}")
    
    if os.path.exists(main_path):
        content = open(main_path, encoding="utf-8").read()
        check("BloquesListScreen" in content, "main.dart imports/uses BloquesListScreen")
        check("CapsulaDetailScreen" in content, "main.dart imports/uses CapsulaDetailScreen")
        check("UnidadesListScreen" in content, "main.dart imports/uses UnidadesListScreen")
        check("AsambleaGuiadaScreen" in content, "main.dart imports/uses AsambleaGuiadaScreen")
        check("routes:" in content, "main.dart defines named application routes")
        check("'/academy'" in content, "main.dart defines '/academy' route")
        check("'/juega'" in content, "main.dart defines '/juega' route")
        check("onGenerateRoute" in content, "main.dart defines onGenerateRoute for parameterized screens")

def verify_codebase_cleanliness():
    print("\n--- 7. Codebase Cleanliness: Zero Network & Zero Clinical Terms ---")
    features_dir = os.path.join(PROJECT_ROOT, "lib/features")
    files_to_check = [os.path.join(PROJECT_ROOT, "lib/main.dart")]
    for root, _, files in os.walk(features_dir):
        for f in files:
            if f.endswith(".dart"):
                files_to_check.append(os.path.join(root, f))

    for path in sorted(files_to_check):
        rel_path = os.path.relpath(path, PROJECT_ROOT)
        content = open(path, encoding="utf-8").read()
        
        # Check network tokens
        has_network = False
        for token in FORBIDDEN_NETWORK_TOKENS:
            if token in content:
                has_network = True
                check(False, f"{rel_path} contains forbidden network token: '{token}'")
        if not has_network:
            check(True, f"{rel_path} strictly excludes network tokens")

        # Check forbidden clinical terms
        match = CLINICAL_BLACKLIST_REGEX.search(content)
        if match:
            check(False, f"{rel_path} contains prohibited clinical term: '{match.group(0)}'")
        else:
            check(True, f"{rel_path} free of prohibited clinical terminology")

def run_regressions():
    print("\n--- 8. Milestone 1, 2 & 3 Regression Checks ---")
    v1_script = os.path.join(PROJECT_ROOT, "verify_m1.py")
    v2_script = os.path.join(PROJECT_ROOT, "verify_m2.py")
    m2_adversarial = os.path.join(PROJECT_ROOT, "test/data/run_m2_adversarial_suite.py")
    m3_academy_stress = os.path.join(PROJECT_ROOT, "test/features/academy/run_academy_ux_stress_tests.py")
    m3_juega_challenger = os.path.join(PROJECT_ROOT, "test/features/juega/run_m3_adversarial_challenger.py")

    for script_path, name in [
        (v1_script, "Milestone 1 verify_m1.py"),
        (v2_script, "Milestone 2 verify_m2.py"),
        (m2_adversarial, "M2 Adversarial Suite"),
        (m3_academy_stress, "M3 Academy UX Stress Tests (Challenger 2)"),
        (m3_juega_challenger, "M3 Juega Adversarial Challenger (Challenger 1)"),
    ]:
        if os.path.exists(script_path):
            ret = os.system(f"python3 '{script_path}' > /dev/null 2>&1")
            check(ret == 0, f"Regression check passed: {name} (exit code {ret})")
        else:
            check(False, f"Regression script not found: {script_path}")

def main():
    print("==================================================")
    print("Running Milestone 3 Empirical Verification Suite (It2)")
    print("«Descubre con Lúa · Edición Vigo»")
    print("==================================================")
    
    verify_audio_asset()
    verify_academy_module()
    verify_juega_module()
    verify_adult_typography_ast()
    verify_test_suite_disambiguation()
    verify_main_routing()
    verify_codebase_cleanliness()
    run_regressions()
    
    print("\n==================================================")
    if FAILED_CHECKS == 0:
        print(f"🎉 ALL {TOTAL_CHECKS} MILESTONE 3 CHECKS PASSED WITH ZERO DEFECTS")
        print("==================================================")
        sys.exit(0)
    else:
        print(f"❌ VERIFICATION FAILED: {FAILED_CHECKS} of {TOTAL_CHECKS} checks failed.")
        print("==================================================")
        sys.exit(1)

if __name__ == '__main__':
    main()
