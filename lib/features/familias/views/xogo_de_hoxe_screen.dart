import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/brand/lua_pixel.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/storage/calendario_store.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cabecera.dart';
import '../../../data/models/calendario_model.dart';
import '../../../data/models/dia_calendario_dual_model.dart';
import '../../../data/models/tpr_curriculum_scheduler.dart';
import '../../calendario/widgets/palabras_do_dia.dart';

/// El juego de casa de un día, en palabras de casa.
///
/// El momento como título («Antes de durmir»), el texto entero, el inglés que
/// se oye desde aquí, el porqué plegado y un solo botón: «Xa o fixemos», que
/// suma a la racha de la persona adulta. Antes este juego se titulaba con el
/// nombre interno de la asamblea, y había que marcarlo «Feito Hoxe» dentro
/// del calendario.
class XogoDeHoxeScreen extends StatefulWidget {
  const XogoDeHoxeScreen({
    super.key,
    required this.dia,
    required this.eHoxe,
    required this.nomeDoDia,
    required this.language,
    required this.store,
    this.onLanguageChanged,
    this.audioService,
    this.plan,
    this.agora,
  });

  final DiaCalendarioDual dia;

  /// Es el juego de HOY. El fin de semana se enseña el del lunes, y ese no
  /// se marca como hecho: no se ha hecho todavía.
  final bool eHoxe;
  final LocalizedString nomeDoDia;
  final AppLanguage language;
  final CalendarioStore store;
  final ValueChanged<AppLanguage>? onLanguageChanged;
  final OfflineAudioService? audioService;

  /// Las palabras inglesas de ese día, si el curso está cargado.
  final DailyTprPlan? plan;
  final DateTime? agora;

  @override
  State<XogoDeHoxeScreen> createState() => _XogoDeHoxeScreenState();
}

class _XogoDeHoxeScreenState extends State<XogoDeHoxeScreen> {
  late AppLanguage _language = widget.language;
  bool _porque = false;

  @override
  void didUpdateWidget(covariant XogoDeHoxeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.language != widget.language) _language = widget.language;
  }

  void _cambiarLingua(AppLanguage l) {
    setState(() => _language = l);
    widget.onLanguageChanged?.call(l);
  }

  bool get _feito {
    final e = widget.store.estadoParaFecha(widget.agora ?? DateTime.now());
    return e == EstadoEstimulacion.soloHogar ||
        e == EstadoEstimulacion.dobleEstimulacion;
  }

  /// La respuesta es inmediata: el día queda apuntado en memoria al momento
  /// y el disco se escribe por detrás. Esperar a la escritura dejaba el botón
  /// sin respuesta un instante, justo cuando se acaba de hacer el juego.
  void _xaOFixemos() {
    unawaited(widget.store.registrarHogar(widget.agora ?? DateTime.now()));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final lang = _language;
    final isGl = lang == AppLanguage.gl;
    final fam = widget.dia.familias;
    final tpr = widget.dia.profesorado.tprIngles?.trim() ?? '';
    final dia = widget.nomeDoDia.resolve(lang);
    final feito = widget.eHoxe && _feito;

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: widget.eHoxe
            ? (isGl ? 'O xogo de hoxe' : 'El juego de hoy')
            : (isGl
                ? 'O xogo do ${dia.toLowerCase()}'
                : 'El juego del ${dia.toLowerCase()}'),
        language: lang,
        onLanguageChanged: _cambiarLingua,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                key: const Key('xogo_de_hoxe'),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                children: [
                  Text(
                    '${dia.toUpperCase()} · 3 MIN',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: context.acento,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    isGl ? 'O momento' : 'El momento',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Semantics(
                    header: true,
                    child: Text(
                      fam.momento.resolve(lang),
                      key: const Key('xogo_momento'),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        height: 1.15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    fam.rutinaFogar.resolve(lang),
                    key: const Key('xogo_texto'),
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppTheme.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  if (tpr.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    _Ingles(
                      frase: tpr,
                      plan: widget.plan,
                      language: lang,
                      audioService: widget.audioService,
                    ),
                  ],
                  const SizedBox(height: 18),
                  _Pregado(
                    titulo: isGl ? 'Por que funciona' : 'Por qué funciona',
                    aberto: _porque,
                    onTap: () => setState(() => _porque = !_porque),
                    textos: [
                      fam.consignaFamilia.resolve(lang),
                      fam.fraseConexion.resolve(lang),
                    ],
                  ),
                ],
              ),
            ),
            _BarraFeito(
              eHoxe: widget.eHoxe,
              feito: feito,
              racha: widget.store.rachaActual,
              language: lang,
              nomeDoDia: dia,
              onFeito: _xaOFixemos,
            ),
          ],
        ),
      ),
    );
  }
}

/// La frase en inglés del juego, con su voz, y las palabras del día.
class _Ingles extends StatelessWidget {
  const _Ingles({
    required this.frase,
    required this.plan,
    required this.language,
    required this.audioService,
  });

  final String frase;
  final DailyTprPlan? plan;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isGl ? 'EN INGLÉS, CO CORPO' : 'EN INGLÉS, CON EL CUERPO',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '«$frase»',
                  key: const Key('xogo_ingles'),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              BotonEscuchar(
                audioService: audioService,
                texto: frase,
                language: AppLanguage.en,
                interfaz: language,
                style: estiloIngles(frase),
                compacto: true,
                descripcion: frase,
              ),
            ],
          ),
          if (plan case final p? when p.newWords.isNotEmpty) ...[
            const SizedBox(height: 12),
            PalabrasDoDia(
              plan: p,
              language: language,
              audioService: audioService,
              paraFogar: true,
              detalle: false,
            ),
          ],
        ],
      ),
    );
  }
}

/// El porqué, plegado: la teoría no va delante de lo que hay que hacer.
class _Pregado extends StatelessWidget {
  const _Pregado({
    required this.titulo,
    required this.aberto,
    required this.onTap,
    required this.textos,
  });

  final String titulo;
  final bool aberto;
  final VoidCallback onTap;
  final List<String> textos;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        side: const BorderSide(color: AppTheme.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            key: const Key('xogo_por_que'),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 52),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline_rounded,
                        color: context.acento, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      aberto
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (aberto)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final t in textos.where((t) => t.trim().isNotEmpty))
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        t,
                        style: const TextStyle(
                          fontSize: 15.5,
                          color: AppTheme.textPrimary,
                          height: 1.45,
                        ),
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

/// Abajo, el único botón: «Xa o fixemos». Hecho, Lúa lo celebra con la
/// racha de la persona adulta; nunca con nada de la criatura.
class _BarraFeito extends StatelessWidget {
  const _BarraFeito({
    required this.eHoxe,
    required this.feito,
    required this.racha,
    required this.language,
    required this.nomeDoDia,
    required this.onFeito,
  });

  final bool eHoxe;
  final bool feito;
  final int racha;
  final AppLanguage language;
  final String nomeDoDia;
  final VoidCallback onFeito;

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: !eHoxe
          ? Text(
              isGl
                  ? 'Este xogo é para o ${nomeDoDia.toLowerCase()}. Ese día podedes marcalo como feito.'
                  : 'Este juego es para el ${nomeDoDia.toLowerCase()}. Ese día podréis marcarlo como hecho.',
              key: const Key('xogo_non_e_hoxe'),
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondary,
                height: 1.35,
              ),
            )
          : feito
              ? Row(
                  key: const Key('xogo_feito'),
                  children: [
                    const ExcludeSemantics(
                      child: LuaPixel(pose: LuaPose.head, size: 40),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        racha > 1
                            ? (isGl
                                ? 'Feito. Levades $racha días seguidos.'
                                : 'Hecho. Lleváis $racha días seguidos.')
                            : (isGl
                                ? 'Feito hoxe. Moi ben!'
                                : 'Hecho hoy. ¡Muy bien!'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.successInk,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                )
              : SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    key: const Key('xogo_xa_o_fixemos'),
                    onPressed: onFeito,
                    icon: const Icon(Icons.check_rounded, size: 24),
                    label: Text(
                      isGl ? 'Xa o fixemos' : 'Ya lo hicimos',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
    );
  }
}
