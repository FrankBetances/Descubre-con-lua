import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/core/audio/mock_offline_audio_service.dart';
import '../../lib/core/localization/app_language.dart';
import '../../lib/core/localization/localized_string.dart';
import '../../lib/core/theme/app_theme.dart';

void main() {
  group('Adversarial Stress Tests - LocalizedString', () {
    test('Empty and whitespace string edge cases', () {
      const emptyBoth = LocalizedString(gl: '', es: '');
      expect(emptyBoth.hasParity, isFalse);
      expect(emptyBoth.resolve(AppLanguage.gl), isEmpty);
      expect(emptyBoth.resolve(AppLanguage.es), isEmpty);

      const whitespaceGl = LocalizedString(gl: '   \t\n', es: 'Castellano');
      expect(whitespaceGl.hasParity, isFalse);

      const whitespaceEs = LocalizedString(gl: 'Galego', es: '   \r\n');
      expect(whitespaceEs.hasParity, isFalse);

      const whitespaceBoth = LocalizedString(gl: ' \t ', es: ' \n ');
      expect(whitespaceBoth.hasParity, isFalse);
    });

    test('Special Galician characters preservation across serialization', () {
      const galicianCorpus = LocalizedString(
        gl: 'Ría de Vigo: argüír pola antigüidade dos mexillóns, café con morriña, música miúda e polbo á feira coa heroïna de Samil',
        es: 'Ría de Vigo: argüir por la antigüedad de los mejillones, café con morriña, música menuda y pulpo a la feria con la heroína de Samil',
      );

      expect(galicianCorpus.hasParity, isTrue);
      expect(galicianCorpus.gl.contains('á'), isTrue);
      expect(galicianCorpus.gl.contains('é'), isTrue);
      expect(galicianCorpus.gl.contains('í'), isTrue);
      expect(galicianCorpus.gl.contains('ó'), isTrue);
      expect(galicianCorpus.gl.contains('ú'), isTrue);
      expect(galicianCorpus.gl.contains('ñ'), isTrue);
      expect(galicianCorpus.gl.contains('ï'), isTrue);
      expect(galicianCorpus.gl.contains('ü'), isTrue);

      // JSON string round-trip with utf-8 encoding/decoding
      final jsonMap = galicianCorpus.toJson();
      final serializedJson = jsonEncode(jsonMap);
      final deserializedMap = jsonDecode(serializedJson) as Map<String, dynamic>;
      final reconstructed = LocalizedString.fromJson(deserializedMap);

      expect(reconstructed, equals(galicianCorpus));
      expect(reconstructed.gl, equals(galicianCorpus.gl));
      expect(reconstructed.es, equals(galicianCorpus.es));
      expect(reconstructed.hashCode, equals(galicianCorpus.hashCode));
    });

    test('JSON deserialization handles missing, null, and unexpected keys', () {
      final missingEs = LocalizedString.fromJson({'gl': 'Soamente galego'});
      expect(missingEs.gl, equals('Soamente galego'));
      expect(missingEs.es, isEmpty);
      expect(missingEs.hasParity, isFalse);

      final missingGl = LocalizedString.fromJson({'es': 'Solo español'});
      expect(missingGl.gl, isEmpty);
      expect(missingGl.es, equals('Solo español'));
      expect(missingGl.hasParity, isFalse);

      final nullValues = LocalizedString.fromJson({'gl': null, 'es': null});
      expect(nullValues.gl, isEmpty);
      expect(nullValues.es, isEmpty);
      expect(nullValues.hasParity, isFalse);

      final extraKeys = LocalizedString.fromJson({
        'gl': 'Texto GL',
        'es': 'Texto ES',
        'extra_data': 'ignorar',
        'metadata': {'id': 1234},
      });
      expect(extraKeys.gl, equals('Texto GL'));
      expect(extraKeys.es, equals('Texto ES'));
      expect(extraKeys.hasParity, isTrue);
    });

    test('Equality, hashing, and collection collision resistance', () {
      const a = LocalizedString(gl: 'Vigo', es: 'Vigo');
      const b = LocalizedString(gl: 'Vigo', es: 'Vigo');
      const c = LocalizedString(gl: 'Cíes', es: 'Cíes');

      expect(a == b, isTrue);
      expect(b == a, isTrue);
      expect(a == c, isFalse);
      expect(a.hashCode == b.hashCode, isTrue);

      final uniqueSet = <LocalizedString>{};
      for (int i = 0; i < 500; i++) {
        uniqueSet.add(LocalizedString(gl: 'Palabra $i', es: 'Palabra $i'));
      }
      expect(uniqueSet.length, equals(500));

      // Adding duplicate should not increase set size
      uniqueSet.add(const LocalizedString(gl: 'Palabra 0', es: 'Palabra 0'));
      expect(uniqueSet.length, equals(500));
    });

    test('copyWith behaves correctly for partial and empty updates', () {
      const original = LocalizedString(gl: 'Mar', es: 'Mar');
      final updatedEs = original.copyWith(es: 'Océano');
      expect(updatedEs.gl, equals('Mar'));
      expect(updatedEs.es, equals('Océano'));

      final noOp = original.copyWith();
      expect(noOp, equals(original));

      final emptyGl = original.copyWith(gl: '');
      expect(emptyGl.gl, isEmpty);
      expect(emptyGl.es, equals('Mar'));
    });
  });

  group('Adversarial Stress Tests - AppLanguage', () {
    test('Toggle stability across multiple cycles', () {
      var lang = AppLanguage.gl;
      for (int i = 0; i < 1000; i++) {
        lang = lang.toggle();
        expect(lang, equals(i.isEven ? AppLanguage.es : AppLanguage.gl));
      }
      expect(lang, equals(AppLanguage.gl));
    });

    test('Invalid code parsing fallback resilience', () {
      expect(AppLanguage.fromCode(null), equals(AppLanguage.gl));
      expect(AppLanguage.fromCode(''), equals(AppLanguage.gl));
      expect(AppLanguage.fromCode('   \n\t'), equals(AppLanguage.gl));
      expect(AppLanguage.fromCode('unknown_dialect'), equals(AppLanguage.gl));
      expect(AppLanguage.fromCode('en'), equals(AppLanguage.gl));
      expect(AppLanguage.fromCode('en-US'), equals(AppLanguage.gl));
      expect(AppLanguage.fromCode('fr'), equals(AppLanguage.gl));
      expect(AppLanguage.fromCode('pt-PT'), equals(AppLanguage.gl));
      expect(AppLanguage.fromCode('12345'), equals(AppLanguage.gl));
      expect(AppLanguage.fromCode('!@#\$%^&*()'), equals(AppLanguage.gl));

      // Valid codes and regional variants
      expect(AppLanguage.fromCode('es'), equals(AppLanguage.es));
      expect(AppLanguage.fromCode('es-ES'), equals(AppLanguage.es));
      expect(AppLanguage.fromCode('es-MX'), equals(AppLanguage.es));
      expect(AppLanguage.fromCode('  ES  '), equals(AppLanguage.es));
      expect(AppLanguage.fromCode('gl'), equals(AppLanguage.gl));
      expect(AppLanguage.fromCode('gl-ES'), equals(AppLanguage.gl));
      expect(AppLanguage.fromCode('  GL  '), equals(AppLanguage.gl));
    });
  });

  group('Adversarial Stress Tests - MockOfflineAudioService', () {
    late MockOfflineAudioService audioService;

    setUp(() {
      audioService = MockOfflineAudioService();
    });

    tearDown(() {
      audioService.dispose();
    });

    test('Rapid sequential method calls maintain state consistency', () async {
      for (int i = 0; i < 100; i++) {
        await audioService.playAsset('assets/audio/test_$i.wav');
        expect(audioService.isPlaying, isTrue);
        expect(audioService.currentAssetPath, equals('assets/audio/test_$i.wav'));

        await audioService.pause();
        expect(audioService.isPlaying, isFalse);

        await audioService.stop();
        expect(audioService.isPlaying, isFalse);
      }

      expect(audioService.callLog.length, equals(300));
      expect(audioService.callLog.first, equals('playAsset:assets/audio/test_0.wav'));
      expect(audioService.callLog.last, equals('stop'));
    });

    test('callLog is immutable against external tampering', () {
      expect(() => (audioService.callLog as dynamic).add('illegal'), throwsA(isA<UnsupportedError>()));
    });

    test('Empty or blank asset paths are rejected', () async {
      expect(() => audioService.playAsset(''), throwsArgumentError);
      expect(() => audioService.playAsset('   \t\n'), throwsArgumentError);
    });

    test('Concurrent stream subscribers and early cancellations', () async {
      final logA = <bool>[];
      final logB = <bool>[];
      final logC = <bool>[];

      final subA = audioService.isPlayingStream.listen(logA.add);
      final subB = audioService.isPlayingStream.listen(logB.add);
      final subC = audioService.isPlayingStream.listen(logC.add);

      await audioService.playAsset('assets/audio/mar.wav');
      await Future.delayed(const Duration(milliseconds: 10));

      // Cancel subB early
      await subB.cancel();

      await audioService.pause();
      await Future.delayed(const Duration(milliseconds: 10));

      expect(logA, containsAllInOrder([true, false]));
      expect(logB, contains(true));
      expect(logB.contains(false), isFalse); // cancelled before pause
      expect(logC, containsAllInOrder([true, false]));

      await subA.cancel();
      await subC.cancel();
    });

    test('Idempotent dispose and post-dispose state guards', () async {
      audioService.dispose();
      // Second dispose should be a no-op without error
      expect(() => audioService.dispose(), returnsNormally);

      expect(() => audioService.playAsset('mar.wav'), throwsStateError);
      expect(() => audioService.pause(), throwsStateError);
      expect(() => audioService.stop(), throwsStateError);
    });
  });

  group('Adversarial Stress Tests - AppTheme', () {
    double relativeLuminance(Color color) {
      double transform(double c) =>
          c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055) * ((c + 0.055) / 1.055); // approximated power 2.4

      final r = transform(color.red / 255.0);
      final g = transform(color.green / 255.0);
      final b = transform(color.blue / 255.0);
      return 0.2126 * r + 0.7152 * g + 0.0722 * b;
    }

    double contrastRatio(Color c1, Color c2) {
      final l1 = relativeLuminance(c1);
      final l2 = relativeLuminance(c2);
      final lighter = l1 > l2 ? l1 : l2;
      final darker = l1 > l2 ? l2 : l1;
      return (lighter + 0.05) / (darker + 0.05);
    }

    test('Color contrast ratios meet WCAG AA standards (>= 4.5:1 for normal text, >= 3.0:1 for large)', () {
      final theme = AppTheme.lightTheme;
      final colorScheme = theme.colorScheme;

      // onPrimary (white) on primary (Vigo Blue #1B4965)
      final primaryContrast = contrastRatio(colorScheme.onPrimary, colorScheme.primary);
      expect(primaryContrast, greaterThanOrEqualTo(4.5));

      // onSurface (textSlate #1C2541) on surface (backgroundSand #F4F1DE)
      final surfaceContrast = contrastRatio(colorScheme.onSurface, colorScheme.surface);
      expect(surfaceContrast, greaterThanOrEqualTo(4.5));

      // onSurface (textSlate) on cardSurface (#FFFFFF)
      final cardContrast = contrastRatio(AppTheme.textSlate, AppTheme.cardSurface);
      expect(cardContrast, greaterThanOrEqualTo(4.5));

      // onSecondary (textSlate) on secondary (Sea Glass #62B6CB)
      final secondaryContrast = contrastRatio(colorScheme.onSecondary, colorScheme.secondary);
      expect(secondaryContrast, greaterThanOrEqualTo(3.0));
    });

    test('Adult typography hierarchy strictly satisfies minimum 16sp body constraint', () {
      final textTheme = AppTheme.lightTheme.textTheme;

      expect(textTheme.bodyLarge?.fontSize, greaterThanOrEqualTo(16.0));
      expect(textTheme.bodyMedium?.fontSize, greaterThanOrEqualTo(16.0));
      expect(textTheme.titleLarge?.fontSize, greaterThanOrEqualTo(20.0));
      expect(textTheme.headlineLarge?.fontSize, greaterThanOrEqualTo(24.0));
    });
  });
}
