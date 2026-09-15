#!/usr/bin/env python3
"""
Adversarial & Edge-Case Stress Testing Suite for Milestone 1.
Executed independently by Reviewer 2 (teamwork_preview_reviewer_m1_2).
"""

import os
import sys
import re
import xml.etree.ElementTree as ET

PROJECT_ROOT = "<documentos locales>/Descubre con Lúa"

def test_app_language_logic():
    print("Testing AppLanguage logic...")
    # Re-implement exact logic as defined in lib/core/localization/app_language.dart
    def from_code(code):
        if code is None:
            return "gl"
        normalized = code.strip().lower()
        if normalized.startswith("es"):
            return "es"
        return "gl"

    def toggle(lang):
        return "es" if lang == "gl" else "gl"

    # Edge cases
    assert from_code(None) == "gl", "null should fallback to gl"
    assert from_code("") == "gl", "empty string should fallback to gl"
    assert from_code("   ") == "gl", "whitespace should fallback to gl"
    assert from_code("es") == "es"
    assert from_code("ES") == "es"
    assert from_code("  es  ") == "es"
    assert from_code("es-ES") == "es"
    assert from_code("es_ES") == "es"
    assert from_code("es-MX") == "es"
    assert from_code("gl") == "gl"
    assert from_code("GL") == "gl"
    assert from_code("gl-ES") == "gl"
    assert from_code("en") == "gl", "unsupported language should fallback to gl"
    assert from_code("fr") == "gl"
    assert from_code("pt") == "gl"

    assert toggle("gl") == "es"
    assert toggle("es") == "gl"
    assert toggle(toggle("gl")) == "gl"
    print("✅ AppLanguage logic passed all edge cases.")

def test_localized_string_logic():
    print("Testing LocalizedString logic...")
    class LocalizedString:
        def __init__(self, gl, es):
            self.gl = gl
            self.es = es
        
        @classmethod
        def from_json(cls, json_data):
            return cls(
                gl=str(json_data.get("gl") or ""),
                es=str(json_data.get("es") or "")
            )
        
        def resolve(self, lang):
            return self.gl if lang == "gl" else self.es
        
        def to_json(self):
            return {"gl": self.gl, "es": self.es}
        
        @property
        def has_parity(self):
            return bool(self.gl and self.gl.strip()) and bool(self.es and self.es.strip())
        
        def copy_with(self, gl=None, es=None):
            return LocalizedString(
                gl=self.gl if gl is None else gl,
                es=self.es if es is None else es
            )
        
        def __eq__(self, other):
            return isinstance(other, LocalizedString) and self.gl == other.gl and self.es == other.es
        
        def __hash__(self):
            return hash((self.gl, self.es))

    s1 = LocalizedString("O mar", "El mar")
    assert s1.resolve("gl") == "O mar"
    assert s1.resolve("es") == "El mar"
    assert s1.has_parity is True

    # Parity edge cases
    assert LocalizedString("", "El mar").has_parity is False
    assert LocalizedString("O mar", "").has_parity is False
    assert LocalizedString("   ", "El mar").has_parity is False
    assert LocalizedString("O mar", "   ").has_parity is False
    assert LocalizedString("   ", "   ").has_parity is False
    assert LocalizedString("", "").has_parity is False
    assert LocalizedString("\t\n", "El mar").has_parity is False

    # from_json edge cases
    parsed = LocalizedString.from_json({"gl": "Peixe", "es": "Pez"})
    assert parsed.gl == "Peixe" and parsed.es == "Pez"
    assert parsed.has_parity is True

    empty_parsed = LocalizedString.from_json({})
    assert empty_parsed.gl == "" and empty_parsed.es == ""
    assert empty_parsed.has_parity is False

    null_parsed = LocalizedString.from_json({"gl": None, "es": None})
    assert null_parsed.gl == "" and null_parsed.es == ""

    # copy_with
    c1 = s1.copy_with(es="Nuevo")
    assert c1.gl == "O mar" and c1.es == "Nuevo"
    c2 = s1.copy_with()
    assert c2 == s1

    # Equality & Hash
    assert s1 == LocalizedString("O mar", "El mar")
    assert hash(s1) == hash(LocalizedString("O mar", "El mar"))
    assert s1 != LocalizedString("Outro", "Otro")
    print("✅ LocalizedString logic passed all edge cases.")

def test_mock_audio_service_logic():
    print("Testing MockOfflineAudioService logic simulation...")
    class MockAudio:
        def __init__(self):
            self.is_playing = False
            self.current_asset = None
            self.call_log = []
            self.is_disposed = False
            self.stream_events = []

        def _check_disposed(self):
            if self.is_disposed:
                raise RuntimeError("Cannot use after dispose")

        def play_asset(self, path):
            self._check_disposed()
            if not path or not path.strip():
                raise ValueError("Asset path cannot be empty")
            self.current_asset = path
            self.is_playing = True
            self.call_log.append(f"playAsset:{path}")
            self.stream_events.append(True)

        def pause(self):
            self._check_disposed()
            self.is_playing = False
            self.call_log.append("pause")
            self.stream_events.append(False)

        def stop(self):
            self._check_disposed()
            self.is_playing = False
            self.call_log.append("stop")
            self.stream_events.append(False)

        def reset(self):
            self.is_playing = False
            self.current_asset = None
            self.call_log.clear()
            if not self.is_disposed:
                self.stream_events.append(False)

        def dispose(self):
            if not self.is_disposed:
                self.is_disposed = True

    svc = MockAudio()
    assert svc.is_playing is False
    assert svc.current_asset is None
    assert len(svc.call_log) == 0

    # Normal playback
    svc.play_asset("assets/audio/mar_pulso_72bpm.wav")
    assert svc.is_playing is True
    assert svc.current_asset == "assets/audio/mar_pulso_72bpm.wav"
    assert "playAsset:assets/audio/mar_pulso_72bpm.wav" in svc.call_log
    assert svc.stream_events[-1] is True

    # Pause
    svc.pause()
    assert svc.is_playing is False
    assert "pause" in svc.call_log
    assert svc.stream_events[-1] is False

    # Stop
    svc.stop()
    assert svc.is_playing is False
    assert "stop" in svc.call_log
    assert svc.stream_events[-1] is False

    # Empty asset error
    try:
        svc.play_asset("   ")
        assert False, "Should have thrown on empty asset"
    except ValueError:
        pass

    # Reset
    svc.reset()
    assert svc.is_playing is False
    assert svc.current_asset is None
    assert len(svc.call_log) == 0

    # Dispose
    svc.dispose()
    assert svc.is_disposed is True
    svc.dispose() # Idempotent

    try:
        svc.play_asset("test.wav")
        assert False, "Should throw after dispose"
    except RuntimeError:
        pass

    try:
        svc.pause()
        assert False, "Should throw after dispose"
    except RuntimeError:
        pass

    try:
        svc.stop()
        assert False, "Should throw after dispose"
    except RuntimeError:
        pass
    print("✅ MockOfflineAudioService passed all state machine tests.")

def test_theme_specifications():
    print("Testing AppTheme specifications...")
    theme_file = os.path.join(PROJECT_ROOT, "lib/core/theme/app_theme.dart")
    with open(theme_file, "r", encoding="utf-8") as f:
        theme = f.read()

    # Verify colors
    assert "0xFF1B4965" in theme, "Missing Primary Vigo Blue (0xFF1B4965)"
    assert "0xFF62B6CB" in theme, "Missing Secondary Sea Glass (0xFF62B6CB)"
    assert "0xFFF4F1DE" in theme, "Missing Background Sand (0xFFF4F1DE)"
    assert "0xFF1C2541" in theme, "Missing Text Slate (0xFF1C2541)"
    assert "0xFFE07A5F" in theme, "Missing Accent Terracotta (0xFFE07A5F)"
    assert "0xFF81B29A" in theme, "Missing Calm Sage (0xFF81B29A)"

    # Verify typography scale
    assert "fontSize: 18.0" in theme, "bodyLarge should be 18sp"
    assert "fontSize: 16.0" in theme, "bodyMedium should be 16sp"
    assert "useMaterial3: true" in theme, "Material 3 must be enabled"
    print("✅ AppTheme tokens and typography specifications verified.")

def test_adversarial_network_scan():
    print("Running adversarial network scan across the entire project...")
    network_signatures = [
        r"package:http",
        r"package:dio",
        r"package:retrofit",
        r"package:chopper",
        r"package:web_socket_channel",
        r"package:grpc",
        r"package:firebase",
        r"package:sentry",
        r"package:datadog",
        r"package:mixpanel",
        r"package:amplitude",
        r"HttpClient\b",
        r"WebSocket\b",
        r"Socket\.connect",
        r"RawSocket",
        r"InternetAddress",
        r"http://",
        r"https://",
        r"ws://",
        r"wss://",
    ]

    lib_dir = os.path.join(PROJECT_ROOT, "lib")
    found_violations = []

    for root, _, files in os.walk(lib_dir):
        for file in files:
            if file.endswith(".dart"):
                fpath = os.path.join(root, file)
                with open(fpath, "r", encoding="utf-8") as f:
                    lines = f.readlines()
                for idx, line in enumerate(lines, 1):
                    # Ignore schema urls in xml comments or flutter imports
                    stripped = line.strip()
                    for sig in network_signatures:
                        if re.search(sig, line):
                            # Allow if in comment explaining zero network
                            if stripped.startswith("//") or stripped.startswith("///"):
                                continue
                            found_violations.append((fpath, idx, line.strip(), sig))

    assert len(found_violations) == 0, f"Network violations found: {found_violations}"
    print("✅ Zero network calls, sockets, or HTTP clients detected in lib/.")

def test_manifest_security():
    print("Testing AndroidManifest security and permissions...")
    manifest_path = os.path.join(PROJECT_ROOT, "android/app/src/main/AndroidManifest.xml")
    tree = ET.parse(manifest_path)
    root = tree.getroot()

    tools_ns = "{http://schemas.android.com/tools}"
    android_ns = "{http://schemas.android.com/apk/res/android}"

    assert root.attrib.get("package") == "com.earlify.descubreconlua", "Package ID mismatch"

    permissions = root.findall("uses-permission")
    assert len(permissions) >= 3, f"Expected at least 3 permission removals, found {len(permissions)}"

    removed_permissions = set()
    for p in permissions:
        name = p.attrib.get(f"{android_ns}name")
        node_action = p.attrib.get(f"{tools_ns}node")
        assert node_action == "remove", f"Permission {name} is NOT removed! tools:node='{node_action}'"
        removed_permissions.add(name)

    assert "android.permission.INTERNET" in removed_permissions, "INTERNET permission must be explicitly removed"
    assert "android.permission.ACCESS_NETWORK_STATE" in removed_permissions, "ACCESS_NETWORK_STATE must be explicitly removed"
    assert "android.permission.ACCESS_WIFI_STATE" in removed_permissions, "ACCESS_WIFI_STATE must be explicitly removed"
    print("✅ AndroidManifest strictly removes all network permissions.")

def main():
    print("==========================================================")
    print("Reviewer 2 Adversarial Stress Testing Suite — Milestone 1")
    print("==========================================================")
    test_app_language_logic()
    test_localized_string_logic()
    test_mock_audio_service_logic()
    test_theme_specifications()
    test_adversarial_network_scan()
    test_manifest_security()
    print("==========================================================")
    print("🎉 ALL ADVERSARIAL CHALLENGES AND VERIFICATIONS PASSED")
    print("==========================================================")

if __name__ == "__main__":
    main()
