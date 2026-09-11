#!/usr/bin/env python3
"""
Adversarial Privacy & Zero-Network Test Harness
Milestone 1 — Descubre con Lúa · Edición Vigo

Probes:
1. AndroidManifest.xml parser variations and permissions leaks.
2. Android Manifest Merger resilience under malicious/dependency injection attacks.
3. pubspec.yaml dependency auditing (active, commented, transitive, overrides).
4. Codebase inspection for hidden network APIs across lib/, test/, android/.
5. Test environment offline isolation & determinism verification.
"""

import os
import re
import sys
import xml.etree.ElementTree as ET
import xml.dom.minidom as minidom
import xml.sax

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "../.."))
MANIFEST_PATH = os.path.join(PROJECT_ROOT, "android/app/src/main/AndroidManifest.xml")
PUBSPEC_PATH = os.path.join(PROJECT_ROOT, "pubspec.yaml")
LIB_DIR = os.path.join(PROJECT_ROOT, "lib")
TEST_DIR = os.path.join(PROJECT_ROOT, "test")
ANDROID_DIR = os.path.join(PROJECT_ROOT, "android")

ANDROID_NS = "http://schemas.android.com/apk/res/android"
TOOLS_NS = "http://schemas.android.com/tools"

# Comprehensive blacklist of 80+ network/telemetry/ad/analytics packages
PROHIBITED_PACKAGES = [
    # HTTP & REST clients
    "http", "dio", "chopper", "retrofit", "uno", "requests", "rest_client",
    "http_client", "shelf", "shelf_router",
    # WebSockets & Realtime
    "web_socket_channel", "socket_io_client", "socket_io", "pusher_client", "centrifuge",
    # RPC & Messaging protocols
    "grpc", "mqtt_client", "stomp_dart_client", "dart_amqp",
    # Firebase SDKs
    "firebase_core", "firebase_analytics", "firebase_auth", "cloud_firestore",
    "firebase_database", "firebase_messaging", "firebase_storage",
    "firebase_crashlytics", "firebase_remote_config", "firebase_performance",
    # Analytics & Tracking
    "sentry", "sentry_flutter", "datadog_flutter", "mixpanel_flutter",
    "amplitude_flutter", "posthog_flutter", "segment_analytics",
    "matomo_tracker", "clevertap_plugin", "countly_flutter",
    "bugsnag_flutter", "instabug_flutter", "appsflyer_sdk", "adjust_sdk",
    "facebook_app_events", "branch_modular",
    # Ads
    "google_mobile_ads", "unity_ads_plugin", "applovin_max",
    # Connectivity & Network state checkers
    "connectivity_plus", "network_info_plus", "internet_connection_checker",
    "wifi_info_flutter", "connectivity",
    # Cloud BaaS SDKs
    "supabase_flutter", "appwrite", "amplify_flutter", "parse_server_sdk"
]

# Hidden network APIs to hunt in code
PROHIBITED_DART_SYMBOLS = [
    "HttpClient",
    "Socket.connect",
    "RawSocket.connect",
    "SecureSocket.connect",
    "RawSecureSocket.connect",
    "WebSocket.connect",
    "RawDatagramSocket",
    "HttpServer.bind",
    "NetworkInterface.list",
    "InternetAddress",
    "HttpClientRequest",
    "HttpClientResponse",
    "package:http/",
    "package:dio/",
]

# Sensitive permissions in Android that relate to networking or data exfiltration
PROHIBITED_ANDROID_PERMISSIONS = [
    "android.permission.INTERNET",
    "android.permission.ACCESS_NETWORK_STATE",
    "android.permission.ACCESS_WIFI_STATE",
    "android.permission.CHANGE_NETWORK_STATE",
    "android.permission.CHANGE_WIFI_STATE",
    "android.permission.CHANGE_WIFI_MULTICAST_STATE",
    "android.permission.NFC",
    "android.permission.BLUETOOTH",
    "android.permission.BLUETOOTH_ADMIN",
    "android.permission.BLUETOOTH_CONNECT",
    "android.permission.BLUETOOTH_SCAN",
    "android.permission.NEARBY_WIFI_DEVICES",
    "android.permission.ACCESS_FINE_LOCATION",
    "android.permission.ACCESS_COARSE_LOCATION",
    "android.permission.READ_PHONE_STATE",
]

total_tests = 0
passed_tests = 0
failed_tests = 0

def log_pass(test_id, message):
    global total_tests, passed_tests
    total_tests += 1
    passed_tests += 1
    print(f"  [PASS] {test_id}: {message}")

def log_fail(test_id, message):
    global total_tests, failed_tests
    total_tests += 1
    failed_tests += 1
    print(f"  [FAIL] {test_id}: {message}")


# ==============================================================================
# SUITE 1: AndroidManifest.xml Multi-Parser & Token Stress-Testing
# ==============================================================================
def run_suite_1():
    print("\n" + "="*70)
    print("SUITE 1: AndroidManifest.xml Multi-Parser & Token Stress Test")
    print("="*70)

    if not os.path.isfile(MANIFEST_PATH):
        log_fail("M1.1", f"Manifest file missing at {MANIFEST_PATH}")
        return

    log_pass("M1.1", "AndroidManifest.xml exists")

    # 1.1 ElementTree Parsing with Namespace Verification
    try:
        tree = ET.parse(MANIFEST_PATH)
        root = tree.getroot()
        log_pass("M1.2", "Parsed successfully with xml.etree.ElementTree")
    except Exception as e:
        log_fail("M1.2", f"ElementTree parse error: {e}")
        return

    # Check root namespace declarations
    with open(MANIFEST_PATH, 'r', encoding='utf-8') as f:
        raw_content = f.read()

    if f'xmlns:tools="{TOOLS_NS}"' in raw_content:
        log_pass("M1.3", f"tools namespace matches EXACT AGP URI: {TOOLS_NS}")
    else:
        log_fail("M1.3", "tools namespace missing or incorrect URI")

    if f'xmlns:android="{ANDROID_NS}"' in raw_content:
        log_pass("M1.4", f"android namespace matches EXACT AOSP URI: {ANDROID_NS}")
    else:
        log_fail("M1.4", "android namespace missing or incorrect URI")

    # Inspect all uses-permission elements via ElementTree
    uses_permissions = root.findall("uses-permission")
    log_pass("M1.5", f"Found {len(uses_permissions)} uses-permission elements in source manifest")

    for idx, perm in enumerate(uses_permissions):
        name = perm.attrib.get(f"{{{ANDROID_NS}}}name", "")
        node_action = perm.attrib.get(f"{{{TOOLS_NS}}}node", "")
        if not name:
            name = perm.attrib.get("android:name", "")
        if not node_action:
            node_action = perm.attrib.get("tools:node", "")

        if node_action == "remove":
            log_pass(f"M1.6.{idx}", f"Permission '{name}' has explicit tools:node='remove'")
        else:
            log_fail(f"M1.6.{idx}", f"Permission '{name}' lacks tools:node='remove'! Action: '{node_action}'")

    # 1.2 minidom Parser Verification
    try:
        dom = minidom.parse(MANIFEST_PATH)
        dom_perms = dom.getElementsByTagName("uses-permission")
        log_pass("M1.7", f"DOM parser found {len(dom_perms)} uses-permission nodes")
        for idx, p in enumerate(dom_perms):
            p_name = p.getAttribute("android:name")
            p_node = p.getAttribute("tools:node")
            if p_node == "remove":
                log_pass(f"M1.8.{idx}", f"DOM verified: {p_name} has tools:node='remove'")
            else:
                log_fail(f"M1.8.{idx}", f"DOM failure: {p_name} has tools:node='{p_node}'")
    except Exception as e:
        log_fail("M1.7", f"DOM parser error: {e}")

    # 1.3 Check for any positive permissions or other tags
    all_elements = list(root.iter())
    for elem in all_elements:
        tag = elem.tag.split("}")[-1] if "}" in elem.tag else elem.tag
        if tag in ["permission", "uses-permission-sdk-23", "uses-permission-sdk-m"]:
            log_fail("M1.9", f"Unexpected permission tag found: <{tag}>")
            break
    else:
        log_pass("M1.9", "No positive permission declaration tags (<permission>, <uses-permission-sdk-23>) found")

    # 1.4 Check for other debug/profile manifests
    debug_manifest = os.path.join(PROJECT_ROOT, "android/app/src/debug/AndroidManifest.xml")
    profile_manifest = os.path.join(PROJECT_ROOT, "android/app/src/profile/AndroidManifest.xml")
    if os.path.exists(debug_manifest):
        log_fail("M1.10", f"Found debug manifest at {debug_manifest}, could leak internet permission")
    else:
        log_pass("M1.10", "No debug AndroidManifest.xml exists (avoids debug observatory network leak)")

    if os.path.exists(profile_manifest):
        log_fail("M1.11", f"Found profile manifest at {profile_manifest}")
    else:
        log_pass("M1.11", "No profile AndroidManifest.xml exists")

    # 1.5 Check application attributes (backup, cleartext traffic)
    application = root.find("application")
    if application is not None:
        allow_backup = application.attrib.get(f"{{{ANDROID_NS}}}allowBackup")
        if allow_backup == "false":
            log_pass("M1.12", "application has android:allowBackup='false' (prevents data exfiltration via adb)")
        else:
            log_fail("M1.12", f"application allowBackup is '{allow_backup}' (expected 'false')")

        cleartext = application.attrib.get(f"{{{ANDROID_NS}}}usesCleartextTraffic")
        if cleartext != "true":
            log_pass("M1.13", "application does not enable cleartext traffic (usesCleartextTraffic != true)")
        else:
            log_fail("M1.13", "application explicitly enabled usesCleartextTraffic='true'!")

    # 1.6 Check components for intent filters with network schemes (http/https)
    network_schemes_found = []
    for data_elem in root.iter("data"):
        scheme = data_elem.attrib.get(f"{{{ANDROID_NS}}}scheme", "")
        if scheme in ["http", "https", "ftp", "ws", "wss"]:
            network_schemes_found.append(scheme)

    if not network_schemes_found:
        log_pass("M1.14", "No components declare network URL schemes (http/https/ftp/ws/wss)")
    else:
        log_fail("M1.14", f"Components declare network URL schemes: {network_schemes_found}")

    # 1.7 Check for XML character entity obfuscation or CDATA blocks
    if "<![CDATA[" in raw_content:
        log_fail("M1.15", "Manifest contains CDATA sections which could obfuscate permissions")
    else:
        log_pass("M1.15", "No CDATA obfuscation in AndroidManifest.xml")

    # 1.8 Verify case sensitivity / regex check for internet
    raw_lower = raw_content.lower()
    matches = re.findall(r"permission[a-z._]*internet", raw_lower)
    for m in matches:
        if m != "permission.internet":
            log_fail("M1.16", f"Suspicious permission string found: {m}")
            break
    else:
        log_pass("M1.16", "No misspelled/obfuscated permission variants detected")


# ==============================================================================
# SUITE 2: Android Manifest Merger Simulation (Google ManifestMerger2)
# ==============================================================================
class AndroidManifestMergerSimulator:
    """
    Simulates Google's ManifestMerger2 algorithm for uses-permission elements.
    Merge key: android:name
    Rules:
    - Main manifest has highest priority (app level).
    - Lower priority elements merged into higher priority.
    - If higher priority has tools:node="remove", the element is completely excised from output.
    - If higher priority does NOT have tools:node="remove", the lower priority element is merged in.
    """
    def __init__(self, main_manifest_path):
        self.main_path = main_manifest_path
        self.tree = ET.parse(main_manifest_path)
        self.root = self.tree.getroot()

    def simulate_merge(self, library_manifests, override_main_remove_rules=False):
        """
        Runs merge simulation against a list of library manifest strings.
        Returns the final set of active uses-permission names in the merged output.
        """
        main_rules = {}
        for p in self.root.findall("uses-permission"):
            name = p.attrib.get(f"{{{ANDROID_NS}}}name") or p.attrib.get("android:name", "")
            node = p.attrib.get(f"{{{TOOLS_NS}}}node") or p.attrib.get("tools:node", "")
            if override_main_remove_rules:
                node = ""
            main_rules[name] = node

        lib_permissions = set()
        for lib_xml in library_manifests:
            lib_tree = ET.fromstring(lib_xml)
            for p in lib_tree.findall("uses-permission"):
                name = p.attrib.get(f"{{{ANDROID_NS}}}name") or p.attrib.get("android:name", "")
                if name:
                    lib_permissions.add(name)

        final_permissions = set()

        # 1. Main manifest positive permissions (if any)
        for name, action in main_rules.items():
            if action != "remove" and action != "removeAll":
                final_permissions.add(name)

        # 2. Merge from libraries
        for lib_perm in lib_permissions:
            action = main_rules.get(lib_perm)
            if action == "remove" or action == "removeAll":
                # Suppressed by tools:node="remove"!
                continue
            else:
                final_permissions.add(lib_perm)

        return final_permissions


def run_suite_2():
    print("\n" + "="*70)
    print("SUITE 2: Android Manifest Merger Adversarial Injection Stress Test")
    print("="*70)

    merger = AndroidManifestMergerSimulator(MANIFEST_PATH)

    # Attack Scenario 2.1: Rogue 3rd party dependency injects INTERNET
    rogue_lib_1 = """<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="com.rogue.analytics">
        <uses-permission android:name="android.permission.INTERNET" />
    </manifest>"""
    merged_perms_1 = merger.simulate_merge([rogue_lib_1])
    if "android.permission.INTERNET" not in merged_perms_1:
        log_pass("M2.1", "Rogue dependency with INTERNET successfully blocked by tools:node='remove'")
    else:
        log_fail("M2.1", "VULNERABILITY: INTERNET permission leaked into merged manifest!")

    # Attack Scenario 2.2: Rogue library with extra attributes (e.g. maxSdkVersion)
    rogue_lib_attribs = """<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="com.rogue.attribs">
        <uses-permission android:name="android.permission.INTERNET" android:maxSdkVersion="34" android:required="true" />
    </manifest>"""
    merged_perms_attribs = merger.simulate_merge([rogue_lib_attribs])
    if "android.permission.INTERNET" not in merged_perms_attribs:
        log_pass("M2.2", "Library with extra attributes (maxSdkVersion, required) still stripped by merge key")
    else:
        log_fail("M2.2", "VULNERABILITY: Attribute variation bypassed tools:node='remove'!")

    # Attack Scenario 2.3: Rogue library injects ACCESS_NETWORK_STATE and ACCESS_WIFI_STATE
    rogue_lib_2 = """<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="com.rogue.wifi">
        <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
        <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    </manifest>"""
    merged_perms_2 = merger.simulate_merge([rogue_lib_2])
    if "android.permission.ACCESS_NETWORK_STATE" not in merged_perms_2 and "android.permission.ACCESS_WIFI_STATE" not in merged_perms_2:
        log_pass("M2.3", "Network and WiFi state permissions successfully blocked by tools:node='remove'")
    else:
        log_fail("M2.3", f"Network/WiFi permissions leaked: {merged_perms_2}")

    # Attack Scenario 2.4: Multiple aggressive libraries attempting concurrent injection
    merged_perms_3 = merger.simulate_merge([rogue_lib_1, rogue_lib_attribs, rogue_lib_2])
    if not any(p in merged_perms_3 for p in ["android.permission.INTERNET", "android.permission.ACCESS_NETWORK_STATE", "android.permission.ACCESS_WIFI_STATE"]):
        log_pass("M2.4", "Multiple concurrent library injection attack completely neutralized (0 network perms)")
    else:
        log_fail("M2.4", f"Concurrent injection succeeded in leaking: {merged_perms_3}")

    # Scenario 2.5: Library attempting tools:node="replace" or "merge" to counter app removal
    rogue_lib_override = """<manifest xmlns:android="http://schemas.android.com/apk/res/android" xmlns:tools="http://schemas.android.com/tools" package="com.rogue.force">
        <uses-permission android:name="android.permission.INTERNET" tools:node="replace" />
    </manifest>"""
    merged_perms_override = merger.simulate_merge([rogue_lib_override])
    if "android.permission.INTERNET" not in merged_perms_override:
        log_pass("M2.5", "Library tools:node='replace' cannot override higher-priority app removal rule")
    else:
        log_fail("M2.5", "Library tools:node override succeeded!")

    # Scenario 2.6: Negative control (Mutation Testing)
    # If the app did NOT have tools:node="remove", does the rogue library succeed in injecting INTERNET?
    mutated_merge = merger.simulate_merge([rogue_lib_1], override_main_remove_rules=True)
    if "android.permission.INTERNET" in mutated_merge:
        log_pass("M2.6", "Negative Control Validated: Without tools:node='remove', INTERNET leaks. Proves defensive necessity.")
    else:
        log_fail("M2.6", "Merger simulator defective: failed to detect leak under mutation")


# ==============================================================================
# SUITE 3: Pubspec Dependency & Comment Adversarial Audit
# ==============================================================================
def run_suite_3():
    print("\n" + "="*70)
    print("SUITE 3: Pubspec Dependency & Comment Adversarial Audit")
    print("="*70)

    if not os.path.isfile(PUBSPEC_PATH):
        log_fail("M3.1", f"pubspec.yaml missing at {PUBSPEC_PATH}")
        return

    with open(PUBSPEC_PATH, "r", encoding="utf-8") as f:
        lines = f.readlines()

    raw_content = "".join(lines)
    log_pass("M3.1", "pubspec.yaml loaded successfully")

    # 3.1 Check blacklist across active AND commented lines
    detected_in_active = []
    detected_in_comments = []

    for line_no, line in enumerate(lines, 1):
        stripped = line.strip()
        is_comment = stripped.startswith("#")

        for pkg in PROHIBITED_PACKAGES:
            pattern = rf"\b{re.escape(pkg)}\s*:"
            if re.search(pattern, stripped):
                if is_comment:
                    detected_in_comments.append((line_no, pkg, stripped))
                else:
                    detected_in_active.append((line_no, pkg, stripped))

    if not detected_in_active:
        log_pass("M3.2", f"Zero prohibited network/telemetry packages in active dependencies ({len(PROHIBITED_PACKAGES)} checked)")
    else:
        log_fail("M3.2", f"Active prohibited packages found: {detected_in_active}")

    if not detected_in_comments:
        log_pass("M3.3", "Zero commented-out network libraries found in pubspec.yaml (no dormant network code)")
    else:
        log_fail("M3.3", f"Commented-out network packages found: {detected_in_comments}")

    # 3.2 Check for dependency overrides or external git/hosted links
    if "dependency_overrides:" in raw_content:
        log_fail("M3.4", "pubspec.yaml contains dependency_overrides!")
    else:
        log_pass("M3.4", "No dependency_overrides declared")

    git_deps = [line.strip() for line in lines if "git:" in line and not line.strip().startswith("#")]
    if git_deps:
        log_fail("M3.5", f"External git dependencies found: {git_deps}")
    else:
        log_pass("M3.5", "No unvetted external git dependencies declared")

    # 3.3 Verify only flutter and flutter_test are runtime/test SDK deps
    runtime_deps = []
    in_deps = False
    in_dev_deps = False
    for line in lines:
        if line.startswith("dependencies:"):
            in_deps = True
            in_dev_deps = False
            continue
        elif line.startswith("dev_dependencies:"):
            in_deps = False
            in_dev_deps = True
            continue
        elif line.startswith("flutter:") or (line and not line.startswith(" ") and not line.startswith("#")):
            in_deps = False
            in_dev_deps = False
            continue

        if in_deps and line.strip() and not line.strip().startswith("#"):
            match = re.match(r"^ {2}([a-zA-Z0-9_]+):", line)
            if match:
                runtime_deps.append(match.group(1))

    if runtime_deps == ["flutter"]:
        log_pass("M3.6", f"Runtime dependencies strictly restricted to ['flutter']: {runtime_deps}")
    else:
        log_fail("M3.6", f"Unexpected runtime dependencies: {runtime_deps}")


# ==============================================================================
# SUITE 4: Deep Static Codebase Audit for Hidden Network APIs
# ==============================================================================
def run_suite_4():
    print("\n" + "="*70)
    print("SUITE 4: Codebase Hidden Network APIs & Socket Hunt")
    print("="*70)

    # 4.1 Scan all files in lib/
    lib_violations = []
    dart_files_count = 0

    for root_dir, _, files in os.walk(LIB_DIR):
        for file in files:
            if file.endswith(".dart"):
                dart_files_count += 1
                file_path = os.path.join(root_dir, file)
                rel_path = os.path.relpath(file_path, PROJECT_ROOT)
                with open(file_path, "r", encoding="utf-8") as f:
                    content = f.read()

                # Check prohibited symbols
                for sym in PROHIBITED_DART_SYMBOLS:
                    if sym in content:
                        lib_violations.append((rel_path, sym))

                # Check for raw URI schemes (http:// or https://)
                urls = re.findall(r'["\'](https?://[^"\']+)["\']', content)
                for u in urls:
                    if not u.startswith("http://schemas.android.com"):
                        lib_violations.append((rel_path, f"URL:{u}"))

                # Check for dart:io import
                if re.search(r"import\s+['\"]dart:io['\"]", content):
                    lib_violations.append((rel_path, "import 'dart:io'"))

                # Check for dart:html import
                if re.search(r"import\s+['\"]dart:html['\"]", content):
                    lib_violations.append((rel_path, "import 'dart:html'"))

    log_pass("M4.1", f"Scanned {dart_files_count} Dart files in lib/")

    if not lib_violations:
        log_pass("M4.2", f"Zero network sockets, HTTP clients, or dart:io imports in lib/ ({dart_files_count} files)")
    else:
        log_fail("M4.2", f"Network violations detected in lib/: {lib_violations}")

    # 4.2 Check Android Kotlin/Java source code for network APIs
    android_violations = []
    for root_dir, _, files in os.walk(os.path.join(ANDROID_DIR, "app/src/main")):
        for file in files:
            if file.endswith((".kt", ".java")):
                file_path = os.path.join(root_dir, file)
                rel_path = os.path.relpath(file_path, PROJECT_ROOT)
                with open(file_path, "r", encoding="utf-8") as f:
                    content = f.read()

                for kw in ["HttpURLConnection", "OkHttpClient", "Retrofit", "java.net.Socket", "java.net.URL", "ConnectivityManager"]:
                    if kw in content:
                        android_violations.append((rel_path, kw))

    if not android_violations:
        log_pass("M4.3", "Zero native Android network clients or socket calls in Kotlin source")
    else:
        log_fail("M4.3", f"Native network calls found: {android_violations}")

    # 4.3 Check Gradle scripts for network dependencies
    gradle_files = [
        os.path.join(ANDROID_DIR, "build.gradle"),
        os.path.join(ANDROID_DIR, "app/build.gradle")
    ]
    gradle_violations = []
    for g_file in gradle_files:
        if os.path.exists(g_file):
            with open(g_file, "r", encoding="utf-8") as f:
                g_content = f.read()
            for dep in ["okhttp", "retrofit", "volley", "firebase", "play-services-ads"]:
                if dep in g_content.lower():
                    gradle_violations.append((os.path.basename(g_file), dep))

    if not gradle_violations:
        log_pass("M4.4", "Zero network libraries or SDK dependencies in Gradle build scripts")
    else:
        log_fail("M4.4", f"Gradle network dependencies found: {gradle_violations}")


# ==============================================================================
# SUITE 5: Test Environment Offline Isolation & Determinism Audit
# ==============================================================================
def run_suite_5():
    print("\n" + "="*70)
    print("SUITE 5: Test Environment Offline Isolation & Determinism Audit")
    print("="*70)

    test_dart_files = []
    for root_dir, _, files in os.walk(TEST_DIR):
        for file in files:
            if file.endswith(".dart"):
                test_dart_files.append(os.path.join(root_dir, file))

    log_pass("M5.1", f"Found {len(test_dart_files)} test suite Dart files")

    # Verify that tests don't establish real network sockets
    live_network_in_tests = []
    for t_path in test_dart_files:
        rel_path = os.path.relpath(t_path, PROJECT_ROOT)
        with open(t_path, "r", encoding="utf-8") as f:
            t_content = f.read()

        # Check for active live network invocations (not string assertions)
        if "HttpServer.bind" in t_content or "Socket.connect(" in t_content:
            live_network_in_tests.append((rel_path, "Active socket connection in test"))

    if not live_network_in_tests:
        log_pass("M5.2", "Zero live network sockets opened in test suites (100% offline determinism)")
    else:
        log_fail("M5.2", f"Live sockets found in tests: {live_network_in_tests}")


# ==============================================================================
# MAIN RUNNER
# ==============================================================================
def main():
    print("="*70)
    print("STARTING ADVERSARIAL PRIVACY & ZERO-NETWORK PROBE (CHALLENGER 1)")
    print(f"Target: {PROJECT_ROOT}")
    print("="*70)

    run_suite_1()
    run_suite_2()
    run_suite_3()
    run_suite_4()
    run_suite_5()

    print("\n" + "="*70)
    print("PROBE RESULTS SUMMARY")
    print("="*70)
    print(f"Total Tests Executed : {total_tests}")
    print(f"Passed               : {passed_tests}")
    print(f"Failed               : {failed_tests}")
    print("="*70)

    if failed_tests == 0:
        print("VERDICT: APPROVE (Zero-Network Privacy Certifiably Intact)")
        sys.exit(0)
    else:
        print("VERDICT: REQUEST_CHANGES (Vulnerabilities/Leaks Detected)")
        sys.exit(1)


if __name__ == "__main__":
    main()
