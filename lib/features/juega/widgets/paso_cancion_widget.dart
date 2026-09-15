import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/audio/local_audio_player.dart';
import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/unidad_model.dart';
import 'rhythm_bar_widget.dart';

/// Phase 1: canción a pulso.
///
/// The teacher gets:
/// - a VISUAL metronome at the unit's tempo, beats read from the `*` markers
///   in the lyrics. It is drawn rather than clicked, as in the earlier project in the house: an audible
///   metronome competes with the voice the children are following, and many of
///   them wear a hearing aid or an implant
/// - the lyrics with those same markers, for clapping or patting knees
/// - the recited lyrics as a bundled recording, on demand
/// - the teacher facilitation directive (consigna docente)
class PasoCancionWidget extends StatefulWidget {
  final CancionPulso cancion;
  final AppLanguage language;
  final OfflineAudioService audioService;

  /// Modo asamblea: solo lo que se hace AHORA. Lo demás —la consigna, que ya
  /// está arriba en grande, y la nota de que el audio es local— se pliega.
  final bool soloEsencial;

  const PasoCancionWidget({
    super.key,
    required this.cancion,
    required this.language,
    required this.audioService,
    this.soloEsencial = false,
  });

  @override
  State<PasoCancionWidget> createState() => _PasoCancionWidgetState();
}

class _PasoCancionWidgetState extends State<PasoCancionWidget> {
  bool _isPlaying = false;
  String? _audioError;
  StreamSubscription<bool>? _audioSubscription;

  /// Visual metronome state. One tick per beat, as in the earlier project in the house: the pulse is
  /// drawn rather than sounded, so the auditory channel stays free for the
  /// voice — half the children this work is aimed at wear a hearing aid or an
  /// implant, and a clicking metronome competes with the words.
  Timer? _pulseTimer;
  int _beat = 0;
  bool _pulseRunning = false;

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
    _pulseTimer?.cancel();
    _audioSubscription?.cancel();
    super.dispose();
  }

  int get _beatsPerLine => widget.cancion.beatsPerLine(widget.language);

  void _togglePulse() {
    if (_pulseRunning) {
      _stopPulse();
      return;
    }
    setState(() {
      _pulseRunning = true;
      _beat = 0;
    });
    _pulseTimer?.cancel();
    _pulseTimer = Timer.periodic(widget.cancion.beatDuration, (_) {
      if (!mounted) return;
      setState(() => _beat = (_beat + 1) % _beatsPerLine);
    });
  }

  void _stopPulse() {
    _pulseTimer?.cancel();
    _pulseTimer = null;
    if (!mounted) return;
    setState(() {
      _pulseRunning = false;
      _beat = 0;
    });
  }

  Future<void> _handlePlay() async {
    final assetPath = widget.cancion.resolveAudio(widget.language);
    final effectivePath =
        assetPath.isNotEmpty ? assetPath : 'assets/audio/mar_pulso_72bpm.wav';
    try {
      await widget.audioService.playAsset(effectivePath);
      if (mounted) setState(() => _audioError = null);
    } on AudioAssetException {
      // A recording missing from the package used to be invisible: the button
      // flipped to "playing" and the room heard silence. The teacher is told
      // instead, and can run the assembly with her own voice.
      if (!mounted) return;
      setState(() {
        _audioError = widget.language == AppLanguage.gl
            ? 'Esta gravación non está incluída nesta versión. Podes marcar o pulso coa túa voz.'
            : 'Esta grabación no está incluida en esta versión. Puedes marcar el pulso con tu voz.';
      });
    }
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

        // Visual metronome. The pulse is shown, not clicked: an audible
        // metronome would compete with the very voice the children follow.
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
                RhythmBarWidget(
                  beats: _beatsPerLine,
                  accentEvery: cancion.accentEvery(widget.language),
                  current: _pulseRunning ? _beat : null,
                  tempoLabel: isGl
                      ? '${cancion.bpm} pulsacións por minuto · $_beatsPerLine tempos por verso'
                      : '${cancion.bpm} pulsaciones por minuto · $_beatsPerLine tiempos por verso',
                  semanticsLabel: isGl
                      ? 'Metrónomo visual a ${cancion.bpm} pulsacións por minuto, $_beatsPerLine tempos por verso'
                      : 'Metrónomo visual a ${cancion.bpm} pulsaciones por minuto, $_beatsPerLine tiempos por verso',
                ),
                const SizedBox(height: 14.0),
                OutlinedButton.icon(
                  onPressed: _togglePulse,
                  icon: Icon(
                    _pulseRunning
                        ? Icons.stop_rounded
                        : Icons.play_arrow_rounded,
                  ),
                  label: Text(
                    _pulseRunning
                        ? (isGl ? 'Deter o pulso' : 'Detener el pulso')
                        : (isGl ? 'Marcar o pulso' : 'Marcar el pulso'),
                  ),
                ),
              ],
            ),
          ),
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
                    // Flexible: «Reproduciendo el recitado de la letra» no cabe
                    // en una línea de 256 dp ni a escala normal.
                    Flexible(
                      child: Text(
                        _isPlaying
                            ? (isGl
                                ? 'Reproducindo o recitado da letra'
                                : 'Reproduciendo el recitado de la letra')
                            : (isGl
                                ? 'Recitado da letra detido'
                                : 'Recitado de la letra detenido'),
                        maxLines: 2,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSlate,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_audioError != null) ...[
                  const SizedBox(height: 12.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline,
                          size: 20, color: Color(0xFF8A6D3B)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _audioError!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF8A6D3B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
                if (!widget.soloEsencial) const SizedBox(height: 8.0),
                if (!widget.soloEsencial)
                  Text(
                    isGl
                        ? 'Audio 100% sen conexión (mar_pulso_72bpm.wav / local)'
                        : 'Audio 100% sin conexión (mar_pulso_72bpm.wav / local)',
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

        // Teacher Consigna. En modo asamblea se pliega: la consigna de la
        // fase ya está arriba, en grande, y repetirla aquí solo alarga la
        // pantalla que hay que recorrer con doce criaturas delante.
        if (!widget.soloEsencial)
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
                      Align(
                        alignment: Alignment.centerLeft,
                        child: BotonEscuchar(
                          audioService: widget.audioService,
                          texto:
                              cancion.consignaDocente.resolve(widget.language),
                          language: widget.language,
                          compacto: true,
                          descripcion: widget.language == AppLanguage.gl
                              ? 'a consigna docente'
                              : 'la consigna docente',
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
