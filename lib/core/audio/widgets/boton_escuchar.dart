import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../localization/app_language.dart';
import '../../localization/localized_string.dart';
import '../../theme/app_theme.dart';
import '../offline_audio_service.dart';
import '../voice_id.dart';

/// El botón de escuchar de una tarjeta.
///
/// Existe porque el apoyo de voz estaba en dos sitios de toda la app —el pulso
/// y las palabras de vocabulario— y el resto de las tarjetas no tenían nada.
/// Para una maestra que no creció falando galego, oír la pronunciación modelo
/// antes de decirla en la asamblea es justo lo que hace útil una voz neuronal.
///
/// Se le pasa el TEXTO, no una ruta. La ruta la deriva [voiceAssetPath] del
/// propio texto, así que es imposible que la tarjeta enseñe una frase y suene
/// otra: si alguien edita la frase, cambia el identificador, la grabación vieja
/// deja de referenciarse y el gate de cobertura lo dice.
///
/// Si la grabación no está —una frase nueva sin sintetizar todavía— el botón
/// NO se pinta. No se pinta apagado ni con un aviso: una tarjeta con un altavoz
/// que no suena es peor que una tarjeta sin altavoz.
class BotonEscuchar extends StatefulWidget {
  final OfflineAudioService? audioService;

  /// El texto tal y como se ve en la tarjeta.
  final String texto;

  /// La lengua de la GRABACIÓN: `en` para el inglés.
  final AppLanguage language;

  /// La lengua de la PANTALLA, para «Escoitar» y lo que lee TalkBack. Hace
  /// falta cuando [language] es `en`: sin ella el rótulo salía «Escuchar»,
  /// en castellano, dentro de la app en gallego.
  final AppLanguage? interfaz;

  /// `slow` solo para palabras sueltas, que existen para ser imitadas.
  final VoiceStyle style;

  /// Con etiqueta («Escoitar») o solo el altavoz redondo.
  final bool compacto;

  /// Se pinta como una pastilla con el PROPIO texto dentro y un altavoz
  /// delante. Es lo que usan las palabras y las órdenes en inglés: la persona
  /// adulta ve lo que va a decir y lo oye en el mismo gesto. Manda sobre
  /// [compacto].
  final bool comoChip;

  /// Color de la pastilla cuando [comoChip]. Por defecto, el de la app.
  final Color? colorChip;

  /// Qué se está escuchando. Va al lector de pantalla, no a la vista.
  final String? descripcion;

  const BotonEscuchar({
    super.key,
    required this.audioService,
    required this.texto,
    required this.language,
    this.interfaz,
    this.style = VoiceStyle.tutor,
    this.compacto = false,
    this.comoChip = false,
    this.colorChip,
    this.descripcion,
  });

  static const _escuchar = LocalizedString(gl: 'Escoitar', es: 'Escuchar');
  static const _parar = LocalizedString(gl: 'Parar', es: 'Parar');

  @override
  State<BotonEscuchar> createState() => _BotonEscucharState();
}

class _BotonEscucharState extends State<BotonEscuchar> {
  /// Qué grabaciones existen de verdad en el paquete. Se pregunta una vez por
  /// ruta y se recuerda: la lista del lector tiene una tarjeta por sección y
  /// preguntar en cada repintado sería E/S por fotograma.
  static final Map<String, bool> _existe = {};

  StreamSubscription<bool>? _sub;
  bool _sonando = false;
  bool? _disponible;

  String get _ruta =>
      voiceAssetPath(widget.style, widget.texto, widget.language);

  @override
  void initState() {
    super.initState();
    _escuchar();
    _comprobar();
  }

  @override
  void didUpdateWidget(BotonEscuchar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.texto != widget.texto ||
        oldWidget.language != widget.language ||
        oldWidget.style != widget.style) {
      _comprobar();
    }
    if (oldWidget.audioService != widget.audioService) _escuchar();
  }

  void _escuchar() {
    _sub?.cancel();
    final servicio = widget.audioService;
    if (servicio == null) return;
    _sonando = servicio.isPlaying && servicio.currentAssetPath == _ruta;
    _sub = servicio.isPlayingStream.listen((playing) {
      if (!mounted) return;
      setState(() {
        _sonando = playing && servicio.currentAssetPath == _ruta;
      });
    });
  }

  Future<void> _comprobar() async {
    final ruta = _ruta;
    final recordado = _existe[ruta];
    if (recordado != null) {
      if (mounted) setState(() => _disponible = recordado);
      return;
    }
    var hay = false;
    try {
      await rootBundle.load(ruta);
      hay = true;
    } catch (_) {
      hay = false;
    }
    _existe[ruta] = hay;
    if (mounted) setState(() => _disponible = hay);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _pulsar() async {
    final servicio = widget.audioService;
    if (servicio == null) return;
    if (_sonando) {
      await servicio.stop();
    } else {
      // Parar lo anterior antes de empezar: si no, dos tarjetas seguidas dejan
      // dos voces hablando encima.
      if (servicio.isPlaying) await servicio.stop();
      await servicio.playAsset(_ruta);
    }
  }

  /// La pastilla sin altavoz: el texto en inglés se lee igual, pero no se
  /// puede pulsar. Es lo que se ve mientras una grabación todavía no existe.
  ///
  /// Una palabra del léxico es CONTENIDO; el altavoz es el añadido. Esconder la
  /// palabra entera por no tener todavía su grabación dejaba el apartado
  /// «Léxico e comandos TPR en inglés» con el rótulo puesto y nada debajo.
  Widget _chipMudo(BuildContext context) {
    final color = widget.colorChip ?? context.acento;
    return Container(
      constraints: const BoxConstraints(minHeight: AppTheme.touchMin),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        // Opaco: sobre una tarjeta ya teñida, un fondo translúcido se oscurecía
        // y el texto dejaba de pasar AA.
        color: Color.alphaBlend(color.withAlpha(12), Colors.white),
        borderRadius: BorderRadius.circular(AppTheme.radiusField),
        border: Border.all(color: color.withAlpha(50)),
      ),
      // Sin grabación, en gris de texto: se lee entero (7,56:1) y no parece
      // que se pueda pulsar.
      child: Text(
        widget.texto,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.audioService == null || _disponible != true) {
      // En modo pastilla se queda el texto, sin altavoz. En los demás modos el
      // botón desaparece entero: un altavoz suelto que no suena no aporta nada.
      return widget.comoChip ? _chipMudo(context) : const SizedBox.shrink();
    }

    final etiqueta = (_sonando ? BotonEscuchar._parar : BotonEscuchar._escuchar)
        .resolve(widget.interfaz ?? widget.language);
    final icono = _sonando ? Icons.stop_rounded : Icons.volume_up_rounded;

    if (widget.comoChip) {
      final color = widget.colorChip ?? context.acento;
      return Semantics(
        // Un nodo propio, con el tamaño del botón: sin él, la etiqueta se
        // fundía con la del antecesor y TalkBack recibía otro rectángulo.
        container: true,
        button: true,
        label: '$etiqueta: ${widget.descripcion ?? widget.texto}',
        child: Material(
          // Opaco por lo mismo que la pastilla muda: el acento encima da
          // 4,75:1 en docentes y 4,62:1 en familias, esté donde esté.
          color: _sonando
              ? color
              : Color.alphaBlend(color.withAlpha(20), Colors.white),
          borderRadius: BorderRadius.circular(AppTheme.radiusField),
          child: InkWell(
            onTap: _pulsar,
            borderRadius: BorderRadius.circular(AppTheme.radiusField),
            child: Container(
              constraints: const BoxConstraints(minHeight: AppTheme.touchMin),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusField),
                border: Border.all(color: color.withAlpha(90)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icono, size: 18, color: _sonando ? Colors.white : color),
                  const SizedBox(width: 6),
                  // El texto en inglés NO se recorta: si no cabe entero, se
                  // parte en dos líneas. Una orden a medias no se puede decir.
                  Flexible(
                    child: Text(
                      widget.texto,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _sonando ? Colors.white : color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (widget.compacto) {
      return Semantics(
        // Un nodo propio, con el tamaño del botón: sin él, la etiqueta se
        // fundía con la del antecesor y TalkBack recibía otro rectángulo.
        container: true,
        button: true,
        label: widget.descripcion == null
            ? etiqueta
            : '$etiqueta: ${widget.descripcion}',
        child: Material(
          color: _sonando ? context.acento : context.acentoTint,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: _pulsar,
            customBorder: const CircleBorder(),
            // 48 dp: el mínimo que se puede pulsar con seguridad, y la mano de
            // una maestra en una asamblea no apunta fino.
            child: SizedBox(
              width: AppTheme.touchMin,
              height: AppTheme.touchMin,
              child: Icon(
                icono,
                size: 22,
                color: _sonando ? Colors.white : context.acento,
              ),
            ),
          ),
        ),
      );
    }

    return Semantics(
      container: true,
      button: true,
      label: widget.descripcion == null
          ? etiqueta
          : '$etiqueta: ${widget.descripcion}',
      child: TextButton.icon(
        onPressed: _pulsar,
        icon: Icon(icono, size: 20),
        label: Text(etiqueta),
        style: TextButton.styleFrom(
          foregroundColor: context.acento,
          backgroundColor: context.acentoTint,
          minimumSize: const Size(0, AppTheme.touchMin),
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusField),
          ),
        ),
      ),
    );
  }
}
