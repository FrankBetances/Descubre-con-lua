import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';

/// 0-2 años por proyectos (O-20261109-4, ACOPROS): un proyecto por mes con
/// unas 20 palabras, su canción, una rima tradicional y cuatro semanas que
/// empiezan por el vocabulario y la canción. Sin gramática: «Ya debería
/// saber» son palabras sueltas y «Cómo hablar», frases de dos elementos con
/// su gesto. Lo genera `tools/gen_acopros_0_2.py` del material de 0-2.
class PalabraProxecto {
  final String en;
  final LocalizedString significado;
  final LocalizedString xesto;

  /// O-20261111-2: la lámina que dibuja ESTA palabra y su gesto.
  final String? lamina;
  const PalabraProxecto(
      {required this.en,
      required this.significado,
      required this.xesto,
      this.lamina});
}

class Proxecto02 {
  final int mesCalendario;
  final LocalizedString titulo;
  final LocalizedString? steam;
  final LocalizedString cancion;
  final String rimaEn;
  final LocalizedString rima;

  /// O-20261111-2: las láminas de la canción y de la rima.
  final String? cancionLamina;
  final String? rimaLamina;
  final List<PalabraProxecto> palabras;
  final List<({int semana, LocalizedString fase, List<String> palabras})>
      semanas;
  final List<String> comoFalar;
  final List<String> xaSabe;
  final LocalizedString guia;

  const Proxecto02({
    required this.mesCalendario,
    required this.titulo,
    required this.steam,
    required this.cancion,
    required this.rimaEn,
    required this.rima,
    this.cancionLamina,
    this.rimaLamina,
    required this.palabras,
    required this.semanas,
    required this.comoFalar,
    required this.xaSabe,
    required this.guia,
  });

  PalabraProxecto? palabra(String en) =>
      palabras.where((p) => p.en == en).firstOrNull;

  /// Las palabras de la semana 1 a 4 (la 5.ª es la 4.ª).
  List<PalabraProxecto> daSemana(int semana) {
    final s = semanas[(semana.clamp(1, semanas.length)) - 1];
    return [
      for (final en in s.palabras)
        if (palabra(en) case final p?) p,
    ];
  }
}

class Proxectos02 {
  final List<Proxecto02> proxectos;
  const Proxectos02(this.proxectos);

  static const assetPath = 'assets/content/acopros/proxectos_0_2.json';
  static Proxectos02? _lidos;
  static Future<Proxectos02>? _enCurso;
  static Proxectos02? get lidos => _lidos;

  static Future<Proxectos02> cargar() => _enCurso ??=
      rootBundle.loadString(assetPath).then((r) => _lidos = fromRaw(r));

  @visibleForTesting
  static void sembrar(Proxectos02 p) {
    _lidos = p;
    _enCurso = SynchronousFuture(p);
  }

  Proxecto02? doMes(int mes) =>
      proxectos.where((p) => p.mesCalendario == mes).firstOrNull;

  static LocalizedString _t(Object? v) => LocalizedString.fromJson(
      Map<String, dynamic>.from(v is Map ? v : const {}));

  static Proxectos02 fromRaw(String raw) {
    final j = json.decode(raw) as Map<String, dynamic>;
    List<String> l(Object? v) => [for (final x in v as List) x.toString()];
    return Proxectos02([
      for (final p in j['proxectos'] as List)
        Proxecto02(
          mesCalendario: p['mesCalendario'] as int,
          titulo: _t(p['proxecto']),
          steam: p['steam'] is Map
              ? _t((p['steam'] as Map)['titulo'] ?? p['steam'])
              : null,
          cancion: _t(p['cancion']),
          rimaEn: (p['rima'] as Map)['en'] as String,
          rima: _t(p['rima']),
          cancionLamina: (p['cancion'] as Map)['lamina'] as String?,
          rimaLamina: (p['rima'] as Map)['lamina'] as String?,
          palabras: [
            for (final w in p['palabras'] as List)
              PalabraProxecto(
                en: w['en'] as String,
                significado: _t(w),
                xesto: _t(w['xesto']),
                lamina: w['lamina'] as String?,
              ),
          ],
          semanas: [
            for (final s in p['semanas'] as List)
              (
                semana: s['semana'] as int,
                fase: _t(s['fase']),
                palabras: l(s['palabras']),
              ),
          ],
          comoFalar: l(p['comoFalar']),
          xaSabe: l(p['xaSabe']),
          guia: _t(p['guia']),
        ),
    ]);
  }
}

/// La lección de 0-2: el proyecto del mes y lo de esta semana.
class LeccionProxecto02 extends StatefulWidget {
  final int mesCalendario;
  final int semana;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  const LeccionProxecto02({
    super.key,
    required this.mesCalendario,
    required this.semana,
    required this.language,
    this.audioService,
  });

  @override
  State<LeccionProxecto02> createState() => _LeccionProxecto02State();
}

class _LeccionProxecto02State extends State<LeccionProxecto02> {
  Proxectos02? _p = Proxectos02.lidos;

  @override
  void initState() {
    super.initState();
    if (_p == null) {
      Proxectos02.cargar().then((p) {
        if (mounted) setState(() => _p = p);
      }, onError: (_) {});
    }
  }

  Widget _escoitar(String en, LocalizedString? significado) => BotonEscuchar(
        audioService: widget.audioService,
        texto: en,
        language: AppLanguage.en,
        interfaz: widget.language,
        style: estiloIngles(en),
        comoChip: true,
        colorChip: context.acento,
        descripcion: en,
        significado: significado,
      );

  @override
  Widget build(BuildContext context) {
    final pr = _p?.doMes(widget.mesCalendario);
    if (pr == null) return const SizedBox.shrink();
    final lang = widget.language;
    final isGl = lang == AppLanguage.gl;
    final acento = context.acento;
    final s = pr.semanas[(widget.semana.clamp(1, pr.semanas.length)) - 1];
    final daSemana = pr.daSemana(widget.semana);

    Widget seccion(Key key, String titulo, List<Widget> fillos) => Padding(
          key: key,
          padding: const EdgeInsets.only(top: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo.toUpperCase(),
                  style: TextStyle(
                      fontSize: 13,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w900,
                      color: acento)),
              const SizedBox(height: 6),
              ...fillos,
            ],
          ),
        );

    Text corpo(String t) => Text(t,
        style: const TextStyle(
            fontSize: 15, height: 1.35, color: AppTheme.textPrimary));

    return Material(
      key: const Key('proxecto_0_2'),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                isGl
                    ? 'PROXECTO DO MES · 0-2 ANOS'
                    : 'PROYECTO DEL MES · 0-2 AÑOS',
                style: TextStyle(
                    fontSize: 13,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w900,
                    color: acento)),
            const SizedBox(height: 4),
            Text(pr.titulo.resolve(lang),
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary)),
            if (pr.steam case final st?)
              Text('STEAM: ${st.resolve(lang)}',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: acento)),
            seccion(
              const Key('proxecto_semana'),
              '${isGl ? 'Semana' : 'Semana'} ${s.semana} · ${s.fase.resolve(lang)}',
              [
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final p in daSemana) _escoitar(p.en, p.significado),
                ]),
              ],
            ),
            seccion(const Key('proxecto_cancion'),
                isGl ? 'A canción do proxecto' : 'La canción del proyecto', [
              corpo('«${pr.cancion.resolve(lang)}»'),
            ]),
            seccion(const Key('proxecto_rima'),
                isGl ? 'Rima tradicional' : 'Rima tradicional', [
              _escoitar(pr.rimaEn, pr.rima),
              const SizedBox(height: 4),
              Text(pr.rima.resolve(lang),
                  style: const TextStyle(
                      fontSize: 14, color: AppTheme.textSecondary)),
            ]),
            seccion(
                const Key('proxecto_como_falar'),
                isGl
                    ? 'Como falar: dúas palabras, co xesto'
                    : 'Cómo hablar: dos palabras, con el gesto',
                [
                  for (final f in pr.comoFalar)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _escoitar(f, pr.palabra(f)?.significado),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                                pr.palabra(f)?.xesto.resolve(lang) ?? '',
                                style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.3,
                                    color: AppTheme.textSecondary)),
                          ),
                        ],
                      ),
                    ),
                ]),
            seccion(const Key('proxecto_xa_sabe'),
                isGl ? 'Xa debería saber' : 'Ya debería saber', [
              if (pr.xaSabe.isEmpty)
                corpo(isGl
                    ? 'É o primeiro proxecto: empezamos.'
                    : 'Es el primer proyecto: empezamos.')
              else
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final w in pr.xaSabe) _escoitar(w, null),
                ]),
            ]),
            seccion(const Key('proxecto_guia'), isGl ? 'Guía' : 'Guía',
                [corpo(pr.guia.resolve(lang))]),
            Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                key: const Key('proxecto_palabras'),
                tilePadding: EdgeInsets.zero,
                title: Text(
                    isGl
                        ? 'As ${pr.palabras.length} palabras do proxecto'
                        : 'Las ${pr.palabras.length} palabras del proyecto',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary)),
                children: [
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final p in pr.palabras) _escoitar(p.en, p.significado),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Las palabras de la semana del proyecto de 0-2, para «Más material del
/// día» (ACOPROS: «20 palabras bien escogidas», no el banco diario).
class PalabrasProxecto02 extends StatelessWidget {
  final int mesCalendario;
  final int semana;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  const PalabrasProxecto02({
    super.key,
    required this.mesCalendario,
    required this.semana,
    required this.language,
    this.audioService,
  });

  @override
  Widget build(BuildContext context) {
    final pr = Proxectos02.lidos?.doMes(mesCalendario);
    if (pr == null) return const SizedBox.shrink();
    final isGl = language == AppLanguage.gl;
    return Column(
      key: const Key('palabras_proxecto_0_2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            isGl
                ? 'As palabras desta semana, das ${pr.palabras.length} do proxecto'
                : 'Las palabras de esta semana, de las ${pr.palabras.length} del proyecto',
            style:
                const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final p in pr.daSemana(semana))
            BotonEscuchar(
              audioService: audioService,
              texto: p.en,
              language: AppLanguage.en,
              interfaz: language,
              style: estiloIngles(p.en),
              comoChip: true,
              colorChip: context.acento,
              descripcion: p.en,
              significado: p.significado,
            ),
        ]),
      ],
    );
  }
}
