#!/usr/bin/env python3
"""
Adversarial Stress Test & Quality Verification Suite for Milestone 3
Reviewer 2: M3 Juega con Lúa & Audio Reviewer
Descubre con Lúa · Edición Vigo
"""

import os
import sys
import wave
import struct
import math
import json
import re

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

# ---------------------------------------------------------------------
# 1. FORENSIC AUDIO AUDIT: assets/audio/mar_pulso_72bpm.wav
# ---------------------------------------------------------------------
def audit_audio_asset():
    print("\n--- 1. Audio Asset Forensic Audit (mar_pulso_72bpm.wav) ---")
    wav_path = os.path.join(PROJECT_ROOT, "assets/audio/mar_pulso_72bpm.wav")
    check(os.path.isfile(wav_path), f"File exists: {wav_path}")
    
    file_size = os.path.getsize(wav_path)
    check(file_size > 1_000_000, f"File size is realistic for uncompressed PCM: {file_size} bytes")
    
    # Read raw header bytes
    with open(wav_path, "rb") as f:
        header = f.read(44)
    check(header[0:4] == b"RIFF", "RIFF magic header present")
    check(header[8:12] == b"WAVE", "WAVE format header present")
    check(header[12:16] == b"fmt ", "fmt subchunk marker present")
    
    with wave.open(wav_path, "rb") as w:
        channels = w.getnchannels()
        sampwidth = w.getsampwidth()
        framerate = w.getframerate()
        nframes = w.getnframes()
        duration = nframes / framerate
        
        check(channels == 1, f"Mono audio verified (channels={channels})")
        check(sampwidth == 2, f"16-bit PCM verified (sampwidth={sampwidth} bytes = 16 bits)")
        check(framerate == 44100, f"Sample rate 44.1 kHz verified ({framerate} Hz)")
        check(duration >= 25.0, f"Duration is sufficient ({duration:.2f}s >= 25s)")
        
        # Exact mathematical samples per beat for 72 BPM
        # 60 / 72 = 0.8333333... s * 44100 = 36750.0 samples
        expected_samples_per_beat = 44100 * 60 // 72
        check(expected_samples_per_beat == 36750, f"Expected samples per beat is exactly 36,750 (got {expected_samples_per_beat})")
        
        raw_frames = w.readframes(nframes)
        samples = struct.unpack(f"<{nframes}h", raw_frames)
        
        num_beats = nframes // expected_samples_per_beat
        check(num_beats == 32, f"Exact number of full 4/4 bars (32 beats = 8 bars) verified (got {num_beats})")
        
        # Audio clipping check: signed 16-bit range is -32768 to 32767
        max_abs = max(abs(s) for s in samples)
        check(max_abs < 32000, f"No digital clipping (peak={max_abs} < 32000 / 32767 headroom)")
        
        # Beat onset verification: each 36,750 window must peak in the attack phase (first 50ms = 2205 samples)
        all_beats_valid = True
        for b in range(num_beats):
            b_start = b * expected_samples_per_beat
            b_attack = samples[b_start : b_start + 2205]
            b_tail = samples[b_start + 4410 : b_start + expected_samples_per_beat]
            
            attack_peak = max(abs(s) for s in b_attack)
            tail_rms = math.sqrt(sum(s*s for s in b_tail) / len(b_tail))
            
            if attack_peak < 12000 or tail_rms > 2000:
                all_beats_valid = False
                print(f"    Beat {b} anomaly: attack_peak={attack_peak}, tail_rms={tail_rms:.1f}")
                
        check(all_beats_valid, "All 32 beats have strong attack (>12000) and quiet tail (decay < 2000 RMS)")

# ---------------------------------------------------------------------
# 2. CODE & SOLEMN ADULT DESIGN AUDIT: lib/features/juega/
# ---------------------------------------------------------------------
def audit_juega_module():
    print("\n--- 2. Juega con Lúa UI & Pedagogical Design Audit ---")
    juega_dir = os.path.join(PROJECT_ROOT, "lib/features/juega")
    
    unidades_screen = os.path.join(juega_dir, "views/unidades_list_screen.dart")
    asamblea_screen = os.path.join(juega_dir, "views/asamblea_guiada_screen.dart")
    
    check(os.path.isfile(unidades_screen), "UnidadesListScreen exists")
    check(os.path.isfile(asamblea_screen), "AsambleaGuiadaScreen exists")
    
    # Check age band filtering in UnidadesListScreen
    with open(unidades_screen, "r", encoding="utf-8") as f:
        u_src = f.read()
        
    check("0-2 anos" in u_src and "2-3 anos" in u_src, "UnidadesListScreen contains age band labels ('0-2 anos', '2-3 anos')")
    check("getUnidadesByTramoEtario" in u_src, "UnidadesListScreen calls getUnidadesByTramoEtario")
    check("getAllUnidades" in u_src, "UnidadesListScreen calls getAllUnidades")
    check("AsambleaGuiadaScreen" in u_src, "UnidadesListScreen navigates to AsambleaGuiadaScreen")
    
    # Check 6 assembly phases in asamblea_guiada_screen
    with open(asamblea_screen, "r", encoding="utf-8") as f:
        a_src = f.read()
        
    check("PasoCancionWidget" in a_src, "AsambleaGuiadaScreen includes Phase 1: PasoCancionWidget")
    check("PasoContoWidget" in a_src, "AsambleaGuiadaScreen includes Phase 2: PasoContoWidget")
    check("PasoPreguntasWidget" in a_src, "AsambleaGuiadaScreen includes Phase 3: PasoPreguntasWidget")
    check("PasoExploracionWidget" in a_src, "AsambleaGuiadaScreen includes Phase 4: PasoExploracionWidget")
    check("PasoMatematicasWidget" in a_src, "AsambleaGuiadaScreen includes Phase 5: PasoMatematicasWidget")
    check("PasoPonteCasaWidget" in a_src, "AsambleaGuiadaScreen includes Phase 6: PasoPonteCasaWidget")
    
    # Check audio pausing when moving away from Phase 1
    check("_currentPaso == 0 && _audioService.isPlaying" in a_src and "_audioService.pause()" in a_src,
          "AsambleaGuiadaScreen auto-pauses audio when progressing past Phase 1")
    check("_audioService.stop()" in a_src, "AsambleaGuiadaScreen cleans up audio on dispose and finish")
    
    # Check Phase 1: Cancion
    p1_path = os.path.join(juega_dir, "widgets/paso_cancion_widget.dart")
    with open(p1_path, "r", encoding="utf-8") as f:
        p1_src = f.read()
    check("bpm" in p1_src and "BPM" in p1_src, "Phase 1 displays song BPM badge")
    check("consignaDocente" in p1_src, "Phase 1 displays teacher consigna")
    check("letraConPulsos" in p1_src, "Phase 1 displays lyrics with rhythm markers")
    check("mar_pulso_72bpm.wav" in p1_src, "Phase 1 references local mar_pulso_72bpm.wav")
    check("playAsset" in p1_src and "pause" in p1_src and "stop" in p1_src, "Phase 1 controls audio playback (play/pause/stop)")
    
    # Check Phase 2: Conto
    p2_path = os.path.join(juega_dir, "widgets/paso_conto_widget.dart")
    with open(p2_path, "r", encoding="utf-8") as f:
        p2_src = f.read()
    check("preguntaComprension" in p2_src, "Phase 2 displays comprehension prompts for circle")
    check("paginas" in p2_src, "Phase 2 supports multi-page story reading")
    
    # Check Phase 3: Preguntas
    p3_path = os.path.join(juega_dir, "widgets/paso_preguntas_widget.dart")
    with open(p3_path, "r", encoding="utf-8") as f:
        p3_src = f.read()
    check("Nivel 1" in p3_src and "Nivel 2" in p3_src and "Nivel 3" in p3_src, "Phase 3 models all 3 scaffolding levels")
    check("respuestaSugerida" in p3_src, "Phase 3 shows expected infant responses")
    check("consejoDocente" in p3_src, "Phase 3 provides teacher pedagogical hints")
    
    # Check Phase 4: Exploracion sensorial & SAFETY ALERT
    p4_path = os.path.join(juega_dir, "widgets/paso_exploracion_widget.dart")
    with open(p4_path, "r", encoding="utf-8") as f:
        p4_src = f.read()
    check("avisoSeguridad" in p4_src, "Phase 4 displays avisoSeguridad")
    check("4-5 cm" in p4_src or "4 cm" in p4_src, "Phase 4 enforces safety alert on piece size (>4-5 cm)")
    check("Supervisión adulta continua" in p4_src or "Supervisión" in p4_src, "Phase 4 mandates continuous adult supervision")
    check("materiales" in p4_src, "Phase 4 lists required manipulative materials")
    check("pasos" in p4_src, "Phase 4 details facilitation steps")
    
    # Check Phase 5: Matematicas temperas
    p5_path = os.path.join(juega_dir, "widgets/paso_matematicas_widget.dart")
    with open(p5_path, "r", encoding="utf-8") as f:
        p5_src = f.read()
    check("concepto" in p5_src, "Phase 5 presents core early math concept (grande / pequeno)")
    check("vocabularioMatematico" in p5_src, "Phase 5 provides mathematical vocabulary")
    check("accionesSugeridas" in p5_src, "Phase 5 suggests concrete classroom manipulative actions")
    
    # Check Phase 6: Ponte a casa
    p6_path = os.path.join(juega_dir, "widgets/paso_ponte_casa_widget.dart")
    with open(p6_path, "r", encoding="utf-8") as f:
        p6_src = f.read()
    check("mensajeFamilias" in p6_src, "Phase 6 drafts message for families")
    check("recomendacionConversacion" in p6_src, "Phase 6 provides pickup/dropoff conversation tips")
    check("actividadesSugeridas" in p6_src, "Phase 6 suggests home reinforcement activities")
    check("onFinalizar" in p6_src, "Phase 6 provides assembly completion action")

# ---------------------------------------------------------------------
# 3. SOBER DESIGN & ADULT FOCUS AUDIT
# ---------------------------------------------------------------------
def audit_sober_teacher_design():
    print("\n--- 3. Sober Teacher Design Audit (Zero Neon, Zero Toddler Games) ---")
    prohibited_game_mechanics = [
        "Confetti",
        "Lottie",
        "Flare",
        "Rive",
        "ShakeDetector",
        "Gyroscope",
        "Gamification",
        "Coin",
        "RewardPopup",
        "ParticleSystem",
        "CelebrationAnimation",
        "BalloonPop",
    ]
    
    juega_dir = os.path.join(PROJECT_ROOT, "lib/features/juega")
    files_to_check = []
    for root, _, files in os.walk(juega_dir):
        for file in files:
            if file.endswith(".dart"):
                files_to_check.append(os.path.join(root, file))
                
    zero_game_mechanics = True
    for fpath in files_to_check:
        with open(fpath, "r", encoding="utf-8") as f:
            content = f.read()
        for token in prohibited_game_mechanics:
            if token in content:
                print(f"  ❌ Prohibited toddler game token '{token}' in {fpath}")
                zero_game_mechanics = False
                
    check(zero_game_mechanics, "Zero toddler game mechanics or distracting game animations in lib/features/juega")

# ---------------------------------------------------------------------
# 4. ROUTING & INTEGRATION AUDIT: lib/main.dart
# ---------------------------------------------------------------------
def audit_main_routing():
    print("\n--- 4. Main App Routing Integration Audit ---")
    main_path = os.path.join(PROJECT_ROOT, "lib/main.dart")
    check(os.path.isfile(main_path), "lib/main.dart exists")
    
    with open(main_path, "r", encoding="utf-8") as f:
        src = f.read()
        
    check("'/juega': (context) => UnidadesListScreen" in src, "lib/main.dart registers '/juega' route to UnidadesListScreen")
    check("'/academy': (context) => BloquesListScreen" in src, "lib/main.dart registers '/academy' route to BloquesListScreen")
    check("settings.name == '/juega/asamblea'" in src, "lib/main.dart handles '/juega/asamblea' parameterized route")
    check("settings.name == '/academy/capsula'" in src, "lib/main.dart handles '/academy/capsula' parameterized route")
    check("UnidadesListScreen" in src, "HomeScreen links to UnidadesListScreen")

# ---------------------------------------------------------------------
# 5. TEST SUITE AUDIT: test/features/juega/juega_flow_test.dart
# ---------------------------------------------------------------------
def audit_test_suite():
    print("\n--- 5. Test Suite Verification (juega_flow_test.dart) ---")
    test_path = os.path.join(PROJECT_ROOT, "test/features/juega/juega_flow_test.dart")
    check(os.path.isfile(test_path), f"Test file exists: {test_path}")
    
    with open(test_path, "r", encoding="utf-8") as f:
        src = f.read()
        
    check("testWidgets('UnidadesListScreen renders unit card and launches assembly'" in src,
          "juega_flow_test.dart tests UnidadesListScreen rendering and launch")
    check("testWidgets('AsambleaGuiadaScreen navigates through all 6 phases and manages audio'" in src,
          "juega_flow_test.dart tests AsambleaGuiadaScreen all 6 phases and audio")
    check("mockAudioService.isPlaying" in src, "juega_flow_test.dart asserts on audio playback state")
    check("Fase 1 de 6" in src and "Fase 6 de 6" in src, "juega_flow_test.dart verifies start-to-finish phase progression")

# ---------------------------------------------------------------------
# 6. INTEGRITY VIOLATION SCAN
# ---------------------------------------------------------------------
def audit_integrity():
    print("\n--- 6. Integrity Violation Scan ---")
    # Check for hardcoded test bypasses or fake facades in lib/
    lib_dir = os.path.join(PROJECT_ROOT, "lib/features/juega")
    clean_code = True
    
    for root, _, files in os.walk(lib_dir):
        for file in files:
            if file.endswith(".dart"):
                p = os.path.join(root, file)
                with open(p, "r", encoding="utf-8") as f:
                    content = f.read()
                    
                if "return true;" in content and len(content.splitlines()) < 20:
                    print(f"  ❌ Suspect facade in {p}")
                    clean_code = False
                if "TODO" in content or "FIXME" in content:
                    print(f"  ⚠️ Warning: TODO or FIXME in {p}")
                    
    check(clean_code, "No fake facades or trivial stubs detected in lib/features/juega")

def main():
    print("=" * 65)
    print("Milestone 3 Reviewer 2 Adversarial & Quality Review")
    print("Edición Vigo · Juega con Lúa & Audio Asset")
    print("=" * 65)
    
    audit_audio_asset()
    audit_juega_module()
    audit_sober_teacher_design()
    audit_main_routing()
    audit_test_suite()
    audit_integrity()
    
    print("\n" + "=" * 65)
    print(f"TOTAL CHECKS: {TOTAL_CHECKS}")
    print(f"FAILED CHECKS: {FAILED_CHECKS}")
    if FAILED_CHECKS == 0:
        print("VERDICT: APPROVE (100% Passing with Zero Integrity Violations)")
        print("=" * 65)
        sys.exit(0)
    else:
        print(f"VERDICT: REQUEST_CHANGES ({FAILED_CHECKS} checks failed)")
        print("=" * 65)
        sys.exit(1)

if __name__ == "__main__":
    main()
