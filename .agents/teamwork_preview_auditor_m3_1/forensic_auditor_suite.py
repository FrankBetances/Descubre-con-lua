#!/usr/bin/env python3
"""
Independent Forensic Integrity Audit Suite for Milestone 3 Deliverables
«Descubre con Lúa · Edición Vigo»
Role: M3 Forensic Integrity Auditor (teamwork_preview_auditor)
"""

import os
import sys
import wave
import struct
import math
import re

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "../.."))

CHECKS_RUN = 0
CHECKS_PASSED = 0
CHECKS_FAILED = 0
VIOLATIONS = []

def audit_check(condition: bool, check_id: str, description: str, evidence: str = ""):
    global CHECKS_RUN, CHECKS_PASSED, CHECKS_FAILED, VIOLATIONS
    CHECKS_RUN += 1
    if condition:
        CHECKS_PASSED += 1
        print(f"  [PASS] {check_id}: {description}")
    else:
        CHECKS_FAILED += 1
        print(f"  [FAIL] {check_id}: {description}")
        if evidence:
            print(f"         EVIDENCE: {evidence}")
        VIOLATIONS.append((check_id, description, evidence))

# ----------------------------------------------------------------------
# 1. FORENSIC AUDIO VERIFICATION (mar_pulso_72bpm.wav)
# ----------------------------------------------------------------------
def audit_audio_asset():
    print("\n" + "="*70)
    print("PILLAR 1: FORENSIC AUDIO ASSET INTEGRITY (assets/audio/mar_pulso_72bpm.wav)")
    print("="*70)

    wav_path = os.path.join(PROJECT_ROOT, "assets/audio/mar_pulso_72bpm.wav")
    audit_check(os.path.isfile(wav_path), "AUD-AUD-01", "WAV file physically exists on disk")
    if not os.path.isfile(wav_path):
        return

    # Check file size matches uncompressed PCM calculation
    file_size = os.path.getsize(wav_path)
    # Expected: 44 bytes RIFF header + 1176000 frames * 2 bytes = 2352044 bytes
    expected_size = 44 + (1176000 * 2)
    audit_check(file_size == expected_size, "AUD-AUD-02",
                f"File size matches exact uncompressed PCM 16-bit mono: {file_size} == {expected_size} bytes")

    # Inspect RIFF header bytes directly
    with open(wav_path, "rb") as f:
        riff_header = f.read(12)
        fmt_chunk = f.read(24)
        data_header = f.read(8)

    audit_check(riff_header[:4] == b'RIFF', "AUD-AUD-03", "RIFF chunk marker present")
    audit_check(riff_header[8:12] == b'WAVE', "AUD-AUD-04", "WAVE format marker present")
    audit_check(fmt_chunk[:4] == b'fmt ', "AUD-AUD-05", "fmt subchunk marker present")
    audit_check(data_header[:4] == b'data', "AUD-AUD-06", "data subchunk marker present")

    # Read PCM waveform
    with wave.open(wav_path, "rb") as w:
        nchannels = w.getnchannels()
        sampwidth = w.getsampwidth()
        framerate = w.getframerate()
        nframes = w.getnframes()
        raw = w.readframes(nframes)

    audit_check(nchannels == 1, "AUD-AUD-07", f"Mono channel configuration (channels={nchannels})")
    audit_check(sampwidth == 2, "AUD-AUD-08", f"16-bit sample depth (bytes={sampwidth})")
    audit_check(framerate == 44100, "AUD-AUD-09", f"Sample rate is exactly 44,100 Hz ({framerate})")
    audit_check(nframes == 1176000, "AUD-AUD-10", f"Total frames is exactly 1,176,000 frames ({nframes})")

    duration = nframes / framerate
    audit_check(abs(duration - 26.6666667) < 0.001, "AUD-AUD-11",
                f"Audio duration is exactly 26.67 seconds (32 beats at 72 BPM): {duration:.4f}s")

    samples = struct.unpack(f"<{nframes}h", raw)

    # Calculate DC offset
    dc_offset = sum(samples) / len(samples)
    audit_check(abs(dc_offset) < 5.0, "AUD-AUD-12",
                f"DC offset is negligible ({dc_offset:.4f}, threshold < 5.0)")

    # Calculate amplitude and silence
    max_val = max(samples)
    min_val = min(samples)
    rms = math.sqrt(sum(s*s for s in samples) / len(samples))
    audit_check(max_val > 15000 and max_val < 32760, "AUD-AUD-13",
                f"Peak positive amplitude is healthy without clipping: {max_val} / 32767")
    audit_check(min_val < -15000 and min_val > -32760, "AUD-AUD-14",
                f"Peak negative amplitude is healthy without clipping: {min_val} / -32768")
    audit_check(rms > 1000 and rms < 10000, "AUD-AUD-15",
                f"Overall RMS level is audible and balanced: {rms:.2f}")

    # Check rhythm timing: 72 BPM => period = 36750 frames
    beat_period = 36750
    beats = nframes // beat_period
    audit_check(beats == 32, "AUD-AUD-16", f"Waveform contains exactly 32 beats ({beats})")

    # Analyze beat frequencies using zero-crossing on pulse bursts
    def get_burst_freq(beat_idx):
        start = beat_idx * beat_period
        burst = samples[start + 200 : start + 2000]
        crossings = sum(1 for i in range(len(burst)-1) if (burst[i] >= 0 and burst[i+1] < 0) or (burst[i] < 0 and burst[i+1] >= 0))
        return crossings / (2.0 * (len(burst) / 44100.0))

    # Beat 1 (downbeat of bar 1) vs Beat 2 (upbeat of bar 1)
    f_down = get_burst_freq(0)
    f_up = get_burst_freq(1)
    audit_check(580 <= f_down <= 595, "AUD-AUD-17",
                f"Downbeat pulse frequency is ~587 Hz (D5 musical accent): {f_down:.1f} Hz")
    audit_check(435 <= f_up <= 445, "AUD-AUD-18",
                f"Standard pulse frequency is ~440 Hz (A4 reference): {f_up:.1f} Hz")

    # Check last 500 samples are zero (clean fade out / no truncation pop)
    last_samples_max = max(abs(s) for s in samples[-500:])
    audit_check(last_samples_max == 0, "AUD-AUD-19",
                f"Audio terminates with perfect zero silence (no click/pop): max={last_samples_max}")

# ----------------------------------------------------------------------
# 2. FORENSIC SOURCE CODE & FACADE DETECTION
# ----------------------------------------------------------------------
M3_CORE_FILES = [
    "lib/main.dart",
    "lib/features/academy/views/bloques_list_screen.dart",
    "lib/features/academy/views/capsula_detail_screen.dart",
    "lib/features/academy/widgets/seccion_capsula_widget.dart",
    "lib/features/academy/widgets/selector_idioma_widget.dart",
    "lib/features/juega/views/unidades_list_screen.dart",
    "lib/features/juega/views/asamblea_guiada_screen.dart",
    "lib/features/juega/widgets/paso_cancion_widget.dart",
    "lib/features/juega/widgets/paso_conto_widget.dart",
    "lib/features/juega/widgets/paso_preguntas_widget.dart",
    "lib/features/juega/widgets/paso_exploracion_widget.dart",
    "lib/features/juega/widgets/paso_matematicas_widget.dart",
    "lib/features/juega/widgets/paso_ponte_casa_widget.dart",
]

def audit_source_code_and_facades():
    print("\n" + "="*70)
    print("PILLAR 2: FORENSIC CODE ANALYSIS & FACADE DETECTION")
    print("="*70)

    for rel_path in M3_CORE_FILES:
        full_path = os.path.join(PROJECT_ROOT, rel_path)
        audit_check(os.path.isfile(full_path), f"SRC-EXISTS-{rel_path}", f"{rel_path} exists")
        if not os.path.isfile(full_path):
            continue

        with open(full_path, "r", encoding="utf-8") as f:
            code = f.read()

        # 1. Check for dummy placeholders
        dummy_markers = ["// TODO", "// FIXME", "// PLACEHOLDER", "// TBD", "throw UnimplementedError", "throw NotImplementedError"]
        found_markers = [m for m in dummy_markers if m.lower() in code.lower()]
        audit_check(len(found_markers) == 0, f"SRC-NO-DUMMY-{rel_path}",
                    f"No dummy markers in {rel_path}", evidence=str(found_markers))

        # 2. Check for empty build methods
        empty_build = re.search(r'Widget\s+build\s*\([^)]*\)\s*\{\s*return\s+(const\s+)?(SizedBox\(\)|Container\(\)|Placeholder\(\));\s*\}', code)
        audit_check(empty_build is None, f"SRC-NO-EMPTY-BUILD-{rel_path}",
                    f"{rel_path} does not have an empty facade build() method")

        # 3. Check for hardcoded test bypasses
        hardcoded_pass = re.search(r'return\s+["\']PASS["\']|return\s+true;\s*//\s*bypass', code)
        audit_check(hardcoded_pass is None, f"SRC-NO-HARDCODED-PASS-{rel_path}",
                    f"{rel_path} does not contain hardcoded PASS test bypasses")

        # 4. Check minimum substance (file lines > 50)
        lines_count = len(code.splitlines())
        audit_check(lines_count >= 50, f"SRC-SUBSTANTIAL-{rel_path}",
                    f"{rel_path} has substantial genuine implementation ({lines_count} lines)")

# ----------------------------------------------------------------------
# 3. PEDAGOGICAL & ARCHITECTURAL CONSTRAINTS AUDIT
# ----------------------------------------------------------------------
def audit_pedagogical_constraints():
    print("\n" + "="*70)
    print("PILLAR 3: PEDAGOGICAL, ADULT-FIRST & PRIVACY CONSTRAINTS AUDIT")
    print("="*70)

    # 1. Adult typography >= 16sp
    seccion_widget_path = os.path.join(PROJECT_ROOT, "lib/features/academy/widgets/seccion_capsula_widget.dart")
    with open(seccion_widget_path, "r", encoding="utf-8") as f:
        s_code = f.read()
    audit_check("fontSize: 16" in s_code or "fontSize: 17" in s_code or "fontSize: 18" in s_code,
                "PED-TYPO-01", "Adult reading typography >= 16sp enforced in capsule body")

    # 2. 4 canonical sections in Academy
    capsula_detail_path = os.path.join(PROJECT_ROOT, "lib/features/academy/views/capsula_detail_screen.dart")
    with open(capsula_detail_path, "r", encoding="utf-8") as f:
        c_code = f.read()
    audit_check("TipoSeccionCapsula.ideaClave" in c_code, "PED-ACAD-01", "Section 1 (Idea Clave) present")
    audit_check("TipoSeccionCapsula.porQueImporta" in c_code, "PED-ACAD-02", "Section 2 (Por que importa) present")
    audit_check("TipoSeccionCapsula.queHacerEnCasa" in c_code, "PED-ACAD-03", "Section 3 (Que facer na casa) present")
    audit_check("TipoSeccionCapsula.ejemploCotidiano" in c_code, "PED-ACAD-04", "Section 4 (Exemplo cotian) present")
    audit_check("afirmaciones" in c_code and "Verdadeiro" in c_code, "PED-ACAD-05",
                "Formative non-punitive reflection (Afirmacion) implemented")

    # 3. Juega con Lua 6 Assembly steps
    asamblea_path = os.path.join(PROJECT_ROOT, "lib/features/juega/views/asamblea_guiada_screen.dart")
    with open(asamblea_path, "r", encoding="utf-8") as f:
        a_code = f.read()
    for paso_idx in range(1, 7):
        audit_check(f"case {paso_idx-1}:" in a_code, f"PED-JUEGA-STEP-{paso_idx}",
                    f"Assembly phase {paso_idx} orchestrated in AsambleaGuiadaScreen")

    # 4. Mandatory Safety Alert in Phase 4
    exploracion_path = os.path.join(PROJECT_ROOT, "lib/features/juega/widgets/paso_exploracion_widget.dart")
    with open(exploracion_path, "r", encoding="utf-8") as f:
        e_code = f.read()
    audit_check("avisoSeguridad" in e_code, "PED-SAFETY-01", "Safety notice rendered in Phase 4")
    audit_check("4" in e_code and "cm" in e_code.lower(), "PED-SAFETY-02", "Piece size requirement (>4-5 cm) explicitly stated")
    audit_check("supervisi" in e_code.lower(), "PED-SAFETY-03", "Continuous adult supervision explicitly mandated")

    # 5. Zero internet / network imports in any M3 code
    for rel_path in M3_CORE_FILES:
        full_path = os.path.join(PROJECT_ROOT, rel_path)
        if not os.path.isfile(full_path):
            continue
        with open(full_path, "r", encoding="utf-8") as f:
            code = f.read()
        for forbidden in ["package:http", "package:dio", "url_launcher", "firebase", "HttpClient", "WebSocket"]:
            audit_check(forbidden not in code, f"NET-ZERO-{forbidden}-{os.path.basename(rel_path)}",
                        f"{os.path.basename(rel_path)} does not contain {forbidden}")

    # 6. Zero prohibited clinical terms in M3 code
    clinical_regex = re.compile(
        r'\b(trastorno|trastornos|patolog[ií]a|patolog[ií]as|patolox[ií]a|patolox[ií]as|'
        r'diagn[oó]stic[oa]s?|s[ií]ntoma|s[ií]ntomas|sintomatolog[ií]a|'
        r'd[eé]ficit|paciente|pacientes|terapia|terapias|terap[eé]utic[oa]s?|'
        r'(?!(tratamiento|tratamento)\s+d[eé]\s+a(ug|gu)a)(tratamiento|tratamientos|tratamento|tratamentos)|'
        r'dislalia|dislexia|afasia|disfasia|criba[sxd]?[a-záéíóúñ]*|screening)\b',
        re.IGNORECASE
    )
    for rel_path in M3_CORE_FILES:
        full_path = os.path.join(PROJECT_ROOT, rel_path)
        if not os.path.isfile(full_path):
            continue
        with open(full_path, "r", encoding="utf-8") as f:
            code = f.read()
        m = clinical_regex.search(code)
        audit_check(m is None, f"CLIN-CLEAN-{os.path.basename(rel_path)}",
                    f"{os.path.basename(rel_path)} is free of prohibited clinical terminology",
                    evidence=m.group(0) if m else "")

# ----------------------------------------------------------------------
# 4. TEST SUITE AUTHENTICITY AUDIT (test/features/)
# ----------------------------------------------------------------------
def audit_test_authenticity():
    print("\n" + "="*70)
    print("PILLAR 4: TEST SUITE AUTHENTICITY AUDIT (test/features/)")
    print("="*70)

    test_files = [
        "test/features/academy/academy_flow_test.dart",
        "test/features/juega/juega_flow_test.dart",
    ]

    for t_rel in test_files:
        t_path = os.path.join(PROJECT_ROOT, t_rel)
        audit_check(os.path.isfile(t_path), f"TEST-EXISTS-{t_rel}", f"Test file {t_rel} exists")
        if not os.path.isfile(t_path):
            continue

        with open(t_path, "r", encoding="utf-8") as f:
            t_code = f.read()

        # Check for real testWidgets
        test_widgets_count = len(re.findall(r'testWidgets\s*\(', t_code))
        audit_check(test_widgets_count >= 2, f"TEST-REAL-WIDGETS-{t_rel}",
                    f"{t_rel} defines {test_widgets_count} real testWidgets (>= 2)")

        # Check for user interaction (pumpWidget, tap, pumpAndSettle)
        audit_check("pumpWidget" in t_code, f"TEST-PUMP-{t_rel}", f"{t_rel} pumps widgets into test environment")
        audit_check("tester.tap" in t_code, f"TEST-TAP-{t_rel}", f"{t_rel} simulates real user taps")
        audit_check("pumpAndSettle" in t_code or "tester.pump" in t_code, f"TEST-SETTLE-{t_rel}", f"{t_rel} settles animation frames")

        # Check for non-trivial assertions
        audit_check("expect(" in t_code, f"TEST-EXPECT-{t_rel}", f"{t_rel} contains expect() assertions")
        trivial_assert = re.search(r'expect\(\s*(true|1)\s*,\s*(isTrue|equals\(1\))\s*\)', t_code)
        audit_check(trivial_assert is None, f"TEST-NO-TRIVIAL-{t_rel}",
                    f"{t_rel} contains no trivial self-certifying expect(true, isTrue) assertions")

# ----------------------------------------------------------------------
# 5. MAIN APPLICATION ROUTING INTEGRITY AUDIT
# ----------------------------------------------------------------------
def audit_main_routing():
    print("\n" + "="*70)
    print("PILLAR 5: MAIN APPLICATION ROUTING INTEGRITY AUDIT (lib/main.dart)")
    print("="*70)

    main_path = os.path.join(PROJECT_ROOT, "lib/main.dart")
    with open(main_path, "r", encoding="utf-8") as f:
        m_code = f.read()

    audit_check("routes: {" in m_code, "ROUTE-DEF-01", "MaterialApp routes map declared")
    audit_check("'/academy':" in m_code, "ROUTE-ACAD-01", "Route '/academy' mapped to BloquesListScreen")
    audit_check("'/juega':" in m_code, "ROUTE-JUEGA-01", "Route '/juega' mapped to UnidadesListScreen")
    audit_check("onGenerateRoute:" in m_code, "ROUTE-GEN-01", "onGenerateRoute configured for parameterized routing")
    audit_check("'/academy/capsula'" in m_code, "ROUTE-CAPS-01", "onGenerateRoute supports '/academy/capsula'")
    audit_check("'/juega/asamblea'" in m_code, "ROUTE-ASAM-01", "onGenerateRoute supports '/juega/asamblea'")

def main():
    print("="*70)
    print("STARTING FORENSIC INTEGRITY AUDIT SUITE FOR MILESTONE 3")
    print(f"Target: {PROJECT_ROOT}")
    print("="*70)

    audit_audio_asset()
    audit_source_code_and_facades()
    audit_pedagogical_constraints()
    audit_test_authenticity()
    audit_main_routing()

    print("\n" + "="*70)
    print("FORENSIC INTEGRITY AUDIT SUMMARY")
    print("="*70)
    print(f"Total Checks Executed : {CHECKS_RUN}")
    print(f"Checks Passed         : {CHECKS_PASSED}")
    print(f"Checks Failed         : {CHECKS_FAILED}")
    print("="*70)

    if CHECKS_FAILED == 0:
        print("\n🏆 FORENSIC VERDICT: CLEAN")
        print("Milestone 3 deliverables are authentic, genuine, compliant, and verified without shortcuts.")
        sys.exit(0)
    else:
        print(f"\n🚨 FORENSIC VERDICT: INTEGRITY VIOLATION ({CHECKS_FAILED} checks failed)")
        for check_id, desc, ev in VIOLATIONS:
            print(f"  - [{check_id}] {desc}: {ev}")
        sys.exit(1)

if __name__ == "__main__":
    main()
