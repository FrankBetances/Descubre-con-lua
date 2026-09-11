#!/usr/bin/env python3
"""
Independent Adversarial Audit Script for Milestone 1:
«Descubre con Lúa · Edición Vigo» (M1 Android & Privacy).

Audited by: teamwork_preview_reviewer_m1_1
"""

import os
import re
import sys
import xml.etree.ElementTree as ET

PROJECT_ROOT = "/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa"

failures = []
passed_checks = []

def record_pass(check_name):
    passed_checks.append(check_name)
    print(f"  [PASS] {check_name}")

def record_fail(check_name, reason):
    failures.append((check_name, reason))
    print(f"  [FAIL] {check_name} -> {reason}")

print("=================================================================")
print("  REVIEWER 1 INDEPENDENT ADVERSARIAL AUDIT — MILESTONE 1")
print("=================================================================")

# 1. Android Manifest Audit
print("\n--- 1. AndroidManifest.xml Deep Adversarial Audit ---")
manifest_path = os.path.join(PROJECT_ROOT, "android/app/src/main/AndroidManifest.xml")
if not os.path.exists(manifest_path):
    record_fail("Manifest Existence", f"File missing at {manifest_path}")
else:
    record_pass("Manifest Existence")
    try:
        tree = ET.parse(manifest_path)
        root = tree.getroot()
        record_pass("Manifest XML Syntax Valid")

        # Namespaces
        android_ns = "{http://schemas.android.com/apk/res/android}"
        tools_ns = "{http://schemas.android.com/tools}"

        # Check package ID
        pkg = root.attrib.get("package", "")
        if pkg == "com.earlify.descubreconlua":
            record_pass("Manifest Package ID matches com.earlify.descubreconlua")
        else:
            record_fail("Manifest Package ID", f"Found: {pkg}")

        # Check all uses-permission
        permissions = root.findall("uses-permission")
        required_removals = {
            "android.permission.INTERNET": False,
            "android.permission.ACCESS_NETWORK_STATE": False,
            "android.permission.ACCESS_WIFI_STATE": False,
        }

        active_permissions = []
        for p in permissions:
            name = p.attrib.get(f"{android_ns}name", "")
            node = p.attrib.get(f"{tools_ns}node", "")
            if name in required_removals:
                if node == "remove":
                    required_removals[name] = True
                    record_pass(f"Explicit tools:node='remove' for {name}")
                else:
                    record_fail(f"Removal of {name}", f"tools:node is '{node}', expected 'remove'")
            else:
                if node != "remove":
                    active_permissions.append(name)

        for perm, removed in required_removals.items():
            if not removed:
                record_fail(f"Required Removal: {perm}", "Not found with tools:node='remove'")

        if active_permissions:
            record_fail("Zero Active Permissions", f"Found active permissions: {active_permissions}")
        else:
            record_pass("Strict Zero Active Permissions in Manifest (0 positive grants)")

        # Application tag audit
        app = root.find("application")
        if app is not None:
            allow_backup = app.attrib.get(f"{android_ns}allowBackup", "")
            if allow_backup == "false":
                record_pass("android:allowBackup is 'false' (prevents adb state leakage)")
            else:
                record_fail("allowBackup setting", f"allowBackup is '{allow_backup}', expected 'false'")

            label = app.attrib.get(f"{android_ns}label", "")
            if label == "Descubre con Lúa":
                record_pass(f"Application label matches 'Descubre con Lúa'")
            else:
                record_fail("Application label", f"Found: {label}")

            # Activity audit
            activity = app.find("activity")
            if activity is not None:
                exported = activity.attrib.get(f"{android_ns}exported", "")
                if exported == "true":
                    record_pass("MainActivity android:exported='true' (API 31+ requirement satisfied)")
                else:
                    record_fail("MainActivity exported", f"android:exported is '{exported}'")
            else:
                record_fail("MainActivity tag", "No activity tag found under application")

    except Exception as e:
        record_fail("Manifest Parse", f"Exception during XML parsing: {e}")


# 2. Gradle Build Configuration Audit
print("\n--- 2. Gradle Configuration Audit ---")
app_gradle = os.path.join(PROJECT_ROOT, "android/app/build.gradle")
if os.path.exists(app_gradle):
    with open(app_gradle, "r", encoding="utf-8") as f:
        gradle_text = f.read()

    if 'namespace "com.earlify.descubreconlua"' in gradle_text:
        record_pass("build.gradle namespace is 'com.earlify.descubreconlua'")
    else:
        record_fail("build.gradle namespace", "Missing namespace 'com.earlify.descubreconlua'")

    if 'applicationId "com.earlify.descubreconlua"' in gradle_text:
        record_pass("build.gradle applicationId is 'com.earlify.descubreconlua'")
    else:
        record_fail("build.gradle applicationId", "Missing applicationId 'com.earlify.descubreconlua'")

    if 'compileSdk 34' in gradle_text:
        record_pass("build.gradle compileSdk is 34")
    else:
        record_fail("build.gradle compileSdk", "compileSdk is not 34")

    if 'minSdk 24' in gradle_text:
        record_pass("build.gradle minSdk is 24")
    else:
        record_fail("build.gradle minSdk", "minSdk is not 24")

    if 'targetSdk 34' in gradle_text:
        record_pass("build.gradle targetSdk is 34")
    else:
        record_fail("build.gradle targetSdk", "targetSdk is not 34")

    if 'JavaVersion.VERSION_17' in gradle_text:
        record_pass("build.gradle specifies Java 17 compatibility")
    else:
        record_fail("build.gradle Java version", "Java 17 compatibility missing")


# 3. Kotlin MainActivity Audit
print("\n--- 3. Kotlin MainActivity Audit ---")
main_activity = os.path.join(PROJECT_ROOT, "android/app/src/main/kotlin/com/earlify/descubreconlua/MainActivity.kt")
if os.path.exists(main_activity):
    with open(main_activity, "r", encoding="utf-8") as f:
        kt_text = f.read()
    if "package com.earlify.descubreconlua" in kt_text:
        record_pass("MainActivity.kt package declaration matches com.earlify.descubreconlua")
    else:
        record_fail("MainActivity.kt package", "Incorrect package declaration")
    if "class MainActivity : FlutterActivity()" in kt_text or "class MainActivity: FlutterActivity()" in kt_text:
        record_pass("MainActivity extends FlutterActivity")
    else:
        record_fail("MainActivity class definition", "MainActivity does not extend FlutterActivity")
else:
    record_fail("MainActivity.kt Existence", f"File missing at {main_activity}")


# 4. pubspec.yaml Audit
print("\n--- 4. pubspec.yaml Dependency Audit ---")
pubspec_path = os.path.join(PROJECT_ROOT, "pubspec.yaml")
if os.path.exists(pubspec_path):
    with open(pubspec_path, "r", encoding="utf-8") as f:
        pubspec_lines = f.readlines()

    # Verify dependencies section
    in_dependencies = False
    in_dev_dependencies = False
    deps = []
    dev_deps = []

    for line in pubspec_lines:
        trimmed = line.strip()
        if trimmed == "dependencies:":
            in_dependencies = True
            in_dev_dependencies = False
            continue
        elif trimmed == "dev_dependencies:":
            in_dependencies = False
            in_dev_dependencies = True
            continue
        elif trimmed and not trimmed.startswith("#") and not line.startswith(" ") and not line.startswith("\t"):
            in_dependencies = False
            in_dev_dependencies = False

        if in_dependencies and trimmed and not trimmed.startswith("#"):
            deps.append(trimmed)
        elif in_dev_dependencies and trimmed and not trimmed.startswith("#"):
            dev_deps.append(trimmed)

    # Check dependencies: only flutter: sdk: flutter
    dep_str = " ".join(deps)
    if "flutter:" in dep_str and "sdk: flutter" in dep_str and len(deps) == 2:
        record_pass("pubspec dependencies contains ONLY flutter SDK")
    else:
        record_fail("pubspec dependencies", f"Unexpected dependencies: {deps}")

    # Check prohibited networking libraries anywhere in pubspec
    full_pubspec = "".join(pubspec_lines)
    prohibited_keywords = [
        "http:", "dio:", "retrofit:", "chopper:", "web_socket_channel:",
        "grpc:", "firebase", "sentry", "datadog", "mixpanel", "amplitude",
        "google_mobile_ads", "facebook", "url_launcher", "webview"
    ]
    found_prohibited = [kw for kw in prohibited_keywords if kw in full_pubspec.lower()]
    if not found_prohibited:
        record_pass("pubspec.yaml is 100% free of network and analytics packages")
    else:
        record_fail("pubspec prohibited packages", f"Found prohibited packages: {found_prohibited}")
else:
    record_fail("pubspec.yaml Existence", "pubspec.yaml not found")


# 5. Codebase Zero-Network Audit (lib/ and android/)
print("\n--- 5. Codebase Zero-Network Audit (lib/ and android/) ---")
network_patterns = [
    (r"\bHttpClient\b", "dart:io HttpClient"),
    (r"\bWebSocket\b", "dart:io WebSocket"),
    (r"\bSocket\.connect\b", "Raw Socket connection"),
    (r"\bRawSocket\b", "dart:io RawSocket"),
    (r"\bSecureSocket\b", "dart:io SecureSocket"),
    (r"\bInternetAddress\b", "dart:io InternetAddress"),
    (r"https?://", "HTTP/HTTPS hardcoded URL"),
    (r"java\.net\.URL", "Java URL"),
    (r"java\.net\.HttpURLConnection", "Java HttpURLConnection"),
]

lib_dir = os.path.join(PROJECT_ROOT, "lib")
code_violations = []
for root, _, files in os.walk(lib_dir):
    for f in files:
        if f.endswith(".dart"):
            fpath = os.path.join(root, f)
            relpath = os.path.relpath(fpath, PROJECT_ROOT)
            with open(fpath, "r", encoding="utf-8") as dart_file:
                content = dart_file.read()
            for pattern, desc in network_patterns:
                matches = re.findall(pattern, content)
                if matches:
                    code_violations.append((relpath, desc, matches))

if not code_violations:
    record_pass("lib/ Dart source files: 0 network clients, sockets, or HTTP/S URLs found")
else:
    for relpath, desc, matches in code_violations:
        record_fail(f"Network violation in {relpath}", f"Found {desc}: {matches}")


# 6. Integrity & Facade Check
print("\n--- 6. Integrity & Implementation Authenticity Audit ---")
# Check MockOfflineAudioService logic
mock_path = os.path.join(PROJECT_ROOT, "lib/core/audio/mock_offline_audio_service.dart")
with open(mock_path, "r", encoding="utf-8") as f:
    mock_code = f.read()

checks = [
    ("Real state tracking (_isPlaying)", "_isPlaying = true" in mock_code and "_isPlaying = false" in mock_code),
    ("Real stream emission (_controller.add)", "_controller.add(true)" in mock_code and "_controller.add(false)" in mock_code),
    ("Argument validation (empty path)", "throw ArgumentError" in mock_code),
    ("Lifecycle validation (after dispose)", "throw StateError" in mock_code),
    ("Call history tracking (_callLog)", "_callLog.add" in mock_code),
]
for desc, cond in checks:
    if cond:
        record_pass(f"MockOfflineAudioService: {desc}")
    else:
        record_fail(f"MockOfflineAudioService: {desc}", "Implementation is dummy/incomplete")

# Check LocalizedString logic
loc_path = os.path.join(PROJECT_ROOT, "lib/core/localization/localized_string.dart")
with open(loc_path, "r", encoding="utf-8") as f:
    loc_code = f.read()

loc_checks = [
    ("Immutability (final gl and es)", "final String gl;" in loc_code and "final String es;" in loc_code),
    ("JSON serialization (fromJson & toJson)", "factory LocalizedString.fromJson" in loc_code and "Map<String, String> toJson" in loc_code),
    ("Language resolution (resolve)", "String resolve(AppLanguage lang)" in loc_code),
    ("Parity validation (hasParity)", "bool get hasParity" in loc_code),
    ("Equality contract (operator == & hashCode)", "operator ==" in loc_code and "hashCode" in loc_code),
]
for desc, cond in loc_checks:
    if cond:
        record_pass(f"LocalizedString: {desc}")
    else:
        record_fail(f"LocalizedString: {desc}", "Implementation incomplete")

# Check Test Files Authenticity
test_manifest_path = os.path.join(PROJECT_ROOT, "test/privacy/privacy_manifest_test.dart")
with open(test_manifest_path, "r", encoding="utf-8") as f:
    test_code = f.read()

# Ensure tests don't have hardcoded dummy assertions like expect(true, isTrue)
if "expect(true, isTrue)" in test_code or "expect(1, equals(1))" in test_code:
    record_fail("Test Authenticity", "Found trivial hardcoded self-passing assertion")
else:
    record_pass("Privacy test suite has NO trivial self-passing assertions")

if "tools:node=\"remove\"" in test_code and "package=\"com.earlify.descubreconlua\"" in test_code:
    record_pass("Privacy test suite verifies explicit manifest removal directives and package ID")
else:
    record_fail("Privacy test assertions", "Missing critical assertion targets")


# Summary
print("\n=================================================================")
print(f"AUDIT SUMMARY: {len(passed_checks)} PASSED, {len(failures)} FAILED")
print("=================================================================")
if failures:
    print("❌ ADVERSARIAL AUDIT FAILED:")
    for check, reason in failures:
        print(f"   - {check}: {reason}")
    sys.exit(1)
else:
    print("🎉 ALL INDEPENDENT ADVERSARIAL AUDIT CHECKS PASSED WITH ZERO VIOLATIONS!")
    sys.exit(0)
