import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/unidad_model.dart';

/// Phase 1: Canción a pulso with offline audio player and rhythm markers.
///
/// Provides teachers with:
/// - Song lyrics with rhythm markers (*) for clapping or patting knees.
/// - Offline audio playback controls (play / pause / stop).
/// - Prominent BPM indicator for steady tempo regulation in 0-3 classrooms.
/// - Teacher facilitation directive (consigna docente).
class PasoCancionWidget extends StatefulWidget {
  final CancionPulso cancion;
  final AppLanguage language;
  final OfflineAudioService audioService;

  const PasoCancionWidget({
    super.key,
    required this.cancion,
    required this.language,
    required this.audioService,
  });

  @override
  State<PasoCancionWidget> createState() => _PasoCancionWidgetState();
}

class _PasoCancionWidgetState extends State<PasoCancionWidget> {
  bool _isPlaying = false;
  StreamSubscription<bool>? _audioSubscription;

  @override
  void initState() {
    super.initState();
    _isPlaying = widget.audioService.isPlaying;
    _audioSubscription = widget.audioService.isPlayingStream.listen((playing) {
      if (mounted) {
        setState(() {
          _isPlaying = playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioSubscription?.cancel();
    super.dispose();
  }

  Future<void> _handlePlay() async {
    // Prefer unit asset; fall back to procedural reference pulse mar_pulso_72bpm.wav if needed
    final assetPath = widget.cancion.resolveAudio(widget.language);
    final effectivePath =
        assetPath.isNotEmpty ? assetPath : 'assets/audio/mar_pulso_72bpm.wav';
    await widget.audioService.playAsset(effectivePath);
  }

  Future<void> _handlePause() async {
    await widget.audioService.pause();
  }

  Future<void> _handleStop() async {
    await widget.audioService.stop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGl = widget.language == AppLanguage.gl;
    final cancion = widget.cancion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step title & BPM badge
        Row(
          children: [
            Expanded(
              child: Text(
                cancion.titulo.resolve(widget.language),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryVigoBlue,
                  fontSize: 22.0,
                ),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: AppTheme.primaryVigoBlue,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.speed, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '${cancion.bpm} BPM',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),

        // Offline Audio Controller Card
        Card(
          color: AppTheme.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: const BorderSide(color: Color(0xFFD0D7DE), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isPlaying ? Colors.green : Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isPlaying
                          ? (isGl
                              ? 'Reproducindo pulso rítmico offline'
                              : 'Reproduciendo pulso rítmico offline')
                          : (isGl
                              ? 'Reprodutor de son local pausado'
                              : 'Reproductor de sonido local pausado'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSlate,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      onPressed: _handleStop,
                      icon: const Icon(Icons.stop_rounded),
                      iconSize: 28,
                      tooltip: isGl ? 'Deter' : 'Detener',
                    ),
                    const SizedBox(width: 20),
                    IconButton.filled(
                      onPressed: _isPlaying ? _handlePause : _handlePlay,
                      icon: Icon(_isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded),
                      iconSize: 36,
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.primaryVigoBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16.0),
                      ),
                      tooltip: _isPlaying
                          ? (isGl ? 'Pausar' : 'Pausar')
                          : (isGl ? 'Reproducir' : 'Reproducir'),
                    ),
                    const SizedBox(width: 20),
                    IconButton.filledTonal(
                      onPressed: _handlePlay,
                      icon: const Icon(Icons.replay_rounded),
                      iconSize: 28,
                      tooltip: isGl ? 'Reiniciar pulso' : 'Reiniciar pulso',
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  isGl
                      ? '🔒 Audio 100% sen conexión (mar_pulso_72bpm.wav / local)'
                      : '🔒 Audio 100% sin conexión (mar_pulso_72bpm.wav / local)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF64748B),
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20.0),

        // Teacher Consigna
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF7EE),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: const Color(0xFFDFD7BE)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.record_voice_over_outlined,
                  color: AppTheme.primaryVigoBlue, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGl
                          ? 'Consigna para a docente:'
                          : 'Consigna para la docente:',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryVigoBlue,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cancion.consignaDocente.resolve(widget.language),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 16.0,
                        height: 1.45,
                        color: AppTheme.textSlate,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20.0),

        // Lyrics with Pulse Markers
        Text(
          isGl
              ? 'Letra con pulsos rítmicos (*):'
              : 'Letra con pulsos rítmicos (*):',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryVigoBlue,
          ),
        ),
        const SizedBox(height: 10.0),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: const Color(0xFFE2DDD0), width: 1.5),
          ),
          child: Text(
            cancion.letraConPulsos.resolve(widget.language),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 18.0,
              height: 1.8,
              letterSpacing: 0.3,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSlate,
            ),
          ),
        ),
      ],
    );
  }
}
