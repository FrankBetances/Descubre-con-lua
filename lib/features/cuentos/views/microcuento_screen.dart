import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/brand/lamina_vector.dart';
import '../../../core/brand/lua_pixel.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cabecera.dart';
import '../../../core/widgets/espera_visible.dart';
import '../../../data/models/microcuento_model.dart';
import '../../../data/models/rexistro_frases_model.dart';

/// Quién lo lee: la docente con el grupo o la familia con su criatura.
enum ModoMicrocuento { aula, casa }

/// El microcuento de la unidad, lámina a lámina (M5.1).
///
/// En los dos modos: la lámina, la trama en la lengua de la pantalla, la frase
/// de Lúa en inglés con su voz, su gesto y su onomatopeya, y la espera, vista y
/// en silencio.
///
/// - **Aula**: la tríada (señalar, imitar, acercar a su vida) y, plegado, el
///   guion de recast para las cinco respuestas que pueden llegar del grupo.
/// - **Casa**: una sola pregunta por lámina, la que toca por edad, con su
///   ayuda. No la tríada: en casa hay una criatura y una pregunta basta.
///
/// La voz es solo la del inglés: la trama la lee la persona adulta.
class MicrocuentoScreen extends StatefulWidget {
  final Microcuento microcuento;
  final ModoMicrocuento modo;

  /// Donde están las frases de Lúa. Sin él, la lámina se enseña sin frase.
  final RexistroDeFrases? rexistro;
  final AppLanguage language;
  final ValueChanged<AppLanguage>? onLanguageChanged;
  final OfflineAudioService? audioService;

  const MicrocuentoScreen({
    super.key,
    required this.microcuento,
    required this.modo,
    required this.rexistro,
    required this.language,
    this.onLanguageChanged,
    this.audioService,
  });

  @override
  State<MicrocuentoScreen> createState() => _MicrocuentoScreenState();
}

class _MicrocuentoScreenState extends State<MicrocuentoScreen> {
  late AppLanguage _language = widget.language;
  int _indice = 0;
  bool _recastAberto = false;
  final _scroll = ScrollController();

  static const _laminaDe =
      LocalizedString(gl: 'Lámina {n} de {t}', es: 'Lámina {n} de {t}');
  static const _diLua = LocalizedString(gl: 'Lúa di', es: 'Lúa dice');
  static const _tresPreguntas =
      LocalizedString(gl: 'Despois, unha a unha', es: 'Después, una a una');
  static const _sinalar = LocalizedString(gl: 'Sinalar', es: 'Señalar');
  static const _imitar =
      LocalizedString(gl: 'Imitar co corpo', es: 'Imitar con el cuerpo');
  static const _achegar =
      LocalizedString(gl: 'Achegalo á súa vida', es: 'Acercarlo a su vida');
  static const _guion = LocalizedString(
      gl: 'Se responde así, ti dis…', es: 'Si responde así, tú dices…');
  static const _silencio =
      LocalizedString(gl: 'Non di nada', es: 'No dice nada');
  static const _sinala =
      LocalizedString(gl: 'Sinala sen falar', es: 'Señala sin hablar');
  static const _linguaCasa = LocalizedString(
      gl: 'Contesta na lingua de casa', es: 'Contesta en la lengua de casa');
  static const _unhaPalabra =
      LocalizedString(gl: 'Di unha palabra', es: 'Dice una palabra');
  static const _formaTorcida =
      LocalizedString(gl: 'Dio doutra maneira', es: 'Lo dice de otra manera');
  static const _semRepetir = LocalizedString(
      gl: 'Sen pedir que repita: devólvelle a frase ben dita.',
      es: 'Sin pedir que repita: devuélvele la frase bien dicha.');
  static const _preguntaCasa = LocalizedString(
      gl: 'A pregunta desta lámina', es: 'La pregunta de esta lámina');
  static const _anterior = LocalizedString(gl: 'Anterior', es: 'Anterior');
  static const _seguinte = LocalizedString(gl: 'Seguinte', es: 'Siguiente');
  static const _rematar = LocalizedString(gl: 'Rematar', es: 'Terminar');
  static const _pendente = LocalizedString(
      gl: 'Lámina pendente de debuxar', es: 'Lámina pendiente de dibujar');

  static const Map<TipoPreguntaCasa, LocalizedString> _tipos = {
    TipoPreguntaCasa.peer:
        LocalizedString(gl: 'Pregunta e agarda', es: 'Pregunta y espera'),
    TipoPreguntaCasa.completar:
        LocalizedString(gl: 'Que a complete', es: 'Que la complete'),
    TipoPreguntaCasa.recordar:
        LocalizedString(gl: 'Que se lembre', es: 'Que se acuerde'),
    TipoPreguntaCasa.abrir:
        LocalizedString(gl: 'Pregunta aberta', es: 'Pregunta abierta'),
    TipoPreguntaCasa.queOnde:
        LocalizedString(gl: 'Que ou onde', es: 'Qué o dónde'),
    TipoPreguntaCasa.achegar:
        LocalizedString(gl: 'Á súa vida', es: 'A su vida'),
  };

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _cambiarLingua(AppLanguage lang) {
    setState(() => _language = lang);
    widget.onLanguageChanged?.call(lang);
  }

  void _ir(int indice) {
    setState(() {
      _indice = indice;
      _recastAberto = false;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final lang = _language;
    final mc = widget.microcuento;
    final total = mc.laminas.length;
    final lamina = total == 0 ? null : mc.laminas[_indice];
    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: mc.titulo.resolve(lang),
        language: lang,
        onLanguageChanged: _cambiarLingua,
      ),
      body: SafeArea(
        child: lamina == null
            ? const SizedBox.shrink()
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      key: const ValueKey('microcuento'),
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _laminaDe
                                .resolve(lang)
                                .replaceAll('{n}', '${_indice + 1}')
                                .replaceAll('{t}', '$total'),
                            key: const ValueKey('microcuento_lamina_n'),
                            style: TextStyle(
                              color: context.acento,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _Lamina(
                            key: ValueKey('lamina_${_indice + 1}'),
                            clave: lamina.lamina,
                            pendente: _pendente.resolve(lang),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            lamina.trama.resolve(lang),
                            key: const ValueKey('microcuento_trama'),
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 17,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _FraseDeLua(
                            frase: widget.rexistro?.frase(lamina.lua),
                            onomatopeia: lamina.onomatopeia,
                            rotulo: _diLua.resolve(lang),
                            language: lang,
                            audioService: widget.audioService,
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: EsperaVisible(
                              segundos: mc.esperaSegundos,
                              language: lang,
                              color: context.acento,
                              fondo: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (widget.modo == ModoMicrocuento.aula)
                            ..._aula(lamina, lang)
                          else
                            ..._casa(lamina, lang),
                        ],
                      ),
                    ),
                  ),
                  _Navegacion(
                    anterior: _indice > 0 ? () => _ir(_indice - 1) : null,
                    seguinte: _indice < total - 1
                        ? () => _ir(_indice + 1)
                        : () => Navigator.of(context).maybePop(),
                    rotuloAnterior: _anterior.resolve(lang),
                    rotuloSeguinte: (_indice < total - 1 ? _seguinte : _rematar)
                        .resolve(lang),
                  ),
                ],
              ),
      ),
    );
  }

  List<Widget> _aula(LaminaMicrocuento lamina, AppLanguage lang) => [
        _Rotulo(_tresPreguntas.resolve(lang)),
        const SizedBox(height: 8),
        for (final (clave, rotulo, p) in [
          ('triada_sinalar', _sinalar, lamina.sinalar),
          ('triada_imitar', _imitar, lamina.imitar),
          ('triada_achegar', _achegar, lamina.achegar),
        ]) ...[
          _Pregunta(
            key: ValueKey(clave),
            rotulo: rotulo.resolve(lang),
            en: p.en,
            axuda: p.axuda.resolve(lang),
            language: lang,
            audioService: widget.audioService,
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 4),
        OutlinedButton.icon(
          key: const ValueKey('abrir_recast'),
          onPressed: () => setState(() => _recastAberto = !_recastAberto),
          icon: Icon(_recastAberto
              ? Icons.expand_less_rounded
              : Icons.expand_more_rounded),
          label: Text(
            _guion.resolve(lang),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, AppTheme.touchMin),
            foregroundColor: context.acento,
            side: BorderSide(color: context.acento),
            alignment: Alignment.centerLeft,
          ),
        ),
        if (_recastAberto) ...[
          const SizedBox(height: 8),
          _Recasts(
            key: const ValueKey('recast'),
            recast: lamina.recast,
            language: lang,
            audioService: widget.audioService,
            rotulos: (
              silencio: _silencio.resolve(lang),
              sinala: _sinala.resolve(lang),
              linguaCasa: _linguaCasa.resolve(lang),
              unhaPalabra: _unhaPalabra.resolve(lang),
              formaTorcida: _formaTorcida.resolve(lang),
            ),
            semRepetir: _semRepetir.resolve(lang),
          ),
        ],
      ];

  List<Widget> _casa(LaminaMicrocuento lamina, AppLanguage lang) => [
        _Rotulo(_preguntaCasa.resolve(lang)),
        const SizedBox(height: 8),
        _Pregunta(
          key: const ValueKey('pregunta_casa'),
          rotulo: (_tipos[lamina.casa.tipo] ?? _preguntaCasa).resolve(lang),
          en: lamina.casa.en,
          axuda: lamina.casa.axuda.resolve(lang),
          language: lang,
          audioService: widget.audioService,
        ),
        const SizedBox(height: 10),
        Text(
          _semRepetir.resolve(lang),
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ];
}

/// La lámina a lo ancho. Mientras no está dibujada se dice, en vez de dejar
/// un hueco.
class _Lamina extends StatelessWidget {
  final String? clave;
  final String pendente;

  const _Lamina({super.key, required this.clave, required this.pendente});

  @override
  Widget build(BuildContext context) {
    final aviso = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.image_outlined, color: AppTheme.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              pendente,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
    final c = clave;
    if (c == null) return aviso;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      child: LayoutBuilder(
        builder: (context, limites) => LaminaEscena(
          clave: c,
          ancho: limites.maxWidth,
          mentres: aviso,
        ),
      ),
    );
  }
}

class _FraseDeLua extends StatelessWidget {
  final FraseDoRexistro? frase;
  final String onomatopeia;
  final String rotulo;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  const _FraseDeLua({
    required this.frase,
    required this.onomatopeia,
    required this.rotulo,
    required this.language,
    required this.audioService,
  });

  @override
  Widget build(BuildContext context) {
    final f = frase;
    if (f == null) return const SizedBox.shrink();
    return Container(
      key: const ValueKey('frase_de_lua'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.acentoTint,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LuaPixel(size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rotulo.toUpperCase(),
                  style: TextStyle(
                    color: context.acento,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 6),
                BotonEscuchar(
                  audioService: audioService,
                  texto: f.en,
                  language: AppLanguage.en,
                  interfaz: language,
                  style: estiloIngles(f.en),
                  comoChip: true,
                ),
                if (onomatopeia.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    onomatopeia,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  f.accion.resolve(language),
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    height: 1.35,
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

class _Rotulo extends StatelessWidget {
  final String texto;
  const _Rotulo(this.texto);

  @override
  Widget build(BuildContext context) => Text(
        texto.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      );
}

/// Una pregunta en inglés con su voz y, debajo, qué hace la adulta.
class _Pregunta extends StatelessWidget {
  final String rotulo;
  final String en;
  final String axuda;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  const _Pregunta({
    super.key,
    required this.rotulo,
    required this.en,
    required this.axuda,
    required this.language,
    required this.audioService,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rotulo,
              style: TextStyle(
                color: context.acento,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            BotonEscuchar(
              audioService: audioService,
              texto: en,
              language: AppLanguage.en,
              interfaz: language,
              style: estiloIngles(en),
              comoChip: true,
            ),
            if (axuda.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                axuda,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
            ],
          ],
        ),
      );
}

typedef _RotulosRecast = ({
  String silencio,
  String sinala,
  String linguaCasa,
  String unhaPalabra,
  String formaTorcida,
});

class _Recasts extends StatelessWidget {
  final RecastsDaLamina recast;
  final AppLanguage language;
  final OfflineAudioService? audioService;
  final _RotulosRecast rotulos;
  final String semRepetir;

  const _Recasts({
    super.key,
    required this.recast,
    required this.language,
    required this.audioService,
    required this.rotulos,
    required this.semRepetir,
  });

  Widget _fila(BuildContext context, String cando,
          {String? di, String? acolle, required String en, String? axuda}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              di == null ? cando : '$cando: «$di»',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (acolle != null) ...[
              const SizedBox(height: 4),
              Text(
                acolle,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 4),
            BotonEscuchar(
              audioService: audioService,
              texto: en,
              language: AppLanguage.en,
              interfaz: language,
              style: estiloIngles(en),
              comoChip: true,
            ),
            if (axuda != null && axuda.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                axuda,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              semRepetir,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
            _fila(context, rotulos.silencio,
                en: recast.silencio.en,
                axuda: recast.silencio.axuda.resolve(language)),
            _fila(context, rotulos.sinala,
                en: recast.sinala.en,
                axuda: recast.sinala.axuda.resolve(language)),
            _fila(context, rotulos.linguaCasa,
                di: recast.linguaCasa.di.resolve(language),
                acolle: recast.linguaCasa.acolle.resolve(language),
                en: recast.linguaCasa.en),
            _fila(context, rotulos.unhaPalabra,
                di: recast.unhaPalabra.di, en: recast.unhaPalabra.en),
            _fila(context, rotulos.formaTorcida,
                di: recast.formaTorcida.di, en: recast.formaTorcida.en),
          ],
        ),
      );
}

class _Navegacion extends StatelessWidget {
  final VoidCallback? anterior;
  final VoidCallback seguinte;
  final String rotuloAnterior;
  final String rotuloSeguinte;

  const _Navegacion({
    required this.anterior,
    required this.seguinte,
    required this.rotuloAnterior,
    required this.rotuloSeguinte,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                key: const ValueKey('microcuento_anterior'),
                onPressed: anterior,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, AppTheme.touchMin),
                ),
                child: Text(rotuloAnterior),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                key: const ValueKey('microcuento_seguinte'),
                onPressed: seguinte,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, AppTheme.touchMin),
                  backgroundColor: context.acento,
                ),
                child: Text(rotuloSeguinte),
              ),
            ),
          ],
        ),
      );
}
