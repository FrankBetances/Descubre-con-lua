import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Privacy & Binary Security Certification', () {
    late File manifestFile;
    late File pubspecFile;
    late Directory libDirectory;

    setUpAll(() {
      // Locate project root relative to test execution path
      final currentDir = Directory.current.path;
      final projectRoot = currentDir.endsWith('test')
          ? Directory.current.parent.path
          : currentDir;

      manifestFile = File('$projectRoot/android/app/src/main/AndroidManifest.xml');
      pubspecFile = File('$projectRoot/pubspec.yaml');
      libDirectory = Directory('$projectRoot/lib');
    });

    test('AndroidManifest.xml strictly excludes INTERNET and network permissions', () {
      expect(manifestFile.existsSync(), isTrue,
          reason: 'AndroidManifest.xml must exist at android/app/src/main/AndroidManifest.xml');

      final content = manifestFile.readAsStringSync();

      // Check package ID
      expect(content, contains('package="com.earlify.descubreconlua"'),
          reason: 'Package ID must be com.earlify.descubreconlua');

      // Check application label
      expect(content, contains('android:label="Descubre con Lúa"'),
          reason: 'Application label must be "Descubre con Lúa"');

      // Check tools namespace is defined for remove directives
      expect(content, contains('xmlns:tools="http://schemas.android.com/tools"'),
          reason: 'xmlns:tools must be declared for removal rules');

      // Verify INTERNET permission is strictly removed
      final internetLines = content
          .split('\n')
          .where((line) => line.contains('android.permission.INTERNET'))
          .toList();

      expect(internetLines, isNotEmpty,
          reason: 'Must contain explicit removal rule for android.permission.INTERNET');
      for (final line in internetLines) {
        expect(line, contains('tools:node="remove"'),
            reason: 'Any reference to INTERNET must have tools:node="remove"');
      }

      // Verify ACCESS_NETWORK_STATE is strictly removed
      final networkStateLines = content
          .split('\n')
          .where((line) => line.contains('android.permission.ACCESS_NETWORK_STATE'))
          .toList();

      expect(networkStateLines, isNotEmpty,
          reason: 'Must contain explicit removal rule for android.permission.ACCESS_NETWORK_STATE');
      for (final line in networkStateLines) {
        expect(line, contains('tools:node="remove"'),
            reason: 'Any reference to ACCESS_NETWORK_STATE must have tools:node="remove"');
      }

      // Ensure NO unauthorized positive permission grants exist
      final positivePermissions = content
          .split('\n')
          .map((line) => line.trim())
          .where((line) =>
              line.startsWith('<uses-permission') &&
              !line.contains('tools:node="remove"'))
          .toList();

      expect(positivePermissions, isEmpty,
          reason: 'Release manifest must have ZERO active positive permissions');
    });

    test('pubspec.yaml contains ZERO network or analytics dependencies', () {
      expect(pubspecFile.existsSync(), isTrue,
          reason: 'pubspec.yaml must exist at project root');

      final content = pubspecFile.readAsStringSync();

      // Prohibited networking and analytics libraries
      const prohibitedPackages = [
        'http:',
        'dio:',
        'retrofit:',
        'chopper:',
        'web_socket_channel:',
        'grpc:',
        'firebase_core:',
        'firebase_analytics:',
        'firebase_auth:',
        'cloud_firestore:',
        'sentry_flutter:',
        'sentry:',
        'datadog_flutter:',
        'mixpanel_flutter:',
        'amplitude_flutter:',
        'google_mobile_ads:',
        'facebook_app_events:',
      ];

      for (final package in prohibitedPackages) {
        expect(content, isNot(contains(package)),
            reason: 'Prohibited network dependency "$package" detected in pubspec.yaml');
      }

      // Verify flutter SDK is the only runtime dependency
      expect(content, contains('sdk: flutter'),
          reason: 'pubspec.yaml must declare flutter SDK dependency');

      // Verify offline asset paths are configured
      expect(content, contains('assets/content/unidades/'),
          reason: 'pubspec.yaml must declare assets/content/unidades/');
      expect(content, contains('assets/content/capsulas/'),
          reason: 'pubspec.yaml must declare assets/content/capsulas/');
      expect(content, contains('assets/audio/'),
          reason: 'pubspec.yaml must declare assets/audio/');
    });

    test('Source code in lib/ contains ZERO network socket or HTTP clients', () {
      expect(libDirectory.existsSync(), isTrue,
          reason: 'lib/ directory must exist');

      final dartFiles = libDirectory
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));

      for (final file in dartFiles) {
        final code = file.readAsStringSync();
        expect(code, isNot(contains('HttpClient')),
            reason: 'HttpClient found in ${file.path}');
        expect(code, isNot(contains('WebSocket')),
            reason: 'WebSocket found in ${file.path}');
        expect(code, isNot(contains('Socket.connect')),
            reason: 'Socket.connect found in ${file.path}');
      }
    });
  });
}
