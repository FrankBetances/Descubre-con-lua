import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/brand/iconos_contenido.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/paxina_sen_scroll.dart';
import '../../../core/widgets/aviso_contenido_ilegible.dart';
import '../../../data/models/calendario_model.dart';
import '../../../data/repositories/calendario_repository.dart';
import '../widgets/selector_idioma_widget.dart';

/// La guía de la familia: cómo meter el inglés en la casa sin saturar.
///
/// Todo lo que se lee aquí sale de `assets/content/calendario/atencion.json`.
/// Los minutos son un TIEMPO DE JUEGO SUGERIDO, dicho en lenguaje de crianza:
/// no son un umbral del desarrollo ni el resultado de medir a nadie, y esta app
/// no evalúa a ninguna criatura. Por eso tampoco se titulan las reglas como
/// hallazgos de neurociencia: son criterio pedagógico, y se presentan como tal.
class GuiaAtencionScreen extends StatefulWidget {
  final AppLanguage initialLanguage;
  final ValueChanged<AppLanguage>? onLanguageChanged;
  final OfflineAudioService? audioService;

  /// El contenido ya cargado. Si no se pasa, se lee del paquete.
  final CalendarioContenido? contenido;

  const GuiaAtencionScreen({
    super.key,
    this.initialLanguage = AppLanguage.gl,
    this.onLanguageChanged,
    this.audioService,
    this.contenido,
  });

  @override
  State<GuiaAtencionScreen> createState() => _GuiaAtencionScreenState();
}

class _GuiaAtencionScreenState extends State<GuiaAtencionScreen> {
  late AppLanguage _language;
  int _tramoSeleccionado = 0;
  GuiaAtencion? _guia;

  /// Lo que impidió leer la guía, si pasó.
  String? _fallo;

  static const _titulo = LocalizedString(
    gl: 'Guía de inglés na casa',
    es: 'Guía de inglés en casa',
  );

  static const _subtitulo = LocalizedString(
    gl: 'Aprender unha lingua nova sen saturar: rutinas curtas, respecto aos '
        'tempos e cero pantallas para a crianza.',
    es: 'Aprender una lengua nueva sin saturar: rutinas cortas, respeto a los '
        'tiempos y cero pantallas para la criatura.',
  );

  static const _reglasKicker = LocalizedString(
    gl: 'TRES REGRAS PARA A CASA',
    es: 'TRES REGLAS PARA CASA',
  );

  static const _edadKicker = LocalizedString(
    gl: 'CANTO DURA O XOGO, SEGUNDO A IDADE',
    es: 'CUÁNTO DURA EL JUEGO, SEGÚN LA EDAD',
  );

  static const _tiempoSugerido = LocalizedString(
    gl: 'Xogo suxerido: arredor de',
    es: 'Juego sugerido: alrededor de',
  );

  static const _minutos = LocalizedString(gl: 'min', es: 'min');

  static const _momento = LocalizedString(
    gl: 'Momento da casa:',
    es: 'Momento en casa:',
  );

  static const _queFacer = LocalizedString(
    gl: 'Que facer (co corpo):',
    es: 'Qué hacer (con el cuerpo):',
  );

  static const _queEvitar = LocalizedString(
    gl: 'Que evitar:',
    es: 'Qué evitar:',
  );

  static const _comoSeDi = LocalizedString(
    gl: 'Como se di. Pulsa e escóitao antes de dicirllo:',
    es: 'Cómo se dice. Pulsa y escúchalo antes de decírselo:',
  );

  static const _aviso = LocalizedString(
    gl: 'Os minutos son unha suxestión de xogo, non unha medida do '
        'desenvolvemento de ninguén. Esta app non avalía a ningunha crianza.',
    es: 'Los minutos son una sugerencia de juego, no una medida del desarrollo '
        'de nadie. Esta app no evalúa a ninguna criatura.',
  );

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
    final yaCargado = widget.contenido;
    if (yaCargado != null) {
      _guia = yaCargado.guia;
    } else {
      CalendarioContenido.cargar().then((c) {
        if (!mounted) return;
        setState(() => _guia = c.guia);
        // Mismo fallo que el Calendario: sin catchError, el disco giraba para
        // siempre en vez de decir que el fichero no estaba en el paquete.
      }).catchError((Object e) {
        if (!mounted) return;
        setState(() => _fallo = '${CalendarioContenido.atencionAsset} · $e');
      });
    }
  }

  void _onToggleLanguage(AppLanguage newLang) {
    setState(() => _language = newLang);
    widget.onLanguageChanged?.call(newLang);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final guia = _guia;
    final fallo = _fallo;

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        title: Text(
          _titulo.resolve(_language),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: SelectorIdiomaWidget(
              currentLanguage: _language,
              onLanguageChanged: _onToggleLanguage,
              // GL/ES, como el resto de la app: con el nombre entero
              // («Galego», «Castellano») la barra desbordaba 119 px a escala
              // de texto grande.
              compact: true,
            ),
          ),
        ],
      ),
      // targetSdk 36 obliga al borde a borde en Android 15+: la ventana
      // ya no reserva la barra de gestos y el final de esta pantalla
      // quedaba por debajo. `top: false` porque el inset de arriba ya lo
      // consume el AppBar; volver a pedirlo aquí no suma nada.
      body: SafeArea(
        top: false,
        child: fallo != null
            ? AvisoContenidoIlegible(asset: fallo, language: _language)
            : guia == null
                ? const Center(child: CircularProgressIndicator())
                : PaxinaSenScroll(
                    desprazarSeNonCabe: true,
                    padding: const EdgeInsets.all(AppTheme.spaceLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _subtitulo.resolve(_language),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceLg),
                        _Kicker(_edadKicker.resolve(_language)),
                        const SizedBox(height: AppTheme.spaceSm),
                        _SelectorTramos(
                          tramos: guia.tramos,
                          lang: _language,
                          seleccionado: _tramoSeleccionado,
                          onSeleccionar: (i) =>
                              setState(() => _tramoSeleccionado = i),
                        ),
                        const SizedBox(height: AppTheme.spaceLg),
                        _TarjetaTramo(
                          tramo: guia.tramos[_tramoSeleccionado.clamp(
                              0, guia.tramos.length - 1)],
                          lang: _language,
                          audioService: widget.audioService,
                          tiempoSugerido: _tiempoSugerido.resolve(_language),
                          minutos: _minutos.resolve(_language),
                          momento: _momento.resolve(_language),
                          queFacer: _queFacer.resolve(_language),
                          queEvitar: _queEvitar.resolve(_language),
                          comoSeDi: _comoSeDi.resolve(_language),
                        ),
                        const SizedBox(height: AppTheme.spaceSm),
                        Text(
                          _aviso.resolve(_language),
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: AppTheme.spaceXl),
                        _Kicker(_reglasKicker.resolve(_language)),
                        const SizedBox(height: AppTheme.spaceSm),
                        ...guia.reglas.map(
                          (r) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppTheme.spaceSm),
                            child: _TarjetaRegla(regla: r, lang: _language),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceXl),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _Kicker extends StatelessWidget {
  final String texto;

  const _Kicker(this.texto);

  @override
  Widget build(BuildContext context) => Text(
        texto,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
      );
}

class _SelectorTramos extends StatelessWidget {
  final List<TramoAtencion> tramos;
  final AppLanguage lang;
  final int seleccionado;
  final ValueChanged<int> onSeleccionar;

  const _SelectorTramos({
    required this.tramos,
    required this.lang,
    required this.seleccionado,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    // Wrap y no una fila con altura fija: a escala de texto grande las etiquetas
    // caen a la línea siguiente en vez de cortarse.
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < tramos.length; i++)
          ChoiceChip(
            label: Text(tramos[i].rangoEdad.resolve(lang)),
            selected: i == seleccionado,
            onSelected: (val) {
              if (val) onSeleccionar(i);
            },
            selectedColor: AppTheme.primary,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: i == seleccionado ? Colors.white : AppTheme.textPrimary,
              fontWeight:
                  i == seleccionado ? FontWeight.bold : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: i == seleccionado ? AppTheme.primary : AppTheme.border,
              ),
            ),
          ),
      ],
    );
  }
}

class _TarjetaTramo extends StatelessWidget {
  final TramoAtencion tramo;
  final AppLanguage lang;
  final OfflineAudioService? audioService;
  final String tiempoSugerido;
  final String minutos;
  final String momento;
  final String queFacer;
  final String queEvitar;
  final String comoSeDi;

  const _TarjetaTramo({
    required this.tramo,
    required this.lang,
    required this.audioService,
    required this.tiempoSugerido,
    required this.minutos,
    required this.momento,
    required this.queFacer,
    required this.queEvitar,
    required this.comoSeDi,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        side: const BorderSide(color: AppTheme.border),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryLight,
                  radius: 22,
                  child: Icon(iconoDeContenido(tramo.icono),
                      color: AppTheme.primaryDark, size: 24),
                ),
                const SizedBox(width: AppTheme.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tramo.rangoEdad.resolve(lang),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      // «Alrededor de 3 min», no «3 min máximo»: un tope suena
                      // a norma, y esto es una sugerencia de juego.
                      Text(
                        '$tiempoSugerido ${tramo.minutosSugeridos} $minutos',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            _Fila(
              label: momento,
              contenido: tramo.momentoDomestico.resolve(lang),
              icono: Icons.alarm_on_rounded,
            ),
            const SizedBox(height: 12),
            _Fila(
              label: queFacer,
              contenido: tramo.queFacer.resolve(lang),
              icono: Icons.check_circle_outline_rounded,
              colorIcono: AppTheme.success,
            ),
            const SizedBox(height: 12),
            _Fila(
              label: queEvitar,
              contenido: tramo.queEvitar.resolve(lang),
              icono: Icons.highlight_off_rounded,
              colorIcono: AppTheme.error,
            ),
            if (tramo.fraseIngles.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                comoSeDi,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              BotonEscuchar(
                audioService: audioService,
                texto: tramo.fraseIngles,
                language: AppLanguage.en,
                comoChip: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  final String label;
  final String contenido;
  final IconData icono;
  final Color colorIcono;

  const _Fila({
    required this.label,
    required this.contenido,
    required this.icono,
    this.colorIcono = AppTheme.primaryDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 18, color: colorIcono),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                height: 1.3,
              ),
              children: [
                TextSpan(
                  text: '$label ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: contenido),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TarjetaRegla extends StatelessWidget {
  final ReglaCasa regla;
  final AppLanguage lang;

  const _TarjetaRegla({required this.regla, required this.lang});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        side: const BorderSide(color: AppTheme.border),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.pageBg,
              radius: 18,
              child: Icon(iconoDeContenido(regla.icono),
                  size: 20, color: AppTheme.primaryDark),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    regla.titulo.resolve(lang),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    regla.texto.resolve(lang),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      height: 1.35,
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
