import 'package:flutter/material.dart';
import '../../../core/audio/fade_audio_coordinator.dart';
import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/asamblea_segundo_ciclo_model.dart';
import '../../../data/repositories/content_repository.dart';
import '../../academy/widgets/selector_idioma_widget.dart';
import '../widgets/backstage/backstage_level_switcher.dart';
import '../widgets/backstage/backstage_phase_timer_widget.dart';
import '../widgets/backstage/paso_calm_widget.dart';
import '../widgets/backstage/paso_core_tpr_widget.dart';
import '../widgets/backstage/paso_opening_widget.dart';
import '../widgets/backstage/paso_rhythm_widget.dart';

/// Pantalla Backstage de Asemblea Matinal para o Segundo Ciclo (3-6 anos).
///
/// Filosofía de deseño:
/// - Modo escuro integral (`AppTheme.backstageDarkTheme`) para cero emisión lumínica cara aos nenos.
/// - Tipografía de alta lexibilidade (>= 24sp en comandos e títulos) visible a distancia polo docente.
/// - Áreas táctiles amplas (>= 48dp/64dp).
/// - Temporizador silencioso e discreto con indicación ámbar en horas extras.
/// - Coordenación de audio con fundido suave (fade-in / fade-out) sen estridencias.
/// - Cero elementos lúdicos infantís nin gamificación punitiva na pantalla.
class BackstageAsambleaScreen extends StatefulWidget {
  final ContentRepository repository;
  final OfflineAudioService? audioService;
  final NivelEducativoSegundoCiclo initialNivel;
  final AppLanguage initialLanguage;
  final ValueChanged<AppLanguage>? onLanguageChanged;
  final int initialMes;

  const BackstageAsambleaScreen({
    super.key,
    required this.repository,
    this.audioService,
    this.initialNivel = NivelEducativoSegundoCiclo.infantil4,
    this.initialLanguage = AppLanguage.gl,
    this.onLanguageChanged,
    this.initialMes = 9,
  });

  @override
  State<BackstageAsambleaScreen> createState() =>
      _BackstageAsambleaScreenState();
}

class _BackstageAsambleaScreenState extends State<BackstageAsambleaScreen> {
  late NivelEducativoSegundoCiclo _nivel;
  late AppLanguage _language;
  late int _faseIndex; // 0..3
  AsambleaSegundoCiclo? _asamblea;
  FadeAudioCoordinator? _audioCoordinator;

  bool _isPlayingCue = false;
  bool _isPulsePlaying = false;
  bool _isPlayingCalmAudio = false;
  String? _currentlyPlayingAsset;

  @override
  void initState() {
    super.initState();
    _nivel = widget.initialNivel;
    _language = widget.initialLanguage;
    _faseIndex = 0;

    if (widget.audioService != null) {
      _audioCoordinator = FadeAudioCoordinator(service: widget.audioService!);
    }

    _loadAsamblea();
  }

  void _loadAsamblea() {
    if (!widget.repository.isInitialized) {
      widget.repository.initialize().then((_) {
        if (mounted) {
          setState(() {
            _loadAsamblea();
          });
        }
      });
      return;
    }
    final asamblea = widget.repository.getAsambleaByMesYNivelSync(
      widget.initialMes,
      _nivel,
    );
    if (asamblea != null) {
      _asamblea = asamblea;
    } else {
      final list = widget.repository.getAsambleasByNivelSync(_nivel);
      if (list.isNotEmpty) {
        _asamblea = list.first;
      }
    }
  }

  void _onNivelChanged(NivelEducativoSegundoCiclo nuevoNivel) {
    if (_nivel == nuevoNivel) return;
    _stopAllAudio();
    setState(() {
      _nivel = nuevoNivel;
      _faseIndex = 0;
      _loadAsamblea();
    });
  }

  void _onFaseSelected(int index) {
    if (_faseIndex == index) return;
    _stopAllAudio();
    setState(() {
      _faseIndex = index.clamp(0, 3);
    });
  }

  void _toggleLanguage() {
    final newLang = _language.toggle();
    setState(() {
      _language = newLang;
    });
    widget.onLanguageChanged?.call(newLang);
  }

  Future<void> _stopAllAudio() async {
    if (_audioCoordinator != null) {
      await _audioCoordinator!.stopWithFadeOut();
    }
    if (mounted) {
      setState(() {
        _isPlayingCue = false;
        _isPulsePlaying = false;
        _isPlayingCalmAudio = false;
        _currentlyPlayingAsset = null;
      });
    }
  }

  Future<void> _handlePlayOpeningCue(String? cueAsset) async {
    if (_audioCoordinator == null || cueAsset == null || cueAsset.isEmpty) {
      return;
    }
    if (_isPlayingCue) {
      await _stopAllAudio();
    } else {
      await _stopAllAudio();
      setState(() {
        _isPlayingCue = true;
        _currentlyPlayingAsset = cueAsset;
      });
      try {
        await _audioCoordinator!.playWithFadeIn(cueAsset);
      } catch (_) {
        if (mounted) {
          setState(() {
            _isPlayingCue = false;
            _currentlyPlayingAsset = null;
          });
        }
      }
    }
  }

  Future<void> _handleTogglePulse(String? pulseAsset) async {
    if (_audioCoordinator == null) return;
    if (_isPulsePlaying) {
      await _stopAllAudio();
    } else {
      await _stopAllAudio();
      final assetToPlay = (pulseAsset != null && pulseAsset.isNotEmpty)
          ? pulseAsset
          : 'assets/audio/mar_pulso_72bpm.wav';
      setState(() {
        _isPulsePlaying = true;
        _currentlyPlayingAsset = assetToPlay;
      });
      try {
        await _audioCoordinator!.playWithFadeIn(assetToPlay);
      } catch (_) {
        if (mounted) {
          setState(() {
            _isPulsePlaying = false;
            _currentlyPlayingAsset = null;
          });
        }
      }
    }
  }

  Future<void> _handlePlayCommandAudio(String audioAsset) async {
    if (_audioCoordinator == null) return;
    if (_currentlyPlayingAsset == audioAsset) {
      await _stopAllAudio();
    } else {
      await _stopAllAudio();
      setState(() {
        _currentlyPlayingAsset = audioAsset;
      });
      try {
        await _audioCoordinator!.playWithFadeIn(audioAsset);
      } catch (_) {
        if (mounted) {
          setState(() {
            _currentlyPlayingAsset = null;
          });
        }
      }
    }
  }

  Future<void> _handlePlayCalmAudio(String? calmAsset) async {
    if (_audioCoordinator == null || calmAsset == null || calmAsset.isEmpty) {
      return;
    }
    if (_isPlayingCalmAudio) {
      await _stopAllAudio();
    } else {
      await _stopAllAudio();
      setState(() {
        _isPlayingCalmAudio = true;
        _currentlyPlayingAsset = calmAsset;
      });
      try {
        await _audioCoordinator!.playWithFadeIn(calmAsset);
      } catch (_) {
        if (mounted) {
          setState(() {
            _isPlayingCalmAudio = false;
            _currentlyPlayingAsset = null;
          });
        }
      }
    }
  }

  /// Con el texto grande del sistema la cabecera se come la pantalla. Lo que
  /// sobra entonces es el adorno, no el contenido: misma regla que en la
  /// asamblea de primer ciclo.
  static bool _textoMoiGrande(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(14) > 19;

  Future<bool> _confirmFinish() async {
    final isGl = _language == AppLanguage.gl;
    final shouldFinish = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backstageSurfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          side: const BorderSide(color: AppTheme.backstageBorder, width: 1.5),
        ),
        title: Text(
          isGl ? 'Rematar Asemblea Matinal?' : '¿Finalizar Asamblea Matinal?',
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.backstageTextPrimary,
          ),
        ),
        content: Text(
          isGl
              ? 'Completáronse as 4 fases canónicas da asemblea de hoxe. Desexas concluír a sesión e saír ao menú?'
              : 'Se han completado las 4 fases canónicas de la asamblea de hoy. ¿Deseas concluir la sesión y salir al menú?',
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 16,
            color: AppTheme.backstageTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              isGl ? 'Continuar na Asemblea' : 'Continuar en la Asamblea',
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.backstageTextSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.backstageAccent,
              foregroundColor: AppTheme.backstageBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusButton),
              ),
            ),
            child: Text(
              isGl ? 'Rematar e Saír' : 'Finalizar y Salir',
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldFinish == true) {
      await _stopAllAudio();
      return true;
    }
    return false;
  }

  Future<bool> _confirmExit() async {
    final isGl = _language == AppLanguage.gl;
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backstageSurfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          side: const BorderSide(color: AppTheme.backstageBorder, width: 1.5),
        ),
        title: Text(
          isGl ? 'Saír da Asemblea?' : '¿Salir de la Asamblea?',
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.backstageTextPrimary,
          ),
        ),
        content: Text(
          isGl
              ? 'Ao saír deterase o temporizador da fase e calquera son que estea activo.'
              : 'Al salir se detendrá el temporizador de la fase y cualquier sonido que esté activo.',
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 16,
            color: AppTheme.backstageTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              isGl ? 'Continuar Asemblea' : 'Continuar Asamblea',
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.backstageAccent,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusButton),
              ),
            ),
            child: Text(
              isGl ? 'Saír' : 'Salir',
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      await _stopAllAudio();
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _audioCoordinator?.stopImmediate();
    _audioCoordinator?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isGl = _language == AppLanguage.gl;
    final asamblea = _asamblea;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final ok = await _confirmExit();
        if (ok && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backstageBg,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 26),
            onPressed: () async {
              final ok = await _confirmExit();
              if (ok && context.mounted) {
                Navigator.of(context).pop();
              }
            },
            tooltip: 'Volver',
          ),
          title: Text(
            isGl ? 'Modo Asemblea · 2.º Ciclo' : 'Modo Asamblea · 2.º Ciclo',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: SelectorIdiomaWidget(
                currentLanguage: _language,
                onLanguageChanged: (l) => _toggleLanguage(),
                compact: true,
              ),
            ),
          ],
        ),
        body: asamblea == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    isGl
                        ? 'Non se atoparon contidos para este nivel.'
                        : 'No se encontraron contenidos para este nivel.',
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 16,
                      color: AppTheme.backstageTextSecondary,
                    ),
                  ),
                ),
              )
            : SafeArea(
                child: Column(
                  children: [
                    // La cabecera de la asamblea de primer ciclo, misma
                    // pieza: en qué fase vamos, cómo se llama, y una barra
                    // que lo dice sin números. El stepper de cuatro
                    // pastillas y el cronómetro gigante se fueron con el
                    // fondo negro: decían lo mismo ocupando media pantalla.
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      color: AppTheme.cardSurface,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          BackstageLevelSwitcher(
                            nivelSeleccionado: _nivel,
                            onNivelChanged: _onNivelChanged,
                            language: _language,
                          ),
                          const SizedBox(height: 12),
                          if (!_textoMoiGrande(context))
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    isGl
                                        ? 'Fase ${_faseIndex + 1} de 4'
                                        : 'Fase ${_faseIndex + 1} de 4',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppTheme.primaryVigoBlue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    asamblea
                                        .fases[_faseIndex.clamp(
                                            0, asamblea.fases.length - 1)]
                                        .tipo
                                        .nombre
                                        .resolve(_language),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                      color: AppTheme.textSlate,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (!_textoMoiGrande(context))
                            const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: (_faseIndex + 1) / 4.0,
                            backgroundColor: const Color(0xFFE2DDD0),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryVigoBlue),
                            minHeight: 6.0,
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                          const SizedBox(height: 10),
                          // Los segundos de la fase. Empieza parado, como el de
                          // primer ciclo: la asamblea arranca cuando lo dice la
                          // docente, no cuando se abre la pantalla.
                          Center(
                            child: BackstagePhaseTimerWidget(
                              key: ValueKey(
                                'timer_fase_${_faseIndex}_nivel_${_nivel.clave}',
                              ),
                              duracionSegundos: asamblea
                                  .fases[_faseIndex.clamp(
                                      0, asamblea.fases.length - 1)]
                                  .duracionSegundos,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // El aviso de la asamblea de primer ciclo, palabra por
                    // palabra: el móvil es del adulto y no se enseña.
                    if (!_textoMoiGrande(context))
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        color: AppTheme.primaryLight,
                        child: Row(
                          children: [
                            const Icon(Icons.phonelink_erase_rounded,
                                size: 18, color: AppTheme.primaryDark),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isGl
                                    ? 'Asistente docente · Móbil fóra da vista'
                                    : 'Asistente docente · Móvil fuera de la vista',
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Divider(
                      color: AppTheme.backstageBorder,
                      height: 1,
                    ),

                    // Bloque principal scrollable co contido da fase activa
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: _buildPhaseContent(asamblea),
                      ),
                    ),

                    // Barra inferior de navegación entre fases
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppTheme.backstageSurface,
                        border: Border(
                          top: BorderSide(
                            color: AppTheme.backstageBorder,
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Botón Fase Anterior
                          Expanded(
                            child: OutlinedButton.icon(
                              key:
                                  const ValueKey('backstage_prev_phase_button'),
                              onPressed: _faseIndex > 0
                                  ? () => _onFaseSelected(_faseIndex - 1)
                                  : null,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.backstageTextPrimary,
                                disabledForegroundColor:
                                    AppTheme.backstageTextMuted,
                                side: BorderSide(
                                  color: _faseIndex > 0
                                      ? AppTheme.backstageBorder
                                      : AppTheme.backstageBorder
                                          .withValues(alpha: 0.3),
                                ),
                                minimumSize: const Size(0, 52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusButton,
                                  ),
                                ),
                              ),
                              icon: const Icon(Icons.chevron_left_rounded),
                              label: Text(
                                isGl ? 'Fase Anterior' : 'Fase Anterior',
                                style: const TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Botón Seguinte Fase / Rematar
                          Expanded(
                            child: ElevatedButton.icon(
                              key:
                                  const ValueKey('backstage_next_phase_button'),
                              onPressed: () async {
                                if (_faseIndex < 3) {
                                  _onFaseSelected(_faseIndex + 1);
                                  return;
                                }
                                // Rematar asemblea
                                final ok = await _confirmFinish();
                                if (!context.mounted) return;
                                if (ok) {
                                  Navigator.of(context).pop();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.backstageAccent,
                                foregroundColor: AppTheme.backstageBg,
                                minimumSize: const Size(0, 52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusButton,
                                  ),
                                ),
                              ),
                              icon: Icon(
                                _faseIndex < 3
                                    ? Icons.arrow_forward_rounded
                                    : Icons.check_circle_rounded,
                              ),
                              label: Text(
                                _faseIndex < 3
                                    ? (isGl
                                        ? 'Seguinte Fase'
                                        : 'Siguiente Fase')
                                    : (isGl
                                        ? 'Rematar Asemblea'
                                        : 'Finalizar Asamblea'),
                                style: const TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPhaseContent(AsambleaSegundoCiclo asamblea) {
    if (asamblea.fases.isEmpty) return const SizedBox.shrink();
    final safeIndex = _faseIndex.clamp(0, asamblea.fases.length - 1);
    final fase = asamblea.fases[safeIndex];

    return switch (safeIndex) {
      0 => PasoOpeningWidget(
          fase: fase,
          language: _language,
          audioService: widget.audioService,
          onPlayCue: (fase.audioAsset != null && fase.audioAsset!.isNotEmpty)
              ? () => _handlePlayOpeningCue(fase.audioAsset)
              : null,
          isPlayingCue: _isPlayingCue,
        ),
      1 => PasoRhythmWidget(
          fase: fase,
          language: _language,
          audioService: widget.audioService,
          onTogglePulse: () => _handleTogglePulse(fase.audioAsset),
          isPulsePlaying: _isPulsePlaying,
        ),
      2 => PasoCoreTprWidget(
          fase: fase,
          language: _language,
          audioService: widget.audioService,
          metodologia: asamblea.metodologiaTpr,
          onPlayCommandAudio: _handlePlayCommandAudio,
          currentlyPlayingAsset: _currentlyPlayingAsset,
          onStopAudio: _stopAllAudio,
        ),
      3 => PasoCalmWidget(
          fase: fase,
          language: _language,
          audioService: widget.audioService,
          onPlayCalmAudio:
              (fase.audioAsset != null && fase.audioAsset!.isNotEmpty)
                  ? () => _handlePlayCalmAudio(fase.audioAsset)
                  : null,
          isPlayingCalmAudio: _isPlayingCalmAudio,
        ),
      _ => const SizedBox.shrink(),
    };
  }
}
