import 'dart:async';
import 'offline_audio_service.dart';

/// In-memory, deterministic implementation of [OfflineAudioService]
/// for widget testing, CI execution, and offline development.
///
/// Fully tracks state, emits state changes through reactive streams,
/// and maintains call history without invoking native platform channels.
class MockOfflineAudioService implements OfflineAudioService {
  bool _isPlaying = false;
  String? _currentAssetPath;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  final List<String> _callLog = [];
  bool _isDisposed = false;

  @override
  bool get isPlaying => _isPlaying;

  @override
  String? get currentAssetPath => _currentAssetPath;

  @override
  Stream<bool> get isPlayingStream => _controller.stream;

  /// Unmodifiable list of method calls recorded for testing verification.
  List<String> get callLog => List.unmodifiable(_callLog);

  @override
  Future<void> playAsset(String assetPath) async {
    _checkDisposed();
    if (assetPath.trim().isEmpty) {
      throw ArgumentError('Asset path cannot be empty');
    }
    _currentAssetPath = assetPath;
    _isPlaying = true;
    _callLog.add('playAsset:$assetPath');
    _controller.add(true);
  }

  @override
  Future<void> pause() async {
    _checkDisposed();
    _isPlaying = false;
    _callLog.add('pause');
    _controller.add(false);
  }

  @override
  Future<void> stop() async {
    _checkDisposed();
    _isPlaying = false;
    _callLog.add('stop');
    _controller.add(false);
  }

  /// Clears call history and resets state.
  void reset() {
    _isPlaying = false;
    _currentAssetPath = null;
    _callLog.clear();
    if (!_isDisposed) {
      _controller.add(false);
    }
  }

  @override
  void dispose() {
    if (!_isDisposed) {
      _isDisposed = true;
      _controller.close();
    }
  }

  void _checkDisposed() {
    if (_isDisposed) {
      throw StateError('Cannot use MockOfflineAudioService after dispose()');
    }
  }
}
