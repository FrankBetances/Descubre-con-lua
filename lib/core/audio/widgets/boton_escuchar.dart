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

  final AppLanguage language;

  /// `slow` solo para palabras sueltas, que existen para ser imitadas.
  final VoiceStyle style;

  /// Con etiqueta («Escoitar») o solo el altavoz redondo.
  final bool compacto;

  /// Qué se está escuchando. Va al lector de pantalla, no a la vista.
  final String? descripcion;

  const BotonEscuchar({
    super.key,
    required this.audioService,
    required this.texto,
    required this.language,
    this.style = VoiceStyle.tutor,
    this.compacto = false,
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

  @override
  Widget build(BuildContext context) {
    if (widget.audioService == null || _disponible != true) {
      return const SizedBox.shrink();
    }

    final etiqueta = (_sonando ? BotonEscuchar._parar : BotonEscuchar._escuchar)
        .resolve(widget.language);
    final icono = _sonando ? Icons.stop_rounded : Icons.volume_up_rounded;

    if (widget.compacto) {
      return Semantics(
        button: true,
        label: widget.descripcion == null
            ? etiqueta
            : '$etiqueta: ${widget.descripcion}',
        child: Material(
          color: _sonando ? AppTheme.primaryInk : AppTheme.primaryLight,
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
                color: _sonando ? Colors.white : AppTheme.primaryInk,
              ),
            ),
          ),
        ),
      );
    }

    return Semantics(
      button: true,
      label: widget.descripcion == null
          ? etiqueta
          : '$etiqueta: ${widget.descripcion}',
      child: TextButton.icon(
        onPressed: _pulsar,
        icon: Icon(icono, size: 20),
        label: Text(etiqueta),
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.primaryInk,
          backgroundColor: AppTheme.primaryLight,
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
