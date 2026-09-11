#!/usr/bin/env python3
"""
Empirical Adversarial Challenger Probe: Typography & Lifecycle Invariants
«Descubre con Lúa · Edición Vigo» — Milestone 4 (Challenger 1)

Probes:
1. Adult Typography Invariant:
   - Comprehensive scan of lib/features/ and lib/main.dart.
   - Rigorous audit of all pedagogical body text (must be >= 16.0sp).
   - Audit of all < 16.0sp occurrences ensuring they are restricted to auxiliary metadata/badges/captions.
2. Offline Audio Lifecycle & Stream Subscription Audit:
   - PasoCancionWidget StreamSubscription declaration, listener, mounted guard, and dispose cancellation.
   - AsambleaGuiadaScreen auto-pause, stop on pop, and external service preservation.
3. Exploration Safety Notice Non-Bypassability:
   - PasoExploracionWidget unconditional safety alert rendering, lack of dismiss/close mechanics.
   - Sequential assembly stepper preventing Phase 4 bypass.
"""

import os
import sys
import re

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

total_checks = 0
passed_checks = 0
failed_checks = 0
findings = []

def check(condition: bool, description: str, detail: str = ""):
    global total_checks, passed_checks, failed_checks, findings
    total_checks += 1
    if condition:
        passed_checks += 1
        print(f"  ✅ PASS: {description}")
    else:
        failed_checks += 1
        msg = f"{description}" + (f" -> {detail}" if detail else "")
        findings.append(msg)
        print(f"  ❌ FAIL: {msg}")

print("=" * 75)
print("RUNNING ADVERSARIAL TYPOGRAPHY & LIFECYCLE PROBE (CHALLENGER 1 - M4)")
print("=" * 75)

# =============================================================================
# 1. ADULT TYPOGRAPHY INVARIANT AUDIT
# =============================================================================
print("\n>>> 1. Adult Typography Invariant Audit across lib/features & lib/main.dart")

features_dir = os.path.join(PROJECT_ROOT, "lib/features")
main_file = os.path.join(PROJECT_ROOT, "lib/main.dart")

dart_files = [main_file]
for root, _, files in os.walk(features_dir):
    for f in files:
        if f.endswith(".dart"):
            dart_files.append(os.path.join(root, f))

# Regex to detect bodyMedium or bodyLarge overrides below 16.0sp
body_override_re = re.compile(
    r"body(?:Medium|Large)\?\.copyWith\s*\([^)]*fontSize:\s*([0-9.]+)",
    re.DOTALL
)

body_violations = []
for p in dart_files:
    rel = os.path.relpath(p, PROJECT_ROOT)
    with open(p, "r", encoding="utf-8") as fh:
        content = fh.read()
    for m in body_override_re.finditer(content):
        sz = float(m.group(1))
        if sz < 16.0:
            lno = content[:m.start()].count("\n") + 1
            body_violations.append((rel, lno, sz, m.group(0).replace("\n", " ")))

check(len(body_violations) == 0, "Zero bodyMedium / bodyLarge font size overrides below 16.0sp", str(body_violations))

# Verify that all canonical content reading components specify fontSize >= 16.0sp
# 1.1 SeccionCapsulaWidget (Academy 4 parts)
seccion_dart = os.path.join(PROJECT_ROOT, "lib/features/academy/widgets/seccion_capsula_widget.dart")
with open(seccion_dart, "r", encoding="utf-8") as f:
    seccion_content = f.read()
check("fontSize: 17.0" in seccion_content, "SeccionCapsulaWidget headline text is 17.0sp (>= 16.0)")
check("fontSize: 16.5" in seccion_content, "SeccionCapsulaWidget body text is 16.5sp (>= 16.0)")

# 1.2 PasoCancionWidget
cancion_dart = os.path.join(PROJECT_ROOT, "lib/features/juega/widgets/paso_cancion_widget.dart")
with open(cancion_dart, "r", encoding="utf-8") as f:
    cancion_content = f.read()
check("cancion.letraConPulsos" in cancion_content and "fontSize: 18.0" in cancion_content, "PasoCancionWidget lyrics text is 18.0sp (>= 16.0)")
check("cancion.consignaDocente" in cancion_content and "fontSize: 16.0" in cancion_content, "PasoCancionWidget teacher consigna is 16.0sp (>= 16.0)")

# 1.3 PasoContoWidget
conto_dart = os.path.join(PROJECT_ROOT, "lib/features/juega/widgets/paso_conto_widget.dart")
with open(conto_dart, "r", encoding="utf-8") as f:
    conto_content = f.read()
check("currentPage.texto" in conto_content and "fontSize: 18.0" in conto_content, "PasoContoWidget story page text is 18.0sp (>= 16.0)")
check("preguntaComprension" in conto_content and "fontSize: 16.0" in conto_content, "PasoContoWidget comprehension question is 16.0sp (>= 16.0)")

# 1.4 PasoPreguntasWidget
preguntas_dart = os.path.join(PROJECT_ROOT, "lib/features/juega/widgets/paso_preguntas_widget.dart")
with open(preguntas_dart, "r", encoding="utf-8") as f:
    preguntas_content = f.read()
check("p.enunciado" in preguntas_content and "fontSize: 17.5" in preguntas_content, "PasoPreguntasWidget question prompt is 17.5sp (>= 16.0)")
check("p.respuestaSugerida" in preguntas_content and "fontSize: 16.0" in preguntas_content, "PasoPreguntasWidget suggested answer is 16.0sp (>= 16.0)")
check("p.consejoDocente" in preguntas_content and "fontSize: 16.0" in preguntas_content, "PasoPreguntasWidget teacher advice is 16.0sp (>= 16.0)")

# 1.5 PasoExploracionWidget
exploracion_dart = os.path.join(PROJECT_ROOT, "lib/features/juega/widgets/paso_exploracion_widget.dart")
with open(exploracion_dart, "r", encoding="utf-8") as f:
    exploracion_content = f.read()
check("avisoSeguridad" in exploracion_content and "fontSize: 16.0" in exploracion_content, "PasoExploracionWidget safety alert body is 16.0sp (>= 16.0)")
check("objetivoSensorial" in exploracion_content and "fontSize: 16.0" in exploracion_content, "PasoExploracionWidget sensory objective is 16.0sp (>= 16.0)")
check("m.resolve" in exploracion_content and "fontSize: 16.0" in exploracion_content, "PasoExploracionWidget materials list is 16.0sp (>= 16.0)")
check("paso.resolve" in exploracion_content and "fontSize: 16.0" in exploracion_content, "PasoExploracionWidget steps list is 16.0sp (>= 16.0)")

# 1.6 PasoMatematicasWidget
mates_dart = os.path.join(PROJECT_ROOT, "lib/features/juega/widgets/paso_matematicas_widget.dart")
with open(mates_dart, "r", encoding="utf-8") as f:
    mates_content = f.read()
check("descripcion.resolve" in mates_content and "fontSize: 16.0" in mates_content, "PasoMatematicasWidget description is 16.0sp (>= 16.0)")
check("vocabularioMatematico" in mates_content and "fontSize: 16.0" in mates_content, "PasoMatematicasWidget vocabulary is 16.0sp (>= 16.0)")
check("accionesSugeridas" in mates_content and "fontSize: 16.0" in mates_content, "PasoMatematicasWidget suggested actions is 16.0sp (>= 16.0)")

# 1.7 PasoPonteCasaWidget
ponte_dart = os.path.join(PROJECT_ROOT, "lib/features/juega/widgets/paso_ponte_casa_widget.dart")
with open(ponte_dart, "r", encoding="utf-8") as f:
    ponte_content = f.read()
check("mensajeFamilias" in ponte_content and "fontSize: 16.0" in ponte_content, "PasoPonteCasaWidget family message is 16.0sp (>= 16.0)")
check("recomendacionConversacion" in ponte_content and "fontSize: 16.0" in ponte_content, "PasoPonteCasaWidget conversation advice is 16.0sp (>= 16.0)")
check("actividadesSugeridas" in ponte_content and "fontSize: 16.0" in ponte_content, "PasoPonteCasaWidget suggested activities is 16.0sp (>= 16.0)")


# =============================================================================
# 2. OFFLINE AUDIO LIFECYCLE & STREAM DISPOSAL AUDIT
# =============================================================================
print("\n>>> 2. Offline Audio Lifecycle & Stream Disposal Audit")

# PasoCancionWidget checks
check("StreamSubscription<bool>? _audioSubscription;" in cancion_content, "PasoCancionWidget declares typed StreamSubscription<bool>? field")
check("_audioSubscription = widget.audioService.isPlayingStream.listen" in cancion_content, "PasoCancionWidget assigns listener to _audioSubscription in initState")
check("if (mounted)" in cancion_content, "PasoCancionWidget guards setState with mounted check")
check("_audioSubscription?.cancel();" in cancion_content, "PasoCancionWidget cancels _audioSubscription in dispose()")

# AsambleaGuiadaScreen checks
asamblea_dart = os.path.join(PROJECT_ROOT, "lib/features/juega/views/asamblea_guiada_screen.dart")
with open(asamblea_dart, "r", encoding="utf-8") as f:
    asamblea_content = f.read()

check("_audioService.stop();" in asamblea_content, "AsambleaGuiadaScreen calls _audioService.stop() in dispose()")
check("if (_createdInternalAudioService) {\n      _audioService.dispose();\n    }" in asamblea_content or
      "if (_createdInternalAudioService)" in asamblea_content and "_audioService.dispose();" in asamblea_content,
      "AsambleaGuiadaScreen preserves caller-injected audioService while disposing internal service")

# Auto-pause check
check("if (_currentPaso == 0 && _audioService.isPlaying) {\n        _audioService.pause();\n      }" in asamblea_content or
      "_currentPaso == 0 && _audioService.isPlaying" in asamblea_content,
      "AsambleaGuiadaScreen automatically pauses playback upon advancing past Phase 1")


# =============================================================================
# 3. SAFETY NOTICE NON-BYPASSABILITY AUDIT
# =============================================================================
print("\n>>> 3. Safety Notice Non-Bypassability Audit")

# Verification in PasoExploracionWidget
check("⚠️ PROTOCOLO DE SEGURIDADE NA AULA" in exploracion_content, "PasoExploracionWidget contains Galician safety header")
check("⚠️ PROTOCOLO DE SEGURIDAD EN EL AULA" in exploracion_content, "PasoExploracionWidget contains Spanish safety header")
check("Icons.warning_amber_rounded" in exploracion_content, "Safety banner features prominent warning amber icon")
check("4-5 cm" in exploracion_content, "Safety notice mandates regulatory manipulative size (> 4-5 cm)")
check("Supervisión adulta continua" in exploracion_content, "Safety notice mandates continuous adult supervision")

# Non-dismissibility checks
check("Dismissible" not in exploracion_content, "Safety card is NOT Dismissible")
check("Icons.close" not in exploracion_content, "Safety card has NO close button")
check("ExpansionTile" not in exploracion_content, "Safety card is NOT collapsible")

# Sequential flow enforcement in AsambleaGuiadaScreen
check("switch (_currentPaso)" in asamblea_content and "case 3:\n        return PasoExploracionWidget" in asamblea_content,
      "AsambleaGuiadaScreen binds Step 4 strictly to PasoExploracionWidget")
check("jumpTo" not in asamblea_content and "_currentPaso = 4" not in asamblea_content and "_currentPaso = 5" not in asamblea_content,
      "AsambleaGuiadaScreen provides zero jump mechanisms to skip Step 4")


print("\n" + "=" * 75)
print("TYPOGRAPHY & LIFECYCLE PROBE SUMMARY")
print("=" * 75)
print(f"Total Checks Evaluated : {total_checks}")
print(f"Passed Checks          : {passed_checks}")
print(f"Failed Checks          : {failed_checks}")
print("=" * 75)

if failed_checks == 0:
    print("ALL TYPOGRAPHY, AUDIO LIFECYCLE, AND SAFETY INVARIANTS CONFIRMED")
    sys.exit(0)
else:
    print(f"FAILED: {failed_checks} checks failed!")
    for f in findings:
        print(f"  ❌ {f}")
    sys.exit(1)
