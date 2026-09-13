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
import 'nota_para_casas_screen.dart';
import '../widgets/barra_ingles_widget.dart';
import '../widgets/paso_ponte_casa_widget.dart';
import '../widgets/paso_preguntas_widget.dart';
import '../../premios/premios_model.dart';
import '../../premios/premios_repository.dart';
import '../../../core/storage/calendario_store.dart';

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

  /// Opcional a propósito: los tests que ya existían montan esta pantalla sin
  /// premios y tienen que seguir valiendo. Sin repositorio, la asamblea
  /// funciona igual y no cuenta nada.
  final PremiosRepository? premios;

  /// Rexistro do calendario escolar-fogar para a dobre estimulación.
  final CalendarioStore? calendario;

  const AsambleaGuiadaScreen({
    super.key,
    required this.unidad,
    this.audioService,
    this.initialLanguage = AppLanguage.gl,
    this.onLanguageChanged,
    this.premios,
    this.calendario,
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

  Future<void> _finalizarAsamblea() async {
    final isGl = _language == AppLanguage.gl;
    _audioService.stop();

    // Los premios de Lúa cuentan esta asamblea. Es lo ÚNICO que se guarda: un
    // contador y la fecha, sin nada de ninguna crianza ni de la sesión.
    final nuevas = await widget.premios?.registrar(
          Perfil.docente,
          EventoPremio.asamblea,
        ) ??
        const <Insignia>[];

    // La asamblea queda registrada en el calendario del aula. Solo el lado del
    // aula: lo que pase en cada casa lo marca cada casa, porque esta app no
    // tiene forma de saberlo y fingir que sí era el defecto de fondo.
    await widget.calendario?.registrarAula();

    if (!mounted) return;

    // El mensaje anterior decía «la app no guarda nada de la sesión». Dejó de
    // ser cierto en el momento en que empezó a contarse la asamblea, así que
    // cambia aquí, en el mismo cambio que lo volvió falso. Un texto que miente
    // a la maestra es el mismo defecto que un informe que certifica lo que no
    // ejecutó.
    final mensaje = nuevas.isNotEmpty
        ? (isGl
            ? 'Asemblea completada. Gañaches: ${nuevas.first.titulo.gl}'
            : 'Asamblea completada. Ganaste: ${nuevas.first.titulo.es}')
        : (isGl
            ? 'Asemblea completada. Só se garda a conta, nada da sesión.'
            : 'Asamblea completada. Solo se guarda la cuenta, nada de la sesión.');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: AppTheme.calmSage,
      ),
    );

    // Y aquí es donde la asamblea llega a las casas: con una nota que se copia,
    // no con una casilla en el móvil de una familia que no estuvo en el aula.
    // Si la unidad no trae puente con la casa, no se enseña nada.
    if (widget.unidad.puenteCasa.mensajeFamilias
        .resolve(_language)
        .trim()
        .isNotEmpty) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NotaParaCasasScreen(
            unidad: widget.unidad,
            language: _language,
            audioService: _audioService,
          ),
        ),
      );
      if (!mounted) return;
    }

    Navigator.of(context).pop();
  }

  Widget _buildContenidoDelPaso() {
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
          audioService: _audioService,
        );
      case 2:
        return PasoPreguntasWidget(
          preguntas: unidad.preguntas,
          language: _language,
          audioService: _audioService,
        );
      case 3:
        return PasoExploracionWidget(
          exploracion: unidad.exploracion,
          language: _language,
          audioService: _audioService,
        );
      case 4:
        return PasoMatematicasWidget(
          matematicas: unidad.matematicas,
          language: _language,
          audioService: _audioService,
        );
      case 5:
        return PasoPonteCasaWidget(
          ponteCasa: unidad.puenteCasa,
          language: _language,
          audioService: _audioService,
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
            // Banner de Asistente Docente: Cero Pantallas e tempo recomendado
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: AppTheme.primaryLight,
              child: Row(
                children: [
                  const Icon(Icons.phonelink_erase_rounded,
                      size: 18, color: AppTheme.primaryDark),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isGl
                          ? 'Asistente docente · Móbil fóra da vista · 5-8 min máx.'
                          : 'Asistente docente · Móvil fuera de la vista · 5-8 min máx.',
                      style: const TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: const Text(
                      '~1-2 min',
                      style: TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                      ),
                    ),
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
                  _buildContenidoDelPaso(),
                  const SizedBox(height: 32.0),
                ],
              ),
            ),

            // El inglés de la fase, ANCLADO encima de la navegación.
            //
            // Estuvo dentro del scroll y era inútil: quedaba al final de una
            // fase larga, debajo del pliegue, y para oír «Gentle waves» había
            // que bajar hasta el fondo con doce criaturas delante. Aquí no se
            // mueve: mismo sitio en las seis fases, al alcance del pulgar.
            BarraInglesFase(
              textos: widget.unidad.ingles.deFase(_currentPaso),
              language: _language,
              audioService: _audioService,
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
                      minimumSize: const Size(0, 48),
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
                        minimumSize: const Size(0, 48),
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
                        minimumSize: const Size(0, 48),
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
