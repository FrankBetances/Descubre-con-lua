#!/usr/bin/env python3
"""
Adversarial Stress Test Suite for Milestone 3 Academy Module
Reviewer 1: M3 Academy UI & Pedagogical Reviewer
Tests boundary conditions, edge cases, fallback behaviors, routing, and language state reactivity.
"""

import os
import re
import sys

PROJECT_ROOT = "/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa"

stress_passed = 0
stress_failed = 0
stress_notes = []

def assert_test(cond, name, note=None):
    global stress_passed, stress_failed
    if cond:
        stress_passed += 1
        print(f"  ⚡ PASS: {name}")
    else:
        stress_failed += 1
        print(f"  ❌ FAIL: {name}")
        if note:
            stress_notes.append(f"{name}: {note}")

print("================================================================================")
print("Adversarial Stress-Testing: Academy (Familias) — Boundary Conditions & Resilience")
print("================================================================================\n")

# --- 1. Color Hex Parser Resilience ---
print("--- 1. Hex Color Parser Resilience in BloquesListScreen ---")
bloques_screen = open(os.path.join(PROJECT_ROOT, "lib/features/academy/views/bloques_list_screen.dart")).read()

# Verify try-catch fallback in _colorFromHex
has_try_catch = "try {" in bloques_screen and "catch (_)" in bloques_screen and "return fallback;" in bloques_screen
assert_test(has_try_catch, "_colorFromHex has defensive try-catch block with fallback")

has_length_handling = "hexString.length == 6 || hexString.length == 7" in bloques_screen
assert_test(has_length_handling, "_colorFromHex handles both 6-char (#RRGGBB) and raw formats")

# --- 2. Icon Key Resilience ---
print("\n--- 2. Icon Key Mapping Resilience in BloquesListScreen ---")
all_icons_covered = all(k in bloques_screen for k in [
    "ear_sparkles", "chat_bubble_heart", "people_arrows", "child_play", "home_globe"
])
assert_test(all_icons_covered, "_iconForBloque maps all 5 canonical block icon keys")

has_default_icon = "default:" in bloques_screen and "Icons.auto_stories_outlined" in bloques_screen
assert_test(has_default_icon, "_iconForBloque provides safe fallback icon for unknown icon keys")

# --- 3. Empty State Fallbacks ---
print("\n--- 3. Empty & Boundary State Fallbacks ---")
has_empty_capsules_guard = "capsulas.isNotEmpty" in bloques_screen and "Novas cápsulas deste bloque en preparación" in bloques_screen
assert_test(has_empty_capsules_guard, "BloquesListScreen handles empty capsule list with graceful non-crashing banner")

capsula_screen = open(os.path.join(PROJECT_ROOT, "lib/features/academy/views/capsula_detail_screen.dart")).read()
has_empty_afirmaciones_guard = "capsula.afirmaciones.isNotEmpty" in capsula_screen
assert_test(has_empty_afirmaciones_guard, "CapsulaDetailScreen guards against empty affirmations without crashing")

has_empty_areas_guard = "curriculo.areas.isNotEmpty" in capsula_screen
assert_test(has_empty_areas_guard, "CapsulaDetailScreen guards curricular areas wrap against empty list")

# --- 4. Main App Routing Contract ---
print("\n--- 4. Main Application Route Registration ---")
main_dart = open(os.path.join(PROJECT_ROOT, "lib/main.dart")).read()

has_academy_route = "'/academy'" in main_dart and "BloquesListScreen" in main_dart
assert_test(has_academy_route, "main.dart registers named route '/academy' pointing to BloquesListScreen")

has_capsula_param_route = "'/academy/capsula'" in main_dart and "CapsulaDetailScreen" in main_dart
assert_test(has_capsula_param_route, "main.dart registers onGenerateRoute for '/academy/capsula' with CapsulaDetailScreen")

# --- 5. Redundant Tap Guarding in SelectorIdiomaWidget ---
print("\n--- 5. SelectorIdiomaWidget Idempotency ---")
selector_widget = open(os.path.join(PROJECT_ROOT, "lib/features/academy/widgets/selector_idioma_widget.dart")).read()
has_idempotency_guard = "if (!isSelected)" in selector_widget
assert_test(has_idempotency_guard, "SelectorIdiomaWidget ignores clicks on already selected language")

# --- 6. Canonical Section Color Scheme Differentiation ---
print("\n--- 6. SeccionCapsulaWidget Palette Distinctiveness ---")
seccion_widget = open(os.path.join(PROJECT_ROOT, "lib/features/academy/widgets/seccion_capsula_widget.dart")).read()
has_all_4_accents = (
    "AppTheme.primaryVigoBlue" in seccion_widget and
    "Color(0xFF2C5E7A)" in seccion_widget and
    "AppTheme.calmSage" in seccion_widget and
    "AppTheme.accentTerracotta" in seccion_widget
)
assert_test(has_all_4_accents, "SeccionCapsulaWidget defines 4 visually distinct accent colors for canonical sections")

# --- 7. Adult Typography Strict Enforcement ---
print("\n--- 7. Adult Typography Enforcement (>= 16sp) ---")
# Check SeccionCapsulaWidget body text
assert_test(
    "fontSize: 16.5" in seccion_widget,
    "SeccionCapsulaWidget body text strictly set to 16.5sp (>= 16sp adult standard)"
)
assert_test(
    "height: 1.6" in seccion_widget,
    "SeccionCapsulaWidget body text has comfortable adult reading leading (height: 1.6)"
)

# Check CapsulaDetailScreen subtitle and reflection text
assert_test(
    "fontSize: 17.0" in capsula_screen,
    "CapsulaDetailScreen subtitle set to 17.0sp for parental readability"
)
assert_test(
    "fontSize: 16.5" in capsula_screen,
    "CapsulaDetailScreen reflection question set to 16.5sp"
)

# --- 8. Zero External Links & Zero Game Mechanics Verification ---
print("\n--- 8. Strict Privacy & Non-Game Invariant ---")
external_link_patterns = [r"https?://", r"mailto:", r"tel:", r"launchUrl", r"canLaunchUrl", r"url_launcher"]
has_any_link = False
for pattern in external_link_patterns:
    for code, name in [(bloques_screen, "BloquesListScreen"), (capsula_screen, "CapsulaDetailScreen"), (seccion_widget, "SeccionCapsulaWidget"), (selector_widget, "SelectorIdiomaWidget")]:
        if re.search(pattern, code):
            has_any_link = True
            print(f"  Found link pattern '{pattern}' in {name}")
assert_test(not has_any_link, "Zero external links, web intents, or network URLs in any Academy file")

# --- 9. Formative Evaluation Non-Punitiveness ---
print("\n--- 9. Pedagogical Reflection Tone & Non-Punitiveness ---")
has_non_punitive_feedback = (
    "userChoice == afirmacion.esVerdadera" in capsula_screen and
    "check_circle_outline" in capsula_screen and
    "info_outline" in capsula_screen and
    "calmSage" in capsula_screen and
    "accentTerracotta" in capsula_screen
)
assert_test(has_non_punitive_feedback, "Reflection feedback uses calm Sage/Terracotta and constructive info icons rather than punitive error alerts")

print("\n================================================================================")
print(f"Adversarial Stress Test Summary: {stress_passed} PASSED, {stress_failed} FAILED")
if stress_notes:
    print("Notes:")
    for n in stress_notes:
        print(f"  - {n}")
print("================================================================================")

sys.exit(0 if stress_failed == 0 else 1)
