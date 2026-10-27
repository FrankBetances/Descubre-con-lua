import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/espera_visible.dart';
import '../../../data/models/hogar_model.dart';
import '../../../data/models/steam_do_mes_model.dart';
import '../../../data/models/xogos_fogar_model.dart';

/// El reto de casa de esta semana (F5): el momento del mes, la frase con su
/// voz para la adulta, qué hacer, la espera, qué no pedir y qué decir según
/// responda. Debajo, el juego del mes, qué mirar y la frase del mes pasado.
///
/// Todo sale del bloque `hogar` de la unidad del mes
/// (`tools/gen_hogar.py`); aquí solo hay rótulos.
class RetoDaSemana extends StatefulWidget {
  final HogarDaUnidade hogar;
  final int semana;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  /// El botón del microcuento en modo casa, si la unidad lo tiene.
  final Widget? lectura;

  /// El antetítulo, si no es el del reto del mes («… SEMANA 2 DE 4»): la
  /// lección semanal (P11) pone el suyo.
  final String? rotulo;

  const RetoDaSemana({
    super.key,
    required this.hogar,
    required this.semana,
    required this.language,
    this.audioService,
    this.lectura,
    this.rotulo,
  });

  @override
  State<RetoDaSemana> createState() => _RetoDaSemanaState();
}

class _RetoDaSemanaState extends State<RetoDaSemana> {
  // Sin catchError: en un SynchronousFuture no completa nunca.
  late final Future<XogosFogar?> _xogos =
      XogosFogar.cargar().then<XogosFogar?>((x) => x, onError: (_) => null);
  late final Future<SteamDoMes?> _steam =
      SteamDoMes.cargar().then<SteamDoMes?>((s) => s, onError: (_) => null);

  static const _kicker =
      LocalizedString(gl: 'O RETO DA SEMANA', es: 'EL RETO DE LA SEMANA');
  static const _semana = LocalizedString(gl: 'Semana', es: 'Semana');
  static const _momento = LocalizedString(gl: 'Cando', es: 'Cuándo');
  static const _con = LocalizedString(gl: 'Con', es: 'Con');
  static const _facer = LocalizedString(gl: 'Que fas', es: 'Qué haces');
  static const _mans = LocalizedString(gl: 'Coas mans', es: 'Con las manos');
  static const _nonPedir =
      LocalizedString(gl: 'Que non lle pides', es: 'Qué no le pides');
  static const _seResponde =
      LocalizedString(gl: 'Segundo como responda', es: 'Según cómo responda');
  static const _silencio =
      LocalizedString(gl: 'Se non di nada', es: 'Si no dice nada');
  static const _linguaCasa = LocalizedString(
      gl: 'Se contesta na lingua da casa',
      es: 'Si contesta en la lengua de casa');
  static const _unhaPalabra =
      LocalizedString(gl: 'Se di unha palabra', es: 'Si dice una palabra');
  static const _xogo =
      LocalizedString(gl: 'O XOGO DO MES', es: 'EL JUEGO DEL MES');
  static const _xogoDaUnidade =
      LocalizedString(gl: 'O XOGO DA UNIDADE', es: 'EL JUEGO DE LA UNIDAD');
  static const _observar = LocalizedString(
      gl: 'QUE MIRAR · NON SE MARCA NIN SE GARDA',
      es: 'QUÉ MIRAR · NO SE MARCA NI SE GUARDA');
  static const _reactivar =
      LocalizedString(gl: 'O MES PASADO', es: 'EL MES PASADO');

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;
    final h = widget.hogar;
    final reto = h.daSemana(widget.semana);
    if (reto == null) return const SizedBox.shrink();
    final kicker = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.6,
      color: context.acento,
    );
    const corpo = TextStyle(
      fontSize: 15,
      color: AppTheme.textPrimary,
      height: 1.4,
    );
    Widget linea(LocalizedString rotulo, LocalizedString texto) => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text.rich(
            TextSpan(children: [
              TextSpan(
                text: '${rotulo.resolve(lang)}: ',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              TextSpan(text: texto.resolve(lang)),
            ]),
            style: corpo,
          ),
        );

    return Material(
      key: const Key('reto_da_semana'),
      color: AppTheme.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        side: BorderSide(color: context.acento, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.rotulo ??
                  '${_kicker.resolve(lang)} · ${_semana.resolve(lang).toUpperCase()} '
                      '${reto.semana} DE 4 · ${reto.nomeFase.resolve(lang).toUpperCase()}',
              style: kicker,
            ),
            const SizedBox(height: 10),
            BotonEscuchar(
              key: const Key('reto_frase'),
              audioService: widget.audioService,
              texto: reto.frase.en,
              language: AppLanguage.en,
              interfaz: lang,
              style: estiloIngles(reto.frase.en),
              comoChip: true,
              colorChip: context.acento,
              descripcion: reto.frase.en,
              significado: reto.frase.significado,
            ),
            if (reto.frase.significado case final s?)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  s.resolve(lang),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            linea(
                _momento,
                LocalizedString(
                  gl: '${h.momento.gl} · ${h.minutos} min',
                  es: '${h.momento.es} · ${h.minutos} min',
                )),
            linea(_con, h.escena),
            linea(_facer, reto.queFacer),
            linea(_mans, reto.mans),
            const SizedBox(height: 10),
            EsperaVisible(
              segundos: reto.esperaSegundos,
              language: lang,
              color: context.acento,
              fondo: context.acentoTint,
            ),
            linea(_nonPedir, reto.nonPedir),
            Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                key: const Key('reto_recast'),
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 6),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                iconColor: context.acento,
                title: Text(_seResponde.resolve(lang), style: kicker),
                children: [
                  linea(_silencio, reto.recastSilencio),
                  linea(_linguaCasa, reto.recastLinguaCasa),
                  linea(_unhaPalabra, reto.recastUnhaPalabra),
                ],
              ),
            ),
            if (widget.lectura case final l?) ...[
              const SizedBox(height: 4),
              l,
            ],
            _Xogo(
              hogar: h,
              xogos: _xogos,
              steam: _steam,
              language: lang,
              rotulo: (widget.rotulo == null ? _xogo : _xogoDaUnidade)
                  .resolve(lang),
              kicker: kicker,
            ),
            if (h.queObservar.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(_observar.resolve(lang), style: kicker),
              for (final o in h.queObservar)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('·  ${o.resolve(lang)}', style: corpo),
                ),
            ],
            if ((h.reactivar, h.reactivarTexto) case (final r?, final t?)) ...[
              const SizedBox(height: 14),
              Text(_reactivar.resolve(lang), style: kicker),
              const SizedBox(height: 6),
              BotonEscuchar(
                audioService: widget.audioService,
                texto: r.en,
                language: AppLanguage.en,
                interfaz: lang,
                style: estiloIngles(r.en),
                comoChip: true,
                colorChip: context.acento,
                descripcion: r.en,
              ),
              const SizedBox(height: 4),
              Text(t.resolve(lang), style: corpo),
            ],
          ],
        ),
      ),
    );
  }
}

class _Xogo extends StatelessWidget {
  final HogarDaUnidade hogar;
  final Future<XogosFogar?> xogos;
  final Future<SteamDoMes?> steam;
  final AppLanguage language;
  final String rotulo;
  final TextStyle kicker;

  const _Xogo({
    required this.hogar,
    required this.xogos,
    required this.steam,
    required this.language,
    required this.rotulo,
    required this.kicker,
  });

  @override
  Widget build(BuildContext context) {
    Widget pinta(String titulo, String texto) => Padding(
          key: const Key('reto_xogo'),
          padding: const EdgeInsets.only(top: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(rotulo, style: kicker),
              const SizedBox(height: 4),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                texto,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        );
    if (hogar.xogo case final id?) {
      return FutureBuilder<XogosFogar?>(
        future: xogos,
        builder: (context, snap) {
          final x = snap.data?.xogos.where((x) => x.id == id).firstOrNull;
          if (x == null) return const SizedBox.shrink();
          return pinta('${x.titulo.resolve(language)} · ${x.duracionMin} min',
              x.guionAdulto.resolve(language));
        },
      );
    }
    if (hogar.steam case final id?) {
      return FutureBuilder<SteamDoMes?>(
        future: steam,
        builder: (context, snap) {
          final e =
              snap.data?.experimentos.where((e) => e.id == id).firstOrNull;
          if (e == null) return const SizedBox.shrink();
          return pinta(e.titulo.resolve(language),
              [for (final p in e.casa) p.resolve(language)].join(' '));
        },
      );
    }
    return const SizedBox.shrink();
  }
}
