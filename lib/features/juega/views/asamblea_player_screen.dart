import 'package:flutter/material.dart';

import '../../../core/audio/fade_audio_coordinator.dart';
import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/brand/lamina_vector.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/asamblea_segundo_ciclo_model.dart'
    show FaseAsamblea, TipoFaseAsamblea;
import '../../../data/models/progresion_model.dart';

/// El reproductor de la asamblea, el mismo para los dos ciclos.
///
/// Lo que mandan los dos documentos curriculares, y que aquí se cumple:
///
/// - **Una fase ocupa una pantalla entera.** No hay desplazamiento vertical:
///   si algo no cabe, se recorta, no se empuja hacia abajo. La docente tiene
///   doce criaturas delante y no lee hacia abajo.
/// - **Se pasa de fase deslizando de lado**, sin apartar la vista del grupo.
///   Los botones grandes siguen ahí para quien prefiera tocar.
/// - **Fondo oscuro y tipografía grande**: la consigna va a 26 pt, que es lo
///   que pide el documento («no inferiores a 24 puntos», legible a dos metros
///   con el aparato en una repisa).
/// - **Cero elementos para captar la atención infantil.** El móvil es del
///   adulto y no se enseña.
class AsambleaPlayerScreen extends StatefulWidget {
  /// Las cuatro fases de la microcápsula, en orden.
  final List<FaseAsamblea> fases;

  /// Lo que se está dando: mes y grupo. Va en la barra, pequeño.
  final String subtitulo;

  /// El material manipulable del día, si el contenido lo nombra.
  final String? material;

  /// La canción del día, si el contenido la nombra.
  final String? cancion;

  /// El centro de interés del día. Va en todas las fases, abajo: es lo que
  /// une las cuatro y lo que la docente necesita recordar si entra a mitad.
  final String? centroInteres;

  final OfflineAudioService? audioService;
  final AppLanguage language;

  /// El día de la progresión que se está dando, si se abrió por un día. Se
  /// enseña en la fase núcleo: semana, día y foco. Las [fases] ya vienen con
  /// el día aplicado; esto es solo para decirlo en pantalla.
  final DiaDeProgresion? dia;
  final SemanaDeProgresion? semana;

  const AsambleaPlayerScreen({
    super.key,
    required this.fases,
    required this.subtitulo,
    required this.language,
    this.material,
    this.cancion,
    this.centroInteres,
    this.audioService,
    this.dia,
    this.semana,
  });

  @override
  State<AsambleaPlayerScreen> createState() => _AsambleaPlayerScreenState();
}

class _AsambleaPlayerScreenState extends State<AsambleaPlayerScreen> {
  static const Color _fondo = Color(0xFF10151C);
  static const Color _superficie = Color(0xFF1A222C);
  static const Color _borde = Color(0xFF2C3846);
  static const Color _textoPrincipal = Color(0xFFF2F5F7);
  static const Color _textoSecundario = Color(0xFFA8B6C4);
  static const Color _acento = Color(0xFF3ED8D2);

  late final PageController _paxinas;
  int _indice = 0;
  FadeAudioCoordinator? _audio;
  String? _soando;

  @override
  void initState() {
    super.initState();
    _paxinas = PageController();
    if (widget.audioService != null) {
      _audio = FadeAudioCoordinator(service: widget.audioService!);
    }
  }

  @override
  void dispose() {
    _paxinas.dispose();
    _audio?.stopImmediate();
    _audio?.dispose();
    super.dispose();
  }

  Future<void> _parar() async {
    await _audio?.stopWithFadeOut();
    if (mounted) setState(() => _soando = null);
  }

  Future<void> _alternar(String asset) async {
    if (_audio == null || asset.isEmpty) return;
    if (_soando == asset) {
      await _parar();
      return;
    }
    await _parar();
    setState(() => _soando = asset);
    try {
      await _audio!.playWithFadeIn(asset);
    } catch (_) {
      if (mounted) setState(() => _soando = null);
    }
  }

  void _ir(int i) {
    final destino = i.clamp(0, widget.fases.length - 1);
    if (destino == _indice) return;
    _parar();
    _paxinas.animateToPage(
      destino,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<bool> _confirmarSaida() async {
    final isGl = widget.language == AppLanguage.gl;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _superficie,
        title: Text(
          isGl ? 'Saír da asemblea?' : '¿Salir de la asamblea?',
          style: const TextStyle(color: _textoPrincipal, fontSize: 20),
        ),
        content: Text(
          isGl
              ? 'Pérdese por onde ías. O contido non se borra.'
              : 'Se pierde por dónde ibas. El contenido no se borra.',
          style: const TextStyle(color: _textoSecundario, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(isGl ? 'Seguir' : 'Seguir',
                style: const TextStyle(color: _textoSecundario)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(isGl ? 'Saír' : 'Salir',
                style: const TextStyle(color: _acento)),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isGl = widget.language == AppLanguage.gl;
    final total = widget.fases.length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final ok = await _confirmarSaida();
        if (!mounted) return;
        if (ok) Navigator.of(this.context).pop();
      },
      child: Scaffold(
        backgroundColor: _fondo,
        body: SafeArea(
          child: Column(
            children: [
              _Barra(
                subtitulo: widget.subtitulo,
                indice: _indice,
                total: total,
                onSair: () async {
                  final ok = await _confirmarSaida();
                  if (!mounted) return;
                  if (ok) Navigator.of(this.context).pop();
                },
              ),
              Expanded(
                child: PageView.builder(
                  controller: _paxinas,
                  itemCount: total,
                  onPageChanged: (i) {
                    _parar();
                    setState(() => _indice = i);
                  },
                  itemBuilder: (context, i) => _PantallaDeFase(
                    fase: widget.fases[i],
                    language: widget.language,
                    material: widget.material,
                    cancion: widget.cancion,
                    centroInteres: widget.centroInteres,
                    soando: _soando,
                    onAlternarAudio: _alternar,
                    audioService: widget.audioService,
                    dia: widget.dia,
                    semana: widget.semana,
                  ),
                ),
              ),
              _BarraInferior(
                indice: _indice,
                total: total,
                isGl: isGl,
                onAnterior: () => _ir(_indice - 1),
                onSeguinte: () async {
                  if (_indice < total - 1) {
                    _ir(_indice + 1);
                    return;
                  }
                  final ok = await _confirmarSaida();
                  if (!mounted) return;
                  if (ok) Navigator.of(this.context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Barra extends StatelessWidget {
  final String subtitulo;
  final int indice;
  final int total;
  final Future<void> Function() onSair;

  const _Barra({
    required this.subtitulo,
    required this.indice,
    required this.total,
    required this.onSair,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onSair,
            icon: const Icon(Icons.close_rounded,
                color: _AsambleaPlayerScreenState._textoSecundario, size: 26),
            tooltip: 'Saír',
          ),
          Expanded(
            child: Text(
              subtitulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _AsambleaPlayerScreenState._textoSecundario,
                letterSpacing: 0.5,
              ),
            ),
          ),
          // Los puntos: en qué fase vamos, sin ocupar media pantalla.
          Row(
            children: [
              for (int i = 0; i < total; i++)
                Container(
                  width: i == indice ? 22 : 8,
                  height: 8,
                  margin: const EdgeInsets.only(left: 5),
                  decoration: BoxDecoration(
                    color: i == indice
                        ? _AsambleaPlayerScreenState._acento
                        : _AsambleaPlayerScreenState._borde,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Una fase = una pantalla. Sin ningún desplazable dentro.
class _PantallaDeFase extends StatelessWidget {
  final FaseAsamblea fase;
  final AppLanguage language;
  final String? material;
  final String? cancion;
  final String? centroInteres;
  final String? soando;
  final Future<void> Function(String asset) onAlternarAudio;

  /// La voz. Sin ella la pantalla enseña las frases y no las dice, que es
  /// justo lo que pasó al unificar el reproductor: las grabaciones estaban en
  /// el paquete y ninguna tenía un botón que la tocara.
  final OfflineAudioService? audioService;
  final DiaDeProgresion? dia;
  final SemanaDeProgresion? semana;

  const _PantallaDeFase({
    required this.fase,
    required this.language,
    required this.soando,
    required this.onAlternarAudio,
    required this.audioService,
    this.dia,
    this.semana,
    this.material,
    this.cancion,
    this.centroInteres,
  });

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    final minutos = (fase.duracionSegundos / 60).round();
    final asset = fase.audioAsset;
    final temAudio = asset != null && asset.isNotEmpty;

    final eNucleo = fase.tipo == TipoFaseAsamblea.coreTprChallenge;
    final diaDeHoxe = dia;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // La lámina de la fase. Se perdió al unificar el reproductor y
              // es la imagen de apoyo que la docente enseña con la mano: sin
              // ella la pantalla era solo texto.
              if (fase.lamina.isNotEmpty) ...[
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _AsambleaPlayerScreenState._superficie,
                    borderRadius: BorderRadius.circular(AppTheme.radiusField),
                    border:
                        Border.all(color: _AsambleaPlayerScreenState._borde),
                  ),
                  alignment: Alignment.center,
                  child: LaminaEscena(clave: fase.lamina, ancho: 48),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fase.titulo.resolve(language),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _AsambleaPlayerScreenState._acento,
                      ),
                    ),
                    if (eNucleo && diaDeHoxe != null)
                      Text(
                        key: const ValueKey('dia_no_reproductor'),
                        '${isGl ? 'Semana' : 'Semana'} ${diaDeHoxe.semana}'
                        '${semana != null ? ' · ${semana!.nome.resolve(language)}' : ''}'
                        ' · ${diaDeHoxe.nomeDia.resolve(language)}: '
                        '${diaDeHoxe.foco.resolve(language)}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _AsambleaPlayerScreenState._textoSecundario,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$minutos min',
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _AsambleaPlayerScreenState._textoSecundario,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // La consigna, en grande. Es lo único que la docente lee de lejos.
          // Y con su voz al lado: la app la dice, no solo la enseña.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  fase.consignaDocente.resolve(language),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 26,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                    color: _AsambleaPlayerScreenState._textoPrincipal,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              BotonEscuchar(
                key: const ValueKey('voz_consigna'),
                audioService: audioService,
                texto: fase.consignaDocente.resolve(language),
                language: language,
                compacto: true,
                descripcion: isGl ? 'a consigna' : 'la consigna',
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (temAudio)
            _BotonDeSon(
              activo: soando == asset,
              etiqueta: fase.cueAcustica?.isNotEmpty == true
                  ? fase.cueAcustica!
                  : (isGl ? 'Son da fase' : 'Sonido de la fase'),
              onPulsar: () => onAlternarAudio(asset),
            )
          else if (fase.cueAcustica?.isNotEmpty == true)
            _Cue(texto: fase.cueAcustica!, audioService: audioService),
          const SizedBox(height: 14),
          // Los comandos en inglés, si esta fase los tiene. Máximo tres, que
          // es lo que dicen los documentos: tres órdenes por sesión.
          Expanded(
            child: fase.comandosL3.isEmpty
                ? _Apoios(
                    material: material,
                    cancion: cancion,
                    centroInteres: centroInteres,
                    isGl: isGl,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final cmd in fase.comandosL3.take(3))
                        Expanded(
                          child: _Comando(
                            textoIngles: cmd.textoIngles,
                            accion: cmd.accionFisica.resolve(language),
                            audioService: audioService,
                            isGl: isGl,
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _Comando extends StatelessWidget {
  final String textoIngles;
  final String accion;
  final OfflineAudioService? audioService;
  final bool isGl;

  const _Comando({
    required this.textoIngles,
    required this.accion,
    required this.audioService,
    required this.isGl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _AsambleaPlayerScreenState._superficie,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: _AsambleaPlayerScreenState._borde),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  textoIngles,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _AsambleaPlayerScreenState._textoPrincipal,
                  ),
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    accion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 13.5,
                      color: _AsambleaPlayerScreenState._textoSecundario,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // La orden en inglés, dicha por la voz inglesa. Es el corazón del
          // TPR: la docente la oye y la repite; sin esto la app está muda.
          BotonEscuchar(
            audioService: audioService,
            texto: textoIngles,
            language: AppLanguage.en,
            style: estiloIngles(textoIngles),
            compacto: true,
            descripcion: isGl ? 'a orde en inglés' : 'la orden en inglés',
          ),
        ],
      ),
    );
  }
}

class _BotonDeSon extends StatelessWidget {
  final bool activo;
  final String etiqueta;
  final VoidCallback onPulsar;

  const _BotonDeSon({
    required this.activo,
    required this.etiqueta,
    required this.onPulsar,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppTheme.backstageTouchMin,
      child: ElevatedButton.icon(
        onPressed: onPulsar,
        style: ElevatedButton.styleFrom(
          backgroundColor: activo
              ? _AsambleaPlayerScreenState._acento
              : _AsambleaPlayerScreenState._superficie,
          foregroundColor: activo
              ? _AsambleaPlayerScreenState._fondo
              : _AsambleaPlayerScreenState._textoPrincipal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusButton),
            side: const BorderSide(color: _AsambleaPlayerScreenState._borde),
          ),
        ),
        icon: Icon(activo ? Icons.stop_rounded : Icons.volume_up_rounded),
        label: Text(
          etiqueta,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _Cue extends StatelessWidget {
  final String texto;
  final OfflineAudioService? audioService;

  const _Cue({required this.texto, required this.audioService});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _AsambleaPlayerScreenState._superficie,
        borderRadius: BorderRadius.circular(AppTheme.radiusField),
        border: Border.all(color: _AsambleaPlayerScreenState._borde),
      ),
      child: Row(
        children: [
          const Icon(Icons.graphic_eq_rounded,
              size: 18, color: _AsambleaPlayerScreenState._acento),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _AsambleaPlayerScreenState._textoPrincipal,
              ),
            ),
          ),
          const SizedBox(width: 10),
          BotonEscuchar(
            audioService: audioService,
            texto: texto,
            language: AppLanguage.en,
            style: estiloIngles(texto),
            compacto: true,
          ),
        ],
      ),
    );
  }
}

class _Apoios extends StatelessWidget {
  final String? material;
  final String? cancion;
  final String? centroInteres;
  final bool isGl;

  const _Apoios({
    this.material,
    this.cancion,
    this.centroInteres,
    required this.isGl,
  });

  @override
  Widget build(BuildContext context) {
    final filas = <Widget>[];
    if (centroInteres != null && centroInteres!.isNotEmpty) {
      filas.add(_fila(Icons.explore_outlined, centroInteres!));
    }
    if (material != null && material!.isNotEmpty) {
      filas.add(_fila(Icons.pan_tool_outlined, material!));
    }
    if (cancion != null && cancion!.isNotEmpty) {
      filas.add(_fila(Icons.music_note_outlined, cancion!));
    }
    if (filas.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: filas,
    );
  }

  Widget _fila(IconData icona, String texto) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icona,
                size: 18, color: _AsambleaPlayerScreenState._textoSecundario),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                texto,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _AsambleaPlayerScreenState._textoSecundario,
                ),
              ),
            ),
          ],
        ),
      );
}

class _BarraInferior extends StatelessWidget {
  final int indice;
  final int total;
  final bool isGl;
  final VoidCallback onAnterior;
  final Future<void> Function() onSeguinte;

  const _BarraInferior({
    required this.indice,
    required this.total,
    required this.isGl,
    required this.onAnterior,
    required this.onSeguinte,
  });

  @override
  Widget build(BuildContext context) {
    final ultima = indice >= total - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: AppTheme.backstageTouchMin,
              child: OutlinedButton(
                key: const ValueKey('player_fase_anterior'),
                onPressed: indice > 0 ? onAnterior : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _AsambleaPlayerScreenState._textoPrincipal,
                  disabledForegroundColor: _AsambleaPlayerScreenState._borde,
                  side: const BorderSide(
                      color: _AsambleaPlayerScreenState._borde),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                  ),
                ),
                child: Text(
                  isGl ? 'Anterior' : 'Anterior',
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: AppTheme.backstageTouchMin,
              child: ElevatedButton(
                key: const ValueKey('player_fase_seguinte'),
                onPressed: onSeguinte,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _AsambleaPlayerScreenState._acento,
                  foregroundColor: _AsambleaPlayerScreenState._fondo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                  ),
                ),
                child: Text(
                  ultima
                      ? (isGl ? 'Rematar' : 'Finalizar')
                      : (isGl ? 'Seguinte fase' : 'Siguiente fase'),
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
