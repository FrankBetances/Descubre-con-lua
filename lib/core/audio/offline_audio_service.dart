import 'dart:async';

/// Abstract contract for local offline audio playback.
///
/// Designed strictly for local bundled assets (e.g. pulse songs for guided assembly)
/// with zero network interaction and complete testability.
abstract class OfflineAudioService {
  /// Plays or resumes playback of a local offline asset file.
  Future<void> playAsset(String assetPath);

  /// Pauses current playback.
  Future<void> pause();

  /// Stops current playback and resets position to beginning.
  Future<void> stop();

  /// Broadcast stream indicating playback state changes.
  Stream<bool> get isPlayingStream;

  /// Current synchronous playback status.
  bool get isPlaying;

  /// Currently loaded asset path, if any.
  String? get currentAssetPath;

  /// Releases audio resources.
  void dispose();
}
