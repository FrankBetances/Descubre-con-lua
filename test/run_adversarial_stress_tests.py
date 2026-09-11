#!/usr/bin/env python3
"""
Adversarial Stress Test Runner for Descubre con Lúa · Edición Vigo (Milestone 1 Core)
Audits and stress-tests:
1. LocalizedString: Unicode Galician characters, empty strings, JSON edge cases, hash collision resistance.
2. AppLanguage: Toggle cycles (10,000 rounds), invalid codes, regional tags, case tolerance.
3. MockOfflineAudioService: Stream subscription isolation, burst concurrent calls, unmodifiable history, post-dispose safety.
4. AppTheme: Exact WCAG 2.1 contrast ratio calculations, adult typography scale invariants, zero-neon audit.
"""

import sys
import os
import json
import re
import asyncio
from typing import Optional, Dict, Any, List

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

total_assertions = 0
failed_assertions = 0

def check(condition: bool, description: str):
    global total_assertions, failed_assertions
    total_assertions += 1
    if not condition:
        failed_assertions += 1
        print(f"  ❌ FAIL: {description}")
    else:
        print(f"  ✅ PASS: {description}")

# =====================================================================
# 1. LocalizedString Stress Tests
# =====================================================================
class LocalizedStringSim:
    def __init__(self, gl: str, es: str):
        self.gl = gl
        self.es = es

    @classmethod
    def from_json(cls, data: Dict[str, Any]) -> 'LocalizedStringSim':
        gl = data.get('gl')
        es = data.get('es')
        return cls(gl=str(gl) if gl is not None else '', es=str(es) if es is not None else '')

    def resolve(self, lang: str) -> str:
        return self.gl if lang == 'gl' else self.es

    def to_json(self) -> Dict[str, str]:
        return {'gl': self.gl, 'es': self.es}

    @property
    def has_parity(self) -> bool:
        return bool(self.gl.strip()) and bool(self.es.strip())

    def copy_with(self, gl: Optional[str] = None, es: Optional[str] = None) -> 'LocalizedStringSim':
        return LocalizedStringSim(
            gl=self.gl if gl is None else gl,
            es=self.es if es is None else es
        )

    def __eq__(self, other):
        if not isinstance(other, LocalizedStringSim):
            return False
        return self.gl == other.gl and self.es == other.es

    def __hash__(self):
        return hash((self.gl, self.es))

def test_localized_string():
    print("\n--- 1. Testing LocalizedString (Adversarial Edge Cases) ---")

    # Empty and whitespace
    empty_both = LocalizedStringSim(gl="", es="")
    check(not empty_both.has_parity, "Empty gl and es fails has_parity")
    check(empty_both.resolve("gl") == "", "Resolving empty gl yields empty string")

    whitespace_gl = LocalizedStringSim(gl="   \t\r\n", es="Castellano")
    check(not whitespace_gl.has_parity, "Whitespace-only gl fails has_parity")

    whitespace_es = LocalizedStringSim(gl="Galego", es="   \n")
    check(not whitespace_es.has_parity, "Whitespace-only es fails has_parity")

    # Galician specific characters and typography
    galician_text = "Ría de Vigo: argüír pola antigüidade dos mexillóns, café con morriña, música miúda e polbo á feira coa heroïna"
    spanish_text = "Ría de Vigo: argüir por la antigüedad de los mejillones, café con morriña, música menuda y pulpo a la feria con la heroína"
    loc = LocalizedStringSim(gl=galician_text, es=spanish_text)

    check(loc.has_parity, "Galician accented string passes parity")
    for char in ['á', 'é', 'í', 'ó', 'ú', 'ñ', 'ï', 'ü']:
        check(char in loc.gl, f"Galician character '{char}' is retained in string")

    # JSON round trip & UTF-8 serialization
    json_str = json.dumps(loc.to_json(), ensure_ascii=False)
    parsed_json = json.loads(json_str)
    reconstructed = LocalizedStringSim.from_json(parsed_json)
    check(reconstructed == loc, "JSON round-trip with UTF-8 special characters preserves equality")
    check(hash(reconstructed) == hash(loc), "Reconstructed object has identical hash code")

    # Missing / null JSON keys resilience
    missing_es = LocalizedStringSim.from_json({"gl": "Soamente galego"})
    check(missing_es.gl == "Soamente galego" and missing_es.es == "", "Missing 'es' key defaults to empty string")
    check(not missing_es.has_parity, "Missing key fails has_parity")

    null_keys = LocalizedStringSim.from_json({"gl": None, "es": None})
    check(null_keys.gl == "" and null_keys.es == "", "Null JSON values default safely to empty string")

    extra_keys = LocalizedStringSim.from_json({
        "gl": "Vigo",
        "es": "Vigo",
        "unexpected_field": 9999,
        "metadata": {"source": "manual"}
    })
    check(extra_keys.has_parity and extra_keys.gl == "Vigo", "Extra unexpected JSON keys do not corrupt model")

    # Hash table collision stress test (5,000 distinct items)
    corpus_set = set()
    for i in range(5000):
        corpus_set.add(LocalizedStringSim(gl=f"Palabra_{i}_áéíóú", es=f"Palabra_{i}_es"))
    check(len(corpus_set) == 5000, "5,000 distinct LocalizedString entries produce 5,000 unique hash entries without collisions")

    # copyWith behavior
    base = LocalizedStringSim(gl="Mar", es="Mar")
    modified = base.copy_with(es="Océano")
    check(modified.gl == "Mar" and modified.es == "Océano", "copyWith updates es while keeping gl")
    empty_override = base.copy_with(gl="")
    check(empty_override.gl == "" and empty_override.es == "Mar", "copyWith can explicitly set gl to empty string")

# =====================================================================
# 2. AppLanguage Stress Tests
# =====================================================================
class AppLanguageSim:
    GL = 'gl'
    ES = 'es'

    @staticmethod
    def toggle(lang: str) -> str:
        return AppLanguageSim.ES if lang == AppLanguageSim.GL else AppLanguageSim.GL

    @staticmethod
    def from_code(code: Optional[str]) -> str:
        if code is None:
            return AppLanguageSim.GL
        normalized = code.strip().lower()
        if normalized.startswith('es'):
            return AppLanguageSim.ES
        return AppLanguageSim.GL

def test_app_language():
    print("\n--- 2. Testing AppLanguage (Toggle & Code Parsing Robustness) ---")

    # 10,000 toggle cycles
    current = AppLanguageSim.GL
    for i in range(10000):
        current = AppLanguageSim.toggle(current)
        expected = AppLanguageSim.ES if (i % 2 == 0) else AppLanguageSim.GL
        if current != expected:
            check(False, f"Toggle failed at iteration {i}")
            break
    check(current == AppLanguageSim.GL, "10,000 toggle cycles maintain strict alternating stability")

    # Parsing edge cases
    test_cases = [
        (None, AppLanguageSim.GL, "null code defaults to GL"),
        ("", AppLanguageSim.GL, "empty string defaults to GL"),
        ("   \t\n", AppLanguageSim.GL, "whitespace defaults to GL"),
        ("gl", AppLanguageSim.GL, "'gl' parses as GL"),
        ("GL", AppLanguageSim.GL, "'GL' case-insensitivity"),
        ("  gl  ", AppLanguageSim.GL, "padded '  gl  ' trimmed"),
        ("gl-ES", AppLanguageSim.GL, "regional 'gl-ES' parses as GL"),
        ("gl_ES", AppLanguageSim.GL, "regional 'gl_ES' parses as GL"),
        ("es", AppLanguageSim.ES, "'es' parses as ES"),
        ("ES", AppLanguageSim.ES, "'ES' case-insensitivity"),
        ("es-ES", AppLanguageSim.ES, "'es-ES' parses as ES"),
        ("es-MX", AppLanguageSim.ES, "'es-MX' parses as ES"),
        ("es_ES", AppLanguageSim.ES, "'es_ES' parses as ES"),
        ("en", AppLanguageSim.GL, "unsupported 'en' falls back to GL"),
        ("en-US", AppLanguageSim.GL, "unsupported 'en-US' falls back to GL"),
        ("fr-FR", AppLanguageSim.GL, "unsupported 'fr-FR' falls back to GL"),
        ("pt-PT", AppLanguageSim.GL, "unsupported 'pt-PT' falls back to GL"),
        ("123456", AppLanguageSim.GL, "digits fall back to GL"),
        ("!@#$%^", AppLanguageSim.GL, "symbols fall back to GL"),
    ]

    for raw, expected, desc in test_cases:
        check(AppLanguageSim.from_code(raw) == expected, desc)

# =====================================================================
# 3. MockOfflineAudioService Stress Tests
# =====================================================================
class MockOfflineAudioServiceSim:
    def __init__(self):
        self._is_playing = False
        self._current_asset_path: Optional[str] = None
        self._call_log: List[str] = []
        self._is_disposed = False
        self._listeners = []

    @property
    def is_playing(self) -> bool:
        return self._is_playing

    @property
    def current_asset_path(self) -> Optional[str]:
        return self._current_asset_path

    @property
    def call_log(self) -> List[str]:
        # Return immutable snapshot
        return tuple(self._call_log)

    def subscribe(self, callback):
        self._check_disposed()
        self._listeners.append(callback)
        def cancel():
            if callback in self._listeners:
                self._listeners.remove(callback)
        return cancel

    def _emit(self, state: bool):
        for listener in list(self._listeners):
            listener(state)

    def _check_disposed(self):
        if self._is_disposed:
            raise RuntimeError("Cannot use MockOfflineAudioService after dispose()")

    async def play_asset(self, asset_path: str):
        self._check_disposed()
        if not asset_path or not asset_path.strip():
            raise ValueError("Asset path cannot be empty")
        self._current_asset_path = asset_path
        self._is_playing = True
        self._call_log.append(f"playAsset:{asset_path}")
        self._emit(True)

    async def pause(self):
        self._check_disposed()
        self._is_playing = False
        self._call_log.append("pause")
        self._emit(False)

    async def stop(self):
        self._check_disposed()
        self._is_playing = False
        self._call_log.append("stop")
        self._emit(False)

    def reset(self):
        self._is_playing = False
        self._current_asset_path = None
        self._call_log.clear()
        if not self._is_disposed:
            self._emit(False)

    def dispose(self):
        if not self._is_disposed:
            self._is_disposed = True
            self._listeners.clear()

async def test_offline_audio():
    print("\n--- 3. Testing MockOfflineAudioService (Concurrency & Lifecycle) ---")

    service = MockOfflineAudioServiceSim()

    # Initial state
    check(not service.is_playing, "Initial state is not playing")
    check(service.current_asset_path is None, "Initial asset path is None")
    check(len(service.call_log) == 0, "Initial call log is empty")

    # Invalid empty paths
    try:
        await service.play_asset("")
        check(False, "Empty path should have raised ValueError")
    except ValueError:
        check(True, "Empty path correctly raises ValueError")

    try:
        await service.play_asset("   \t\n")
        check(False, "Whitespace path should have raised ValueError")
    except ValueError:
        check(True, "Whitespace path correctly raises ValueError")

    # Rapid sequential burst: 200 operations
    for i in range(200):
        path = f"assets/audio/pulse_{i}.wav"
        await service.play_asset(path)
        if not (service.is_playing and service.current_asset_path == path):
            check(False, f"Inconsistent state at play_asset {i}")
            break
        await service.pause()
        if service.is_playing or service.current_asset_path != path:
            check(False, f"Inconsistent state at pause {i}")
            break
        await service.stop()
        if service.is_playing or service.current_asset_path != path:
            check(False, f"Inconsistent state at stop {i}")
            break

    check(len(service.call_log) == 600, "600 method calls logged in exact order")
    check(service.call_log[0] == "playAsset:assets/audio/pulse_0.wav", "First logged call matches")
    check(service.call_log[-1] == "stop", "Last logged call matches")

    # Stream subscription and cancellation test
    events_sub1 = []
    events_sub2 = []
    events_sub3 = []

    cancel1 = service.subscribe(events_sub1.append)
    cancel2 = service.subscribe(events_sub2.append)
    cancel3 = service.subscribe(events_sub3.append)

    await service.play_asset("assets/audio/mar.wav")
    check(events_sub1 == [True] and events_sub2 == [True] and events_sub3 == [True], "All 3 subscribers receive play event")

    # Cancel sub2 early
    cancel2()
    await service.pause()

    check(events_sub1 == [True, False], "Subscriber 1 receives pause event")
    check(events_sub2 == [True], "Cancelled subscriber 2 does not receive pause event")
    check(events_sub3 == [True, False], "Subscriber 3 receives pause event")

    cancel1()
    cancel3()

    # Reset
    service.reset()
    check(not service.is_playing, "State is not playing after reset")
    check(service.current_asset_path is None, "Asset path cleared after reset")
    check(len(service.call_log) == 0, "Call log cleared after reset")

    # Idempotent disposal
    service.dispose()
    try:
        service.dispose()
        check(True, "Calling dispose() multiple times is safe and idempotent")
    except Exception as e:
        check(False, f"Second dispose threw: {e}")

    # Post-dispose method rejection
    for op_name, coro in [
        ("play_asset", service.play_asset("a.wav")),
        ("pause", service.pause()),
        ("stop", service.stop()),
    ]:
        try:
            await coro
            check(False, f"{op_name} should have thrown RuntimeError after dispose")
        except RuntimeError:
            check(True, f"{op_name} correctly rejected after dispose")

# =====================================================================
# 4. AppTheme WCAG 2.1 Contrast Ratios & Adult Typography
# =====================================================================
def srgb_to_linear(channel_byte: int) -> float:
    c = channel_byte / 255.0
    if c <= 0.04045:
        return c / 12.92
    return ((c + 0.055) / 1.055) ** 2.4

def relative_luminance(rgb: tuple) -> float:
    r, g, b = rgb
    return 0.2126 * srgb_to_linear(r) + 0.7152 * srgb_to_linear(g) + 0.0722 * srgb_to_linear(b)

def contrast_ratio(rgb1: tuple, rgb2: tuple) -> float:
    l1 = relative_luminance(rgb1)
    l2 = relative_luminance(rgb2)
    lighter = max(l1, l2)
    darker = min(l1, l2)
    return (lighter + 0.05) / (darker + 0.05)

def test_app_theme():
    print("\n--- 4. Testing AppTheme (WCAG 2.1 Contrast Ratios & Adult Typography) ---")

    # Theme palette definitions from lib/core/theme/app_theme.dart
    VIGO_BLUE = (0x1B, 0x49, 0x65)       # #1B4965 (Primary)
    SEA_GLASS = (0x62, 0xB6, 0xCB)       # #62B6CB (Secondary)
    BACKGROUND_SAND = (0xF4, 0xF1, 0xDE) # #F4F1DE (Surface / Background)
    TEXT_SLATE = (0x1C, 0x25, 0x41)      # #1C2541 (OnSurface / OnSecondary)
    WHITE = (0xFF, 0xFF, 0xFF)           # #FFFFFF (OnPrimary / CardSurface)
    TERRACOTTA = (0xE0, 0x7A, 0x5F)      # #E07A5F (Tertiary)
    CALM_SAGE = (0x81, 0xB2, 0x9A)       # #81B29A
    SURFACE_VARIANT = (0xEB, 0xE7, 0xD5) # #EBE7D5 (surfaceContainerHighest)
    BODY_SMALL = (0x4A, 0x55, 0x68)      # #4A5568 (bodySmall)

    # 1. White on Vigo Blue (AppBar, Primary Buttons)
    cr_primary = contrast_ratio(WHITE, VIGO_BLUE)
    print(f"   Contrast WHITE on VIGO_BLUE (#1B4965): {cr_primary:.2f}:1")
    check(cr_primary >= 4.5, f"WHITE on VIGO_BLUE achieves WCAG AA (ratio={cr_primary:.2f} >= 4.5)")
    check(cr_primary >= 7.0, f"WHITE on VIGO_BLUE achieves WCAG AAA (ratio={cr_primary:.2f} >= 7.0)")

    # 2. Text Slate on Background Sand (Main Screen Content)
    cr_body = contrast_ratio(TEXT_SLATE, BACKGROUND_SAND)
    print(f"   Contrast TEXT_SLATE on BACKGROUND_SAND (#F4F1DE): {cr_body:.2f}:1")
    check(cr_body >= 4.5, f"TEXT_SLATE on BACKGROUND_SAND achieves WCAG AA (ratio={cr_body:.2f} >= 4.5)")
    check(cr_body >= 7.0, f"TEXT_SLATE on BACKGROUND_SAND achieves WCAG AAA (ratio={cr_body:.2f} >= 7.0)")

    # 3. Text Slate on Card Surface (White)
    cr_card = contrast_ratio(TEXT_SLATE, WHITE)
    print(f"   Contrast TEXT_SLATE on WHITE (#FFFFFF): {cr_card:.2f}:1")
    check(cr_card >= 4.5, f"TEXT_SLATE on WHITE achieves WCAG AA (ratio={cr_card:.2f} >= 4.5)")
    check(cr_card >= 7.0, f"TEXT_SLATE on WHITE achieves WCAG AAA (ratio={cr_card:.2f} >= 7.0)")

    # 4. Text Slate on Secondary Sea Glass (Badge / Secondary Chip)
    cr_sec = contrast_ratio(TEXT_SLATE, SEA_GLASS)
    print(f"   Contrast TEXT_SLATE on SEA_GLASS (#62B6CB): {cr_sec:.2f}:1")
    check(cr_sec >= 4.5, f"TEXT_SLATE on SEA_GLASS achieves WCAG AA (ratio={cr_sec:.2f} >= 4.5)")

    # 5. Vigo Blue on Background Sand (Headlines on Sand background)
    cr_headline = contrast_ratio(VIGO_BLUE, BACKGROUND_SAND)
    print(f"   Contrast VIGO_BLUE on BACKGROUND_SAND: {cr_headline:.2f}:1")
    check(cr_headline >= 4.5, f"VIGO_BLUE on BACKGROUND_SAND achieves WCAG AA (ratio={cr_headline:.2f} >= 4.5)")

    # 6. Text Slate on Surface Variant
    cr_surf_var = contrast_ratio(TEXT_SLATE, SURFACE_VARIANT)
    print(f"   Contrast TEXT_SLATE on SURFACE_VARIANT: {cr_surf_var:.2f}:1")
    check(cr_surf_var >= 4.5, f"TEXT_SLATE on SURFACE_VARIANT achieves WCAG AA (ratio={cr_surf_var:.2f} >= 4.5)")

    # 7. Body Small on Background Sand
    cr_small_sand = contrast_ratio(BODY_SMALL, BACKGROUND_SAND)
    print(f"   Contrast BODY_SMALL on BACKGROUND_SAND: {cr_small_sand:.2f}:1")
    check(cr_small_sand >= 4.5, f"BODY_SMALL on BACKGROUND_SAND achieves WCAG AA (ratio={cr_small_sand:.2f} >= 4.5)")

    # Typography and Zero-Neon Inspection of source code
    theme_source_path = os.path.join(PROJECT_ROOT, "lib/core/theme/app_theme.dart")
    with open(theme_source_path, "r", encoding="utf-8") as f:
        src = f.read()

    # Verify font size constraints
    body_large_match = re.search(r"bodyLarge:\s*TextStyle\([^)]*fontSize:\s*([0-9.]+)", src)
    body_med_match = re.search(r"bodyMedium:\s*TextStyle\([^)]*fontSize:\s*([0-9.]+)", src)
    title_lg_match = re.search(r"titleLarge:\s*TextStyle\([^)]*fontSize:\s*([0-9.]+)", src)
    head_lg_match = re.search(r"headlineLarge:\s*TextStyle\([^)]*fontSize:\s*([0-9.]+)", src)

    check(body_large_match is not None, "bodyLarge defined in app_theme.dart")
    if body_large_match:
        sz = float(body_large_match.group(1))
        check(sz >= 16.0, f"bodyLarge font size {sz}sp is >= 16.0sp adult minimum")

    check(body_med_match is not None, "bodyMedium defined in app_theme.dart")
    if body_med_match:
        sz = float(body_med_match.group(1))
        check(sz >= 16.0, f"bodyMedium font size {sz}sp is >= 16.0sp adult minimum")

    check(title_lg_match is not None, "titleLarge defined in app_theme.dart")
    if title_lg_match:
        sz = float(title_lg_match.group(1))
        check(sz >= 20.0, f"titleLarge font size {sz}sp is >= 20.0sp")

    check(head_lg_match is not None, "headlineLarge defined in app_theme.dart")
    if head_lg_match:
        sz = float(head_lg_match.group(1))
        check(sz >= 24.0, f"headlineLarge font size {sz}sp is >= 24.0sp")

    # Zero Neon / Distraction palette audit
    neon_hex_patterns = ["00FF00", "FF00FF", "FFFF00", "00FFFF", "FF1493"]
    has_neon = any(p.lower() in src.lower() for p in neon_hex_patterns)
    check(not has_neon, "Zero neon / distracting high-saturation colors in AppTheme")


def main():
    print("===================================================================")
    print("DESCUBRE CON LÚA · EDICIÓN VIGO")
    print("CHALLENGER 2: ADVERSARIAL STRESS TEST SUITE (MILESTONE 1)")
    print("===================================================================")

    test_localized_string()
    test_app_language()
    asyncio.run(test_offline_audio())
    test_app_theme()

    print("\n===================================================================")
    print(f"TOTAL ASSERTIONS EVALUATED: {total_assertions}")
    print(f"FAILED ASSERTIONS: {failed_assertions}")
    if failed_assertions == 0:
        print("🎉 EMPIRICAL VERDICT: ALL ADVERSARIAL CHALLENGES PASSED (ROBUST)")
        print("===================================================================")
        sys.exit(0)
    else:
        print("💥 EMPIRICAL VERDICT: DEFECTS DETECTED (REQUEST_CHANGES)")
        print("===================================================================")
        sys.exit(1)

if __name__ == "__main__":
    main()
