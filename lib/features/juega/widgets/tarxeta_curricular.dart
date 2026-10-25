import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/ruta_lua.dart';
import '../../../data/models/conto_dialogado_model.dart';
import '../../../data/models/steam_do_mes_model.dart';
import '../../../data/models/unidade_curricular_model.dart';
import '../../cuentos/views/contos_dialogados_screen.dart';
import '../../steam/views/steam_do_mes_screen.dart';

/// La unidad del plan curricular de Frank que toca este mes (F11): su título,
/// en qué mes de la unidad se está, los objetivos y el vocabulario diana con
/// voz y significado; debajo, plegado, cómo se trabaja.
class TarxetaCurricular extends StatefulWidget {
  final String cursoId;
  final int mesCalendario;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  /// En casa: sin dinámica de aula, con la orientación para la familia.
  final bool enCasa;

  /// Con los botones de cuentos y STEAM. Hoxe los enseña fuera, como pasos
  /// propios (F10), y aquí los quita para no repetirlos.
  final bool conAccesos;

  const TarxetaCurricular({
    super.key,
    required this.cursoId,
    required this.mesCalendario,
    required this.language,
    this.audioService,
    this.enCasa = false,
    this.conAccesos = true,
  });

  @override
  State<TarxetaCurricular> createState() => _TarxetaCurricularState();
}

class _TarxetaCurricularState extends State<TarxetaCurricular> {
  late final Future<PlanCurricular> _plan = PlanCurricular.cargar();
  late final Future<BibliotecaDialogada?> _biblioteca =
      BibliotecaDialogada.cargar()
          .then<BibliotecaDialogada?>((b) => b)
          .catchError((Object _) => null);
  // Sin catchError: en un SynchronousFuture no completa nunca.
  late final Future<SteamDoMes?> _steam =
      SteamDoMes.cargar().then<SteamDoMes?>((s) => s, onError: (_) => null);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PlanCurricular>(
      future: _plan,
      builder: (context, snap) {
        final plan = snap.data;
        final u = plan?.para(widget.cursoId, widget.mesCalendario);
        if (plan == null || u == null) return const SizedBox.shrink();
        final lang = widget.language;
        final isGl = lang == AppLanguage.gl;
        final (n, de) = plan.mesDentro(widget.cursoId, widget.mesCalendario);
        Widget chips(List<FraseCurricular> fs) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final f in fs)
                  BotonEscuchar(
                    audioService: widget.audioService,
                    texto: f.en,
                    language: AppLanguage.en,
                    interfaz: lang,
                    comoChip: true,
                    significado: f.significado,
                  ),
              ],
            );
        // Material y no Container: el ExpansionTile pinta su toque en el
        // Material más cercano, y un fondo intermedio lo taparía.
        return Padding(
          key: ValueKey('plan_curricular_${u.id}'),
          padding:
              EdgeInsets.only(top: widget.conAccesos ? AppTheme.spaceMd : 0),
          child: Material(
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
                    (isGl
                            ? 'PLAN CURRICULAR · MES $n DE $de DA UNIDADE'
                            : 'PLAN CURRICULAR · MES $n DE $de DE LA UNIDAD')
                        .toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: context.acento,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    u.titulo.resolve(lang),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (u.objetivos.isNotEmpty) ...[
                    _Rotulo(isGl ? 'Obxectivos' : 'Objetivos'),
                    for (final o in u.objetivos) _Texto('· ${o.resolve(lang)}'),
                  ],
                  if (u.vocabulario.isNotEmpty) ...[
                    _Rotulo(isGl
                        ? 'Vocabulario diana (dous toques: o significado)'
                        : 'Vocabulario diana (dos toques: el significado)'),
                    chips(u.vocabulario),
                  ],
                  // F12: los cuentos dialogados de esta unidad del plan.
                  if (widget.conAccesos)
                    FutureBuilder<BibliotecaDialogada?>(
                      future: _biblioteca,
                      builder: (context, b) {
                        final contos = b.data?.daUnidade(u.id) ?? const [];
                        if (contos.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: OutlinedButton.icon(
                            key: ValueKey('contos_da_unidade_${u.id}'),
                            onPressed: () => Navigator.of(context).push(RutaLua(
                              de: context,
                              builder: (_) => ContosDialogadosScreen(
                                unidade: u.id,
                                tituloUnidade: u.titulo.resolve(lang),
                                contos: contos,
                                language: lang,
                                audioService: widget.audioService,
                              ),
                            )),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, AppTheme.touchMin),
                              alignment: Alignment.centerLeft,
                            ),
                            icon: const Icon(Icons.auto_stories_rounded),
                            label: Text(
                              isGl
                                  ? 'Contos desta unidade (${contos.length})'
                                  : 'Cuentos de esta unidad (${contos.length})',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        );
                      },
                    ),
                  // F8: el experimento STEAM de este mes, atado a la unidad.
                  if (widget.conAccesos)
                    FutureBuilder<SteamDoMes?>(
                      future: _steam,
                      builder: (context, s) {
                        final e =
                            s.data?.para(widget.cursoId, widget.mesCalendario);
                        if (e == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: OutlinedButton.icon(
                            key: ValueKey('steam_do_mes_boton_${e.id}'),
                            onPressed: () => Navigator.of(context).push(RutaLua(
                              de: context,
                              builder: (_) => SteamDoMesScreen(
                                experimento: e,
                                language: lang,
                                audioService: widget.audioService,
                                enCasa: widget.enCasa,
                              ),
                            )),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, AppTheme.touchMin),
                              alignment: Alignment.centerLeft,
                            ),
                            icon: const Icon(Icons.science_rounded),
                            label: Text(
                              'STEAM · ${e.nomeFenomeno.resolve(lang)}: ${e.titulo.resolve(lang)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        );
                      },
                    ),
                  Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      key: ValueKey('plan_curricular_mais_${u.id}'),
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: EdgeInsets.zero,
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      title: Text(
                        isGl ? 'Como se traballa' : 'Cómo se trabaja',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: context.acento,
                        ),
                      ),
                      children: [
                        if (u.accionsTPR.isNotEmpty) ...[
                          _Rotulo(isGl ? 'Accións TPR' : 'Acciones TPR'),
                          for (final a in u.accionsTPR)
                            _Texto('${a.en} — ${a.xesto?.resolve(lang) ?? ''}'),
                        ],
                        if (u.formulas.isNotEmpty) ...[
                          _Rotulo(
                              isGl ? 'Fórmulas de xogo' : 'Fórmulas de juego'),
                          chips(u.formulas),
                        ],
                        if (u.estructuras.isNotEmpty) ...[
                          _Rotulo(isGl ? 'Estruturas' : 'Estructuras'),
                          chips(u.estructuras),
                        ],
                        if (u.rimas.isNotEmpty) ...[
                          _Rotulo(isGl ? 'Rimas' : 'Rimas'),
                          chips(u.rimas),
                        ],
                        if (u.realia.isNotEmpty) ...[
                          _Rotulo(isGl ? 'Material real' : 'Material real'),
                          for (final r in u.realia)
                            _Texto('· ${r.resolve(lang)}'),
                        ],
                        if (u.fonoloxia case final f?) ...[
                          _Rotulo(isGl ? 'O son' : 'El sonido'),
                          _Texto(f.resolve(lang)),
                        ],
                        if (!widget.enCasa)
                          for (final (rotulo, texto) in u.dinamica) ...[
                            _Rotulo(rotulo.resolve(lang)),
                            _Texto(texto.resolve(lang)),
                          ],
                        if (u.frasesAdulta.isNotEmpty) ...[
                          _Rotulo(isGl ? 'O que dis ti' : 'Lo que dices tú'),
                          chips(u.frasesAdulta),
                        ],
                        if (widget.enCasa)
                          if (u.familia case final f?) ...[
                            _Rotulo(isGl ? 'Na casa' : 'En casa'),
                            _Texto(f.resolve(lang)),
                          ],
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Rotulo extends StatelessWidget {
  final String texto;
  const _Rotulo(this.texto);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 6),
        child: Text(
          texto,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
      );
}

class _Texto extends StatelessWidget {
  final String texto;
  const _Texto(this.texto);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          texto,
          style: const TextStyle(
            fontSize: 15,
            color: AppTheme.textPrimary,
            height: 1.4,
          ),
        ),
      );
}
