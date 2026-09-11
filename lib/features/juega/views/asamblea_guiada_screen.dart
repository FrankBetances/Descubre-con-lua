import 'package:flutter/material.dart';
import '../../../core/audio/local_audio_player.dart';
import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/unidad_model.dart';
import '../../academy/widgets/selector_idioma_widget.dart';
import '../widgets/paso_cancion_widget.dart';
import '../widgets/paso_conto_widget.dart';
import '../widgets/paso_exploracion_widget.dart';
import '../widgets/paso_matematicas_widget.dart';
import '../widgets/paso_ponte_casa_widget.dart';
import '../widgets/paso_preguntas_widget.dart';

/// Screen orchestrating the 6 canonical assembly phases for early childhood teachers.
///
/// Phases:
/// 1. Canción a pulso (offline audio player & rhythm markers)
/// 2. Cuento guiado (narrative reading & comprehension)
/// 3. Preguntas graduadas (3 developmental scaffolding levels)
/// 4. Exploración sensorial (materials, steps & mandatory safety alert)
/// 5. Matemáticas temperás (early math concepts & actions)
/// 6. Ponte á casa (family bridge communication)
///
/// Strictly teacher-focused: Sober Material 3 UI, zero child-distracting neon/animations,
/// zero tactile game mechanics for toddlers.
class AsambleaGuiadaScreen extends StatefulWidget {
  final Unidad unidad;
  final OfflineAudioService? audioService;
  final AppLanguage initialLanguage;
  final ValueChanged<AppLanguage>? onLanguageChanged;

  const AsambleaGuiadaScreen({
    super.key,
    required this.unidad,
    this.audioService,
    this.initialLanguage = AppLanguage.gl,
    this.onLanguageChanged,
  });

  @override
  State<AsambleaGuiadaScreen> createState() => _AsambleaGuiadaScreenState();
}

class _AsambleaGuiadaScreenState extends State<AsambleaGuiadaScreen> {
  late int _currentPaso;
  late AppLanguage _language;
  late OfflineAudioService _audioService;
  bool _createdInternalAudioService = false;

  final List<String> _titulosPasosGl = const [
    '1. Canción a pulso',
    '2. Cuento guiado',
    '3. Preguntas graduadas',
    '4. Exploración sensorial',
    '5. Matemáticas temperás',
    '6. Ponte á casa',
  ];

  final List<String> _titulosPasosEs = const [
    '1. Canción a pulso',
    '2. Cuento guiado',
    '3. Preguntas graduadas',
    '4. Exploración sensorial',
    '5. Matemáticas tempranas',
    '6. Puente a casa',
  ];

  @override
  void initState() {
    super.initState();
    _currentPaso = 0;
    _language = widget.initialLanguage;
    if (widget.audioService != null) {
      _audioService = widget.audioService!;
    } else {
      _audioService = LocalAudioPlayer();
      _createdInternalAudioService = true;
    }
  }

  @override
  void dispose() {
    _audioService.stop();
    if (_createdInternalAudioService) {
      _audioService.dispose();
    }
    super.dispose();
  }

  void _onToggleLanguage(AppLanguage newLang) {
    setState(() {
      _language = newLang;
    });
    widget.onLanguageChanged?.call(newLang);
  }

  void _nextPaso() {
    if (_currentPaso < 5) {
      // Pause audio when moving away from Phase 1
      if (_currentPaso == 0 && _audioService.isPlaying) {
        _audioService.pause();
      }
      setState(() {
        _currentPaso++;
      });
    }
  }

  void _previousPaso() {
    if (_currentPaso > 0) {
      setState(() {
        _currentPaso--;
      });
    }
  }

  void _finalizarAsamblea() {
    final isGl = _language == AppLanguage.gl;
    _audioService.stop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isGl
              ? 'Asemblea completada con éxito. Proposta gardada.'
              : 'Asamblea completada con éxito. Propuesta guardada.',
        ),
        backgroundColor: AppTheme.calmSage,
      ),
    );
    Navigator.of(context).pop();
  }

  Widget _buildCurrentPasoWidget() {
    final unidad = widget.unidad;

    switch (_currentPaso) {
      case 0:
        return PasoCancionWidget(
          cancion: unidad.cancionPulso,
          language: _language,
          audioService: _audioService,
        );
      case 1:
        return PasoContoWidget(
          cuento: unidad.cuento,
          language: _language,
        );
      case 2:
        return PasoPreguntasWidget(
          preguntas: unidad.preguntas,
          language: _language,
        );
      case 3:
        return PasoExploracionWidget(
          exploracion: unidad.exploracion,
          language: _language,
        );
      case 4:
        return PasoMatematicasWidget(
          matematicas: unidad.matematicas,
          language: _language,
        );
      case 5:
        return PasoPonteCasaWidget(
          ponteCasa: unidad.puenteCasa,
          language: _language,
          onFinalizar: _finalizarAsamblea,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGl = _language == AppLanguage.gl;
    final titulosPasos = isGl ? _titulosPasosGl : _titulosPasosEs;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isGl ? 'Modo Asemblea · Aula' : 'Modo Asamblea · Aula',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: SelectorIdiomaWidget(
              currentLanguage: _language,
              onLanguageChanged: _onToggleLanguage,
              compact: true,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Stepper progress indicator header
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              color: AppTheme.cardSurface,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isGl
                            ? 'Fase ${_currentPaso + 1} de 6'
                            : 'Fase ${_currentPaso + 1} de 6',
                        style: const TextStyle(
                          color: AppTheme.primaryVigoBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                      Text(
                        titulosPasos[_currentPaso],
                        style: const TextStyle(
                          color: AppTheme.textSlate,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_currentPaso + 1) / 6.0,
                    backgroundColor: const Color(0xFFE2DDD0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryVigoBlue),
                    minHeight: 6.0,
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Main Phase Content View
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20.0),
                children: [
                  _buildCurrentPasoWidget(),
                  const SizedBox(height: 32.0),
                ],
              ),
            ),

            // Bottom Navigation Toolbar
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              decoration: const BoxDecoration(
                color: AppTheme.cardSurface,
                border: Border(
                    top: BorderSide(color: Color(0xFFE2DDD0), width: 1.0)),
              ),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _currentPaso > 0 ? _previousPaso : null,
                    icon: const Icon(Icons.arrow_back),
                    label: Text(isGl ? 'Anterior' : 'Anterior'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                    ),
                  ),
                  const Spacer(),
                  if (_currentPaso < 5)
                    ElevatedButton.icon(
                      onPressed: _nextPaso,
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(isGl ? 'Seguinte' : 'Siguiente'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryVigoBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 12.0),
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: _finalizarAsamblea,
                      icon: const Icon(Icons.check),
                      label: Text(isGl ? 'Finalizar' : 'Finalizar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryVigoBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 12.0),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
