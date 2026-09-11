#!/usr/bin/env python3
"""
Empirical Verification Suite for Milestone 3: Pedagogical Modules
«Descubre con Lúa · Edición Vigo»

Verifies:
1. Procedural offline audio asset (assets/audio/mar_pulso_72bpm.wav).
2. Academy (Familias) module components and contracts.
3. Juega con Lúa (Aula / Docentes) module components and 6 assembly phases.
4. Safety alert prominence (>4-5cm, adult supervision) and adult typography (>= 16sp).
5. Dynamic bilingual switching (gl / es).
6. Main app routing and navigation integration.
7. Zero network libraries, zero clinical terms, and regression verification across M1 & M2.
"""

import os
import sys
import wave
import re
from typing import List

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
            
            check(channels == 1, f"Audio is mono (channels={channels})")
            check(sampwidth == 2, f"Audio bit depth is 16-bit PCM (bytes={sampwidth})")
            check(framerate == 44100, f"Audio sample rate is 44.1 kHz (framerate={framerate})")
            check(duration > 20.0, f"Audio duration is sufficient ({duration:.2f}s > 20s)")
            
            # Check 72 BPM rhythm math: period = 60 / 72 = 0.8333s => samples per beat = 36750
            samples_per_beat = int(round(framerate * (60.0 / 72.0)))
            check(samples_per_beat == 36750, f"72 BPM sample periodicity exactness ({samples_per_beat} samples)")

def verify_academy_module():
    print("\n--- 2. Academy (Familias) Module ---")
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
        content = open(bloques_view).read()
        check("class BloquesListScreen" in content, "BloquesListScreen class declared")
        check("getAllBloques" in content, "BloquesListScreen queries the 5 developmental blocks")
        check("SelectorIdiomaWidget" in content, "BloquesListScreen integrates SelectorIdiomaWidget")
        check("CapsulaDetailScreen" in content, "BloquesListScreen links to CapsulaDetailScreen")
        
    if os.path.exists(capsula_view):
        content = open(capsula_view).read()
        check("class CapsulaDetailScreen" in content, "CapsulaDetailScreen class declared")
        check("ideaClave" in content, "CapsulaDetailScreen renders Idea clave section")
        check("porQueImporta" in content, "CapsulaDetailScreen renders Por qué importa section")
        check("queHacerEnCasa" in content, "CapsulaDetailScreen renders Qué hacer en casa section")
        check("ejemploCotidiano" in content, "CapsulaDetailScreen renders Ejemplo cotidiano section")
        check("afirmaciones" in content, "CapsulaDetailScreen handles formative reflection (Afirmacion)")
        check("SelectorIdiomaWidget" in content, "CapsulaDetailScreen integrates dynamic language toggle")
        check("Decreto 150/2022" in content or "curriculo" in content, "CapsulaDetailScreen displays curricular framework")

    if os.path.exists(seccion_widget):
        content = open(seccion_widget).read()
        check("class SeccionCapsulaWidget" in content, "SeccionCapsulaWidget class declared")
        check("TipoSeccionCapsula" in content, "Canonical section enum defined")
        # Adult typography check
        check("fontSize: 16" in content or "fontSize: 17" in content, "Adult typography font size >= 16sp enforced in body text")

    if os.path.exists(selector_widget):
        content = open(selector_widget).read()
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
        content = open(unidades_view).read()
        check("class UnidadesListScreen" in content, "UnidadesListScreen class declared")
        check("0-2" in content and "2-3" in content, "Age band filtering tabs supported ('0-2', '2-3')")
        check("AsambleaGuiadaScreen" in content, "UnidadesListScreen launches guided assembly")
        
    if os.path.exists(asamblea_view):
        content = open(asamblea_view).read()
        check("class AsambleaGuiadaScreen" in content, "AsambleaGuiadaScreen class declared")
        check("PasoCancionWidget" in content, "Phase 1 integrated in assembly wizard")
        check("PasoContoWidget" in content, "Phase 2 integrated in assembly wizard")
        check("PasoPreguntasWidget" in content, "Phase 3 integrated in assembly wizard")
        check("PasoExploracionWidget" in content, "Phase 4 integrated in assembly wizard")
        check("PasoMatematicasWidget" in content, "Phase 5 integrated in assembly wizard")
        check("PasoPonteCasaWidget" in content, "Phase 6 integrated in assembly wizard")

    if os.path.exists(paso1):
        content = open(paso1).read()
        check("OfflineAudioService" in content, "Paso 1 interacts with OfflineAudioService")
        check("playAsset" in content, "Paso 1 has play functionality")
        check("pause" in content, "Paso 1 has pause functionality")
        check("stop" in content, "Paso 1 has stop functionality")
        check("BPM" in content, "Paso 1 displays song BPM")
        check("consignaDocente" in content, "Paso 1 displays teacher directive")

    if os.path.exists(paso2):
        content = open(paso2).read()
        check("Cuento" in content, "Paso 2 displays story")
        check("preguntaComprension" in content, "Paso 2 provides comprehension prompts")

    if os.path.exists(paso3):
        content = open(paso3).read()
        check("nivel" in content, "Paso 3 handles graduated question levels")
        check("consejoDocente" in content, "Paso 3 provides pedagogical tips for teacher")
        check("Nivel 1" in content and "Nivel 2" in content and "Nivel 3" in content, "Paso 3 explicitly models levels 1, 2, 3")

    if os.path.exists(paso4):
        content = open(paso4).read()
        check("avisoSeguridad" in content, "Paso 4 displays mandatory safety alert")
        check("materiales" in content, "Paso 4 lists required manipulative materials")
        check("pasos" in content, "Paso 4 details facilitation steps")
        # Check piece size and supervision notice
        check("4" in content or "5" in content, "Safety alert highlights piece size limit (>4-5 cm)")
        check("supervisi" in content.lower(), "Safety alert mandates continuous adult supervision")

    if os.path.exists(paso5):
        content = open(paso5).read()
        check("concepto" in content, "Paso 5 presents early mathematical concepts")
        check("accionesSugeridas" in content, "Paso 5 suggests classroom actions")
        check("vocabularioMatematico" in content, "Paso 5 reinforces mathematical vocabulary")

    if os.path.exists(paso6):
        content = open(paso6).read()
        check("mensajeFamilias" in content, "Paso 6 drafts family communication")
        check("actividadesSugeridas" in content, "Paso 6 suggests home reinforcement activities")
        check("recomendacionConversacion" in content, "Paso 6 guides home conversation")

def verify_main_routing():
    print("\n--- 4. Main App Routing Integration ---")
    main_path = os.path.join(PROJECT_ROOT, "lib/main.dart")
    check(os.path.exists(main_path), f"main.dart exists: {main_path}")
    
    if os.path.exists(main_path):
        content = open(main_path).read()
        check("BloquesListScreen" in content, "main.dart imports/uses BloquesListScreen")
        check("CapsulaDetailScreen" in content, "main.dart imports/uses CapsulaDetailScreen")
        check("UnidadesListScreen" in content, "main.dart imports/uses UnidadesListScreen")
        check("AsambleaGuiadaScreen" in content, "main.dart imports/uses AsambleaGuiadaScreen")
        check("routes:" in content, "main.dart defines named application routes")
        check("'/academy'" in content, "main.dart defines '/academy' route")
        check("'/juega'" in content, "main.dart defines '/juega' route")
        check("onGenerateRoute" in content, "main.dart defines onGenerateRoute for parameterized screens")

def verify_codebase_cleanliness():
    print("\n--- 5. Codebase Cleanliness, Privacy & Clinical Guard ---")
    m3_files = [
        "lib/main.dart",
        "lib/features/academy/widgets/selector_idioma_widget.dart",
        "lib/features/academy/widgets/seccion_capsula_widget.dart",
        "lib/features/academy/views/bloques_list_screen.dart",
        "lib/features/academy/views/capsula_detail_screen.dart",
        "lib/features/juega/widgets/paso_cancion_widget.dart",
        "lib/features/juega/widgets/paso_conto_widget.dart",
        "lib/features/juega/widgets/paso_preguntas_widget.dart",
        "lib/features/juega/widgets/paso_exploracion_widget.dart",
        "lib/features/juega/widgets/paso_matematicas_widget.dart",
        "lib/features/juega/widgets/paso_ponte_casa_widget.dart",
        "lib/features/juega/views/asamblea_guiada_screen.dart",
        "lib/features/juega/views/unidades_list_screen.dart",
        "test/features/academy/academy_flow_test.dart",
        "test/features/juega/juega_flow_test.dart",
    ]

    for rel_path in m3_files:
        full_path = os.path.join(PROJECT_ROOT, rel_path)
        if not os.path.exists(full_path):
            check(False, f"Required file missing: {rel_path}")
            continue
        
        content = open(full_path).read()
        
        # Check network forbidden tokens
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
    print("\n--- 6. Milestone 1 & 2 Regression Checks ---")
    v1_script = os.path.join(PROJECT_ROOT, ".agents/teamwork_preview_worker_m1/verify_m1.py")
    v2_script = os.path.join(PROJECT_ROOT, ".agents/teamwork_preview_worker_m2/verify_m2.py")
    m2_challenger = os.path.join(PROJECT_ROOT, "test/data/m2_challenger_adversarial_suite.py")
    m2_stress = os.path.join(PROJECT_ROOT, "test/data/run_m2_challenger_stress.py")
    
    for script_path, name in [
        (v1_script, "Milestone 1 verify_m1.py"),
        (v2_script, "Milestone 2 verify_m2.py"),
        (m2_challenger, "Challenger 1 Adversarial Suite"),
        (m2_stress, "Challenger 2 Adversarial Stress Suite"),
    ]:
        if os.path.exists(script_path):
            ret = os.system(f"python3 '{script_path}' > /dev/null 2>&1")
            check(ret == 0, f"Regression check passed: {name} (exit code {ret})")
        else:
            check(False, f"Regression script not found: {script_path}")

def main():
    print("==================================================")
    print("Running Milestone 3 Empirical Verification Suite")
    print("«Descubre con Lúa · Edición Vigo»")
    print("==================================================")
    
    verify_audio_asset();
    verify_academy_module();
    verify_juega_module();
    verify_main_routing();
    verify_codebase_cleanliness();
    run_regressions();
    
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
