import 'package:flutter/material.dart';
import '../../../core/audio/local_audio_player.dart';
import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/paxina_sen_scroll.dart';
import '../../../data/models/unidad_model.dart';
import '../../academy/widgets/selector_idioma_widget.dart';
import '../widgets/paso_cancion_widget.dart';
import '../widgets/paso_conto_widget.dart';
import '../widgets/paso_exploracion_widget.dart';
import '../widgets/paso_matematicas_widget.dart';
import 'nota_para_casas_screen.dart';
import '../widgets/barra_ingles_widget.dart';
import '../widgets/consigna_fase_widget.dart';
import '../../../data/repositories/ritual_repository.dart';
import '../widgets/vocabulario_widget.dart';
import '../widgets/paso_ponte_casa_widget.dart';
import '../widgets/paso_preguntas_widget.dart';
import '../../premios/premios_model.dart';
import '../../premios/premios_repository.dart';
import '../../../core/storage/calendario_store.dart';
import '../../../core/widgets/boton_atras.dart';

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

  /// La página del cuento que se está leyendo. La barra de inglés la necesita:
  /// cada página tiene lo suyo que decir, y una lista para todo el cuento deja
  /// a la docente sin saber cuándo toca cada palabra.
  int _paginaConto = 0;

  /// El ritual: la consigna y los minutos de cada fase. Si no se puede leer, la
  /// asamblea funciona igual y sin consigna: es una ayuda, no un requisito, y
  /// dejar la pantalla en blanco por ella sería peor que no tenerla.
  RitualAsamblea _ritual = RitualAsamblea.ningun;

  /// Modo asamblea: arranca ENCENDIDO. Con doce criaturas en la alfombra se
  /// mira el móvil dos segundos, y lo que sobra estorba. La ficha completa
  /// —consejos, materiales, objetivos— es para preparar la sesión antes, y
  /// está a un toque.
  bool _modoAsamblea = true;
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
    RitualAsamblea.cargar().then((r) {
      if (!mounted) return;
      setState(() => _ritual = r);
    }).catchError((Object _) {/* sin consigna, pero con asamblea */});
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

  /// La duración de la asamblea, sumada del ritual. Antes aquí había un
  /// «5-8 min máx.» escrito a mano que no lo sostenía nada.
  String get _duracionTotal {
    final total = _ritual.minutosTotales;
    return total > 0 ? ' · ~$total min' : '';
  }

  /// Si la persona que mira lleva el texto del sistema muy grande.
  ///
  /// A partir de aquí la pantalla recoge el adorno para que quepa el
  /// contenido. El umbral está en el tamaño RESULTANTE, no en el factor: es lo
  /// que decide si una línea cabe.
  static bool _textoMoiGrande(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(14) > 19;

  /// Lo que se dice en inglés justo ahora.
  ///
  /// En el cuento manda la página que se tiene delante; en las demás fases, el
  /// inglés de la fase. Si una página no lo trae escrito, se cae al de la fase
  /// en vez de dejar la barra vacía.
  List<String> _inglesDeAhora() {
    const faseConto = 1;
    if (_currentPaso == faseConto) {
      final paginas = widget.unidad.cuento.paginas;
      if (_paginaConto >= 0 && _paginaConto < paginas.length) {
        final dePagina = paginas[_paginaConto].ingles;
        if (dePagina.isNotEmpty) return dePagina;
      }
    }
    return widget.unidad.ingles.deFase(_currentPaso);
  }

  Widget _buildContenidoDelPaso() {
    final unidad = widget.unidad;

    switch (_currentPaso) {
      case 0:
        return PasoCancionWidget(
          cancion: unidad.cancionPulso,
          language: _language,
          audioService: _audioService,
          soloEsencial: _modoAsamblea,
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PasoContoWidget(
              cuento: unidad.cuento,
              language: _language,
              audioService: _audioService,
              onPaginaCambiada: (i) => setState(() => _paginaConto = i),
            ),
            const SizedBox(height: AppTheme.spaceLg),
            VocabularioDaUnidade(
              items: unidad.vocabulario,
              language: _language,
              audioService: _audioService,
            ),
          ],
        );
      case 2:
        return PasoPreguntasWidget(
          preguntas: unidad.preguntas,
          language: _language,
          audioService: _audioService,
          soloEsencial: _modoAsamblea,
        );
      case 3:
        return PasoExploracionWidget(
          exploracion: unidad.exploracion,
          language: _language,
          audioService: _audioService,
          soloEsencial: _modoAsamblea,
        );
      case 4:
        return PasoMatematicasWidget(
          matematicas: unidad.matematicas,
          language: _language,
          audioService: _audioService,
          soloEsencial: _modoAsamblea,
        );
      case 5:
        return PasoPonteCasaWidget(
          ponteCasa: unidad.puenteCasa,
          language: _language,
          audioService: _audioService,
          onFinalizar: _finalizarAsamblea,
          soloEsencial: _modoAsamblea,
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
        leading: const BotonAtras(),
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
            // Con el texto grande del sistema, la pantalla se queda sin sitio:
            // cabecera, aviso, barra de inglés y navegación sumaban más que el
            // alto disponible y el conjunto desbordaba por abajo. Lo que sobra
            // en ese caso es el adorno, no el contenido: el rótulo de la fase
            // y el aviso de «móbil fóra da vista» se recogen, y la barra de
            // progreso —que dice lo mismo— se queda.
            // Stepper progress indicator header
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              color: AppTheme.cardSurface,
              child: Column(
                children: [
                  // Flexible en los dos, y no un Row a pelo: «Fase 4 de 6» y
                  // «4. Exploración sensorial» no caben juntos en 360 dp, y
                  // menos con el texto grande del sistema. Desbordaba desde
                  // siempre; en release eso no se ve, el texto se corta.
                  if (!_textoMoiGrande(context))
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Fase ${_currentPaso + 1} de 6',
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
                            titulosPasos[_currentPaso],
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
                  if (!_textoMoiGrande(context)) const SizedBox(height: 8),
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
            // La consigna de la fase: qué se hace AHORA, en una línea grande,
            // con los minutos sugeridos y un reloj que empieza parado.
            if (_ritual.enPosicion(_currentPaso) != null)
              ConsignaFaseWidget.dePrimeiroCiclo(
                key: ValueKey('consigna_$_currentPaso'),
                fase: _ritual.enPosicion(_currentPaso)!,
                language: _language,
              ),

            // Banner de Asistente Docente: Cero Pantallas e tempo recomendado
            if (!_textoMoiGrande(context))
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
                            ? 'Asistente docente · Móbil fóra da vista$_duracionTotal'
                            : 'Asistente docente · Móvil fuera de la vista$_duracionTotal',
                        style: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                    ),
                    // Aquí había un «~1-2 min» escrito a mano que discutía con
                    // los minutos reales de la fase, ahora en la consigna de
                    // arriba. Dos cifras distintas para lo mismo es peor que
                    // ninguna.
                  ],
                ),
              ),
            if (!_textoMoiGrande(context)) const Divider(height: 1),

            // Main Phase Content View
            Expanded(
              child: PaxinaSenScroll(
                  // Esta es la asamblea VIEJA de seis pasos del 1.º ciclo, la que
                  // venía del encargo original. No está en los documentos
                  // curriculares de Frank, que piden CUATRO fases, y su contenido
                  // no cabe ni encogido al 80 %. Hasta que se retire en favor del
                  // reproductor nuevo, se deja desplazar antes que recortar texto.
                  desprazarSeNonCabe: true,
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildContenidoDelPaso(),
                      const SizedBox(height: AppTheme.spaceLg),
                      // Ni un ExpansionTile ni un acordeón por bloque: un solo
                      // interruptor para toda la fase. Con el grupo delante no se
                      // decide bloque a bloque qué se despliega, se decide una vez.
                      Center(
                        child: TextButton.icon(
                          key: const Key('boton_ficha_completa'),
                          onPressed: () =>
                              setState(() => _modoAsamblea = !_modoAsamblea),
                          icon: Icon(_modoAsamblea
                              ? Icons.unfold_more_rounded
                              : Icons.unfold_less_rounded),
                          label: Text(
                            _modoAsamblea
                                ? (isGl
                                    ? 'Ver a ficha completa'
                                    : 'Ver la ficha completa')
                                : (isGl
                                    ? 'Volver ao modo asemblea'
                                    : 'Volver al modo asamblea'),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                          ),
                          style: TextButton.styleFrom(
                            minimumSize: const Size(0, AppTheme.touchMin),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32.0),
                    ],
                  )),
            ),

            // El inglés de la fase, ANCLADO encima de la navegación.
            //
            // Estuvo dentro del scroll y era inútil: quedaba al final de una
            // fase larga, debajo del pliegue, y para oír «Gentle waves» había
            // que bajar hasta el fondo con doce criaturas delante. Aquí no se
            // mueve: mismo sitio en las seis fases, al alcance del pulgar.
            BarraInglesFase(
              textos: _inglesDeAhora(),
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
              // Expanded en los dos botones y un hueco fijo en medio, en vez
              // de `Spacer` con botones a su tamaño natural: con el texto
              // grande del sistema esa fila desbordaba 289 px por la derecha,
              // y en release eso no se ve: el botón de «Seguinte» se queda a
              // medias fuera de la pantalla.
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _currentPaso > 0 ? _previousPaso : null,
                      icon: const Icon(Icons.arrow_back),
                      label: Text(
                        isGl ? 'Anterior' : 'Anterior',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _currentPaso < 5
                        ? ElevatedButton.icon(
                            key: const Key('boton_seguinte_fase'),
                            onPressed: _nextPaso,
                            icon: const Icon(Icons.arrow_forward),
                            label: Text(
                              isGl ? 'Seguinte' : 'Siguiente',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 48),
                              backgroundColor: AppTheme.primaryVigoBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 12.0),
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: _finalizarAsamblea,
                            icon: const Icon(Icons.check),
                            label: Text(
                              isGl ? 'Finalizar' : 'Finalizar',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 48),
                              backgroundColor: AppTheme.primaryVigoBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 12.0),
                            ),
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
