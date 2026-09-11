import 'package:flutter_test/flutter_test.dart';
import '../../lib/core/audio/mock_offline_audio_service.dart';

void main() {
  group('MockOfflineAudioService tests', () {
    late MockOfflineAudioService service;

    setUp(() {
      service = MockOfflineAudioService();
    });

    tearDown(() {
      service.dispose();
    });

    test('Initial state is stopped and has no active asset', () {
      expect(service.isPlaying, isFalse);
      expect(service.currentAssetPath, isNull);
      expect(service.callLog, isEmpty);
    });

    test('playAsset updates state, call log, and emits true on stream', () async {
      final emittedStates = <bool>[];
      final subscription = service.isPlayingStream.listen(emittedStates.add);

      await service.playAsset('assets/audio/mar_pulso_72bpm.wav');

      expect(service.isPlaying, isTrue);
      expect(service.currentAssetPath, equals('assets/audio/mar_pulso_72bpm.wav'));
      expect(service.callLog, contains('playAsset:assets/audio/mar_pulso_72bpm.wav'));

      await Future.delayed(const Duration(milliseconds: 10));
      expect(emittedStates, contains(true));

      await subscription.cancel();
    });

    test('pause updates state, call log, and emits false on stream', () async {
      final emittedStates = <bool>[];
      final subscription = service.isPlayingStream.listen(emittedStates.add);

      await service.playAsset('assets/audio/mar_pulso_72bpm.wav');
      await service.pause();

      expect(service.isPlaying, isFalse);
      expect(service.callLog, contains('pause'));

      await Future.delayed(const Duration(milliseconds: 10));
      expect(emittedStates, contains(false));

      await subscription.cancel();
    });

    test('stop resets state and logs stop', () async {
      await service.playAsset('assets/audio/mar_pulso_72bpm.wav');
      await service.stop();

      expect(service.isPlaying, isFalse);
      expect(service.callLog, contains('stop'));
    });

    test('playAsset throws ArgumentError on empty path', () async {
      expect(() => service.playAsset('   '), throwsArgumentError);
    });

    test('Operations throw StateError after dispose', () {
      service.dispose();
      expect(() => service.playAsset('any.wav'), throwsStateError);
      expect(() => service.pause(), throwsStateError);
      expect(() => service.stop(), throwsStateError);
    });
  });
}
