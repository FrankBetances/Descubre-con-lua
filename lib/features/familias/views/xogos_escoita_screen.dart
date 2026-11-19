import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/brand/imaxe_escena.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/navigation/ruta_lua.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cabecera.dart';
import '../../../core/widgets/movimiento.dart';
import '../../../data/models/escoita_model.dart';

/// Na casa → Explorar → Xogos de escoita (O-20261119-8).
///
/// Los pares, las progresiones, los contrarios, las rutinas y las categorías
/// de Valeria, en la lengua de la app. Adaptado: el niño no habla a la
/// pantalla; la app dice una palabra, el niño señala el dibujo y la persona
/// adulta toca el que señaló. Juego educativo, sin finalidad sanitaria.
class XogosEscoitaScreen extends StatelessWidget {
  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final OfflineAudioService? audioService;

  const XogosEscoitaScreen({
    super.key,
    required this.language,
    required this.onLanguageChanged,
    this.audioService,
  });

  static const titulo =
      LocalizedString(gl: 'Xogos de escoita', es: 'Juegos de escucha');

  @override
  Widget build(BuildContext context) {
    final lang = language == AppLanguage.es ? AppLanguage.es : AppLanguage.gl;
    final isGl = lang == AppLanguage.gl;
    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: titulo.resolve(lang),
        language: language,
        onLanguageChanged: onLanguageChanged,
      ),
      body: FutureBuilder<BancoEscoita>(
        future: BancoEscoita.cargar(lang),
        builder: (context, s) {
          final b = s.data;
          if (b == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final seccions = <_Seccion>[
            _Seccion(
              clave: 'escoita_pares',
              icona: Icons.hearing_rounded,
              nome: isGl ? 'Escoita e sinala' : 'Escucha y señala',
              di: isGl
                  ? 'Dúas palabras que só cambian nun son'
                  : 'Dos palabras que solo cambian en un sonido',
              n: b.pares.length,
              abrir: (_) =>
                  _ParesScreen(banco: b, lang: lang, audio: audioService),
            ),
            for (final (clave, icona, nome, di, grupos) in [
              (
                'escoita_progresions',
                Icons.trending_up_rounded,
                isGl ? 'Palabras que medran' : 'Palabras que crecen',
                isGl
                    ? 'O que é, unha parte, o que fai e como é'
                    : 'Qué es, una parte, qué hace y cómo es',
                b.progresions
              ),
              (
                'escoita_capsulas',
                Icons.compare_arrows_rounded,
                isGl ? 'Contrarios' : 'Contrarios',
                isGl
                    ? 'Grande e pequeno, cheo e baleiro…'
                    : 'Grande y pequeño, lleno y vacío…',
                b.capsulas
              ),
              (
                'escoita_escenarios',
                Icons.wb_sunny_rounded,
                isGl ? 'Rutinas do día' : 'Rutinas del día',
                isGl
                    ? 'As palabras da mañá, o baño e a cama'
                    : 'Las palabras de la mañana, el baño y la cama',
                b.escenarios
              ),
              (
                'escoita_categorias',
                Icons.category_rounded,
                isGl ? 'Categorías' : 'Categorías',
                isGl
                    ? 'Froitas, animais, cores, o corpo…'
                    : 'Frutas, animales, colores, el cuerpo…',
                b.categorias
              ),
            ])
              _Seccion(
                clave: clave,
                icona: icona,
                nome: nome,
                di: di,
                n: grupos.length,
                abrir: (_) => _GruposScreen(
                    titulo: nome,
                    grupos: grupos,
                    lang: lang,
                    audio: audioService),
              ),
          ];
          return ListView(
            key: const Key('escoita_lista'),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Text(
                isGl
                    ? 'Para xogar xuntos: a app di a palabra, o neno ou a nena sinala o debuxo e ti tocas o que sinalou.'
                    : 'Para jugar juntos: la app dice la palabra, el niño o la niña señala el dibujo y tú tocas el que señaló.',
                style: const TextStyle(
                    fontSize: 16, height: 1.35, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 14),
              for (var i = 0; i < seccions.length; i++)
                Entrada(
                  orden: i,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TarxetaSeccion(
                      s: seccions[i],
                      onTap: () => Navigator.of(context).push(
                          RutaLua(de: context, builder: seccions[i].abrir)),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Seccion {
  final String clave;
  final IconData icona;
  final String nome;
  final String di;
  final int n;
  final WidgetBuilder abrir;
  const _Seccion({
    required this.clave,
    required this.icona,
    required this.nome,
    required this.di,
    required this.n,
    required this.abrir,
  });
}

class _TarxetaSeccion extends StatelessWidget {
  final _Seccion s;
  final VoidCallback onTap;
  const _TarxetaSeccion({required this.s, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final acento = context.acento;
    return Pulsable(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        child: InkWell(
          key: Key(s.clave),
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              border: Border.all(color: AppTheme.border),
              // El canto de abajo de Valeria: el botón en relieve.
              boxShadow: [
                BoxShadow(
                    color: acento.withAlpha(110), offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: context.acentoTint,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(s.icona, color: acento, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.nome,
                          style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary)),
                      const SizedBox(height: 2),
                      Text(s.di,
                          style: const TextStyle(
                              fontSize: 15, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text('${s.n}',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: acento)),
                Icon(Icons.chevron_right_rounded, color: acento),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// El dibujo de una palabra; sin lámina, la palabra escrita en grande.
class _Debuxo extends StatelessWidget {
  final PezaEscoita p;
  final AppLanguage lang;
  final double ancho;
  const _Debuxo({required this.p, required this.lang, this.ancho = 140});

  @override
  Widget build(BuildContext context) {
    if (p.lamina case final c?) {
      return LaminaPalabra(
          clave: c, significado: p.palabra, lang: lang, ancho: ancho);
    }
    return Semantics(
      image: true,
      label: p.palabra,
      child: Container(
        width: ancho,
        height: ancho * 0.75,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.acentoTint,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(p.palabra,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: context.acento)),
      ),
    );
  }
}

Future<void> _soar(
    OfflineAudioService? a, String texto, AppLanguage lang) async {
  if (a == null || texto.isEmpty) return;
  try {
    await a.playAsset(voiceAssetPath(VoiceStyle.tutor, texto, lang));
  } catch (_) {
    // Sin grabación todavía: el texto sigue en pantalla para leerlo.
  }
}

class _ParesScreen extends StatelessWidget {
  final BancoEscoita banco;
  final AppLanguage lang;
  final OfflineAudioService? audio;
  const _ParesScreen(
      {required this.banco, required this.lang, required this.audio});

  @override
  Widget build(BuildContext context) {
    final isGl = lang == AppLanguage.gl;
    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar:
          AppBar(title: Text(isGl ? 'Escoita e sinala' : 'Escucha y señala')),
      body: ListView(
        key: const Key('escoita_pares_lista'),
        padding: const EdgeInsets.all(16),
        children: [
          for (var i = 0; i < banco.pares.length; i++)
            Entrada(
              orden: i,
              child: Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  key: Key('escoita_par_${banco.pares[i].id}'),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  title: Text(
                      '${banco.pares[i].a.palabra} · ${banco.pares[i].b.palabra}',
                      style: const TextStyle(
                          fontSize: 19, fontWeight: FontWeight.w900)),
                  trailing: Icon(Icons.play_circle_fill_rounded,
                      color: context.acento, size: 34),
                  onTap: () => Navigator.of(context).push(RutaLua(
                      de: context,
                      builder: (_) => XogoPar(
                          par: banco.pares[i], lang: lang, audio: audio))),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// El juego de un par: la app dice una de las dos palabras, el niño señala y
/// la persona adulta toca el dibujo señalado. Acierto: la misión de Valeria
/// para celebrar; si no, la pista y la misión para volver a escuchar.
class XogoPar extends StatefulWidget {
  final ParEscoita par;
  final AppLanguage lang;
  final OfflineAudioService? audio;
  final math.Random? azar;
  const XogoPar(
      {super.key,
      required this.par,
      required this.lang,
      required this.audio,
      this.azar});

  @override
  State<XogoPar> createState() => _XogoParState();
}

class _XogoParState extends State<XogoPar> {
  late final math.Random _azar = widget.azar ?? math.Random();
  PezaEscoita? _dita;
  bool? _acerto;

  void _escoitar() {
    final p = _azar.nextBool() ? widget.par.a : widget.par.b;
    setState(() {
      _dita = p;
      _acerto = null;
    });
    _soar(widget.audio, p.palabra, widget.lang);
  }

  void _sinalou(PezaEscoita p) {
    if (_dita == null) return;
    setState(() => _acerto = identical(p, _dita));
  }

  @override
  Widget build(BuildContext context) {
    final isGl = widget.lang == AppLanguage.gl;
    final par = widget.par;
    final acento = context.acento;
    Widget opcion(PezaEscoita p, String k) => Expanded(
          child: Pulsable(
            child: GestureDetector(
              key: Key(k),
              onTap: () => _sinalou(p),
              child: AnimatedContainer(
                duration: movimientoQuieto(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    width: 4,
                    color: _acerto != null && identical(p, _dita)
                        ? const Color(0xFF15803D)
                        : AppTheme.border,
                  ),
                ),
                child: Column(
                  children: [
                    FittedBox(child: _Debuxo(p: p, lang: widget.lang)),
                    const SizedBox(height: 6),
                    Text(p.palabra,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ),
          ),
        );
    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(title: Text('${par.a.palabra} · ${par.b.palabra}')),
      body: ListView(
        key: const Key('escoita_xogo'),
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            isGl
                ? '1. Tocade «Escoitar». 2. O neno ou a nena sinala o debuxo que oíu. 3. Toca ti o que sinalou.'
                : '1. Tocad «Escuchar». 2. El niño o la niña señala el dibujo que oyó. 3. Toca tú el que señaló.',
            style: const TextStyle(fontSize: 16, height: 1.35),
          ),
          const SizedBox(height: 16),
          Row(children: [
            opcion(par.a, 'escoita_a'),
            const SizedBox(width: 12),
            opcion(par.b, 'escoita_b'),
          ]),
          const SizedBox(height: 16),
          Center(
            child: Latido(
              child: FilledButton.icon(
                key: const Key('escoita_escoitar'),
                style: FilledButton.styleFrom(
                  backgroundColor: acento,
                  minimumSize: const Size(220, 56),
                  textStyle: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w900),
                ),
                onPressed: _escoitar,
                icon: const Icon(Icons.volume_up_rounded),
                label: Text(_dita == null
                    ? (isGl ? 'Escoitar' : 'Escuchar')
                    : (isGl ? 'Outra palabra' : 'Otra palabra')),
              ),
            ),
          ),
          if (_acerto != null) ...[
            const SizedBox(height: 16),
            Entrada(
              key: ValueKey('${_dita!.palabra}$_acerto'),
              child: Container(
                key: const Key('escoita_resposta'),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _acerto!
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFFF4D6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _acerto!
                          ? (isGl
                              ? 'Moi ben! Era «${_dita!.palabra}».'
                              : '¡Muy bien! Era «${_dita!.palabra}».')
                          : (isGl
                              ? 'Era «${_dita!.palabra}». Escoitade outra vez.'
                              : 'Era «${_dita!.palabra}». Escuchad otra vez.'),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    if (!_acerto!) ...[
                      Text(par.pista,
                          style: const TextStyle(fontSize: 16, height: 1.35)),
                      const SizedBox(height: 6),
                    ],
                    Text(_acerto! ? par.misionAcerto : par.misionFallo,
                        style: const TextStyle(fontSize: 16, height: 1.35)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GruposScreen extends StatelessWidget {
  final String titulo;
  final List<GrupoEscoita> grupos;
  final AppLanguage lang;
  final OfflineAudioService? audio;
  const _GruposScreen(
      {required this.titulo,
      required this.grupos,
      required this.lang,
      required this.audio});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppTheme.pageBg,
        appBar: AppBar(title: Text(titulo)),
        body: ListView(
          key: const Key('escoita_grupos'),
          padding: const EdgeInsets.all(16),
          children: [
            for (var i = 0; i < grupos.length; i++)
              Entrada(
                orden: i,
                child: Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(grupos[i].titulo,
                            style: const TextStyle(
                                fontSize: 19, fontWeight: FontWeight.w900)),
                        if (grupos[i].subtitulo.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(grupos[i].subtitulo,
                              style: const TextStyle(
                                  fontSize: 15, color: AppTheme.textSecondary)),
                        ],
                        const SizedBox(height: 10),
                        for (final p in grupos[i].pezas)
                          _FilaPeza(p: p, lang: lang, audio: audio),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}

class _FilaPeza extends StatelessWidget {
  final PezaEscoita p;
  final AppLanguage lang;
  final OfflineAudioService? audio;
  const _FilaPeza({required this.p, required this.lang, required this.audio});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Debuxo(p: p, lang: lang, ancho: 96),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(
                      child: Text(p.palabra,
                          style: const TextStyle(
                              fontSize: 19, fontWeight: FontWeight.w900)),
                    ),
                    IconButton(
                      tooltip: lang == AppLanguage.gl ? 'Escoitar' : 'Escuchar',
                      icon:
                          Icon(Icons.volume_up_rounded, color: context.acento),
                      onPressed: () => _soar(audio, p.palabra, lang),
                    ),
                  ]),
                  if (p.frase.isNotEmpty)
                    Text(p.frase, style: const TextStyle(fontSize: 16)),
                  if (p.accion.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(p.accion,
                        style: const TextStyle(
                            fontSize: 15,
                            height: 1.3,
                            color: AppTheme.textSecondary)),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
}
