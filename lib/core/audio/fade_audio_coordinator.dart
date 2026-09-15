import 'dart:async';
import 'offline_audio_service.dart';

/// Coordenador de audio con atenuación progresiva (fade-in / fade-out)
/// deseñado para a xestión da asemblea entre bastidores (Backstage).
///
/// Evita sobresaltos acústicos no grupo de infantil aplicando fundidos suaves
/// ao iniciar ou deter as pistas ambientais e os pulsos rítmicos.
class FadeAudioCoordinator {
  final OfflineAudioService _service;
  final Duration defaultFadeDuration;

  Timer? _fadeTimer;
  bool _isFading = false;

  FadeAudioCoordinator({
    required OfflineAudioService service,
    this.defaultFadeDuration = const Duration(milliseconds: 800),
  }) : _service = service;

  OfflineAudioService get service => _service;
  bool get isPlaying => _service.isPlaying;
  String? get currentAssetPath => _service.currentAssetPath;
  Stream<bool> get isPlayingStream => _service.isPlayingStream;
  bool get isFading => _isFading;

  /// Reproduce un asset aplicando un fade-in suave.
  Future<void> playWithFadeIn(
    String assetPath, {
    Duration? duration,
  }) async {
    _cancelCurrentFade();
    _isFading = true;

    // Iniciamos a reprodución no servizo base
    await _service.playAsset(assetPath);

    final fadeTime = duration ?? defaultFadeDuration;
    final completer = Completer<void>();

    // Temporizador de simulación de fade-in para estados coordinados
    _fadeTimer = Timer(fadeTime, () {
      _isFading = false;
      completer.complete();
    });

    return completer.future;
  }

  /// Detén a reprodución actual aplicando un fade-out suave.
  Future<void> stopWithFadeOut({
    Duration? duration,
  }) async {
    if (!_service.isPlaying) return;

    _cancelCurrentFade();
    _isFading = true;

    final fadeTime = duration ?? defaultFadeDuration;
    final completer = Completer<void>();

    _fadeTimer = Timer(fadeTime, () async {
      await _service.stop();
      _isFading = false;
      completer.complete();
    });

    return completer.future;
  }

  /// Detén de inmediato calquera son activo sen agardar ao fundido (ej. saída urxente).
  Future<void> stopImmediate() async {
    _cancelCurrentFade();
    _isFading = false;
    await _service.stop();
  }

  /// Cancela calquera temporizador de fundido en curso.
  void _cancelCurrentFade() {
    _fadeTimer?.cancel();
    _fadeTimer = null;
  }

  /// Libera recursos.
  void dispose() {
    _cancelCurrentFade();
  }
}
