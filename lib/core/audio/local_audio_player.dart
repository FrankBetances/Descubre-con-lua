import 'dart:async';

import 'package:flutter/services.dart';

import 'offline_audio_service.dart';

/// Velocidad de la voz (O-20261109-4, ACOPROS): 0,8 cuando el curso que se
/// ve es 0-2 años, 1,0 en el resto. La ponen el Portal Familias y el Portal
/// Docentes al cambiar de curso.
double velocidadeVoz = 1.0;

/// La velocidad para un curso.
double velocidadeDoCurso(String cursoId) => cursoId == 'curso_0_2' ? 0.8 : 1.0;

/// Plays bundled recordings through Android's own MediaPlayer.
///
/// This is the implementation the app runs. Until now `main.dart` wired
/// `MockOfflineAudioService` into production, so the play button changed state
/// and nothing was ever heard.
///
/// It deliberately adds no package: the platform side is a few lines of Kotlin
/// over `MediaPlayer`, which keeps `pubspec.yaml` at zero third-party
/// dependencies and keeps the release APK free of any library that could open
/// a socket.
class LocalAudioPlayer implements OfflineAudioService {
  static const MethodChannel _channel =
      MethodChannel('com.earlify.descubreconlua/audio');

  final MethodChannel _platform;
  final StreamController<bool> _playing = StreamController<bool>.broadcast();

  bool _isPlaying = false;
  String? _currentAssetPath;
  bool _isDisposed = false;

  LocalAudioPlayer({MethodChannel? channel}) : _platform = channel ?? _channel {
    _platform.setMethodCallHandler(_onPlatformCall);
  }

  @override
  bool get isPlaying => _isPlaying;

  @override
  String? get currentAssetPath => _currentAssetPath;

  @override
  Stream<bool> get isPlayingStream => _playing.stream;

  /// Playback reaching its end is reported by the platform, not predicted here.
  Future<dynamic> _onPlatformCall(MethodCall call) async {
    if (call.method == 'onCompleted') {
      _emit(false);
    }
    return null;
  }

  void _emit(bool playing) {
    _isPlaying = playing;
    if (!_isDisposed) {
      _playing.add(playing);
    }
  }

  @override
  Future<void> playAsset(String assetPath) async {
    _checkDisposed();
    if (assetPath.trim().isEmpty) {
      throw ArgumentError('Asset path cannot be empty');
    }
    _currentAssetPath = assetPath;
    try {
      await _platform.invokeMethod<void>('play', {
        'asset': assetPath,
        if (velocidadeVoz != 1.0) 'speed': velocidadeVoz,
      });
      _emit(true);
    } on PlatformException catch (e) {
      // A missing recording must not look like a recording that played. The
      // caller decides what the teacher sees; the state stays honest.
      _emit(false);
      throw AudioAssetException(assetPath, e.message ?? e.code);
    }
  }

  @override
  Future<void> pause() async {
    _checkDisposed();
    await _platform.invokeMethod<void>('pause');
    _emit(false);
  }

  @override
  Future<void> stop() async {
    _checkDisposed();
    await _platform.invokeMethod<void>('stop');
    _emit(false);
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _platform.invokeMethod<void>('release').catchError((_) {});
    _playing.close();
  }

  void _checkDisposed() {
    if (_isDisposed) {
      throw StateError('Cannot use LocalAudioPlayer after dispose()');
    }
  }
}

/// Raised when a bundled recording cannot be played.
class AudioAssetException implements Exception {
  final String assetPath;
  final String reason;

  const AudioAssetException(this.assetPath, this.reason);

  @override
  String toString() => 'AudioAssetException($assetPath): $reason';
}
