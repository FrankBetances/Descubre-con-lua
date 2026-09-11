#!/usr/bin/env python3
"""
Empirical verification script for Milestone 1: Base Setup & Privacy.
Validates pubspec.yaml, Android scaffolding, release manifest,
clean architecture core files, and privacy constraints.
Fully self-contained: zero dependencies on .agents/.
"""

import os
import sys
import xml.etree.ElementTree as ET

PROJECT_ROOT = os.path.dirname(os.path.abspath(__file__))

def check(condition, message):
    if not condition:
        print(f"❌ FAIL: {message}")
        sys.exit(1)
    print(f"✅ PASS: {message}")

def verify_pubspec():
    pubspec_path = os.path.join(PROJECT_ROOT, "pubspec.yaml")
    check(os.path.exists(pubspec_path), "pubspec.yaml exists")
    with open(pubspec_path, "r", encoding="utf-8") as f:
        content = f.read()

    prohibited = [
        "http:", "dio:", "retrofit:", "chopper:", "web_socket_channel:",
        "grpc:", "firebase_core:", "firebase_analytics:", "firebase_auth:",
        "cloud_firestore:", "sentry_flutter:", "sentry:", "datadog_flutter:",
        "mixpanel_flutter:", "amplitude_flutter:", "google_mobile_ads:"
    ]
    for pkg in prohibited:
        check(pkg not in content, f"pubspec.yaml excludes prohibited network library: {pkg}")

    check("sdk: flutter" in content, "pubspec.yaml declares flutter sdk")
    check("assets/content/unidades/" in content, "pubspec.yaml declares assets/content/unidades/")
    check("assets/content/capsulas/" in content, "pubspec.yaml declares assets/content/capsulas/")
    check("assets/audio/" in content, "pubspec.yaml declares assets/audio/")

def verify_android_scaffolding():
    # settings.gradle
    settings_path = os.path.join(PROJECT_ROOT, "android", "settings.gradle")
    check(os.path.exists(settings_path), "android/settings.gradle exists")

    # build.gradle
    root_gradle = os.path.join(PROJECT_ROOT, "android", "build.gradle")
    check(os.path.exists(root_gradle), "android/build.gradle exists")

    # app/build.gradle
    app_gradle = os.path.join(PROJECT_ROOT, "android", "app", "build.gradle")
    check(os.path.exists(app_gradle), "android/app/build.gradle exists")
    with open(app_gradle, "r", encoding="utf-8") as f:
        gradle_content = f.read()
    check('namespace "com.earlify.descubreconlua"' in gradle_content, "app/build.gradle has namespace com.earlify.descubreconlua")
    check('applicationId "com.earlify.descubreconlua"' in gradle_content, "app/build.gradle has applicationId com.earlify.descubreconlua")
    check('compileSdk 34' in gradle_content, "app/build.gradle has compileSdk 34")
    check('minSdk 24' in gradle_content, "app/build.gradle has minSdk 24")
    check('targetSdk 34' in gradle_content, "app/build.gradle has targetSdk 34")

    # MainActivity.kt
    main_activity = os.path.join(PROJECT_ROOT, "android", "app", "src", "main", "kotlin", "com", "earlify", "descubreconlua", "MainActivity.kt")
    check(os.path.exists(main_activity), "MainActivity.kt exists in correct package directory")
    with open(main_activity, "r", encoding="utf-8") as f:
        kt_content = f.read()
    check("package com.earlify.descubreconlua" in kt_content, "MainActivity.kt has package com.earlify.descubreconlua")
    check("class MainActivity" in kt_content, "MainActivity.kt defines MainActivity class")

def verify_android_manifest():
    manifest_path = os.path.join(PROJECT_ROOT, "android", "app", "src", "main", "AndroidManifest.xml")
    check(os.path.exists(manifest_path), "AndroidManifest.xml exists")
    with open(manifest_path, "r", encoding="utf-8") as f:
        raw_xml = f.read()

    check('package="com.earlify.descubreconlua"' in raw_xml, "AndroidManifest.xml specifies package com.earlify.descubreconlua")
    check('android:label="Descubre con Lúa"' in raw_xml, "AndroidManifest.xml specifies label 'Descubre con Lúa'")
    check('xmlns:tools="http://schemas.android.com/tools"' in raw_xml, "AndroidManifest.xml declares tools namespace")

    # Parse XML
    tree = ET.parse(manifest_path)
    root = tree.getroot()

    tools_ns = "{http://schemas.android.com/tools}"
    android_ns = "{http://schemas.android.com/apk/res/android}"

    uses_permissions = root.findall("uses-permission")
    check(len(uses_permissions) >= 2, f"Found {len(uses_permissions)} uses-permission elements for explicit removal")

    has_internet_removal = False
    has_network_state_removal = False

    for elem in uses_permissions:
        name = elem.attrib.get(f"{android_ns}name", "")
        node_rule = elem.attrib.get(f"{tools_ns}node", "")
        if name == "android.permission.INTERNET":
            check(node_rule == "remove", "android.permission.INTERNET has tools:node='remove'")
            has_internet_removal = True
        elif name == "android.permission.ACCESS_NETWORK_STATE":
            check(node_rule == "remove", "android.permission.ACCESS_NETWORK_STATE has tools:node='remove'")
            has_network_state_removal = True
        else:
            # Any other permission must also be explicitly removed
            check(node_rule == "remove", f"Permission {name} must have tools:node='remove'")

    check(has_internet_removal, "Manifest contains explicit removal rule for android.permission.INTERNET")
    check(has_network_state_removal, "Manifest contains explicit removal rule for android.permission.ACCESS_NETWORK_STATE")

def verify_lib_core():
    core_files = [
        "lib/main.dart",
        "lib/core/theme/app_theme.dart",
        "lib/core/localization/app_language.dart",
        "lib/core/localization/localized_string.dart",
        "lib/core/audio/offline_audio_service.dart",
        "lib/core/audio/mock_offline_audio_service.dart",
    ]
    for rel_path in core_files:
        full_path = os.path.join(PROJECT_ROOT, rel_path)
        check(os.path.exists(full_path), f"{rel_path} exists")

    # Check AppTheme tokens
    theme_file = os.path.join(PROJECT_ROOT, "lib/core/theme/app_theme.dart")
    with open(theme_file, "r", encoding="utf-8") as f:
        theme_content = f.read()
    check("0xFF1B4965" in theme_content, "AppTheme contains primary maritime Vigo blue (#1B4965)")
    check("0xFF62B6CB" in theme_content, "AppTheme contains secondary sea glass blue (#62B6CB)")
    check("0xFFF4F1DE" in theme_content, "AppTheme contains background sand (#F4F1DE)")
    check("bodyLarge" in theme_content and "bodyMedium" in theme_content, "AppTheme contains large readable body typography")

    # Check LocalizedString
    localized_file = os.path.join(PROJECT_ROOT, "lib/core/localization/localized_string.dart")
    with open(localized_file, "r", encoding="utf-8") as f:
        loc_content = f.read()
    check("final String gl;" in loc_content and "final String es;" in loc_content, "LocalizedString has typed gl and es fields")
    check("String resolve(AppLanguage lang)" in loc_content, "LocalizedString has resolve(AppLanguage) method")

    # Check OfflineAudioService
    audio_interface = os.path.join(PROJECT_ROOT, "lib/core/audio/offline_audio_service.dart")
    with open(audio_interface, "r", encoding="utf-8") as f:
        audio_content = f.read()
    for method in ["playAsset", "pause", "stop", "isPlayingStream", "dispose"]:
        check(method in audio_content, f"OfflineAudioService specifies {method}")

    # Check MockOfflineAudioService
    mock_audio = os.path.join(PROJECT_ROOT, "lib/core/audio/mock_offline_audio_service.dart")
    with open(mock_audio, "r", encoding="utf-8") as f:
        mock_content = f.read()
    check("implements OfflineAudioService" in mock_content, "MockOfflineAudioService implements OfflineAudioService")
    check("StreamController<bool>" in mock_content, "MockOfflineAudioService has reactive StreamController")

    # Check lib/ for zero network sockets / clients
    lib_dir = os.path.join(PROJECT_ROOT, "lib")
    for root, dirs, files in os.walk(lib_dir):
        for file in files:
            if file.endswith(".dart"):
                file_path = os.path.join(root, file)
                with open(file_path, "r", encoding="utf-8") as f:
                    code = f.read()
                check("HttpClient" not in code, f"No HttpClient in {file}")
                check("WebSocket" not in code, f"No WebSocket in {file}")
                check("Socket.connect" not in code, f"No Socket.connect in {file}")

def verify_test_files():
    tests = [
        "test/privacy/privacy_manifest_test.dart",
        "test/core/localization_test.dart",
        "test/core/offline_audio_test.dart",
        "test/core/theme_test.dart",
    ]
    for test_path in tests:
        full_path = os.path.join(PROJECT_ROOT, test_path)
        check(os.path.exists(full_path), f"Test file {test_path} exists")

def main():
    print("==================================================")
    print("Running Milestone 1 Empirical Verification Suite")
    print("==================================================")
    verify_pubspec()
    verify_android_scaffolding()
    verify_android_manifest()
    verify_lib_core()
    verify_test_files()
    print("==================================================")
    print("🎉 ALL MILESTONE 1 CHECKS PASSED WITH ZERO DEFECTS")
    print("==================================================")

if __name__ == "__main__":
    main()
